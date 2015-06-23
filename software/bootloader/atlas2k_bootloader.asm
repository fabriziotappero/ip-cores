; *****************************************************************************************************************
; *****************************************************************************************************************
; ATLAS 2K Bootloader
;
; Bootloader (ROM) pages starting at 0x8000
;
; Options:
;  -> load image via UART
;  -> execute image in memory (page: 0x0000, address: 0x0000)
;  -> load image from SPI EEPROM
;  -> burn image to SPI EEPROM
;  -> make hex dump from memory (any page)
;  -> make hex word dump from Wishbone address
;
; Boot configuration via CP1.COM_0_CORE.SYS_IN (bits 1 downto 0):
;  -> "00": Launch console
;  -> "01": Boot from UART
;  -> "10": Boot from SPI EEPROM (CS0)
;  -> "11": Boot from memory (page: 0x0000, address: 0x0000)
;
; SPI-EEPROM at CS0 (boot EEPROM) must have 16-bit data address (!) -> max size is 64kB - 16 bytes
; => e.g. 25LCD512
;
; Terminal configuration (CP1.COM_0_CORE.UART): 2400-8-N-1
; This bootloader does not need any RAM at all, thus the baud rate must be low
; to allow burning of the EEPROM 'on the fly'.
;
; For version info see the string section.
;
; 'Global variables'
;  usr_r0: Image size
;  usr_r1: Image checksum
;  usr_r2: Image name (0,1)
;  usr_r3: Image name (2,3)
;  usr_r4: Image name (4,5)
;  usr_r5: Image name (6,7)
;  usr_r6: Image name (8,9)
;  usr_r7: GP variable
;  LFSR_poly: Checksum computation
; *****************************************************************************************************************
; *****************************************************************************************************************

; -----------------------------------------------------------------------------
; Processor register definitions
; -----------------------------------------------------------------------------
.equ sp           r6 ; stack pointer
.equ lr           r7 ; link register

; -----------------------------------------------------------------------------
; CPU function cores
; -----------------------------------------------------------------------------
.equ sys0_core    c0
.equ sys1_core    c1
.equ com0_core    c2
.equ com1_core    c3

; -----------------------------------------------------------------------------
; MSR bits
; -----------------------------------------------------------------------------
.equ msr_gxint_en #11 ; global external interrupt enable
.equ msr_xint0_en #12 ; enable external interrupt line 0
.equ msr_xint1_en #13 ; enable external interrupt line 1

; -----------------------------------------------------------------------------
; Configuration constans
; -----------------------------------------------------------------------------
.equ uart_baud_c #2400  ; com0_core.UART default baud rate
; keep the baud rate low - EEPROM programming is done without buffering!


; *****************************************************************************************************************
; Exception Vector Table
; *****************************************************************************************************************
reset_vec:		b reset
x_int0_vec:		b boot_irq_error					; fatal error
x_int1_vec:		b boot_irq_error					; fatal error
cmd_err_vec:	b boot_irq_error					; fatal error
swi_vec:		b boot_irq_error					; fatal error


; *****************************************************************************************************************
; Interrupt service routine - this is fatal!
; *****************************************************************************************************************
boot_irq_error:
            ; restore bootloader page
            ldil  r0, #0x00
            ldih  r0, #0x80
            mcr   #1, sys1_core, r0, #2				; set d-page = 0x8000

            ; set alarm lights
            ldih  r0, #0b10011001
            mcr   #1, com0_core, r0, #7				; set system output

            ; print error message
            ldil  r2, low[string_err_irq]
            ldih  r2, high[string_err_irq]
            bl    uart_print__

            b     #+0								; freeze


; *****************************************************************************************************************
; Main Program
; *****************************************************************************************************************
reset:		; set mmu pages
            mrc   #1, r0, sys1_core, #1				; get sys i-page
            mcr   #1, sys1_core, r0, #0
            mcr   #1, sys1_core, r0, #2

            ; init MSR
            ldil  r7, #0x00
            ldih  r7, #0xF8							; sys_mode, prv_sys_mode, g_irq_en, int1_en, int0_en
            stsr  r7

            ; disable irq ctrl, lfsr and timer
            CLR   R0                                ; ZERO
            mcr   #1, sys0_core, r0, #0				; clear irq mask register
            mcr   #1, sys0_core, r0, #3				; clear timer threshold - disable timer
            mcr   #1, sys0_core, r0, #5				; clear lfsr data register - disable lfsr
            mrc   #1, r0, sys0_core, #0				; ack pending IRQs

            ; setup Wishbone bus controller
            mcr   #1, com1_core, r0, #0				; set WB ctrl reg (burst size = 1, all options disabled)
            mcr   #1, com1_core, r0, #3				; clear WB address offset reg
            ldil  r0, #100                          ; timeout = 100 cycles
            mcr   #1, com1_core, r0, #5				; set WB timeout reg

            ; alive LED
            ldih  r2, #0x01
            mcr   #1, com0_core, r2, #7				; set system output

            ; get system clock frequency
            mrc   #1, r0, sys1_core, #7				; clock low
            mrc   #1, r1, sys1_core, #7				; clock high

            ; baud rate
            ldil  r2, low[uart_baud_c]
            ldih  r2, high[uart_baud_c]
            ldil  r3, #15
            add   r2, r2, r3						; +15 to compensate UART's latency

            ; compute and set UART prescaler
            clr   r3
            clr   r4
