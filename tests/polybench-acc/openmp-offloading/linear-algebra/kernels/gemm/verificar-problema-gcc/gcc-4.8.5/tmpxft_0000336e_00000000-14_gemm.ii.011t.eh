
;; Function float absVal(float) (_Z6absValf, funcdef_no=3240, decl_uid=65923, cgraph_uid=3062)

float absVal(float) (float a)
{
  float D.67511;

  if (a < 0.0) goto <D.67509>; else goto <D.67510>;
  <D.67509>:
  D.67511 = -a;
  goto <D.67512>;
  <D.67510>:
  D.67511 = a;
  goto <D.67512>;
  <D.67512>:
  return D.67511;
}



;; Function float percentDiff(double, double) (_Z11percentDiffdd, funcdef_no=3241, decl_uid=65927, cgraph_uid=3063)

float percentDiff(double, double) (double val1, double val2)
{
  float D.67535;
  float D.67534;
  float D.67533;
  float D.67532;
  double D.67531;
  float D.67530;
  float D.67529;
  double D.67528;
  float D.67527;
  double D.67523;
  float D.67522;
  float D.67521;
  double D.67519;
  float D.67518;
  float D.67517;
  bool iftmp.1;
  bool retval.0;

  D.67517 = (float) val1;
  D.67518 = absVal (D.67517);
  D.67519 = (double) D.67518;
  if (D.67519 < 1.00000000000000002081668171172168513294309377670288085938e-2) goto <D.67520>; else goto <D.67515>;
  <D.67520>:
  D.67521 = (float) val2;
  D.67522 = absVal (D.67521);
  D.67523 = (double) D.67522;
  if (D.67523 < 1.00000000000000002081668171172168513294309377670288085938e-2) goto <D.67524>; else goto <D.67515>;
  <D.67524>:
  iftmp.1 = 1;
  goto <D.67516>;
  <D.67515>:
  iftmp.1 = 0;
  <D.67516>:
  retval.0 = iftmp.1;
  if (retval.0 != 0) goto <D.67525>; else goto <D.67526>;
  <D.67525>:
  D.67527 = 0.0;
  goto <D.67536>;
  <D.67526>:
  D.67528 = val1 - val2;
  D.67529 = (float) D.67528;
  D.67530 = absVal (D.67529);
  D.67531 = val1 + 9.99999993922529029077850282192230224609375e-9;
  D.67532 = (float) D.67531;
  D.67533 = absVal (D.67532);
  D.67534 = D.67530 / D.67533;
  D.67535 = absVal (D.67534);
  D.67527 = D.67535 * 1.0e+2;
  goto <D.67536>;
  <D.67536>:
  return D.67527;
}



;; Function uint64_t get_time() (_Z8get_timev, funcdef_no=3246, decl_uid=66101, cgraph_uid=3068)

uint64_t get_time() ()
{
  struct timespec spec;
  long unsigned int D.67542;
  long int D.67541;
  long unsigned int D.67540;
  long unsigned int D.67539;
  long int D.67538;
  uint64_t D.67537;

  clock_gettime (1, &spec);
  D.67538 = spec.tv_sec;
  D.67539 = (long unsigned int) D.67538;
  D.67540 = D.67539 * 1000000000;
  D.67541 = spec.tv_nsec;
  D.67542 = (long unsigned int) D.67541;
  D.67537 = D.67540 + D.67542;
  goto <D.67544>;
  <D.67544>:
  spec = {CLOBBER};
  goto <D.67543>;
  <D.67543>:
  return D.67537;
}



;; Function void hookomp_timing_start(uint64_t*) (_Z20hookomp_timing_startPm, funcdef_no=3247, decl_uid=66105, cgraph_uid=3069)

void hookomp_timing_start(uint64_t*) (uint64_t * _start)
{
  long unsigned int D.67545;

  D.67545 = get_time ();
  *_start = D.67545;
  return;
}



;; Function void hookomp_timing_stop(uint64_t*) (_Z19hookomp_timing_stopPm, funcdef_no=3248, decl_uid=66108, cgraph_uid=3070)

void hookomp_timing_stop(uint64_t*) (uint64_t * _stop)
{
  long unsigned int D.67546;

  D.67546 = get_time ();
  *_stop = D.67546;
  return;
}



;; Function void hookomp_timing_print(uint64_t, uint64_t) (_Z20hookomp_timing_printmm, funcdef_no=3249, decl_uid=66112, cgraph_uid=3071)

void hookomp_timing_print(uint64_t, uint64_t) (uint64_t tstart, uint64_t tstop)
{
  long unsigned int D.67547;

  D.67547 = tstop - tstart;
  printf ("%llu", D.67547);
  return;
}



;; Function int printf(const char*, ...) (<unset-asm-name>, funcdef_no=3213, decl_uid=1095, cgraph_uid=3035)

int printf(const char*, ...) (const char * restrict __fmt)
{
  int D.67550;
  int D.67548;

  D.67550 = __printf_chk (1, __fmt, __builtin_va_arg_pack ());
  D.67548 = D.67550;
  goto <D.67549>;
  <D.67549>:
  return D.67548;
}



;; Function void hookomp_timing_print_without_dev() (_Z32hookomp_timing_print_without_devv, funcdef_no=3250, decl_uid=66114, cgraph_uid=3072)

void hookomp_timing_print_without_dev() ()
{
  uint64_t dt_time;
  uint64_t dev_time;
  uint64_t total_time;
  long unsigned int D.67572;
  uint64_t iftmp.14;
  long unsigned int D.67568;
  long unsigned int data_transfer_d2h_start.13;
  long unsigned int data_transfer_d2h_stop.12;
  long unsigned int D.67565;
  long unsigned int data_transfer_h2d_start.11;
  long unsigned int data_transfer_h2d_stop.10;
  long unsigned int D.67562;
  long unsigned int dev_kernel3_start.9;
  long unsigned int dev_kernel3_stop.8;
  long unsigned int D.67559;
  long unsigned int D.67558;
  long unsigned int dev_kernel2_start.7;
  long unsigned int dev_kernel2_stop.6;
  long unsigned int D.67555;
  long unsigned int dev_kernel1_start.5;
  long unsigned int dev_kernel1_stop.4;
  long unsigned int omp_start.3;
  long unsigned int omp_stop.2;

  omp_stop.2 = omp_stop;
  omp_start.3 = omp_start;
  total_time = omp_stop.2 - omp_start.3;
  dev_kernel1_stop.4 = dev_kernel1_stop;
  dev_kernel1_start.5 = dev_kernel1_start;
  D.67555 = dev_kernel1_stop.4 - dev_kernel1_start.5;
  dev_kernel2_stop.6 = dev_kernel2_stop;
  dev_kernel2_start.7 = dev_kernel2_start;
  D.67558 = dev_kernel2_stop.6 - dev_kernel2_start.7;
  D.67559 = D.67555 + D.67558;
  dev_kernel3_stop.8 = dev_kernel3_stop;
  dev_kernel3_start.9 = dev_kernel3_start;
  D.67562 = dev_kernel3_stop.8 - dev_kernel3_start.9;
  dev_time = D.67559 + D.67562;
  data_transfer_h2d_stop.10 = data_transfer_h2d_stop;
  data_transfer_h2d_start.11 = data_transfer_h2d_start;
  D.67565 = data_transfer_h2d_stop.10 - data_transfer_h2d_start.11;
  data_transfer_d2h_stop.12 = data_transfer_d2h_stop;
  data_transfer_d2h_start.13 = data_transfer_d2h_start;
  D.67568 = data_transfer_d2h_stop.12 - data_transfer_d2h_start.13;
  dt_time = D.67565 + D.67568;
  if (total_time != 0) goto <D.67570>; else goto <D.67571>;
  <D.67570>:
  D.67572 = total_time - dev_time;
  iftmp.14 = D.67572 - dt_time;
  goto <D.67573>;
  <D.67571>:
  iftmp.14 = total_time;
  <D.67573>:
  printf ("%llu", iftmp.14);
  return;
}



