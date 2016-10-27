
;; Function float absVal(float) (_Z6absValf, funcdef_no=3194, decl_uid=65338, cgraph_uid=3016)

float absVal(float) (float a)
{
  float D.66867;

  if (a < 0.0) goto <D.66865>; else goto <D.66866>;
  <D.66865>:
  D.66867 = -a;
  goto <D.66868>;
  <D.66866>:
  D.66867 = a;
  goto <D.66868>;
  <D.66868>:
  return D.66867;
}



;; Function float percentDiff(double, double) (_Z11percentDiffdd, funcdef_no=3195, decl_uid=65342, cgraph_uid=3017)

float percentDiff(double, double) (double val1, double val2)
{
  float D.66891;
  float D.66890;
  float D.66889;
  float D.66888;
  double D.66887;
  float D.66886;
  float D.66885;
  double D.66884;
  float D.66883;
  double D.66879;
  float D.66878;
  float D.66877;
  double D.66875;
  float D.66874;
  float D.66873;
  bool iftmp.1;
  bool retval.0;

  D.66873 = (float) val1;
  D.66874 = absVal (D.66873);
  D.66875 = (double) D.66874;
  if (D.66875 < 1.00000000000000002081668171172168513294309377670288085938e-2) goto <D.66876>; else goto <D.66871>;
  <D.66876>:
  D.66877 = (float) val2;
  D.66878 = absVal (D.66877);
  D.66879 = (double) D.66878;
  if (D.66879 < 1.00000000000000002081668171172168513294309377670288085938e-2) goto <D.66880>; else goto <D.66871>;
  <D.66880>:
  iftmp.1 = 1;
  goto <D.66872>;
  <D.66871>:
  iftmp.1 = 0;
  <D.66872>:
  retval.0 = iftmp.1;
  if (retval.0 != 0) goto <D.66881>; else goto <D.66882>;
  <D.66881>:
  D.66883 = 0.0;
  goto <D.66892>;
  <D.66882>:
  D.66884 = val1 - val2;
  D.66885 = (float) D.66884;
  D.66886 = absVal (D.66885);
  D.66887 = val1 + 9.99999993922529029077850282192230224609375e-9;
  D.66888 = (float) D.66887;
  D.66889 = absVal (D.66888);
  D.66890 = D.66886 / D.66889;
  D.66891 = absVal (D.66890);
  D.66883 = D.66891 * 1.0e+2;
  goto <D.66892>;
  <D.66892>:
  return D.66883;
}



;; Function uint64_t get_time() (_Z8get_timev, funcdef_no=3200, decl_uid=65516, cgraph_uid=3022)

uint64_t get_time() ()
{
  struct timespec spec;
  long unsigned int D.66898;
  long int D.66897;
  long unsigned int D.66896;
  long unsigned int D.66895;
  long int D.66894;
  uint64_t D.66893;

  clock_gettime (1, &spec);
  D.66894 = spec.tv_sec;
  D.66895 = (long unsigned int) D.66894;
  D.66896 = D.66895 * 1000000000;
  D.66897 = spec.tv_nsec;
  D.66898 = (long unsigned int) D.66897;
  D.66893 = D.66896 + D.66898;
  goto <D.66900>;
  <D.66900>:
  spec = {CLOBBER};
  goto <D.66899>;
  <D.66899>:
  return D.66893;
}



;; Function void hookomp_timing_start(uint64_t*) (_Z20hookomp_timing_startPm, funcdef_no=3201, decl_uid=65520, cgraph_uid=3023)

void hookomp_timing_start(uint64_t*) (uint64_t * _start)
{
  long unsigned int D.66901;

  D.66901 = get_time ();
  *_start = D.66901;
  return;
}



;; Function void hookomp_timing_stop(uint64_t*) (_Z19hookomp_timing_stopPm, funcdef_no=3202, decl_uid=65523, cgraph_uid=3024)

void hookomp_timing_stop(uint64_t*) (uint64_t * _stop)
{
  long unsigned int D.66902;

  D.66902 = get_time ();
  *_stop = D.66902;
  return;
}



;; Function void hookomp_timing_print(uint64_t, uint64_t) (_Z20hookomp_timing_printmm, funcdef_no=3203, decl_uid=65527, cgraph_uid=3025)

void hookomp_timing_print(uint64_t, uint64_t) (uint64_t tstart, uint64_t tstop)
{
  long unsigned int D.66903;

  D.66903 = tstop - tstart;
  printf ("%llu", D.66903);
  return;
}



;; Function void hookomp_timing_print_without_dev() (_Z32hookomp_timing_print_without_devv, funcdef_no=3204, decl_uid=65529, cgraph_uid=3026)

void hookomp_timing_print_without_dev() ()
{
  uint64_t dt_time;
  uint64_t dev_time;
  uint64_t total_time;
  long unsigned int D.66925;
  uint64_t iftmp.14;
  long unsigned int D.66921;
  long unsigned int data_transfer_d2h_start.13;
  long unsigned int data_transfer_d2h_stop.12;
  long unsigned int D.66918;
  long unsigned int data_transfer_h2d_start.11;
  long unsigned int data_transfer_h2d_stop.10;
  long unsigned int D.66915;
  long unsigned int dev_kernel3_start.9;
  long unsigned int dev_kernel3_stop.8;
  long unsigned int D.66912;
  long unsigned int D.66911;
  long unsigned int dev_kernel2_start.7;
  long unsigned int dev_kernel2_stop.6;
  long unsigned int D.66908;
  long unsigned int dev_kernel1_start.5;
  long unsigned int dev_kernel1_stop.4;
  long unsigned int omp_start.3;
  long unsigned int omp_stop.2;

  omp_stop.2 = omp_stop;
  omp_start.3 = omp_start;
  total_time = omp_stop.2 - omp_start.3;
  dev_kernel1_stop.4 = dev_kernel1_stop;
  dev_kernel1_start.5 = dev_kernel1_start;
  D.66908 = dev_kernel1_stop.4 - dev_kernel1_start.5;
  dev_kernel2_stop.6 = dev_kernel2_stop;
  dev_kernel2_start.7 = dev_kernel2_start;
  D.66911 = dev_kernel2_stop.6 - dev_kernel2_start.7;
  D.66912 = D.66908 + D.66911;
  dev_kernel3_stop.8 = dev_kernel3_stop;
  dev_kernel3_start.9 = dev_kernel3_start;
  D.66915 = dev_kernel3_stop.8 - dev_kernel3_start.9;
  dev_time = D.66912 + D.66915;
  data_transfer_h2d_stop.10 = data_transfer_h2d_stop;
  data_transfer_h2d_start.11 = data_transfer_h2d_start;
  D.66918 = data_transfer_h2d_stop.10 - data_transfer_h2d_start.11;
  data_transfer_d2h_stop.12 = data_transfer_d2h_stop;
  data_transfer_d2h_start.13 = data_transfer_d2h_start;
  D.66921 = data_transfer_d2h_stop.12 - data_transfer_d2h_start.13;
  dt_time = D.66918 + D.66921;
  if (total_time != 0) goto <D.66923>; else goto <D.66924>;
  <D.66923>:
  D.66925 = total_time - dev_time;
  iftmp.14 = D.66925 - dt_time;
  goto <D.66926>;
  <D.66924>:
  iftmp.14 = total_time;
  <D.66926>:
  printf ("%llu", iftmp.14);
  return;
}



;; Function void hookomp_print_time_results() (_Z26hookomp_print_time_resultsv, funcdef_no=3205, decl_uid=65534, cgraph_uid=3027)

