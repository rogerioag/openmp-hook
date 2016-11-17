
#ifndef IVY_BRIDGE_H
#define IVY_BRIDGE_H

/*	pilipili2 (grenoble): 
    	Model: 62 - 3EH : Ivy Bridge - IvyBridge-EP
    	http://ark.intel.com/products/75790/Intel-Xeon-Processor-E5-2630-v2-15M-Cache-2_60-GHz
    	Launch Date: 	Q3'13
    	['Ivy Bridge E', '2013.3', '06_3EH', 'ivy bridge-e, i7-4930K'],
	['Ivy Bridge EN', '2014.1', '06_3EH', 'ivy bridge en'],
	['Ivy Bridge EP', '2013.3', '06_3EH', 'ivy bridge ep'],
   	Vendor string and code   : GenuineIntel (1)
	Model string and code    : Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz (62)
	CPU Revision             : 4.000000
	CPUID Info               : Family: 6  Model: 62  Stepping: 4
	CPU Max Megahertz        : 3100
	CPU Min Megahertz        : 1200
	Hdw Threads per core     : 2
	Cores per Socket         : 6
	Sockets                  : 2
	NUMA Nodes               : 2
	CPUs per Node            : 12
	Total CPUs               : 24
	Running in a VM          : no
	Number Hardware Counters : 11
	Max Multiplex Counters   : 128

	http://www.cpu-world.com/CPUs/Xeon/Intel-Xeon%20E5-2630%20v2.html
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
/* MEM_event_names */// { "ivbep_unc_ha0::UNC_H_IMC_READS:cpu=0", "ivbep_unc_ha0::UNC_H_IMC_WRITES:cpu=0", NULL, NULL, NULL },
/* MEM_event_names */{ "UNC_H_IMC_READS", "UNC_H_IMC_WRITES", NULL, NULL, NULL },
/* L3_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L3_DCR", "PAPI_L3_DCW", NULL },
/* L2_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L2_DCR", "PAPI_L2_DCW", NULL },
/* FPO_event_names */{ "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_DP_OPS", NULL, NULL },
/* L1_event_names */ { "UNHALTED_CORE_CYCLES", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL }
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
/* FPO_event_names */ COMP_UNCORE
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
   Xeon: 110.4 GFlops, Memory Bandwidth: 51.2 GB/s
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
/* Xeon */	{ 
				.dev_type = T_CPU, .id = 0, .theor_flops = 110.4, .theor_bandwidth = 51.2, .efect_flops = 110.4, 
				/*.efect_bandwidth*/
				{ /* READ -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 51.2, 51.2, 51.2 }, 
				  /* WRITE -> MEMORY_ALLOC_DEFAULT, MEMORY_ALLOC_PAGEABLE, MEMORY_ALLOC_PINNED */
					{ 51.2, 51.2, 51.2 } 
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

#endif /* IVY_BRIDGE_H */