main_baud_loop:
            subs  r0, r0, r2						; do bad division...
            sbcs  r1, r1, r3
            bmi   #+3
            inc   r4, r4, #1
            b     main_baud_loop
            mcr   #1, com0_core, r4, #1				; set UART prescaler

            ; activate UART core
            mrc   #1, r0, com0_core, #2				; com ctrl reg
            sbr   r0, r0, #6						; UART EN
            mcr   #1, com0_core, r0, #2				; com ctrl reg

            ; print intro
            ldil  r2, low[string_intro0]
            ldih  r2, high[string_intro0]
            bl    uart_print__

            ; print boot page
            ldil  r2, low[string_intro3]
            ldih  r2, high[string_intro3]
            bl    uart_print__
            mrc   #1, r4, sys1_core, #1				; get sys i-page
            bl    print_hex_string__

            ; print clock speed
            ldil  r2, low[string_intro4]
            ldih  r2, high[string_intro4]
            bl    uart_print__
            mrc   #1, r5, sys1_core, #7				; clock low
            mrc   #1, r4, sys1_core, #7				; clock high
            bl    print_hex_string__				; print clock high
            mov   r4, r5
            bl    print_hex_string__				; print clock low
            bl    uart_linebreak__

            ; check boot config switches
            mrc   #1, r0, com0_core, #7				; parallel input
            ldil  r1, #0x03							; bit mask
            and   r0, r0, r1

            ; option selection
            ldil  r6, #'0'
            add   r6, r6, r0						; add ascii offset to selection
            b     console_selector


; -----------------------------------------------------------------------------------
; Terminal console
; -----------------------------------------------------------------------------------
start_console:
            ; print menu
            ldil  r2, low[string_menu0]
            ldih  r2, high[string_menu0]
            bl    uart_print__
            ldil  r2, low[string_menup]
            ldih  r2, high[string_menup]
            bl    uart_print__

console_input:
            ldil  r2, low[string_menux]
            ldih  r2, high[string_menux]
            bl    uart_print__						; print prompt

            ; process unser input
console_wait:
            bl    uart_receivebyte__				; wait for user input
            mov   r6, r0							; backup for selector
            mov   r1, r0							; backup for echo
            bl    uart_sendbyte__					; echo selection
            bl    uart_linebreak__

            ; go to submenu
console_selector:
            ldil  r1, #'0'
            cmp   r1, r6
            beq   start_console						; restart console

            ldil  r1, #'1'
            cmp   r1, r6
            beq   boot_uart							; boot from uart

            ldil  r1, #'2'
            cmp   r1, r6
            beq   boot_eeprom						; boot from eeprom

            ldil  r1, #'3'
            cmp   r1, r6
            beq   boot_memory						; boot from memory

            ldil  r1, #'4'
            cmp   r1, r6
            beq   boot_wishbone						; boot from wishbone device

            ldil  r5, low[burn_eeprom]
            ldih  r5, high[burn_eeprom]
            ldil  r1, #'p'
            cmp   r1, r6
            rbaeq r5								; program eeprom

            ldil  r1, #'d'
            cmp   r1, r6
            beq   mem_dump						    ; ram dump

            ldil  r5, low[wb_dump]
            ldih  r5, high[wb_dump]
            ldil  r1, #'w'
            cmp   r1, r6
            rbaeq r5								; wishbone dump

            ldil  r1, #'r'
            cmp   r1, r6
            bne   console_input						; invalid input

            ; HARD restart - back to bootloader page
            clr   r0
            ldil  r1, #0x00
            ldih  r1, #0x80
            mcr   #1, sys1_core, r1, #1
            gt    r0


; -----------------------------------------------------------------------------------
; Booting from memory
; -----------------------------------------------------------------------------------
boot_memory:
            ldil  r2, low[string_booting]
            ldih  r2, high[string_booting]
            bl    uart_print__

            ; print no image info on start-up
            clr   r0
            stub  r2, r0

            b     start_image


; -----------------------------------------------------------------------------------
; Intermediate Brach Stops - Stop 2
; -----------------------------------------------------------------------------------
uart_print__:			b uart_print_
uart_linebreak__:		b uart_linebreak_
uart_sendbyte__:		b uart_sendbyte_
uart_receivebyte__:		b uart_receivebyte_
print_hex_string__:     b print_hex_string_


