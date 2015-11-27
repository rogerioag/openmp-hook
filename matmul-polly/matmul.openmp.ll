; ModuleID = 'matmul.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@A = common global [1536 x [1536 x float]] zeroinitializer, align 16
@B = common global [1536 x [1536 x float]] zeroinitializer, align 16
@stdout = external global %struct._IO_FILE*, align 8
@.str = private unnamed_addr constant [5 x i8] c"%lf \00", align 1
@C = common global [1536 x [1536 x float]] zeroinitializer, align 16

; Function Attrs: nounwind uwtable
define void @init_array() #0 {
  %polly.par.userContext = alloca {}
  br label %polly.split_new_and_old

polly.split_new_and_old:                          ; preds = %0
  br i1 or (i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0)), i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0))), label %polly.start, label %.preheader

.preheader:                                       ; preds = %polly.split_new_and_old, %20
  %indvars.iv3 = phi i64 [ 0, %polly.split_new_and_old ], [ %indvars.iv.next4, %20 ]
  br label %1

; <label>:1                                       ; preds = %1, %.preheader
  %indvars.iv = phi i64 [ 0, %.preheader ], [ %indvars.iv.next.1, %1 ]
  %2 = mul nuw nsw i64 %indvars.iv, %indvars.iv3
  %3 = trunc i64 %2 to i32
  %4 = srem i32 %3, 1024
  %5 = or i32 %4, 1
  %6 = sitofp i32 %5 to double
  %7 = fmul double %6, 5.000000e-01
  %8 = fptrunc double %7 to float
  %9 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3, i64 %indvars.iv
  store float %8, float* %9, align 8, !tbaa !1
  %10 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3, i64 %indvars.iv
  store float %8, float* %10, align 8, !tbaa !1
  %indvars.iv.next = or i64 %indvars.iv, 1
  %11 = mul nuw nsw i64 %indvars.iv.next, %indvars.iv3
  %12 = trunc i64 %11 to i32
  %13 = srem i32 %12, 1024
  %14 = add nsw i32 %13, 1
  %15 = sitofp i32 %14 to double
  %16 = fmul double %15, 5.000000e-01
  %17 = fptrunc double %16 to float
  %18 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3, i64 %indvars.iv.next
  store float %17, float* %18, align 4, !tbaa !1
  %19 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3, i64 %indvars.iv.next
  store float %17, float* %19, align 4, !tbaa !1
  %indvars.iv.next.1 = add nsw i64 %indvars.iv, 2
  %exitcond.1 = icmp eq i64 %indvars.iv.next.1, 1536
  br i1 %exitcond.1, label %20, label %1

; <label>:20                                      ; preds = %1
  %indvars.iv.next4 = add nuw nsw i64 %indvars.iv3, 1
  %exitcond5 = icmp eq i64 %indvars.iv.next4, 1536
  br i1 %exitcond5, label %polly.merge_new_and_old, label %.preheader

polly.merge_new_and_old:                          ; preds = %polly.start, %20
  ret void

polly.start:                                      ; preds = %polly.split_new_and_old
  %21 = bitcast {}* %polly.par.userContext to i8*
  call void @llvm.lifetime.start(i64 0, i8* %21)
  %polly.par.userContext1 = bitcast {}* %polly.par.userContext to i8*
  call void @GOMP_parallel_loop_runtime_start(void (i8*)* @init_array.polly.subfn, i8* %polly.par.userContext1, i32 0, i64 0, i64 1536, i64 1)
  call void @init_array.polly.subfn(i8* %polly.par.userContext1)
  call void @GOMP_parallel_end()
  %22 = bitcast {}* %polly.par.userContext to i8*
  call void @llvm.lifetime.end(i64 8, i8* %22)
  br label %polly.merge_new_and_old
}

; Function Attrs: nounwind uwtable
define void @print_array() #0 {
  br label %.preheader

.preheader:                                       ; preds = %15, %0
  %indvars.iv6 = phi i64 [ 0, %0 ], [ %indvars.iv.next7, %15 ]
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8, !tbaa !5
  br label %2

; <label>:2                                       ; preds = %13, %.preheader
  %indvars.iv = phi i64 [ 0, %.preheader ], [ %indvars.iv.next, %13 ]
  %3 = phi %struct._IO_FILE* [ %1, %.preheader ], [ %14, %13 ]
  %4 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv6, i64 %indvars.iv
  %5 = load float, float* %4, align 4, !tbaa !1
  %6 = fpext float %5 to double
  %7 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %3, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str, i64 0, i64 0), double %6) #2
  %8 = trunc i64 %indvars.iv to i32
  %9 = srem i32 %8, 80
  %10 = icmp eq i32 %9, 79
  br i1 %10, label %11, label %13

