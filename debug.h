
#ifndef DEBUG_H
#define DEBUG_H

#define DEBUG 1
#define VERBOSE 1

#if defined(DEBUG) && DEBUG > 0
 #define PRINT_MSG(type, fmt, args...)	do{ fprintf(stderr, "%s: [%10s:%07d] Thread [%lu] in %s(): " fmt, \
    type, __FILE__, __LINE__, (long int) pthread_self(), __func__, ##args); } while(0)

 #define PRT_DEBUG(fmt, args...) PRINT_MSG("DEBUG",fmt,args)

 #define TRACE(fmt, args...) PRINT_MSG("TRACE",fmt,args)
#else
 #define PRINT_MSG(type, fmt, args...) do{ } while (0)
#endif

// #define VERBOSE 1
// Use make OPTIONS=-DVERBOSE
#if defined(VERBOSE) && VERBOSE > 0
#define PRINT_FUNC_NAME fprintf(stderr, "TRACE-FUNCNAME: [%10s:%07d] Thread [%lu] is calling [%s()]\n", __FILE__, __LINE__, (long int) pthread_self(), __FUNCTION__)
#else
#define PRINT_FUNC_NAME (void) 0
#endif

#endif /* DEBUG_H */
