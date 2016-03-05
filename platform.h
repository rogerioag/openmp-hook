
#ifndef PLATFORM_H
#define PLATFORM_H

#define NUM_DEVICES 2

/* Memory Operation.*/
#define MEMORY_READ 0
#define MEMORY_WRITE 0

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
    double latency;
} Device_Descriptor_Type;

/* Theoretical values.
   Xeon: 110.4 GFlops, Memory Bandwidth: 51.2 GB/s
   k40c: 4291.2 GFlops, Memory Bandwidth: 288 GB/s */
//static Device_Descriptor_Type devices[NUM_DEVICES] = {
///* Xeon */	{ .dev_type=T_CPU, .id = 0, .theor_flops =  110.4, .theor_bandwidth =  51.2, .efect_flops = 110.4, .efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_DEFAULT] = 51.2, .efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_DEFAULT] = 51.2, .efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PAGEABLE] = 0.0, .efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PAGEABLE] = 0.0, .efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PINNED] = 0.0, .efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PINNED] = 0.0, .latency = 0.0},
///* GPU0 */	{ .dev_type=T_GPU, .id = 1, .theor_flops = 4291.2, .theor_bandwidth = 288.0, .efect_flops = 4291.2, .efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_DEFAULT] = 288.0, .efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_DEFAULT] = 288.0, .efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PAGEABLE] = 288.0, .efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PAGEABLE] = 288.0, .efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PINNED] = 288.0, .efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PINNED] = 288.0, .latency = 0.0}
//};

Device_Descriptor_Type devices[NUM_DEVICES];

/* Xeon */	
devices[0].dev_type=T_CPU;
devices[0].id = 0;
devices[0].theor_flops =  110.4;
devices[0].theor_bandwidth =  51.2;
devices[0].efect_flops = 110.4;
devices[0].efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_DEFAULT] = 51.2;
devices[0].efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_DEFAULT] = 51.2;
devices[0].efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PAGEABLE] = 0.0;
devices[0].efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PAGEABLE] = 0.0;
devices[0].efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PINNED] = 0.0;
devices[0].efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PINNED] = 0.0;
devices[0].latency = 0.0;


/* GPU0 */
devices[1].dev_type=T_GPU; 
devices[1].id = 1; 
devices[1].theor_flops = 4291.2; 
devices[1].theor_bandwidth = 288.0; 
devices[1].efect_flops = 4291.2; 
devices[1].efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_DEFAULT] = 288.0; 
devices[1].efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_DEFAULT] = 288.0; 
devices[1].efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PAGEABLE] = 288.0; 
devices[1].efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PAGEABLE] = 288.0; 
devices[1].efect_bandwidth[MEMORY_READ][MEMORY_ALLOC_PINNED] = 288.0; 
devices[1].efect_bandwidth[MEMORY_WRITE][MEMORY_ALLOC_PINNED] = 288.0; 
devices[1].latency = 0.0;

#endif /* PLATFORM_H */
