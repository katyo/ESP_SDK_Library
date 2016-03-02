/*
 * AES functions
 * Copyright (c) 2003-2006, Jouni Malinen <j@w1.fi>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Alternatively, this software may be distributed under the terms of BSD
 * license.
 *
 * See README and COPYING for more details.
 */

#ifndef _AES_DECRYPT_H_
#  define _AES_DECRYPT_H_

#  include "c_types.h"

#  ifndef AES_BLOCK_SIZE
#    define AES_BLOCK_SIZE 16
#  endif

int aes_unwrap(const uint8_t* kek, size_t kek_len, int n, const uint8_t *cipher, uint8_t* plain);

void *aes_decrypt_init(const uint8_t *key, size_t len);
void aes_decrypt(void *ctx, const uint8_t *crypt, uint8_t *plain);
void aes_decrypt_deinit(void *ctx);

#endif /* _AES_DECRYPT_H_ */
