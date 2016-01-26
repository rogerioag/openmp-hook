
#ifndef PLATFORM_H
#define PLATFORM_H

#define NUM_DEVICES 2

typedef struct DEVICE_DESC_TYPE {
  unsigned int id;
  double flops;
  double bandwidth;
} DEVICE_DESC_TYPE;

static DEVICE_DESC_TYPE devices[NUM_DEVICES] = {
/* Xeon */	{ .id = 0, .flops =  110.4, .bandwidth =  51.2 },
/* GPU0 */	{ .id = 1, .flops = 4291.2, .bandwidth = 288.0 }
};

#endif /* PLATFORM_H */
