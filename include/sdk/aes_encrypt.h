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

#ifndef _AES_ENCRYPT_H_
#  define _AES_ENCRYPT_H_

#  include "c_types.h"

#  ifndef AES_BLOCK_SIZE
#    define AES_BLOCK_SIZE 16
#  endif

int aes_wrap(const uint8_t *kek, size_t kek_len, int n, const uint8_t *plain, uint8_t *cipher);

void *aes_encrypt_init(const uint8_t *key, size_t len);
void aes_encrypt(void *ctx, const uint8_t *plain, uint8_t *crypt);
void aes_encrypt_deinit(void *ctx);

#endif /* _AES_ENCRYPT_H_ */
