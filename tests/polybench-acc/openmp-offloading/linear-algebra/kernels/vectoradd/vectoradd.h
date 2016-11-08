
#ifndef VECTORADD_H
# define VECTORADD_H

/* Default to STANDARD_DATASET. */
#if !defined(TOY_DATASET) && !defined(MINI_DATASET) && !defined(TINY_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET) && !defined(HUGE_DATASET) && !defined(BIG_HUGE_DATASET)
#define STANDARD_DATASET
#endif

/* Do not define anything if the user manually defines the size. */
# if !defined(NI)
/* Define the possible dataset sizes. */
#ifdef TOY_DATASET
#define NI 32
#endif

#ifdef MINI_DATASET
#define NI 64
#endif

#ifdef TINY_DATASET
#define NI 128
#endif

#ifdef SMALL_DATASET
#define NI 256
#endif

#ifdef MEDIUM_DATASET
#define NI 512
#endif

#ifdef STANDARD_DATASET /* Default if unspecified. */
#define NI 1024
#endif

#ifdef LARGE_DATASET
#define NI 2048
#endif

#ifdef EXTRALARGE_DATASET
#define NI 4096
#endif

#ifdef HUGE_DATASET
#define NI 8192
#endif

#ifdef BIG_HUGE_DATASET
#define NI 1000000
#endif

#endif /* !N */

#define _PB_NI POLYBENCH_LOOP_BOUND(NI,ni)

#ifndef DATA_TYPE
#define DATA_TYPE double
#define DATA_PRINTF_MODIFIER "%0.2lf "
#endif

/* Thread block dimensions */
#define DIM_THREAD_BLOCK_X 32
#define DIM_THREAD_BLOCK_Y 8


#endif /* !VECTORADD*/
