
#ifndef DEBUG_H
#define DEBUG_H
#include <time.h>

#define DEBUG 1
#define VERBOSE 1

void timestamp()
{
    time_t ltime; /* calendar time */
    ltime=time(NULL); /* get current cal time */
    printf("\n[%s]",asctime( localtime(&ltime) ) );
}

#if defined(DEBUG) && DEBUG > 0
 #define TRACE(fmt, args...)	do{fprintf(stderr, "[TRACE]: [%10s:%07d] Thread [%lu] in %s(): " fmt, \
    __FILE__, __LINE__, (long int) pthread_self(), __func__, ##args); } while(0)

#else
 #define TRACE(fmt, args...) do{ } while (0)
#endif

// #define VERBOSE 1
// Use make OPTIONS=-DVERBOSE
#if defined(VERBOSE) && VERBOSE > 0
#define PRINT_FUNC_NAME fprintf(stderr, "TRACE-FUNC-NAME: [%10s:%07d] Thread [%lu] is calling [%s()]\n",__FILE__, __LINE__, (long int) pthread_self(), __FUNCTION__)
#else
#define PRINT_FUNC_NAME (void) 0
#endif

#endif /* DEBUG_H */
