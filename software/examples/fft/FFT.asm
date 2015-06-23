; **************************************************************************************************************
; FFT - Fast Fourier Transformation
;
; N=32:   13851 cycles
; N=64:   33765 cycles
; N=128: 107192 cycles
; **************************************************************************************************************


; **************************************************************************************************************
; Defintions
; **************************************************************************************************************
.equ sys0_core  c0
.equ sys1_core  c1
.equ com0_core  c2
.equ com1_core  c3
.equ sp         r6 ; stack pointer
.equ lr         r7 ; link register


; **************************************************************************************************************
; FFT Configuration
; **************************************************************************************************************
.equ fft_n_c	#128 ; = N
.equ fft_mem_c	#256 ; = N*2


; **************************************************************************************************************
; Exception Vector Table
; **************************************************************************************************************
reset_vec:		b reset
x_int0_vec:		b err_handler
x_int1_vec:		b err_handler
cmd_err_vec:	b err_handler
swi_vec:		b err_handler


; **************************************************************************************************************
; IRQ/SWI/CMD_ERR: Terminate
; **************************************************************************************************************
err_handler:
			bl    uart_linebreak
			ldil  r2, low[err_string]
			ldih  r2, high[err_string]
			bl    uart_print
			bl    uart_linebreak
			b     #+0								; freeze


; **************************************************************************************************************
; Main Program
; **************************************************************************************************************
reset:		ldil  sp, low[stack_end]            	; setup negative-growing stack
            ldih  sp, high[stack_end]

			; print intro
			ldil  r2, low[string_intro]
			ldih  r2, high[string_intro]
			bl    uart_print

			; init timer
			ldil  r0, #0xFF
			mcr   #1, sys0_core, r0, #3				; timer threshold
			ldil  r0, #2
			mcr   #1, sys0_core, r0, #4				; timer prescaler = 1/4


; rearrange input data (bit-reverse sorting)
; -----------------------------------------------------------------------------
			; compute r0=log2(N)
			ldil  r0, low[fft_n_c]					; N
			ldih  r0, high[fft_n_c]
			ldil  r7, low[math_log2]
			ldih  r7, high[math_log2]
			gtl   r7
			push  r0								; = ld(N)

			; re-order
			ldil  r5, low[input_signal]
			ldih  r5, high[input_signal]
			ldil  r2, low[fft_ram]
			ldih  r2, high[fft_ram]
			clr   r3, #0							; initial offset fft_ram
fft_store_loop:
			ldr   r0, r5, +#2, post, !				; get real part of sample
			ldil  r1, #0x00							; imaginary part = 0
			peek  r4								; = ld(N)

			ldil  r7, low[store_fft_sample]
			ldih  r7, high[store_fft_sample]
			gtl   r7

			inc   r3, r3, #1						; in offset
			ldil  r0, low[fft_n_c]					; N
			ldih  r0, high[fft_n_c]
			cmp   r3, r0
			bne   fft_store_loop
			pop   r0


; Perform FFT
; -----------------------------------------------------------------------------
			; reset timer
			clr   r5
			mcr   #1, sys0_core, r5, #2				; timer counter

			; perform FFT
			ldil  r0, low[fft_ram]
			ldih  r0, high[fft_ram]
			ldil  r1, low[fft_n_c]
			ldih  r1, high[fft_n_c]
			ldil  r2, low[fft_sincos_lut]
			ldih  r2, high[fft_sincos_lut]
			bl    math_fft

			; get timer
			mrc   #1, r4, sys0_core, #2				; timer counter
			bl    print_hex_string
			bl    uart_linebreak


; print FFT result
; -----------------------------------------------------------------------------
			ldil  r5, low[fft_ram]
			ldih  r5, high[fft_ram]
			ldil  r3, low[fft_n_c]
			ldih  r3, high[fft_n_c]
print_results:
			ldr   r4, r5, +#2, post, !
			bl    print_hex_string

			ldil  r1, #32
			bl    uart_sendbyte

			ldr   r4, r5, +#2, post, !
			bl    print_hex_string

			bl    uart_linebreak

			decs  r3, r3, #1
			bne   print_results

			b     #+0


; **************************************************************************************************************
; Communication Subroutines
; **************************************************************************************************************

; --------------------------------------------------------------------------------------------------------
; Print char (byte) via CP0.COM_0.UART
; Arguments: r1 = char (low byte)
; Results: -
; Used registers: r0, r1
uart_sendbyte:
; --------------------------------------------------------------------------------------------------------
			mrc  #1, r0, com0_core, #2				; get com control register
			stb  r0, #5								; copy uart tx_busy flag to T-flag
			bts  uart_sendbyte						; still set, keep on waiting
			mcr  #1, com0_core, r1, #0				; send data
			ret  lr


