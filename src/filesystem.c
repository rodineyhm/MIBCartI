#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "filesystem.h"
#include "intellicart.h"
#include "memory.h"
#include "vfs.h"
#include "launcher.h"
#include "utils.h"
#include "audio.h"

#if PICO_RP2350
   #include "pico/sha256.h"
#endif

// Suporte a Criptografia e Leitura de ID Único da Placa
#include "aes.h"
#include "pico/unique_id.h"

extern Cartridge cart;
extern mm_map_t m;

extern uint8_t tv_mode;      // 0: PAL, 1: NTSC
extern uint8_t ecs_present;  // 0: ECS absent, 1: ECS present
extern uint8_t voice_present; // 0: iVoice absent, 1: iVoice Absent
extern uint8_t audio_volume;

static const uint8_t MASKED_SECRET_KEY[16] = {
   0x84, 0x1D, 0x91, 0x5A, 0xE8, 0x10, 0x81, 0x54,
   0xEC, 0x1B, 0x9C, 0x25, 0x95, 0x6B, 0xF5, 0x36
};

static const uint8_t MASK_PATTERN[4] = { 0xA5, 0x59, 0xC3, 0x17 };

// Gera a chave AES-128 de 16 bytes combinando o Serial da placa com a Master Key
static void get_board_aes_key(uint8_t key_out[16]) {
   char serial_str[17] = {0};
   pico_get_unique_board_id_string(serial_str, sizeof(serial_str));

   uint8_t master_key_buf[16];

   // 1. Reconstrói a chave mestre na RAM temporariamente usando o padrão multibyte
   for (int i = 0; i < 16; i++) {
      master_key_buf[i] = MASKED_SECRET_KEY[i] ^ MASK_PATTERN[i % sizeof(MASK_PATTERN)];
   }

   // 2. Combina o serial da placa com a chave mestre reconstruída
   for (int i = 0; i < 16; i++) {
      char c = serial_str[i];
      if (c >= 'a' && c <= 'z') c -= 32; // Garante caixa alta
      
      key_out[i] = (uint8_t)c ^ master_key_buf[i];
   }

   // 3. Limpa a chave mestre do buffer da RAM imediatamente após o uso
   volatile uint8_t *p = master_key_buf;
   for (size_t i = 0; i < sizeof(master_key_buf); i++) {
      p[i] = 0;
   }
}


#define ROTRIGHT(a,b) (((a) >> (b)) | ((a) << (32 - (b))))
#define CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
#define MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define EP0(x) (ROTRIGHT(x,2) ^ ROTRIGHT(x,13) ^ ROTRIGHT(x,22))
#define EP1(x) (ROTRIGHT(x,6) ^ ROTRIGHT(x,11) ^ ROTRIGHT(x,25))
#define SIG0(x) (ROTRIGHT(x,7) ^ ROTRIGHT(x,18) ^ ((x) >> 3))
#define SIG1(x) (ROTRIGHT(x,17) ^ ROTRIGHT(x,19) ^ ((x) >> 10))


// ============================================================================
// FUNÇÕES DO FILESYSTEM
// ============================================================================

int entry_compare(const void *p1, const void *p2) {
   SCREEN_ENTRY *e1 = (SCREEN_ENTRY *) p1;
   SCREEN_ENTRY *e2 = (SCREEN_ENTRY *) p2;

   if (e1->isDir && !e2->isDir)
      return -1;
   else if (!e1->isDir && e2->isDir)
      return 1;
   else
      return strncasecmp(e1->filename, e2->filename, 64 );
}

char *get_filename_ext(char *filename) {
   char *dot = strrchr(filename, '.');

   if (!dot || dot == filename)
      return "";
   return dot + 1;
}

int is_rom_file(char *filename) {
   char inputBuffer[3];
   vfs_file_t *f;

   if ( (f = vfs_open(filename, "r")) == NULL) {
      printf("load_file %s error\n", filename);
      return -1;
   }

   vfs_read(f, inputBuffer, sizeof(inputBuffer));
   vfs_close(f);

   return !((inputBuffer[0] != 0xA8 && (inputBuffer[0] & ~0x20) != 0x41) ||
         (inputBuffer[1] ^ inputBuffer[2]) != 0xFF);
}

int is_valid_file(char *filename) {
   char *ext = get_filename_ext(filename);

   return (strcasecmp(ext, "BIN") == 0 || strcasecmp(ext, "INT") == 0 || 
         strcasecmp(ext, "ITV") == 0 || strcasecmp(ext, "ROM") == 0 ||
         strcasecmp(ext, "MIB") == 0);
}