void hookomp_print_time_results() ()
{
  int D.66952;
  bool made_the_offloading.33;
  int D.66950;
  bool decided_by_offloading.32;
  int D.66948;
  bool D.66944;
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

  stdout.15 = stdout;
  __builtin_fwrite ("ORIG = ", 1, 7, stdout.15);
  seq_stop.16 = seq_stop;
  seq_start.17 = seq_start;
  hookomp_timing_print (seq_start.17, seq_stop.16);
  stdout.15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15);
  stdout.15 = stdout;
  __builtin_fwrite ("OMP_OFF = ", 1, 10, stdout.15);
  omp_stop.18 = omp_stop;
  omp_start.19 = omp_start;
  hookomp_timing_print (omp_start.19, omp_stop.18);
  stdout.15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15);
  stdout.15 = stdout;
  __builtin_fwrite ("OMP = ", 1, 6, stdout.15);
  hookomp_timing_print_without_dev ();
  stdout.15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15);
  stdout.15 = stdout;
  __builtin_fwrite ("CUDA_KERNEL1 = ", 1, 15, stdout.15);
  dev_kernel1_stop.20 = dev_kernel1_stop;
  dev_kernel1_start.21 = dev_kernel1_start;
  hookomp_timing_print (dev_kernel1_start.21, dev_kernel1_stop.20);
  stdout.15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15);
  stdout.15 = stdout;
  __builtin_fwrite ("CUDA_KERNEL2 = ", 1, 15, stdout.15);
  dev_kernel2_stop.22 = dev_kernel2_stop;
  dev_kernel2_start.23 = dev_kernel2_start;
  hookomp_timing_print (dev_kernel2_start.23, dev_kernel2_stop.22);
  stdout.15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15);
  stdout.15 = stdout;
  __builtin_fwrite ("CUDA_KERNEL3 = ", 1, 15, stdout.15);
  dev_kernel3_stop.24 = dev_kernel3_stop;
  dev_kernel3_start.25 = dev_kernel3_start;
  hookomp_timing_print (dev_kernel3_start.25, dev_kernel3_stop.24);
  stdout.15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15);
  stdout.15 = stdout;
  __builtin_fwrite ("DT_H2D = ", 1, 9, stdout.15);
  data_transfer_h2d_stop.26 = data_transfer_h2d_stop;
  data_transfer_h2d_start.27 = data_transfer_h2d_start;
  hookomp_timing_print (data_transfer_h2d_start.27, data_transfer_h2d_stop.26);
  stdout.15 = stdout;
  __builtin_fwrite (", ", 1, 2, stdout.15);
  stdout.15 = stdout;
  __builtin_fwrite ("DT_D2H = ", 1, 9, stdout.15);
  data_transfer_d2h_stop.28 = data_transfer_d2h_stop;
  data_transfer_d2h_start.29 = data_transfer_d2h_start;
  hookomp_timing_print (data_transfer_d2h_start.29, data_transfer_d2h_stop.28);
  reach_offload_decision_point.31 = reach_offload_decision_point;
  D.66944 = ~reach_offload_decision_point.31;
  if (D.66944 != 0) goto <D.66945>; else goto <D.66946>;
  <D.66945>:
  iftmp.30 = 1;
  goto <D.66947>;
  <D.66946>:
  iftmp.30 = 0;
  <D.66947>:
  stdout.15 = stdout;
  fprintf (stdout.15, ", WORK_FINISHED_BEFORE_OFFLOAD_DECISION = %d", iftmp.30);
  reach_offload_decision_point.31 = reach_offload_decision_point;
  D.66948 = (int) reach_offload_decision_point.31;
  stdout.15 = stdout;
  fprintf (stdout.15, ", REACH_OFFLOAD_DECISION_POINT = %d", D.66948);
  decided_by_offloading.32 = decided_by_offloading;
  D.66950 = (int) decided_by_offloading.32;
  stdout.15 = stdout;
  fprintf (stdout.15, ", DECIDED_BY_OFFLOADING = %d", D.66950);
  made_the_offloading.33 = made_the_offloading;
  D.66952 = (int) made_the_offloading.33;
  stdout.15 = stdout;
  fprintf (stdout.15, ", MADE_THE_OFFLOADING = %d", D.66952);
  stdout.15 = stdout;
  __builtin_fputc (10, stdout.15);
  return;
}



;; Function bool create_target_functions_table(Func****, int, int) (_Z29create_target_functions_tablePPPP4Funcii, funcdef_no=3206, decl_uid=66020, cgraph_uid=3028)

bool create_target_functions_table(Func****, int, int) (struct Func * * * * table_, int nrows, int ncolumns)
{
  int j;
  int i;
  bool result;
  struct Func * * * table;
  bool D.66974;
  struct Func * D.66971;
  void * D.66970;
  struct Func * * D.66969;
  long unsigned int D.66968;
  long unsigned int D.66967;
  struct Func * * D.66964;
  void * D.66963;
  long unsigned int D.66962;
  long unsigned int D.66961;
  struct Func * * * D.66960;
  long unsigned int D.66959;
  long unsigned int D.66958;
  long unsigned int D.66955;
  long unsigned int D.66954;
  struct _IO_FILE * stderr.34;

  result = 1;
  stderr.34 = stderr;
  __builtin_fwrite ("Allocating the rows.\n", 1, 21, stderr.34);
  D.66954 = (long unsigned int) nrows;
  D.66955 = D.66954 * 8;
  table = malloc (D.66955);
  if (table != 0B) goto <D.66956>; else goto <D.66957>;
  <D.66956>:
  stderr.34 = stderr;
  __builtin_fwrite ("Allocating the columns.\n", 1, 24, stderr.34);
  i = 0;
  goto <D.66033>;
  <D.66032>:
  D.66958 = (long unsigned int) i;
  D.66959 = D.66958 * 8;
  D.66960 = table + D.66959;
  D.66961 = (long unsigned int) ncolumns;
  D.66962 = D.66961 * 8;
  D.66963 = malloc (D.66962);
  *D.66960 = D.66963;
  D.66958 = (long unsigned int) i;
  D.66959 = D.66958 * 8;
  D.66960 = table + D.66959;
  D.66964 = *D.66960;
  if (D.66964 != 0B) goto <D.66965>; else goto <D.66966>;
  <D.66965>:
  j = 0;
  goto <D.66031>;
  <D.66030>:
  D.66958 = (long unsigned int) i;
  D.66959 = D.66958 * 8;
  D.66960 = table + D.66959;
  D.66964 = *D.66960;
  D.66967 = (long unsigned int) j;
  D.66968 = D.66967 * 8;
  D.66969 = D.66964 + D.66968;
  D.66970 = malloc (48);
  *D.66969 = D.66970;
  D.66958 = (long unsigned int) i;
  D.66959 = D.66958 * 8;
  D.66960 = table + D.66959;
  D.66964 = *D.66960;
  D.66967 = (long unsigned int) j;
  D.66968 = D.66967 * 8;
  D.66969 = D.66964 + D.66968;
  D.66971 = *D.66969;
  D.66971->f = 0B;
  j = j + 1;
  <D.66031>:
  if (j < ncolumns) goto <D.66030>; else goto <D.66028>;
  <D.66028>:
  goto <D.66972>;
  <D.66966>:
  stderr.34 = stderr;
  __builtin_fwrite ("Error in table of target functions allocation (columns).\n", 1, 57, stderr.34);
  result = 0;
  <D.66972>:
  i = i + 1;
  <D.66033>:
  if (i < nrows) goto <D.66032>; else goto <D.66026>;
  <D.66026>:
  goto <D.66973>;
  <D.66957>:
  stderr.34 = stderr;
  __builtin_fwrite ("Error in table of target functions allocation (rows).\n", 1, 54, stderr.34);
  result = 0;
  <D.66973>:
  stderr.34 = stderr;
  __builtin_fwrite ("Allocating the columns is OK.\n", 1, 30, stderr.34);
  *table_ = table;
  D.66974 = result;
  goto <D.66975>;
  <D.66975>:
  return D.66974;
}



;; Function void call_function_ffi_call(Func*) (_Z22call_function_ffi_callP4Func, funcdef_no=3207, decl_uid=66035, cgraph_uid=3029)

