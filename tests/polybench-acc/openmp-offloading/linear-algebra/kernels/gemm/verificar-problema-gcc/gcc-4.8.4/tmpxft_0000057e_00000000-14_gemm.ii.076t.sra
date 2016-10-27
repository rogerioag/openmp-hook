
;; Function void* xmalloc(size_t) (_ZL7xmallocm, funcdef_no=3225, decl_uid=66490, cgraph_uid=3047)

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
  __builtin_fwrite ("[PolyBench] posix_memalign: cannot allocate memory", 1, 50, stderr.73_8);
  exit (1);

  <bb 5>:
  newA ={v} {CLOBBER};
  return newA.72_6;

}



;; Function void __cudaUnregisterBinaryUtil() (_ZL26__cudaUnregisterBinaryUtilv, funcdef_no=3229, decl_uid=66570, cgraph_uid=3050)

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



;; Function <built-in> (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0, funcdef_no=3256, decl_uid=67054, cgraph_uid=3087)

<built-in> (struct .omp_data_s.41 * .omp_data_i)
{
  int k;
  int j;
  long int .iend0.113;
  int i;
  long int .istart0.112;
  long int .iend0.111;
  long int .istart0.110;
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
  _19 = __builtin_GOMP_loop_dynamic_start (0, _17, 1, 64, &.istart0.110, &.iend0.111);
  if (_19 != 0)
    goto <bb 3>;
  else
    goto <bb 11>;

  <bb 3>:

  <bb 4>:
  .istart0.112_20 = .istart0.110;
  i_21 = (int) .istart0.112_20;
  .iend0.113_22 = .iend0.111;
  _23 = (int) .iend0.113_22;

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
  _27 = __builtin_GOMP_loop_dynamic_next (&.istart0.110, &.iend0.111);
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



;; Function void gemm_cuda_kernel(int, int, int, double, double, double*, double*, double*) (_Z16gemm_cuda_kerneliiiddPdS_S_, funcdef_no=3252, decl_uid=66200, cgraph_uid=3073)

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



;; Function float absVal(float) (_Z6absValf, funcdef_no=3194, decl_uid=65338, cgraph_uid=3016)

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



;; Function float percentDiff(double, double) (_Z11percentDiffdd, funcdef_no=3195, decl_uid=65342, cgraph_uid=3017)

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



;; Function uint64_t get_time() (_Z8get_timev, funcdef_no=3200, decl_uid=65516, cgraph_uid=3022)

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



;; Function void hookomp_timing_start(uint64_t*) (_Z20hookomp_timing_startPm, funcdef_no=3201, decl_uid=65520, cgraph_uid=3023)

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



;; Function void hookomp_timing_stop(uint64_t*) (_Z19hookomp_timing_stopPm, funcdef_no=3202, decl_uid=65523, cgraph_uid=3024)

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



;; Function void hookomp_timing_print(uint64_t, uint64_t) (_Z20hookomp_timing_printmm, funcdef_no=3203, decl_uid=65527, cgraph_uid=3025)

void hookomp_timing_print(uint64_t, uint64_t) (uint64_t tstart, uint64_t tstop)
{
  long unsigned int _3;

  <bb 2>:
  _3 = tstop_1(D) - tstart_2(D);
  printf ("%llu", _3);
  return;

}



;; Function void hookomp_timing_print_without_dev() (_Z32hookomp_timing_print_without_devv, funcdef_no=3204, decl_uid=65529, cgraph_uid=3026)

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
  printf ("%llu", iftmp.14_1);
  return;

}