; <label>:11                                      ; preds = %2
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8, !tbaa !5
  %fputc3 = tail call i32 @fputc(i32 10, %struct._IO_FILE* %12)
  br label %13

; <label>:13                                      ; preds = %11, %2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %14 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8, !tbaa !5
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
  %.lcssa.phiops = alloca float
  %.phiops = alloca float
  %polly.par.userContext = alloca {}
  br label %polly.split_new_and_old

polly.split_new_and_old:                          ; preds = %0
  br i1 and (i1 and (i1 or (i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0), i64 -3072)), i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0))), i1 or (i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0), i64 -3072)), i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i32 0, i32 0, i32 0)))), i1 or (i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0)), i1 icmp ule (float* getelementptr (float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i32 0, i32 0, i32 0), i64 2359296), float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i32 0, i32 0, i32 0)))), label %polly.start, label %.preheader.i

.preheader.i:                                     ; preds = %polly.split_new_and_old, %20
  %indvars.iv3.i = phi i64 [ 0, %polly.split_new_and_old ], [ %indvars.iv.next4.i, %20 ]
  br label %1

; <label>:1                                       ; preds = %1, %.preheader.i
  %indvars.iv.i = phi i64 [ 0, %.preheader.i ], [ %indvars.iv.next.i.1, %1 ]
  %2 = mul nuw nsw i64 %indvars.iv.i, %indvars.iv3.i
  %3 = trunc i64 %2 to i32
  %4 = srem i32 %3, 1024
  %5 = or i32 %4, 1
  %6 = sitofp i32 %5 to double
  %7 = fmul double %6, 5.000000e-01
  %8 = fptrunc double %7 to float
  %9 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3.i, i64 %indvars.iv.i
  store float %8, float* %9, align 8, !tbaa !1
  %10 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3.i, i64 %indvars.iv.i
  store float %8, float* %10, align 8, !tbaa !1
  %indvars.iv.next.i = or i64 %indvars.iv.i, 1
  %11 = mul nuw nsw i64 %indvars.iv.next.i, %indvars.iv3.i
  %12 = trunc i64 %11 to i32
  %13 = srem i32 %12, 1024
  %14 = add nsw i32 %13, 1
  %15 = sitofp i32 %14 to double
  %16 = fmul double %15, 5.000000e-01
  %17 = fptrunc double %16 to float
  %18 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3.i, i64 %indvars.iv.next.i
  store float %17, float* %18, align 4, !tbaa !1
  %19 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3.i, i64 %indvars.iv.next.i
  store float %17, float* %19, align 4, !tbaa !1
  %indvars.iv.next.i.1 = add nsw i64 %indvars.iv.i, 2
  %exitcond.i.1 = icmp eq i64 %indvars.iv.next.i.1, 1536
  br i1 %exitcond.i.1, label %20, label %1

; <label>:20                                      ; preds = %1
  %indvars.iv.next4.i = add nuw nsw i64 %indvars.iv3.i, 1
  %exitcond5.i = icmp eq i64 %indvars.iv.next4.i, 1536
  br i1 %exitcond5.i, label %.preheader.preheader, label %.preheader.i

.preheader.preheader:                             ; preds = %20
  br label %.preheader

.preheader:                                       ; preds = %init_array.exit, %.preheader.preheader
  %indvars.iv8 = phi i64 [ %indvars.iv.next9, %init_array.exit ], [ 0, %.preheader.preheader ]
  br label %21

; <label>:21                                      ; preds = %43, %.preheader
  %indvars.iv4 = phi i64 [ 0, %.preheader ], [ %indvars.iv.next5, %43 ]
  %22 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv8, i64 %indvars.iv4
  store float 0.000000e+00, float* %22, align 4, !tbaa !1
  br label %23