; -----------------------------------------------------------------------------------
; Booting from Wishbone device
; -----------------------------------------------------------------------------------
boot_wishbone:
            ; get and set base address
            ldil  r2, low[string_ewbadr]
            ldih  r2, high[string_ewbadr]
            bl    uart_print_

            ; get and set base address (32-bit)
            bl    receive_hex_word_
            mcr   #1, com1_core, r4, #2             ; set high part of base address
            bl    receive_hex_word_
            mcr   #1, com1_core, r4, #1             ; set low part of base address
            ldil  r0, low[user_wait]             ; wait for user to acknowledge
            ldih  r0, high[user_wait]
            gtl   r0
            bl    uart_linebreak_

            ; get signature
            bl    wb_read_word__                   ; get word from Wishbone
            ldil  r0, #0xFE
            ldih  r0, #0xCA
            cmp   r0, r6
            bne   signature_err_

            ; get size
            bl    wb_read_word__                   ; get word from Wishbone
            sft   r6, r6, #lsl                      ; size in words!
            stub  r0, r6

            ; get checksum
            bl    wb_read_word__                   ; get word from Wishbone
            stub  r1, r6

            ; get image name
            bl    wb_read_word__                   ; get word from Wishbone
            stub  r2, r6

            bl    wb_read_word__                   ; get word from Wishbone
            stub  r3, r6

            bl    wb_read_word__                   ; get word from Wishbone
            stub  r4, r6

            bl    wb_read_word__                   ; get word from Wishbone
            stub  r5, r6

            bl    wb_read_word__                   ; get word from Wishbone
            stub  r6, r6

            ; download program
            ldil  r5, #0							; base address MEMORY = 0x0000
            mcr   #1, sys1_core, r5, #2				; set system d-page
            mcr   #1, sys0_core, r5, #6				; set checksum = 0

boot_wishbone_loop:
            bl    wb_read_word__                    ; get word
            str   r6, r5, +#2, post, !				; save to data mem

            ; update checksum
            mrc   #1, r0, sys0_core, #6				; get checksum
            eor   r0, r0, r6
            mcr   #1, sys0_core, r0, #6				; set checksum

            ; check size counter
            ldub  r0, r0
            cmp   r5, r0							; done?
            bne   boot_wishbone_loop

            b     download_completed


; -----------------------------------------------------------------------------------
; Booting from SPI EEPROM
; -----------------------------------------------------------------------------------
boot_eeprom:
            ; get signature
            ldil  r2, #0
            bl    eeprom_get_word                   ; get word from EEPROM
            ldil  r0, #0xFE
            ldih  r0, #0xCA
            cmp   r0, r5
            bne   signature_err_

            ; get size in bytes
            ldil  r2, #2
            bl    eeprom_get_word                   ; get word from EEPROM
            stub  r0, r5

            ; get checksum
            ldil  r2, #4
            bl    eeprom_get_word                   ; get word from EEPROM
            stub  r1, r5

            ; get image name
            ldil  r2, #6
            bl    eeprom_get_word                   ; get word from EEPROM
            stub  r2, r5

            ldil  r2, #8
            bl    eeprom_get_word                   ; get word from EEPROM
            stub  r3, r5

            ldil  r2, #10
            bl    eeprom_get_word                   ; get word from EEPROM
            stub  r4, r5

            ldil  r2, #12
            bl    eeprom_get_word                   ; get word from EEPROM
            stub  r5, r5

            ldil  r2, #14
            bl    eeprom_get_word                   ; get word from EEPROM
            stub  r6, r5

            ; download program
            ldil  r4, #0							; base address MEMORY = 0x0000
            mcr   #1, sys1_core, r4, #2				; set system d-page
            mcr   #1, sys0_core, r4, #6				; set checksum = 0

boot_eeprom_loop:
            ldil  r0, #16                           ; base offset
            add   r2, r4, r0						; access EEPROM = MEM_pnt +16
            bl    eeprom_get_word                   ; get word from (address in r2)
            str   r5, r4, +#2, post, !				; save to data mem

            ; update checksum
            mrc   #1, r0, sys0_core, #6				; get checksum
            eor   r0, r0, r5
            mcr   #1, sys0_core, r0, #6				; set checksum

            ; check size counter
            ldub  r0, r0
            cmp   r4, r0							; done?
            bne   boot_eeprom_loop

            b     download_completed


            ; get word from (address in r2)
eeprom_get_word:
            mov   r6, lr
            bl    spi_eeprom_read_byte__			; read byte from eeprom
            sft   r5, r3, #swp
            inc   r2, r2, #1
            bl    spi_eeprom_read_byte__			; read byte from eeprom
            orr   r5, r5, r3
            ret   r6


; -----------------------------------------------------------------------------------
; Booting from UART
; -----------------------------------------------------------------------------------
boot_uart:	ldil  r2, low[string_boot_wimd]
            ldih  r2, high[string_boot_wimd]
            bl    uart_print_

            ; check signature (2 byte)
            bl    uart_get_word                     ; get a word from console
            ldil  r0, #0xFE
            ldih  r0, #0xCA
            cmp   r1, r0							; signature test
            bne   signature_err_

            ; get program size (2 byte)
            bl    uart_get_word                     ; get a word from console
            sft   r1, r1, #lsl						; #bytes = 2*#words
            stub  r0, r1

            ; get checksum (2 byte)
            bl    uart_get_word                     ; get a word from console
            stub  r1, r1

            ; get image name (10 byte)
            bl    uart_get_word                     ; get a word from console
            stub  r2, r1
            bl    uart_get_word                     ; get a word from console
            stub  r3, r1
            bl    uart_get_word                     ; get a word from console
            stub  r4, r1
            bl    uart_get_word                     ; get a word from console
            stub  r5, r1
            bl    uart_get_word                     ; get a word from console
            stub  r6, r1

            ; init download
            clr   r5								; address = 0x00000000
            mcr   #1, sys1_core, r5, #2				; set system d-page
            mcr   #1, sys0_core, r5, #6				; set checksum = 0

            ; downloader
