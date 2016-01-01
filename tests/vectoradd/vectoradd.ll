; ModuleID = 'vectoradd.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@stdout = external global %struct._IO_FILE*
@.str = private unnamed_addr constant [29 x i8] c"Initialize vectors on host:\0A\00", align 1
@h_a = common global [1024 x float] zeroinitializer, align 16
@h_b = common global [1024 x float] zeroinitializer, align 16
@.str1 = private unnamed_addr constant [29 x i8] c"Printing the vector result:\0A\00", align 1
@.str2 = private unnamed_addr constant [13 x i8] c"h_c[%d]: %f\0A\00", align 1
@h_c = common global [1024 x float] zeroinitializer, align 16
@.str3 = private unnamed_addr constant [24 x i8] c"Final Result: (%f, %f)\0A\00", align 1

; Function Attrs: nounwind uwtable
define void @init_array() #0 {
overflow.checked:
  %0 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %1 = tail call i64 @fwrite(i8* getelementptr inbounds ([29 x i8]* @.str, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %0)
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %overflow.checked
  %index = phi i64 [ 0, %overflow.checked ], [ %index.next.1, %vector.body ]
  %2 = getelementptr inbounds [1024 x float]* @h_a, i64 0, i64 %index
  %3 = bitcast float* %2 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %3, align 16, !tbaa !5
  %.sum3 = or i64 %index, 4
  %4 = getelementptr [1024 x float]* @h_a, i64 0, i64 %.sum3
  %5 = bitcast float* %4 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %5, align 16, !tbaa !5
  %6 = getelementptr inbounds [1024 x float]* @h_b, i64 0, i64 %index
  %7 = bitcast float* %6 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %7, align 16, !tbaa !5
  %.sum4 = or i64 %index, 4
  %8 = getelementptr [1024 x float]* @h_b, i64 0, i64 %.sum4
  %9 = bitcast float* %8 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %9, align 16, !tbaa !5
  %index.next = add nuw nsw i64 %index, 8
  %10 = getelementptr inbounds [1024 x float]* @h_a, i64 0, i64 %index.next
  %11 = bitcast float* %10 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %11, align 16, !tbaa !5
  %.sum3.1 = or i64 %index.next, 4
  %12 = getelementptr [1024 x float]* @h_a, i64 0, i64 %.sum3.1
  %13 = bitcast float* %12 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %13, align 16, !tbaa !5
  %14 = getelementptr inbounds [1024 x float]* @h_b, i64 0, i64 %index.next
  %15 = bitcast float* %14 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %15, align 16, !tbaa !5
  %.sum4.1 = or i64 %index.next, 4
  %16 = getelementptr [1024 x float]* @h_b, i64 0, i64 %.sum4.1
  %17 = bitcast float* %16 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %17, align 16, !tbaa !5
  %index.next.1 = add nuw nsw i64 %index.next, 8
  %18 = icmp eq i64 %index.next.1, 1024
  br i1 %18, label %middle.block, label %vector.body, !llvm.loop !7

middle.block:                                     ; preds = %vector.body
  ret void
}

; Function Attrs: nounwind
declare i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture readonly, ...) #1

; Function Attrs: nounwind uwtable
define void @print_array() #0 {
  %1 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %2 = tail call i64 @fwrite(i8* getelementptr inbounds ([29 x i8]* @.str1, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %1)
  br label %3

; <label>:3                                       ; preds = %3, %0
  %indvars.iv = phi i64 [ 0, %0 ], [ %indvars.iv.next, %3 ]
  %4 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %5 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv
  %6 = load float* %5, align 4, !tbaa !5
  %7 = fpext float %6 to double
  %8 = trunc i64 %indvars.iv to i32
  %9 = tail call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %4, i8* getelementptr inbounds ([13 x i8]* @.str2, i64 0, i64 0), i32 %8, double %7) #2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 1024
  br i1 %exitcond, label %10, label %3

; <label>:10                                      ; preds = %3
  ret void
}

; Function Attrs: nounwind uwtable
define void @check_result() #0 {
  br label %1