void call_function_ffi_call(Func*) (struct Func * ff)
{
  ffi_status D.66989;
  struct ffi_cif cif;
  void (*<T1993>) (void) D.66988;
  void * D.66987;
  void * D.66986;
  void * * D.66985;
  ffi_status D.66982;
  unsigned int D.66981;
  int D.66980;
  struct ffi_type * D.66979;
  struct ffi_type * * D.66978;
  bool retval.36;
  struct _IO_FILE * stderr.35;

  stderr.35 = stderr;
  __builtin_fwrite (" In call_function_ffi_call.\n", 1, 28, stderr.35);
  D.66978 = ff->arg_types;
  D.66979 = ff->ret_type;
  D.66980 = ff->nargs;
  D.66981 = (unsigned int) D.66980;
  D.66989 = ffi_prep_cif (&cif, 2, D.66981, D.66979, D.66978);
  D.66982 = D.66989;
  retval.36 = D.66982 != 0;
  if (retval.36 != 0) goto <D.66983>; else goto <D.66984>;
  <D.66983>:
  stderr.35 = stderr;
  __builtin_fwrite ("Error ffi_prep_cif.\n", 1, 20, stderr.35);
  exit (1);
  <D.66984>:
  D.66985 = ff->arg_values;
  D.66986 = ff->ret_value;
  D.66987 = ff->f;
  D.66988 = (void (*<T1993>) (void)) D.66987;
  ffi_call (&cif, D.66988, D.66986, D.66985);
  cif = {CLOBBER};
  return;
  <D.66990>:
  cif = {CLOBBER};
  resx 1
}



;; Function void init_array(int, int, int, double*, double*, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z10init_arrayiiiPdS_PA4096_dS1_S1_, funcdef_no=3208, decl_uid=66046, cgraph_uid=3030)

void init_array(int, int, int, double*, double*, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double * alpha, double * beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int j;
  int i;
  double[4096] * D.67000;
  double[4096] * D.66999;
  double D.66998;
  double D.66997;
  double D.66996;
  double D.66995;
  double[4096] * D.66994;
  long unsigned int D.66993;
  long unsigned int D.66992;

  *alpha = 3.2412e+4;
  *beta = 2.123e+3;
  i = 0;
  goto <D.66057>;
  <D.66056>:
  j = 0;
  goto <D.66055>;
  <D.66054>:
  D.66992 = (long unsigned int) i;
  D.66993 = D.66992 * 32768;
  D.66994 = A + D.66993;
  D.66995 = (double) i;
  D.66996 = (double) j;
  D.66997 = D.66995 * D.66996;
  D.66998 = D.66997 * 2.44140625e-4;
  *D.66994[j] = D.66998;
  j = j + 1;
  <D.66055>:
  if (j < nk) goto <D.66054>; else goto <D.66052>;
  <D.66052>:
  i = i + 1;
  <D.66057>:
  if (i < ni) goto <D.66056>; else goto <D.66050>;
  <D.66050>:
  i = 0;
  goto <D.66065>;
  <D.66064>:
  j = 0;
  goto <D.66063>;
  <D.66062>:
  D.66992 = (long unsigned int) i;
  D.66993 = D.66992 * 32768;
  D.66999 = B + D.66993;
  D.66995 = (double) i;
  D.66996 = (double) j;
  D.66997 = D.66995 * D.66996;
  D.66998 = D.66997 * 2.44140625e-4;
  *D.66999[j] = D.66998;
  j = j + 1;
  <D.66063>:
  if (j < nj) goto <D.66062>; else goto <D.66060>;
  <D.66060>:
  i = i + 1;
  <D.66065>:
  if (i < nk) goto <D.66064>; else goto <D.66058>;
  <D.66058>:
  i = 0;
  goto <D.66073>;
  <D.66072>:
  j = 0;
  goto <D.66071>;
  <D.66070>:
  D.66992 = (long unsigned int) i;
  D.66993 = D.66992 * 32768;
  D.67000 = C + D.66993;
  D.66995 = (double) i;
  D.66996 = (double) j;
  D.66997 = D.66995 * D.66996;
  D.66998 = D.66997 * 2.44140625e-4;
  *D.67000[j] = D.66998;
  j = j + 1;
  <D.66071>:
  if (j < nj) goto <D.66070>; else goto <D.66068>;
  <D.66068>:
  i = i + 1;
  <D.66073>:
  if (i < ni) goto <D.66072>; else goto <D.66066>;
  <D.66066>:
  return;
}



;; Function void copy_array(int, int, double (*)[4096], double (*)[4096]) (_Z10copy_arrayiiPA4096_dS0_, funcdef_no=3209, decl_uid=66078, cgraph_uid=3031)

void copy_array(int, int, double (*)[4096], double (*)[4096]) (int ni, int nj, double[4096] * C_source, double[4096] * C_dest)
{
  int j;
  int i;
  double D.67005;
  double[4096] * D.67004;
  double[4096] * D.67003;
  long unsigned int D.67002;
  long unsigned int D.67001;

  i = 0;
  goto <D.66089>;
  <D.66088>:
  j = 0;
  goto <D.66087>;
  <D.66086>:
  D.67001 = (long unsigned int) i;
  D.67002 = D.67001 * 32768;
  D.67003 = C_dest + D.67002;
  D.67001 = (long unsigned int) i;
  D.67002 = D.67001 * 32768;
  D.67004 = C_source + D.67002;
  D.67005 = *D.67004[j];
  *D.67003[j] = D.67005;
  j = j + 1;
  <D.66087>:
  if (j < nj) goto <D.66086>; else goto <D.66084>;
  <D.66084>:
  i = i + 1;
  <D.66089>:
  if (i < ni) goto <D.66088>; else goto <D.66082>;
  <D.66082>:
  return;
}



;; Function void compareResults(int, int, double (*)[4096], double (*)[4096]) (_Z14compareResultsiiPA4096_dS0_, funcdef_no=3210, decl_uid=66094, cgraph_uid=3032)

void compareResults(int, int, double (*)[4096], double (*)[4096]) (int ni, int nj, double[4096] * C, double[4096] * C_output)
{
  int fail;
  int j;
  int i;
  struct _IO_FILE * stderr.38;
  double D.67014;
  float D.67013;
  double D.67012;
  double[4096] * D.67011;
  double D.67010;
  double[4096] * D.67009;
  long unsigned int D.67008;
  long unsigned int D.67007;
  bool retval.37;

  fail = 0;
  i = 0;
  goto <D.66106>;
  <D.66105>:
  j = 0;
  goto <D.66104>;
  <D.66103>:
  D.67007 = (long unsigned int) i;
  D.67008 = D.67007 * 32768;
  D.67009 = C_output + D.67008;
  D.67010 = *D.67009[j];
  D.67007 = (long unsigned int) i;
  D.67008 = D.67007 * 32768;
  D.67011 = C + D.67008;
  D.67012 = *D.67011[j];
  D.67013 = percentDiff (D.67012, D.67010);
  D.67014 = (double) D.67013;
  retval.37 = D.67014 > 5.000000000000000277555756156289135105907917022705078125e-2;
  if (retval.37 != 0) goto <D.67015>; else goto <D.67016>;
  <D.67015>:
  fail = fail + 1;
  goto <D.67017>;
  <D.67016>:
  <D.67017>:
  j = j + 1;
  <D.66104>:
  if (j < nj) goto <D.66103>; else goto <D.66101>;
  <D.66101>:
  i = i + 1;
  <D.66106>:
  if (i < ni) goto <D.66105>; else goto <D.66099>;
  <D.66099>:
  stderr.38 = stderr;
  fprintf (stderr.38, "Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", 5.000000000000000277555756156289135105907917022705078125e-2, fail);
  return;
}



;; Function void gemm(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z4gemmiiiddPA4096_dS0_S0_, funcdef_no=3212, decl_uid=66130, cgraph_uid=3034)