; --------------------------------------------------------------------------------------------------------
; Receive a byte via CP0.COM_0.UART
; Arguments: -
; Results: r0 (low byte)
; Used registers: r0
uart_receivebyte:
; --------------------------------------------------------------------------------------------------------
			mrc   #1, r0, com0_core, #0				; get uart status/data register
			stbi  r0, #15							; copy inverted uart rx_ready flag to T-flag
			bts   uart_receivebyte					; nothing received, keep on waiting
			ldih  r0, #0x00							; clear upper byte
			ret   lr								; return


; --------------------------------------------------------------------------------------------------------
; Prints 16bit data as 4x char hex value
; Arguments:
;  r4 = data
; Results: -
; Used registers: r0, r1, r2, r3, r4, lr
print_hex_string:
; --------------------------------------------------------------------------------------------------------
			push  r0
			push  r1
			push  r2
			push  r3
			push  r4
			push  lr							; backup link regiiter

			; char 3
			sft   r2, r4, #rol
			sft   r2, r2, #rol
			sft   r2, r2, #rol
			sft   r2, r2, #rol
			bl    conv_hex_comp
			bl    uart_sendbyte

			; char 2
			sft   r2, r4, #swp
			bl    conv_hex_comp
			bl    uart_sendbyte

			; char 1
			sft   r2, r4, #lsr
			sft   r2, r2, #lsr
			sft   r2, r2, #lsr
			sft   r2, r2, #lsr
			bl    conv_hex_comp
			bl    uart_sendbyte

			; char 0
			mov   r2, r4
			bl    conv_hex_comp
			bl    uart_sendbyte

			pop   lr
			pop   r4
			pop   r3
			pop   r2
			pop   r1
			pop   r0
			ret   lr

; compute hex-char from 4-bit value of r2, result in r1
conv_hex_comp:	ldil  r1, #0x0f						; mask for lowest 4 bit
				and   r2, r2, r1

				ldil  r1, #9
				cmp   r1, r2
				bcs   #+3

				ldil  r1, #48						; this is a '0'
				b     #+2
				ldil  r1, #55						; this is an 'A'-10
				add   r1, r1, r2					; resulting char in lower byte
				ret   lr


; --------------------------------------------------------------------------------------------------------
; Print linebreak
; Arguments: -
; Results: -
; Used registers: r0, r1, r2, lr
uart_linebreak:
; --------------------------------------------------------------------------------------------------------
			push  r0
			push  r1
			push  r2
			push  lr

			mov   r2, lr
			ldil  r1, #0x0D							; carriage return
			bl    uart_sendbyte
			ldil  r1, #0x0A							; line feed
			mov   lr, r2
			bl    uart_sendbyte

			pop   lr
			pop   r2
			pop   r1
			pop   r0
			ret   lr


; --------------------------------------------------------------------------------------------------------
; Print char-string (bytes) via CP0.COM_0.UART
; Arguments: r2 = address of string (string must be zero-terminated!)
; Results: -
; Used registers: r0, r1, r2, r3, r4, lr
uart_print:
; --------------------------------------------------------------------------------------------------------
            mov   r4, lr

uart_print_loop:
			ldr   r0, r2, +#1, post, !				; get one string byte
			ldil  r1, #0x00							; upper byte mask
			ldih  r1, #0xFF
			and   r1, r0, r1
			sfts  r1, r1, #swp						; swap bytes and test if zero
			beq   uart_print_loop_end
			bl    uart_sendbyte
			b     uart_print_loop

uart_print_loop_end:
			ret   r4



; ***********************************************************************************************************
; Fast Fourier Transformation (Cooley and Tukey Algorithm)
; --------------------------------------------------------------------------------------------------------
; Perform Radix-2 FFT. Make sure to scramble (bit-reverse sorting) input data before
; Arguments:
;  r0 = pointer to signal memory (input/output)
;  r1 = number of points (must be a power of two and not zero)
;  r2 = pointer to sincos table
; Results: -
; Used registers: r0, r1, r2, r3, r4, r5, r6, r7 (saves on stack)
; --------------------------------------------------------------------------------------------------------
math_fft:
; ***********************************************************************************************************
			push  r5
			push  r4
			push  r3
			push  r2
			push  r1
			push  r0
			push  lr								; save all regs

			; save config
			ldil  r7, low[v_math_fft_num_levels]
			ldih  r7, high[v_math_fft_num_levels]
			str   r0, r7, -#6, pre					; pointer to signal memory
			str   r1, r7, -#2, pre					; number of points
			str   r2, r7, -#4, pre					; pointer to sincos table

			; get number of levels = ld(N)
			clr   r0
