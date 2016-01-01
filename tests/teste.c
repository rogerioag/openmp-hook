/* Generic function to get next chunk. */
bool HOOKOMP_generic_next (long *istart, long *iend, bool (*fn_next_chunk) (long *, long *)){
   PRINT_FUNC_NAME;
   bool result = false;
   TRACE("[hookomp]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

   /* Registry the thread which will be execute alone. down semaphore. */
   sem_wait(&mutex_registry_thread_in_func_next);

   if(thread_executing_function_next == -1){
     thread_executing_function_next = pthread_self();
     TRACE("[hookomp]: Thread [%lu] is entering in controled execution.\n", (long int) thread_executing_function_next);
   }
   /* up semaphore. */
   sem_post(&mutex_registry_thread_in_func_next);
   int total_of_iterations = 0;

   /* Verify if the thread is the thread executing. */
   if(thread_executing_function_next == (long int) pthread_self()){
     total_of_iterations = (loop_iterations_end - loop_iterations_start);

     if(executed_loop_iterations < (total_of_iterations / percentual_of_code)){
       TRACE("[hookomp]: [Before]-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
       result = fn_next_chunk(istart, iend);
       TRACE("[hookomp]: [After]-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
       /* Update the number of iterations executed by this thread. */
       TRACE("[hookomp]: [Before]-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);
       executed_loop_iterations += (*iend - *istart);
       TRACE("[hookomp]: [After]-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);

       /* PAPI Start the counters. */
       if(!started_measuring){
         if(RM_start_counters()){
           TRACE("[hookomp] GOMP_single_start: PAPI Counters Started.\n");
         }
         else {
           TRACE("Error calling RM_start_counters from GOMP_single_start.\n");
         }
         started_measuring = true;
       }
     }
     else{
       TRACE("[hookomp]: GOMP_loop_runtime_next -- Tid[%lu] executed %ld iterations of %ld.\n", thread_executing_function_next, executed_loop_iterations, (loop_iterations_end - loop_iterations_start));
     }
   }
   else{
     /* If it is executing in a section to measurements, the threads will be blocked. */             
     if (is_executed_measures_section){
       /* Other team threads will be blocked. */
       TRACE("[hookomp]: Thread [%lu] will be blocked.\n", (long int) pthread_self());
       sem_wait(&sem_blocks_other_team_threads);       
     }  
     /* if decided by offloading, no more work to do, so return false. */
     if(!decided_by_offloading){
       result = fn_next_chunk(istart, iend);   
     }
     else{
       result = false;
     }
    }
    return result;
}