void gemm(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int k;
  int j;
  int i;
  double D.67032;
  double D.67031;
  double D.67030;
  double[4096] * D.67029;
  long unsigned int D.67028;
  long unsigned int D.67027;
  double D.67026;
  double D.67025;
  double[4096] * D.67024;
  double D.67023;
  double D.67022;
  double[4096] * D.67021;
  long unsigned int D.67020;
  long unsigned int D.67019;

  i = 0;
  goto <D.66146>;
  <D.66145>:
  j = 0;
  goto <D.66144>;
  <D.66143>:
  D.67019 = (long unsigned int) i;
  D.67020 = D.67019 * 32768;
  D.67021 = C + D.67020;
  D.67019 = (long unsigned int) i;
  D.67020 = D.67019 * 32768;
  D.67021 = C + D.67020;
  D.67022 = *D.67021[j];
  D.67023 = D.67022 * beta;
  *D.67021[j] = D.67023;
  k = 0;
  goto <D.66142>;
  <D.66141>:
  D.67019 = (long unsigned int) i;
  D.67020 = D.67019 * 32768;
  D.67021 = C + D.67020;
  D.67019 = (long unsigned int) i;
  D.67020 = D.67019 * 32768;
  D.67021 = C + D.67020;
  D.67022 = *D.67021[j];
  D.67019 = (long unsigned int) i;
  D.67020 = D.67019 * 32768;
  D.67024 = A + D.67020;
  D.67025 = *D.67024[k];
  D.67026 = D.67025 * alpha;
  D.67027 = (long unsigned int) k;
  D.67028 = D.67027 * 32768;
  D.67029 = B + D.67028;
  D.67030 = *D.67029[j];
  D.67031 = D.67026 * D.67030;
  D.67032 = D.67022 + D.67031;
  *D.67021[j] = D.67032;
  k = k + 1;
  <D.66142>:
  if (k < nk) goto <D.66141>; else goto <D.66139>;
  <D.66139>:
  j = j + 1;
  <D.66144>:
  if (j < nj) goto <D.66143>; else goto <D.66137>;
  <D.66137>:
  i = i + 1;
  <D.66146>:
  if (i < ni) goto <D.66145>; else goto <D.66135>;
  <D.66135>:
  return;
}



;; Function void gemm_original(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z13gemm_originaliiiddPA4096_dS0_S0_, funcdef_no=3213, decl_uid=66155, cgraph_uid=3035)

void gemm_original(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  hookomp_timing_start (&seq_start);
  gemm (ni, nj, nk, alpha, beta, A, B, C);
  hookomp_timing_stop (&seq_stop);
  return;
}



;; Function void gemm_omp_kernel(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_, funcdef_no=3214, decl_uid=66165, cgraph_uid=3036)

void gemm_omp_kernel(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int k;
  int j;
  int i;
  int D.67092;
  int k;
  int j;
  int i;
  struct .omp_data_s.41 .omp_data_o.42;
  int D.67091;
  int D.67090;
  double[4096] * D.67089;
  double D.67088;
  double[4096] * D.67087;
  double[4096] * D.67086;
  double[4096] * D.67085;
  double D.67084;
  double[4096] * D.67083;
  double[4096] * D.67082;

  .omp_data_o.42.alpha = alpha;
  .omp_data_o.42.beta = beta;
  .omp_data_o.42.A = A;
  .omp_data_o.42.B = B;
  .omp_data_o.42.C = C;
  .omp_data_o.42.ni = ni;
  .omp_data_o.42.nj = nj;
  .omp_data_o.42.nk = nk;
  #pragma omp parallel num_threads(8) shared(C) shared(B) shared(A) shared(beta) shared(alpha) shared(nk) shared(nj) shared(ni) [child fn: _Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0 (.omp_data_o.42)]
  .omp_data_i = &.omp_data_o.42;
  current_loop_index = 0;
  num_threads_defined = 8;
  D.67033 = 16;
  D.67034 = D.67033 + 8;
  D.67035 = D.67034 * 16777216;
  q_data_transfer_write.39 = (long long int) D.67035;
  q_data_transfer_write = q_data_transfer_write.39;
  D.67037 = 134217728;
  q_data_transfer_read.40 = (long long int) D.67037;
  q_data_transfer_read = q_data_transfer_read.40;
  type_of_data_allocation = 1;
  D.67092 = .omp_data_i->ni;
  #pragma omp for schedule(dynamic,64) private(k) private(j) private(i)
  for (i = 0; i < D.67092; i = i + 1)
  j = 0;
  goto <D.67076>;
  <D.67077>:
  D.67039 = (long unsigned int) i;
  D.67040 = D.67039 * 32768;
  D.67082 = .omp_data_i->C;
  D.67041 = D.67082 + D.67040;
  D.67039 = (long unsigned int) i;
  D.67040 = D.67039 * 32768;
  D.67083 = .omp_data_i->C;
  D.67041 = D.67083 + D.67040;
  D.67042 = *D.67041[j];
  D.67084 = .omp_data_i->beta;
  D.67043 = D.67042 * D.67084;
  *D.67041[j] = D.67043;
  k = 0;
  goto <D.67078>;
  <D.67079>:
  D.67039 = (long unsigned int) i;
  D.67040 = D.67039 * 32768;
  D.67085 = .omp_data_i->C;
  D.67041 = D.67085 + D.67040;
  D.67039 = (long unsigned int) i;
  D.67040 = D.67039 * 32768;
  D.67086 = .omp_data_i->C;
  D.67041 = D.67086 + D.67040;
  D.67042 = *D.67041[j];
  D.67039 = (long unsigned int) i;
  D.67040 = D.67039 * 32768;
  D.67087 = .omp_data_i->A;
  D.67044 = D.67087 + D.67040;
  D.67045 = *D.67044[k];
  D.67088 = .omp_data_i->alpha;
  D.67046 = D.67045 * D.67088;
  D.67047 = (long unsigned int) k;
  D.67048 = D.67047 * 32768;
  D.67089 = .omp_data_i->B;
  D.67049 = D.67089 + D.67048;
  D.67050 = *D.67049[j];
  D.67051 = D.67046 * D.67050;
  D.67052 = D.67042 + D.67051;
  *D.67041[j] = D.67052;
  k = k + 1;
  <D.67078>:
  D.67090 = .omp_data_i->nk;
  if (k < D.67090) goto <D.67079>; else goto <D.67080>;
  <D.67080>:
  j = j + 1;
  <D.67076>:
  D.67091 = .omp_data_i->nj;
  if (j < D.67091) goto <D.67077>; else goto <D.67081>;
  <D.67081>:
  #pragma omp continue (i, i)
  #pragma omp return
  #pragma omp return
  alpha = .omp_data_o.42.alpha;
  beta = .omp_data_o.42.beta;
  A = .omp_data_o.42.A;
  B = .omp_data_o.42.B;
  C = .omp_data_o.42.C;
  ni = .omp_data_o.42.ni;
  nj = .omp_data_o.42.nj;
  nk = .omp_data_o.42.nk;
  return;
}



;; Function void gemm_omp(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z8gemm_ompiiiddPA4096_dS0_S0_, funcdef_no=3215, decl_uid=66187, cgraph_uid=3037)

void gemm_omp(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C_outputFromOMP)
{
  hookomp_timing_start (&omp_start);
  gemm_omp_kernel (ni, nj, nk, alpha, beta, A, B, C_outputFromOMP);
  hookomp_timing_stop (&omp_stop);
  return;
}



;; Function void GPU_argv_init() (_Z13GPU_argv_initv, funcdef_no=3216, decl_uid=66189, cgraph_uid=3038)

void GPU_argv_init() ()
{
  struct cudaDeviceProp deviceProp;
  struct _IO_FILE * stderr.43;

  stderr.43 = stderr;
  __builtin_fwrite ("GPU init.\n", 1, 10, stderr.43);
  cudaGetDeviceProperties (&deviceProp, 0);
  stderr.43 = stderr;
  fprintf (stderr.43, "setting device %d with name %s\n", 0, &deviceProp.name);
  cudaSetDevice (0);
  deviceProp = {CLOBBER};
  return;
  <D.67095>:
  deviceProp = {CLOBBER};
  resx 1
}



;; Function void gemm_cuda(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096]) (_Z9gemm_cudaiiiddPA4096_dS0_S0_S0_S0_, funcdef_no=3217, decl_uid=66211, cgraph_uid=3039)

