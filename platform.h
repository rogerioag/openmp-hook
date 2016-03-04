
#ifndef PLATFORM_H
#define PLATFORM_H

#define NUM_DEVICES 2

enum Device_Type { 
    T_CPU,
    T_GPU 
}; 

typedef struct Device_Descriptor {
    enum Device_Type dev_type;
    unsigned int id;
        double theor_flops;
        double theor_bandwidth;
        double efect_flops;
    union {
    	struct {
        double efect_bandwidth;
      };
    	struct {
        double efect_bandwidth_pinned_mem;
        double efect_bandwidth_pageable_mem;
      };    	
  	};
} Device_Descriptor_Type;


/* Theoretical values.
   Xeon: 110.4 GFlops, Memory Bandwidth: 51.2 GB/s
   k40c: 4291.2 GFlops, Memory Bandwidth: 288 GB/s */
static Device_Descriptor_Type devices[NUM_DEVICES] = {
/* Xeon */	{ .dev_type=T_CPU, .id = 0, .theor_flops =  110.4, .theor_bandwidth =  51.2, .efect_flops = 110.4, .efect_bandwidth =  51.2},
/* GPU0 */	{ .dev_type=T_GPU, .id = 1, .theor_flops = 4291.2, .theor_bandwidth = 288.0, .efect_flops = 4291.2, .efect_bandwidth_pinned_mem = 288.0, .efect_bandwidth_pageable_mem = 288.0}
};

#endif /* PLATFORM_H */