uart_downloader:
            bl    uart_get_word                     ; get a word from console
            str   r1, r5, +#2, post, !				; save to data mem

            ; update checksum
            mrc   #1, r0, sys0_core, #6				; get checksum
            eor   r0, r0, r1
            mcr   #1, sys0_core, r0, #6				; set checksum

            ldub  r0, r0
            cmp   r5, r0							; done?
            bne   uart_downloader


; image download completed - prepare image launch
; ---------------------------------------------------
download_completed:
            ; re-init system d page
            mrc   #1, r0, sys1_core, #1				; get sys i-page
            mcr   #1, sys1_core, r0, #2				; reset system d-page

            ; download completed
            ldil  r2, low[string_done]
            ldih  r2, high[string_done]
            bl    uart_print_

            ; transfer done - check checksum
            mrc   #1, r0, sys0_core, #6				; get checksum
            ldub  r1, r1
            cmp   r0, r1
            beq   start_image

            ; checksum error!
            ldil  r2, low[string_err_check]
            ldih  r2, high[string_err_check]
            bl    uart_print_
            b     resume_error_					    ; resume error


            ; get a full word via console
uart_get_word:
            mov   r6, lr
            bl    uart_receivebyte_					; get high-byte
            sft   r1, r0, #swp						; swap bytes
            bl    uart_receivebyte_					; get low-byte
            orr   r1, r1, r0						; construct word
            ret   r6


; -----------------------------------------------------------------------------------
; Intermediate Brach Stops - Stop 1
; -----------------------------------------------------------------------------------
uart_print_:			b uart_print
uart_linebreak_:		b uart_linebreak
uart_sendbyte_:			b uart_sendbyte
uart_receivebyte_:		b uart_receivebyte
spi_eeprom_read_byte__:	b spi_eeprom_read_byte_
signature_err_:         b signature_err
console_input_:         b console_input
print_hex_string_:      b print_hex_string0
wb_read_word__:         b wb_read_word_
receive_hex_word_:      b receive_hex_word


; -----------------------------------------------------------------------------------
; Start image from memory
; -----------------------------------------------------------------------------------
start_image:
            ldil  r2, low[string_start_im]
            ldih  r2, high[string_start_im]
            bl    uart_print

            ; print image name
            ldubs r1, r2
            beq   start_image_no_text				; print image info?

            ldil  r1, #34							;'"'
            bl    uart_sendbyte
            ldub  r1, r2
            bl    start_image_print_name_sub
            ldub  r1, r3
            bl    start_image_print_name_sub
            ldub  r1, r4
            bl    start_image_print_name_sub
            ldub  r1, r5
            bl    start_image_print_name_sub
            ldub  r1, r6
            bl    start_image_print_name_sub
            ldil  r1, #34							;'"'
            bl    uart_sendbyte
            bl    uart_linebreak

start_image_no_text:
            ; print checksum
            ldil  r2, low[string_checksum]
            ldih  r2, high[string_checksum]
            bl    uart_print
            mrc   #1, r4, sys0_core, #6				; get checksum
            bl    print_hex_string                  ; print computed checksum
            bl    uart_linebreak

            ; start the image
            bl    uart_linebreak
            bl    uart_linebreak
            bl    uart_linebreak

            ; re-init MSR
            ldil  r1, #0x00
            ldih  r1, #0xC0                         ; current/prev mode = sys
            stsr  r1

            CLR   R0								; ZERO!

            ; clear alive LED
            mcr   #1, com0_core, r0, #7				; set system output

            ; set mmu pages, address: 0x0000
            mcr   #1, sys1_core, r0, #0             ; irq base address
            mcr   #1, sys1_core, r0, #3
            mcr   #1, sys1_core, r0, #4
            mcr   #1, sys1_core, r0, #2				; d-page - set first
            mcr   #1, sys1_core, r0, #1				; i-page
            gt    r0								; start image at 0x0000 & 0x0000


start_image_print_name_sub:
            mov   r6, lr
            sft   r1, r1, #swp
            bl    uart_sendbyte
            sft   r1, r1, #swp
            bl    uart_sendbyte
            ret   r6


; -----------------------------------------------------------------------------------
; RAM page dump via console
; -----------------------------------------------------------------------------------
mem_dump:	ldil  r2, low[string_edpage]
            ldih  r2, high[string_edpage]
            bl    uart_print

            ; get d-page
            bl    receive_hex_word

            ; wait for enter/abort
            ldil  r2, low[user_wait]
            ldih  r2, high[user_wait]
            gtl   r2

            ; let's go
            mcr   #1, sys1_core, r4, #2				; set d-page
            bl    uart_linebreak

            ; hex word loop
            ldil  r5, #0x00							; reset byte counter