;; Function void hookomp_print_time_results() (_Z26hookomp_print_time_resultsv, funcdef_no=3251, decl_uid=66119, cgraph_uid=3073)

void hookomp_print_time_results() ()
{
  int D.67599;
  bool made_the_offloading.33;
  int D.67597;
  bool decided_by_offloading.32;
  int D.67595;
  bool D.67591;
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
  fprintf (stdout.15, "ORIG = ");
  seq_stop.16 = seq_stop;
  seq_start.17 = seq_start;
  hookomp_timing_print (seq_start.17, seq_stop.16);
  stdout.15 = stdout;
  fprintf (stdout.15, ", ");
  stdout.15 = stdout;
  fprintf (stdout.15, "OMP_OFF = ");
  omp_stop.18 = omp_stop;
  omp_start.19 = omp_start;
  hookomp_timing_print (omp_start.19, omp_stop.18);
  stdout.15 = stdout;
  fprintf (stdout.15, ", ");
  stdout.15 = stdout;
  fprintf (stdout.15, "OMP = ");
  hookomp_timing_print_without_dev ();
  stdout.15 = stdout;
  fprintf (stdout.15, ", ");
  stdout.15 = stdout;
  fprintf (stdout.15, "CUDA_KERNEL1 = ");
  dev_kernel1_stop.20 = dev_kernel1_stop;
  dev_kernel1_start.21 = dev_kernel1_start;
  hookomp_timing_print (dev_kernel1_start.21, dev_kernel1_stop.20);
  stdout.15 = stdout;
  fprintf (stdout.15, ", ");
  stdout.15 = stdout;
  fprintf (stdout.15, "CUDA_KERNEL2 = ");
  dev_kernel2_stop.22 = dev_kernel2_stop;
  dev_kernel2_start.23 = dev_kernel2_start;
  hookomp_timing_print (dev_kernel2_start.23, dev_kernel2_stop.22);
  stdout.15 = stdout;
  fprintf (stdout.15, ", ");
  stdout.15 = stdout;
  fprintf (stdout.15, "CUDA_KERNEL3 = ");
  dev_kernel3_stop.24 = dev_kernel3_stop;
  dev_kernel3_start.25 = dev_kernel3_start;
  hookomp_timing_print (dev_kernel3_start.25, dev_kernel3_stop.24);
  stdout.15 = stdout;
  fprintf (stdout.15, ", ");
  stdout.15 = stdout;
  fprintf (stdout.15, "DT_H2D = ");
  data_transfer_h2d_stop.26 = data_transfer_h2d_stop;
  data_transfer_h2d_start.27 = data_transfer_h2d_start;
  hookomp_timing_print (data_transfer_h2d_start.27, data_transfer_h2d_stop.26);
  stdout.15 = stdout;
  fprintf (stdout.15, ", ");
  stdout.15 = stdout;
  fprintf (stdout.15, "DT_D2H = ");
  data_transfer_d2h_stop.28 = data_transfer_d2h_stop;
  data_transfer_d2h_start.29 = data_transfer_d2h_start;
  hookomp_timing_print (data_transfer_d2h_start.29, data_transfer_d2h_stop.28);
  reach_offload_decision_point.31 = reach_offload_decision_point;
  D.67591 = ~reach_offload_decision_point.31;
  if (D.67591 != 0) goto <D.67592>; else goto <D.67593>;
  <D.67592>:
  iftmp.30 = 1;
  goto <D.67594>;
  <D.67593>:
  iftmp.30 = 0;
  <D.67594>:
  stdout.15 = stdout;
  fprintf (stdout.15, ", WORK_FINISHED_BEFORE_OFFLOAD_DECISION = %d", iftmp.30);
  reach_offload_decision_point.31 = reach_offload_decision_point;
  D.67595 = (int) reach_offload_decision_point.31;
  stdout.15 = stdout;
  fprintf (stdout.15, ", REACH_OFFLOAD_DECISION_POINT = %d", D.67595);
  decided_by_offloading.32 = decided_by_offloading;
  D.67597 = (int) decided_by_offloading.32;
  stdout.15 = stdout;
  fprintf (stdout.15, ", DECIDED_BY_OFFLOADING = %d", D.67597);
  made_the_offloading.33 = made_the_offloading;
  D.67599 = (int) made_the_offloading.33;
  stdout.15 = stdout;
  fprintf (stdout.15, ", MADE_THE_OFFLOADING = %d", D.67599);
  stdout.15 = stdout;
  fprintf (stdout.15, "\n");
  return;
}



;; Function int fprintf(FILE*, const char*, ...) (<unset-asm-name>, funcdef_no=3212, decl_uid=1062, cgraph_uid=3034)

int fprintf(FILE*, const char*, ...) (struct FILE * restrict __stream, const char * restrict __fmt)
{
  int D.67602;
  int D.67600;

  D.67602 = __fprintf_chk (__stream, 1, __fmt, __builtin_va_arg_pack ());
  D.67600 = D.67602;
  goto <D.67601>;
  <D.67601>:
  return D.67600;
}



;; Function bool create_target_functions_table(Func****, int, int) (_Z29create_target_functions_tablePPPP4Funcii, funcdef_no=3256, decl_uid=66664, cgraph_uid=3078)

bool create_target_functions_table(Func****, int, int) (struct Func * * * * table_, int nrows, int ncolumns)
{
  int j;
  int i;
  bool result;
  struct Func * * * table;
  bool D.67624;
  struct Func * D.67621;
  void * D.67620;
  struct Func * * D.67619;
  long unsigned int D.67618;
  long unsigned int D.67617;
  struct Func * * D.67614;
  void * D.67613;
  long unsigned int D.67612;
  long unsigned int D.67611;
  struct Func * * * D.67610;
  long unsigned int D.67609;
  long unsigned int D.67608;
  long unsigned int D.67605;
  long unsigned int D.67604;
  struct _IO_FILE * stderr.34;

  result = 1;
  stderr.34 = stderr;
  fprintf (stderr.34, "Allocating the rows.\n");
  D.67604 = (long unsigned int) nrows;
  D.67605 = D.67604 * 8;
  table = malloc (D.67605);
  if (table != 0B) goto <D.67606>; else goto <D.67607>;
  <D.67606>:
  stderr.34 = stderr;
  fprintf (stderr.34, "Allocating the columns.\n");
  i = 0;
  goto <D.66677>;
  <D.66676>:
  D.67608 = (long unsigned int) i;
  D.67609 = D.67608 * 8;
  D.67610 = table + D.67609;
  D.67611 = (long unsigned int) ncolumns;
  D.67612 = D.67611 * 8;
  D.67613 = malloc (D.67612);
  *D.67610 = D.67613;
  D.67608 = (long unsigned int) i;
  D.67609 = D.67608 * 8;
  D.67610 = table + D.67609;
  D.67614 = *D.67610;
  if (D.67614 != 0B) goto <D.67615>; else goto <D.67616>;
  <D.67615>:
  j = 0;
  goto <D.66675>;
  <D.66674>:
  D.67608 = (long unsigned int) i;
  D.67609 = D.67608 * 8;
  D.67610 = table + D.67609;
  D.67614 = *D.67610;
  D.67617 = (long unsigned int) j;
  D.67618 = D.67617 * 8;
  D.67619 = D.67614 + D.67618;
  D.67620 = malloc (48);
  *D.67619 = D.67620;
  D.67608 = (long unsigned int) i;
  D.67609 = D.67608 * 8;
  D.67610 = table + D.67609;
  D.67614 = *D.67610;
  D.67617 = (long unsigned int) j;
  D.67618 = D.67617 * 8;
  D.67619 = D.67614 + D.67618;
  D.67621 = *D.67619;
  D.67621->f = 0B;
  j = j + 1;
  <D.66675>:
  if (j < ncolumns) goto <D.66674>; else goto <D.66672>;
  <D.66672>:
  goto <D.67622>;
  <D.67616>:
  stderr.34 = stderr;
  fprintf (stderr.34, "Error in table of target functions allocation (columns).\n");
  result = 0;
  <D.67622>:
  i = i + 1;
  <D.66677>:
  if (i < nrows) goto <D.66676>; else goto <D.66670>;
  <D.66670>:
  goto <D.67623>;
  <D.67607>:
  stderr.34 = stderr;
  fprintf (stderr.34, "Error in table of target functions allocation (rows).\n");
  result = 0;
  <D.67623>:
  stderr.34 = stderr;
  fprintf (stderr.34, "Allocating the columns is OK.\n");
  *table_ = table;
  D.67624 = result;
  goto <D.67625>;
  <D.67625>:
  return D.67624;
}