math_fft_get_lvs:
			sft   r1, r1, #lsr
			teq   r1, r1
			beq   #+3
			inc   r0, r0, #1
			b     math_fft_get_lvs
			ldil  r7, low[v_math_fft_num_levels]
			ldih  r7, high[v_math_fft_num_levels]
			str   r0, r7, +#0, pre

			; init control varibales
			ldil  r7, low[v_math_fft_num_levels]
			ldih  r7, high[v_math_fft_num_levels]
			ldil  r5, #1
			str   r5, r7, +#2, pre					; current_level = 1 = first level
			str   r5, r7, +#4, pre					; current_dft   = 1 = first sub DFT
			str   r5, r7, +#6, pre					; current_btfly = 1 = first butterfly

			ldil  r7, low[v_math_fft_a_offs]
			ldih  r7, high[v_math_fft_a_offs]
			ldil  r5, #0
			str   r5, r7, +#0, pre					; offset A

math_fft_level:	ldil  r7, low[v_math_fft_dft]
				ldih  r7, high[v_math_fft_dft]
				ldr   r1, r7, -#2, pre				; current LEVEL
				ldr   r2, r7, +#0, pre				; current SUB_DFT
				dec   r2, r2, #1

				ldil  r4, #4
				sft   r4, r4, #lsl
				decs  r1, r1, #1
				bne   #-2							; r4 = 4<<LEVEL
				mul   r2, r2, r4					; r2 = [SUB_DFT-1]*[4<<LEVEL]
				str   r2, r7, +#4, pre				; current offset A

math_fft_butterfly:		; compute offsets -> and pointer
						ldil  r7, low[v_math_fft_num_levels]
						ldih  r7, high[v_math_fft_num_levels]
						ldr   r4, r7, -#6, pre					; signal mem pointer
						ldr   r1, r7, +#2, pre					; current LEVEL
						ldr   r2, r7, +#6, pre					; current BUTTERFLY
						ldr   r3, r7, -#4, pre					; sincos table pointer
						dec   r2, r2, #1						; = BUTTERFLY-1
						sft   r2, r2, #lsl
						sft   r2, r2, #lsl						; offset W = (BUTTERFLY-1)*4
						add   r2, r3, r2						; pointer W

						ldil  r7, low[v_math_fft_a_offs]
						ldih  r7, high[v_math_fft_a_offs]
						ldr   r0, r7, +#0, pre					; offset A
						add   r0, r0, r4						; pointer A
		
						ldil  r3, #2
						sft   r3, r3, #lsl
						decs  r1, r1, #1
						bne   #-2
						add   r1, r0, r3						; pointer B

						; backup pointer
						ldil  r7, low[v_math_fft_a_pnt]
						ldih  r7, high[v_math_fft_a_pnt]
						str   r0, r7, +#0, pre					; A
						str   r1, r7, +#2, pre					; B
						str   r2, r7, +#4, pre					; W

						; get data
						mov   r3, r0
						mov   r4, r1
						mov   r5, r2
						push  r3
						push  r4
						ldr   r0, r3, +#0, pre					; A_real
						ldr   r1, r3, +#2, pre					; A_imag
						ldr   r2, r4, +#0, pre					; B_real
						ldr   r3, r4, +#2, pre					; B_imag
						ldr   r4, r5, +#0, pre					; W_real
						ldr   r5, r5, +#2, pre					; W_imag

						; perform butterfly
						bl    fft_butterfly

						; store new data
						pop   r5
						pop   r4
						str   r2, r5, +#0, pre					; B_real'
						str   r3, r5, +#2, pre					; B_imag'
						str   r0, r4, +#0, pre					; A_real'
						str   r1, r4, +#2, pre					; A_imag'

						; add step_width to offset A
						ldil  r7, low[v_math_fft_a_offs]
						ldih  r7, high[v_math_fft_a_offs]
						ldr   r0, r7, +#0, pre
						ldil  r1, #4
						add   r0, r0, r1
						str   r0, r7, +#0, pre

						; all butterflies done?
						ldil  r7, low[v_math_fft_num_levels]
						ldih  r7, high[v_math_fft_num_levels]
						ldr   r0, r7, +#2, pre					; current LEVEL
						ldr   r2, r7, +#6, pre					; current BUTTERFLY

						ldil  r1, #1
						decs  r0, r0, #1
						beq   #+3
						sft   r1, r1, #lsl						; #butterflies per sub dft = 1<<(LEVEL-1)
						b     #-3

						cmp   r1, r2							; #butterflies per sub DFT = current BUTTERFLY?
						inc   r2, r2, #1						; inc BUTTERFLY
						str   r2, r7, +#6, pre					; new BUTTERFLY
						bne   math_fft_butterfly

						ldil  r2, #1
						str   r2, r7, +#6, pre					; reset BUTTERFLY

					; all sub DFTs done?
					ldil  r7, low[v_math_fft_num_levels]
					ldih  r7, high[v_math_fft_num_levels]
					ldr   r0, r7, -#2, pre					; N
					ldr   r1, r7, +#2, pre					; current LEVEL
					ldr   r2, r7, +#4, pre					; current SUB_DFT

					sft   r0, r0, #lsr						; number of DFTs = N >> LEVEL
					decs  r1, r1, #1
					bne   #-2

					cmp   r0, r2							; #sub DFTs per level = current SUB_DFT?
					inc   r2, r2, #1						; inc SUB_DFT
					str   r2, r7, +#4, pre					; new SUB_DFT
					bne   math_fft_level

					ldil  r2, #1							; reset value for SUB_DFT
					str   r2, r7, +#4, pre					; reset SUB_DFT?

				; all levels done?
				ldil  r7, low[v_math_fft_num_levels]
				ldih  r7, high[v_math_fft_num_levels]
				ldr   r0, r7, +#0, pre					; #levels
				ldr   r1, r7, +#2, pre					; current LEVEL
				cmp   r0, r1
				inc   r1, r1, #1						; inc current LEVEL
				str   r1, r7, +#2, pre					; new LEVEL
				bne   math_fft_level

			; terminate
			pop   lr
			pop   r0
			pop   r1
			pop   r2
			pop   r3
			pop   r4
			pop   r5								; restore regs

			ret   lr