mem_dump_loop:
            ; display address?
            ldil  r0, #0x0F
            ands  r0, r5, r0
            bne   mem_dump_loop_2

            ; display!
            bl    uart_linebreak
            ldil  r1, #36							; '$'
            bl    uart_sendbyte
            mrc   #1, r4, sys1_core, #2				; get d-page
            bl    print_hex_string					; print 4hex page
            ldil  r1, #'.'							; ' '
            bl    uart_sendbyte
            mov   r4, r5
            bl    print_hex_string					; print 4hex byte address
            ldil  r1, #58							; ':'
            bl    uart_sendbyte
            ldil  r1, #32							; ' '
            bl    uart_sendbyte

mem_dump_loop_2:
            ldr   r4, r5, +#2, post, !				; get one word

            ; display hex data
            ldil  r1, #32							; ' '
            bl    uart_sendbyte
            bl    print_hex_string					; print 4hex data

            ; print ASCII data?
            ldil  r0, #0x0F
            ands  r0, r5, r0
            bne   mem_dump_loop_3

            ; display!
            ldil  r1, #32							; ' '
            bl    uart_sendbyte
            bl    uart_sendbyte
            ldil  r0, #16
            sub   r4, r5, r0
            ldil  r0, #0xF0
            and   r4, r4, r0
            ldil  r2, #46							; '.'
mem_dump_ascii:
            ldr   r1, r4, +#1, post, !				; get one byte
            sft   r1, r1, #swp
            ldih  r1, #0x00							; clear high byte
            ldil  r0, #32							; ' ' space
            cmp   r1, r0							; is ASCII command?
            mvhi  r1, r2                            ; no? print '.'
            bl    uart_sendbyte
            ldil  r1, #0x0F
            and   r0, r1, r4
            teq   r0, r1
            bne   mem_dump_ascii

            ; user console interrupt?
mem_dump_loop_3:
            mrc   #1, r0, com0_core, #0				; get uart RTX register
            stb   r0, #15							; copy uart rx_ready flag to T-flag
            bts   mem_dump_end

            ; check pointer
            ldil  r3, #0xFE							; last address
            teq   r3, r5
            bne   mem_dump_loop

mem_dump_end:
            bl    uart_receivebyte					; wait for enter
            clr   r0
            gt    r0								; restart bootloader


; -----------------------------------------------------------------------------------
; Intermediate Brach Stops - Stop 0
; -----------------------------------------------------------------------------------
spi_eeprom_read_byte_:	b spi_eeprom_read_byte0
print_hex_string0:      b print_hex_string


; -----------------------------------------------------------------------------------
; Burn SPI EEPROM
; -----------------------------------------------------------------------------------
burn_eeprom:
            ; disable write protection
            ldil  r0, #1							; CS0
            mcr   #1, com0_core, r0, #4				; set CS
            ldil  r0, 0b01010000					; UART EN, auto CS, MSB first, mode 0
            ldih  r0, 0b00111111					; prsc 3, length = 16 bit
            mcr   #1, com0_core, r0, #2				; SPI config

            ldil  r0, #0x00
            ldih  r0, #0x01							; write status reg
            bl    spi_trans							; iniatiate transmission
    
            ; we are ready! - waiting for image data...
            ldil  r2, low[string_prog_eep]
            ldih  r2, high[string_prog_eep]
            bl    uart_print
            ldil  r2, low[string_boot_wimd]
            ldih  r2, high[string_boot_wimd]
            bl    uart_print

            ; get signature
            bl    uart_receivebyte					; get high-byte
            sft   r1, r0, #swp						; swap bytes
            bl    uart_receivebyte					; get low-byte
            orr   r0, r1, r0						; construct word
            ldil  r1, #0xFE
            ldih  r1, #0xCA
            cmp   r0, r1
            bne   signature_err

            ; write signature (2 bytes)
            ldil  r2, #0
            mov   r5, r1
            bl    eeprom_write_word                 ; write word to eeprom

            ; get image size
            bl    uart_receivebyte					; get high-byte
            sft   r1, r0, #swp						; swap bytes
            bl    uart_receivebyte					; get low-byte
            orr   r5, r1, r0						; construct word
            sft   r5, r5, #lsl						; #bytes = 2*#words
            stub  r0, r5

            ; write image size (2 bytes)
            ldil  r2, #2
            bl    eeprom_write_word                 ; write word to eeprom

            ; get checksum
            bl    uart_receivebyte					; get high-byte
            sft   r1, r0, #swp						; swap bytes
            bl    uart_receivebyte					; get low-byte
            orr   r5, r1, r0						; construct word
            stub  r1, r5

            ; write checksum (2 bytes)
            ldil  r2, #4
            bl    eeprom_write_word                 ; write word to eeprom

            ; write image name (10 bytes)
            ldil  r2, #6							; base address
burn_eeprom_image_name:
            bl    uart_receivebyte					; get byte
            mov   r3, r0
            bl    spi_eeprom_write_byte
            inc   r2, r2, #1
            ldil  r0, #16							; end address
            cmp   r2, r0
            bne   burn_eeprom_image_name

            ; write image data
;           ldil  r2, #16							; base address
            clr   r5								; byte counter
