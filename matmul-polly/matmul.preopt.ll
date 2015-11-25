; ModuleID = 'matmul.s'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@A = common global [1536 x [1536 x float]] zeroinitializer, align 16
@B = common global [1536 x [1536 x float]] zeroinitializer, align 16
@stdout = external global %struct._IO_FILE*, align 8
@.str = private unnamed_addr constant [5 x i8] c"%lf \00", align 1
@C = common global [1536 x [1536 x float]] zeroinitializer, align 16
@.str.1 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1

; Function Attrs: nounwind uwtable
define void @init_array() #0 {
  br label %.split

.split:                                           ; preds = %0
  br label %.preheader

.preheader:                                       ; preds = %.split, %18
  %indvars.iv3 = phi i64 [ 0, %.split ], [ %indvars.iv.next4, %18 ]
  br label %1

; <label>:1                                       ; preds = %.preheader, %1
  %indvars.iv = phi i64 [ 0, %.preheader ], [ %indvars.iv.next, %1 ]
  %2 = mul nuw nsw i64 %indvars.iv, %indvars.iv3
  %3 = trunc i64 %2 to i32
  %4 = srem i32 %3, 1024
  %5 = add nsw i32 %4, 1
  %6 = sitofp i32 %5 to double
  %7 = fmul double %6, 5.000000e-01
  %8 = fptrunc double %7 to float
  %9 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv3, i64 %indvars.iv
  store float %8, float* %9, align 4
  %10 = mul nuw nsw i64 %indvars.iv, %indvars.iv3
  %11 = trunc i64 %10 to i32
  %12 = srem i32 %11, 1024
  %13 = add nsw i32 %12, 1
  %14 = sitofp i32 %13 to double
  %15 = fmul double %14, 5.000000e-01
  %16 = fptrunc double %15 to float
  %17 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv3, i64 %indvars.iv
  store float %16, float* %17, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp ne i64 %indvars.iv.next, 1536
  br i1 %exitcond, label %1, label %18

; <label>:18                                      ; preds = %1
  %indvars.iv.next4 = add nuw nsw i64 %indvars.iv3, 1
  %exitcond5 = icmp ne i64 %indvars.iv.next4, 1536
  br i1 %exitcond5, label %.preheader, label %19

; <label>:19                                      ; preds = %18
  ret void
}

; Function Attrs: nounwind uwtable
define void @print_array() #0 {
  br label %.split

.split:                                           ; preds = %0
  br label %.preheader

.preheader:                                       ; preds = %.split, %15
  %indvars.iv6 = phi i64 [ 0, %.split ], [ %indvars.iv.next7, %15 ]
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  br label %2

; <label>:2                                       ; preds = %.preheader, %13
  %indvars.iv = phi i64 [ 0, %.preheader ], [ %indvars.iv.next, %13 ]
  %3 = phi %struct._IO_FILE* [ %1, %.preheader ], [ %14, %13 ]
  %4 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv6, i64 %indvars.iv
  %5 = load float, float* %4, align 4
  %6 = fpext float %5 to double
  %7 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %3, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str, i64 0, i64 0), double %6) #2
  %8 = trunc i64 %indvars.iv to i32
  %9 = srem i32 %8, 80
  %10 = icmp eq i32 %9, 79
  br i1 %10, label %11, label %13

; <label>:11                                      ; preds = %2
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %fputc3 = tail call i32 @fputc(i32 10, %struct._IO_FILE* %12)
  br label %13

; <label>:13                                      ; preds = %2, %11
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %14 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %exitcond = icmp ne i64 %indvars.iv.next, 1536
  br i1 %exitcond, label %2, label %15

; <label>:15                                      ; preds = %13
  %.lcssa = phi %struct._IO_FILE* [ %14, %13 ]
  %fputc = tail call i32 @fputc(i32 10, %struct._IO_FILE* %.lcssa)
  %indvars.iv.next7 = add nuw nsw i64 %indvars.iv6, 1
  %exitcond8 = icmp ne i64 %indvars.iv.next7, 1536
  br i1 %exitcond8, label %.preheader, label %16

; <label>:16                                      ; preds = %15
  ret void
}

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  br label %.split

.split:                                           ; preds = %0
  tail call void @init_array()
  br label %.preheader

.preheader:                                       ; preds = %.split, %14
  %indvars.iv7 = phi i64 [ 0, %.split ], [ %indvars.iv.next8, %14 ]
  br label %1

; <label>:1                                       ; preds = %.preheader, %13
  %indvars.iv4 = phi i64 [ 0, %.preheader ], [ %indvars.iv.next5, %13 ]
  %2 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv7, i64 %indvars.iv4
  store float 0.000000e+00, float* %2, align 4
  br label %3

; <label>:3                                       ; preds = %1, %3
  %indvars.iv = phi i64 [ 0, %1 ], [ %indvars.iv.next, %3 ]
  %4 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv7, i64 %indvars.iv4
  %5 = load float, float* %4, align 4
  %6 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @A, i64 0, i64 %indvars.iv7, i64 %indvars.iv
  %7 = load float, float* %6, align 4
  %8 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @B, i64 0, i64 %indvars.iv, i64 %indvars.iv4
  %9 = load float, float* %8, align 4
  %10 = fmul float %7, %9
  %11 = fadd float %5, %10
  %12 = getelementptr inbounds [1536 x [1536 x float]], [1536 x [1536 x float]]* @C, i64 0, i64 %indvars.iv7, i64 %indvars.iv4
  store float %11, float* %12, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp ne i64 %indvars.iv.next, 1536
  br i1 %exitcond, label %3, label %13

; <label>:13                                      ; preds = %3
  %indvars.iv.next5 = add nuw nsw i64 %indvars.iv4, 1
  %exitcond6 = icmp ne i64 %indvars.iv.next5, 1536
  br i1 %exitcond6, label %1, label %14

; <label>:14                                      ; preds = %13
  %indvars.iv.next8 = add nuw nsw i64 %indvars.iv7, 1
  %exitcond9 = icmp ne i64 %indvars.iv.next8, 1536
  br i1 %exitcond9, label %.preheader, label %15

; <label>:15                                      ; preds = %14
  ret i32 0
}

; Function Attrs: nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE* nocapture) #2

; Function Attrs: nounwind
declare i32 @fputc(i32, %struct._IO_FILE* nocapture) #2

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final 254071)"}
