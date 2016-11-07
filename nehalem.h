#ifndef NEHALEM_H
#define NEHALEM_H

/*	ragserver:
	http://ark.intel.com/products/41315/Intel-Core-i7-870-Processor-8M-Cache-2_93-GHz
	Model: 30 - 1EH : Nehalem - Lynnfield
   	Vendor string and code   : GenuineIntel (1)
	Model string and code    : Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz (30)
	CPU Revision             : 5.000000
	CPUID Info               : Family: 6  Model: 30  Stepping: 5
	CPU Max Megahertz        : 2934
	CPU Min Megahertz        : 1199
	Hdw Threads per core     : 2
	Cores per Socket         : 4
	Sockets                  : 1
	NUMA Nodes               : 1
	CPUs per Node            : 8
	Total CPUs               : 8
	Running in a VM          : no
	Number Hardware Counters : 7
	Max Multiplex Counters   : 192
*/

#define NUM_EVENT_SETS 5
#define NUM_MAX_EVENTS 5

/* Events more PAPI_get_real_cyc() that work with time stamp counter (tsc), getting the value of rdtsc. */

/* Indexes to define the position of values. */
#define IDX_MEM 0
#define IDX_LLC 1
#define IDX_L2 2
#define IDX_L1 3
#define IDX_FPO 4

#define COMP_CORE 0
#define COMP_UNCORE 1

/* Names of Events. */
/* Attention: Position is important to read the table values after. */
static char *event_names[NUM_EVENT_SETS][NUM_MAX_EVENTS] = { 
/* MEM_event_names */ //{ "ivbep_unc_ha0::UNC_H_IMC_READS:cpu=0", "ivbep_unc_ha0::UNC_H_IMC_WRITES:cpu=0", NULL, NULL, NULL },
/* MEM_event_names *///{ "UNC_H_IMC_READS", "UNC_H_IMC_WRITES", NULL, NULL, NULL },
  /* MEM_event_names */{ "UNC_QMC_NORMAL_READS:ANY:cpu=0", "UNC_QMC_WRITES:FULL_ANY:cpu=0", NULL, NULL, NULL },
/* L3_event_names */ { "PAPI_L3_TCR", "PAPI_L3_TCW", NULL, NULL, NULL },
/* L2_event_names */ { "PAPI_L2_DCR", "PAPI_L2_DCW", NULL, NULL, NULL },
///* L1_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L1_TCR", "PAPI_L1_TCW", NULL },
/* L1_event_names */// { "UNHALTED_CORE_CYCLES", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL },
  /* L1_event_names */// { "ix86arch::UNHALTED_CORE_CYCLES:cpu=0", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL },
  /* L1_event_names */// { "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL, NULL, NULL },
  /* L1_event_names */ { "PAPI_L1_TCR", "PAPI_L1_TCW", NULL, NULL, NULL },
/* FPO_event_names */{ "PAPI_DP_OPS", NULL, NULL, NULL, NULL }
};

/* Position, column in te values table according with events names. */
static int event_position[NUM_EVENT_SETS] = { 
/* MEM_events */  0 ,
/* L3_events  */  0 ,
/* L2_events  */  0 ,
/* L1_events  */  0 ,
/* FPO_events */  0 
};

/* The kind of component the eventset was associated. Is need different event sets to measures preset events and native events. 
   Components cpu (0) and perf_event_uncore to uncore events are associated with EventSet. 
   This kind is used to switch between EventSets. */
static int kind_of_event_set[NUM_EVENT_SETS] = { 
/* MEM_event_names */ COMP_UNCORE ,
/* L3_event_names */  COMP_CORE ,
/* L2_event_names */  COMP_CORE ,
/* L1_event_names */  COMP_CORE ,
/* FPO_event_names */ COMP_CORE
};

#endif /* NEHALEM_H */