burn_eeprom_image_data:
            bl    uart_receivebyte					; get byte
            mov   r3, r0
            bl    spi_eeprom_write_byte
            inc   r2, r2, #1
            ldub  r0, r0							; get absolute size
            inc   r5, r5, #1
            cmp   r5, r0
            bne   burn_eeprom_image_data

            ; set global write protection
            ldil  r0, #1							; CS0
            mcr   #1, com0_core, r0, #4				; set CS
            ldil  r0, 0b01010000					; UART EN, auto CS, MSB first, mode 0
            ldih  r0, 0b00111111					; prsc 3, length = 16 bit
            mcr   #1, com0_core, r0, #2				; SPI config

            ldil  r0, #0x0C							; protect all
            ldih  r0, #0x01							; status reg write
            bl    spi_trans							; iniatiate transmission

            ; we are done!
            ldil  r2, low[string_done]
            ldih  r2, high[string_done]
            bl    uart_print

            ; return to main console
            ldil  r5, low[start_console]
            ldih  r5, high[start_console]
            gt    r5


            ; write word in r5 to eeprom, address in r2
eeprom_write_word:
            mov   r6, lr
            sft   r3, r5, #swp
            bl    spi_eeprom_write_byte
            inc   r2, r2, #1
            mov   r3, r5
            bl    spi_eeprom_write_byte
            ret   r6


; -----------------------------------------------------------------------------------
; Signature error
; -----------------------------------------------------------------------------------
signature_err:
            ldil  r2, low[string_err_image]
            ldih  r2, high[string_err_image]
            bl    uart_print
resume_error_:                                      ; interm. branch stop
            b     resume_error				        ; resume error


; *****************************************************************************************************************
; Communication subroutines
; *****************************************************************************************************************

; -----------------------------------------------------------------------------------
; Intermediate Brach Stops
; -----------------------------------------------------------------------------------
spi_eeprom_read_byte0:	b spi_eeprom_read_byte
wb_read_word_:          b wb_read_word


; --------------------------------------------------------------------------------------------------------
; Print char-string (bytes) via CP1.COM_0.UART
; Arguments: r2 = address of string (string must be zero-terminated!)
; Results: -
; Used registers: r0, r1, r2, r3, lr
uart_print:
; --------------------------------------------------------------------------------------------------------
            mov   r3, lr

uart_print_loop:
            ldr   r1, r2, +#1, post, !				; get one string byte
      sft   r1, r1, #swp						; swap high and low byte
            ldih  r1, #0x00							; clear high byte
      teq   r1, r1							; test if string end
            beq   uart_print_loop_end
            bl    uart_sendbyte
            b     uart_print_loop

uart_print_loop_end:
            ret   r3


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
; Print char (byte) via CP1.COM_0.UART
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
; Receive a byte via CP1.COM_0.UART
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
; Reads 16 bit data as 4x hex chars via UART (and echo them)
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
            bls   #+2								; '0'..'9' -> ok
            dec   r1, r1, #7						; 'A' - '0' - 10 = 7 -> 'A'..'F' -> ok

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
; Used registers: r0, r1, r2, r4, r6, lr
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
conv_hex_comp:
            ldil  r1, #0x0f					        ; mask for lowest 4 bit
            and   r2, r2, r1

            ldil  r1, #9
            cmp   r1, r2
            bcs   #+3

            ldil  r1, #48					        ; this is a '0'
            b     #+2
            ldil  r1, #55					        ; this is an 'A'-10
            add   r1, r1, r2				        ; resulting char in lower byte
            ret   lr


; --------------------------------------------------------------------------------------------------------
; Starts SPI transmission and waits for transmission to finish
; Arguments:
;  r0 = TX data
; Results:
;  r0 = RX data
; Used registers: r0
spi_trans:
; --------------------------------------------------------------------------------------------------------
            mcr   #1, com0_core, r0, #3				; set SPI data - start transfer

            ; wait for end
            mrc   #1, r0, com0_core, #2				; get status reg
            stb   r0, #3							; busy flag
            bts   #-2								; still set?

            mrc   #1, r0, com0_core, #3				; get received data

            ret   lr


; --------------------------------------------------------------------------------------------------------
; Writes 1 byte to serial EEPROM @ CS0
; Arguments:
;  r2 = Address word
;  r3 = Data byte (low part)
; Results: -
; Used registers: r0, r1, r2, r3, lr
spi_eeprom_write_byte:
; --------------------------------------------------------------------------------------------------------
            mov   r1, lr							; save link register

            ; set write-enable latch
            ; -------------------------------------------
            ldil  r0, 0b01010000					; UART EN, auto CS, MSB first, mode 0
            ldih  r0, 0b00110111					; prsc 3, length = 8 bit
            mcr   #1, com0_core, r0, #2				; SPI config
            ldil  r0, #1							; CS0
            mcr   #1, com0_core, r0, #4				; config CS
            ldil  r0, #0x06							; write enable command
            bl    spi_trans							; iniatiate transmission

            ; check status reg
            ; -------------------------------------------
            ldil  r0, 0b01010000					; UART EN, auto CS, MSB first, mode 0
            ldih  r0, 0b00111111					; prsc 3, length = 16 bit
            mcr   #1, com0_core, r0, #2				; SPI config
            ldil  r0, #0x00
            ldih  r0, #0x05							; read SREG command
            bl    spi_trans							; iniatiate transmission

            ; check WIP flag
            stb   r0, #1							; WEL flag
            bts   spi_eeprom_write

            ; EEPROM ACCESS ERROR!
            ldil  r2, low[string_err_eep]
            ldih  r2, high[string_err_eep]
            bl    uart_print
            b     resume_error					    ; resume error

