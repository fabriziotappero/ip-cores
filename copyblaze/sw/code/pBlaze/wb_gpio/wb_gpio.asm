; project	: copyBlaze 8 bit processor
; file name	: wb_gpio.asm
; author	: abdAllah Meziti
; licence	: LGPL

; this programm test the wishbone copyBlaze instruction.
; it use this module : 
; 			wb_gpio_08.vhd

		WB_GPIO_IN_ADDR		.EQU	0x01
		WB_GPIO_OU_ADDR		.EQU	0x04
	
		wb_data_out				.EQU   s8
		wb_data_in				.EQU   s0
		;

		; ==========================================================
start:
		; ==========================================================

		; 
		LOAD	wb_data_out,		0x00	; 
		LOAD	wb_data_out,		0x01	; 
		LOAD	wb_data_out,		0x02	; 

		; wishbone WRITE instruction
		WBWRSING	wb_data_out,	WB_GPIO_OU_ADDR
		LOAD	wb_data_out,		0x03	; 
		LOAD	wb_data_out,		0x04	; 
		LOAD	wb_data_out,		0x05	; 
		; wishbone WRITE instruction
		WBWRSING	wb_data_out,	WB_GPIO_OU_ADDR 
		LOAD	wb_data_out,		0x06	; 
		LOAD	wb_data_out,		0x07	; 
		LOAD	wb_data_out,		0x08	; 
		; wishbone READ instruction
		WBRDSING	wb_data_in,		WB_GPIO_IN_ADDR	; 
		LOAD	wb_data_out,		0x0A	; 
		LOAD	wb_data_out,		0x0B	; 
		LOAD	wb_data_out,		0x0C	; 

end:		
		JUMP	end
		;
