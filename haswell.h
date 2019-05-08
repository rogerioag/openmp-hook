
#ifndef HASWELL_H
#define HASWELL_H

/*	titanx-pascal (utfpr-cm): 
    	Model: 60 - 3C : Haswell
    	https://ark.intel.com/pt-br/products/80806/Intel-Core-i7-4790-Processor-8M-Cache-up-to-4-00-GHz-
    	Launch Date: 	Q2'14
    	
	   	PAPI version             : 5.6.0.0
		Operating system         : Linux 4.9.0-4-amd64
		Vendor string and code   : GenuineIntel (1, 0x1)
		Model string and code    : Intel(R) Core(TM) i7-4790 CPU @ 3.60GHz (60, 0x3c)
		CPU revision             : 3.000000
		CPUID                    : Family/Model/Stepping 6/60/3, 0x06/0x3c/0x03
		CPU Max MHz              : 4000
		CPU Min MHz              : 800
		Total cores              : 8
		SMT threads per core     : 2
		Cores per socket         : 4
		Sockets                  : 1
		Cores per NUMA region    : 8
		NUMA regions             : 1
		Running in a VM          : no
		Number Hardware Counters : 0
		Max Multiplex Counters   : 384
		Fast counter read (rdpmc): no


	http://www.cpu-world.com/cgi-bin/IdentifyPart.pl?PART=i7-4790
	http://www.cpu-world.com/CPUs/Core_i7/Intel-Core%20i7-4790.html
*/

#define NUM_DEVICES 2

/* Cache line size: 64 bytes. http://www.cpu-world.com/CPUs/Core_i7/Intel-Core%20i7-4790.html */
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
#define IDX_L1 3
#define IDX_FPO 4

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
/* L1_event_names */ { "UNHALTED_CORE_CYCLES", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL },
/* FPO_event_names */{ "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_DP_OPS", NULL, NULL },
};


/* Position, column in te values table according with events names. */
static int event_position[NUM_EVENT_SETS] = { 
/* MEM_events */  0 ,
/* L3_events  */  2 ,
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

#endif /* HASWELL_H */