;; Function void call_function_ffi_call(Func*) (_Z22call_function_ffi_callP4Func, funcdef_no=3257, decl_uid=66679, cgraph_uid=3079)

void call_function_ffi_call(Func*) (struct Func * ff)
{
  ffi_status D.67639;
  struct ffi_cif cif;
  void (*<T19f3>) (void) D.67638;
  void * D.67637;
  void * D.67636;
  void * * D.67635;
  ffi_status D.67632;
  unsigned int D.67631;
  int D.67630;
  struct ffi_type * D.67629;
  struct ffi_type * * D.67628;
  bool retval.36;
  struct _IO_FILE * stderr.35;

  stderr.35 = stderr;
  fprintf (stderr.35, " In call_function_ffi_call.\n");
  D.67628 = ff->arg_types;
  D.67629 = ff->ret_type;
  D.67630 = ff->nargs;
  D.67631 = (unsigned int) D.67630;
  D.67639 = ffi_prep_cif (&cif, 2, D.67631, D.67629, D.67628);
  D.67632 = D.67639;
  retval.36 = D.67632 != 0;
  if (retval.36 != 0) goto <D.67633>; else goto <D.67634>;
  <D.67633>:
  stderr.35 = stderr;
  fprintf (stderr.35, "Error ffi_prep_cif.\n");
  exit (1);
  <D.67634>:
  D.67635 = ff->arg_values;
  D.67636 = ff->ret_value;
  D.67637 = ff->f;
  D.67638 = (void (*<T19f3>) (void)) D.67637;
  ffi_call (&cif, D.67638, D.67636, D.67635);
  cif = {CLOBBER};
  return;
  <D.67640>:
  cif = {CLOBBER};
  resx 1
}



;; Function void init_array(int, int, int, double*, double*, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z10init_arrayiiiPdS_PA4096_dS1_S1_, funcdef_no=3258, decl_uid=66690, cgraph_uid=3080)

void init_array(int, int, int, double*, double*, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double * alpha, double * beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int j;
  int i;
  double[4096] * D.67650;
  double[4096] * D.67649;
  double D.67648;
  double D.67647;
  double D.67646;
  double D.67645;
  double[4096] * D.67644;
  long unsigned int D.67643;
  long unsigned int D.67642;

  *alpha = 3.2412e+4;
  *beta = 2.123e+3;
  i = 0;
  goto <D.66701>;
  <D.66700>:
  j = 0;
  goto <D.66699>;
  <D.66698>:
  D.67642 = (long unsigned int) i;
  D.67643 = D.67642 * 32768;
  D.67644 = A + D.67643;
  D.67645 = (double) i;
  D.67646 = (double) j;
  D.67647 = D.67645 * D.67646;
  D.67648 = D.67647 * 2.44140625e-4;
  *D.67644[j] = D.67648;
  j = j + 1;
  <D.66699>:
  if (j < nk) goto <D.66698>; else goto <D.66696>;
  <D.66696>:
  i = i + 1;
  <D.66701>:
  if (i < ni) goto <D.66700>; else goto <D.66694>;
  <D.66694>:
  i = 0;
  goto <D.66709>;
  <D.66708>:
  j = 0;
  goto <D.66707>;
  <D.66706>:
  D.67642 = (long unsigned int) i;
  D.67643 = D.67642 * 32768;
  D.67649 = B + D.67643;
  D.67645 = (double) i;
  D.67646 = (double) j;
  D.67647 = D.67645 * D.67646;
  D.67648 = D.67647 * 2.44140625e-4;
  *D.67649[j] = D.67648;
  j = j + 1;
  <D.66707>:
  if (j < nj) goto <D.66706>; else goto <D.66704>;
  <D.66704>:
  i = i + 1;
  <D.66709>:
  if (i < nk) goto <D.66708>; else goto <D.66702>;
  <D.66702>:
  i = 0;
  goto <D.66717>;
  <D.66716>:
  j = 0;
  goto <D.66715>;
  <D.66714>:
  D.67642 = (long unsigned int) i;
  D.67643 = D.67642 * 32768;
  D.67650 = C + D.67643;
  D.67645 = (double) i;
  D.67646 = (double) j;
  D.67647 = D.67645 * D.67646;
  D.67648 = D.67647 * 2.44140625e-4;
  *D.67650[j] = D.67648;
  j = j + 1;
  <D.66715>:
  if (j < nj) goto <D.66714>; else goto <D.66712>;
  <D.66712>:
  i = i + 1;
  <D.66717>:
  if (i < ni) goto <D.66716>; else goto <D.66710>;
  <D.66710>:
  return;
}



;; Function void copy_array(int, int, double (*)[4096], double (*)[4096]) (_Z10copy_arrayiiPA4096_dS0_, funcdef_no=3259, decl_uid=66722, cgraph_uid=3081)

void copy_array(int, int, double (*)[4096], double (*)[4096]) (int ni, int nj, double[4096] * C_source, double[4096] * C_dest)
{
  int j;
  int i;
  double D.67655;
  double[4096] * D.67654;
  double[4096] * D.67653;
  long unsigned int D.67652;
  long unsigned int D.67651;

  i = 0;
  goto <D.66733>;
  <D.66732>:
  j = 0;
  goto <D.66731>;
  <D.66730>:
  D.67651 = (long unsigned int) i;
  D.67652 = D.67651 * 32768;
  D.67653 = C_dest + D.67652;
  D.67651 = (long unsigned int) i;
  D.67652 = D.67651 * 32768;
  D.67654 = C_source + D.67652;
  D.67655 = *D.67654[j];
  *D.67653[j] = D.67655;
  j = j + 1;
  <D.66731>:
  if (j < nj) goto <D.66730>; else goto <D.66728>;
  <D.66728>:
  i = i + 1;
  <D.66733>:
  if (i < ni) goto <D.66732>; else goto <D.66726>;
  <D.66726>:
  return;
}



;; Function void compareResults(int, int, double (*)[4096], double (*)[4096]) (_Z14compareResultsiiPA4096_dS0_, funcdef_no=3260, decl_uid=66738, cgraph_uid=3082)