;; Function void hookomp_print_time_results() (_Z26hookomp_print_time_resultsv, funcdef_no=3205, decl_uid=65534, cgraph_uid=3027)

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
  long unsigned int _91;
  long unsigned int _94;
  long unsigned int _95;
  long unsigned int _98;
  long unsigned int _102;
  long unsigned int _105;
  long unsigned int _107;
  bool _111;
  int _112;

  <bb 2>:
  stdout.15_3 = stdout;
  __builtin_fwrite ("ORIG = ", 1, 7, stdout.15_3);
  seq_stop.16_5 = seq_stop;
  seq_start.17_6 = seq_start;
  _72 = seq_stop.16_5 - seq_start.17_6;
  printf ("%llu", _72);
  stdout.15_8 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15_8);
  stdout.15_10 = stdout;
  __builtin_fwrite ("OMP_OFF = ", 1, 10, stdout.15_10);
  omp_stop.18_12 = omp_stop;
  omp_start.19_13 = omp_start;
  _73 = omp_stop.18_12 - omp_start.19_13;
  printf ("%llu", _73);
  stdout.15_15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15_15);
  stdout.15_17 = stdout;
  __builtin_fwrite ("OMP = ", 1, 6, stdout.15_17);
  omp_stop.2_86 = omp_stop;
  omp_start.3_87 = omp_start;
  total_time_88 = omp_stop.2_86 - omp_start.3_87;
  dev_kernel1_stop.4_89 = dev_kernel1_stop;
  dev_kernel1_start.5_90 = dev_kernel1_start;
  _91 = dev_kernel1_stop.4_89 - dev_kernel1_start.5_90;
  dev_kernel2_stop.6_92 = dev_kernel2_stop;
  dev_kernel2_start.7_93 = dev_kernel2_start;
  _94 = dev_kernel2_stop.6_92 - dev_kernel2_start.7_93;
  _95 = _91 + _94;
  dev_kernel3_stop.8_96 = dev_kernel3_stop;
  dev_kernel3_start.9_97 = dev_kernel3_start;
  _98 = dev_kernel3_stop.8_96 - dev_kernel3_start.9_97;
  dev_time_99 = _95 + _98;
  data_transfer_h2d_stop.10_100 = data_transfer_h2d_stop;
  data_transfer_h2d_start.11_101 = data_transfer_h2d_start;
  _102 = data_transfer_h2d_stop.10_100 - data_transfer_h2d_start.11_101;
  data_transfer_d2h_stop.12_103 = data_transfer_d2h_stop;
  data_transfer_d2h_start.13_104 = data_transfer_d2h_start;
  _105 = data_transfer_d2h_stop.12_103 - data_transfer_d2h_start.13_104;
  dt_time_106 = _102 + _105;
  if (total_time_88 != 0)
    goto <bb 3>;
  else
    goto <bb 4>;

  <bb 3>:
  _107 = total_time_88 - dev_time_99;
  iftmp.14_108 = _107 - dt_time_106;

  <bb 4>:
  # iftmp.14_109 = PHI <0(2), iftmp.14_108(3)>
  printf ("%llu", iftmp.14_109);
  stdout.15_20 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15_20);
  stdout.15_22 = stdout;
  __builtin_fwrite ("CUDA_KERNEL1 = ", 1, 15, stdout.15_22);
  dev_kernel1_stop.20_24 = dev_kernel1_stop;
  dev_kernel1_start.21_25 = dev_kernel1_start;
  _74 = dev_kernel1_stop.20_24 - dev_kernel1_start.21_25;
  printf ("%llu", _74);
  stdout.15_27 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15_27);
  stdout.15_29 = stdout;
  __builtin_fwrite ("CUDA_KERNEL2 = ", 1, 15, stdout.15_29);
  dev_kernel2_stop.22_31 = dev_kernel2_stop;
  dev_kernel2_start.23_32 = dev_kernel2_start;
  _75 = dev_kernel2_stop.22_31 - dev_kernel2_start.23_32;
  printf ("%llu", _75);
  stdout.15_34 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15_34);
  stdout.15_36 = stdout;
  __builtin_fwrite ("CUDA_KERNEL3 = ", 1, 15, stdout.15_36);
  dev_kernel3_stop.24_38 = dev_kernel3_stop;
  dev_kernel3_start.25_39 = dev_kernel3_start;
  _76 = dev_kernel3_stop.24_38 - dev_kernel3_start.25_39;
  printf ("%llu", _76);
  stdout.15_41 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15_41);
  stdout.15_43 = stdout;
  __builtin_fwrite ("DT_H2D = ", 1, 9, stdout.15_43);
  data_transfer_h2d_stop.26_45 = data_transfer_h2d_stop;
  data_transfer_h2d_start.27_46 = data_transfer_h2d_start;
  _77 = data_transfer_h2d_stop.26_45 - data_transfer_h2d_start.27_46;
  printf ("%llu", _77);
  stdout.15_48 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15_48);
  stdout.15_50 = stdout;
  __builtin_fwrite ("DT_D2H = ", 1, 9, stdout.15_50);
  data_transfer_d2h_stop.28_52 = data_transfer_d2h_stop;
  data_transfer_d2h_start.29_53 = data_transfer_d2h_start;
  _78 = data_transfer_d2h_stop.28_52 - data_transfer_d2h_start.29_53;
  printf ("%llu", _78);
  reach_offload_decision_point.31_55 = reach_offload_decision_point;
  _111 = ~reach_offload_decision_point.31_55;
  _112 = (int) _111;
  stdout.15_56 = stdout;
  fprintf (stdout.15_56, ", WORK_FINISHED_BEFORE_OFFLOAD_DECISION = %d", _112);
  reach_offload_decision_point.31_58 = reach_offload_decision_point;
  _59 = (int) reach_offload_decision_point.31_58;
  stdout.15_60 = stdout;
  fprintf (stdout.15_60, ", REACH_OFFLOAD_DECISION_POINT = %d", _59);
  decided_by_offloading.32_62 = decided_by_offloading;
  _63 = (int) decided_by_offloading.32_62;
  stdout.15_64 = stdout;
  fprintf (stdout.15_64, ", DECIDED_BY_OFFLOADING = %d", _63);
  made_the_offloading.33_66 = made_the_offloading;
  _67 = (int) made_the_offloading.33_66;
  stdout.15_68 = stdout;
  fprintf (stdout.15_68, ", MADE_THE_OFFLOADING = %d", _67);
  stdout.15_70 = stdout;
  __builtin_fputc (10, stdout.15_70);
  return;

}



