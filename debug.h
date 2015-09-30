
#ifndef DEBUG_H
#define DEBUG_H

#define DEBUG 1
#define VERBOSE 1

#if defined(DEBUG) && DEBUG > 0
 #define TRACE(fmt, args...)	do{ fprintf(stderr, "DEBUG: %s:%d:%s(): " fmt, \
    __FILE__, __LINE__, __func__, ##args); } while(0)
#else
 #define TRACE(fmt, args...) do{ } while (0)
#endif

// #define VERBOSE 1
// Use make OPTIONS=-DVERBOSE
#ifdef VERBOSE
#define HOOKOMP_FUNC_NAME fprintf(stderr, "[%s] Calling [%s]\n", __FILE__, __FUNCTION__)
#else
#define HOOKOMP_FUNC_NAME (void) 0
#endif

#endif /* DEBUG_H */
