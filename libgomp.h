/* Copyright (C) 2005-2015 Free Software Foundation, Inc.
   Contributed by Richard Henderson <rth@redhat.com>.

   This file is part of the GNU Offloading and Multi Processing Library
   (libgomp).

   Libgomp is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   Libgomp is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.

   Under Section 7 of GPL version 3, you are granted additional
   permissions described in the GCC Runtime Library Exception, version
   3.1, as published by the Free Software Foundation.

   You should have received a copy of the GNU General Public License and
   a copy of the GCC Runtime Library Exception along with this program;
   see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
   <http://www.gnu.org/licenses/>.  */

/* This file contains data types and function declarations that are not
   part of the official OpenACC or OpenMP user interfaces.  There are
   declarations in here that are part of the GNU Offloading and Multi
   Processing ABI, in that the compiler is required to know about them
   and use them.

   The convention is that the all caps prefix "GOMP" is used group items
   that are part of the external ABI, and the lower case prefix "gomp"
   is used group items that are completely private to the library.  */

#ifndef LIBGOMP_DEFS_H 
#define LIBGOMP_DEFS_H 1

#include <pthread.h>

/* This structure contains the data to control one work-sharing construct,
   either a LOOP (FOR/DO) or a SECTIONS.  */

enum gomp_schedule_type
{
  GFS_RUNTIME,
  GFS_STATIC,
  GFS_DYNAMIC,
  GFS_GUIDED,
  GFS_AUTO
};

typedef int gomp_mutex_t;
typedef void *gomp_ptrlock_t;

struct gomp_work_share
{
  /* This member records the SCHEDULE clause to be used for this construct.
     The user specification of "runtime" will already have been resolved.
     If this is a SECTIONS construct, this value will always be DYNAMIC.  */
  enum gomp_schedule_type sched;

  int mode;

  union {
    struct {
      /* This is the chunk_size argument to the SCHEDULE clause.  */
      long chunk_size;

      /* This is the iteration end point.  If this is a SECTIONS construct,
   this is the number of contained sections.  */
      long end;

      /* This is the iteration step.  If this is a SECTIONS construct, this
   is always 1.  */
      long incr;
    };

    struct {
      /* The same as above, but for the unsigned long long loop variants.  */
      unsigned long long chunk_size_ull;
      unsigned long long end_ull;
      unsigned long long incr_ull;
    };
  };

  /* This is a circular queue that details which threads will be allowed
     into the ordered region and in which order.  When a thread allocates
     iterations on which it is going to work, it also registers itself at
     the end of the array.  When a thread reaches the ordered region, it
     checks to see if it is the one at the head of the queue.  If not, it
     blocks on its RELEASE semaphore.  */
  unsigned *ordered_team_ids;

  /* This is the number of threads that have registered themselves in
     the circular queue ordered_team_ids.  */
  unsigned ordered_num_used;

  /* This is the team_id of the currently acknowledged owner of the ordered
     section, or -1u if the ordered section has not been acknowledged by
     any thread.  This is distinguished from the thread that is *allowed*
     to take the section next.  */
  unsigned ordered_owner;

  /* This is the index into the circular queue ordered_team_ids of the
     current thread that's allowed into the ordered reason.  */
  unsigned ordered_cur;

  /* This is a chain of allocated gomp_work_share blocks, valid only
     in the first gomp_work_share struct in the block.  */
  struct gomp_work_share *next_alloc;

  /* The above fields are written once during workshare initialization,
     or related to ordered worksharing.  Make sure the following fields
     are in a different cache line.  */

  /* This lock protects the update of the following members.  */
  gomp_mutex_t lock __attribute__((aligned (64)));

  /* This is the count of the number of threads that have exited the work
     share construct.  If the construct was marked nowait, they have moved on
     to other work; otherwise they're blocked on a barrier.  The last member
     of the team to exit the work share construct must deallocate it.  */
  unsigned threads_completed;

  union {
    /* This is the next iteration value to be allocated.  In the case of
       GFS_STATIC loops, this the iteration start point and never changes.  */
    long next;

    /* The same, but with unsigned long long type.  */
    unsigned long long next_ull;

    /* This is the returned data structure for SINGLE COPYPRIVATE.  */
    void *copyprivate;
  };

  union {
    /* Link to gomp_work_share struct for next work sharing construct
       encountered after this one.  */
    gomp_ptrlock_t next_ws;

    /* gomp_work_share structs are chained in the free work share cache
       through this.  */
    struct gomp_work_share *next_free;
  };

  /* If only few threads are in the team, ordered_team_ids can point
     to this array which fills the padding at the end of this struct.  */
  unsigned inline_ordered_team_ids[0];
};