;; Function bool create_target_functions_table(Func****, int, int) (_Z29create_target_functions_tablePPPP4Funcii, funcdef_no=3206, decl_uid=66020, cgraph_uid=3028)

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
  __builtin_fwrite ("Allocating the rows.\n", 1, 21, stderr.34_11);
  _14 = (long unsigned int) nrows_13(D);
  _15 = _14 * 8;
  table_17 = malloc (_15);
  if (table_17 != 0B)
    goto <bb 3>;
  else
    goto <bb 9>;

  <bb 3>:
  stderr.34_18 = stderr;
  __builtin_fwrite ("Allocating the columns.\n", 1, 24, stderr.34_18);
  if (nrows_13(D) > 0)
    goto <bb 4>;
  else
    goto <bb 10>;

  <bb 4>:
  # result_57 = PHI <result_1(8), 1(3)>
  # i_58 = PHI <i_43(8), 0(3)>
  _20 = (long unsigned int) i_58;
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
  # j_51 = PHI <0(4)>
  if (ncolumns_23(D) > j_51)
    goto <bb 6>;
  else
    goto <bb 8>;

  <bb 6>:
  # j_59 = PHI <j_40(6), j_51(5)>
  _29 = *_22;
  _30 = (long unsigned int) j_59;
  _31 = _30 * 8;
  _32 = _29 + _31;
  _34 = malloc (48);
  *_32 = _34;
  _36 = *_22;
  _37 = _36 + _31;
  _38 = *_37;
  _38->f = 0B;
  j_40 = j_59 + 1;
  if (ncolumns_23(D) > j_40)
    goto <bb 6>;
  else
    goto <bb 8>;

  <bb 7>:
  stderr.34_41 = stderr;
  __builtin_fwrite ("Error in table of target functions allocation (columns).\n", 1, 57, stderr.34_41);

  <bb 8>:
  # result_1 = PHI <result_57(6), 0(7), result_57(5)>
  i_43 = i_58 + 1;
  if (nrows_13(D) > i_43)
    goto <bb 4>;
  else
    goto <bb 10>;

  <bb 9>:
  stderr.34_44 = stderr;
  __builtin_fwrite ("Error in table of target functions allocation (rows).\n", 1, 54, stderr.34_44);

  <bb 10>:
  # result_3 = PHI <result_1(8), 0(9), 1(3)>
  stderr.34_46 = stderr;
  __builtin_fwrite ("Allocating the columns is OK.\n", 1, 30, stderr.34_46);
  *table__48(D) = table_17;
  return result_3;

}



