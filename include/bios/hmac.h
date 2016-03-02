#ifndef _HMAC_H_
#define _HMAC_H_

#define MD5_MAC_LEN 16

int hmac_md5_vector(const uint8_t *key, size_t key_len, size_t num_elem,
                    const uint8_t *addr[], const size_t *len, uint8_t *mac);
int hmac_md5(const uint8_t *key, size_t key_len, const uint8_t *data, size_t data_len,
             uint8_t *mac);

#define SHA1_MAC_LEN 20

int hmac_sha1_vector(const uint8_t *key, size_t key_len, size_t num_elem,
                     const uint8_t *addr[], const size_t *len, uint8_t *mac);
int hmac_sha1(const uint8_t *key, size_t key_len, const uint8_t *data, size_t data_len,
               uint8_t *mac);

int pbkdf2_sha1(const char *passphrase, const uint8_t *ssid, size_t ssid_len,
		int iterations, uint8_t *buf, size_t buflen);

#endif /* _HMAC_H_ */