int read_directory(char *path, SCREEN_ENTRY *dst) {

   unsigned int id = 0;
   SCREEN_ENTRY *orig_dst = dst;
   vfs_dirent_t ent;

   vfs_dir_t *dir = vfs_opendir(path);
   if (!dir) {
      printf("read_directory: vfs_opendir error (%s)\n", path);
      return -1;
   };

   while ((vfs_readdir(dir, &ent) > 0) & (id<512)) {

      if ((strcmp(ent.name, ".") == 0 || strcmp(ent.name, "..") == 0))
         continue;

      if ( (ent.type & VFS_TYPE_HIDDEN) || (ent.type & VFS_TYPE_SYSTEM) )
         continue;

      dst->isDir = (ent.type & VFS_TYPE_DIR) ? 1 : 0;

      if (!dst->isDir)
         if (!is_valid_file(ent.name))
            continue;

      dst->id = id++;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstringop-truncation"
      strncpy(dst->filename, ent.name, 64);
#pragma GCC diagnostic pop

      dst++;
   }
   vfs_closedir(dir);

   qsort(orig_dst, id, sizeof(SCREEN_ENTRY), entry_compare);
   
   return id;
}

int load_file(char *filename) {

   unsigned int size = 0;
   unsigned char buf[2];
   vfs_stat_t st;

   if (vfs_stat(filename, &st) == 0) {
      printf("file size: %d bytes\n", st.size);
      if (st.size > MAX_ROM_SIZE*2) {
         printf("file size exceeds maximum supported size of %d bytes\n", MAX_ROM_SIZE*2);
         return -2;
      }
   }
   
   printf("load_file(): filename %s\n", filename);
   vfs_file_t *f = vfs_open(filename, "r");

   if (f == NULL) {
      printf("load_file %s error\n", filename);
      return -1;
   }

   // init cartridge
   init_cart();

   // handle Intellicart rom file
   if(is_rom_file(filename)) {

      uint32_t from, prev_from;
      uint16_t prev_size, target;
      char inputBuffer[3];

      mm_init(&m);

      vfs_read(f, inputBuffer, sizeof(inputBuffer));
      
      int slots = inputBuffer[1];

      for(int i=0; i<slots; i++) {

         vfs_read(f, inputBuffer, 2);

         int lo = inputBuffer[0] << 8;
         int hi = (inputBuffer[1] << 8) + 0x100;

         target = lo;
         if (i == 0)
            from = 0x0000;
         else
            from = prev_from + prev_size + 1;

         prev_size = (hi - lo) - 1;
         prev_from = from;

         mm_add(&m, from, from + (hi - lo) - 1, target, MM_NO_PAGE);

         for (int j = lo; j < hi; j++) {

            vfs_read(f, inputBuffer, 2);
            cart.ROM[size] = inputBuffer[1] | (inputBuffer[0] << 8);
            size++;
         }

         vfs_read(f, inputBuffer, 2);
      }

      char memattr[50];

      vfs_read(f, memattr, sizeof(memattr));

      for (int i = 0; i < 32; i++) {
         
         int attr = 0xF & (memattr[(i >> 1)] >> ((i & 1) * 4));
         int lohi = memattr[16 + ((i >> 1) | ((i & 1) << 4))];
         int lo   = (lohi >> 4) & 0x7;
         int hi   = (lohi & 0x7) + 1;

         if(attr & 0x02) { 

            uint8_t w;

            if(attr & 0x04)
               w = 8;
            else w = 16;

            mm_add_ram(&m, i * 0x800, (i * 0x800) + ((hi - lo) * 0x100) - 1, w);
         }
      }

      if (!vfs_eof(f)) {

         printf("ROM has metadata section @%d\n", size);

         while (!vfs_eof(f)) {

            vfs_read(f, inputBuffer, 1);

            int nb = inputBuffer[0] >> 6;
            int len = inputBuffer[0] & 0x3F;

            for(int i=0; i<nb; i++) {
               vfs_read(f, inputBuffer, 1);
               len |= inputBuffer[0] << (6 + i*8);
            }

            vfs_read(f, inputBuffer, 1);

            int tag = inputBuffer[0];

            if (tag == 0x06) {

               vfs_read(f, inputBuffer, 1);
               
#if CONFIG_ECS_AUDIO || CONFIG_INTELLIVOICE
               if (ecs_present == 0) {
                  if ( (inputBuffer[0] >> 6) != 0 ) {
                     cart.ECSSupport = true;
                  }
               }
               if (voice_present == 0) {
                  if ( (inputBuffer[0] >> 4) & 0x02 ) {
                     cart.IntellivoiceSupport = true;
                     printf("Intellivoice emulation enabled\n");
                  }
               }
#endif
               vfs_read(f, inputBuffer, 2);
            
               if(len > 3) {

                  vfs_read(f, inputBuffer, 2);

#if CONFIG_JLP
                  int jlp_value = inputBuffer[0] >> 6;
                  int jlpflash_value = inputBuffer[1];

                  config_jlp(jlp_value, jlpflash_value, filename);
#endif
               }

            } else {

               for(int i=0; i<len; i++) 
                  vfs_read(f, inputBuffer, 1);
            }

            vfs_read(f, inputBuffer, 2);
         }
      }


} else if (strcasecmp(get_filename_ext(filename), "MIB") == 0) {

      char header[4];
      if (vfs_read(f, header, 4) < 4 || memcmp(header, "MIB\x01", 4) != 0) {
         printf("load_file: Header MIB invalido!\n");
         vfs_close(f);
         return -3;
      }

      uint8_t iv[16];
      vfs_read(f, iv, 16);

      size_t payload_len = st.size - 20; 

      // Obtém a chave AES atrelada ao Serial da placa
      uint8_t aes_key[16];
      get_board_aes_key(aes_key);

      struct AES_ctx aes_ctx;
      AES_init_ctx_iv(&aes_ctx, aes_key, iv);

      // Lê e descriptografa o ficheiro inteiro em blocos de 512 bytes
      uint8_t chunk[512];
      size_t bytes_left = payload_len;

      while (bytes_left > 0) {
         size_t to_read = (bytes_left > 512) ? 512 : bytes_left;
         size_t r = vfs_read(f, chunk, to_read);
         if (r < 2) break;

         // Descriptografa o bloco atual (o aes_ctx incrementa o contador automaticamente)
         AES_CTR_xcrypt_buffer(&aes_ctx, chunk, r);

         // Preenche a ROM do cartucho
         for (size_t i = 0; i < r; i += 2) {
            cart.ROM[size] = chunk[i+1] | (chunk[i] << 8);
            size++;
         }
         bytes_left -= r;
      }

      // O ficheiro é fechado automaticamente no final de load_file()

   } else {
      // handle raw rom file (.BIN, .INT, .ITV)

#if PICO_RP2350
      pico_sha256_state_t state;
      sha256_result_t result;
      pico_sha256_start_blocking(&state, SHA256_BIG_ENDIAN, true);
#endif

      while (!(vfs_eof(f))) {
         vfs_read(f, buf, sizeof(buf));
         cart.ROM[size] = buf[1] | (buf[0] << 8);
         size++;
      }

#if PICO_RP2350
      pico_sha256_update_blocking(&state, (const uint8_t*)cart.ROM, (size*2) - 1);
      pico_sha256_finish(&state, &result);
      
      printf("SHA256: ");
      for (int i = 0; i < SHA256_RESULT_BYTES; i++)
         printf("%02x", result.bytes[i]);
      printf("\n");
#endif
   }

   cart.len = size;
   vfs_close(f);

   printf("load_file: size: %ld bytes\n", cart.len*2);
   return 0;
}