; <label>:23                                      ; preds = %23, %21
  %indvars.iv = phi i64 [ 0, %21 ], [ %indvars.iv.next.2, %23 ]
  %24 = phi float [ 0.000000e+00, %21 ], [ %42, %23 ]
  %25 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv8, i64 %indvars.iv
  %26 = load float, float* %25, align 4, !tbaa !1
  %27 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv, i64 %indvars.iv4
  %28 = load float, float* %27, align 4, !tbaa !1
  %29 = fmul float %26, %28
  %30 = fadd float %24, %29
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %31 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv8, i64 %indvars.iv.next
  %32 = load float, float* %31, align 4, !tbaa !1
  %33 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv.next, i64 %indvars.iv4
  %34 = load float, float* %33, align 4, !tbaa !1
  %35 = fmul float %32, %34
  %36 = fadd float %30, %35
  %indvars.iv.next.1 = add nsw i64 %indvars.iv, 2
  %37 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv8, i64 %indvars.iv.next.1
  %38 = load float, float* %37, align 4, !tbaa !1
  %39 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv.next.1, i64 %indvars.iv4
  %40 = load float, float* %39, align 4, !tbaa !1
  %41 = fmul float %38, %40
  %42 = fadd float %36, %41
  %indvars.iv.next.2 = add nsw i64 %indvars.iv, 3
  %exitcond.2 = icmp eq i64 %indvars.iv.next.2, 1536
  br i1 %exitcond.2, label %43, label %23

; <label>:43                                      ; preds = %23
  %.lcssa = phi float [ %42, %23 ]
  store float %.lcssa, float* %22, align 4, !tbaa !1
  %indvars.iv.next5 = add nuw nsw i64 %indvars.iv4, 1
  %exitcond6 = icmp eq i64 %indvars.iv.next5, 1536
  br i1 %exitcond6, label %init_array.exit, label %21

init_array.exit:                                  ; preds = %43
  %indvars.iv.next9 = add nuw nsw i64 %indvars.iv8, 1
  %exitcond10 = icmp eq i64 %indvars.iv.next9, 1536
  br i1 %exitcond10, label %polly.merge_new_and_old, label %.preheader

polly.merge_new_and_old:                          ; preds = %polly.loop_exit, %init_array.exit
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
  br label %polly.loop_preheader

polly.loop_exit:                                  ; preds = %polly.loop_exit4
  br label %polly.merge_new_and_old

polly.loop_header:                                ; preds = %polly.loop_exit4, %polly.loop_preheader
  %polly.indvar = phi i64 [ 0, %polly.loop_preheader ], [ %polly.indvar_next, %polly.loop_exit4 ]
  br label %polly.loop_preheader3

polly.loop_exit4:                                 ; preds = %polly.stmt.38
  %polly.indvar_next = add nsw i64 %polly.indvar, 1
  %polly.loop_cond = icmp sle i64 %polly.indvar, 1534
  br i1 %polly.loop_cond, label %polly.loop_header, label %polly.loop_exit

polly.loop_preheader:                             ; preds = %polly.start
  br label %polly.loop_header

polly.loop_header2:                               ; preds = %polly.stmt.38, %polly.loop_preheader3
  %polly.indvar5 = phi i64 [ 0, %polly.loop_preheader3 ], [ %polly.indvar_next6, %polly.stmt.38 ]
  br label %polly.stmt.

polly.stmt.:                                      ; preds = %polly.loop_header2
  %scevgep8 = getelementptr float, float* %scevgep, i64 %polly.indvar5
  store float 0.000000e+00, float* %scevgep8, align 4, !alias.scope !7, !noalias !9
  store float 0.000000e+00, float* %.phiops
  br label %polly.loop_preheader10

polly.loop_exit11:                                ; preds = %polly.stmt.15
  br label %polly.stmt.38

polly.stmt.38:                                    ; preds = %polly.loop_exit11
  %.lcssa.phiops.reload = load float, float* %.lcssa.phiops
  %scevgep40 = getelementptr float, float* %scevgep39, i64 %polly.indvar5
  store float %.lcssa.phiops.reload, float* %scevgep40, align 4, !alias.scope !7, !noalias !9
  %46 = add i64 %polly.indvar5, 1
  %p_exitcond6 = icmp eq i64 %46, 1536
  %polly.indvar_next6 = add nsw i64 %polly.indvar5, 1
  %polly.loop_cond7 = icmp sle i64 %polly.indvar5, 1534
  br i1 %polly.loop_cond7, label %polly.loop_header2, label %polly.loop_exit4

polly.loop_preheader3:                            ; preds = %polly.loop_header
  %scevgep = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %polly.indvar, i64 0
  %scevgep16 = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %polly.indvar, i64 0
  %47 = mul i64 %polly.indvar, 1536
  %scevgep22 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 0, i64 1), i64 %47
  %scevgep30 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 0, i64 2), i64 %47
  %scevgep39 = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %polly.indvar, i64 0
  br label %polly.loop_header2