void gemm_cuda(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C, double[4096] * C_inputToGpu, double[4096] * C_outputFromGpu)
{
  cudaError D.67117;
  struct dim3 grid;
  struct dim3 block;
  double * C_gpu;
  double * B_gpu;
  double * A_gpu;
  cudaError D.67113;
  unsigned int D.67112;
  long unsigned int D.67111;
  float D.67110;
  float D.67109;
  float D.67108;
  unsigned int D.67107;
  unsigned int D.67106;
  long unsigned int D.67105;
  float D.67104;
  float D.67103;
  float D.67102;
  unsigned int D.67101;
  double * C_gpu.47;
  double * B_gpu.46;
  double * A_gpu.45;
  long unsigned int D.67097;
  struct _IO_FILE * stderr.44;

  stderr.44 = stderr;
  __builtin_fwrite ("Calling function gemm_cuda.\n", 1, 28, stderr.44);
  GPU_argv_init ();
  D.67097 = 134217728;
  cudaMalloc (&A_gpu, D.67097);
  D.67097 = 134217728;
  cudaMalloc (&B_gpu, D.67097);
  D.67097 = 134217728;
  cudaMalloc (&C_gpu, D.67097);
  hookomp_timing_start (&data_transfer_h2d_start);
  D.67097 = 134217728;
  A_gpu.45 = A_gpu;
  cudaMemcpy (A_gpu.45, A, D.67097, 1);
  D.67097 = 134217728;
  B_gpu.46 = B_gpu;
  cudaMemcpy (B_gpu.46, B, D.67097, 1);
  D.67097 = 134217728;
  C_gpu.47 = C_gpu;
  cudaMemcpy (C_gpu.47, C_inputToGpu, D.67097, 1);
  hookomp_timing_stop (&data_transfer_h2d_stop);
  dim3::dim3 (&block, 32, 8, 1);
  D.67101 = block.y;
  D.67102 = (float) D.67101;
  D.67103 = 4.096e+3 / D.67102;
  D.67104 = std::ceil (D.67103);
  D.67105 = (long unsigned int) D.67104;
  D.67106 = (unsigned int) D.67105;
  D.67107 = block.x;
  D.67108 = (float) D.67107;
  D.67109 = 4.096e+3 / D.67108;
  D.67110 = std::ceil (D.67109);
  D.67111 = (long unsigned int) D.67110;
  D.67112 = (unsigned int) D.67111;
  dim3::dim3 (&grid, D.67112, D.67106, 1);
  hookomp_timing_start (&dev_kernel1_start);
  D.67117 = cudaConfigureCall (grid, block, 0, 0B);
  D.67113 = D.67117;
  if (D.67113 == 0) goto <D.67114>; else goto <D.67115>;
  <D.67114>:
  C_gpu.47 = C_gpu;
  B_gpu.46 = B_gpu;
  A_gpu.45 = A_gpu;
  gemm_cuda_kernel (ni, nj, nk, alpha, beta, A_gpu.45, B_gpu.46, C_gpu.47);
  goto <D.67116>;
  <D.67115>:
  <D.67116>:
  cudaThreadSynchronize ();
  hookomp_timing_stop (&dev_kernel1_stop);
  hookomp_timing_start (&data_transfer_d2h_start);
  D.67097 = 134217728;
  C_gpu.47 = C_gpu;
  cudaMemcpy (C_outputFromGpu, C_gpu.47, D.67097, 2);
  hookomp_timing_stop (&data_transfer_d2h_stop);
  A_gpu.45 = A_gpu;
  cudaFree (A_gpu.45);
  B_gpu.46 = B_gpu;
  cudaFree (B_gpu.46);
  C_gpu.47 = C_gpu;
  cudaFree (C_gpu.47);
  A_gpu = {CLOBBER};
  B_gpu = {CLOBBER};
  C_gpu = {CLOBBER};
  block = {CLOBBER};
  grid = {CLOBBER};
  return;
  <D.67118>:
  A_gpu = {CLOBBER};
  B_gpu = {CLOBBER};
  C_gpu = {CLOBBER};
  block = {CLOBBER};
  grid = {CLOBBER};
  resx 1
}



;; Function float std::ceil(float) (_ZSt4ceilf, funcdef_no=139, decl_uid=8558, cgraph_uid=131)

float std::ceil(float) (float __x)
{
  float D.67119;

  D.67119 = __builtin_ceilf (__x);
  goto <D.67120>;
  <D.67120>:
  return D.67119;
}



;; Function dim3::dim3(unsigned int, unsigned int, unsigned int) (_ZN4dim3C2Ejjj, funcdef_no=3, decl_uid=3003, cgraph_uid=3)

dim3::dim3(unsigned int, unsigned int, unsigned int) (struct dim3 * const this, unsigned int vx, unsigned int vy, unsigned int vz)
{
  this->x = vx;
  this->y = vy;
  this->z = vz;
  return;
}



;; Function int main(int, char**) (main, funcdef_no=3218, decl_uid=66234, cgraph_uid=3040)