/* This structure contains all of the thread-local data associated with 
   a thread team.  This is the data that must be saved when a thread
   encounters a nested PARALLEL construct.  */

struct gomp_team_state
{
  /* This is the team of which the thread is currently a member.  */
  struct gomp_team *team;

  /* This is the work share construct which this thread is currently
     processing.  Recall that with NOWAIT, not all threads may be 
     processing the same construct.  */
  struct gomp_work_share *work_share;

  /* This is the previous work share construct or NULL if there wasn't any.
     When all threads are done with the current work sharing construct,
     the previous one can be freed.  The current one can't, as its
     next_ws field is used.  */
  struct gomp_work_share *last_work_share;

  /* This is the ID of this thread within the team.  This value is
     guaranteed to be between 0 and N-1, where N is the number of
     threads in the team.  */
  unsigned team_id;

  /* Nesting level.  */
  unsigned level;

  /* Active nesting level.  Only active parallel regions are counted.  */
  unsigned active_level;

  /* Place-partition-var, offset and length into gomp_places_list array.  */
  unsigned place_partition_off;
  unsigned place_partition_len;

#ifdef HAVE_SYNC_BUILTINS
  /* Number of single stmts encountered.  */
  unsigned long single_count;
#endif

  /* For GFS_RUNTIME loops that resolved to GFS_STATIC, this is the
     trip number through the loop.  So first time a particular loop
     is encountered this number is 0, the second time through the loop
     is 1, etc.  This is unused when the compiler knows in advance that
     the loop is statically scheduled.  */
  unsigned long static_trip;
};


struct gomp_task;
struct gomp_taskgroup;
struct htab;

struct gomp_task_depend_entry
{
  void *addr;
  struct gomp_task_depend_entry *next;
  struct gomp_task_depend_entry *prev;
  struct gomp_task *task;
  bool is_in;
  bool redundant;
  bool redundant_out;
};

struct gomp_dependers_vec
{
  size_t n_elem;
  size_t allocated;
  struct gomp_task *elem[];
};

/* This structure contains all data that is private to libgomp and is
   allocated per thread.  */

typedef int gomp_sem_t;

typedef struct
{
  /* Make sure total/generation is in a mostly read cacheline, while
     awaited in a separate cacheline.  */
  unsigned total __attribute__((aligned (64)));
  unsigned generation;
  unsigned awaited __attribute__((aligned (64)));
  unsigned awaited_final;
} gomp_barrier_t;

struct gomp_thread
{
  /* This is the function that the thread should run upon launch.  */
  void (*fn) (void *data);
  void *data;

  /* This is the current team state for this thread.  The ts.team member
     is NULL only if the thread is idle.  */
  struct gomp_team_state ts;

  /* This is the task that the thread is currently executing.  */
  struct gomp_task *task;

  /* This semaphore is used for ordered loops.  */
  gomp_sem_t release;

  /* Place this thread is bound to plus one, or zero if not bound
     to any place.  */
  unsigned int place;

  /* User pthread thread pool */
  struct gomp_thread_pool *thread_pool;
};


struct gomp_thread_pool
{
  /* This array manages threads spawned from the top level, which will
     return to the idle loop once the current PARALLEL construct ends.  */
  struct gomp_thread **threads;
  unsigned threads_size;
  unsigned threads_used;
  /* The last team is used for non-nested teams to delay their destruction to
     make sure all the threads in the team move on to the pool's barrier before
     the team's barrier is destroyed.  */
  struct gomp_team *last_team;
  /* Number of threads running in this contention group.  */
  unsigned long threads_busy;

  /* This barrier holds and releases threads waiting in threads.  */
  gomp_barrier_t threads_dock;
};

enum gomp_cancel_kind
{
  GOMP_CANCEL_PARALLEL = 1,
  GOMP_CANCEL_LOOP = 2,
  GOMP_CANCEL_FOR = GOMP_CANCEL_LOOP,
  GOMP_CANCEL_DO = GOMP_CANCEL_LOOP,
  GOMP_CANCEL_SECTIONS = 4,
  GOMP_CANCEL_TASKGROUP = 8
};

/*#if defined HAVE_TLS || defined USE_EMUTLS
extern __thread struct gomp_thread gomp_tls_data;
static inline struct gomp_thread *gomp_thread (void)
{
  return &gomp_tls_data;
}
#else
extern pthread_key_t gomp_tls_key;
static inline struct gomp_thread *gomp_thread (void)
{
  return pthread_getspecific (gomp_tls_key);
}
#endif*/
extern struct gomp_thread* gomp_thread();


#endif /* LIBGOMP_DEFS_H */