polly.loop_header9:                               ; preds = %polly.stmt.15, %polly.loop_preheader10
  %polly.indvar12 = phi i64 [ 0, %polly.loop_preheader10 ], [ %polly.indvar_next13, %polly.stmt.15 ]
  br label %polly.stmt.15

polly.stmt.15:                                    ; preds = %polly.loop_header9
  %48 = mul i64 %polly.indvar12, 3
  %.phiops.reload = load float, float* %.phiops
  %scevgep17 = getelementptr float, float* %scevgep16, i64 %48
  %_p_scalar_ = load float, float* %scevgep17, align 4, !alias.scope !10, !noalias !14
  %49 = mul i64 %polly.indvar12, 4608
  %scevgep19 = getelementptr float, float* %scevgep18, i64 %49
  %_p_scalar_20 = load float, float* %scevgep19, align 4, !alias.scope !13, !noalias !15
  %p_ = fmul float %_p_scalar_, %_p_scalar_20
  %p_21 = fadd float %.phiops.reload, %p_
  %50 = mul i64 %polly.indvar12, 3
  %51 = add i64 %50, 1
  %scevgep23 = getelementptr float, float* %scevgep22, i64 %50
  %_p_scalar_24 = load float, float* %scevgep23, align 4, !alias.scope !10, !noalias !14
  %52 = mul i64 %polly.indvar12, 4608
  %scevgep26 = getelementptr float, float* %scevgep25, i64 %52
  %_p_scalar_27 = load float, float* %scevgep26, align 4, !alias.scope !13, !noalias !15
  %p_28 = fmul float %_p_scalar_24, %_p_scalar_27
  %p_29 = fadd float %p_21, %p_28
  %53 = mul i64 %polly.indvar12, 3
  %54 = add i64 %53, 2
  %scevgep31 = getelementptr float, float* %scevgep30, i64 %53
  %_p_scalar_32 = load float, float* %scevgep31, align 4, !alias.scope !10, !noalias !14
  %55 = mul i64 %polly.indvar12, 4608
  %scevgep34 = getelementptr float, float* %scevgep33, i64 %55
  %_p_scalar_35 = load float, float* %scevgep34, align 4, !alias.scope !13, !noalias !15
  %p_36 = fmul float %_p_scalar_32, %_p_scalar_35
  %p_37 = fadd float %p_29, %p_36
  %56 = mul i64 %polly.indvar12, 3
  %57 = add i64 %56, 3
  %p_exitcond.2 = icmp eq i64 %57, 1536
  store float %p_37, float* %.phiops
  store float %p_37, float* %.lcssa.phiops
  %polly.indvar_next13 = add nsw i64 %polly.indvar12, 1
  %polly.loop_cond14 = icmp sle i64 %polly.indvar12, 510
  br i1 %polly.loop_cond14, label %polly.loop_header9, label %polly.loop_exit11

polly.loop_preheader10:                           ; preds = %polly.stmt.
  %scevgep18 = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 0, i64 %polly.indvar5
  %scevgep25 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 1, i64 0), i64 %polly.indvar5
  %scevgep33 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 2, i64 0), i64 %polly.indvar5
  br label %polly.loop_header9
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
  %polly.par.LB = load i64, i64* %polly.par.LBPtr
  %polly.par.UB = load i64, i64* %polly.par.UBPtr
  %polly.par.UBAdjusted = sub i64 %polly.par.UB, 1
  br label %polly.loop_preheader

polly.loop_exit:                                  ; preds = %polly.loop_exit4
  br label %polly.par.checkNext

polly.loop_header:                                ; preds = %polly.loop_exit4, %polly.loop_preheader
  %polly.indvar = phi i64 [ %polly.par.LB, %polly.loop_preheader ], [ %polly.indvar_next, %polly.loop_exit4 ]
  br label %polly.loop_preheader3

polly.loop_exit4:                                 ; preds = %polly.stmt.
  %polly.indvar_next = add nsw i64 %polly.indvar, 1
  %polly.adjust_ub = sub i64 %polly.par.UBAdjusted, 1
  %polly.loop_cond = icmp sle i64 %polly.indvar, %polly.adjust_ub
  br i1 %polly.loop_cond, label %polly.loop_header, label %polly.loop_exit

polly.loop_preheader:                             ; preds = %polly.par.loadIVBounds
  br label %polly.loop_header

