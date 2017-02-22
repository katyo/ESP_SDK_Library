#ifndef __SNTP_H__
#define __SNTP_H__

#include <time.h>

struct tm *sntp_mktm_r(const time_t * tim_p, struct tm *res, int is_gmtime);
struct tm *sntp_localtime_r(const time_t * tim_p, struct tm *res);
struct tm *sntp_localtime(const time_t * tim_p);
int sntp__tzcalc_limits(int year);
char *sntp_asctime_r(const struct tm *tim_p, char *result);
char *sntp_asctime(const struct tm *tim_p);

#endif /* __SNTP_H__ */
