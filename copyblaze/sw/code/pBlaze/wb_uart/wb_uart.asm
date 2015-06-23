; project	: copyBlaze 8 bit processor
; file name	: wb_uart.asm
; author	: abdAllah Meziti
; licence	: LGPL

; this programm test the wishbone copyBlaze instruction.
; it use this module : 
; 			wb_uart_08.vhd

		WB_UART_STATUS		.EQU	0x00
		WB_UART_DIV_LOW		.EQU	0x04
		WB_UART_DIV_HIGH	.EQU	0x05
		WB_UART_DATA		.EQU	0x08
		
		wb_data_to_wb		.EQU   s0
		wb_data_from_wb		.EQU   s1
		;

		; ==========================================================
start:
		; ==========================================================

		; initialize the wb_uart registers
		LOAD		wb_data_to_wb,		0x02				; 
		WBWRSING	wb_data_to_wb,		WB_UART_DIV_LOW		; DIV_LOW = 0x02

		LOAD		wb_data_to_wb,		0x00				; 
		WBWRSING	wb_data_to_wb,		WB_UART_DIV_HIGH	; DIV_HIGH = 0x00

;		LOAD		wb_data_to_wb,		0x04				; 
;		WBWRSING	wb_data_to_wb,		WB_UART_STATUS		; STATUS = 0x04 : rx_irqen=1
		
		LOAD		wb_data_to_wb,		0x08				; 
		WBWRSING	wb_data_to_wb,		WB_UART_STATUS		; STATUS = 0x08 : tx_irqen=1
		
		; write a data to the UART
		LOAD		wb_data_to_wb,		0x55				; 
		WBWRSING	wb_data_to_wb,		WB_UART_DATA		;
		
		; enable interrupts
		EINT
end:		
		JUMP	end
		;

;	*************************
;	Interrupt Service Routine
;	*************************
ISR:
		WBRDSING	wb_data_from_wb,	WB_UART_STATUS		; read the status
		
		ADD			wb_data_to_wb,		0x01
		
		WBWRSING	wb_data_to_wb,		WB_UART_DATA		;
		
		
		RETI      ENABLE
;		RETI      DISABLE
;	*************************
;	End ISR Interrupt Handler
;	*************************

		.ORG	0x3FF
VECTOR:
		JUMP	ISR