polly.loop_header2:                               ; preds = %polly.stmt., %polly.loop_preheader3
  %polly.indvar5 = phi i64 [ 0, %polly.loop_preheader3 ], [ %polly.indvar_next6, %polly.stmt. ]
  br label %polly.stmt.

polly.stmt.:                                      ; preds = %polly.loop_header2
  %2 = shl i64 %polly.indvar5, 1
  %3 = mul i64 %15, %polly.indvar5
  %4 = trunc i64 %polly.indvar5 to i32
  %5 = mul i32 %17, %4
  %p_ = srem i32 %5, 1024
  %p_8 = or i32 %p_, 1
  %p_9 = sitofp i32 %p_8 to double
  %p_10 = fmul double %p_9, 5.000000e-01
  %p_11 = fptrunc double %p_10 to float
  %6 = shl i64 %polly.indvar5, 1
  %scevgep12 = getelementptr float, float* %scevgep, i64 %6
  store float %p_11, float* %scevgep12, align 8, !alias.scope !16, !noalias !18, !llvm.mem.parallel_loop_access !20
  %scevgep14 = getelementptr float, float* %scevgep13, i64 %6
  store float %p_11, float* %scevgep14, align 8, !alias.scope !19, !noalias !21, !llvm.mem.parallel_loop_access !20
  %7 = add i64 %6, 1
  %8 = mul i64 %polly.indvar, %7
  %9 = trunc i64 %polly.indvar5 to i32
  %10 = shl i32 %9, 1
  %11 = add i32 %10, 1
  %12 = mul i32 %18, %11
  %p_15 = srem i32 %12, 1024
  %p_16 = add nsw i32 %p_15, 1
  %p_17 = sitofp i32 %p_16 to double
  %p_18 = fmul double %p_17, 5.000000e-01
  %p_19 = fptrunc double %p_18 to float
  %13 = shl i64 %polly.indvar5, 1
  %scevgep21 = getelementptr float, float* %scevgep20, i64 %13
  store float %p_19, float* %scevgep21, align 4, !alias.scope !16, !noalias !18, !llvm.mem.parallel_loop_access !20
  %scevgep23 = getelementptr float, float* %scevgep22, i64 %13
  store float %p_19, float* %scevgep23, align 4, !alias.scope !19, !noalias !21, !llvm.mem.parallel_loop_access !20
  %14 = add i64 %13, 2
  %p_exitcond.1 = icmp eq i64 %14, 1536
  %polly.indvar_next6 = add nsw i64 %polly.indvar5, 1
  %polly.loop_cond7 = icmp sle i64 %polly.indvar5, 766
  br i1 %polly.loop_cond7, label %polly.loop_header2, label %polly.loop_exit4, !llvm.loop !20

polly.loop_preheader3:                            ; preds = %polly.loop_header
  %15 = shl i64 %polly.indvar, 1
  %16 = trunc i64 %polly.indvar to i32
  %17 = shl i32 %16, 1
  %scevgep = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %polly.indvar, i64 0
  %scevgep13 = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %polly.indvar, i64 0
  %18 = trunc i64 %polly.indvar to i32
  %19 = mul i64 %polly.indvar, 1536
  %scevgep20 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 0, i64 1), i64 %19
  %scevgep22 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 0, i64 1), i64 %19
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
  %polly.par.LB = load i64, i64* %polly.par.LBPtr
  %polly.par.UB = load i64, i64* %polly.par.UBPtr
  %polly.par.UBAdjusted = sub i64 %polly.par.UB, 1
  br label %polly.loop_preheader

polly.loop_exit:                                  ; preds = %polly.loop_exit4
  br label %polly.par.checkNext

polly.loop_header:                                ; preds = %polly.loop_exit4, %polly.loop_preheader
  %polly.indvar = phi i64 [ %polly.par.LB, %polly.loop_preheader ], [ %polly.indvar_next, %polly.loop_exit4 ]
  br label %polly.loop_preheader3

polly.loop_exit4:                                 ; preds = %polly.stmt.
  %polly.indvar_next = add nsw i64 %polly.indvar, 1
  %polly.adjust_ub = sub i64 %polly.par.UBAdjusted, 1
  %polly.loop_cond = icmp sle i64 %polly.indvar, %polly.adjust_ub
  br i1 %polly.loop_cond, label %polly.loop_header, label %polly.loop_exit

polly.loop_preheader:                             ; preds = %polly.par.loadIVBounds
  br label %polly.loop_header