spi_eeprom_write:
            ; send write instruction and
            ; high address byte (16 bit trans)
            ; -------------------------------------------
            ldil  r0, 0b01000000					; UART EN, manual CS, MSB first, mode 0
            ldih  r0, 0b00111111					; prsc 3, length = 16 bit
            mcr   #1, com0_core, r0, #2				; SPI config

            ldil  r0, #1							; CS0
            mcr   #1, com0_core, r0, #4				; pre-assert CS

            sft   r0, r2, #swp						; swap high address byte to low byte
            ldih  r0, #0x02							; write command
            bl    spi_trans							; iniatiate transmission

            ; send low address byte and
            ; send data byte (16 bit trans)
            ; -------------------------------------------
            mov   lr, r2							; copy address
            ldih  lr, #0x00							; clear high part
            sft   lr, lr, #swp						; swap bytes
            mov   r0, r3							; copy data byte
            ldih  r0, #0x00							; clear high data byte
            orr   r0, r0, lr						; merge low address and data byte
            bl    spi_trans							; iniatiate transmission

            clr   r0
            mcr   #1, com0_core, r0, #4				; de-assert CS

            ; wait for write command to finish
            ; 16 bit transfer
            ; -------------------------------------------
            ldil  r0, 0b01010000					; UART EN, auto CS, MSB first, mode 0
            ldih  r0, 0b00111111					; prsc 3, length = 16 bit
            mcr   #1, com0_core, r0, #2				; SPI config
            ldil  r0, #1							; CS0
            mcr   #1, com0_core, r0, #4				; set CS

spi_eeprom_write_byte_bsy:
            ldil  r0, #0x00
            ldih  r0, #0x05							; read SREG command
            bl    spi_trans							; iniatiate transmission

            ; check WIP flag
            stb   r0, #0							; WIP flag
            bts   spi_eeprom_write_byte_bsy

            ret   r1


; --------------------------------------------------------------------------------------------------------
; Reads 1 byte from serial EEPROM @ CS0
; Arguments:
;  r2 = Address word
; Results:
;  r3 = Data byte (low part)
; Used registers: r0, r1, r2, r3, lr
spi_eeprom_read_byte:
; --------------------------------------------------------------------------------------------------------
            mov   r1, lr							; save link register

            ; config SPI
            ldil  r0, 0b01000000					; UART EN, manual CS, MSB first, mode 0
            ldih  r0, 0b00111111					; prsc 3, length = 16 bit
            mcr   #1, com0_core, r0, #2				; SPI config
            ldil  r0, #1							; CS0
            mcr   #1, com0_core, r0, #4				; pre-assert CS

            ; send read instruction and
            ; high address (16 bit trans)
            ; -------------------------------------------
            sft   r0, r2, #swp						; swap high address byte to low byte
            ldih  r0, #0x03							; read command
            bl    spi_trans							; iniatiate transmission

            ; send low address byte and
            ; read data byte (16 bit trans)
            ; -------------------------------------------
            mov   r0, r2							; copy address
            ldih  r0, #0x00							; data transfer dummy
            sft   r0, r0, #swp						; swap data and address bytes
            bl    spi_trans							; iniatiate transmission

            clr   r3
            mcr   #1, com0_core, r3, #4				; deassert CS
            mov   r3, r0
            ldih  r3, #0x00							; clear high byte

            ret   r1


; --------------------------------------------------------------------------------------------------------
; Reads 1 word from the Wishbone network (base address must be set before, word address increment)
; Arguments: -
; Results:
;  r6 = data
; Used registers: r0, r1, r6 ,lr
wb_read_word:
; --------------------------------------------------------------------------------------------------------
            cdp   #1, com1_core, com1_core, #0      ; initiate read-transfer

            mrc   #1, r0, com1_core, #0				; get WB status reg
            stb   r0, #6                            ; busy flag -> t-flag
            bts   #-2                               ; repeat until data is ready

            ; check word
            ldil  r6, #0b00000110                   ; bus or timeout flag set?
            ands  r0, r0, r6
            bne   wb_read_word_err

            ; increment base address
            mrc   #1, r1, com1_core, #1				; get WB base adr low
            mrc   #1, r6, com1_core, #2				; get WB base adr high
            clr   r0
            incs  r1, r1, #2                        ; inc 2 = one word
            adc   r6, r6, r0
            mcr   #1, com1_core, r1, #1             ; set low part of base address
            mcr   #1, com1_core, r6, #2             ; set high part of base address

            mrc   #1, r6, com1_core, #4				; get data
            ret   lr

            ; WB access error (ERR or no ACK)