void compareResults(int, int, double (*)[4096], double (*)[4096]) (int ni, int nj, double[4096] * C, double[4096] * C_output)
{
  int fail;
  int j;
  int i;
  struct _IO_FILE * stderr.38;
  double D.67664;
  float D.67663;
  double D.67662;
  double[4096] * D.67661;
  double D.67660;
  double[4096] * D.67659;
  long unsigned int D.67658;
  long unsigned int D.67657;
  bool retval.37;

  fail = 0;
  i = 0;
  goto <D.66750>;
  <D.66749>:
  j = 0;
  goto <D.66748>;
  <D.66747>:
  D.67657 = (long unsigned int) i;
  D.67658 = D.67657 * 32768;
  D.67659 = C_output + D.67658;
  D.67660 = *D.67659[j];
  D.67657 = (long unsigned int) i;
  D.67658 = D.67657 * 32768;
  D.67661 = C + D.67658;
  D.67662 = *D.67661[j];
  D.67663 = percentDiff (D.67662, D.67660);
  D.67664 = (double) D.67663;
  retval.37 = D.67664 > 5.000000000000000277555756156289135105907917022705078125e-2;
  if (retval.37 != 0) goto <D.67665>; else goto <D.67666>;
  <D.67665>:
  fail = fail + 1;
  goto <D.67667>;
  <D.67666>:
  <D.67667>:
  j = j + 1;
  <D.66748>:
  if (j < nj) goto <D.66747>; else goto <D.66745>;
  <D.66745>:
  i = i + 1;
  <D.66750>:
  if (i < ni) goto <D.66749>; else goto <D.66743>;
  <D.66743>:
  stderr.38 = stderr;
  fprintf (stderr.38, "Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", 5.000000000000000277555756156289135105907917022705078125e-2, fail);
  return;
}



;; Function void gemm(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z4gemmiiiddPA4096_dS0_S0_, funcdef_no=3262, decl_uid=66774, cgraph_uid=3084)

void gemm(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int k;
  int j;
  int i;
  double D.67682;
  double D.67681;
  double D.67680;
  double[4096] * D.67679;
  long unsigned int D.67678;
  long unsigned int D.67677;
  double D.67676;
  double D.67675;
  double[4096] * D.67674;
  double D.67673;
  double D.67672;
  double[4096] * D.67671;
  long unsigned int D.67670;
  long unsigned int D.67669;

  i = 0;
  goto <D.66790>;
  <D.66789>:
  j = 0;
  goto <D.66788>;
  <D.66787>:
  D.67669 = (long unsigned int) i;
  D.67670 = D.67669 * 32768;
  D.67671 = C + D.67670;
  D.67669 = (long unsigned int) i;
  D.67670 = D.67669 * 32768;
  D.67671 = C + D.67670;
  D.67672 = *D.67671[j];
  D.67673 = D.67672 * beta;
  *D.67671[j] = D.67673;
  k = 0;
  goto <D.66786>;
  <D.66785>:
  D.67669 = (long unsigned int) i;
  D.67670 = D.67669 * 32768;
  D.67671 = C + D.67670;
  D.67669 = (long unsigned int) i;
  D.67670 = D.67669 * 32768;
  D.67671 = C + D.67670;
  D.67672 = *D.67671[j];
  D.67669 = (long unsigned int) i;
  D.67670 = D.67669 * 32768;
  D.67674 = A + D.67670;
  D.67675 = *D.67674[k];
  D.67676 = D.67675 * alpha;
  D.67677 = (long unsigned int) k;
  D.67678 = D.67677 * 32768;
  D.67679 = B + D.67678;
  D.67680 = *D.67679[j];
  D.67681 = D.67676 * D.67680;
  D.67682 = D.67672 + D.67681;
  *D.67671[j] = D.67682;
  k = k + 1;
  <D.66786>:
  if (k < nk) goto <D.66785>; else goto <D.66783>;
  <D.66783>:
  j = j + 1;
  <D.66788>:
  if (j < nj) goto <D.66787>; else goto <D.66781>;
  <D.66781>:
  i = i + 1;
  <D.66790>:
  if (i < ni) goto <D.66789>; else goto <D.66779>;
  <D.66779>:
  return;
}



;; Function void gemm_original(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z13gemm_originaliiiddPA4096_dS0_S0_, funcdef_no=3263, decl_uid=66799, cgraph_uid=3085)

void gemm_original(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  hookomp_timing_start (&seq_start);
  gemm (ni, nj, nk, alpha, beta, A, B, C);
  hookomp_timing_stop (&seq_stop);
  return;
}



;; Function void gemm_omp_kernel(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z15gemm_omp_kerneliiiddPA4096_dS0_S0_, funcdef_no=3264, decl_uid=66809, cgraph_uid=3086)

