#include <stdio.h>
#include <stdlib.h>
#include <papi.h>
#include <omp.h>

int main(){
  int i, maxthr, retval;
  long long elapsed_us, elapsed_cyc;
  char errstring[PAPI_MAX_STR_LEN];

  retval = PAPI_library_init(PAPI_VER_CURRENT);
  if (retval != PAPI_VER_CURRENT){
    PAPI_perror(errstring);
    printf("%s:%d::PAPI_library_init failed. %d %s\n",__FILE__,__LINE__,retval,errstring);
    exit(1);
  }

  if (PAPI_set_debug(PAPI_VERB_ECONT) != PAPI_OK)
    exit(1);

  retval = PAPI_thread_init((unsigned long (*)(void))(omp_get_thread_num));
  if (retval != PAPI_OK){
    PAPI_perror(errstring);
    printf("%s:%d::PAPI_thread_init failed. %d %s\n", __FILE__,__LINE__,retval,errstring);
    exit(1);
  }
  elapsed_us = PAPI_get_real_usec();
  elapsed_cyc = PAPI_get_real_cyc();

  maxthr = omp_get_num_procs();

#pragma omp parallel for
  for (i=1;i<maxthr+1;i++)
    Thread(1000000*i);

  elapsed_cyc = PAPI_get_real_cyc() - elapsed_cyc;
  elapsed_us = PAPI_get_real_usec() - elapsed_us;

  printf("Master real usec   : \t%lld\n", elapsed_us);
  printf("Master real cycles : \t%lld\n", elapsed_cyc);

  exit(0);
}
