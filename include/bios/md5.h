#ifndef _MD5_H_
#define _MD5_H_

#include "c_types.h"

#define MD5_HASH_LEN 16

struct MD5Context {
    uint32_t buf[4];
    uint32_t bits[2];
    uint8_t in[64];
};

void MD5Init(struct MD5Context *context);
void MD5Update(struct MD5Context *context, unsigned char const *buf, unsigned len);
void MD5Final(unsigned char digest[16], struct MD5Context *context);

#endif /* _MD5_H_ */
