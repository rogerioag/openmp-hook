/**
 * syr2k.h: This file is part of the PolyBench/C 3.2 test suite.
 *
 *
 * Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://polybench.sourceforge.net
 */
#ifndef SYR2K_H
# define SYR2K_H

/* Default to STANDARD_DATASET. */
#if !defined(TOY_DATASET) && !defined(MINI_DATASET) && !defined(TINY_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET) && !defined(HUGE_DATASET)
#define STANDARD_DATASET
#endif

/* Do not define anything if the user manually defines the size. */
# if !defined(NI) && !defined(NJ) && !defined(NK)
/* Define the possible dataset sizes. */
#ifdef TOY_DATASET
#define NI 32
#define NJ 32
#define NK 32
#endif

#ifdef MINI_DATASET
#define NI 64
#define NJ 64
#define NK 64
#endif

#ifdef TINY_DATASET
#define NI 128
#define NJ 128
#define NK 128
#endif

#ifdef SMALL_DATASET
#define NI 256
#define NJ 256
#define NK 256
#endif

#ifdef MEDIUM_DATASET
#define NI 512
#define NJ 512
#define NK 512
#endif

#ifdef STANDARD_DATASET /* Default if unspecified. */
#define NI 1024
#define NJ 1024
#define NK 1024
#endif

#ifdef LARGE_DATASET
#define NI 2048
#define NJ 2048
#define NK 2048
#endif

#ifdef EXTRALARGE_DATASET
#define NI 4096
#define NJ 4096
#define NK 4096
#endif

#ifdef HUGE_DATASET
#define NI 8192
#define NJ 8192
#define NK 8192
#endif
#endif /* !N */

# define _PB_NI POLYBENCH_LOOP_BOUND(NI,ni)
# define _PB_NJ POLYBENCH_LOOP_BOUND(NJ,nj)

# ifndef DATA_TYPE
#  define DATA_TYPE double
#  define DATA_PRINTF_MODIFIER "%0.2lf "
# endif


#endif /* !SYR2K */
