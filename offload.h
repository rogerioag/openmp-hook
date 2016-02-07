/**
 * offload.h : This file is part of the HOOKOMP.
 * Functions to support for offloading, for using in benchmarks.
 *
 * Contact: Rogério Aparecido Gonçalves <rogerio.rag@gmail.com>
 */

#ifndef OFFLOAD_H
# define OFFLOAD_H

#include <dlfcn.h>
#include <ffi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <stdint.h>
#include <inttypes.h>
#include <assert.h>

 typedef struct Func {
  void *f;
  int nargs;
  ffi_type** arg_types;
  void** arg_values;
  ffi_type* ret_type;
  void* ret_value;
} Func;

/* Alternative Functions table pointer. */
Func ***table;

Func ***TablePointerFunctions;

/* current loop index. */
long int current_loop_index;

/* Amount of bytes that will be moved to device, if offloading. */
  /* Write: sent to device. Inputs to kernel. */
long long q_data_transfer_write;
/* Read: get from device. Results, data that was modified. */
long long q_data_transfer_read;

/* ------------------------------------------------------------- */
/* Creation of alternative functions table. */
bool create_target_functions_table(Func ****table_, int nrows, int ncolumns) {

  Func ***table;

  bool result = true;
  int i, j;

  fprintf(stderr, "Allocating the rows.\n");
  table = (Func ***) malloc(nrows * sizeof(Func **));

  if (table != NULL) {
    fprintf(stderr, "Allocating the columns.\n");

    for (i = 0; i < nrows; i++) {
      table[i] = (Func **) malloc(ncolumns * sizeof(Func *));
      if (table[i] != NULL) {
        for (j = 0; j < ncolumns; j++) {
          table[i][j] = (Func *) malloc(sizeof(Func));
          (table[i][j])-> f = NULL;
        }
      } else {
        fprintf(stderr,
            "Error in table of target functions allocation (columns).\n");
        result = false;
      }
    }
  } else {
    fprintf(stderr,
        "Error in table of target functions allocation (rows).\n");
    result = false;
  }
  fprintf(stderr, "Allocating the columns is OK.\n");

  /*fprintf(stderr, "Printing.\n");
  for (i = 0; i < nrows; i++) {
    for (j = 0; j < ncolumns; j++) {
      fprintf(stderr, "table[%d][%d]= %p\n", i, j, (table[i][j])->f);
    }
  }
  fprintf(stderr, "Printing OK.\n");*/

  *table_ = table;

  return result;
}

/* ------------------------------------------------------------- */
/* Call the target function. This function is only for standalone tests.
 * other function is called in hookomp.c
*/
void call_function_ffi_call(Func* ff) {
  fprintf(stderr," In call_function_ffi_call.\n");
  ffi_cif cif;

  if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, ff->nargs, ff->ret_type,
      ff->arg_types) != FFI_OK) {
    fprintf(stderr,"Error ffi_prep_cif.\n");
    exit(1);
  }

  ffi_call(&cif, FFI_FN(ff->f), ff->ret_value, ff->arg_values);
}

#endif /* !OFFLOAD*/