; FFT run-time data memory
v_math_fft_sig_pnt:		nop			; pointer to processing memory
v_math_sincos_pnt:		nop			; pointer to sincos table
v_math_fft_num_points:	nop			; number of points (N)
v_math_fft_num_levels:  nop			; #levels
v_math_fft_level:       nop			; current LEVEL
v_math_fft_dft:         nop			; current SUB_DFT
v_math_fft_btfly:       nop			; current BUTTERFLY

v_math_fft_a_offs:		nop			; offset for A
v_math_fft_a_pnt:		nop			; pointer for A
v_math_fft_b_pnt:		nop			; pointer for B
v_math_fft_w_pnt:		nop			; pointer for W


; ***********************************************************************************************************
; FFT Butterfly (16-bit)
; --------------------------------------------------------------------------------------------------------
; Twiddle factors (W): 1-bit SIGN + 1-bit integer + 14-bit fractional part
; A' = A + B*W
; B' = B - B*W
; Arguments:
;  r0 = A_real
;  r1 = A_imag
;  r2 = B_real
;  r3 = B_imag
;  r4 = W_real
;  r5 = W_imag
; Results:
;  r0 = A_real_new
;  r1 = A_imag_new
;  r2 = B_real_new
;  r3 = B_imag_new
; Used registers: r0, r1, r2, r3, r4, r5, r6, r7 (saves on stack)
; --------------------------------------------------------------------------------------------------------
fft_butterfly:
; ***********************************************************************************************************
			push  lr

			; multiplications (signed!)
			push  r0
			push  r1

			ldil  r7, low[fft_butterfly_mem]
			ldih  r7, high[fft_butterfly_mem]

			mul   r0, r4, r2
			mulh  r1, r4, r2						; r1:r0 = U = W_real*B_real
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol						; r1 = r1:r0 >> 14
			str   r1, r7, +#0, pre

			mul   r0, r4, r3
			mulh  r1, r4, r3						; r1:r0 = V = W_real*B_imag
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol						; r1 = r1:r0 >> 14
			str   r1, r7, +#2, pre

			mul   r0, r5, r2
			mulh  r1, r5, r2						; r1:r0 = X = W_imag*B_real
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol						; r1 = r1:r0 >> 14
			str   r1, r7, +#4, pre

			mul   r0, r5, r3
			mulh  r1, r5, r3						; r1:r0 = Y = W_imag*B_imag
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol
			sfts  r0, r0, #lsl
			sft   r1, r1, #rol						; r1 = r1:r0 >> 14
			str   r1, r7, +#6, pre

			pop   r1
			pop   r0

			; additions
			; A_real' = A_real + U - Y
			ldr   r2, r7, +#0, pre					; r2 = U
			ldr   r3, r7, +#6, pre					; r3 = Y
			adds  r2, r0, r2						; r2 = A_real + U
			sbc   r3, r2, r3						; A_real' = r3 = r2 - Y
			push  r3

			; A_imag' = A_imag + V + X
			ldr   r2, r7, +#2, pre					; r2 = V
			ldr   r3, r7, +#4, pre					; r3 = X
			adds  r2, r1, r2						; r2 = A_imga + V
			adc   r3, r2, r3						; A_imag' = r3 = r2 +X
			push  r3

			; B_real' = A_real - U + Y
			ldr   r2, r7, +#0, pre					; r2 = U
			ldr   r3, r7, +#6, pre					; r3 = Y
			subs  r2, r0, r2						; r2 = A_real - U
			adc   r3, r2, r3						; B_real' = r3 = r2 + Y
			push  r3

			; B_imag' = A_imag - V - X
			ldr   r2, r7, +#2, pre					; r2 = V
			ldr   r3, r7, +#4, pre					; r3 = X
			subs  r2, r1, r2						; r2 = A_real - U
			sbc   r3, r2, r3						; B_imag' = r3 = r2 - Y