; <label>:1                                       ; preds = %1, %0
  %indvars.iv = phi i64 [ 0, %0 ], [ %indvars.iv.next.3, %1 ]
  %sum.02 = phi float [ 0.000000e+00, %0 ], [ %13, %1 ]
  %2 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv
  %3 = load float* %2, align 4, !tbaa !5
  %4 = fadd float %sum.02, %3
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %5 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.next
  %6 = load float* %5, align 4, !tbaa !5
  %7 = fadd float %4, %6
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv.next, 1
  %8 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.next.1
  %9 = load float* %8, align 4, !tbaa !5
  %10 = fadd float %7, %9
  %indvars.iv.next.2 = add nuw nsw i64 %indvars.iv.next.1, 1
  %11 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.next.2
  %12 = load float* %11, align 4, !tbaa !5
  %13 = fadd float %10, %12
  %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv.next.2, 1
  %exitcond.3 = icmp eq i64 %indvars.iv.next.3, 1024
  br i1 %exitcond.3, label %14, label %1

; <label>:14                                      ; preds = %1
  %.lcssa = phi float [ %13, %1 ]
  %15 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %16 = fpext float %.lcssa to double
  %17 = fmul float %.lcssa, 9.765625e-04
  %18 = fpext float %17 to double
  %19 = tail call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %15, i8* getelementptr inbounds ([24 x i8]* @.str3, i64 0, i64 0), double %16, double %18) #2
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
overflow.checked:
  %0 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %1 = tail call i64 @fwrite(i8* getelementptr inbounds ([29 x i8]* @.str, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %0) #2
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %overflow.checked
  %index = phi i64 [ 0, %overflow.checked ], [ %index.next.1, %vector.body ]
  %2 = getelementptr inbounds [1024 x float]* @h_a, i64 0, i64 %index
  %3 = bitcast float* %2 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %3, align 16, !tbaa !5
  %.sum30 = or i64 %index, 4
  %4 = getelementptr [1024 x float]* @h_a, i64 0, i64 %.sum30
  %5 = bitcast float* %4 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %5, align 16, !tbaa !5
  %6 = getelementptr inbounds [1024 x float]* @h_b, i64 0, i64 %index
  %7 = bitcast float* %6 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %7, align 16, !tbaa !5
  %.sum31 = or i64 %index, 4
  %8 = getelementptr [1024 x float]* @h_b, i64 0, i64 %.sum31
  %9 = bitcast float* %8 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %9, align 16, !tbaa !5
  %index.next = add nuw nsw i64 %index, 8
  %10 = getelementptr inbounds [1024 x float]* @h_a, i64 0, i64 %index.next
  %11 = bitcast float* %10 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %11, align 16, !tbaa !5
  %.sum30.1 = or i64 %index.next, 4
  %12 = getelementptr [1024 x float]* @h_a, i64 0, i64 %.sum30.1
  %13 = bitcast float* %12 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %13, align 16, !tbaa !5
  %14 = getelementptr inbounds [1024 x float]* @h_b, i64 0, i64 %index.next
  %15 = bitcast float* %14 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %15, align 16, !tbaa !5
  %.sum31.1 = or i64 %index.next, 4
  %16 = getelementptr [1024 x float]* @h_b, i64 0, i64 %.sum31.1
  %17 = bitcast float* %16 to <4 x float>*
  store <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float>* %17, align 16, !tbaa !5
  %index.next.1 = add nuw nsw i64 %index.next, 8
  %18 = icmp eq i64 %index.next.1, 1024
  br i1 %18, label %vector.body12.preheader, label %vector.body, !llvm.loop !10

vector.body12.preheader:                          ; preds = %vector.body
  br label %vector.body12

vector.body12:                                    ; preds = %vector.body12.preheader, %vector.body12
  %index15 = phi i64 [ %index.next22, %vector.body12 ], [ 0, %vector.body12.preheader ]
  %19 = getelementptr inbounds [1024 x float]* @h_a, i64 0, i64 %index15
  %20 = bitcast float* %19 to <4 x float>*
  %wide.load = load <4 x float>* %20, align 16, !tbaa !5
  %.sum32 = or i64 %index15, 4
  %21 = getelementptr [1024 x float]* @h_a, i64 0, i64 %.sum32
  %22 = bitcast float* %21 to <4 x float>*
  %wide.load27 = load <4 x float>* %22, align 16, !tbaa !5
  %23 = getelementptr inbounds [1024 x float]* @h_b, i64 0, i64 %index15
  %24 = bitcast float* %23 to <4 x float>*
  %wide.load28 = load <4 x float>* %24, align 16, !tbaa !5
  %.sum33 = or i64 %index15, 4
  %25 = getelementptr [1024 x float]* @h_b, i64 0, i64 %.sum33
  %26 = bitcast float* %25 to <4 x float>*
  %wide.load29 = load <4 x float>* %26, align 16, !tbaa !5
  %27 = fadd <4 x float> %wide.load, %wide.load28
  %28 = fadd <4 x float> %wide.load27, %wide.load29
  %29 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %index15
  %30 = bitcast float* %29 to <4 x float>*
  store <4 x float> %27, <4 x float>* %30, align 16, !tbaa !5
  %.sum34 = or i64 %index15, 4
  %31 = getelementptr [1024 x float]* @h_c, i64 0, i64 %.sum34
  %32 = bitcast float* %31 to <4 x float>*
  store <4 x float> %28, <4 x float>* %32, align 16, !tbaa !5
  %index.next22 = add i64 %index15, 8
  %33 = icmp eq i64 %index.next22, 1024
  br i1 %33, label %middle.block13, label %vector.body12, !llvm.loop !11

middle.block13:                                   ; preds = %vector.body12
  %34 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %35 = tail call i64 @fwrite(i8* getelementptr inbounds ([29 x i8]* @.str1, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %34) #2
  br label %36

; <label>:36                                      ; preds = %36, %middle.block13
  %indvars.iv.i1 = phi i64 [ 0, %middle.block13 ], [ %indvars.iv.next.i2, %36 ]
  %37 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %38 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.i1
  %39 = load float* %38, align 4, !tbaa !5
  %40 = fpext float %39 to double
  %41 = trunc i64 %indvars.iv.i1 to i32
  %42 = tail call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %37, i8* getelementptr inbounds ([13 x i8]* @.str2, i64 0, i64 0), i32 %41, double %40) #2
  %indvars.iv.next.i2 = add nuw nsw i64 %indvars.iv.i1, 1
  %exitcond.i3 = icmp eq i64 %indvars.iv.next.i2, 1024
  br i1 %exitcond.i3, label %print_array.exit.preheader, label %36

print_array.exit.preheader:                       ; preds = %36
  br label %print_array.exit

print_array.exit:                                 ; preds = %print_array.exit, %print_array.exit.preheader
  %indvars.iv.i4 = phi i64 [ 0, %print_array.exit.preheader ], [ %indvars.iv.next.i5.3, %print_array.exit ]
  %sum.02.i = phi float [ 0.000000e+00, %print_array.exit.preheader ], [ %54, %print_array.exit ]
  %43 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.i4
  %44 = load float* %43, align 4, !tbaa !5
  %45 = fadd float %sum.02.i, %44
  %indvars.iv.next.i5 = add nuw nsw i64 %indvars.iv.i4, 1
  %46 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.next.i5
  %47 = load float* %46, align 4, !tbaa !5
  %48 = fadd float %45, %47
  %indvars.iv.next.i5.1 = add nuw nsw i64 %indvars.iv.next.i5, 1
  %49 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.next.i5.1
  %50 = load float* %49, align 4, !tbaa !5
  %51 = fadd float %48, %50
  %indvars.iv.next.i5.2 = add nuw nsw i64 %indvars.iv.next.i5.1, 1
  %52 = getelementptr inbounds [1024 x float]* @h_c, i64 0, i64 %indvars.iv.next.i5.2
  %53 = load float* %52, align 4, !tbaa !5
  %54 = fadd float %51, %53
  %indvars.iv.next.i5.3 = add nuw nsw i64 %indvars.iv.next.i5.2, 1
  %exitcond.i6.3 = icmp eq i64 %indvars.iv.next.i5.3, 1024
  br i1 %exitcond.i6.3, label %check_result.exit, label %print_array.exit

check_result.exit:                                ; preds = %print_array.exit
  %.lcssa = phi float [ %54, %print_array.exit ]
  %55 = load %struct._IO_FILE** @stdout, align 8, !tbaa !1
  %56 = fpext float %.lcssa to double
  %57 = fmul float %.lcssa, 9.765625e-04
  %58 = fpext float %57 to double
  %59 = tail call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %55, i8* getelementptr inbounds ([24 x i8]* @.str3, i64 0, i64 0), double %56, double %58) #2
  ret i32 0
}

; Function Attrs: nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE* nocapture) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.6.0 (tags/RELEASE_360/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"any pointer", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!6, !6, i64 0}
!6 = !{!"float", !3, i64 0}
!7 = distinct !{!7, !8, !9}
!8 = !{!"llvm.loop.vectorize.width", i32 1}
!9 = !{!"llvm.loop.interleave.count", i32 1}
!10 = distinct !{!10, !8, !9}
!11 = distinct !{!11, !8, !9}
