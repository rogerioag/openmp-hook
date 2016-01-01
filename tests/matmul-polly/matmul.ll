; ModuleID = 'matmul.c'
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
  br label %.preheader

.preheader:                                       ; preds = %20, %0
  %indvars.iv3 = phi i64 [ 0, %0 ], [ %indvars.iv.next4, %20 ]
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
  br i1 %exitcond5, label %21, label %.preheader

; <label>:21                                      ; preds = %20
  ret void
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

; <label>:13                                      ; preds = %2, %11
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
  br label %.preheader.i

.preheader.i:                                     ; preds = %20, %0
  %indvars.iv3.i = phi i64 [ 0, %0 ], [ %indvars.iv.next4.i, %20 ]
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

.preheader:                                       ; preds = %.preheader.preheader, %init_array.exit
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
  br i1 %exitcond10, label %44, label %.preheader

; <label>:44                                      ; preds = %init_array.exit
  ret i32 0
}

; Function Attrs: nounwind
declare i32 @fputc(i32, %struct._IO_FILE* nocapture) #2

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final 254107)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!6, !6, i64 0}
!6 = !{!"any pointer", !3, i64 0}