int main(int, char**) (int argc, char * * argv)
{
  bool D.67193;
  void * D.67192;
  void * D.67191;
  double[4096][4096] * D.67190;
  void * D.67189;
  void * D.67188;
  void * D.67187;
  static const char __PRETTY_FUNCTION__[22] = "int main(int, char**)";
  int ndevices;
  int nloops;
  struct Func * ff_0;
  int n_params;
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
  int D.67185;
  unsigned char D.67181;
  char * D.67180;
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
  struct Func * * * TablePointerFunctions.56;
  struct Func * D.67163;
  struct Func * * D.67162;
  struct Func * * D.67161;
  struct Func * * * table.55;
  bool retval.54;
  struct ffi_type * * D.67154;
  struct ffi_type * * D.67153;
  struct ffi_type * * D.67152;
  struct ffi_type * * D.67151;
  struct ffi_type * * D.67150;
  struct ffi_type * * D.67149;
  struct ffi_type * * D.67148;
  struct ffi_type * * D.67147;
  struct ffi_type * * D.67146;
  struct ffi_type * * D.67145;
  struct ffi_type * * D.67144;
  void * * D.67143;
  void * * D.67142;
  void * * D.67141;
  void * * D.67140;
  void * * D.67139;
  void * * D.67138;
  void * * D.67137;
  void * * D.67136;
  void * * D.67135;
  void * * D.67134;
  void * * D.67133;
  void * * D.67132;
  void * D.67131;
  void * D.67130;
  long unsigned int D.67129;
  long unsigned int D.67128;
  int D.67127;
  struct _IO_FILE * stderr.53;
  void * C_outputFromGpu.52;
  void * C_inputToGpu.51;
  void * C.50;
  void * B.49;
  void * A.48;

  ni = 4096;
  nj = 4096;
  nk = 4096;
  D.67187 = polybench_alloc_data (16777216, 8);
  A.48 = D.67187;
  A = A.48;
  D.67188 = polybench_alloc_data (16777216, 8);
  B.49 = D.67188;
  B = B.49;
  D.67189 = polybench_alloc_data (16777216, 8);
  C.50 = D.67189;
  C = C.50;
  D.67190 = polybench_alloc_data (16777216, 8);
  C_outputFromOMP = D.67190;
  D.67191 = polybench_alloc_data (16777216, 8);
  C_inputToGpu.51 = D.67191;
  C_inputToGpu = C_inputToGpu.51;
  D.67192 = polybench_alloc_data (16777216, 8);
  C_outputFromGpu.52 = D.67192;
  C_outputFromGpu = C_outputFromGpu.52;
  stderr.53 = stderr;
  __builtin_fwrite ("Preparing alternatives functions.\n", 1, 34, stderr.53);
  n_params = 10;
  ff_0 = malloc (48);
  D.67127 = n_params + 1;
  D.67128 = (long unsigned int) D.67127;
  D.67129 = D.67128 * 8;
  D.67130 = malloc (D.67129);
  ff_0->arg_types = D.67130;
  D.67127 = n_params + 1;
  D.67128 = (long unsigned int) D.67127;
  D.67129 = D.67128 * 8;
  D.67131 = malloc (D.67129);
  ff_0->arg_values = D.67131;
  ff_0->f = gemm_cuda;
  D.67132 = &ff_0->ret_value;
  memset (D.67132, 0, 8);
  ff_0->ret_type = &ffi_type_void;
  ff_0->nargs = n_params;
  D.67133 = ff_0->arg_values;
  *D.67133 = &ni;
  D.67133 = ff_0->arg_values;
  D.67134 = D.67133 + 8;
  *D.67134 = &nj;
  D.67133 = ff_0->arg_values;
  D.67135 = D.67133 + 16;
  *D.67135 = &nk;
  D.67133 = ff_0->arg_values;
  D.67136 = D.67133 + 24;
  *D.67136 = &alpha;
  D.67133 = ff_0->arg_values;
  D.67137 = D.67133 + 32;
  *D.67137 = &beta;
  D.67133 = ff_0->arg_values;
  D.67138 = D.67133 + 40;
  *D.67138 = &A;
  D.67133 = ff_0->arg_values;
  D.67139 = D.67133 + 48;
  *D.67139 = &B;
  D.67133 = ff_0->arg_values;
  D.67140 = D.67133 + 56;
  *D.67140 = &C;
  D.67133 = ff_0->arg_values;
  D.67141 = D.67133 + 64;
  *D.67141 = &C_inputToGpu;
  D.67133 = ff_0->arg_values;
  D.67142 = D.67133 + 72;
  *D.67142 = &C_outputFromGpu;
  D.67133 = ff_0->arg_values;
  D.67143 = D.67133 + 80;
  *D.67143 = 0B;
  D.67144 = ff_0->arg_types;
  *D.67144 = &ffi_type_sint32;
  D.67144 = ff_0->arg_types;
  D.67145 = D.67144 + 8;
  *D.67145 = &ffi_type_sint32;
  D.67144 = ff_0->arg_types;
  D.67146 = D.67144 + 16;
  *D.67146 = &ffi_type_sint32;
  D.67144 = ff_0->arg_types;
  D.67147 = D.67144 + 24;
  *D.67147 = &ffi_type_double;
  D.67144 = ff_0->arg_types;
  D.67148 = D.67144 + 32;
  *D.67148 = &ffi_type_double;
  D.67144 = ff_0->arg_types;
  D.67149 = D.67144 + 40;
  *D.67149 = &ffi_type_pointer;
  D.67144 = ff_0->arg_types;
  D.67150 = D.67144 + 48;
  *D.67150 = &ffi_type_pointer;
  D.67144 = ff_0->arg_types;
  D.67151 = D.67144 + 56;
  *D.67151 = &ffi_type_pointer;
  D.67144 = ff_0->arg_types;
  D.67152 = D.67144 + 64;
  *D.67152 = &ffi_type_pointer;
  D.67144 = ff_0->arg_types;
  D.67153 = D.67144 + 72;
  *D.67153 = &ffi_type_pointer;
  D.67144 = ff_0->arg_types;
  D.67154 = D.67144 + 80;
  *D.67154 = 0B;
  stderr.53 = stderr;
  __builtin_fwrite ("Creating table of target functions.\n", 1, 36, stderr.53);
  nloops = 1;
  ndevices = 2;
  D.67193 = create_target_functions_table (&table, nloops, ndevices);
  retval.54 = D.67193;
  if (retval.54 != 0) goto <D.67156>; else goto <D.67157>;
  <D.67156>:
  table.55 = table;
  if (table.55 == 0B) goto <D.67159>; else goto <D.67160>;
  <D.67159>:
  __assert_fail ("table != __null", "gemm.cu", 402, &__PRETTY_FUNCTION__);
  <D.67160>:
  stderr.53 = stderr;
  __builtin_fwrite ("Declaring function in 0,1.\n", 1, 27, stderr.53);
  table.55 = table;
  D.67161 = *table.55;
  D.67162 = D.67161 + 8;
  D.67163 = *D.67162;
  *D.67163 = MEM[(const struct Func &)ff_0];
  table.55 = table;
  TablePointerFunctions = table.55;
  TablePointerFunctions.56 = TablePointerFunctions;
  if (TablePointerFunctions.56 == 0B) goto <D.67165>; else goto <D.67166>;
  <D.67165>:
  __assert_fail ("TablePointerFunctions != __null", "gemm.cu", 408, &__PRETTY_FUNCTION__);
  <D.67166>:
  goto <D.67167>;
  <D.67157>:
  <D.67167>:
  stderr.53 = stderr;
  __builtin_fwrite ("Calling init_array.\n", 1, 20, stderr.53);
  C.57 = C;
  B.58 = B;
  A.59 = A;
  nk.60 = nk;
  nj.61 = nj;
  ni.62 = ni;
  init_array (ni.62, nj.61, nk.60, &alpha, &beta, A.59, B.58, C.57);
  C.57 = C;
  nj.61 = nj;
  ni.62 = ni;
  copy_array (ni.62, nj.61, C.57, C_outputFromOMP);
  C_outputFromGpu.63 = C_outputFromGpu;
  C.57 = C;
  nj.61 = nj;
  ni.62 = ni;
  copy_array (ni.62, nj.61, C.57, C_outputFromGpu.63);
  stderr.53 = stderr;
  __builtin_fwrite ("Calling gemm_omp:\n", 1, 18, stderr.53);
  B.58 = B;
  A.59 = A;
  beta.64 = beta;
  alpha.65 = alpha;
  nk.60 = nk;
  nj.61 = nj;
  ni.62 = ni;
  gemm_omp (ni.62, nj.61, nk.60, alpha.65, beta.64, A.59, B.58, C_outputFromOMP);
  stdout.66 = stdout;
  fprintf (stdout.66, "version = OMP+OFF, num_threads = %d, NI = %d, NJ = %d, NK = %d, ", 8, 4096, 4096, 4096);
  hookomp_print_time_results ();
  stderr.53 = stderr;
  __builtin_fwrite ("Calling compareResults(original, omp).\n", 1, 39, stderr.53);
  C.57 = C;
  nj.61 = nj;
  ni.62 = ni;
  compareResults (ni.62, nj.61, C.57, C_outputFromOMP);
  stderr.53 = stderr;
  __builtin_fwrite ("Calling compareResults(original, cuda).\n", 1, 40, stderr.53);
  C_outputFromGpu.63 = C_outputFromGpu;
  C.57 = C;
  nj.61 = nj;
  ni.62 = ni;
  compareResults (ni.62, nj.61, C.57, C_outputFromGpu.63);
  if (argc > 42) goto <D.67178>; else goto <D.67179>;
  <D.67178>:
  D.67180 = *argv;
  D.67181 = MEM[(const unsigned char * {ref-all})D.67180];
  if (D.67181 == 0) goto <D.67182>; else goto <D.67183>;
  <D.67182>:
  C_outputFromGpu.63 = C_outputFromGpu;
  nj.61 = nj;
  ni.62 = ni;
  print_array (ni.62, nj.61, C_outputFromGpu.63);
  goto <D.67184>;
  <D.67183>:
  <D.67184>:
  <D.67179>:
  A.59 = A;
  free (A.59);
  B.58 = B;
  free (B.58);
  C.57 = C;
  free (C.57);
  free (C_outputFromOMP);
  C_outputFromGpu.63 = C_outputFromGpu;
  free (C_outputFromGpu.63);
  D.67185 = 0;
  goto <D.67195>;
  <D.67195>:
  ni = {CLOBBER};
  nj = {CLOBBER};
  nk = {CLOBBER};
  alpha = {CLOBBER};
  beta = {CLOBBER};
  A = {CLOBBER};
  B = {CLOBBER};
  C = {CLOBBER};
  C_inputToGpu = {CLOBBER};
  C_outputFromGpu = {CLOBBER};
  goto <D.67186>;
  D.67185 = 0;
  goto <D.67186>;
  <D.67186>:
  return D.67185;
  <D.67194>:
  ni = {CLOBBER};
  nj = {CLOBBER};
  nk = {CLOBBER};
  alpha = {CLOBBER};
  beta = {CLOBBER};
  A = {CLOBBER};
  B = {CLOBBER};
  C = {CLOBBER};
  C_inputToGpu = {CLOBBER};
  C_outputFromGpu = {CLOBBER};
  resx 1
}