;; Function void call_function_ffi_call(Func*) (_Z22call_function_ffi_callP4Func, funcdef_no=3207, decl_uid=66035, cgraph_uid=3029)

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
  void (*<T1993>) (void) _17;

  <bb 2>:
  stderr.35_2 = stderr;
  __builtin_fwrite (" In call_function_ffi_call.\n", 1, 28, stderr.35_2);
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
  __builtin_fwrite ("Error ffi_prep_cif.\n", 1, 20, stderr.35_11);
  exit (1);

  <bb 4>:
  _14 = ff_4(D)->arg_values;
  _15 = ff_4(D)->ret_value;
  _16 = ff_4(D)->f;
  _17 = (void (*<T1993>) (void)) _16;
  ffi_call (&cif, _17, _15, _14);
  cif ={v} {CLOBBER};
  return;

}



;; Function void init_array(int, int, int, double*, double*, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z10init_arrayiiiPdS_PA4096_dS1_S1_, funcdef_no=3208, decl_uid=66046, cgraph_uid=3030)

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



;; Function void copy_array(int, int, double (*)[4096], double (*)[4096]) (_Z10copy_arrayiiPA4096_dS0_, funcdef_no=3209, decl_uid=66078, cgraph_uid=3031)

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



;; Function void compareResults(int, int, double (*)[4096], double (*)[4096]) (_Z14compareResultsiiPA4096_dS0_, funcdef_no=3210, decl_uid=66094, cgraph_uid=3032)