wb_read_word_err:
            ldil  r2, low[string_err_wb]
            ldih  r2, high[string_err_wb]
            bl    uart_print
;           b     resume_error


; -----------------------------------------------------------------------------------
; Fatal error! Press key to resume (restart bootloader)
; -----------------------------------------------------------------------------------
resume_error:
            ldil  r2, low[string_err_res]
            ldih  r2, high[string_err_res]
            bl    uart_print
            bl    uart_receivebyte					; wait for any key input
            clr   r0
            gt    r0								; restart


; -----------------------------------------------------------------------------------
; Wait for user to cancel/proceed
; -----------------------------------------------------------------------------------
user_wait:  mov   r2, lr
user_wait_: bl    uart_receivebyte
            ldil  r1, #0x0D							; CR - enter
            cmp   r0, r1                            ; execute?
            rbaeq r2
            ldil  r1, #0x08							; Backspace - abort
            cmp   r0, r1                            ; abort?
            beq   wb_dump_end
            b     user_wait_


; *****************************************************************************************************************
; Wishbone Access
; *****************************************************************************************************************

; -----------------------------------------------------------------------------------
; Wisbone Dump
; -----------------------------------------------------------------------------------
wb_dump:    ldil  r2, low[string_ewbadr]
            ldih  r2, high[string_ewbadr]
            bl    uart_print

            ; get and set base address (32-bit)
            bl    receive_hex_word
            mcr   #1, com1_core, r4, #2             ; set high part of base address
            bl    receive_hex_word
            mcr   #1, com1_core, r4, #1             ; set low part of base address
            bl    user_wait                         ; wait for user
            bl    uart_linebreak

            ; get number of entries (16-bit
            ldil  r2, low[string_ewbnum]
            ldih  r2, high[string_ewbnum]
            bl    uart_print
            bl    receive_hex_word
            mov   r5, r4
            bl    user_wait                         ; wait for user
            bl    uart_linebreak

            ; download word from wishbone net
wb_dump_loop:
            teq   r5, r5
            beq   wb_dump_end
            dec   r5, r5, #1

            ; print address (32 bit)
            bl    uart_linebreak
            ldil  r1, #'$'
            bl    uart_sendbyte
            mrc   #1, r4, com1_core, #2				; get hi address
            bl    print_hex_string
            mrc   #1, r4, com1_core, #1				; get lo address
            bl    print_hex_string
            ldil  r1, #58                          ;':'
            bl    uart_sendbyte

            ; print hex data word
            ldil  r1, #32
            bl    uart_sendbyte
            bl    wb_read_word
            mov   r4, r6                            ; data from wishbone
            bl    print_hex_string

            ; print ascii data
            ldil  r6, #32
            ldil  r3, #'.'
            mov   r1, r6                            ; space
            bl    uart_sendbyte

            ; high char
            sft   r1, r4, #swp
            ldih  r1, #0x00
            cmp   r1, r6
            mvhi  r1, r3
            bl    uart_sendbyte

            ; low char
            mov   r1, r4
            ldih  r1, #0x00
            cmp   r1, r6
            mvhi  r1, r3
            bl    uart_sendbyte

            ; user input?
            mrc   #1, r1, com0_core, #0				; get uart status/data register
            stbi  r1, #15							; copy inverted uart rx_ready flag to T-flag
            bts   wb_dump_loop

            ; return to main console
wb_dump_end:
            bl    uart_linebreak
            ldil  r5, low[console_input]
            ldih  r5, high[console_input]
            gt    r5



; *****************************************************************************************************************
; ROM: Text strings
; *****************************************************************************************************************
string_intro0:    .stringz "\n\nAtlas-2K Bootloader - V20140516\nby Stephan Nolting, stnolting@gmail.com\nwww.opencores.org/project,atlas_core\n"
string_intro3:    .stringz "\nBoot page: 0x"
string_intro4:    .stringz "\nClock(Hz): 0x"

string_booting:   .stringz "Booting\n"
string_prog_eep:  .stringz "Burn EEPROM\n"
string_boot_wimd: .stringz "Awaiting image...\n"
string_start_im:  .stringz "Starting image "
string_done:      .stringz "Download complete\n"
string_edpage:    .stringz "Page (4h): $"
string_ewbadr:    .stringz "Addr (8h): $"
string_ewbnum:    .stringz "#words (4h): $"
string_checksum:  .stringz "Checksum: $"


string_menu0:     .stringz "\ncmd/boot-switch:\n 0/'00': (Re-)Start console\n 1/'01': Boot UART\n 2/'10': Boot EEPROM\n 3/'11': Boot memory\n"
string_menup:     .stringz " 4: Boot WB\n p: Burn EEPROM\n d: RAM dump\n r: Reset\n w: WB dump\n"
string_menux:     .stringz "cmd:> "

string_err_image: .stringz "IMAGE ERR!\n"
string_err_irq:   .stringz "\nIRQ ERR!\n"
string_err_check: .stringz "CHECKSUM ERR!\n"
string_err_eep:   .stringz "SPI/EEPROM ERR!\n"
string_err_wb:    .stringz "WB BUS ERR!\n"
string_err_res:   .stringz "Press any key\n"