int get_file_from_id(unsigned int id, char *path) {
   unsigned int i = 0;
   vfs_dir_t *dir;
   vfs_dirent_t ent;

   printf("id: %d, path: %s\n", id, path);

   if ( (dir = vfs_opendir(path)) != NULL) {

      while (1) {

         if (vfs_readdir(dir, &ent) <= 0)
            break;

         if ((strcmp(ent.name, ".") == 0 || strcmp(ent.name, "..") == 0) || ent.name[0] == '.')
            continue;

         if ( (ent.type & VFS_TYPE_HIDDEN) || (ent.type & VFS_TYPE_SYSTEM) )
            continue;

         if ( !(ent.type & VFS_TYPE_DIR) )
            if (!is_valid_file(ent.name))
               continue;

         if (i++ == id) {
            strcat(path, "/");
            strcat(path, ent.name);
            vfs_closedir(dir);
            return 0;
         }
      }
      vfs_closedir(dir);
   }
   return -1;
}

int load_file_by_id(unsigned int id, char *path) {

   int result = get_file_from_id(id, path);
   if (result == 0) {
      printf("load_file_by_id: id %d, opening %s\n", id, path);

      result = load_file(path);
      if (result != 0) {
         printf("load_file_by_id: failed to load %s\n", path);

         char *last_slash = strrchr(path, '/');
         if (last_slash)                  
            *last_slash = 0; 
      }
   }
   return result;
}

int collect_info_by_id(unsigned int id, char *path, INFO_ENTRY *info_entries) {

   int result = get_file_from_id(id, path);
   if (result == 0) {
      printf("collect_info_by_id: id %d, opening %s\n", id, path);

      result = collect_info(path, info_entries);

      char *last_slash = strrchr(path, '/');
      if (last_slash)                  
         *last_slash = 0; 

   }
   return result;
}