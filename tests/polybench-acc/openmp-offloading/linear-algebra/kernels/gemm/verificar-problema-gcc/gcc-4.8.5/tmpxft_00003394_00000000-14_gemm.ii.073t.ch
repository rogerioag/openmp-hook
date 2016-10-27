
;; Function void* xmalloc(size_t) (_ZL7xmallocm, funcdef_no=3275, decl_uid=67134, cgraph_uid=3097)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5
;; 2 succs { 4 3 }
;; 3 succs { 4 5 }
;; 4 succs { }
;; 5 succs { 1 }
void* xmalloc(size_t) (size_t num)
{
  int ret;
  void * newA;
  struct _IO_FILE * stderr.73;
  void * newA.72;

  <bb 2>:
  newA = 0B;
  ret_5 = posix_memalign (&newA, 32, num_3(D));
  newA.72_6 = newA;
  if (newA.72_6 == 0B)
    goto <bb 4>;
  else
    goto <bb 3>;

  <bb 3>:
  if (ret_5 != 0)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 4>:
  stderr.73_8 = stderr;
  __fprintf_chk (stderr.73_8, 1, "[PolyBench] posix_memalign: cannot allocate memory");
  exit (1);

  <bb 5>:
  newA ={v} {CLOBBER};
  return newA.72_6;

}



;; Function void __cudaUnregisterBinaryUtil() (_ZL26__cudaUnregisterBinaryUtilv, funcdef_no=3279, decl_uid=67214, cgraph_uid=3100)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void __cudaUnregisterBinaryUtil() ()
{
  static volatile void * * __ref;
  void * * __cudaFatCubinHandle.84;

  <bb 2>:
  __ref = &__cudaFatCubinHandle;
  __cudaFatCubinHandle.84_3 = __cudaFatCubinHandle;
  __cudaUnregisterFatBinary (__cudaFatCubinHandle.84_3);
  return;

}



;; Function <built-in> (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0, funcdef_no=3306, decl_uid=67704, cgraph_uid=3135)