void compareResults(int, int, double (*)[4096], double (*)[4096]) (int ni, int nj, double[4096] * C, double[4096] * C_output)
{
  bool iftmp.1;
  float D.67900;
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
  float _26;
  float _27;
  float _28;
  double _29;
  float _30;
  float _31;
  float _32;
  double _33;
  double _35;
  float _36;
  float _37;
  double _38;
  float _39;
  float _40;
  float _41;
  float _42;
  float _43;
  float _44;
  float _45;
  float _46;
  float _47;

  <bb 2>:
  if (ni_6(D) > 0)
    goto <bb 19>;
  else
    goto <bb 20>;

  <bb 3>:
  # j_52 = PHI <j_22(17), 0(19)>
  # fail_53 = PHI <fail_3(17), fail_48(19)>
  _8 = (long unsigned int) i_51;
  _9 = _8 * 32768;
  _11 = C_output_10(D) + _9;
  _13 = *_11[j_52];
  _17 = C_16(D) + _9;
  _18 = *_17[j_52];
  _26 = (float) _18;
  if (_26 < 0.0)
    goto <bb 4>;
  else
    goto <bb 5>;

  <bb 4>:
  _27 = -_26;

  <bb 5>:
  # _28 = PHI <_26(3), _27(4)>
  _29 = (double) _28;
  if (_29 < 1.00000000000000002081668171172168513294309377670288085938e-2)
    goto <bb 6>;
  else
    goto <bb 21>;

  <bb 6>:
  _30 = (float) _13;
  if (_30 < 0.0)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 7>:
  _31 = -_30;

  <bb 8>:
  # _32 = PHI <_30(6), _31(7)>
  _33 = (double) _32;
  if (_33 < 1.00000000000000002081668171172168513294309377670288085938e-2)
    goto <bb 15>;
  else
    goto <bb 21>;

  <bb 9>:
  _37 = -_36;

  <bb 10>:
  # _41 = PHI <_36(21), _37(9)>
  _38 = _18 + 9.99999993922529029077850282192230224609375e-9;
  _39 = (float) _38;
  if (_39 < 0.0)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 11>:
  _40 = -_39;

  <bb 12>:
  # _42 = PHI <_39(10), _40(11)>
  _43 = _41 / _42;
  if (_43 < 0.0)
    goto <bb 13>;
  else
    goto <bb 14>;

  <bb 13>:
  _44 = -_43;

  <bb 14>:
  # _45 = PHI <_43(12), _44(13)>
  _46 = _45 * 1.0e+2;

  <bb 15>:
  # _47 = PHI <0.0(8), _46(14)>
  _20 = (double) _47;
  if (_20 > 5.000000000000000277555756156289135105907917022705078125e-2)
    goto <bb 16>;
  else
    goto <bb 17>;

  <bb 16>:
  fail_21 = fail_53 + 1;

  <bb 17>:
  # fail_3 = PHI <fail_53(15), fail_21(16)>
  j_22 = j_52 + 1;
  if (nj_7(D) > j_22)
    goto <bb 3>;
  else
    goto <bb 18>;

  <bb 18>:
  # fail_19 = PHI <fail_3(17), fail_48(19)>
  i_23 = i_51 + 1;
  if (ni_6(D) > i_23)
    goto <bb 19>;
  else
    goto <bb 20>;

  <bb 19>:
  # fail_48 = PHI <fail_19(18), 0(2)>
  # i_51 = PHI <i_23(18), 0(2)>
  if (nj_7(D) > 0)
    goto <bb 3>;
  else
    goto <bb 18>;

  <bb 20>:
  # fail_14 = PHI <fail_19(18), 0(2)>
  stderr.38_24 = stderr;
  fprintf (stderr.38_24, "Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", 5.000000000000000277555756156289135105907917022705078125e-2, fail_14);
  return;

  <bb 21>:
  _35 = _18 - _13;
  _36 = (float) _35;
  if (_36 < 0.0)
    goto <bb 9>;
  else
    goto <bb 10>;

}



;; Function void gemm(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z4gemmiiiddPA4096_dS0_S0_, funcdef_no=3212, decl_uid=66130, cgraph_uid=3034)

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



;; Function void gemm_original(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z13gemm_originaliiiddPA4096_dS0_S0_, funcdef_no=3213, decl_uid=66155, cgraph_uid=3035)

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



;; Function void gemm_omp_kernel(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_, funcdef_no=3214, decl_uid=66165, cgraph_uid=3036)

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



;; Function void gemm_omp(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z8gemm_ompiiiddPA4096_dS0_S0_, funcdef_no=3215, decl_uid=66187, cgraph_uid=3037)

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



;; Function void GPU_argv_init() (_Z13GPU_argv_initv, funcdef_no=3216, decl_uid=66189, cgraph_uid=3038)

void GPU_argv_init() ()
{
  struct cudaDeviceProp deviceProp;
  struct _IO_FILE * stderr.43;

  <bb 2>:
  stderr.43_2 = stderr;
  __builtin_fwrite ("GPU init.\n", 1, 10, stderr.43_2);
  cudaGetDeviceProperties (&deviceProp, 0);
  stderr.43_5 = stderr;
  fprintf (stderr.43_5, "setting device %d with name %s\n", 0, &deviceProp.name);
  cudaSetDevice (0);
  deviceProp ={v} {CLOBBER};
  return;

}



