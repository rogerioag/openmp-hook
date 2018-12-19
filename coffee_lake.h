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

	http://www.cpu-world.com/CPUs/Core_i7/Intel-Core%20i7-870%20BV80605001905AI%20(BX80605I7870%20-%20BXC80605I7870).html
*/

#define NUM_DEVICES 2

/* Cache line size: 64 bytes. http://www.cpu-world.com/CPUs/Xeon/Intel-Xeon%20E5-2630.html */
#define CACHE_LINE_SIZE 64

/* Time of transfer 1 byte over PCI. */
/* Host to Device. */
#define T_WRITE_BYTE 1

/* Device to Host. */
#define T_READ_BYTE 1

#define BYTES_TO_KB 9.76563e-4
#define BYTES_TO_MB 9.5367e-7
#define BYTES_TO_GB 9.3132e-10

/* One to preset, cpu and other to native and uncore. */
#define NUM_PAPI_EVENT_SETS 2

/* Events more PAPI_get_real_cyc() that work with time stamp counter (tsc), getting the value of rdtsc. */

/* Indexes to define the position of values. */
#define IDX_MEM 0
#define IDX_LLC 1
#define IDX_L2 2
#define IDX_L1 4
#define IDX_FPO 3

#define COMP_CORE 0
#define COMP_UNCORE 1

#define NUM_EVENT_SETS 5
#define NUM_MAX_EVENTS 5

/* Events more PAPI_get_real_cyc() that work with time stamp counter (tsc), getting the value of rdtsc. */

/* Names of Events. */
/* Attention: Position is important to read the table values after. */
static char *event_names[NUM_EVENT_SETS][NUM_MAX_EVENTS] = { 
  /* MEM_event_names */{ "UNC_QMC_NORMAL_READS:ANY:cpu=0", "UNC_QMC_WRITES:FULL_ANY:cpu=0", NULL, NULL, NULL },
/* L3_event_names */ { "PAPI_L3_DCR", "PAPI_L3_DCW", NULL, NULL, NULL },
/* L2_event_names */ { "PAPI_L2_DCR", "PAPI_L2_DCW", NULL, NULL, NULL },
///* L1_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L1_TCR", "PAPI_L1_TCW", NULL },
/* L1_event_names */// { "UNHALTED_CORE_CYCLES", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL },
  /* L1_event_names */// { "ix86arch::UNHALTED_CORE_CYCLES:cpu=0", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL },
  /* L1_event_names */// { "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL, NULL, NULL },
  /* L1_event_names */ { "PAPI_DP_OPS", NULL, NULL, NULL, NULL },
/* FPO_event_names */{ "PAPI_L1_DCR", "PAPI_L1_DCW", NULL, NULL, NULL }
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

/* Memory Operation.*/
#define MEMORY_READ 0
#define MEMORY_WRITE 1

/* Type of Memory Data Allocation. */
#define MEMORY_ALLOC_DEFAULT 0
#define MEMORY_ALLOC_PAGEABLE 1
#define MEMORY_ALLOC_PINNED 2
#define MEMORY_ALLOC_UVA 3

enum Device_Type { 
    T_CPU,
    T_GPU 
};

/* Bandwidth can be read or write (direction h2d ou d2h) and have types memory 
	allocation (default (cpu), pageable and pinned (gpu)) */
typedef struct Device_Descriptor {
    enum Device_Type dev_type;
    unsigned int id;
    double theor_flops;
    double theor_bandwidth;
    double efect_flops;
    double efect_bandwidth[2][3];
    double latency[2][3];
} Device_Descriptor_Type;

/* Theoretical values.
   i7-870: 46.3 GFlops, Memory Bandwidth: 21 GB/s
   k40c: 4291.2 GFlops, Memory Bandwidth: 288 GB/s */

/* Sumary of parameters values used in roofline library.
   	** Bandwidth **
   	---------------------------------------------------------------------------------------------------------------------
        	mean(b_pageable_h2d$w)      mean(b_pageable_d2h$w)      mean(b_pinned_h2d$w)        mean(b_pinned_d2h$w)
    ---------------------------------------------------------------------------------------------------------------------
	MB/sec  3210.552                    3208.838                    10256.83                    10267.07
	---------------------------------------------------------------------------------------------------------------------
	GB/s    3.210552                    3.208838                    10.25683                    10.26707
	---------------------------------------------------------------------------------------------------------------------


	** Latency **
	---------------------------------------------------------------------------------------------------------------------
        		mean(pageable_h2d$mean)     mean(pageable_d2h$mean)     mean(pinned_h2d$mean)       mean(pinned_d2h$mean)
    ---------------------------------------------------------------------------------------------------------------------
	ns      	6212.784                    9059.737                    7787.956                    8450.636
	---------------------------------------------------------------------------------------------------------------------
	sec       	6.212784e-6                 9.059737e-6                 7,787956e-6                 8,450636e-6
	---------------------------------------------------------------------------------------------------------------------
*/
static Device_Descriptor_Type devices[NUM_DEVICES] = {
/* i7-870 */	{ 
				.dev_type = T_CPU, .id = 0, .theor_flops = 46.3, .theor_bandwidth = 21.0, .efect_flops = 46.3, 
				/*.efect_bandwidth*/
				{ /* READ -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 21.0, 21.0, 21.0 }, 
				  /* WRITE -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 21.0, 21.0, 21.0 } 
				},
				/*.latency*/ 
				{ /* READ -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 1.0, 1.0, 1.0 }, 
				  /* WRITE -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 1.0, 1.0, 1.0 } 
				},
			},

/* GPU0 */	{ 
				.dev_type = T_GPU, .id = 1, .theor_flops = 4291.2, .theor_bandwidth = 288.0, .efect_flops = 4291.2, 
				/*.efect_bandwidth*/
				{ /* READ (d2h) -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 3.208838, 3.208838, 10.26707 }, 
				  /* WRITE (h2d) -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 3.210552, 3.210552, 10.25683 } 
				},
				/*.latency*/ 
				{ /* READ (d2h) -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 9.059737e-6, 9.059737e-6, 8.450636e-6 }, 
				  /* WRITE (h2d) -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 6.212784e-6, 6.212784e-6, 7.787956e-6 }
				},
			}
};

#endif /* NEHALEM_H */