;; Function void print_array(int, int, double (*)[4096]) (_ZL11print_arrayiiPA4096_d, funcdef_no=3211, decl_uid=66110, cgraph_uid=3033)

void print_array(int, int, double (*)[4096]) (int ni, int nj, double[4096] * C)
{
  int j;
  int i;
  int D.67203;
  int D.67202;
  int D.67201;
  struct _IO_FILE * stderr.67;
  double D.67199;
  double[4096] * D.67198;
  long unsigned int D.67197;
  long unsigned int D.67196;

  i = 0;
  goto <D.66121>;
  <D.66120>:
  j = 0;
  goto <D.66119>;
  <D.66118>:
  D.67196 = (long unsigned int) i;
  D.67197 = D.67196 * 32768;
  D.67198 = C + D.67197;
  D.67199 = *D.67198[j];
  stderr.67 = stderr;
  fprintf (stderr.67, "%0.2lf ", D.67199);
  D.67201 = i * ni;
  D.67202 = D.67201 + j;
  D.67203 = D.67202 % 20;
  if (D.67203 == 0) goto <D.67204>; else goto <D.67205>;
  <D.67204>:
  stderr.67 = stderr;
  __builtin_fputc (10, stderr.67);
  goto <D.67206>;
  <D.67205>:
  <D.67206>:
  j = j + 1;
  <D.66119>:
  if (j < nj) goto <D.66118>; else goto <D.66116>;
  <D.66116>:
  i = i + 1;
  <D.66121>:
  if (i < ni) goto <D.66120>; else goto <D.66114>;
  <D.66114>:
  stderr.67 = stderr;
  __builtin_fputc (10, stderr.67);
  return;
}



;; Function void polybench_flush_cache() (_Z21polybench_flush_cachev, funcdef_no=3220, decl_uid=66470, cgraph_uid=3042)

void polybench_flush_cache() ()
{
  static const char __PRETTY_FUNCTION__[29] = "void polybench_flush_cache()";
  double tmp;
  int i;
  double * flush;
  int cs;
  double D.67212;
  double * D.67211;
  long unsigned int D.67210;
  long unsigned int D.67209;
  long unsigned int D.67208;
  long unsigned int D.67207;

  D.67207 = 4194560;
  cs = (int) D.67207;
  D.67208 = (long unsigned int) cs;
  flush = calloc (D.67208, 8);
  tmp = 0.0;
  i = 0;
  goto <D.66480>;
  <D.66479>:
  D.67209 = (long unsigned int) i;
  D.67210 = D.67209 * 8;
  D.67211 = flush + D.67210;
  D.67212 = *D.67211;
  tmp = D.67212 + tmp;
  i = i + 1;
  <D.66480>:
  if (i < cs) goto <D.66479>; else goto <D.66477>;
  <D.66477>:
  if (tmp <= 1.0e+1) goto <D.67213>; else goto <D.67214>;
  <D.67213>:
  goto <D.67215>;
  <D.67214>:
  __assert_fail ("tmp <= 10.0", "../../../utilities/polybench.c", 96, &__PRETTY_FUNCTION__);
  <D.67215>:
  free (flush);
  return;
}



;; Function void polybench_prepare_instruments() (_Z29polybench_prepare_instrumentsv, funcdef_no=3221, decl_uid=66481, cgraph_uid=3043)

void polybench_prepare_instruments() ()
{
  polybench_flush_cache ();
  return;
}



;; Function void polybench_timer_start() (_Z21polybench_timer_startv, funcdef_no=3222, decl_uid=65328, cgraph_uid=3044)

void polybench_timer_start() ()
{
  double D.67217;
  double polybench_t_start.68;

  polybench_prepare_instruments ();
  D.67217 = rtclock ();
  polybench_t_start.68 = D.67217;
  polybench_t_start = polybench_t_start.68;
  return;
}



;; Function double rtclock() (_ZL7rtclockv, funcdef_no=3219, decl_uid=66466, cgraph_uid=3041)

double rtclock() ()
{
  int stat;
  struct timeval Tp;
  double D.67226;
  double D.67225;
  long int D.67224;
  double D.67223;
  long int D.67222;
  double D.67221;

  stat = gettimeofday (&Tp, 0B);
  if (stat != 0) goto <D.67218>; else goto <D.67219>;
  <D.67218>:
  printf ("Error return from gettimeofday: %d", stat);
  goto <D.67220>;
  <D.67219>:
  <D.67220>:
  D.67222 = Tp.tv_sec;
  D.67223 = (double) D.67222;
  D.67224 = Tp.tv_usec;
  D.67225 = (double) D.67224;
  D.67226 = D.67225 * 9.99999999999999954748111825886258685613938723690807819366e-7;
  D.67221 = D.67223 + D.67226;
  goto <D.67229>;
  <D.67229>:
  Tp = {CLOBBER};
  goto <D.67227>;
  <D.67227>:
  return D.67221;
  <D.67228>:
  Tp = {CLOBBER};
  resx 1
}



;; Function void polybench_timer_stop() (_Z20polybench_timer_stopv, funcdef_no=3223, decl_uid=65329, cgraph_uid=3045)

void polybench_timer_stop() ()
{
  double D.67231;
  double polybench_t_end.69;

  D.67231 = rtclock ();
  polybench_t_end.69 = D.67231;
  polybench_t_end = polybench_t_end.69;
  return;
}



;; Function void polybench_timer_print() (_Z21polybench_timer_printv, funcdef_no=3224, decl_uid=65330, cgraph_uid=3046)

void polybench_timer_print() ()
{
  double D.67234;
  double polybench_t_start.71;
  double polybench_t_end.70;

  polybench_t_end.70 = polybench_t_end;
  polybench_t_start.71 = polybench_t_start;
  D.67234 = polybench_t_end.70 - polybench_t_start.71;
  printf ("%0.6f\n", D.67234);
  return;
}



;; Function void* polybench_alloc_data(long long unsigned int, int) (_Z20polybench_alloc_datayi, funcdef_no=3226, decl_uid=65336, cgraph_uid=3048)

void* polybench_alloc_data(long long unsigned int, int) (long long unsigned int n, int elt_size)
{
  void * D.67238;
  void * ret;
  size_t val;
  void * D.67236;
  long unsigned int D.67235;

  val = n;
  D.67235 = (long unsigned int) elt_size;
  val = D.67235 * val;
  D.67238 = xmalloc (val);
  ret = D.67238;
  D.67236 = ret;
  goto <D.67237>;
  <D.67237>:
  return D.67236;
}



;; Function void* xmalloc(size_t) (_ZL7xmallocm, funcdef_no=3225, decl_uid=66490, cgraph_uid=3047)

void* xmalloc(size_t) (size_t num)
{
  int ret;
  void * newA;
  void * D.67244;
  struct _IO_FILE * stderr.73;
  void * newA.72;

  newA = 0B;
  ret = posix_memalign (&newA, 32, num);
  newA.72 = newA;
  if (newA.72 == 0B) goto <D.67239>; else goto <D.67242>;
  <D.67242>:
  if (ret != 0) goto <D.67239>; else goto <D.67240>;
  <D.67239>:
  stderr.73 = stderr;
  __builtin_fwrite ("[PolyBench] posix_memalign: cannot allocate memory", 1, 50, stderr.73);
  exit (1);
  <D.67240>:
  D.67244 = newA;
  goto <D.67247>;
  <D.67247>:
  newA = {CLOBBER};
  goto <D.67245>;
  <D.67245>:
  return D.67244;
  <D.67246>:
  newA = {CLOBBER};
  resx 1
}