;; Function int main(int, char**) (main, funcdef_no=3218, decl_uid=66234, cgraph_uid=3040) (executed once)

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
  long unsigned int _178;
  long unsigned int _179;
  double[4096] * _180;
  double _182;
  int _184;
  int _185;
  int _186;

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
  __builtin_fwrite ("Preparing alternatives functions.\n", 1, 34, stderr.53_18);
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
  __builtin_fwrite ("Creating table of target functions.\n", 1, 36, stderr.53_57);
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
  __assert_fail ("table != __null", "gemm.cu", 402, &__PRETTY_FUNCTION__);

  <bb 5>:
  stderr.53_64 = stderr;
  __builtin_fwrite ("Declaring function in 0,1.\n", 1, 27, stderr.53_64);
  table.55_66 = table;
  _67 = *table.55_66;
  _68 = MEM[(struct Func * *)_67 + 8B];
  *_68 = MEM[(const struct Func &)ff_0_21];
  TablePointerFunctions = table.55_66;

  <bb 6>:
  stderr.53_73 = stderr;
  __builtin_fwrite ("Calling init_array.\n", 1, 20, stderr.53_73);
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
  # j_213 = PHI <j_154(7), j_61(9)>
  _148 = (long unsigned int) i_201;
  _149 = _148 * 32768;
  _150 = C_outputFromOMP_144 + _149;
  _151 = C.57_82 + _149;
  _153 = *_151[j_213];
  *_150[j_213] = _153;
  j_154 = j_213 + 1;
  if (nj.61_83 > j_154)
    goto <bb 7>;
  else
    goto <bb 8>;

  <bb 8>:
  i_155 = i_201 + 1;
  if (ni.62_84 > i_155)
    goto <bb 9>;
  else
    goto <bb 10>;

  <bb 9>:
  # j_61 = PHI <0(8), 0(6)>
  # i_201 = PHI <i_155(8), 0(6)>
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
  # j_215 = PHI <j_163(11), j_200(13)>
  _157 = (long unsigned int) i_214;
  _158 = _157 * 32768;
  _159 = C_outputFromGpu.63_86 + _158;
  _160 = C.57_82 + _158;
  _162 = *_160[j_215];
  *_159[j_215] = _162;
  j_163 = j_215 + 1;
  if (nj.61_83 > j_163)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 12>:
  i_164 = i_214 + 1;
  if (ni.62_84 > i_164)
    goto <bb 13>;
  else
    goto <bb 14>;

  <bb 13>:
  # j_200 = PHI <0(12), 0(10)>
  # i_214 = PHI <i_164(12), 0(10)>
  if (nj.61_83 > j_200)
    goto <bb 11>;
  else
    goto <bb 12>;

  <bb 14>:
  stderr.53_88 = stderr;
  __builtin_fwrite ("Calling gemm_omp:\n", 1, 18, stderr.53_88);
  B.58_90 = B;
  A.59_91 = A;
  beta.64_92 = beta;
  alpha.65_93 = alpha;
  nk.60_94 = nk;
  nj.61_95 = nj;
  ni.62_96 = ni;
  gemm_omp (ni.62_96, nj.61_95, nk.60_94, alpha.65_93, beta.64_92, A.59_91, B.58_90, C_outputFromOMP_144);
  stdout.66_98 = stdout;
  fprintf (stdout.66_98, "version = OMP+OFF, num_threads = %d, NI = %d, NJ = %d, NK = %d, ", 8, 4096, 4096, 4096);
  hookomp_print_time_results ();
  stderr.53_101 = stderr;
  __builtin_fwrite ("Calling compareResults(original, omp).\n", 1, 39, stderr.53_101);
  C.57_103 = C;
  nj.61_104 = nj;
  ni.62_105 = ni;
  compareResults (ni.62_105, nj.61_104, C.57_103, C_outputFromOMP_144);
  stderr.53_107 = stderr;
  __builtin_fwrite ("Calling compareResults(original, cuda).\n", 1, 40, stderr.53_107);
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
  # j_223 = PHI <j_188(19), j_70(21)>
  _178 = (long unsigned int) i_222;
  _179 = _178 * 32768;
  _180 = C_outputFromGpu.63_118 + _179;
  _182 = *_180[j_223];
  stderr.67_183 = stderr;
  fprintf (stderr.67_183, "%0.2lf ", _182);
  _184 = ni.62_120 * i_222;
  _185 = j_223 + _184;
  _186 = _185 % 20;
  if (_186 == 0)
    goto <bb 18>;
  else
    goto <bb 19>;

  <bb 18>:
  stderr.67_187 = stderr;
  __builtin_fputc (10, stderr.67_187);

  <bb 19>:
  j_188 = j_223 + 1;
  if (nj.61_119 > j_188)
    goto <bb 17>;
  else
    goto <bb 20>;

  <bb 20>:
  i_189 = i_222 + 1;
  if (ni.62_120 > i_189)
    goto <bb 21>;
  else
    goto <bb 22>;

  <bb 21>:
  # j_70 = PHI <0(20), 0(16)>
  # i_222 = PHI <i_189(20), 0(16)>
  if (j_70 < nj.61_119)
    goto <bb 17>;
  else
    goto <bb 20>;

  <bb 22>:
  stderr.67_190 = stderr;
  __builtin_fputc (10, stderr.67_190);

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