;			push  r3

			; re-arrange
;			pop   r3								; r3 = B_imag'
			pop   r2								; r2 = B_real'
			pop   r1								; r1 = A_imag'
			pop   r0								; r0 = A_real'

			; done
			pop   lr
			ret   lr


; Butterfly run-time memory (4x words)
fft_butterfly_mem: .space #4


; ***********************************************************************************************************
; Store complex sample with bit-reversed offset
; --------------------------------------------------------------------------------------------------------
; Arguments:
;  r0 = Sample real part
;  r1 = Sample imaginary part
;  r2 = Destination buffer base address (absolute)
;  r3 = Binary offset number (0..N-1)
;  r4 = ld(N)
; Results: -
; Used registers: r0, r1, r2, r3, r4, r5, r6 (saves on stack)
; --------------------------------------------------------------------------------------------------------
store_fft_sample:
; ***********************************************************************************************************
			push  r3								; backup offset
			push  r4								; backup ld(N)
			push  r5								; backup temp

			; iterative computation of bit-reversed address
			clr   r5
store_fft_sample_brev:
			sfts  r3, r3, #lsr
			sft   r5, r5, #rlc
			decs  r4, r4, #1
			bne   store_fft_sample_brev

			sft   r5, r5, #lsl						; bytes to words
			sft   r5, r5, #lsl						; offset*2 -> 2 samples per offset

			; store it
			add   r5, r2, r5						; add offset to base
			str   r0, r5, +#0, pre					; real
			str   r1, r5, +#2, pre					; imag

			pop   r5								; restore temp
			pop   r4								; restore ld(N)
			pop   r3								; restore original offset

			ret   lr								; terminate


; ***********************************************************************************************************
; Compuation of dual logarithm
; --------------------------------------------------------------------------------------------------------
; Arguments:
;  r0 = Argument
; Results:
;  r0 = log2(Argument)
; Used registers: r0, r1, r6 (saves on stack)
; --------------------------------------------------------------------------------------------------------
math_log2:
; ***********************************************************************************************************
			push  r1								; backup temp

			clr   r1
math_log2_loop:
			sfts  r0, r0, #lsr
			beq   math_log2_end
			inc   r1, r1, #1
			b     math_log2_loop

math_log2_end:
			mov   r0, r1
			pop   r1								; restore temp

			ret   lr								; terminate


; **************************************************************************************************************
; FFT Sin/Cos Look-Up Table (cos(2*pi*k/N), sin(2*pi*k/N); 0 <= k <= N/2), 14-bit fractional part, signed
; **************************************************************************************************************
fft_sincos_lut:
.include "sincos_lut.asm"


; **************************************************************************************************************
; FFT Input signal (dummy)
; **************************************************************************************************************
input_signal:
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0
.dw #1024
.dw #0
.dw #0
.dw #0


; **************************************************************************************************************
; FFT processing memory
; **************************************************************************************************************
fft_ram:
.space fft_mem_c ; N*2


; **************************************************************************************************************
; Strings
; **************************************************************************************************************
err_string:		.stringz "Exception/interrupt error!"
string_intro:	.stringz "Computing FFT... "


; **************************************************************************************************************
; System RAM
; **************************************************************************************************************
stack_begin:  .space #63
stack_end:    nop