polly.loop_header2:                               ; preds = %polly.stmt., %polly.loop_preheader3
  %polly.indvar5 = phi i64 [ 0, %polly.loop_preheader3 ], [ %polly.indvar_next6, %polly.stmt. ]
  br label %polly.stmt.

polly.stmt.:                                      ; preds = %polly.loop_header2
  %2 = shl i64 %polly.indvar5, 1
  %3 = mul i64 %15, %polly.indvar5
  %4 = trunc i64 %polly.indvar5 to i32
  %5 = mul i32 %17, %4
  %p_ = srem i32 %5, 1024
  %p_8 = or i32 %p_, 1
  %p_9 = sitofp i32 %p_8 to double
  %p_10 = fmul double %p_9, 5.000000e-01
  %p_11 = fptrunc double %p_10 to float
  %6 = shl i64 %polly.indvar5, 1
  %scevgep12 = getelementptr float, float* %scevgep, i64 %6
  store float %p_11, float* %scevgep12, align 8, !alias.scope !10, !noalias !14, !llvm.mem.parallel_loop_access !22
  %scevgep14 = getelementptr float, float* %scevgep13, i64 %6
  store float %p_11, float* %scevgep14, align 8, !alias.scope !13, !noalias !15, !llvm.mem.parallel_loop_access !22
  %7 = add i64 %6, 1
  %8 = mul i64 %polly.indvar, %7
  %9 = trunc i64 %polly.indvar5 to i32
  %10 = shl i32 %9, 1
  %11 = add i32 %10, 1
  %12 = mul i32 %18, %11
  %p_15 = srem i32 %12, 1024
  %p_16 = add nsw i32 %p_15, 1
  %p_17 = sitofp i32 %p_16 to double
  %p_18 = fmul double %p_17, 5.000000e-01
  %p_19 = fptrunc double %p_18 to float
  %13 = shl i64 %polly.indvar5, 1
  %scevgep21 = getelementptr float, float* %scevgep20, i64 %13
  store float %p_19, float* %scevgep21, align 4, !alias.scope !10, !noalias !14, !llvm.mem.parallel_loop_access !22
  %scevgep23 = getelementptr float, float* %scevgep22, i64 %13
  store float %p_19, float* %scevgep23, align 4, !alias.scope !13, !noalias !15, !llvm.mem.parallel_loop_access !22
  %14 = add i64 %13, 2
  %p_exitcond.i.1 = icmp eq i64 %14, 1536
  %polly.indvar_next6 = add nsw i64 %polly.indvar5, 1
  %polly.loop_cond7 = icmp sle i64 %polly.indvar5, 766
  br i1 %polly.loop_cond7, label %polly.loop_header2, label %polly.loop_exit4, !llvm.loop !22

polly.loop_preheader3:                            ; preds = %polly.loop_header
  %15 = shl i64 %polly.indvar, 1
  %16 = trunc i64 %polly.indvar to i32
  %17 = shl i32 %16, 1
  %scevgep = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %polly.indvar, i64 0
  %scevgep13 = getelementptr [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %polly.indvar, i64 0
  %18 = trunc i64 %polly.indvar to i32
  %19 = mul i64 %polly.indvar, 1536
  %scevgep20 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 0, i64 1), i64 %19
  %scevgep22 = getelementptr float, float* getelementptr inbounds ([1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 0, i64 1), i64 %19
  br label %polly.loop_header2
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }
attributes #3 = { "polly.skip.fn" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final 254107)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!6, !6, i64 0}
!6 = !{!"any pointer", !3, i64 0}
!7 = distinct !{!7, !8, !"polly.alias.scope.C"}
!8 = distinct !{!8, !"polly.alias.scope.domain"}
!9 = !{!10, !11, !12, !13}
!10 = distinct !{!10, !8, !"polly.alias.scope.A"}
!11 = distinct !{!11, !8, !"polly.alias.scope."}
!12 = distinct !{!12, !8, !"polly.alias.scope..lcssa"}
!13 = distinct !{!13, !8, !"polly.alias.scope.B"}
!14 = !{!11, !7, !12, !13}
!15 = !{!10, !11, !7, !12}
!16 = distinct !{!16, !17, !"polly.alias.scope.A"}
!17 = distinct !{!17, !"polly.alias.scope.domain"}
!18 = !{!19}
!19 = distinct !{!19, !17, !"polly.alias.scope.B"}
!20 = distinct !{!20}
!21 = !{!16}
!22 = distinct !{!22}