;; Function void polybench_flush_cache() (_Z21polybench_flush_cachev, funcdef_no=3220, decl_uid=66470, cgraph_uid=3042)

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



;; Function void polybench_prepare_instruments() (_Z29polybench_prepare_instrumentsv, funcdef_no=3221, decl_uid=66481, cgraph_uid=3043)

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



;; Function void polybench_timer_start() (_Z21polybench_timer_startv, funcdef_no=3222, decl_uid=65328, cgraph_uid=3044)

void polybench_timer_start() ()
{
  struct timeval Tp;
  int stat;
  double D.68182;
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
  printf ("Error return from gettimeofday: %d", stat_16);

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



;; Function void polybench_timer_stop() (_Z20polybench_timer_stopv, funcdef_no=3223, decl_uid=65329, cgraph_uid=3045)

void polybench_timer_stop() ()
{
  struct timeval Tp;
  int stat;
  double D.68200;
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
  printf ("Error return from gettimeofday: %d", stat_5);

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



;; Function void polybench_timer_print() (_Z21polybench_timer_printv, funcdef_no=3224, decl_uid=65330, cgraph_uid=3046)

void polybench_timer_print() ()
{
  double polybench_t_start.71;
  double polybench_t_end.70;
  double _4;

  <bb 2>:
  polybench_t_end.70_2 = polybench_t_end;
  polybench_t_start.71_3 = polybench_t_start;
  _4 = polybench_t_end.70_2 - polybench_t_start.71_3;
  printf ("%0.6f\n", _4);
  return;

}



;; Function void* polybench_alloc_data(long long unsigned int, int) (_Z20polybench_alloc_datayi, funcdef_no=3226, decl_uid=65336, cgraph_uid=3048)

void* polybench_alloc_data(long long unsigned int, int) (long long unsigned int n, int elt_size)
{
  int ret;
  void * newA;
  struct _IO_FILE * stderr.73;
  void * newA.72;
  void * D.68212;
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



;; Function void __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_(int, int, int, double, double, double*, double*, double*) (_Z45__device_stub__Z16gemm_cuda_kerneliiiddPdS_S_iiiddPdS_S_, funcdef_no=3251, decl_uid=66803, cgraph_uid=3072)

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



;; Function void gemm_cuda(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096]) (_Z9gemm_cudaiiiddPA4096_dS0_S0_S0_S0_, funcdef_no=3217, decl_uid=66211, cgraph_uid=3039)

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
  long int _65;
  long unsigned int _66;
  long unsigned int _67;
  long int _68;
  long unsigned int _69;
  uint64_t _70;
  long int _71;
  long unsigned int _72;
  long unsigned int _73;
  long int _74;
  long unsigned int _75;
  uint64_t _76;
  long int _77;
  long unsigned int _78;
  long unsigned int _79;
  long int _80;
  long unsigned int _81;
  uint64_t _82;
  long int _83;
  long unsigned int _84;
  long unsigned int _85;
  long int _86;
  long unsigned int _87;
  uint64_t _88;
  long int _89;
  long unsigned int _90;
  long unsigned int _91;
  long int _92;
  long unsigned int _93;
  uint64_t _94;
  long int _95;
  long unsigned int _96;
  long unsigned int _97;
  long int _98;
  long unsigned int _99;
  uint64_t _100;

  <bb 2>:
  stderr.44_3 = stderr;
  __builtin_fwrite ("Calling function gemm_cuda.\n", 1, 28, stderr.44_3);
  GPU_argv_init ();
  cudaMalloc (&A_gpu, 134217728);
  cudaMalloc (&B_gpu, 134217728);
  cudaMalloc (&C_gpu, 134217728);
  clock_gettime (1, &spec);
  _65 = spec.tv_sec;
  _66 = (long unsigned int) _65;
  _67 = _66 * 1000000000;
  _68 = spec.tv_nsec;
  _69 = (long unsigned int) _68;
  _70 = _67 + _69;
  spec ={v} {CLOBBER};
  data_transfer_h2d_start = _70;
  A_gpu.45_10 = A_gpu;
  cudaMemcpy (A_gpu.45_10, A_11(D), 134217728, 1);
  B_gpu.46_13 = B_gpu;
  cudaMemcpy (B_gpu.46_13, B_14(D), 134217728, 1);
  C_gpu.47_17 = C_gpu;
  cudaMemcpy (C_gpu.47_17, C_inputToGpu_18(D), 134217728, 1);
  clock_gettime (1, &spec);
  _71 = spec.tv_sec;
  _72 = (long unsigned int) _71;
  _73 = _72 * 1000000000;
  _74 = spec.tv_nsec;
  _75 = (long unsigned int) _74;
  _76 = _73 + _75;
  spec ={v} {CLOBBER};
  data_transfer_h2d_stop = _76;
  block.z = 1;
  grid.x = 128;
  grid.y = 512;
  grid.z = 1;
  clock_gettime (1, &spec);
  _77 = spec.tv_sec;
  _78 = (long unsigned int) _77;
  _79 = _78 * 1000000000;
  _80 = spec.tv_nsec;
  _81 = (long unsigned int) _80;
  _82 = _79 + _81;
  spec ={v} {CLOBBER};
  dev_kernel1_start = _82;
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
  _83 = spec.tv_sec;
  _84 = (long unsigned int) _83;
  _85 = _84 * 1000000000;
  _86 = spec.tv_nsec;
  _87 = (long unsigned int) _86;
  _88 = _85 + _87;
  spec ={v} {CLOBBER};
  dev_kernel1_stop = _88;
  clock_gettime (1, &spec);
  _89 = spec.tv_sec;
  _90 = (long unsigned int) _89;
  _91 = _90 * 1000000000;
  _92 = spec.tv_nsec;
  _93 = (long unsigned int) _92;
  _94 = _91 + _93;
  spec ={v} {CLOBBER};
  data_transfer_d2h_start = _94;
  C_gpu.47_43 = C_gpu;
  cudaMemcpy (C_outputFromGpu_44(D), C_gpu.47_43, 134217728, 2);
  clock_gettime (1, &spec);
  _95 = spec.tv_sec;
  _96 = (long unsigned int) _95;
  _97 = _96 * 1000000000;
  _98 = spec.tv_nsec;
  _99 = (long unsigned int) _98;
  _100 = _97 + _99;
  spec ={v} {CLOBBER};
  data_transfer_d2h_stop = _100;
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



;; Function void __sti____cudaRegisterAll_39_tmpxft_0000057e_00000000_7_gemm_cpp1_ii_132e4611() (_ZL76__sti____cudaRegisterAll_39_tmpxft_0000057e_00000000_7_gemm_cpp1_ii_132e4611v, funcdef_no=3254, decl_uid=66806, cgraph_uid=3075) (executed once)

void __sti____cudaRegisterAll_39_tmpxft_0000057e_00000000_7_gemm_cpp1_ii_132e4611() ()
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