void gemm_omp_kernel(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C)
{
  int k;
  int j;
  int i;
  int D.67742;
  int k;
  int j;
  int i;
  struct .omp_data_s.41 .omp_data_o.42;
  int D.67741;
  int D.67740;
  double[4096] * D.67739;
  double D.67738;
  double[4096] * D.67737;
  double[4096] * D.67736;
  double[4096] * D.67735;
  double D.67734;
  double[4096] * D.67733;
  double[4096] * D.67732;

  .omp_data_o.42.alpha = alpha;
  .omp_data_o.42.beta = beta;
  .omp_data_o.42.A = A;
  .omp_data_o.42.B = B;
  .omp_data_o.42.C = C;
  .omp_data_o.42.ni = ni;
  .omp_data_o.42.nj = nj;
  .omp_data_o.42.nk = nk;
  #pragma omp parallel num_threads(8) shared(C) shared(B) shared(A) shared(beta) shared(alpha) shared(nk) shared(nj) shared(ni) [child fn: _Z15gemm_omp_kerneliiiddPA4096_dS0_S0_._omp_fn.0 (.omp_data_o.42)]
  .omp_data_i = (struct .omp_data_s.41 & restrict) &.omp_data_o.42;
  current_loop_index = 0;
  num_threads_defined = 8;
  D.67683 = 16;
  D.67684 = D.67683 + 8;
  D.67685 = D.67684 * 16777216;
  q_data_transfer_write.39 = (long long int) D.67685;
  q_data_transfer_write = q_data_transfer_write.39;
  D.67687 = 134217728;
  q_data_transfer_read.40 = (long long int) D.67687;
  q_data_transfer_read = q_data_transfer_read.40;
  type_of_data_allocation = 1;
  D.67742 = .omp_data_i->ni;
  #pragma omp for schedule(dynamic,64) private(k) private(j) private(i)
  for (i = 0; i < D.67742; i = i + 1)
  j = 0;
  goto <D.67726>;
  <D.67727>:
  D.67689 = (long unsigned int) i;
  D.67690 = D.67689 * 32768;
  D.67732 = .omp_data_i->C;
  D.67691 = D.67732 + D.67690;
  D.67689 = (long unsigned int) i;
  D.67690 = D.67689 * 32768;
  D.67733 = .omp_data_i->C;
  D.67691 = D.67733 + D.67690;
  D.67692 = *D.67691[j];
  D.67734 = .omp_data_i->beta;
  D.67693 = D.67692 * D.67734;
  *D.67691[j] = D.67693;
  k = 0;
  goto <D.67728>;
  <D.67729>:
  D.67689 = (long unsigned int) i;
  D.67690 = D.67689 * 32768;
  D.67735 = .omp_data_i->C;
  D.67691 = D.67735 + D.67690;
  D.67689 = (long unsigned int) i;
  D.67690 = D.67689 * 32768;
  D.67736 = .omp_data_i->C;
  D.67691 = D.67736 + D.67690;
  D.67692 = *D.67691[j];
  D.67689 = (long unsigned int) i;
  D.67690 = D.67689 * 32768;
  D.67737 = .omp_data_i->A;
  D.67694 = D.67737 + D.67690;
  D.67695 = *D.67694[k];
  D.67738 = .omp_data_i->alpha;
  D.67696 = D.67695 * D.67738;
  D.67697 = (long unsigned int) k;
  D.67698 = D.67697 * 32768;
  D.67739 = .omp_data_i->B;
  D.67699 = D.67739 + D.67698;
  D.67700 = *D.67699[j];
  D.67701 = D.67696 * D.67700;
  D.67702 = D.67692 + D.67701;
  *D.67691[j] = D.67702;
  k = k + 1;
  <D.67728>:
  D.67740 = .omp_data_i->nk;
  if (k < D.67740) goto <D.67729>; else goto <D.67730>;
  <D.67730>:
  j = j + 1;
  <D.67726>:
  D.67741 = .omp_data_i->nj;
  if (j < D.67741) goto <D.67727>; else goto <D.67731>;
  <D.67731>:
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



;; Function void gemm_omp(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (_Z8gemm_ompiiiddPA4096_dS0_S0_, funcdef_no=3265, decl_uid=66831, cgraph_uid=3087)

void gemm_omp(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C_outputFromOMP)
{
  hookomp_timing_start (&omp_start);
  gemm_omp_kernel (ni, nj, nk, alpha, beta, A, B, C_outputFromOMP);
  hookomp_timing_stop (&omp_stop);
  return;
}



;; Function void GPU_argv_init() (_Z13GPU_argv_initv, funcdef_no=3266, decl_uid=66833, cgraph_uid=3088)

void GPU_argv_init() ()
{
  struct cudaDeviceProp deviceProp;
  struct _IO_FILE * stderr.43;

  stderr.43 = stderr;
  fprintf (stderr.43, "GPU init.\n");
  cudaGetDeviceProperties (&deviceProp, 0);
  stderr.43 = stderr;
  fprintf (stderr.43, "setting device %d with name %s\n", 0, &deviceProp.name);
  cudaSetDevice (0);
  deviceProp = {CLOBBER};
  return;
  <D.67745>:
  deviceProp = {CLOBBER};
  resx 1
}



;; Function void gemm_cuda(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096]) (_Z9gemm_cudaiiiddPA4096_dS0_S0_S0_S0_, funcdef_no=3267, decl_uid=66855, cgraph_uid=3089)

void gemm_cuda(int, int, int, double, double, double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096], double (*)[4096]) (int ni, int nj, int nk, double alpha, double beta, double[4096] * A, double[4096] * B, double[4096] * C, double[4096] * C_inputToGpu, double[4096] * C_outputFromGpu)
{
  cudaError D.67767;
  struct dim3 grid;
  struct dim3 block;
  double * C_gpu;
  double * B_gpu;
  double * A_gpu;
  cudaError D.67763;
  unsigned int D.67762;
  long unsigned int D.67761;
  float D.67760;
  float D.67759;
  float D.67758;
  unsigned int D.67757;
  unsigned int D.67756;
  long unsigned int D.67755;
  float D.67754;
  float D.67753;
  float D.67752;
  unsigned int D.67751;
  double * C_gpu.47;
  double * B_gpu.46;
  double * A_gpu.45;
  long unsigned int D.67747;
  struct _IO_FILE * stderr.44;

  stderr.44 = stderr;
  fprintf (stderr.44, "Calling function gemm_cuda.\n");
  GPU_argv_init ();
  D.67747 = 134217728;
  cudaMalloc (&A_gpu, D.67747);
  D.67747 = 134217728;
  cudaMalloc (&B_gpu, D.67747);
  D.67747 = 134217728;
  cudaMalloc (&C_gpu, D.67747);
  hookomp_timing_start (&data_transfer_h2d_start);
  D.67747 = 134217728;
  A_gpu.45 = A_gpu;
  cudaMemcpy (A_gpu.45, A, D.67747, 1);
  D.67747 = 134217728;
  B_gpu.46 = B_gpu;
  cudaMemcpy (B_gpu.46, B, D.67747, 1);
  D.67747 = 134217728;
  C_gpu.47 = C_gpu;
  cudaMemcpy (C_gpu.47, C_inputToGpu, D.67747, 1);
  hookomp_timing_stop (&data_transfer_h2d_stop);
  dim3::dim3 (&block, 32, 8, 1);
  D.67751 = block.y;
  D.67752 = (float) D.67751;
  D.67753 = 4.096e+3 / D.67752;
  D.67754 = std::ceil (D.67753);
  D.67755 = (long unsigned int) D.67754;
  D.67756 = (unsigned int) D.67755;
  D.67757 = block.x;
  D.67758 = (float) D.67757;
  D.67759 = 4.096e+3 / D.67758;
  D.67760 = std::ceil (D.67759);
  D.67761 = (long unsigned int) D.67760;
  D.67762 = (unsigned int) D.67761;
  dim3::dim3 (&grid, D.67762, D.67756, 1);
  hookomp_timing_start (&dev_kernel1_start);
  D.67767 = cudaConfigureCall (grid, block, 0, 0B);
  D.67763 = D.67767;
  if (D.67763 == 0) goto <D.67764>; else goto <D.67765>;
  <D.67764>:
  C_gpu.47 = C_gpu;
  B_gpu.46 = B_gpu;
  A_gpu.45 = A_gpu;
  gemm_cuda_kernel (ni, nj, nk, alpha, beta, A_gpu.45, B_gpu.46, C_gpu.47);
  goto <D.67766>;
  <D.67765>:
  <D.67766>:
  cudaThreadSynchronize ();
  hookomp_timing_stop (&dev_kernel1_stop);
  hookomp_timing_start (&data_transfer_d2h_start);
  D.67747 = 134217728;
  C_gpu.47 = C_gpu;
  cudaMemcpy (C_outputFromGpu, C_gpu.47, D.67747, 2);
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
  <D.67768>:
  A_gpu = {CLOBBER};
  B_gpu = {CLOBBER};
  C_gpu = {CLOBBER};
  block = {CLOBBER};
  grid = {CLOBBER};
  resx 1
}



;; Function float std::ceil(float) (_ZSt4ceilf, funcdef_no=154, decl_uid=8694, cgraph_uid=146)

float std::ceil(float) (float __x)
{
  float D.67769;

  D.67769 = __builtin_ceilf (__x);
  goto <D.67770>;
  <D.67770>:
  return D.67769;
}



;; Function dim3::dim3(unsigned int, unsigned int, unsigned int) (_ZN4dim3C2Ejjj, funcdef_no=3, decl_uid=3003, cgraph_uid=3)

dim3::dim3(unsigned int, unsigned int, unsigned int) (struct dim3 * const this, unsigned int vx, unsigned int vy, unsigned int vz)
{
  this->x = vx;
  this->y = vy;
  this->z = vz;
  return;
}



;; Function int main(int, char**) (main, funcdef_no=3268, decl_uid=66878, cgraph_uid=3090)

