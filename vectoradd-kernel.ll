; ModuleID = 'vectoradd_preopt_prepare_indep_blocks_loop_extract_main_vector.body.ll'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v32:32:32-v64:64:64-v128:128:128-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Intrinsic to read X component of thread ID
declare i32 @llvm.nvvm.read.ptx.sreg.tid.x() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.ntid.x() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.ctaid.x() readnone nounwind

; Intrinsic to read Y component of thread ID
declare i32 @llvm.nvvm.read.ptx.sreg.tid.y() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.ntid.y() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.ctaid.y() readnone nounwind

; Intrinsic to read Z component of thread ID
declare i32 @llvm.nvvm.read.ptx.sreg.tid.z() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.ntid.z() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.ctaid.z() readnone nounwind

; Intrinsic to read Z component of thread ID
declare i32 @llvm.nvvm.read.ptx.sreg.nctaid.x() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.nctaid.y() readnone nounwind
declare i32 @llvm.nvvm.read.ptx.sreg.nctaid.z() readnone nounwind


define ptx_kernel void @vectoradd_kernel(float addrspace(1)* %d_a, 
										 float addrspace(1)* %d_b, 
										 float addrspace(1)* %d_c) {
entry:
	;int indice =  blockIdx.y  * gridDim.x  * blockDim.z * blockDim.y * blockDim.x
	;	     + blockIdx.x  * blockDim.z * blockDim.y * blockDim.x
	;	     + threadIdx.z * blockDim.y * blockDim.x
	;	     + threadIdx.y * blockDim.x
	;	     + threadIdx.x;
	
	; threadIdx.
	%t_idx = tail call i32 @llvm.nvvm.read.ptx.sreg.tid.x()
	%t_idy = tail call i32 @llvm.nvvm.read.ptx.sreg.tid.y()
	%t_idz = tail call i32 @llvm.nvvm.read.ptx.sreg.tid.z()
	
	; blockIdx;
	%b_idx = tail call i32 @llvm.nvvm.read.ptx.sreg.ctaid.x()
	%b_idy = tail call i32 @llvm.nvvm.read.ptx.sreg.ctaid.y()
	%b_idz = tail call i32 @llvm.nvvm.read.ptx.sreg.ctaid.z()
	
	; blockDim.
	%b_dimx = tail call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
	%b_dimy = tail call i32 @llvm.nvvm.read.ptx.sreg.ntid.y()
	%b_dimz = tail call i32 @llvm.nvvm.read.ptx.sreg.ntid.z()
	
	; gridDim.
	%g_dimx = tail call i32 @llvm.nvvm.read.ptx.sreg.nctaid.x()
	%g_dimy = tail call i32 @llvm.nvvm.read.ptx.sreg.nctaid.y()
	%g_dimz = tail call i32 @llvm.nvvm.read.ptx.sreg.nctaid.z()
	
	;int indice =  blockIdx.y  * gridDim.x  * blockDim.z * blockDim.y * blockDim.x
	;	     + blockIdx.x  * blockDim.z * blockDim.y * blockDim.x
	;	     + threadIdx.z * blockDim.y * blockDim.x
	;	     + threadIdx.y * blockDim.x
	;	     + threadIdx.x;
	
	%mult1 = mul i32 %b_dimy, %b_dimx
	%mult2 = mul i32 %b_dimz, %mult1
	%mult3 = mul i32 %g_dimx, %mult2
	%mult4 = mul i32 %b_idy, %mult3
	
	;%mult5 = mul i32 %b_dimy, %b_dimx
	;%mult6 = mul i32 %b_dimz, %mult1
	%mult7 = mul i32 %b_idx, %mult2
	
	; %mult8 = mul i32 %b_dimy, %b_dimx
	%mult9 = mul i32 %t_idz, %mult1
	
	%mult10 = mul i32 %t_idy, %b_dimx
	
	%soma1 = add i32 %mult10, %t_idx
	%soma2 = add i32 %mult9, %soma1
	%soma3 = add i32 %mult7, %soma2
	%soma4 = add i32 %mult4, %soma3
	%indice = sext i32 %soma4 to i64
	
	br label %bb_1

bb_1:                                         ; preds = %entry	
	%scevgep = getelementptr float addrspace(1)* %d_c, i64 %indice
	%scevgep1 = bitcast float* %scevgep to <1 x float>*
	%scevgep2 = getelementptr float addrspace(1)* %d_b, i64 %indice
	%scevgep23 = bitcast float* %scevgep2 to <1 x float>*
	%scevgep4 = getelementptr float addrspace(1)* %d_a, i64 %indice
	%scevgep45 = bitcast float* %scevgep4 to <1 x float>*
	%wide.load = load <1 x float>* %scevgep45, align 4
	%wide.load4 = load <1 x float>* %scevgep23, align 4
	%ab = fadd <1 x float> %wide.load, %wide.load4
	store <1 x float> %ab , <1 x float>* %scevgep1 , align 4
	
	br label %return

return:                                           ; preds = %bb_1
	ret void
}

!nvvm.annotations = !{!0}
!0 = metadata !{void (float*,
                      float*,
                      float*)* @vectoradd_kernel, metadata !"vectoradd_kernel", i32 1}