Created preheader block for loop 1
;; 5 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 13 4 5 6 15 7 14 8 9 10 11 12
;;
;; Loop 1
;;  header 13, latch 14
;;  depth 1, outer 0
;;  nodes: 13 14 7 6 5 4 10 9 8 11 15
;;
;; Loop 2
;;  header 4, latch 15
;;  depth 2, outer 1
;;  nodes: 4 15 6 5 10 9 8 11
;;
;; Loop 3
;;  header 5, latch 10
;;  depth 3, outer 2
;;  nodes: 5 10 9 8 11
;;
;; Loop 4
;;  header 9, latch 11
;;  depth 4, outer 3
;;  nodes: 9 11
;; 2 succs { 3 12 }
;; 3 succs { 13 }
;; 13 succs { 4 }
;; 4 succs { 5 }
;; 5 succs { 8 6 }
;; 6 succs { 15 7 }
;; 15 succs { 4 }
;; 7 succs { 12 14 }
;; 14 succs { 13 }
;; 8 succs { 9 }
;; 9 succs { 11 10 }
;; 10 succs { 5 }
;; 11 succs { 9 }
;; 12 succs { 1 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

_55 -> { _24 }
j_56 -> { j_2 }
k_57 -> { k_3 }
.MEM_58 -> { .MEM_6 }
.MEM_59 -> { .MEM_5 }
_60 -> { _36 }
j_61 -> { j_2 }
k_62 -> { k_3 }
.MEM_63 -> { .MEM_5 }
.MEM_64 -> { .MEM_5 }
.MEM_65 -> { .MEM_6 }
.MEM_66 -> { .MEM_6 }
Incremental SSA update started at block: 4
Number of blocks in CFG: 22
Number of blocks to update: 15 ( 68%)


Merging blocks 4 and 16
Merging blocks 8 and 19
Merging blocks 10 and 5
Merging blocks 11 and 9
Removing basic block 14
Removing basic block 15
Removing basic block 17
Removing basic block 18
Removing basic block 20
Removing basic block 21
<built-in> (struct .omp_data_s.41 & restrict .omp_data_i)
{
  int k;
  int j;
  long int .iend0.115;
  int i;
  long int .istart0.114;
  long int .iend0.113;
  long int .istart0.112;
  int _16;
  long int _17;
  bool _19;
  int _23;
  int _24;
  bool _27;
  long unsigned int _28;
  long unsigned int _29;
  double[4096] * _30;
  double[4096] * _31;
  double _32;
  double _33;
  double _34;
  int _36;
  double _39;
  double[4096] * _40;
  double[4096] * _41;
  double _42;
  double _43;
  double _44;
  long unsigned int _45;
  long unsigned int _46;
  double[4096] * _47;
  double[4096] * _48;
  double _49;
  double _50;
  double _51;
  int _55;
  int _60;

  <bb 2>:
  current_loop_index = 0;
  num_threads_defined = 8;
  q_data_transfer_write = 402653184;
  q_data_transfer_read = 134217728;
  type_of_data_allocation = 1;
  _16 = .omp_data_i_15(D)->ni;
  _17 = (long int) _16;
  _19 = __builtin_GOMP_loop_dynamic_start (0, _17, 1, 64, &.istart0.112, &.iend0.113);
  if (_19 != 0)
    goto <bb 3>;
  else
    goto <bb 11>;

  <bb 3>:

  <bb 4>:
  .istart0.114_20 = .istart0.112;
  i_21 = (int) .istart0.114_20;
  .iend0.115_22 = .iend0.113;
  _23 = (int) .iend0.115_22;

  <bb 5>:
  # i_1 = PHI <i_21(4), i_25(6)>
  _55 = .omp_data_i_15(D)->nj;
  if (_55 > 0)
    goto <bb 8>;
  else
    goto <bb 6>;

  <bb 6>:
  i_25 = i_1 + 1;
  if (i_25 < _23)
    goto <bb 5>;
  else
    goto <bb 7>;

  <bb 7>:
  _27 = __builtin_GOMP_loop_dynamic_next (&.istart0.112, &.iend0.113);
  if (_27 != 0)
    goto <bb 4>;
  else
    goto <bb 11>;

  <bb 8>:
  # j_61 = PHI <j_37(9), 0(5)>
  _28 = (long unsigned int) i_1;
  _29 = _28 * 32768;
  _30 = .omp_data_i_15(D)->C;
  _31 = _30 + _29;
  _32 = *_31[j_61];
  _33 = .omp_data_i_15(D)->beta;
  _34 = _32 * _33;
  *_31[j_61] = _34;
  _60 = .omp_data_i_15(D)->nk;
  if (_60 > 0)
    goto <bb 10>;
  else
    goto <bb 9>;

  <bb 9>:
  j_37 = j_61 + 1;
  _24 = .omp_data_i_15(D)->nj;
  if (_24 > j_37)
    goto <bb 8>;
  else
    goto <bb 6>;

  <bb 10>:
  # k_62 = PHI <k_53(10), 0(8)>
  _39 = *_31[j_61];
  _40 = .omp_data_i_15(D)->A;
  _41 = _40 + _29;
  _42 = *_41[k_62];
  _43 = .omp_data_i_15(D)->alpha;
  _44 = _42 * _43;
  _45 = (long unsigned int) k_62;
  _46 = _45 * 32768;
  _47 = .omp_data_i_15(D)->B;
  _48 = _47 + _46;
  _49 = *_48[j_61];
  _50 = _44 * _49;
  _51 = _39 + _50;
  *_31[j_61] = _51;
  k_53 = k_62 + 1;
  _36 = .omp_data_i_15(D)->nk;
  if (_36 > k_53)
    goto <bb 10>;
  else
    goto <bb 9>;

  <bb 11>:
  __builtin_GOMP_loop_end_nowait ();
  return;

}



;; Function void gemm_cuda_kernel(int, int, int, double, double, double*, double*, double*) (_Z16gemm_cuda_kerneliiiddPdS_S_, funcdef_no=3302, decl_uid=66844, cgraph_uid=3123)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5 6 7 8 9 10 11
;; 2 succs { 11 3 }
;; 3 succs { 11 4 }
;; 4 succs { 11 5 }
;; 5 succs { 11 6 }
;; 6 succs { 11 7 }
;; 7 succs { 11 8 }
;; 8 succs { 11 9 }
;; 9 succs { 11 10 }
;; 10 succs { 11 }
;; 11 succs { 1 }
void gemm_cuda_kernel(int, int, int, double, double, double*, double*, double*) (int __cuda_0, int __cuda_1, int __cuda_2, double __cuda_3, double __cuda_4, double * __cuda_5, double * __cuda_6, double * __cuda_7)
{
  static volatile char * __f;
  int __par0;
  int __par1;
  int __par2;
  double __par3;
  double __par4;
  double * __par5;
  double * __par6;
  double * __par7;
  cudaError _11;
  cudaError _12;
  cudaError _13;
  cudaError _14;
  cudaError _15;
  cudaError _16;
  cudaError _17;
  cudaError _18;

  <bb 2>:
  __par0 = __cuda_0_2(D);
  __par1 = __cuda_1_3(D);
  __par2 = __cuda_2_4(D);
  __par3 = __cuda_3_5(D);
  __par4 = __cuda_4_6(D);
  __par5 = __cuda_5_7(D);
  __par6 = __cuda_6_8(D);
  __par7 = __cuda_7_9(D);
  _11 = cudaSetupArgument (&__par0, 4, 0);
  if (_11 != 0)
    goto <bb 11>;
  else
    goto <bb 3>;

  <bb 3>:
  _12 = cudaSetupArgument (&__par1, 4, 4);
  if (_12 != 0)
    goto <bb 11>;
  else
    goto <bb 4>;

  <bb 4>:
  _13 = cudaSetupArgument (&__par2, 4, 8);
  if (_13 != 0)
    goto <bb 11>;
  else
    goto <bb 5>;

  <bb 5>:
  _14 = cudaSetupArgument (&__par3, 8, 16);
  if (_14 != 0)
    goto <bb 11>;
  else
    goto <bb 6>;

  <bb 6>:
  _15 = cudaSetupArgument (&__par4, 8, 24);
  if (_15 != 0)
    goto <bb 11>;
  else
    goto <bb 7>;

  <bb 7>:
  _16 = cudaSetupArgument (&__par5, 8, 32);
  if (_16 != 0)
    goto <bb 11>;
  else
    goto <bb 8>;

  <bb 8>:
  _17 = cudaSetupArgument (&__par6, 8, 40);
  if (_17 != 0)
    goto <bb 11>;
  else
    goto <bb 9>;

  <bb 9>:
  _18 = cudaSetupArgument (&__par7, 8, 48);
  if (_18 != 0)
    goto <bb 11>;
  else
    goto <bb 10>;

  <bb 10>:
  __f = gemm_cuda_kernel;
  cudaLaunch (gemm_cuda_kernel);

  <bb 11>:
  return;

}



;; Function float absVal(float) (_Z6absValf, funcdef_no=3240, decl_uid=65923, cgraph_uid=3062)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4
;; 2 succs { 3 4 }
;; 3 succs { 4 }
;; 4 succs { 1 }
float absVal(float) (float a)
{
  float _1;
  float _3;

  <bb 2>:
  if (a_2(D) < 0.0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  _3 = -a_2(D);

  <bb 4>:
  # _1 = PHI <_3(3), a_2(D)(2)>
  return _1;

}



;; Function float percentDiff(double, double) (_Z11percentDiffdd, funcdef_no=3241, decl_uid=65927, cgraph_uid=3063)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
;; 2 succs { 3 4 }
;; 3 succs { 4 }
;; 4 succs { 5 15 }
;; 5 succs { 6 7 }
;; 6 succs { 7 }
;; 7 succs { 14 15 }
;; 8 succs { 9 }
;; 9 succs { 10 11 }
;; 10 succs { 11 }
;; 11 succs { 12 13 }
;; 12 succs { 13 }
;; 13 succs { 14 }
;; 14 succs { 1 }
;; 15 succs { 8 9 }
float percentDiff(double, double) (double val1, double val2)
{
  bool iftmp.1;
  float _2;
  float _4;
  double _5;
  float _7;
  double _8;
  double _9;
  float _10;
  double _11;
  float _12;
  float _13;
  float _14;
  float _16;
  float _17;
  float _18;
  float _19;
  float _20;
  float _21;
  float _22;
  float _23;
  float _24;
  float _25;

  <bb 2>:
  _4 = (float) val1_3(D);
  if (_4 < 0.0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  _16 = -_4;

  <bb 4>:
  # _17 = PHI <_4(2), _16(3)>
  _5 = (double) _17;
  if (_5 < 1.00000000000000002081668171172168513294309377670288085938e-2)
    goto <bb 5>;
  else
    goto <bb 15>;

  <bb 5>:
  _7 = (float) val2_6(D);
  if (_7 < 0.0)
    goto <bb 6>;
  else
    goto <bb 7>;

  <bb 6>:
  _18 = -_7;

  <bb 7>:
  # _19 = PHI <_7(5), _18(6)>
  _8 = (double) _19;
  if (_8 < 1.00000000000000002081668171172168513294309377670288085938e-2)
    goto <bb 14>;
  else
    goto <bb 15>;

  <bb 8>:
  _20 = -_10;

  <bb 9>:
  # _21 = PHI <_10(15), _20(8)>
  _11 = val1_3(D) + 9.99999993922529029077850282192230224609375e-9;
  _12 = (float) _11;
  if (_12 < 0.0)
    goto <bb 10>;
  else
    goto <bb 11>;

  <bb 10>:
  _22 = -_12;

  <bb 11>:
  # _23 = PHI <_12(9), _22(10)>
  _13 = _21 / _23;
  if (_13 < 0.0)
    goto <bb 12>;
  else
    goto <bb 13>;

  <bb 12>:
  _24 = -_13;

  <bb 13>:
  # _25 = PHI <_13(11), _24(12)>
  _14 = _25 * 1.0e+2;

  <bb 14>:
  # _2 = PHI <0.0(7), _14(13)>
  return _2;

  <bb 15>:
  _9 = val1_3(D) - val2_6(D);
  _10 = (float) _9;
  if (_10 < 0.0)
    goto <bb 8>;
  else
    goto <bb 9>;

}



;; Function uint64_t get_time() (_Z8get_timev, funcdef_no=3246, decl_uid=66101, cgraph_uid=3068)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
uint64_t get_time() ()
{
  struct timespec spec;
  long int _3;
  long unsigned int _4;
  long unsigned int _5;
  long int _6;
  long unsigned int _7;
  uint64_t _8;

  <bb 2>:
  clock_gettime (1, &spec);
  _3 = spec.tv_sec;
  _4 = (long unsigned int) _3;
  _5 = _4 * 1000000000;
  _6 = spec.tv_nsec;
  _7 = (long unsigned int) _6;
  _8 = _5 + _7;
  spec ={v} {CLOBBER};
  return _8;

}



;; Function void hookomp_timing_start(uint64_t*) (_Z20hookomp_timing_startPm, funcdef_no=3247, decl_uid=66105, cgraph_uid=3069)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void hookomp_timing_start(uint64_t*) (uint64_t * _start)
{
  struct timespec spec;
  long int _5;
  long unsigned int _6;
  long unsigned int _7;
  long int _8;
  long unsigned int _9;
  uint64_t _10;

  <bb 2>:
  clock_gettime (1, &spec);
  _5 = spec.tv_sec;
  _6 = (long unsigned int) _5;
  _7 = _6 * 1000000000;
  _8 = spec.tv_nsec;
  _9 = (long unsigned int) _8;
  _10 = _7 + _9;
  spec ={v} {CLOBBER};
  *_start_3(D) = _10;
  return;

}



;; Function void hookomp_timing_stop(uint64_t*) (_Z19hookomp_timing_stopPm, funcdef_no=3248, decl_uid=66108, cgraph_uid=3070)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void hookomp_timing_stop(uint64_t*) (uint64_t * _stop)
{
  struct timespec spec;
  long int _5;
  long unsigned int _6;
  long unsigned int _7;
  long int _8;
  long unsigned int _9;
  uint64_t _10;

  <bb 2>:
  clock_gettime (1, &spec);
  _5 = spec.tv_sec;
  _6 = (long unsigned int) _5;
  _7 = _6 * 1000000000;
  _8 = spec.tv_nsec;
  _9 = (long unsigned int) _8;
  _10 = _7 + _9;
  spec ={v} {CLOBBER};
  *_stop_3(D) = _10;
  return;

}



;; Function void hookomp_timing_print(uint64_t, uint64_t) (_Z20hookomp_timing_printmm, funcdef_no=3249, decl_uid=66112, cgraph_uid=3071)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void hookomp_timing_print(uint64_t, uint64_t) (uint64_t tstart, uint64_t tstop)
{
  long unsigned int _3;

  <bb 2>:
  _3 = tstop_1(D) - tstart_2(D);
  __printf_chk (1, "%llu", _3);
  return;

}



;; Function void hookomp_timing_print_without_dev() (_Z32hookomp_timing_print_without_devv, funcdef_no=3250, decl_uid=66114, cgraph_uid=3072)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4
;; 2 succs { 3 4 }
;; 3 succs { 4 }
;; 4 succs { 1 }
void hookomp_timing_print_without_dev() ()
{
  uint64_t dt_time;
  uint64_t dev_time;
  uint64_t total_time;
  uint64_t iftmp.14;
  long unsigned int data_transfer_d2h_start.13;
  long unsigned int data_transfer_d2h_stop.12;
  long unsigned int data_transfer_h2d_start.11;
  long unsigned int data_transfer_h2d_stop.10;
  long unsigned int dev_kernel3_start.9;
  long unsigned int dev_kernel3_stop.8;
  long unsigned int dev_kernel2_start.7;
  long unsigned int dev_kernel2_stop.6;
  long unsigned int dev_kernel1_start.5;
  long unsigned int dev_kernel1_stop.4;
  long unsigned int omp_start.3;
  long unsigned int omp_stop.2;
  long unsigned int _8;
  long unsigned int _11;
  long unsigned int _12;
  long unsigned int _15;
  long unsigned int _19;
  long unsigned int _22;
  long unsigned int _24;

  <bb 2>:
  omp_stop.2_3 = omp_stop;
  omp_start.3_4 = omp_start;
  total_time_5 = omp_stop.2_3 - omp_start.3_4;
  dev_kernel1_stop.4_6 = dev_kernel1_stop;
  dev_kernel1_start.5_7 = dev_kernel1_start;
  _8 = dev_kernel1_stop.4_6 - dev_kernel1_start.5_7;
  dev_kernel2_stop.6_9 = dev_kernel2_stop;
  dev_kernel2_start.7_10 = dev_kernel2_start;
  _11 = dev_kernel2_stop.6_9 - dev_kernel2_start.7_10;
  _12 = _8 + _11;
  dev_kernel3_stop.8_13 = dev_kernel3_stop;
  dev_kernel3_start.9_14 = dev_kernel3_start;
  _15 = dev_kernel3_stop.8_13 - dev_kernel3_start.9_14;
  dev_time_16 = _12 + _15;
  data_transfer_h2d_stop.10_17 = data_transfer_h2d_stop;
  data_transfer_h2d_start.11_18 = data_transfer_h2d_start;
  _19 = data_transfer_h2d_stop.10_17 - data_transfer_h2d_start.11_18;
  data_transfer_d2h_stop.12_20 = data_transfer_d2h_stop;
  data_transfer_d2h_start.13_21 = data_transfer_d2h_start;
  _22 = data_transfer_d2h_stop.12_20 - data_transfer_d2h_start.13_21;
  dt_time_23 = _19 + _22;
  if (total_time_5 != 0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  _24 = total_time_5 - dev_time_16;
  iftmp.14_25 = _24 - dt_time_23;

  <bb 4>:
  # iftmp.14_1 = PHI <iftmp.14_25(3), 0(2)>
  __printf_chk (1, "%llu", iftmp.14_1);
  return;

}



;; Function void hookomp_print_time_results() (_Z26hookomp_print_time_resultsv, funcdef_no=3251, decl_uid=66119, cgraph_uid=3073)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4
;; 2 succs { 3 4 }
;; 3 succs { 4 }
;; 4 succs { 1 }
void hookomp_print_time_results() ()
{
  uint64_t dt_time;
  uint64_t dev_time;
  uint64_t total_time;
  uint64_t iftmp.14;
  long unsigned int data_transfer_d2h_start.13;
  long unsigned int data_transfer_d2h_stop.12;
  long unsigned int data_transfer_h2d_start.11;
  long unsigned int data_transfer_h2d_stop.10;
  long unsigned int dev_kernel3_start.9;
  long unsigned int dev_kernel3_stop.8;
  long unsigned int dev_kernel2_start.7;
  long unsigned int dev_kernel2_stop.6;
  long unsigned int dev_kernel1_start.5;
  long unsigned int dev_kernel1_stop.4;
  long unsigned int omp_start.3;
  long unsigned int omp_stop.2;
  bool made_the_offloading.33;
  bool decided_by_offloading.32;
  bool reach_offload_decision_point.31;
  int iftmp.30;
  long unsigned int data_transfer_d2h_start.29;
  long unsigned int data_transfer_d2h_stop.28;
  long unsigned int data_transfer_h2d_start.27;
  long unsigned int data_transfer_h2d_stop.26;
  long unsigned int dev_kernel3_start.25;
  long unsigned int dev_kernel3_stop.24;
  long unsigned int dev_kernel2_start.23;
  long unsigned int dev_kernel2_stop.22;
  long unsigned int dev_kernel1_start.21;
  long unsigned int dev_kernel1_stop.20;
  long unsigned int omp_start.19;
  long unsigned int omp_stop.18;
  long unsigned int seq_start.17;
  long unsigned int seq_stop.16;
  struct _IO_FILE * stdout.15;
  int _59;
  int _63;
  int _67;
  long unsigned int _72;
  long unsigned int _73;
  long unsigned int _74;
  long unsigned int _75;
  long unsigned int _76;
  long unsigned int _77;
  long unsigned int _78;
  long unsigned int _111;
  long unsigned int _114;
  long unsigned int _115;
  long unsigned int _118;
  long unsigned int _122;
  long unsigned int _125;
  long unsigned int _127;
  bool _131;
  int _132;

  <bb 2>:
  stdout.15_3 = stdout;
  __fprintf_chk (stdout.15_3, 1, "ORIG = ");
  seq_stop.16_5 = seq_stop;
  seq_start.17_6 = seq_start;
  _72 = seq_stop.16_5 - seq_start.17_6;
  __printf_chk (1, "%llu", _72);
  stdout.15_8 = stdout;
  __fprintf_chk (stdout.15_8, 1, ", ");
  stdout.15_10 = stdout;
  __fprintf_chk (stdout.15_10, 1, "OMP_OFF = ");
  omp_stop.18_12 = omp_stop;
  omp_start.19_13 = omp_start;
  _73 = omp_stop.18_12 - omp_start.19_13;
  __printf_chk (1, "%llu", _73);
  stdout.15_15 = stdout;
  __fprintf_chk (stdout.15_15, 1, ", ");
  stdout.15_17 = stdout;
  __fprintf_chk (stdout.15_17, 1, "OMP = ");
  omp_stop.2_106 = omp_stop;
  omp_start.3_107 = omp_start;
  total_time_108 = omp_stop.2_106 - omp_start.3_107;
  dev_kernel1_stop.4_109 = dev_kernel1_stop;
  dev_kernel1_start.5_110 = dev_kernel1_start;
  _111 = dev_kernel1_stop.4_109 - dev_kernel1_start.5_110;
  dev_kernel2_stop.6_112 = dev_kernel2_stop;
  dev_kernel2_start.7_113 = dev_kernel2_start;
  _114 = dev_kernel2_stop.6_112 - dev_kernel2_start.7_113;
  _115 = _111 + _114;
  dev_kernel3_stop.8_116 = dev_kernel3_stop;
  dev_kernel3_start.9_117 = dev_kernel3_start;
  _118 = dev_kernel3_stop.8_116 - dev_kernel3_start.9_117;
  dev_time_119 = _115 + _118;
  data_transfer_h2d_stop.10_120 = data_transfer_h2d_stop;
  data_transfer_h2d_start.11_121 = data_transfer_h2d_start;
  _122 = data_transfer_h2d_stop.10_120 - data_transfer_h2d_start.11_121;
  data_transfer_d2h_stop.12_123 = data_transfer_d2h_stop;
  data_transfer_d2h_start.13_124 = data_transfer_d2h_start;
  _125 = data_transfer_d2h_stop.12_123 - data_transfer_d2h_start.13_124;
  dt_time_126 = _122 + _125;
  if (total_time_108 != 0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  _127 = total_time_108 - dev_time_119;
  iftmp.14_128 = _127 - dt_time_126;

  <bb 4>:
  # iftmp.14_129 = PHI <0(2), iftmp.14_128(3)>
  __printf_chk (1, "%llu", iftmp.14_129);
  stdout.15_20 = stdout;
  __fprintf_chk (stdout.15_20, 1, ", ");
  stdout.15_22 = stdout;
  __fprintf_chk (stdout.15_22, 1, "CUDA_KERNEL1 = ");
  dev_kernel1_stop.20_24 = dev_kernel1_stop;
  dev_kernel1_start.21_25 = dev_kernel1_start;
  _74 = dev_kernel1_stop.20_24 - dev_kernel1_start.21_25;
  __printf_chk (1, "%llu", _74);
  stdout.15_27 = stdout;
  __fprintf_chk (stdout.15_27, 1, ", ");
  stdout.15_29 = stdout;
  __fprintf_chk (stdout.15_29, 1, "CUDA_KERNEL2 = ");
  dev_kernel2_stop.22_31 = dev_kernel2_stop;
  dev_kernel2_start.23_32 = dev_kernel2_start;
  _75 = dev_kernel2_stop.22_31 - dev_kernel2_start.23_32;
  __printf_chk (1, "%llu", _75);
  stdout.15_34 = stdout;
  __fprintf_chk (stdout.15_34, 1, ", ");
  stdout.15_36 = stdout;
  __fprintf_chk (stdout.15_36, 1, "CUDA_KERNEL3 = ");
  dev_kernel3_stop.24_38 = dev_kernel3_stop;
  dev_kernel3_start.25_39 = dev_kernel3_start;
  _76 = dev_kernel3_stop.24_38 - dev_kernel3_start.25_39;
  __printf_chk (1, "%llu", _76);
  stdout.15_41 = stdout;
  __fprintf_chk (stdout.15_41, 1, ", ");
  stdout.15_43 = stdout;
  __fprintf_chk (stdout.15_43, 1, "DT_H2D = ");
  data_transfer_h2d_stop.26_45 = data_transfer_h2d_stop;
  data_transfer_h2d_start.27_46 = data_transfer_h2d_start;
  _77 = data_transfer_h2d_stop.26_45 - data_transfer_h2d_start.27_46;
  __printf_chk (1, "%llu", _77);
  stdout.15_48 = stdout;
  __fprintf_chk (stdout.15_48, 1, ", ");
  stdout.15_50 = stdout;
  __fprintf_chk (stdout.15_50, 1, "DT_D2H = ");
  data_transfer_d2h_stop.28_52 = data_transfer_d2h_stop;
  data_transfer_d2h_start.29_53 = data_transfer_d2h_start;
  _78 = data_transfer_d2h_stop.28_52 - data_transfer_d2h_start.29_53;
  __printf_chk (1, "%llu", _78);
  reach_offload_decision_point.31_55 = reach_offload_decision_point;
  _131 = ~reach_offload_decision_point.31_55;
  _132 = (int) _131;
  stdout.15_56 = stdout;
  __fprintf_chk (stdout.15_56, 1, ", WORK_FINISHED_BEFORE_OFFLOAD_DECISION = %d", _132);
  reach_offload_decision_point.31_58 = reach_offload_decision_point;
  _59 = (int) reach_offload_decision_point.31_58;
  stdout.15_60 = stdout;
  __fprintf_chk (stdout.15_60, 1, ", REACH_OFFLOAD_DECISION_POINT = %d", _59);
  decided_by_offloading.32_62 = decided_by_offloading;
  _63 = (int) decided_by_offloading.32_62;
  stdout.15_64 = stdout;
  __fprintf_chk (stdout.15_64, 1, ", DECIDED_BY_OFFLOADING = %d", _63);
  made_the_offloading.33_66 = made_the_offloading;
  _67 = (int) made_the_offloading.33_66;
  stdout.15_68 = stdout;
  __fprintf_chk (stdout.15_68, 1, ", MADE_THE_OFFLOADING = %d", _67);
  stdout.15_70 = stdout;
  __fprintf_chk (stdout.15_70, 1, "\n");
  return;

}



;; Function bool create_target_functions_table(Func****, int, int) (_Z29create_target_functions_tablePPPP4Funcii, funcdef_no=3256, decl_uid=66664, cgraph_uid=3078)

Created preheader block for loop 2
;; 3 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 6 5 12 7 8 9 10 11
;;
;; Loop 1
;;  header 9, latch 8
;;  depth 1, outer 0
;;  nodes: 9 8 12 7 4 6 5
;;
;; Loop 2
;;  header 12, latch 5
;;  depth 2, outer 1
;;  nodes: 12 5
;; 2 succs { 3 10 }
;; 3 succs { 9 }
;; 4 succs { 6 7 }
;; 6 succs { 12 }
;; 5 succs { 12 }
;; 12 succs { 5 8 }
;; 7 succs { 8 }
;; 8 succs { 9 }
;; 9 succs { 4 11 }
;; 10 succs { 11 }
;; 11 succs { 1 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

j_57 -> { j_5 }
i_58 -> { i_4 }
.MEM_59 -> { .MEM_6 }
result_60 -> { result_2 }
.MEM_61 -> { .MEM_8 }
result_62 -> { result_2 }
i_63 -> { i_4 }
j_64 -> { j_5 }
.MEM_65 -> { .MEM_6 }
.MEM_66 -> { .MEM_8 }
Incremental SSA update started at block: 2
Number of blocks in CFG: 19
Number of blocks to update: 12 ( 63%)


Merging blocks 3 and 13
Merging blocks 5 and 12
Merging blocks 6 and 16
Merging blocks 8 and 9
Removing basic block 14
Removing basic block 15
Removing basic block 17
Removing basic block 18
bool create_target_functions_table(Func****, int, int) (struct Func * * * * table_, int nrows, int ncolumns)
{
  int j;
  int i;
  bool result;
  struct Func * * * table;
  struct _IO_FILE * stderr.34;
  long unsigned int _14;
  long unsigned int _15;
  long unsigned int _20;
  long unsigned int _21;
  struct Func * * * _22;
  long unsigned int _24;
  long unsigned int _25;
  void * _27;
  struct Func * * _29;
  long unsigned int _30;
  long unsigned int _31;
  struct Func * * _32;
  void * _34;
  struct Func * * _36;
  struct Func * * _37;
  struct Func * _38;

  <bb 2>:
  stderr.34_11 = stderr;
  __fprintf_chk (stderr.34_11, 1, "Allocating the rows.\n");
  _14 = (long unsigned int) nrows_13(D);
  _15 = _14 * 8;
  table_17 = malloc (_15);
  if (table_17 != 0B)
    goto <bb 3>;
  else
    goto <bb 9>;

  <bb 3>:
  stderr.34_18 = stderr;
  __fprintf_chk (stderr.34_18, 1, "Allocating the columns.\n");
  if (nrows_13(D) > 0)
    goto <bb 4>;
  else
    goto <bb 10>;

  <bb 4>:
  # result_62 = PHI <result_1(8), 1(3)>
  # i_63 = PHI <i_43(8), 0(3)>
  _20 = (long unsigned int) i_63;
  _21 = _20 * 8;
  _22 = table_17 + _21;
  _24 = (long unsigned int) ncolumns_23(D);
  _25 = _24 * 8;
  _27 = malloc (_25);
  *_22 = _27;
  if (_27 != 0B)
    goto <bb 5>;
  else
    goto <bb 7>;

  <bb 5>:
  # j_56 = PHI <0(4)>
  if (ncolumns_23(D) > j_56)
    goto <bb 6>;
  else
    goto <bb 8>;

  <bb 6>:
  # j_64 = PHI <j_40(6), j_56(5)>
  _29 = *_22;
  _30 = (long unsigned int) j_64;
  _31 = _30 * 8;
  _32 = _29 + _31;
  _34 = malloc (48);
  *_32 = _34;
  _36 = *_22;
  _37 = _36 + _31;
  _38 = *_37;
  _38->f = 0B;
  j_40 = j_64 + 1;
  if (ncolumns_23(D) > j_40)
    goto <bb 6>;
  else
    goto <bb 8>;

  <bb 7>:
  stderr.34_41 = stderr;
  __fprintf_chk (stderr.34_41, 1, "Error in table of target functions allocation (columns).\n");

  <bb 8>:
  # result_1 = PHI <result_62(6), 0(7), result_62(5)>
  i_43 = i_63 + 1;
  if (nrows_13(D) > i_43)
    goto <bb 4>;
  else
    goto <bb 10>;

  <bb 9>:
  stderr.34_44 = stderr;
  __fprintf_chk (stderr.34_44, 1, "Error in table of target functions allocation (rows).\n");

  <bb 10>:
  # result_3 = PHI <result_1(8), 0(9), 1(3)>
  stderr.34_46 = stderr;
  __fprintf_chk (stderr.34_46, 1, "Allocating the columns is OK.\n");
  *table__48(D) = table_17;
  return result_3;

}



;; Function void call_function_ffi_call(Func*) (_Z22call_function_ffi_callP4Func, funcdef_no=3257, decl_uid=66679, cgraph_uid=3079)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4
;; 2 succs { 3 4 }
;; 3 succs { }
;; 4 succs { 1 }
void call_function_ffi_call(Func*) (struct Func * ff)
{
  struct ffi_cif cif;
  struct _IO_FILE * stderr.35;
  struct ffi_type * * _5;
  struct ffi_type * _6;
  int _7;
  unsigned int _8;
  ffi_status _10;
  void * * _14;
  void * _15;
  void * _16;
  void (*<T19f3>) (void) _17;

  <bb 2>:
  stderr.35_2 = stderr;
  __fprintf_chk (stderr.35_2, 1, " In call_function_ffi_call.\n");
  _5 = ff_4(D)->arg_types;
  _6 = ff_4(D)->ret_type;
  _7 = ff_4(D)->nargs;
  _8 = (unsigned int) _7;
  _10 = ffi_prep_cif (&cif, 2, _8, _6, _5);
  if (_10 != 0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  stderr.35_11 = stderr;
  __fprintf_chk (stderr.35_11, 1, "Error ffi_prep_cif.\n");
  exit (1);

  <bb 4>:
  _14 = ff_4(D)->arg_values;
  _15 = ff_4(D)->ret_value;
  _16 = ff_4(D)->f;
  _17 = (void (*<T19f3>) (void)) _16;
  ffi_call (&cif, _17, _15, _14);
  cif ={v} {CLOBBER};
  return;

}



;; Function void init_array(int, int, int, double*, double*, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z10init_arrayiiiPdS_PA4096_dS1_S1_, funcdef_no=3258, decl_uid=66690, cgraph_uid=3080)

Created preheader block for loop 3
Created preheader block for loop 4
Created preheader block for loop 2
Created preheader block for loop 5
Created preheader block for loop 6
;; 7 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 20 5 6 4 10 7 19 9 18 8 14 11 17 13 16 12 15
;;
;; Loop 3
;;  header 16, latch 13
;;  depth 1, outer 0
;;  nodes: 16 13 17 12 11
;;
;; Loop 4
;;  header 17, latch 11
;;  depth 2, outer 3
;;  nodes: 17 11
;;
;; Loop 2
;;  header 18, latch 9
;;  depth 1, outer 0
;;  nodes: 18 9 19 8 7
;;
;; Loop 5
;;  header 19, latch 7
;;  depth 2, outer 2
;;  nodes: 19 7
;;
;; Loop 1
;;  header 6, latch 5
;;  depth 1, outer 0
;;  nodes: 6 5 20 4 3
;;
;; Loop 6
;;  header 20, latch 3
;;  depth 2, outer 1
;;  nodes: 20 3
;; 2 succs { 6 }
;; 3 succs { 20 }
;; 20 succs { 3 5 }
;; 5 succs { 6 }
;; 6 succs { 4 10 }
;; 4 succs { 20 }
;; 10 succs { 18 }
;; 7 succs { 19 }
;; 19 succs { 7 9 }
;; 9 succs { 18 }
;; 18 succs { 8 14 }
;; 8 succs { 19 }
;; 14 succs { 16 }
;; 11 succs { 17 }
;; 17 succs { 11 13 }
;; 13 succs { 16 }
;; 16 succs { 12 15 }
;; 12 succs { 17 }
;; 15 succs { 1 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

.MEM_64 -> { .MEM_10 }
j_65 -> { j_6 }
i_66 -> { i_3 }
j_67 -> { j_5 }
.MEM_68 -> { .MEM_11 }
.MEM_69 -> { .MEM_12 }
i_70 -> { i_2 }
.MEM_71 -> { .MEM_9 }
i_72 -> { i_1 }
.MEM_73 -> { .MEM_8 }
j_74 -> { j_4 }
.MEM_75 -> { .MEM_7 }
i_76 -> { i_1 }
i_77 -> { i_2 }
i_78 -> { i_3 }
j_79 -> { j_4 }
j_80 -> { j_5 }
j_81 -> { j_6 }
.MEM_82 -> { .MEM_7 }
.MEM_83 -> { .MEM_7 }
.MEM_84 -> { .MEM_9 }
.MEM_85 -> { .MEM_9 }
.MEM_86 -> { .MEM_11 }
.MEM_87 -> { .MEM_11 }
.MEM_88 -> { .MEM_12 }
Incremental SSA update started at block: 33
Number of blocks in CFG: 39
Number of blocks to update: 36 ( 92%)


Merging blocks 2 and 33
Merging blocks 3 and 20
Merging blocks 4 and 36
Merging blocks 5 and 6
Merging blocks 7 and 19
Merging blocks 8 and 30
Merging blocks 9 and 18
Merging blocks 10 and 27
Merging blocks 11 and 17
Merging blocks 12 and 24
Merging blocks 13 and 16
Merging blocks 14 and 21
Removing basic block 22
Removing basic block 23
Removing basic block 25
Removing basic block 26
Removing basic block 28
Removing basic block 29
Removing basic block 31
Removing basic block 32
Removing basic block 34
Removing basic block 35
Removing basic block 37
Removing basic block 38
void init_array(int, int, int, double*, double*, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double * alpha, double * beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int j;
  int i;
  long unsigned int _21;
  long unsigned int _22;
  double[4096] * _24;
  double _25;
  double _26;
  double _27;
  double _28;
  long unsigned int _34;
  long unsigned int _35;
  double[4096] * _37;
  double _38;
  double _39;
  double _40;
  double _41;
  long unsigned int _46;
  long unsigned int _47;
  double[4096] * _49;
  double _50;
  double _51;
  double _52;
  double _53;

  <bb 2>:
  *alpha_14(D) = 3.2412e+4;
  *beta_16(D) = 2.123e+3;
  if (ni_18(D) > 0)
    goto <bb 5>;
  else
    goto <bb 6>;

  <bb 3>:
  # j_79 = PHI <j_30(3), j_45(5)>
  _21 = (long unsigned int) i_76;
  _22 = _21 * 32768;
  _24 = A_23(D) + _22;
  _25 = (double) i_76;
  _26 = (double) j_79;
  _27 = _25 * _26;
  _28 = _27 * 2.44140625e-4;
  *_24[j_79] = _28;
  j_30 = j_79 + 1;
  if (nk_20(D) > j_30)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 4>:
  i_31 = i_76 + 1;
  if (ni_18(D) > i_31)
    goto <bb 5>;
  else
    goto <bb 6>;

  <bb 5>:
  # j_45 = PHI <0(4), 0(2)>
  # i_76 = PHI <i_31(4), 0(2)>
  if (nk_20(D) > j_45)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 6>:
  # i_63 = PHI <0(4), 0(2)>
  if (nk_20(D) > i_63)
    goto <bb 9>;
  else
    goto <bb 10>;

  <bb 7>:
  # j_80 = PHI <j_43(7), j_62(9)>
  _34 = (long unsigned int) i_77;
  _35 = _34 * 32768;
  _37 = B_36(D) + _35;
  _38 = (double) i_77;
  _39 = (double) j_80;
  _40 = _38 * _39;
  _41 = _40 * 2.44140625e-4;
  *_37[j_80] = _41;
  j_43 = j_80 + 1;
  if (nj_33(D) > j_43)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 8>:
  i_44 = i_77 + 1;
  if (nk_20(D) > i_44)
    goto <bb 9>;
  else
    goto <bb 10>;

  <bb 9>:
  # j_62 = PHI <0(8), 0(6)>
  # i_77 = PHI <i_44(8), i_63(6)>
  if (nj_33(D) > j_62)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 10>:
  # i_57 = PHI <0(8), 0(6)>
  if (ni_18(D) > i_57)
    goto <bb 13>;
  else
    goto <bb 14>;

  <bb 11>:
  # j_81 = PHI <j_55(11), j_61(13)>
  _46 = (long unsigned int) i_78;
  _47 = _46 * 32768;
  _49 = C_48(D) + _47;
  _50 = (double) i_78;
  _51 = (double) j_81;
  _52 = _50 * _51;
  _53 = _52 * 2.44140625e-4;
  *_49[j_81] = _53;
  j_55 = j_81 + 1;
  if (nj_33(D) > j_55)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 12>:
  i_56 = i_78 + 1;
  if (ni_18(D) > i_56)
    goto <bb 13>;
  else
    goto <bb 14>;

  <bb 13>:
  # j_61 = PHI <0(12), 0(10)>
  # i_78 = PHI <i_56(12), i_57(10)>
  if (nj_33(D) > j_61)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 14>:
  return;

}



;; Function void copy_array(int, int, double (*)[4096], double (*)[4096]) (_Z10copy_arrayiiPA4096_dS0_, funcdef_no=3259, decl_uid=66722, cgraph_uid=3081)

Created preheader block for loop 2
;; 3 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 8 5 6 4 7
;;
;; Loop 1
;;  header 6, latch 5
;;  depth 1, outer 0
;;  nodes: 6 5 8 4 3
;;
;; Loop 2
;;  header 8, latch 3
;;  depth 2, outer 1
;;  nodes: 8 3
;; 2 succs { 6 }
;; 3 succs { 8 }
;; 8 succs { 3 5 }
;; 5 succs { 6 }
;; 6 succs { 4 7 }
;; 4 succs { 8 }
;; 7 succs { 1 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

i_20 -> { i_1 }
.MEM_21 -> { .MEM_4 }
j_22 -> { j_2 }
.MEM_23 -> { .MEM_3 }
i_24 -> { i_1 }
j_25 -> { j_2 }
.MEM_26 -> { .MEM_3 }
.MEM_27 -> { .MEM_3 }
.MEM_28 -> { .MEM_4 }
Incremental SSA update started at block: 9
Number of blocks in CFG: 15
Number of blocks to update: 12 ( 80%)


Merging blocks 2 and 9
Merging blocks 3 and 8
Merging blocks 4 and 12
Merging blocks 5 and 6
Removing basic block 10
Removing basic block 11
Removing basic block 13
Removing basic block 14
void copy_array(int, int, double (*)[4096], double (*)[4096]) (int ni, int nj, double[4096] * C_source, double[4096] * C_dest)
{
  int j;
  int i;
  long unsigned int _8;
  long unsigned int _9;
  double[4096] * _11;
  double[4096] * _14;
  double _15;

  <bb 2>:
  if (ni_6(D) > 0)
    goto <bb 5>;
  else
    goto <bb 6>;

  <bb 3>:
  # j_25 = PHI <j_17(3), j_19(5)>
  _8 = (long unsigned int) i_24;
  _9 = _8 * 32768;
  _11 = C_dest_10(D) + _9;
  _14 = C_source_13(D) + _9;
  _15 = *_14[j_25];
  *_11[j_25] = _15;
  j_17 = j_25 + 1;
  if (nj_7(D) > j_17)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 4>:
  i_18 = i_24 + 1;
  if (ni_6(D) > i_18)
    goto <bb 5>;
  else
    goto <bb 6>;

  <bb 5>:
  # j_19 = PHI <0(4), 0(2)>
  # i_24 = PHI <i_18(4), 0(2)>
  if (nj_7(D) > j_19)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 6>:
  return;

}



;; Function void compareResults(int, int, double (*)[4096], double (*)[4096]) (_Z14compareResultsiiPA4096_dS0_, funcdef_no=3260, decl_uid=66738, cgraph_uid=3082)

;; 3 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
;;
;; Loop 1
;;  header 20, latch 19
;;  depth 1, outer 0
;;  nodes: 20 19 18 21 17 15 16 8 14 12 13 10 11 23 9 5 3 4 6 7
;;
;; Loop 2
;;  header 18, latch 17
;;  depth 2, outer 1
;;  nodes: 18 17 15 16 8 14 12 13 10 11 23 9 5 3 4 6 7
;; 2 succs { 20 }
;; 3 succs { 4 5 }
;; 4 succs { 5 }
;; 5 succs { 6 23 }
;; 6 succs { 7 8 }
;; 7 succs { 8 }
;; 8 succs { 15 23 }
;; 9 succs { 10 }
;; 10 succs { 11 12 }
;; 11 succs { 12 }
;; 12 succs { 13 14 }
;; 13 succs { 14 }
;; 14 succs { 15 }
;; 15 succs { 16 17 }
;; 16 succs { 17 }
;; 17 succs { 18 }
;; 18 succs { 3 19 }
;; 19 succs { 20 }
;; 20 succs { 21 22 }
;; 21 succs { 18 }
;; 22 succs { 1 }
;; 23 succs { 9 10 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

j_15 -> { j_2 }
fail_35 -> { fail_4 }
fail_50 -> { fail_5 }
i_51 -> { i_1 }
i_52 -> { i_1 }
j_53 -> { j_2 }
fail_54 -> { fail_4 }
Incremental SSA update started at block: 24
Number of blocks in CFG: 30
Number of blocks to update: 15 ( 50%)


Merging blocks 2 and 24
Merging blocks 17 and 18
Merging blocks 19 and 20
Merging blocks 21 and 27
Removing basic block 25
Removing basic block 26
Removing basic block 28
Removing basic block 29
void compareResults(int, int, double (*)[4096], double (*)[4096]) (int ni, int nj, double[4096] * C, double[4096] * C_output)
{
  bool iftmp.1;
  float D.68697;
  int fail;
  int j;
  int i;
  struct _IO_FILE * stderr.38;
  long unsigned int _8;
  long unsigned int _9;
  double[4096] * _11;
  double _13;
  double[4096] * _17;
  double _18;
  double _20;
  float _27;
  float _28;
  float _29;
  double _30;
  float _31;
  float _32;
  float _33;
  double _34;
  double _36;
  float _37;
  float _38;
  double _39;
  float _40;
  float _41;
  float _42;
  float _43;
  float _44;
  float _45;
  float _46;
  float _47;
  float _48;

  <bb 2>:
  if (ni_6(D) > 0)
    goto <bb 19>;
  else
    goto <bb 20>;

  <bb 3>:
  # j_53 = PHI <j_22(17), 0(19)>
  # fail_54 = PHI <fail_3(17), fail_49(19)>
  _8 = (long unsigned int) i_52;
  _9 = _8 * 32768;
  _11 = C_output_10(D) + _9;
  _13 = *_11[j_53];
  _17 = C_16(D) + _9;
  _18 = *_17[j_53];
  _27 = (float) _18;
  if (_27 < 0.0)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 4>:
  _28 = -_27;

  <bb 5>:
  # _29 = PHI <_27(3), _28(4)>
  _30 = (double) _29;
  if (_30 < 1.00000000000000002081668171172168513294309377670288085938e-2)
    goto <bb 6>;
  else
    goto <bb 21>;

  <bb 6>:
  _31 = (float) _13;
  if (_31 < 0.0)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 7>:
  _32 = -_31;

  <bb 8>:
  # _33 = PHI <_31(6), _32(7)>
  _34 = (double) _33;
  if (_34 < 1.00000000000000002081668171172168513294309377670288085938e-2)
    goto <bb 15>;
  else
    goto <bb 21>;

  <bb 9>:
  _38 = -_37;

  <bb 10>:
  # _42 = PHI <_37(21), _38(9)>
  _39 = _18 + 9.99999993922529029077850282192230224609375e-9;
  _40 = (float) _39;
  if (_40 < 0.0)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 11>:
  _41 = -_40;

  <bb 12>:
  # _43 = PHI <_40(10), _41(11)>
  _44 = _42 / _43;
  if (_44 < 0.0)
    goto <bb 13>;
  else
    goto <bb 14>;

  <bb 13>:
  _45 = -_44;

  <bb 14>:
  # _46 = PHI <_44(12), _45(13)>
  _47 = _46 * 1.0e+2;

  <bb 15>:
  # _48 = PHI <0.0(8), _47(14)>
  _20 = (double) _48;
  if (_20 > 5.000000000000000277555756156289135105907917022705078125e-2)
    goto <bb 16>;
  else
    goto <bb 17>;

  <bb 16>:
  fail_21 = fail_54 + 1;

  <bb 17>:
  # fail_3 = PHI <fail_54(15), fail_21(16)>
  j_22 = j_53 + 1;
  if (nj_7(D) > j_22)
    goto <bb 3>;
  else
    goto <bb 18>;

  <bb 18>:
  # fail_19 = PHI <fail_3(17), fail_49(19)>
  i_23 = i_52 + 1;
  if (ni_6(D) > i_23)
    goto <bb 19>;
  else
    goto <bb 20>;

  <bb 19>:
  # fail_49 = PHI <fail_19(18), 0(2)>
  # i_52 = PHI <i_23(18), 0(2)>
  if (nj_7(D) > 0)
    goto <bb 3>;
  else
    goto <bb 18>;

  <bb 20>:
  # fail_14 = PHI <fail_19(18), 0(2)>
  stderr.38_24 = stderr;
  __fprintf_chk (stderr.38_24, 1, "Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", 5.000000000000000277555756156289135105907917022705078125e-2, fail_14);
  return;

  <bb 21>:
  _36 = _18 - _13;
  _37 = (float) _36;
  if (_37 < 0.0)
    goto <bb 9>;
  else
    goto <bb 10>;

}



;; Function void gemm(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z4gemmiiiddPA4096_dS0_S0_, funcdef_no=3262, decl_uid=66774, cgraph_uid=3084)

Created preheader block for loop 2
;; 4 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5 6 11 8 9 7 10
;;
;; Loop 1
;;  header 9, latch 8
;;  depth 1, outer 0
;;  nodes: 9 8 11 7 6 5 3 4
;;
;; Loop 2
;;  header 11, latch 6
;;  depth 2, outer 1
;;  nodes: 11 6 5 3 4
;;
;; Loop 3
;;  header 5, latch 4
;;  depth 3, outer 2
;;  nodes: 5 4
;; 2 succs { 9 }
;; 3 succs { 5 }
;; 4 succs { 5 }
;; 5 succs { 4 6 }
;; 6 succs { 11 }
;; 11 succs { 3 8 }
;; 8 succs { 9 }
;; 9 succs { 7 10 }
;; 7 succs { 11 }
;; 10 succs { 1 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

i_38 -> { i_1 }
.MEM_39 -> { .MEM_5 }
.MEM_40 -> { .MEM_6 }
j_41 -> { j_2 }
k_42 -> { k_3 }
.MEM_43 -> { .MEM_4 }
i_44 -> { i_1 }
j_45 -> { j_2 }
k_46 -> { k_3 }
.MEM_47 -> { .MEM_4 }
.MEM_48 -> { .MEM_4 }
.MEM_49 -> { .MEM_5 }
.MEM_50 -> { .MEM_5 }
.MEM_51 -> { .MEM_6 }
Incremental SSA update started at block: 12
Number of blocks in CFG: 21
Number of blocks to update: 18 ( 86%)


Merging blocks 2 and 12
Merging blocks 3 and 18
Merging blocks 4 and 5
Merging blocks 6 and 11
Merging blocks 7 and 15
Merging blocks 8 and 9
Removing basic block 13
Removing basic block 14
Removing basic block 16
Removing basic block 17
Removing basic block 19
Removing basic block 20
void gemm(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int k;
  int j;
  int i;
  long unsigned int _11;
  long unsigned int _12;
  double[4096] * _13;
  double _14;
  double _16;
  double _20;
  double[4096] * _22;
  double _23;
  double _25;
  long unsigned int _26;
  long unsigned int _27;
  double[4096] * _29;
  double _30;
  double _31;
  double _32;

  <bb 2>:
  if (ni_8(D) > 0)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 3>:
  # j_45 = PHI <j_35(5), j_37(7)>
  _11 = (long unsigned int) i_44;
  _12 = _11 * 32768;
  _13 = C_10(D) + _12;
  _14 = *_13[j_45];
  _16 = _14 * beta_15(D);
  *_13[j_45] = _16;
  if (nk_18(D) > 0)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 4>:
  # k_46 = PHI <k_34(4), 0(3)>
  _20 = *_13[j_45];
  _22 = A_21(D) + _12;
  _23 = *_22[k_46];
  _25 = _23 * alpha_24(D);
  _26 = (long unsigned int) k_46;
  _27 = _26 * 32768;
  _29 = B_28(D) + _27;
  _30 = *_29[j_45];
  _31 = _25 * _30;
  _32 = _20 + _31;
  *_13[j_45] = _32;
  k_34 = k_46 + 1;
  if (nk_18(D) > k_34)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 5>:
  j_35 = j_45 + 1;
  if (nj_9(D) > j_35)
    goto <bb 3>;
  else
    goto <bb 6>;

  <bb 6>:
  i_36 = i_44 + 1;
  if (ni_8(D) > i_36)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 7>:
  # j_37 = PHI <0(6), 0(2)>
  # i_44 = PHI <i_36(6), 0(2)>
  if (nj_9(D) > j_37)
    goto <bb 3>;
  else
    goto <bb 6>;

  <bb 8>:
  return;

}



;; Function void gemm_original(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z13gemm_originaliiiddPA4096_dS0_S0_, funcdef_no=3263, decl_uid=66799, cgraph_uid=3085)

Created preheader block for loop 2
;; 4 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5 6 11 8 9 7 10
;;
;; Loop 1
;;  header 9, latch 8
;;  depth 1, outer 0
;;  nodes: 9 8 11 7 6 5 3 4
;;
;; Loop 2
;;  header 11, latch 6
;;  depth 2, outer 1
;;  nodes: 11 6 5 3 4
;;
;; Loop 3
;;  header 5, latch 4
;;  depth 3, outer 2
;;  nodes: 5 4
;; 2 succs { 9 }
;; 3 succs { 5 }
;; 4 succs { 5 }
;; 5 succs { 4 6 }
;; 6 succs { 11 }
;; 11 succs { 3 8 }
;; 8 succs { 9 }
;; 9 succs { 7 10 }
;; 7 succs { 11 }
;; 10 succs { 1 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

i_59 -> { i_19 }
j_60 -> { j_23 }
.MEM_61 -> { .MEM_48 }
.MEM_62 -> { .MEM_49 }
k_63 -> { k_28 }
.MEM_64 -> { .MEM_47 }
i_65 -> { i_19 }
j_66 -> { j_23 }
k_67 -> { k_28 }
.MEM_68 -> { .MEM_47 }
.MEM_69 -> { .MEM_47 }
.MEM_70 -> { .MEM_48 }
.MEM_71 -> { .MEM_48 }
.MEM_72 -> { .MEM_49 }
Incremental SSA update started at block: 12
Number of blocks in CFG: 21
Number of blocks to update: 18 ( 86%)


Merging blocks 2 and 12
Merging blocks 3 and 18
Merging blocks 4 and 5
Merging blocks 6 and 11
Merging blocks 7 and 15
Merging blocks 8 and 9
Removing basic block 13
Removing basic block 14
Removing basic block 16
Removing basic block 17
Removing basic block 19
Removing basic block 20
void gemm_original(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  struct timespec spec;
  int k;
  int j;
  int i;
  struct timespec spec;
  long int _13;
  long unsigned int _14;
  long unsigned int _15;
  long int _16;
  long unsigned int _17;
  uint64_t _18;
  long unsigned int _20;
  long unsigned int _21;
  double[4096] * _22;
  double _24;
  double _25;
  double _26;
  double[4096] * _27;
  double _29;
  double _30;
  long unsigned int _31;
  long unsigned int _32;
  double[4096] * _33;
  double _34;
  double _35;
  double _36;
  long int _41;
  long unsigned int _42;
  long unsigned int _43;
  long int _44;
  long unsigned int _45;
  uint64_t _46;

  <bb 2>:
  clock_gettime (1, &spec);
  _13 = spec.tv_sec;
  _14 = (long unsigned int) _13;
  _15 = _14 * 1000000000;
  _16 = spec.tv_nsec;
  _17 = (long unsigned int) _16;
  _18 = _15 + _17;
  spec ={v} {CLOBBER};
  seq_start = _18;
  if (ni_3(D) > 0)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 3>:
  # j_66 = PHI <j_38(5), j_58(7)>
  _20 = (long unsigned int) i_65;
  _21 = _20 * 32768;
  _22 = C_10(D) + _21;
  _24 = *_22[j_66];
  _25 = beta_7(D) * _24;
  *_22[j_66] = _25;
  if (nk_5(D) > 0)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 4>:
  # k_67 = PHI <k_37(4), 0(3)>
  _26 = *_22[j_66];
  _27 = A_8(D) + _21;
  _29 = *_27[k_67];
  _30 = alpha_6(D) * _29;
  _31 = (long unsigned int) k_67;
  _32 = _31 * 32768;
  _33 = B_9(D) + _32;
  _34 = *_33[j_66];
  _35 = _30 * _34;
  _36 = _26 + _35;
  *_22[j_66] = _36;
  k_37 = k_67 + 1;
  if (nk_5(D) > k_37)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 5>:
  j_38 = j_66 + 1;
  if (nj_4(D) > j_38)
    goto <bb 3>;
  else
    goto <bb 6>;

  <bb 6>:
  i_39 = i_65 + 1;
  if (ni_3(D) > i_39)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 7>:
  # j_58 = PHI <0(6), 0(2)>
  # i_65 = PHI <i_39(6), 0(2)>
  if (nj_4(D) > j_58)
    goto <bb 3>;
  else
    goto <bb 6>;

  <bb 8>:
  clock_gettime (1, &spec);
  _41 = spec.tv_sec;
  _42 = (long unsigned int) _41;
  _43 = _42 * 1000000000;
  _44 = spec.tv_nsec;
  _45 = (long unsigned int) _44;
  _46 = _43 + _45;
  spec ={v} {CLOBBER};
  seq_stop = _46;
  return;

}



;; Function void gemm_omp_kernel(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_, funcdef_no=3264, decl_uid=66809, cgraph_uid=3086)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void gemm_omp_kernel(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  struct .omp_data_s.41 .omp_data_o.42;

  <bb 2>:
  .omp_data_o.42.alpha = alpha_2(D);
  .omp_data_o.42.beta = beta_4(D);
  .omp_data_o.42.A = A_6(D);
  .omp_data_o.42.B = B_8(D);
  .omp_data_o.42.C = C_10(D);
  .omp_data_o.42.ni = ni_12(D);
  .omp_data_o.42.nj = nj_14(D);
  .omp_data_o.42.nk = nk_16(D);
  __builtin_GOMP_parallel_start (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0, &.omp_data_o.42, 8);
  _Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0 (&.omp_data_o.42);
  __builtin_GOMP_parallel_end ();
  return;

}



;; Function void gemm_omp(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z8gemm_ompiiiddPA4096_dS0_S0_, funcdef_no=3265, decl_uid=66831, cgraph_uid=3087)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void gemm_omp(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C_outputFromOMP)
{
  struct timespec spec;
  struct .omp_data_s.41 .omp_data_o.42;
  struct timespec spec;
  long int _13;
  long unsigned int _14;
  long unsigned int _15;
  long int _16;
  long unsigned int _17;
  uint64_t _18;
  long int _19;
  long unsigned int _20;
  long unsigned int _21;
  long int _22;
  long unsigned int _23;
  uint64_t _24;

  <bb 2>:
  clock_gettime (1, &spec);
  _13 = spec.tv_sec;
  _14 = (long unsigned int) _13;
  _15 = _14 * 1000000000;
  _16 = spec.tv_nsec;
  _17 = (long unsigned int) _16;
  _18 = _15 + _17;
  spec ={v} {CLOBBER};
  omp_start = _18;
  .omp_data_o.42.alpha = alpha_6(D);
  .omp_data_o.42.beta = beta_7(D);
  .omp_data_o.42.A = A_8(D);
  .omp_data_o.42.B = B_9(D);
  .omp_data_o.42.C = C_outputFromOMP_10(D);
  .omp_data_o.42.ni = ni_3(D);
  .omp_data_o.42.nj = nj_4(D);
  .omp_data_o.42.nk = nk_5(D);
  __builtin_GOMP_parallel_start (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0, &.omp_data_o.42, 8);
  _Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0 (&.omp_data_o.42);
  __builtin_GOMP_parallel_end ();
  clock_gettime (1, &spec);
  _19 = spec.tv_sec;
  _20 = (long unsigned int) _19;
  _21 = _20 * 1000000000;
  _22 = spec.tv_nsec;
  _23 = (long unsigned int) _22;
  _24 = _21 + _23;
  spec ={v} {CLOBBER};
  omp_stop = _24;
  return;

}



;; Function void GPU_argv_init() (_Z13GPU_argv_initv, funcdef_no=3266, decl_uid=66833, cgraph_uid=3088)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void GPU_argv_init() ()
{
  struct cudaDeviceProp deviceProp;
  struct _IO_FILE * stderr.43;

  <bb 2>:
  stderr.43_2 = stderr;
  __fprintf_chk (stderr.43_2, 1, "GPU init.\n");
  cudaGetDeviceProperties (&deviceProp, 0);
  stderr.43_5 = stderr;
  __fprintf_chk (stderr.43_5, 1, "setting device %d with name %s\n", 0, &deviceProp.name);
  cudaSetDevice (0);
  deviceProp ={v} {CLOBBER};
  return;

}



;; Function int main(int, char**) (main, funcdef_no=3268, decl_uid=66878, cgraph_uid=3090) (executed once)

Created preheader block for loop 4
Created preheader block for loop 5
Created preheader block for loop 6
;; 7 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5 6 7 29 9 10 8 11 12 28 14 15 13 16 17 18 19 20 21 27 23 24 22 25 26
;;
;; Loop 3
;;  header 24, latch 23
;;  depth 1, outer 0
;;  nodes: 24 23 27 22 21 19 20
;;
;; Loop 4
;;  header 27, latch 21
;;  depth 2, outer 3
;;  nodes: 27 21 19 20
;;
;; Loop 2
;;  header 15, latch 14
;;  depth 1, outer 0
;;  nodes: 15 14 28 13 12
;;
;; Loop 5
;;  header 28, latch 12
;;  depth 2, outer 2
;;  nodes: 28 12
;;
;; Loop 1
;;  header 10, latch 9
;;  depth 1, outer 0
;;  nodes: 10 9 29 8 7
;;
;; Loop 6
;;  header 29, latch 7
;;  depth 2, outer 1
;;  nodes: 29 7
;; 2 succs { 3 6 }
;; 3 succs { 4 5 }
;; 4 succs { }
;; 5 succs { 6 }
;; 6 succs { 10 }
;; 7 succs { 29 }
;; 29 succs { 7 9 }
;; 9 succs { 10 }
;; 10 succs { 8 11 }
;; 8 succs { 29 }
;; 11 succs { 15 }
;; 12 succs { 28 }
;; 28 succs { 12 14 }
;; 14 succs { 15 }
;; 15 succs { 13 16 }
;; 13 succs { 28 }
;; 16 succs { 17 26 }
;; 17 succs { 18 26 }
;; 18 succs { 24 }
;; 19 succs { 20 21 }
;; 20 succs { 21 }
;; 21 succs { 27 }
;; 27 succs { 19 23 }
;; 23 succs { 24 }
;; 24 succs { 22 25 }
;; 22 succs { 27 }
;; 25 succs { 26 }
;; 26 succs { 1 }

SSA replacement table
N_i -> { O_1 ... O_j } means that N_i replaces O_1, ..., O_j

i_72 -> { i_185 }
i_209 -> { i_147 }
.MEM_210 -> { .MEM_165 }
j_211 -> { j_152 }
.MEM_212 -> { .MEM_166 }
j_213 -> { j_161 }
j_214 -> { j_189 }
.MEM_215 -> { .MEM_167 }
i_216 -> { i_147 }
i_217 -> { i_156 }
.MEM_218 -> { .MEM_168 }
.MEM_219 -> { .MEM_202 }
.MEM_220 -> { .MEM_201 }
j_221 -> { j_152 }
i_222 -> { i_156 }
j_223 -> { j_161 }
.MEM_224 -> { .MEM_165 }
.MEM_225 -> { .MEM_165 }
.MEM_226 -> { .MEM_166 }
.MEM_227 -> { .MEM_167 }
.MEM_228 -> { .MEM_167 }
.MEM_229 -> { .MEM_168 }
i_230 -> { i_185 }
j_231 -> { j_189 }
.MEM_232 -> { .MEM_201 }
.MEM_233 -> { .MEM_201 }
.MEM_234 -> { .MEM_202 }
Incremental SSA update started at block: 42
Number of blocks in CFG: 48
Number of blocks to update: 37 ( 77%)


Merging blocks 6 and 42
Merging blocks 7 and 29
Merging blocks 8 and 45
Merging blocks 9 and 10
Merging blocks 11 and 36
Merging blocks 12 and 28
Merging blocks 13 and 39
Merging blocks 14 and 15
Merging blocks 18 and 30
Merging blocks 21 and 27
Merging blocks 22 and 33
Merging blocks 23 and 24
Removing basic block 31
Removing basic block 32
Removing basic block 34
Removing basic block 35
Removing basic block 37
Removing basic block 38
Removing basic block 40
Removing basic block 41
Removing basic block 43
Removing basic block 44
Removing basic block 46
Removing basic block 47
int main(int, char**) (int argc, char * * argv)
{
  struct _IO_FILE * stderr.67;
  int i;
  int j;
  int i;
  int j;
  int i;
  int j;
  void * ret;
  void * ret;
  void * ret;
  void * ret;
  void * ret;
  static const char __PRETTY_FUNCTION__[22] = "int main(int, char**)";
  struct Func * ff_0;
  double[4096][4096] * C_outputFromGpu;
  double[4096][4096] * C_inputToGpu;
  double[4096][4096] * C_outputFromOMP;
  double[4096][4096] * C;
  double[4096][4096] * B;
  double[4096][4096] * A;
  double beta;
  double alpha;
  int nk;
  int nj;
  int ni;
  struct _IO_FILE * stdout.66;
  double alpha.65;
  double beta.64;
  double[4096][4096] * C_outputFromGpu.63;
  int ni.62;
  int nj.61;
  int nk.60;
  double[4096][4096] * A.59;
  double[4096][4096] * B.58;
  double[4096][4096] * C.57;
  struct Func * * * table.55;
  struct _IO_FILE * stderr.53;
  void * _23;
  void * _26;
  void * * _29;
  void * * _33;
  struct ffi_type * * _45;
  bool _60;
  struct Func * * _67;
  struct Func * _68;
  char * _116;
  unsigned char _117;
  long unsigned int _148;
  long unsigned int _149;
  double[4096] * _150;
  double[4096] * _151;
  double _153;
  long unsigned int _157;
  long unsigned int _158;
  double[4096] * _159;
  double[4096] * _160;
  double _162;
  long unsigned int _186;
  long unsigned int _187;
  double[4096] * _188;
  double _190;
  int _192;
  int _193;
  int _194;

  <bb 2>:
  ni = 4096;
  nj = 4096;
  nk = 4096;
  ret_141 = xmalloc (134217728);
  A = ret_141;
  ret_142 = xmalloc (134217728);
  B = ret_142;
  ret_143 = xmalloc (134217728);
  C = ret_143;
  C_outputFromOMP_144 = xmalloc (134217728);
  ret_145 = xmalloc (134217728);
  C_inputToGpu = ret_145;
  ret_146 = xmalloc (134217728);
  C_outputFromGpu = ret_146;
  stderr.53_18 = stderr;
  __fprintf_chk (stderr.53_18, 1, "Preparing alternatives functions.\n");
  ff_0_21 = malloc (48);
  _23 = malloc (88);
  ff_0_21->arg_types = _23;
  _26 = malloc (88);
  ff_0_21->arg_values = _26;
  ff_0_21->f = gemm_cuda;
  _29 = &ff_0_21->ret_value;
  memset (_29, 0, 8);
  ff_0_21->ret_type = &ffi_type_void;
  ff_0_21->nargs = 10;
  _33 = ff_0_21->arg_values;
  *_33 = &ni;
  MEM[(void * *)_33 + 8B] = &nj;
  MEM[(void * *)_33 + 16B] = &nk;
  MEM[(void * *)_33 + 24B] = &alpha;
  MEM[(void * *)_33 + 32B] = &beta;
  MEM[(void * *)_33 + 40B] = &A;
  MEM[(void * *)_33 + 48B] = &B;
  MEM[(void * *)_33 + 56B] = &C;
  MEM[(void * *)_33 + 64B] = &C_inputToGpu;
  MEM[(void * *)_33 + 72B] = &C_outputFromGpu;
  MEM[(void * *)_33 + 80B] = 0B;
  _45 = ff_0_21->arg_types;
  *_45 = &ffi_type_sint32;
  MEM[(struct ffi_type * *)_45 + 8B] = &ffi_type_sint32;
  MEM[(struct ffi_type * *)_45 + 16B] = &ffi_type_sint32;
  MEM[(struct ffi_type * *)_45 + 24B] = &ffi_type_double;
  MEM[(struct ffi_type * *)_45 + 32B] = &ffi_type_double;
  MEM[(struct ffi_type * *)_45 + 40B] = &ffi_type_pointer;
  MEM[(struct ffi_type * *)_45 + 48B] = &ffi_type_pointer;
  MEM[(struct ffi_type * *)_45 + 56B] = &ffi_type_pointer;
  MEM[(struct ffi_type * *)_45 + 64B] = &ffi_type_pointer;
  MEM[(struct ffi_type * *)_45 + 72B] = &ffi_type_pointer;
  MEM[(struct ffi_type * *)_45 + 80B] = 0B;
  stderr.53_57 = stderr;
  __fprintf_chk (stderr.53_57, 1, "Creating table of target functions.\n");
  _60 = create_target_functions_table (&table, 1, 2);
  if (_60 != 0)
    goto <bb 3>;
  else
    goto <bb 6>;

  <bb 3>:
  table.55_62 = table;
  if (table.55_62 == 0B)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 4>:
  __assert_fail ("table != NULL", "gemm.cu", 402, &__PRETTY_FUNCTION__);

  <bb 5>:
  stderr.53_64 = stderr;
  __fprintf_chk (stderr.53_64, 1, "Declaring function in 0,1.\n");
  table.55_66 = table;
  _67 = *table.55_66;
  _68 = MEM[(struct Func * *)_67 + 8B];
  *_68 = MEM[(const struct Func &)ff_0_21];
  TablePointerFunctions = table.55_66;

  <bb 6>:
  stderr.53_73 = stderr;
  __fprintf_chk (stderr.53_73, 1, "Calling init_array.\n");
  C.57_75 = C;
  B.58_76 = B;
  A.59_77 = A;
  nk.60_78 = nk;
  nj.61_79 = nj;
  ni.62_80 = ni;
  init_array (ni.62_80, nj.61_79, nk.60_78, &alpha, &beta, A.59_77, B.58_76, C.57_75);
  C.57_82 = C;
  nj.61_83 = nj;
  ni.62_84 = ni;
  if (ni.62_84 > 0)
    goto <bb 9>;
  else
    goto <bb 10>;

  <bb 7>:
  # j_221 = PHI <j_154(7), j_61(9)>
  _148 = (long unsigned int) i_209;
  _149 = _148 * 32768;
  _150 = C_outputFromOMP_144 + _149;
  _151 = C.57_82 + _149;
  _153 = *_151[j_221];
  *_150[j_221] = _153;
  j_154 = j_221 + 1;
  if (nj.61_83 > j_154)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 8>:
  i_155 = i_209 + 1;
  if (ni.62_84 > i_155)
    goto <bb 9>;
  else
    goto <bb 10>;

  <bb 9>:
  # j_61 = PHI <0(8), 0(6)>
  # i_209 = PHI <i_155(8), 0(6)>
  if (j_61 < nj.61_83)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 10>:
  C_outputFromGpu.63_86 = C_outputFromGpu;
  if (ni.62_84 > 0)
    goto <bb 13>;
  else
    goto <bb 14>;

  <bb 11>:
  # j_223 = PHI <j_163(11), j_208(13)>
  _157 = (long unsigned int) i_222;
  _158 = _157 * 32768;
  _159 = C_outputFromGpu.63_86 + _158;
  _160 = C.57_82 + _158;
  _162 = *_160[j_223];
  *_159[j_223] = _162;
  j_163 = j_223 + 1;
  if (nj.61_83 > j_163)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 12>:
  i_164 = i_222 + 1;
  if (ni.62_84 > i_164)
    goto <bb 13>;
  else
    goto <bb 14>;

  <bb 13>:
  # j_208 = PHI <0(12), 0(10)>
  # i_222 = PHI <i_164(12), 0(10)>
  if (nj.61_83 > j_208)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 14>:
  stderr.53_88 = stderr;
  __fprintf_chk (stderr.53_88, 1, "Calling gemm_omp:\n");
  B.58_90 = B;
  A.59_91 = A;
  beta.64_92 = beta;
  alpha.65_93 = alpha;
  nk.60_94 = nk;
  nj.61_95 = nj;
  ni.62_96 = ni;
  gemm_omp (ni.62_96, nj.61_95, nk.60_94, alpha.65_93, beta.64_92, A.59_91, B.58_90, C_outputFromOMP_144);
  stdout.66_98 = stdout;
  __fprintf_chk (stdout.66_98, 1, "version = OMP+OFF, num_threads = %d, NI = %d, NJ = %d, NK = %d, ", 8, 4096, 4096, 4096);
  hookomp_print_time_results ();
  stderr.53_101 = stderr;
  __fprintf_chk (stderr.53_101, 1, "Calling compareResults(original, omp).\n");
  C.57_103 = C;
  nj.61_104 = nj;
  ni.62_105 = ni;
  compareResults (ni.62_105, nj.61_104, C.57_103, C_outputFromOMP_144);
  stderr.53_107 = stderr;
  __fprintf_chk (stderr.53_107, 1, "Calling compareResults(original, cuda).\n");
  C_outputFromGpu.63_109 = C_outputFromGpu;
  C.57_110 = C;
  nj.61_111 = nj;
  ni.62_112 = ni;
  compareResults (ni.62_112, nj.61_111, C.57_110, C_outputFromGpu.63_109);
  if (argc_114(D) > 42)
    goto <bb 15>;
  else
    goto <bb 23>;

  <bb 15>:
  _116 = *argv_115(D);
  _117 = MEM[(const unsigned char * {ref-all})_116];
  if (_117 == 0)
    goto <bb 16>;
  else
    goto <bb 23>;

  <bb 16>:
  C_outputFromGpu.63_118 = C_outputFromGpu;
  nj.61_119 = nj;
  ni.62_120 = ni;
  if (ni.62_120 > 0)
    goto <bb 21>;
  else
    goto <bb 22>;

  <bb 17>:
  # j_231 = PHI <j_196(19), j_70(21)>
  _186 = (long unsigned int) i_230;
  _187 = _186 * 32768;
  _188 = C_outputFromGpu.63_118 + _187;
  _190 = *_188[j_231];
  stderr.67_191 = stderr;
  __fprintf_chk (stderr.67_191, 1, "%0.2lf ", _190);
  _192 = ni.62_120 * i_230;
  _193 = j_231 + _192;
  _194 = _193 % 20;
  if (_194 == 0)
    goto <bb 18>;
  else
    goto <bb 19>;

  <bb 18>:
  stderr.67_195 = stderr;
  __builtin_fputs ("\n", stderr.67_195);

  <bb 19>:
  j_196 = j_231 + 1;
  if (nj.61_119 > j_196)
    goto <bb 17>;
  else
    goto <bb 20>;

  <bb 20>:
  i_197 = i_230 + 1;
  if (ni.62_120 > i_197)
    goto <bb 21>;
  else
    goto <bb 22>;

  <bb 21>:
  # j_70 = PHI <0(20), 0(16)>
  # i_230 = PHI <i_197(20), 0(16)>
  if (j_70 < nj.61_119)
    goto <bb 17>;
  else
    goto <bb 20>;

  <bb 22>:
  stderr.67_198 = stderr;
  __builtin_fputs ("\n", stderr.67_198);

  <bb 23>:
  A.59_122 = A;
  free (A.59_122);
  B.58_124 = B;
  free (B.58_124);
  C.57_126 = C;
  free (C.57_126);
  free (C_outputFromOMP_144);
  C_outputFromGpu.63_129 = C_outputFromGpu;
  free (C_outputFromGpu.63_129);
  ni ={v} {CLOBBER};
  nj ={v} {CLOBBER};
  nk ={v} {CLOBBER};
  alpha ={v} {CLOBBER};
  beta ={v} {CLOBBER};
  A ={v} {CLOBBER};
  B ={v} {CLOBBER};
  C ={v} {CLOBBER};
  C_inputToGpu ={v} {CLOBBER};
  C_outputFromGpu ={v} {CLOBBER};
  return 0;

}



;; Function void polybench_flush_cache() (_Z21polybench_flush_cachev, funcdef_no=3270, decl_uid=67114, cgraph_uid=3092)

;; 2 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 9 3 4 5 6 7 8
;;
;; Loop 1
;;  header 3, latch 9
;;  depth 1, outer 0
;;  nodes: 3 9 4
;; 2 succs { 8 }
;; 9 succs { 3 }
;; 3 succs { 4 }
;; 4 succs { 9 5 }
;; 5 succs { 7 6 }
;; 6 succs { }
;; 7 succs { 1 }
;; 8 succs { 3 }
Merging blocks 2 and 8
Merging blocks 3 and 4
Removing basic block 9
void polybench_flush_cache() ()
{
  static const char __PRETTY_FUNCTION__[29] = "void polybench_flush_cache()";
  double tmp;
  int i;
  double * flush;
  long unsigned int _6;
  long unsigned int _7;
  double * _8;
  double _9;

  <bb 2>:
  flush_5 = calloc (4194560, 8);

  <bb 3>:
  # i_17 = PHI <i_11(3), 0(2)>
  # tmp_18 = PHI <tmp_10(3), 0.0(2)>
  _6 = (long unsigned int) i_17;
  _7 = _6 * 8;
  _8 = flush_5 + _7;
  _9 = *_8;
  tmp_10 = _9 + tmp_18;
  i_11 = i_17 + 1;
  if (i_11 != 4194560)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 4>:
  # tmp_14 = PHI <tmp_10(3)>
  if (tmp_14 <= 1.0e+1)
    goto <bb 6>;
  else
    goto <bb 5>;

  <bb 5>:
  __assert_fail ("tmp <= 10.0", "../../../utilities/polybench.c", 96, &__PRETTY_FUNCTION__);

  <bb 6>:
  free (flush_5);
  return;

}



;; Function void polybench_prepare_instruments() (_Z29polybench_prepare_instrumentsv, funcdef_no=3271, decl_uid=67125, cgraph_uid=3093)

;; 2 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 9 3 4 5 6 7 8
;;
;; Loop 1
;;  header 3, latch 9
;;  depth 1, outer 0
;;  nodes: 3 9 4
;; 2 succs { 8 }
;; 9 succs { 3 }
;; 3 succs { 4 }
;; 4 succs { 9 5 }
;; 5 succs { 7 6 }
;; 6 succs { }
;; 7 succs { 1 }
;; 8 succs { 3 }
Merging blocks 2 and 8
Merging blocks 3 and 4
Removing basic block 9
void polybench_prepare_instruments() ()
{
  double tmp;
  int i;
  double * flush;
  long unsigned int _5;
  long unsigned int _6;
  double * _7;
  double _8;

  <bb 2>:
  flush_3 = calloc (4194560, 8);

  <bb 3>:
  # i_18 = PHI <i_11(3), 0(2)>
  # tmp_19 = PHI <tmp_10(3), 0.0(2)>
  _5 = (long unsigned int) i_18;
  _6 = _5 * 8;
  _7 = flush_3 + _6;
  _8 = *_7;
  tmp_10 = _8 + tmp_19;
  i_11 = i_18 + 1;
  if (i_11 != 4194560)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 4>:
  # tmp_15 = PHI <tmp_10(3)>
  if (tmp_15 <= 1.0e+1)
    goto <bb 6>;
  else
    goto <bb 5>;

  <bb 5>:
  __assert_fail ("tmp <= 10.0", "../../../utilities/polybench.c", 96, &__PRETTY_FUNCTION__);

  <bb 6>:
  free (flush_3);
  return;

}



;; Function void polybench_timer_start() (_Z21polybench_timer_startv, funcdef_no=3272, decl_uid=65913, cgraph_uid=3094)

;; 2 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 11 3 4 5 6 7 8 9 10
;;
;; Loop 1
;;  header 3, latch 11
;;  depth 1, outer 0
;;  nodes: 3 11 4
;; 2 succs { 10 }
;; 11 succs { 3 }
;; 3 succs { 4 }
;; 4 succs { 11 5 }
;; 5 succs { 7 6 }
;; 6 succs { }
;; 7 succs { 8 9 }
;; 8 succs { 9 }
;; 9 succs { 1 }
;; 10 succs { 3 }
Merging blocks 2 and 10
Merging blocks 3 and 4
Removing basic block 11
void polybench_timer_start() ()
{
  struct timeval Tp;
  int stat;
  double D.68982;
  double tmp;
  int i;
  double * flush;
  long unsigned int _9;
  long unsigned int _10;
  double * _11;
  double _12;
  long int _17;
  double _18;
  long int _19;
  double _20;
  double _21;
  double _22;

  <bb 2>:
  flush_7 = calloc (4194560, 8);

  <bb 3>:
  # i_32 = PHI <i_15(3), 0(2)>
  # tmp_33 = PHI <tmp_14(3), 0.0(2)>
  _9 = (long unsigned int) i_32;
  _10 = _9 * 8;
  _11 = flush_7 + _10;
  _12 = *_11;
  tmp_14 = _12 + tmp_33;
  i_15 = i_32 + 1;
  if (i_15 != 4194560)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 4>:
  # tmp_30 = PHI <tmp_14(3)>
  if (tmp_30 <= 1.0e+1)
    goto <bb 6>;
  else
    goto <bb 5>;

  <bb 5>:
  __assert_fail ("tmp <= 10.0", "../../../utilities/polybench.c", 96, &__PRETTY_FUNCTION__);

  <bb 6>:
  free (flush_7);
  stat_16 = gettimeofday (&Tp, 0B);
  if (stat_16 != 0)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 7>:
  __printf_chk (1, "Error return from gettimeofday: %d", stat_16);

  <bb 8>:
  _17 = Tp.tv_sec;
  _18 = (double) _17;
  _19 = Tp.tv_usec;
  _20 = (double) _19;
  _21 = _20 * 9.99999999999999954748111825886258685613938723690807819366e-7;
  _22 = _18 + _21;
  Tp ={v} {CLOBBER};
  polybench_t_start = _22;
  return;

}



;; Function void polybench_timer_stop() (_Z20polybench_timer_stopv, funcdef_no=3273, decl_uid=65914, cgraph_uid=3095)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4
;; 2 succs { 3 4 }
;; 3 succs { 4 }
;; 4 succs { 1 }
void polybench_timer_stop() ()
{
  struct timeval Tp;
  int stat;
  double D.69000;
  long int _6;
  double _7;
  long int _8;
  double _9;
  double _10;
  double _11;

  <bb 2>:
  stat_5 = gettimeofday (&Tp, 0B);
  if (stat_5 != 0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  __printf_chk (1, "Error return from gettimeofday: %d", stat_5);

  <bb 4>:
  _6 = Tp.tv_sec;
  _7 = (double) _6;
  _8 = Tp.tv_usec;
  _9 = (double) _8;
  _10 = _9 * 9.99999999999999954748111825886258685613938723690807819366e-7;
  _11 = _7 + _10;
  Tp ={v} {CLOBBER};
  polybench_t_end = _11;
  return;

}



;; Function void polybench_timer_print() (_Z21polybench_timer_printv, funcdef_no=3274, decl_uid=65915, cgraph_uid=3096)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void polybench_timer_print() ()
{
  double polybench_t_start.71;
  double polybench_t_end.70;
  double _4;

  <bb 2>:
  polybench_t_end.70_2 = polybench_t_end;
  polybench_t_start.71_3 = polybench_t_start;
  _4 = polybench_t_end.70_2 - polybench_t_start.71_3;
  __printf_chk (1, "%0.6f\n", _4);
  return;

}



;; Function void* polybench_alloc_data(long long unsigned int, int) (_Z20polybench_alloc_datayi, funcdef_no=3276, decl_uid=65921, cgraph_uid=3098)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5
;; 2 succs { 4 3 }
;; 3 succs { 4 5 }
;; 4 succs { }
;; 5 succs { 1 }
void* polybench_alloc_data(long long unsigned int, int) (long long unsigned int n, int elt_size)
{
  int ret;
  void * newA;
  struct _IO_FILE * stderr.73;
  void * newA.72;
  void * D.69012;
  void * ret;
  size_t val;
  long unsigned int _3;

  <bb 2>:
  _3 = (long unsigned int) elt_size_2(D);
  val_4 = n_1(D) * _3;
  newA = 0B;
  ret_8 = posix_memalign (&newA, 32, val_4);
  newA.72_9 = newA;
  if (newA.72_9 == 0B)
    goto <bb 4>;
  else
    goto <bb 3>;

  <bb 3>:
  if (ret_8 != 0)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 4>:
  stderr.73_10 = stderr;
  __builtin_fwrite ("[PolyBench] posix_memalign: cannot allocate memory", 1, 50, stderr.73_10);
  exit (1);

  <bb 5>:
  newA ={v} {CLOBBER};
  return newA.72_9;

}



;; Function void __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_(int, int, int, double, double, double*, double*, double*) (_Z45__device_stub__Z16gemm_cuda_kerneliiiddPdS_S_iiiddPdS_S_, funcdef_no=3301, decl_uid=67447, cgraph_uid=3122)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4 5 6 7 8 9 10 11
;; 2 succs { 11 3 }
;; 3 succs { 11 4 }
;; 4 succs { 11 5 }
;; 5 succs { 11 6 }
;; 6 succs { 11 7 }
;; 7 succs { 11 8 }
;; 8 succs { 11 9 }
;; 9 succs { 11 10 }
;; 10 succs { 11 }
;; 11 succs { 1 }
void __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_(int, int, int, double, double, double*, double*, double*) (int __par0, int __par1, int __par2, double __par3, double __par4, double * __par5, double * __par6, double * __par7)
{
  static volatile char * __f;
  cudaError _4;
  cudaError _6;
  cudaError _8;
  cudaError _10;
  cudaError _12;
  cudaError _14;
  cudaError _16;
  cudaError _18;

  <bb 2>:
  _4 = cudaSetupArgument (&__par0, 4, 0);
  if (_4 != 0)
    goto <bb 11>;
  else
    goto <bb 3>;

  <bb 3>:
  _6 = cudaSetupArgument (&__par1, 4, 4);
  if (_6 != 0)
    goto <bb 11>;
  else
    goto <bb 4>;

  <bb 4>:
  _8 = cudaSetupArgument (&__par2, 4, 8);
  if (_8 != 0)
    goto <bb 11>;
  else
    goto <bb 5>;

  <bb 5>:
  _10 = cudaSetupArgument (&__par3, 8, 16);
  if (_10 != 0)
    goto <bb 11>;
  else
    goto <bb 6>;

  <bb 6>:
  _12 = cudaSetupArgument (&__par4, 8, 24);
  if (_12 != 0)
    goto <bb 11>;
  else
    goto <bb 7>;

  <bb 7>:
  _14 = cudaSetupArgument (&__par5, 8, 32);
  if (_14 != 0)
    goto <bb 11>;
  else
    goto <bb 8>;

  <bb 8>:
  _16 = cudaSetupArgument (&__par6, 8, 40);
  if (_16 != 0)
    goto <bb 11>;
  else
    goto <bb 9>;

  <bb 9>:
  _18 = cudaSetupArgument (&__par7, 8, 48);
  if (_18 != 0)
    goto <bb 11>;
  else
    goto <bb 10>;

  <bb 10>:
  __f = gemm_cuda_kernel;
  cudaLaunch (gemm_cuda_kernel);

  <bb 11>:
  return;

}



;; Function void gemm_cuda(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096]) (_Z9gemm_cudaiiiddPA4096_dS0_S0_S0_S0_, funcdef_no=3267, decl_uid=66855, cgraph_uid=3089)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2 3 4
;; 2 succs { 3 4 }
;; 3 succs { 4 }
;; 4 succs { 1 }
void gemm_cuda(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C, double[4096] * C_inputToGpu, double[4096] * C_outputFromGpu)
{
  struct timespec spec;
  struct timespec spec;
  struct timespec spec;
  struct timespec spec;
  struct timespec spec;
  struct timespec spec;
  struct dim3 grid;
  struct dim3 block;
  double * C_gpu;
  double * B_gpu;
  double * A_gpu;
  double * C_gpu.47;
  double * B_gpu.46;
  double * A_gpu.45;
  struct _IO_FILE * stderr.44;
  cudaError _29;
  long int _66;
  long unsigned int _67;
  long unsigned int _68;
  long int _69;
  long unsigned int _70;
  uint64_t _71;
  long int _72;
  long unsigned int _73;
  long unsigned int _74;
  long int _75;
  long unsigned int _76;
  uint64_t _77;
  long int _78;
  long unsigned int _79;
  long unsigned int _80;
  long int _81;
  long unsigned int _82;
  uint64_t _83;
  long int _84;
  long unsigned int _85;
  long unsigned int _86;
  long int _87;
  long unsigned int _88;
  uint64_t _89;
  long int _90;
  long unsigned int _91;
  long unsigned int _92;
  long int _93;
  long unsigned int _94;
  uint64_t _95;
  long int _96;
  long unsigned int _97;
  long unsigned int _98;
  long int _99;
  long unsigned int _100;
  uint64_t _101;

  <bb 2>:
  stderr.44_3 = stderr;
  __fprintf_chk (stderr.44_3, 1, "Calling function gemm_cuda.\n");
  GPU_argv_init ();
  cudaMalloc (&A_gpu, 134217728);
  cudaMalloc (&B_gpu, 134217728);
  cudaMalloc (&C_gpu, 134217728);
  clock_gettime (1, &spec);
  _66 = spec.tv_sec;
  _67 = (long unsigned int) _66;
  _68 = _67 * 1000000000;
  _69 = spec.tv_nsec;
  _70 = (long unsigned int) _69;
  _71 = _68 + _70;
  spec ={v} {CLOBBER};
  data_transfer_h2d_start = _71;
  A_gpu.45_10 = A_gpu;
  cudaMemcpy (A_gpu.45_10, A_11(D), 134217728, 1);
  B_gpu.46_13 = B_gpu;
  cudaMemcpy (B_gpu.46_13, B_14(D), 134217728, 1);
  C_gpu.47_17 = C_gpu;
  cudaMemcpy (C_gpu.47_17, C_inputToGpu_18(D), 134217728, 1);
  clock_gettime (1, &spec);
  _72 = spec.tv_sec;
  _73 = (long unsigned int) _72;
  _74 = _73 * 1000000000;
  _75 = spec.tv_nsec;
  _76 = (long unsigned int) _75;
  _77 = _74 + _76;
  spec ={v} {CLOBBER};
  data_transfer_h2d_stop = _77;
  block.z = 1;
  grid.x = 128;
  grid.y = 512;
  grid.z = 1;
  clock_gettime (1, &spec);
  _78 = spec.tv_sec;
  _79 = (long unsigned int) _78;
  _80 = _79 * 1000000000;
  _81 = spec.tv_nsec;
  _82 = (long unsigned int) _81;
  _83 = _80 + _82;
  spec ={v} {CLOBBER};
  dev_kernel1_start = _83;
  MEM[(struct dim3 *)&block] = 32;
  MEM[(struct dim3 *)&block + 4B] = 8;
  _29 = cudaConfigureCall (grid, block, 0, 0B);
  if (_29 == 0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  C_gpu.47_30 = C_gpu;
  B_gpu.46_31 = B_gpu;
  A_gpu.45_32 = A_gpu;
  __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_ (ni_33(D), nj_34(D), nk_35(D), alpha_36(D), beta_37(D), A_gpu.45_32, B_gpu.46_31, C_gpu.47_30);

  <bb 4>:
  cudaThreadSynchronize ();
  clock_gettime (1, &spec);
  _84 = spec.tv_sec;
  _85 = (long unsigned int) _84;
  _86 = _85 * 1000000000;
  _87 = spec.tv_nsec;
  _88 = (long unsigned int) _87;
  _89 = _86 + _88;
  spec ={v} {CLOBBER};
  dev_kernel1_stop = _89;
  clock_gettime (1, &spec);
  _90 = spec.tv_sec;
  _91 = (long unsigned int) _90;
  _92 = _91 * 1000000000;
  _93 = spec.tv_nsec;
  _94 = (long unsigned int) _93;
  _95 = _92 + _94;
  spec ={v} {CLOBBER};
  data_transfer_d2h_start = _95;
  C_gpu.47_43 = C_gpu;
  cudaMemcpy (C_outputFromGpu_44(D), C_gpu.47_43, 134217728, 2);
  clock_gettime (1, &spec);
  _96 = spec.tv_sec;
  _97 = (long unsigned int) _96;
  _98 = _97 * 1000000000;
  _99 = spec.tv_nsec;
  _100 = (long unsigned int) _99;
  _101 = _98 + _100;
  spec ={v} {CLOBBER};
  data_transfer_d2h_stop = _101;
  A_gpu.45_47 = A_gpu;
  cudaFree (A_gpu.45_47);
  B_gpu.46_49 = B_gpu;
  cudaFree (B_gpu.46_49);
  C_gpu.47_51 = C_gpu;
  cudaFree (C_gpu.47_51);
  A_gpu ={v} {CLOBBER};
  B_gpu ={v} {CLOBBER};
  C_gpu ={v} {CLOBBER};
  block ={v} {CLOBBER};
  grid ={v} {CLOBBER};
  return;

}



;; Function void __sti____cudaRegisterAll_39_tmpxft_00003394_00000000_7_gemm_cpp1_ii_132e4611() (_ZL76__sti____cudaRegisterAll_39_tmpxft_00003394_00000000_7_gemm_cpp1_ii_132e4611v, funcdef_no=3304, decl_uid=67450, cgraph_uid=3125) (executed once)

;; 1 loops found
;;
;; Loop 0
;;  header 0, latch 1
;;  depth 0, outer -1
;;  nodes: 0 1 2
;; 2 succs { 1 }
void __sti____cudaRegisterAll_39_tmpxft_00003394_00000000_7_gemm_cpp1_ii_132e4611() ()
{
  static volatile void * * __ref;
  void * * _3;

  <bb 2>:
  _3 = __cudaRegisterFatBinary (&__fatDeviceText);
  __cudaFatCubinHandle = _3;
  __ref = _3;
  __nv_fatbinhandle_for_managed_rt = _3;
  __cudaRegisterFunction (_3, gemm_cuda_kernel, "_Z16gemm_cuda_kerneliiiddPdS_S_", "_Z16gemm_cuda_kerneliiiddPdS_S_", -1, 0B, 0B, 0B, 0B, 0B);
  atexit (__cudaUnregisterBinaryUtil);
  return;

}


