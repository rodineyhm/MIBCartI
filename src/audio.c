#include <stdlib.h>
#include <stdio.h>

#include "pico/stdlib.h"
#include "hardware/timer.h"
#include "hardware/pwm.h"
#include "hardware/structs/pwm.h"

#include "board.h"
#include "audio.h"
#include "emu2149.h"
#include "ivoice.h"
#include "intellicart.h"

extern Cartridge cart;     // main data structure for cart emulation

static repeating_timer_t timer;
PSG* psg0 = NULL;
uint8_t AudioVolume;

static uint8_t current_tv_mode = 1; // 0 = PAL, 1 = NTSC
static bool audio_initialized = false;

#define MELODY_LENGTH 8

#define MELODY_LENGTH 8

// Estrutura [8][3]: [Nota][Canal A, Canal B, Canal C]
static const uint16_t melody_ntsc[MELODY_LENGTH][3] = {
    {320, 641, 1281}, // F4 / F3 / F2
    {285, 571, 1141}, // G4 / G3 / G2
    {254, 508, 1017}, // A4 / A3 / A2
    {214, 428, 855},  // C5 / C4 / C3
    {190, 381, 762},  // D5 / D4 / D3
    {214, 428, 855},  // C5 / C4 / C3
    {254, 508, 1017}, // A4 / A3 / A2
    {285, 571, 1141}  // G4 / G3 / G2
};

static const uint16_t melody_pal[MELODY_LENGTH][3] = {
    {358, 716, 1432}, // F4 / F3 / F2
    {319, 638, 1276}, // G4 / G3 / G2
    {284, 568, 1136}, // A4 / A3 / A2
    {239, 478, 956},  // C5 / C4 / C3
    {213, 426, 851},  // D5 / D4 / D3
    {239, 478, 956},  // C5 / C4 / C3
    {284, 568, 1136}, // A4 / A3 / A2
    {319, 638, 1276}  // G4 / G3 / G2
};

static const uint16_t melody_durations[MELODY_LENGTH] = {13320, 13320, 13320, 13320, 13320, 13320, 13320, 20000};



#define NOTE_GATE_TICKS 1000 // Silêncio/articulação entre notas (~25ms)

// Controle do Sequenciador
static volatile bool     melody_playing = false;
static volatile uint8_t  melody_index   = 0;
static volatile uint16_t melody_ticks   = 0;

const uint8_t ECS_LUT[16] = {
   0x00, 0x02, 0x04, 0x0B,
   0x01, 0x03, 0x05, 0x0C,
   0x07, 0x06, 0x0D, 0x08,
   0x09, 0x0A, 0x0E, 0x0F
};

#define GPIO_TO_SLICE(g) ((g) < 32 ? (((g) >> 1) & 7) : (8 + (((g) >> 1) & 3)))

static void play_melody_note(uint8_t index) {
   if (psg0 == NULL) return;

   uint16_t pA = (current_tv_mode == 0) ? melody_pal[index][0] : melody_ntsc[index][0];
   uint16_t pB = (current_tv_mode == 0) ? melody_pal[index][1] : melody_ntsc[index][1];
   uint16_t pC = (current_tv_mode == 0) ? melody_pal[index][2] : melody_ntsc[index][2];

   // Canal A (Regs 0 e 1)
   PSG_writeReg(psg0, 0, pA & 0xFF);
   PSG_writeReg(psg0, 1, (pA >> 8) & 0x0F);

   // Canal B (Regs 2 e 3)
   PSG_writeReg(psg0, 2, pB & 0xFF);
   PSG_writeReg(psg0, 3, (pB >> 8) & 0x0F);

   // Canal C (Regs 4 e 5)
   PSG_writeReg(psg0, 4, pC & 0xFF);
   PSG_writeReg(psg0, 5, (pC >> 8) & 0x0F);

   // Reg 7 (Mixer): 0xF8 (1111 1000 em binário -> Tom Habilitado em A, B e C; Ruído Desabilitado)
   PSG_writeReg(psg0, 7, 0xF8);

   // Volumes Individuais (Regs 8, 9 e 10)
   PSG_writeReg(psg0, 8, 0x0F); // Canal A
   PSG_writeReg(psg0, 9, 0x0F); // Canal B
   PSG_writeReg(psg0, 10, 0x0F); // Canal C
}




