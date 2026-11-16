#ifndef _AES_H_
#define _AES_H_

#include <stdint.h>

struct AES_ctx {
    uint8_t RoundKey[176];
    uint8_t Iv[16];
};

void AES_init_ctx_iv(struct AES_ctx* ctx, const uint8_t* key, const uint8_t* iv);
void AES_CTR_xcrypt_buffer(struct AES_ctx* ctx, uint8_t* buf, uint32_t length);

#endif // _AES_H_