int main(int, char**) (int argc, char * * argv)
{
  bool D.67843;
  void * D.67842;
  void * D.67841;
  double[4096][4096] * D.67840;
  void * D.67839;
  void * D.67838;
  void * D.67837;
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
  int D.67835;
  unsigned char D.67831;
  char * D.67830;
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
  struct Func * D.67813;
  struct Func * * D.67812;
  struct Func * * D.67811;
  struct Func * * * table.55;
  bool retval.54;
  struct ffi_type * * D.67804;
  struct ffi_type * * D.67803;
  struct ffi_type * * D.67802;
  struct ffi_type * * D.67801;
  struct ffi_type * * D.67800;
  struct ffi_type * * D.67799;
  struct ffi_type * * D.67798;
  struct ffi_type * * D.67797;
  struct ffi_type * * D.67796;
  struct ffi_type * * D.67795;
  struct ffi_type * * D.67794;
  void * * D.67793;
  void * * D.67792;
  void * * D.67791;
  void * * D.67790;
  void * * D.67789;
  void * * D.67788;
  void * * D.67787;
  void * * D.67786;
  void * * D.67785;
  void * * D.67784;
  void * * D.67783;
  void * * D.67782;
  void * D.67781;
  void * D.67780;
  long unsigned int D.67779;
  long unsigned int D.67778;
  int D.67777;
  struct _IO_FILE * stderr.53;
  void * C_outputFromGpu.52;
  void * C_inputToGpu.51;
  void * C.50;
  void * B.49;
  void * A.48;

  ni = 4096;
  nj = 4096;
  nk = 4096;
  D.67837 = polybench_alloc_data (16777216, 8);
  A.48 = D.67837;
  A = A.48;
  D.67838 = polybench_alloc_data (16777216, 8);
  B.49 = D.67838;
  B = B.49;
  D.67839 = polybench_alloc_data (16777216, 8);
  C.50 = D.67839;
  C = C.50;
  D.67840 = polybench_alloc_data (16777216, 8);
  C_outputFromOMP = D.67840;
  D.67841 = polybench_alloc_data (16777216, 8);
  C_inputToGpu.51 = D.67841;
  C_inputToGpu = C_inputToGpu.51;
  D.67842 = polybench_alloc_data (16777216, 8);
  C_outputFromGpu.52 = D.67842;
  C_outputFromGpu = C_outputFromGpu.52;
  stderr.53 = stderr;
  fprintf (stderr.53, "Preparing alternatives functions.\n");
  n_params = 10;
  ff_0 = malloc (48);
  D.67777 = n_params + 1;
  D.67778 = (long unsigned int) D.67777;
  D.67779 = D.67778 * 8;
  D.67780 = malloc (D.67779);
  ff_0->arg_types = D.67780;
  D.67777 = n_params + 1;
  D.67778 = (long unsigned int) D.67777;
  D.67779 = D.67778 * 8;
  D.67781 = malloc (D.67779);
  ff_0->arg_values = D.67781;
  ff_0->f = gemm_cuda;
  D.67782 = &ff_0->ret_value;
  memset (D.67782, 0, 8);
  ff_0->ret_type = &ffi_type_void;
  ff_0->nargs = n_params;
  D.67783 = ff_0->arg_values;
  *D.67783 = &ni;
  D.67783 = ff_0->arg_values;
  D.67784 = D.67783 + 8;
  *D.67784 = &nj;
  D.67783 = ff_0->arg_values;
  D.67785 = D.67783 + 16;
  *D.67785 = &nk;
  D.67783 = ff_0->arg_values;
  D.67786 = D.67783 + 24;
  *D.67786 = &alpha;
  D.67783 = ff_0->arg_values;
  D.67787 = D.67783 + 32;
  *D.67787 = &beta;
  D.67783 = ff_0->arg_values;
  D.67788 = D.67783 + 40;
  *D.67788 = &A;
  D.67783 = ff_0->arg_values;
  D.67789 = D.67783 + 48;
  *D.67789 = &B;
  D.67783 = ff_0->arg_values;
  D.67790 = D.67783 + 56;
  *D.67790 = &C;
  D.67783 = ff_0->arg_values;
  D.67791 = D.67783 + 64;
  *D.67791 = &C_inputToGpu;
  D.67783 = ff_0->arg_values;
  D.67792 = D.67783 + 72;
  *D.67792 = &C_outputFromGpu;
  D.67783 = ff_0->arg_values;
  D.67793 = D.67783 + 80;
  *D.67793 = 0B;
  D.67794 = ff_0->arg_types;
  *D.67794 = &ffi_type_sint32;
  D.67794 = ff_0->arg_types;
  D.67795 = D.67794 + 8;
  *D.67795 = &ffi_type_sint32;
  D.67794 = ff_0->arg_types;
  D.67796 = D.67794 + 16;
  *D.67796 = &ffi_type_sint32;
  D.67794 = ff_0->arg_types;
  D.67797 = D.67794 + 24;
  *D.67797 = &ffi_type_double;
  D.67794 = ff_0->arg_types;
  D.67798 = D.67794 + 32;
  *D.67798 = &ffi_type_double;
  D.67794 = ff_0->arg_types;
  D.67799 = D.67794 + 40;
  *D.67799 = &ffi_type_pointer;
  D.67794 = ff_0->arg_types;
  D.67800 = D.67794 + 48;
  *D.67800 = &ffi_type_pointer;
  D.67794 = ff_0->arg_types;
  D.67801 = D.67794 + 56;
  *D.67801 = &ffi_type_pointer;
  D.67794 = ff_0->arg_types;
  D.67802 = D.67794 + 64;
  *D.67802 = &ffi_type_pointer;
  D.67794 = ff_0->arg_types;
  D.67803 = D.67794 + 72;
  *D.67803 = &ffi_type_pointer;
  D.67794 = ff_0->arg_types;
  D.67804 = D.67794 + 80;
  *D.67804 = 0B;
  stderr.53 = stderr;
  fprintf (stderr.53, "Creating table of target functions.\n");
  nloops = 1;
  ndevices = 2;
  D.67843 = create_target_functions_table (&table, nloops, ndevices);
  retval.54 = D.67843;
  if (retval.54 != 0) goto <D.67806>; else goto <D.67807>;
  <D.67806>:
  table.55 = table;
  if (table.55 == 0B) goto <D.67809>; else goto <D.67810>;
  <D.67809>:
  __assert_fail ("table != NULL", "gemm.cu", 402, &__PRETTY_FUNCTION__);
  <D.67810>:
  stderr.53 = stderr;
  fprintf (stderr.53, "Declaring function in 0,1.\n");
  table.55 = table;
  D.67811 = *table.55;
  D.67812 = D.67811 + 8;
  D.67813 = *D.67812;
  *D.67813 = MEM[(const struct Func &)ff_0];
  table.55 = table;
  TablePointerFunctions = table.55;
  TablePointerFunctions.56 = TablePointerFunctions;
  if (TablePointerFunctions.56 == 0B) goto <D.67815>; else goto <D.67816>;
  <D.67815>:
  __assert_fail ("TablePointerFunctions != NULL", "gemm.cu", 408, &__PRETTY_FUNCTION__);
  <D.67816>:
  goto <D.67817>;
  <D.67807>:
  <D.67817>:
  stderr.53 = stderr;
  fprintf (stderr.53, "Calling init_array.\n");
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
  fprintf (stderr.53, "Calling gemm_omp:\n");
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
  fprintf (stderr.53, "Calling compareResults(original, omp).\n");
  C.57 = C;
  nj.61 = nj;
  ni.62 = ni;
  compareResults (ni.62, nj.61, C.57, C_outputFromOMP);
  stderr.53 = stderr;
  fprintf (stderr.53, "Calling compareResults(original, cuda).\n");
  C_outputFromGpu.63 = C_outputFromGpu;
  C.57 = C;
  nj.61 = nj;
  ni.62 = ni;
  compareResults (ni.62, nj.61, C.57, C_outputFromGpu.63);
  if (argc > 42) goto <D.67828>; else goto <D.67829>;
  <D.67828>:
  D.67830 = *argv;
  D.67831 = MEM[(const unsigned char * {ref-all})D.67830];
  if (D.67831 == 0) goto <D.67832>; else goto <D.67833>;
  <D.67832>:
  C_outputFromGpu.63 = C_outputFromGpu;
  nj.61 = nj;
  ni.62 = ni;
  print_array (ni.62, nj.61, C_outputFromGpu.63);
  goto <D.67834>;
  <D.67833>:
  <D.67834>:
  <D.67829>:
  A.59 = A;
  free (A.59);
  B.58 = B;
  free (B.58);
  C.57 = C;
  free (C.57);
  free (C_outputFromOMP);
  C_outputFromGpu.63 = C_outputFromGpu;
  free (C_outputFromGpu.63);
  D.67835 = 0;
  goto <D.67845>;
  <D.67845>:
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
  goto <D.67836>;
  D.67835 = 0;
  goto <D.67836>;
  <D.67836>:
  return D.67835;
  <D.67844>:
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



;; Function void print_array(int, int, double (*)[4096]) (_ZL11print_arrayiiPA4096_d, funcdef_no=3261, decl_uid=66754, cgraph_uid=3083)

void print_array(int, int, double (*)[4096]) (int ni, int nj, double[4096] * C)
{
  int j;
  int i;
  int D.67853;
  int D.67852;
  int D.67851;
  struct _IO_FILE * stderr.67;
  double D.67849;
  double[4096] * D.67848;
  long unsigned int D.67847;
  long unsigned int D.67846;

  i = 0;
  goto <D.66765>;
  <D.66764>:
  j = 0;
  goto <D.66763>;
  <D.66762>:
  D.67846 = (long unsigned int) i;
  D.67847 = D.67846 * 32768;
  D.67848 = C + D.67847;
  D.67849 = *D.67848[j];
  stderr.67 = stderr;
  fprintf (stderr.67, "%0.2lf ", D.67849);
  D.67851 = i * ni;
  D.67852 = D.67851 + j;
  D.67853 = D.67852 % 20;
  if (D.67853 == 0) goto <D.67854>; else goto <D.67855>;
  <D.67854>:
  stderr.67 = stderr;
  fprintf (stderr.67, "\n");
  goto <D.67856>;
  <D.67855>:
  <D.67856>:
  j = j + 1;
  <D.66763>:
  if (j < nj) goto <D.66762>; else goto <D.66760>;
  <D.66760>:
  i = i + 1;
  <D.66765>:
  if (i < ni) goto <D.66764>; else goto <D.66758>;
  <D.66758>:
  stderr.67 = stderr;
  fprintf (stderr.67, "\n");
  return;
}



;; Function void polybench_flush_cache() (_Z21polybench_flush_cachev, funcdef_no=3270, decl_uid=67114, cgraph_uid=3092)

void polybench_flush_cache() ()
{
  static const char __PRETTY_FUNCTION__[29] = "void polybench_flush_cache()";
  double tmp;
  int i;
  double * flush;
  int cs;
  double D.67862;
  double * D.67861;
  long unsigned int D.67860;
  long unsigned int D.67859;
  long unsigned int D.67858;
  long unsigned int D.67857;

  D.67857 = 4194560;
  cs = (int) D.67857;
  D.67858 = (long unsigned int) cs;
  flush = calloc (D.67858, 8);
  tmp = 0.0;
  i = 0;
  goto <D.67124>;
  <D.67123>:
  D.67859 = (long unsigned int) i;
  D.67860 = D.67859 * 8;
  D.67861 = flush + D.67860;
  D.67862 = *D.67861;
  tmp = D.67862 + tmp;
  i = i + 1;
  <D.67124>:
  if (i < cs) goto <D.67123>; else goto <D.67121>;
  <D.67121>:
  if (tmp <= 1.0e+1) goto <D.67863>; else goto <D.67864>;
  <D.67863>:
  goto <D.67865>;
  <D.67864>:
  __assert_fail ("tmp <= 10.0", "../../../utilities/polybench.c", 96, &__PRETTY_FUNCTION__);
  <D.67865>:
  free (flush);
  return;
}



;; Function void polybench_prepare_instruments() (_Z29polybench_prepare_instrumentsv, funcdef_no=3271, decl_uid=67125, cgraph_uid=3093)

void polybench_prepare_instruments() ()
{
  polybench_flush_cache ();
  return;
}



;; Function void polybench_timer_start() (_Z21polybench_timer_startv, funcdef_no=3272, decl_uid=65913, cgraph_uid=3094)

void polybench_timer_start() ()
{
  double D.67867;
  double polybench_t_start.68;

  polybench_prepare_instruments ();
  D.67867 = rtclock ();
  polybench_t_start.68 = D.67867;
  polybench_t_start = polybench_t_start.68;
  return;
}



;; Function double rtclock() (_ZL7rtclockv, funcdef_no=3269, decl_uid=67110, cgraph_uid=3091)

double rtclock() ()
{
  int stat;
  struct timeval Tp;
  double D.67876;
  double D.67875;
  long int D.67874;
  double D.67873;
  long int D.67872;
  double D.67871;

  stat = gettimeofday (&Tp, 0B);
  if (stat != 0) goto <D.67868>; else goto <D.67869>;
  <D.67868>:
  printf ("Error return from gettimeofday: %d", stat);
  goto <D.67870>;
  <D.67869>:
  <D.67870>:
  D.67872 = Tp.tv_sec;
  D.67873 = (double) D.67872;
  D.67874 = Tp.tv_usec;
  D.67875 = (double) D.67874;
  D.67876 = D.67875 * 9.99999999999999954748111825886258685613938723690807819366e-7;
  D.67871 = D.67873 + D.67876;
  goto <D.67879>;
  <D.67879>:
  Tp = {CLOBBER};
  goto <D.67877>;
  <D.67877>:
  return D.67871;
  <D.67878>:
  Tp = {CLOBBER};
  resx 1
}



;; Function void polybench_timer_stop() (_Z20polybench_timer_stopv, funcdef_no=3273, decl_uid=65914, cgraph_uid=3095)

void polybench_timer_stop() ()
{
  double D.67881;
  double polybench_t_end.69;

  D.67881 = rtclock ();
  polybench_t_end.69 = D.67881;
  polybench_t_end = polybench_t_end.69;
  return;
}



;; Function void polybench_timer_print() (_Z21polybench_timer_printv, funcdef_no=3274, decl_uid=65915, cgraph_uid=3096)

void polybench_timer_print() ()
{
  double D.67884;
  double polybench_t_start.71;
  double polybench_t_end.70;

  polybench_t_end.70 = polybench_t_end;
  polybench_t_start.71 = polybench_t_start;
  D.67884 = polybench_t_end.70 - polybench_t_start.71;
  printf ("%0.6f\n", D.67884);
  return;
}



;; Function void* polybench_alloc_data(long long unsigned int, int) (_Z20polybench_alloc_datayi, funcdef_no=3276, decl_uid=65921, cgraph_uid=3098)

void* polybench_alloc_data(long long unsigned int, int) (long long unsigned int n, int elt_size)
{
  void * D.67888;
  void * ret;
  size_t val;
  void * D.67886;
  long unsigned int D.67885;

  val = n;
  D.67885 = (long unsigned int) elt_size;
  val = D.67885 * val;
  D.67888 = xmalloc (val);
  ret = D.67888;
  D.67886 = ret;
  goto <D.67887>;
  <D.67887>:
  return D.67886;
}



;; Function void* xmalloc(size_t) (_ZL7xmallocm, funcdef_no=3275, decl_uid=67134, cgraph_uid=3097)

void* xmalloc(size_t) (size_t num)
{
  int ret;
  void * newA;
  void * D.67894;
  struct _IO_FILE * stderr.73;
  void * newA.72;

  newA = 0B;
  ret = posix_memalign (&newA, 32, num);
  newA.72 = newA;
  if (newA.72 == 0B) goto <D.67889>; else goto <D.67892>;
  <D.67892>:
  if (ret != 0) goto <D.67889>; else goto <D.67890>;
  <D.67889>:
  stderr.73 = stderr;
  fprintf (stderr.73, "[PolyBench] posix_memalign: cannot allocate memory");
  exit (1);
  <D.67890>:
  D.67894 = newA;
  goto <D.67897>;
  <D.67897>:
  newA = {CLOBBER};
  goto <D.67895>;
  <D.67895>:
  return D.67894;
  <D.67896>:
  newA = {CLOBBER};
  resx 1
}



;; Function void __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_(int, int, int, double, double, double*, double*, double*) (_Z45__device_stub__Z16gemm_cuda_kerneliiiddPdS_S_iiiddPdS_S_, funcdef_no=3301, decl_uid=67447, cgraph_uid=3122)

void __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_(int, int, int, double, double, double*, double*, double*) (int __par0, int __par1, int __par2, double __par3, double __par4, double * __par5, double * __par6, double * __par7)
{
  cudaError D.67938;
  cudaError D.67937;
  cudaError D.67936;
  cudaError D.67935;
  cudaError D.67934;
  cudaError D.67933;
  cudaError D.67932;
  cudaError D.67931;
  static volatile char * __f;
  cudaError D.67927;
  bool retval.81;
  cudaError D.67923;
  bool retval.80;
  cudaError D.67919;
  bool retval.79;
  cudaError D.67915;
  bool retval.78;
  cudaError D.67911;
  bool retval.77;
  cudaError D.67907;
  bool retval.76;
  cudaError D.67903;
  bool retval.75;
  cudaError D.67899;
  bool retval.74;

  D.67931 = cudaSetupArgument (&__par0, 4, 0);
  D.67899 = D.67931;
  retval.74 = D.67899 != 0;
  if (retval.74 != 0) goto <D.67900>; else goto <D.67901>;
  <D.67900>:
  goto <D.67930>;
  <D.67901>:
  D.67932 = cudaSetupArgument (&__par1, 4, 4);
  D.67903 = D.67932;
  retval.75 = D.67903 != 0;
  if (retval.75 != 0) goto <D.67904>; else goto <D.67905>;
  <D.67904>:
  goto <D.67930>;
  <D.67905>:
  D.67933 = cudaSetupArgument (&__par2, 4, 8);
  D.67907 = D.67933;
  retval.76 = D.67907 != 0;
  if (retval.76 != 0) goto <D.67908>; else goto <D.67909>;
  <D.67908>:
  goto <D.67930>;
  <D.67909>:
  D.67934 = cudaSetupArgument (&__par3, 8, 16);
  D.67911 = D.67934;
  retval.77 = D.67911 != 0;
  if (retval.77 != 0) goto <D.67912>; else goto <D.67913>;
  <D.67912>:
  goto <D.67930>;
  <D.67913>:
  D.67935 = cudaSetupArgument (&__par4, 8, 24);
  D.67915 = D.67935;
  retval.78 = D.67915 != 0;
  if (retval.78 != 0) goto <D.67916>; else goto <D.67917>;
  <D.67916>:
  goto <D.67930>;
  <D.67917>:
  D.67936 = cudaSetupArgument (&__par5, 8, 32);
  D.67919 = D.67936;
  retval.79 = D.67919 != 0;
  if (retval.79 != 0) goto <D.67920>; else goto <D.67921>;
  <D.67920>:
  goto <D.67930>;
  <D.67921>:
  D.67937 = cudaSetupArgument (&__par6, 8, 40);
  D.67923 = D.67937;
  retval.80 = D.67923 != 0;
  if (retval.80 != 0) goto <D.67924>; else goto <D.67925>;
  <D.67924>:
  goto <D.67930>;
  <D.67925>:
  D.67938 = cudaSetupArgument (&__par7, 8, 48);
  D.67927 = D.67938;
  retval.81 = D.67927 != 0;
  if (retval.81 != 0) goto <D.67928>; else goto <D.67929>;
  <D.67928>:
  goto <D.67930>;
  <D.67929>:
  __f = gemm_cuda_kernel;
  cudaLaunch<char> (gemm_cuda_kernel);
  <D.67930>:
  return;
}



;; Function cudaError_t cudaLaunch(T*) [with T = char; cudaError_t = cudaError] (_Z10cudaLaunchIcE9cudaErrorPT_, funcdef_no=3305, decl_uid=67478, cgraph_uid=3126)

cudaError_t cudaLaunch(T*) [with T = char; cudaError_t = cudaError] (char * func)
{
  cudaError_t D.67941;
  cudaError_t D.67939;

  D.67941 = cudaLaunch (func);
  D.67939 = D.67941;
  goto <D.67940>;
  <D.67940>:
  return D.67939;
}



;; Function void gemm_cuda_kernel(int, int, int, double, double, double*, double*, double*) (_Z16gemm_cuda_kerneliiiddPdS_S_, funcdef_no=3302, decl_uid=66844, cgraph_uid=3123)

void gemm_cuda_kernel(int, int, int, double, double, double*, double*, double*) (int __cuda_0, int __cuda_1, int __cuda_2, double __cuda_3, double __cuda_4, double * __cuda_5, double * __cuda_6, double * __cuda_7)
{
  __device_stub__Z16gemm_cuda_kerneliiiddPdS_S_ (__cuda_0, __cuda_1, __cuda_2, __cuda_3, __cuda_4, __cuda_5, __cuda_6, __cuda_7);
  return;
}



;; Function void __sti____cudaRegisterAll_39_tmpxft_0000336e_00000000_7_gemm_cpp1_ii_132e4611() (_ZL76__sti____cudaRegisterAll_39_tmpxft_0000336e_00000000_7_gemm_cpp1_ii_132e4611v, funcdef_no=3304, decl_uid=67450, cgraph_uid=3125)

void __sti____cudaRegisterAll_39_tmpxft_0000336e_00000000_7_gemm_cpp1_ii_132e4611() ()
{
  void * * D.67944;
  void (*<T7867>) (void * *) callback_fp;
  void * * __cudaFatCubinHandle.83;
  void * * __cudaFatCubinHandle.82;

  D.67944 = __cudaRegisterFatBinary (&__fatDeviceText);
  __cudaFatCubinHandle.82 = D.67944;
  __cudaFatCubinHandle = __cudaFatCubinHandle.82;
  callback_fp = __nv_cudaEntityRegisterCallback;
  __cudaFatCubinHandle.83 = __cudaFatCubinHandle;
  callback_fp (__cudaFatCubinHandle.83);
  atexit (__cudaUnregisterBinaryUtil);
  return;
}



;; Function void __cudaUnregisterBinaryUtil() (_ZL26__cudaUnregisterBinaryUtilv, funcdef_no=3279, decl_uid=67214, cgraph_uid=3100)

void __cudaUnregisterBinaryUtil() ()
{
  void * * __cudaFatCubinHandle.84;

  ____nv_dummy_param_ref (&__cudaFatCubinHandle);
  __cudaFatCubinHandle.84 = __cudaFatCubinHandle;
  __cudaUnregisterFatBinary (__cudaFatCubinHandle.84);
  return;
}



;; Function void ____nv_dummy_param_ref(void*) (_ZL22____nv_dummy_param_refPv, funcdef_no=3278, decl_uid=67150, cgraph_uid=3099)

void ____nv_dummy_param_ref(void*) (void * param)
{
  static volatile void * * __ref;

  __ref = param;
  return;
}



;; Function void __nv_cudaEntityRegisterCallback(void**) (_ZL31__nv_cudaEntityRegisterCallbackPPv, funcdef_no=3303, decl_uid=67449, cgraph_uid=3124)

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