;; Function void __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_(int, int, int, double, double, double*, double*, double*) (_Z45__device_stub__Z16gemm_cuda_kerneliiiddPdS_S_iiiddPdS_S_, funcdef_no=3251, decl_uid=66803, cgraph_uid=3072)

void __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_(int, int, int, double, double, double*, double*, double*) (int __par0, int __par1, int __par2, double __par3, double __par4, double * __par5, double * __par6, double * __par7)
{
  cudaError D.67288;
  cudaError D.67287;
  cudaError D.67286;
  cudaError D.67285;
  cudaError D.67284;
  cudaError D.67283;
  cudaError D.67282;
  cudaError D.67281;
  static volatile char * __f;
  cudaError D.67277;
  bool retval.81;
  cudaError D.67273;
  bool retval.80;
  cudaError D.67269;
  bool retval.79;
  cudaError D.67265;
  bool retval.78;
  cudaError D.67261;
  bool retval.77;
  cudaError D.67257;
  bool retval.76;
  cudaError D.67253;
  bool retval.75;
  cudaError D.67249;
  bool retval.74;

  D.67281 = cudaSetupArgument (&__par0, 4, 0);
  D.67249 = D.67281;
  retval.74 = D.67249 != 0;
  if (retval.74 != 0) goto <D.67250>; else goto <D.67251>;
  <D.67250>:
  goto <D.67280>;
  <D.67251>:
  D.67282 = cudaSetupArgument (&__par1, 4, 4);
  D.67253 = D.67282;
  retval.75 = D.67253 != 0;
  if (retval.75 != 0) goto <D.67254>; else goto <D.67255>;
  <D.67254>:
  goto <D.67280>;
  <D.67255>:
  D.67283 = cudaSetupArgument (&__par2, 4, 8);
  D.67257 = D.67283;
  retval.76 = D.67257 != 0;
  if (retval.76 != 0) goto <D.67258>; else goto <D.67259>;
  <D.67258>:
  goto <D.67280>;
  <D.67259>:
  D.67284 = cudaSetupArgument (&__par3, 8, 16);
  D.67261 = D.67284;
  retval.77 = D.67261 != 0;
  if (retval.77 != 0) goto <D.67262>; else goto <D.67263>;
  <D.67262>:
  goto <D.67280>;
  <D.67263>:
  D.67285 = cudaSetupArgument (&__par4, 8, 24);
  D.67265 = D.67285;
  retval.78 = D.67265 != 0;
  if (retval.78 != 0) goto <D.67266>; else goto <D.67267>;
  <D.67266>:
  goto <D.67280>;
  <D.67267>:
  D.67286 = cudaSetupArgument (&__par5, 8, 32);
  D.67269 = D.67286;
  retval.79 = D.67269 != 0;
  if (retval.79 != 0) goto <D.67270>; else goto <D.67271>;
  <D.67270>:
  goto <D.67280>;
  <D.67271>:
  D.67287 = cudaSetupArgument (&__par6, 8, 40);
  D.67273 = D.67287;
  retval.80 = D.67273 != 0;
  if (retval.80 != 0) goto <D.67274>; else goto <D.67275>;
  <D.67274>:
  goto <D.67280>;
  <D.67275>:
  D.67288 = cudaSetupArgument (&__par7, 8, 48);
  D.67277 = D.67288;
  retval.81 = D.67277 != 0;
  if (retval.81 != 0) goto <D.67278>; else goto <D.67279>;
  <D.67278>:
  goto <D.67280>;
  <D.67279>:
  __f = gemm_cuda_kernel;
  cudaLaunch<char> (gemm_cuda_kernel);
  <D.67280>:
  return;
}



;; Function cudaError_t cudaLaunch(T*) [with T = char; cudaError_t = cudaError] (_Z10cudaLaunchIcE9cudaErrorPT_, funcdef_no=3255, decl_uid=66834, cgraph_uid=3076)

cudaError_t cudaLaunch(T*) [with T = char; cudaError_t = cudaError] (char * func)
{
  cudaError_t D.67291;
  cudaError_t D.67289;

  D.67291 = cudaLaunch (func);
  D.67289 = D.67291;
  goto <D.67290>;
  <D.67290>:
  return D.67289;
}



;; Function void gemm_cuda_kernel(int, int, int, double, double, double*, double*, double*) (_Z16gemm_cuda_kerneliiiddPdS_S_, funcdef_no=3252, decl_uid=66200, cgraph_uid=3073)

void gemm_cuda_kernel(int, int, int, double, double, double*, double*, double*) (int __cuda_0, int __cuda_1, int __cuda_2, double __cuda_3, double __cuda_4, double * __cuda_5, double * __cuda_6, double * __cuda_7)
{
  __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_ (__cuda_0, __cuda_1, __cuda_2, __cuda_3, __cuda_4, __cuda_5, __cuda_6, __cuda_7);
  return;
}



;; Function void __sti____cudaRegisterAll_39_tmpxft_000005b1_00000000_7_gemm_cpp1_ii_132e4611() (_ZL76__sti____cudaRegisterAll_39_tmpxft_000005b1_00000000_7_gemm_cpp1_ii_132e4611v, funcdef_no=3254, decl_uid=66806, cgraph_uid=3075)

void __sti____cudaRegisterAll_39_tmpxft_000005b1_00000000_7_gemm_cpp1_ii_132e4611() ()
{
  void * * D.67294;
  void (*<T73ba>) (void * *) callback_fp;
  void * * __cudaFatCubinHandle.83;
  void * * __cudaFatCubinHandle.82;

  D.67294 = __cudaRegisterFatBinary (&__fatDeviceText);
  __cudaFatCubinHandle.82 = D.67294;
  __cudaFatCubinHandle = __cudaFatCubinHandle.82;
  callback_fp = __nv_cudaEntityRegisterCallback;
  __cudaFatCubinHandle.83 = __cudaFatCubinHandle;
  callback_fp (__cudaFatCubinHandle.83);
  atexit (__cudaUnregisterBinaryUtil);
  return;
}



;; Function void __cudaUnregisterBinaryUtil() (_ZL26__cudaUnregisterBinaryUtilv, funcdef_no=3229, decl_uid=66570, cgraph_uid=3050)

void __cudaUnregisterBinaryUtil() ()
{
  void * * __cudaFatCubinHandle.84;

  ____nv_dummy_param_ref (&__cudaFatCubinHandle);
  __cudaFatCubinHandle.84 = __cudaFatCubinHandle;
  __cudaUnregisterFatBinary (__cudaFatCubinHandle.84);
  return;
}



;; Function void ____nv_dummy_param_ref(void*) (_ZL22____nv_dummy_param_refPv, funcdef_no=3228, decl_uid=66506, cgraph_uid=3049)

void ____nv_dummy_param_ref(void*) (void * param)
{
  static volatile void * * __ref;

  __ref = param;
  return;
}



;; Function void __nv_cudaEntityRegisterCallback(void**) (_ZL31__nv_cudaEntityRegisterCallbackPPv, funcdef_no=3253, decl_uid=66805, cgraph_uid=3074)

void __nv_cudaEntityRegisterCallback(void**) (void * * __T26)
{
  static volatile void * * __ref;

  __ref = __T26;
  __nv_save_fatbinhandle_for_managed_rt (__T26);
  __cudaRegisterFunction (__T26, gemm_cuda_kernel, "_Z16gemm_cuda_kerneliiiddPdS_S_", "_Z16gemm_cuda_kerneliiiddPdS_S_", -1, 0B, 0B, 0B, 0B, 0B);
  return;
}



;; Function void __nv_save_fatbinhandle_for_managed_rt(void**) (_ZL37__nv_save_fatbinhandle_for_managed_rtPPv, funcdef_no=0, decl_uid=2204, cgraph_uid=0)

void __nv_save_fatbinhandle_for_managed_rt(void**) (void * * in)
{
  __nv_fatbinhandle_for_managed_rt = in;
  return;
}


