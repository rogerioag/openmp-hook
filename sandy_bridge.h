
#ifndef SANDY_BRIDGE_H
#define SANDY_BRIDGE_H

/*	hppca-pacgpu-server01: 
	http://ark.intel.com/pt-br/products/64593/Intel-Xeon-Processor-E5-2630-15M-Cache-2_30-GHz-7_20-GTs-Intel-QPI
	Model: 45 - 2DH : SandyBridge - SandyBridge-EP
   	Vendor string and code   : GenuineIntel (1)
	Model string and code    : Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz (45)
	CPU Revision             : 7.000000
	CPUID Info               : Family: 6  Model: 45  Stepping: 7
	CPU Max Megahertz        : 2301
	CPU Min Megahertz        : 1200
	Hdw Threads per core     : 2
	Cores per Socket         : 6
	Sockets                  : 2
	NUMA Nodes               : 2
	CPUs per Node            : 12
	Total CPUs               : 24
	Running in a VM          : no
	Number Hardware Counters : 11
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
/* MEM_event_names */{ "UNC_H_IMC_READS", "UNC_H_IMC_WRITES", NULL, NULL, NULL },
// /* L3_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L3_TCR", "PAPI_L3_TCW", NULL },
/* L3_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L3_DCR", "PAPI_L3_DCW", NULL },  
/* L2_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L2_DCR", "PAPI_L2_DCW", NULL },
///* L1_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L1_TCR", "PAPI_L1_TCW", NULL },
/* L1_event_names */ { "UNHALTED_CORE_CYCLES", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL },
/* FPO_event_names */{ "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_DP_OPS",            NULL, NULL }
};

/* Position, column in te values table according with events names. */
static int event_position[NUM_EVENT_SETS] = { 
/* MEM_events */  0 ,
/* L3_events  */  2,
/* L2_events  */  2 ,
/* L1_events  */  2 ,
/* FPO_events */  2 
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

#endif /* SANDY_BRIDGE_H */