bool __not_in_flash_func(audio_callback)(repeating_timer_t *rt) {   
   static int32_t ecs_raw = 0;
   static int32_t ivoice_raw = 0;
   static uint8_t audio_cycle = 0;

#ifndef NDEBUG
   static uint16_t cnt = 0;
   if (cnt++ >= 8000) {
      cnt = 0;
      printf("audio_callback: ecs=%08lX, ivoice=%08lX\n", ecs_raw, ivoice_raw); 
   }
#else
   /* aplica controle de volume de 8 bits e normaliza para PWM de 10 bits */
   uint16_t pwm = (uint16_t)((((uint32_t)(ecs_raw + ivoice_raw) * (uint32_t)(AudioVolume + 1) / 3) >> 10));
   if (pwm > 1023) pwm = 1023;
   pwm_hw->slice[GPIO_TO_SLICE(AUDIO_PIN)].cc = pwm;
#endif

   // Executa cálculo do ECS se um jogo ECS estiver rodando OU se a melodia estiver ativa
   if (cart.ECSSupport || melody_playing) {
      if (psg0 != NULL) {
         PSG_calc(psg0);
         ecs_raw = (int32_t)psg0->out;
      }

      if (melody_playing) {
         if (melody_ticks > 0) {
            melody_ticks--;

            // Fade-out suave de volume na última nota nos 3 canais
            if (melody_index == MELODY_LENGTH - 1 && melody_ticks < 6000 && psg0 != NULL) {
               uint8_t fade_vol = (uint8_t)(melody_ticks / 400); // Decai de 15 a 0
               PSG_writeReg(psg0, 8, fade_vol & 0x0F);
               PSG_writeReg(psg0, 9, fade_vol & 0x0F);
               PSG_writeReg(psg0, 10, fade_vol & 0x0F);
            }
            // Articulação/pausa curta entre as notas nos 3 canais
            else if (melody_ticks == NOTE_GATE_TICKS && psg0 != NULL) {
               PSG_writeReg(psg0, 8, 0x00);
               PSG_writeReg(psg0, 9, 0x00);
               PSG_writeReg(psg0, 10, 0x00);
            }
         } else {
            melody_index++;
            if (melody_index < MELODY_LENGTH) {
               play_melody_note(melody_index);
               melody_ticks = melody_durations[melody_index];
            } else {
               // Fim da melodia: Mute total no mixer e zera volumes
               melody_playing = false;
               ecs_raw = 0;
               if (psg0 != NULL) {
                  PSG_writeReg(psg0, 7, 0x3F); // Mute total PSG
                  PSG_writeReg(psg0, 8, 0x00);
                  PSG_writeReg(psg0, 9, 0x00);
                  PSG_writeReg(psg0, 10, 0x00);
               }
            }
         }
      }	  
	  
	  
	  
	  
   } else {
      ecs_raw = 0;
   }

   if (cart.IntellivoiceSupport && audio_cycle == 3) {
      ivoice_raw = (int32_t)ivoice_minty_next_sample();
      ivoice_raw = ((ivoice_raw + 32768) >> 2);
   }

   audio_cycle = (audio_cycle + 1) & 0x03;

   return true;
}

void trigger_audio_test_sample(void) {
   if (psg0 == NULL) {
      if (current_tv_mode == 0)
         psg0 = PSG_new(PAL_ECS_FREQ / 2, AUDIO_FREQ);
      else
         psg0 = PSG_new(NTSC_ECS_FREQ / 2, AUDIO_FREQ);

      PSG_setVolumeMode(psg0, EMU2149_VOL_AY_3_8910);
      PSG_reset(psg0);
   }

   // Inicia o sequenciador na primeira nota
   melody_index   = 0;
   melody_ticks   = melody_durations[0];
   melody_playing = true;

   play_melody_note(0);
}

void init_audio(uint8_t tv_mode, uint8_t volume) {
   AudioVolume = volume;
   current_tv_mode = tv_mode;

   // Interrompe qualquer melodia de teste ativa
   melody_playing = false;

   // Re-inicializa o Intellivoice se o jogo necessitar
   if (cart.IntellivoiceSupport) {
      const int pal_mode = (tv_mode == 0u) ? 1 : 0;
      ivoice_init(pal_mode, 1.0);
   }

   // Recria e reseta o chip PSG com a frequência correta do modo de TV (NTSC/PAL)
   uint32_t ecs_freq = (tv_mode == 0) ? (PAL_ECS_FREQ / 2) : (NTSC_ECS_FREQ / 2);

   if (psg0 != NULL) {
      PSG_delete(psg0);
      psg0 = NULL;
   }

   psg0 = PSG_new(ecs_freq, AUDIO_FREQ);
   if (psg0 != NULL) {
      PSG_reset(psg0);
      PSG_setVolumeMode(psg0, EMU2149_VOL_AY_3_8910);
   }

   // Se o hardware PWM/Timer já foi inicializado anteriormente, encerra aqui
   if (audio_initialized) {
      return;
   }

#ifndef NDEBUG
   printf("init_audio: tv_mode=%d, volume=%d\n", tv_mode, AudioVolume);
#else
   gpio_set_function(AUDIO_PIN, GPIO_FUNC_PWM);
   uint audioSlice = pwm_gpio_to_slice_num(AUDIO_PIN);
 
   pwm_config cfg = pwm_get_default_config();
   pwm_config_set_clkdiv(&cfg, 1.0f);
   pwm_config_set_wrap(&cfg, PWM_WRAP);
   pwm_init(audioSlice, &cfg, true);
#endif

   // Registra o timer de áudio apenas uma vez
   add_repeating_timer_us(-(AUDIO_PERIOD), audio_callback, NULL, &timer);
   
   audio_initialized = true;
}




