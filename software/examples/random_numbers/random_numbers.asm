; **************************************************************************************************************
; Print Random Numbers - LFSR Test
;
; Print random hex numbers from the LFSR via UART
; Uses BAUD rate from bootloader config!!!
; **************************************************************************************************************


; **************************************************************************************************************
; Defintions
; **************************************************************************************************************

.equ sys0_core    c0
.equ com0_core    c2
.equ lr           r7 ; link register


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

err_handler:		bl    uart_linebreak
					ldil  r2, low[err_string]
					ldih  r2, high[err_string]
					bl    uart_print
					bl    uart_linebreak
					b     #+0						; freeze


; **************************************************************************************************************
; Main Program
; **************************************************************************************************************

reset:		; print intro
			ldil  r2, low[string_intro]
			ldih  r2, high[string_intro]
			bl    uart_print_br

restart:	; get seed
			ldil  r2, low[string_seed]
			ldih  r2, high[string_seed]
			bl    uart_print
			bl    receive_hex_word
			mcr   #1, sys0_core, r4, #5				; set lfsr data register
			bl    uart_linebreak

			; get taps
			ldil  r2, low[string_taps]
			ldih  r2, high[string_taps]
			bl    uart_print
			bl    receive_hex_word
			cbr   r4, r4, #15						; new value after read access
			mcr   #1, sys0_core, r4, #6				; set lfsr polynomial register
			bl    uart_linebreak

			; read and print hex random numbers
forever:	ldil  r1, #'0'
			bl    uart_sendbyte
			ldil  r1, #'x'
			bl    uart_sendbyte

			; get and print
			mrc   #1, r4, sys0_core, #5			; get lfsr data
			bl    print_hex_string
			bl    uart_linebreak

			; user console interrupt?
			mrc   #1, r0, com0_core, #0				; get uart RTX register
			stb   r0, #15							; copy uart rx_ready flag to T-flag
			bts   restart

			; repeat forever
			b     forever


; **************************************************************************************************************
; Communication Subroutines
; **************************************************************************************************************


; --------------------------------------------------------------------------------------------------------
; Print char-string (bytes) via CP0.COM_0.UART and send linebreak
; Arguments: r2 = address of string (string must be zero-terminated!)
; Results: -
; Used registers: r0, r1, r2, r3, r4, lr
uart_print_br:
; --------------------------------------------------------------------------------------------------------
			ldil  r3, #0xFF
			mov   r4, lr
			b     uart_print_loop


; --------------------------------------------------------------------------------------------------------
; Print char-string (bytes) via CP0.COM_0.UART
; Arguments: r2 = address of string (string must be zero-terminated!)
; Results: -
; Used registers: r0, r1, r2, r3, r4, lr
uart_print:
; --------------------------------------------------------------------------------------------------------
			clr   r3
			mov   r4, lr
			
uart_print_loop:
            ldr   r1, r2, +#1, post, !				; get one string byte
			sft   r1, r1, #swp						; swap high and low byte
            ldih  r1, #0x00							; clear high byte
			teq   r1, r1							; test if string end
            beq   uart_print_loop_end
            bl    uart_sendbyte
            b     uart_print_loop

uart_print_loop_end:
			mov   lr, r4
			teq   r3, r3							; do linebreak?
			rbaeq lr
;			b     uart_linebreak


; --------------------------------------------------------------------------------------------------------
; Print linebreak
; Arguments: -
; Results: -
; Used registers: r0, r1, r2, lr
uart_linebreak:
; --------------------------------------------------------------------------------------------------------
			mov   r2, lr
			ldil  r1, #0x0D							; carriage return
			bl    uart_sendbyte
			ldil  r1, #0x0A							; line feed
			mov   lr, r2
;			b     uart_sendbyte


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
			ret   lr


; --------------------------------------------------------------------------------------------------------
; Reads 16 bit data as 4x hex chars via UART (+ECHO)
; Arguments: -
; Results:
;  r4 = data
; Used registers: r0, r1, r2, r3, r4, lr
receive_hex_word:
; --------------------------------------------------------------------------------------------------------
			mov   r2, lr							; backup link regsiter
			ldil  r4, #0							; clear data register
			ldil  r3, #4							; number of chars

receive_hex_word_loop:
			bl    uart_receivebyte					; get one char

			; convert to higher case
			ldil  r1, #'G'							; = 'F' +1
			cmp   r0, r1
			bmi   #+3								; skip decrement
			ldil  r1, #32							; -> to lower case
			sub   r0, r0, r1

			; is valid?
			ldil  r1, #'0'
			cmp   r0, r1
			bmi   receive_hex_word_loop				; if less than '0'

			ldil  r1, #'F'
			cmp   r1, r0
			bmi   receive_hex_word_loop				; if higher than 'F'

			ldil  r1, #'9'
			cmp   r1, r0
			bls   receive_hex_word_echo				; if less than '9'

			ldil  r1, #'A'
			cmp   r0, r1
			bhi   receive_hex_word_loop				; if less than 'A'

			; echo char
receive_hex_word_echo:
			mov   r1, r0
			bl    uart_sendbyte

			; do conversion
			ldil  r0, #'0'
			sub   r1, r1, r0
			ldil  r0, #9
			cmp   r0, r1
			bls   #+2								; 0..9 -> ok
			dec   r1, r1, #7						; 'A' - '0' - 10 = 7 -> A..F -> ok

			; save conversion data
			sft   r4, r4, #rol
			sft   r4, r4, #rol
			sft   r4, r4, #rol
			sft   r4, r4, #rol
			orr   r4, r4, r1

			; loop controller
			decs  r3, r3, #1
			bne   receive_hex_word_loop

			ret   r2								; return


; --------------------------------------------------------------------------------------------------------
; Prints 16bit data as 4x char hex value
; Arguments:
;  r4 = data
; Results: -
; Used registers: r0, r1, r2, r3, r4, r6, lr
print_hex_string:
; --------------------------------------------------------------------------------------------------------
			mov   r6, lr							; backup link regiiter

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

			ret   r6

; compute hex-char from 4-bit value of r2, result in r1
conv_hex_comp:	ldil r1, #0x0f					; mask for lowest 4 bit
				and  r2, r2, r1

				ldil r1, #9
				cmp  r1, r2
				bcs  #+3

				ldil r1, #48					; this is a '0'
				b    #+2
				ldil r1, #55					; this is an 'A'-10
				add  r1, r1, r2					; resulting char in lower byte
				ret  lr


; **************************************************************************************************************
; Constants
; **************************************************************************************************************

; -- strings --
err_string:   .stringz "Exception/interrupt error!"
string_intro: .stringz "Random Number Generator"
string_seed:  .stringz "Enter LFSR seed (4hex): 0x"
string_taps:  .stringz "Enter LFSR taps (4hex): 0x"
