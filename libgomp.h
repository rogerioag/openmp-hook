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

#ifndef LIBGOMP_H 
#define LIBGOMP_H 1

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

/* This structure describes a "team" of threads.  These are the threads
   that are spawned by a PARALLEL constructs, as well as the work sharing
   constructs that the team encounters.  */

struct gomp_team
{
  /* This is the number of threads in the current team.  */
  unsigned nthreads;

  /* This is number of gomp_work_share structs that have been allocated
     as a block last time.  */
  unsigned work_share_chunk;

  /* This is the saved team state that applied to a master thread before
     the current thread was created.  */
  struct gomp_team_state prev_ts;

  /* List of work shares on which gomp_fini_work_share hasn't been
     called yet.  If the team hasn't been cancelled, this should be
     equal to each thr->ts.work_share, but otherwise it can be a possibly
     long list of workshares.  */
  struct gomp_work_share *work_shares_to_free;

  /* List of gomp_work_share structs chained through next_free fields.
     This is populated and taken off only by the first thread in the
     team encountering a new work sharing construct, in a critical
     section.  */
  struct gomp_work_share *work_share_list_alloc;

  /* List of gomp_work_share structs freed by free_work_share.  New
     entries are atomically added to the start of the list, and
     alloc_work_share can safely only move all but the first entry
     to work_share_list alloc, as free_work_share can happen concurrently
     with alloc_work_share.  */
  struct gomp_work_share *work_share_list_free;

  gomp_mutex_t task_lock;
  struct gomp_task *task_queue;
  /* Number of all GOMP_TASK_{WAITING,TIED} tasks in the team.  */
  unsigned int task_count;
  /* Number of GOMP_TASK_WAITING tasks currently waiting to be scheduled.  */
  unsigned int task_queued_count;
  /* Number of GOMP_TASK_{WAITING,TIED} tasks currently running
     directly in gomp_barrier_handle_tasks; tasks spawned
     from e.g. GOMP_taskwait or GOMP_taskgroup_end don't count, even when
     that is called from a task run from gomp_barrier_handle_tasks.
     task_running_count should be always <= team->nthreads,
     and if current task isn't in_tied_task, then it will be
     even < team->nthreads.  */
  unsigned int task_running_count;
  int work_share_cancelled;
  int team_cancelled;

  /* This array contains structures for implicit tasks.  */
  struct gomp_task implicit_task[];
};

/* This structure contains all data that is private to libgomp and is
   allocated per thread.  */

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

#endif /* LIBGOMP_H */
