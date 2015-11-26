; ModuleID = 'matmul.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@A = common global [1536 x [1536 x float]] zeroinitializer, align 16
@B = common global [1536 x [1536 x float]] zeroinitializer, align 16
@stdout = external global %struct._IO_FILE*
@.str = private unnamed_addr constant [5 x i8] c"%lf \00", align 1
@C = common global [1536 x [1536 x float]] zeroinitializer, align 16

; Function Attrs: nounwind uwtable
define void @init_array() #0 {
  %polly.par.userContext = alloca {}
  br label %polly.split_new_and_old

polly.split_new_and_old:                          ; preds = %0
  br i1 or (i1 icmp ule (float* getelementptr (float* getelementptr inbounds ([1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0)), i1 icmp ule (float* getelementptr (float* getelementptr inbounds ([1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0))), label %polly.start, label %vector.ph

vector.ph:                                        ; preds = %polly.split_new_and_old, %middle.block
  %indvars.iv3 = phi i64 [ 0, %polly.split_new_and_old ], [ %indvars.iv.next4, %middle.block ]
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %induction67 = or i64 %index, 1
  %1 = mul nsw i64 %index, %indvars.iv3
  %2 = mul nsw i64 %induction67, %indvars.iv3
  %3 = trunc i64 %1 to i32
  %4 = trunc i64 %2 to i32
  %5 = srem i32 %3, 1024
  %6 = srem i32 %4, 1024
  %7 = or i32 %5, 1
  %8 = add nsw i32 %6, 1
  %9 = sitofp i32 %7 to double
  %10 = sitofp i32 %8 to double
  %11 = fmul double %9, 5.000000e-01
  %12 = fmul double %10, 5.000000e-01
  %13 = fptrunc double %11 to float
  %14 = fptrunc double %12 to float
  %15 = getelementptr inbounds [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3, i64 %index
  %16 = getelementptr inbounds [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3, i64 %induction67
  store float %13, float* %15, align 8, !tbaa !1
  store float %14, float* %16, align 4, !tbaa !1
  %17 = getelementptr inbounds [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3, i64 %index
  %18 = getelementptr inbounds [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3, i64 %induction67
  store float %13, float* %17, align 8, !tbaa !1
  store float %14, float* %18, align 4, !tbaa !1
  %index.next = add i64 %index, 2
  %19 = icmp eq i64 %index.next, 1536
  br i1 %19, label %middle.block, label %vector.body, !llvm.loop !5

middle.block:                                     ; preds = %vector.body
  %indvars.iv.next4 = add nuw nsw i64 %indvars.iv3, 1
  %exitcond5 = icmp eq i64 %indvars.iv.next4, 1536
  br i1 %exitcond5, label %polly.merge_new_and_old, label %vector.ph

polly.merge_new_and_old:                          ; preds = %polly.start, %middle.block
  ret void

polly.start:                                      ; preds = %polly.split_new_and_old
  %20 = bitcast {}* %polly.par.userContext to i8*
  call void @llvm.lifetime.start(i64 0, i8* %20)
  %polly.par.userContext1 = bitcast {}* %polly.par.userContext to i8*
  call void @GOMP_parallel_loop_runtime_start(void (i8*)* @init_array.polly.subfn, i8* %polly.par.userContext1, i32 0, i64 0, i64 1536, i64 1)
  call void @init_array.polly.subfn(i8* %polly.par.userContext1)
  call void @GOMP_parallel_end()
  %21 = bitcast {}* %polly.par.userContext to i8*
  call void @llvm.lifetime.end(i64 8, i8* %21)
  br label %polly.merge_new_and_old
}

; Function Attrs: nounwind uwtable
define void @print_array() #0 {
  br label %.preheader

.preheader:                                       ; preds = %15, %0
  %indvars.iv6 = phi i64 [ 0, %0 ], [ %indvars.iv.next7, %15 ]
  %1 = load %struct._IO_FILE** @stdout, align 8, !tbaa !8
  br label %2

; <label>:2                                       ; preds = %13, %.preheader
  %indvars.iv = phi i64 [ 0, %.preheader ], [ %indvars.iv.next, %13 ]
  %3 = phi %struct._IO_FILE* [ %1, %.preheader ], [ %14, %13 ]
  %4 = getelementptr inbounds [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv6, i64 %indvars.iv
  %5 = load float* %4, align 4, !tbaa !1
  %6 = fpext float %5 to double
  %7 = tail call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %3, i8* getelementptr inbounds ([5 x i8]* @.str, i64 0, i64 0), double %6) #2
  %8 = trunc i64 %indvars.iv to i32
  %9 = srem i32 %8, 80
  %10 = icmp eq i32 %9, 79
  br i1 %10, label %11, label %13

; <label>:11                                      ; preds = %2
  %12 = load %struct._IO_FILE** @stdout, align 8, !tbaa !8
  %fputc3 = tail call i32 @fputc(i32 10, %struct._IO_FILE* %12)
  br label %13

; <label>:13                                      ; preds = %11, %2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %14 = load %struct._IO_FILE** @stdout, align 8, !tbaa !8
  %exitcond = icmp eq i64 %indvars.iv.next, 1536
  br i1 %exitcond, label %15, label %2

; <label>:15                                      ; preds = %13
  %.lcssa = phi %struct._IO_FILE* [ %14, %13 ]
  %fputc = tail call i32 @fputc(i32 10, %struct._IO_FILE* %.lcssa)
  %indvars.iv.next7 = add nuw nsw i64 %indvars.iv6, 1
  %exitcond8 = icmp eq i64 %indvars.iv.next7, 1536
  br i1 %exitcond8, label %16, label %.preheader

; <label>:16                                      ; preds = %15
  ret void
}

; Function Attrs: nounwind
declare i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture readonly, ...) #1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %polly.par.userContext = alloca {}
  br label %polly.split_new_and_old

polly.split_new_and_old:                          ; preds = %0
  br i1 or (i1 icmp ule (float* getelementptr (float* getelementptr inbounds ([1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0)), i1 icmp ule (float* getelementptr (float* getelementptr inbounds ([1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0))), label %polly.start, label %vector.ph

vector.ph:                                        ; preds = %polly.split_new_and_old, %middle.block
  %indvars.iv3.i = phi i64 [ 0, %polly.split_new_and_old ], [ %indvars.iv.next4.i, %middle.block ]
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %induction1112 = or i64 %index, 1
  %1 = mul nsw i64 %index, %indvars.iv3.i
  %2 = mul nsw i64 %induction1112, %indvars.iv3.i
  %3 = trunc i64 %1 to i32
  %4 = trunc i64 %2 to i32
  %5 = srem i32 %3, 1024
  %6 = srem i32 %4, 1024
  %7 = or i32 %5, 1
  %8 = add nsw i32 %6, 1
  %9 = sitofp i32 %7 to double
  %10 = sitofp i32 %8 to double
  %11 = fmul double %9, 5.000000e-01
  %12 = fmul double %10, 5.000000e-01
  %13 = fptrunc double %11 to float
  %14 = fptrunc double %12 to float
  %15 = getelementptr inbounds [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3.i, i64 %index
  %16 = getelementptr inbounds [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3.i, i64 %induction1112
  store float %13, float* %15, align 8, !tbaa !1
  store float %14, float* %16, align 4, !tbaa !1
  %17 = getelementptr inbounds [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3.i, i64 %index
  %18 = getelementptr inbounds [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3.i, i64 %induction1112
  store float %13, float* %17, align 8, !tbaa !1
  store float %14, float* %18, align 4, !tbaa !1
  %index.next = add i64 %index, 2
  %19 = icmp eq i64 %index.next, 1536
  br i1 %19, label %middle.block, label %vector.body, !llvm.loop !10

middle.block:                                     ; preds = %vector.body
  %indvars.iv.next4.i = add nuw nsw i64 %indvars.iv3.i, 1
  %exitcond5.i = icmp eq i64 %indvars.iv.next4.i, 1536
  br i1 %exitcond5.i, label %polly.merge_new_and_old, label %vector.ph

polly.merge_new_and_old:                          ; preds = %polly.start, %middle.block
  br label %.preheader

.preheader:                                       ; preds = %init_array.exit, %polly.merge_new_and_old
  %indvars.iv8 = phi i64 [ %indvars.iv.next9, %init_array.exit ], [ 0, %polly.merge_new_and_old ]
  br label %20

; <label>:20                                      ; preds = %42, %.preheader
  %indvars.iv4 = phi i64 [ 0, %.preheader ], [ %indvars.iv.next5, %42 ]
  %21 = getelementptr inbounds [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv8, i64 %indvars.iv4
  store float 0.000000e+00, float* %21, align 4, !tbaa !1
  br label %22

; <label>:22                                      ; preds = %22, %20
  %indvars.iv = phi i64 [ 0, %20 ], [ %indvars.iv.next.2, %22 ]
  %23 = phi float [ 0.000000e+00, %20 ], [ %41, %22 ]
  %24 = getelementptr inbounds [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv8, i64 %indvars.iv
  %25 = load float* %24, align 4, !tbaa !1
  %26 = getelementptr inbounds [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv, i64 %indvars.iv4
  %27 = load float* %26, align 4, !tbaa !1
  %28 = fmul float %25, %27
  %29 = fadd float %23, %28
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %30 = getelementptr inbounds [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv8, i64 %indvars.iv.next
  %31 = load float* %30, align 4, !tbaa !1
  %32 = getelementptr inbounds [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv.next, i64 %indvars.iv4
  %33 = load float* %32, align 4, !tbaa !1
  %34 = fmul float %31, %33
  %35 = fadd float %29, %34
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv.next, 1
  %36 = getelementptr inbounds [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv8, i64 %indvars.iv.next.1
  %37 = load float* %36, align 4, !tbaa !1
  %38 = getelementptr inbounds [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv.next.1, i64 %indvars.iv4
  %39 = load float* %38, align 4, !tbaa !1
  %40 = fmul float %37, %39
  %41 = fadd float %35, %40
  %indvars.iv.next.2 = add nuw nsw i64 %indvars.iv.next.1, 1
  %exitcond.2 = icmp eq i64 %indvars.iv.next.2, 1536
  br i1 %exitcond.2, label %42, label %22

; <label>:42                                      ; preds = %22
  %.lcssa = phi float [ %41, %22 ]
  store float %.lcssa, float* %21, align 4, !tbaa !1
  %indvars.iv.next5 = add nuw nsw i64 %indvars.iv4, 1
  %exitcond6 = icmp eq i64 %indvars.iv.next5, 1536
  br i1 %exitcond6, label %init_array.exit, label %20

init_array.exit:                                  ; preds = %42
  %indvars.iv.next9 = add nuw nsw i64 %indvars.iv8, 1
  %exitcond10 = icmp eq i64 %indvars.iv.next9, 1536
  br i1 %exitcond10, label %43, label %.preheader

; <label>:43                                      ; preds = %init_array.exit
  ret i32 0

polly.start:                                      ; preds = %polly.split_new_and_old
  %44 = bitcast {}* %polly.par.userContext to i8*
  call void @llvm.lifetime.start(i64 0, i8* %44)
  %polly.par.userContext1 = bitcast {}* %polly.par.userContext to i8*
  call void @GOMP_parallel_loop_runtime_start(void (i8*)* @main.polly.subfn, i8* %polly.par.userContext1, i32 0, i64 0, i64 1536, i64 1)
  call void @main.polly.subfn(i8* %polly.par.userContext1)
  call void @GOMP_parallel_end()
  %45 = bitcast {}* %polly.par.userContext to i8*
  call void @llvm.lifetime.end(i64 8, i8* %45)
  br label %polly.merge_new_and_old
}

; Function Attrs: nounwind
declare i32 @fputc(i32, %struct._IO_FILE* nocapture) #2

; Function Attrs: nounwind
declare void @llvm.lifetime.start(i64, i8* nocapture) #2

define internal void @init_array.polly.subfn(i8* %polly.par.userContext) #3 {
polly.par.setup:
  %polly.par.LBPtr = alloca i64
  %polly.par.UBPtr = alloca i64
  %polly.par.userContext1 = bitcast i8* %polly.par.userContext to {}*
  br label %polly.par.checkNext

polly.par.exit:                                   ; preds = %polly.par.checkNext
  call void @GOMP_loop_end_nowait()
  ret void

polly.par.checkNext:                              ; preds = %polly.loop_exit, %polly.par.setup
  %0 = call i8 @GOMP_loop_runtime_next(i64* %polly.par.LBPtr, i64* %polly.par.UBPtr)
  %1 = icmp ne i8 %0, 0
  br i1 %1, label %polly.par.loadIVBounds, label %polly.par.exit

polly.par.loadIVBounds:                           ; preds = %polly.par.checkNext
  %polly.par.LB = load i64* %polly.par.LBPtr
  %polly.par.UB = load i64* %polly.par.UBPtr
  %polly.par.UBAdjusted = sub i64 %polly.par.UB, 1
  br label %polly.loop_preheader

polly.loop_exit:                                  ; preds = %polly.loop_exit4
  br label %polly.par.checkNext

polly.loop_header:                                ; preds = %polly.loop_exit4, %polly.loop_preheader
  %polly.indvar = phi i64 [ %polly.par.LB, %polly.loop_preheader ], [ %polly.indvar_next, %polly.loop_exit4 ]
  br label %polly.loop_preheader3

polly.loop_exit4:                                 ; preds = %polly.stmt.vector.body
  %polly.indvar_next = add nsw i64 %polly.indvar, 1
  %polly.adjust_ub = sub i64 %polly.par.UBAdjusted, 1
  %polly.loop_cond = icmp sle i64 %polly.indvar, %polly.adjust_ub
  br i1 %polly.loop_cond, label %polly.loop_header, label %polly.loop_exit

polly.loop_preheader:                             ; preds = %polly.par.loadIVBounds
  br label %polly.loop_header

polly.loop_header2:                               ; preds = %polly.stmt.vector.body, %polly.loop_preheader3
  %polly.indvar5 = phi i64 [ 0, %polly.loop_preheader3 ], [ %polly.indvar_next6, %polly.stmt.vector.body ]
  br label %polly.stmt.vector.body

polly.stmt.vector.body:                           ; preds = %polly.loop_header2
  %2 = trunc i64 %polly.indvar5 to i32
  %3 = mul i32 %12, %2
  %p_ = srem i32 %3, 1024
  %4 = trunc i64 %polly.indvar5 to i32
  %5 = mul i32 %4, 2
  %6 = add i32 %5, 1
  %7 = mul i32 %13, %6
  %p_8 = srem i32 %7, 1024
  %p_9 = or i32 %p_, 1
  %p_10 = add nsw i32 %p_8, 1
  %p_11 = sitofp i32 %p_9 to double
  %p_12 = sitofp i32 %p_10 to double
  %p_13 = fmul double %p_11, 5.000000e-01
  %p_14 = fmul double %p_12, 5.000000e-01
  %p_15 = fptrunc double %p_13 to float
  %p_16 = fptrunc double %p_14 to float
  %8 = mul i64 %polly.indvar5, 2
  %scevgep17 = getelementptr float* %scevgep, i64 %8
  store float %p_15, float* %scevgep17, align 8, !alias.scope !11, !noalias !13, !llvm.mem.parallel_loop_access !15
  %scevgep19 = getelementptr float* %scevgep18, i64 %8
  store float %p_16, float* %scevgep19, align 4, !alias.scope !11, !noalias !13, !llvm.mem.parallel_loop_access !15
  %scevgep21 = getelementptr float* %scevgep20, i64 %8
  store float %p_15, float* %scevgep21, align 8, !alias.scope !14, !noalias !16, !llvm.mem.parallel_loop_access !15
  %9 = mul i64 %polly.indvar5, 2
  %scevgep23 = getelementptr float* %scevgep22, i64 %9
  store float %p_16, float* %scevgep23, align 4, !alias.scope !14, !noalias !16, !llvm.mem.parallel_loop_access !15
  %10 = add i64 %9, 2
  %p_24 = icmp eq i64 %10, 1536
  %polly.indvar_next6 = add nsw i64 %polly.indvar5, 1
  %polly.loop_cond7 = icmp sle i64 %polly.indvar5, 766
  br i1 %polly.loop_cond7, label %polly.loop_header2, label %polly.loop_exit4, !llvm.loop !15

polly.loop_preheader3:                            ; preds = %polly.loop_header
  %11 = trunc i64 %polly.indvar to i32
  %12 = mul i32 %11, 2
  %13 = trunc i64 %polly.indvar to i32
  %scevgep = getelementptr [1536 x [1536 x float]]* @A, i64 0, i64 %polly.indvar, i64 0
  %14 = mul i64 %polly.indvar, 1536
  %scevgep18 = getelementptr float* getelementptr inbounds ([1536 x [1536 x float]]* @A, i64 0, i64 0, i64 1), i64 %14
  %scevgep20 = getelementptr [1536 x [1536 x float]]* @B, i64 0, i64 %polly.indvar, i64 0
  %scevgep22 = getelementptr float* getelementptr inbounds ([1536 x [1536 x float]]* @B, i64 0, i64 0, i64 1), i64 %14
  br label %polly.loop_header2
}

declare i8 @GOMP_loop_runtime_next(i64*, i64*)

declare void @GOMP_loop_end_nowait()

declare void @GOMP_parallel_loop_runtime_start(void (i8*)*, i8*, i32, i64, i64, i64)

declare void @GOMP_parallel_end()

; Function Attrs: nounwind
declare void @llvm.lifetime.end(i64, i8* nocapture) #2

define internal void @main.polly.subfn(i8* %polly.par.userContext) #3 {
polly.par.setup:
  %polly.par.LBPtr = alloca i64
  %polly.par.UBPtr = alloca i64
  %polly.par.userContext1 = bitcast i8* %polly.par.userContext to {}*
  br label %polly.par.checkNext

polly.par.exit:                                   ; preds = %polly.par.checkNext
  call void @GOMP_loop_end_nowait()
  ret void

polly.par.checkNext:                              ; preds = %polly.loop_exit, %polly.par.setup
  %0 = call i8 @GOMP_loop_runtime_next(i64* %polly.par.LBPtr, i64* %polly.par.UBPtr)
  %1 = icmp ne i8 %0, 0
  br i1 %1, label %polly.par.loadIVBounds, label %polly.par.exit

polly.par.loadIVBounds:                           ; preds = %polly.par.checkNext
  %polly.par.LB = load i64* %polly.par.LBPtr
  %polly.par.UB = load i64* %polly.par.UBPtr
  %polly.par.UBAdjusted = sub i64 %polly.par.UB, 1
  br label %polly.loop_preheader

polly.loop_exit:                                  ; preds = %polly.loop_exit4
  br label %polly.par.checkNext

polly.loop_header:                                ; preds = %polly.loop_exit4, %polly.loop_preheader
  %polly.indvar = phi i64 [ %polly.par.LB, %polly.loop_preheader ], [ %polly.indvar_next, %polly.loop_exit4 ]
  br label %polly.loop_preheader3

polly.loop_exit4:                                 ; preds = %polly.stmt.vector.body
  %polly.indvar_next = add nsw i64 %polly.indvar, 1
  %polly.adjust_ub = sub i64 %polly.par.UBAdjusted, 1
  %polly.loop_cond = icmp sle i64 %polly.indvar, %polly.adjust_ub
  br i1 %polly.loop_cond, label %polly.loop_header, label %polly.loop_exit

polly.loop_preheader:                             ; preds = %polly.par.loadIVBounds
  br label %polly.loop_header

polly.loop_header2:                               ; preds = %polly.stmt.vector.body, %polly.loop_preheader3
  %polly.indvar5 = phi i64 [ 0, %polly.loop_preheader3 ], [ %polly.indvar_next6, %polly.stmt.vector.body ]
  br label %polly.stmt.vector.body

polly.stmt.vector.body:                           ; preds = %polly.loop_header2
  %2 = trunc i64 %polly.indvar5 to i32
  %3 = mul i32 %12, %2
  %p_ = srem i32 %3, 1024
  %4 = trunc i64 %polly.indvar5 to i32
  %5 = mul i32 %4, 2
  %6 = add i32 %5, 1
  %7 = mul i32 %13, %6
  %p_8 = srem i32 %7, 1024
  %p_9 = or i32 %p_, 1
  %p_10 = add nsw i32 %p_8, 1
  %p_11 = sitofp i32 %p_9 to double
  %p_12 = sitofp i32 %p_10 to double
  %p_13 = fmul double %p_11, 5.000000e-01
  %p_14 = fmul double %p_12, 5.000000e-01
  %p_15 = fptrunc double %p_13 to float
  %p_16 = fptrunc double %p_14 to float
  %8 = mul i64 %polly.indvar5, 2
  %scevgep17 = getelementptr float* %scevgep, i64 %8
  store float %p_15, float* %scevgep17, align 8, !alias.scope !17, !noalias !19, !llvm.mem.parallel_loop_access !21
  %scevgep19 = getelementptr float* %scevgep18, i64 %8
  store float %p_16, float* %scevgep19, align 4, !alias.scope !17, !noalias !19, !llvm.mem.parallel_loop_access !21
  %scevgep21 = getelementptr float* %scevgep20, i64 %8
  store float %p_15, float* %scevgep21, align 8, !alias.scope !20, !noalias !22, !llvm.mem.parallel_loop_access !21
  %9 = mul i64 %polly.indvar5, 2
  %scevgep23 = getelementptr float* %scevgep22, i64 %9
  store float %p_16, float* %scevgep23, align 4, !alias.scope !20, !noalias !22, !llvm.mem.parallel_loop_access !21
  %10 = add i64 %9, 2
  %p_24 = icmp eq i64 %10, 1536
  %polly.indvar_next6 = add nsw i64 %polly.indvar5, 1
  %polly.loop_cond7 = icmp sle i64 %polly.indvar5, 766
  br i1 %polly.loop_cond7, label %polly.loop_header2, label %polly.loop_exit4, !llvm.loop !21

polly.loop_preheader3:                            ; preds = %polly.loop_header
  %11 = trunc i64 %polly.indvar to i32
  %12 = mul i32 %11, 2
  %13 = trunc i64 %polly.indvar to i32
  %scevgep = getelementptr [1536 x [1536 x float]]* @A, i64 0, i64 %polly.indvar, i64 0
  %14 = mul i64 %polly.indvar, 1536
  %scevgep18 = getelementptr float* getelementptr inbounds ([1536 x [1536 x float]]* @A, i64 0, i64 0, i64 1), i64 %14
  %scevgep20 = getelementptr [1536 x [1536 x float]]* @B, i64 0, i64 %polly.indvar, i64 0
  %scevgep22 = getelementptr float* getelementptr inbounds ([1536 x [1536 x float]]* @B, i64 0, i64 0, i64 1), i64 %14
  br label %polly.loop_header2
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }
attributes #3 = { "polly.skip.fn" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.6.2 (tags/RELEASE_362/final 244750)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = distinct !{!5, !6, !7}
!6 = !{!"llvm.loop.vectorize.width", i32 1}
!7 = !{!"llvm.loop.interleave.count", i32 1}
!8 = !{!9, !9, i64 0}
!9 = !{!"any pointer", !3, i64 0}
!10 = distinct !{!10, !6, !7}
!11 = distinct !{!11, !12, !"polly.alias.scope.A"}
!12 = distinct !{!12, !"polly.alias.scope.domain"}
!13 = !{!14}
!14 = distinct !{!14, !12, !"polly.alias.scope.B"}
!15 = distinct !{!15}
!16 = !{!11}
!17 = distinct !{!17, !18, !"polly.alias.scope.A"}
!18 = distinct !{!18, !"polly.alias.scope.domain"}
!19 = !{!20}
!20 = distinct !{!20, !18, !"polly.alias.scope.B"}
!21 = distinct !{!21}
!22 = !{!17}
