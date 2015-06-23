; This file is part of the Next186 SoC PC project
; http://opencores.org/project,next186

; Filename: BIOS_Next186.asm
; Description: Part of the Next186 SoC PC project, ROM BIOS code
; Version 1.0
; Creation date: Feb-Jun 2013

; Author: Nicolae Dumitrache 
; e-mail: ndumitrache@opencores.org

; -------------------------------------------------------------------------------------
 
; Copyright (C) 2013 Nicolae Dumitrache
 
; This source file may be used and distributed without 
; restriction provided that this copyright statement is not 
; removed from the file and that any derivative work contains 
; the original copyright notice and the associated disclaimer.
 
; This source file is free software; you can redistribute it 
; and/or modify it under the terms of the GNU Lesser General 
; Public License as published by the Free Software Foundation;
; either version 2.1 of the License, or (at your option) any 
; later version. 
 
; This source is distributed in the hope that it will be 
; useful, but WITHOUT ANY WARRANTY; without even the implied 
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
; PURPOSE. See the GNU Lesser General Public License for more 
; details. 
 
; You should have received a copy of the GNU Lesser General 
; Public License along with this source; if not, download it 
; from http://www.opencores.org/lgpl.shtml 
 
; -----------------------------------------------------------------------

; Additional Comments: 
; Assembled with MASM v6.14.8444
; Next186 SoC PC have no ROM, only RAM. The bootstrap code is the initial value of cache 
;  (last half 1K = 4 lines of 256bytes each), initially marked as "dirty", in order to
;  be saved in RAM at first flush
; The bootstrap code may load the BIOS from SD, or from RS232, and place it at F000:E000



.186
.model tiny
.code

SCANCODE1   equ 1

;-------------------------- BIOS data area (BDA) -----------------
;40:0000   2  Base port address of first RS-232 adapter (COM1) See COM Ports
;40:0002   2  Port of COM2
;40:0004   2  Port of COM3
;40:0006   2  Port of COM4
;40:0008   2  Base port addr of first parallel printer (LPT1)  Printer Ports
;40:000A   2  Port of LPT2
;40:000C   2  Port of LPT3
;40:000E   2  Port of LPT4
;40:0010   2  Equipment/hardware installed/active; see Equipment List
;40:0012   1  Errors in PCjr infrared keyboard link
;40:0013   2  Total memory in K-bytes (same as obtained via INT 12H)
;40:0015   2  Scratch pad for manufacturing error tests
;
;40:0017   2  Keyboard status bits; see Keyboard Shift Status Flags
;40:0019   1  Current (accumulating) value of Alt+numpad pseudo-key input;
;             normally 0.  When [Alt] is released, value is stored in
;             keyboard buffer at 001e.
;40:001a   2  Addr of keyboard buffer head (keystroke at that addr is next)
;40:001c   2  Address of keyboard buffer tail
;40:001e  32  Keyboard buffer.  BIOS stores keystrokes here (head and tail
;             point to addresses from 041eH to 043dH inclusive).
;
;40:003e   1  Diskette drive needs recalibration (bit 0=A, bit 1=B, etc.)
;             bits 4-5 indicate which drive is currently selected
;40:003f   1  Diskette motor is running (bit 0=drive A, bit 1=B, etc.)
;40:0040   1  Time until motor off. INT 08H turns motor off when this is 0.
;40:0041   1  Diskette error status; same as status returned by INT 13H
;40:0042   7  Diskette controller status information area
;
;40:0049   1  Current active video mode.  See Video Modes and INT 10H.
;40:004a   2  Screen width in text columns
;40:004c   2  Length (in bytes) of video area (regen size)
;40:004e   2  Offset from video segment of active video memory page
;40:0050  16  Cursor location (8 byte-pairs; low byte=clm, hi byte=row)
;40:0060   2  Cursor size/shape.  Low byte=end scan line; hi byte=start line.
;40:0062   1  Current active video page number
;40:0063   2  Port address for 6845 video controller chip; see CGA I/O Ports
;40:0065   1  Current value of 6845 video ctrlr CRT_MODE (port 3x8H register)
;40:0066   1  Current value of 6845 video ctrlr CRT_PALETTE (port 3x9H reg)
;
;40:0067   5  Cassette data area or POST data area
;               40:0067: 1 byte mouse buffer counter (DataCounter)
;               40:0068: 1 byte mouse packet size (PacketSize): 0 for 3 bytes, 1 for 4 bytes (Intellimouse)
;               40:0069: 1 byte palette paging status
;               40:006a: 1 byte PalPagingCounter - guards pal paging re-entrance
;
;40:006c   4  Timer tick counter (count of 55ms ticks since CPU reset)
;40:0070   1  Timer overflow flag (timer has rolled over 24 hr)
;40:0071   1  Ctrl-Break flag.  Bit 7=1 when break was pressed.  This never
;             gets reset unless you do it yourself.
;
;40:0072   2  1234H means Ctrl+Alt+Del reboot is in progress.  BIOS checks
;             this to avoid doing a "cold boot" with the time-consuming POST
;             4321H means reset, preserving memory
;             5678H, 9abcH, and abcdH (are internal PC Convertible codes)
;
;40:0074   4  PCjr diskette or AT hard disk control area
;  (0074)   1 Status of last fixed-disk drive operation
;  (0075)   1 Number of hard disk drives for AT
;  (0077)   1 Hard disk port for XT.  See XT Hard Disk Ports.
;40:0078   4  Printer time-out values (478H=Lpt1, 478H=Lpt2...)
;40:007c   4  RS-232 time-out values  (47cH=Com1, 47dH=Com2...)
;
;40:0080   2  AT PS/2 keyboard buffer offset start address (usually 01eH)
;40:0082   2                                   end address (usually 003eH)
;
;40:0084   1  EGA text rows-1  (maximum valid row value)
;40:0085   2  EGA bytes per character (scan-lines/char used in active mode)
;40:0087   1  EGA flags; see EgaMiscInfoRec
;40:0088   1  EGA flags; see EgaMiscInfo2Rec
;40:0089   1  VGA flags; see VgaFlagsRec
;             See also:  EGA/VGA Data Areas
;
;40:008b   1  AT PS/2 Media control: data rate, step rate
;40:008c   1  AT PS/2 Hard disk drive controller status
;40:008d   1  AT PS/2 Hard disk drive error status
;40:008e   1  AT PS/2 Hard disk drive interrupt control
;
;40:0090   1  AT PS/2 Disk media state bits for drive 0
;40:0091   1                                for drive 1
;40:0092   1  AT PS/2 Disk operation started flag for drive 0
;40:0093   1                                      for drive 1

;40:0094   1  AT PS/2 Present cylinder number for drive 0
;40:0095   1                                  for drive 1
        ; 2 - Number of 512bytes sectors of HD0
;
;40:0096   1  AT Keyboard flag bit 4=1 (10H) if 101-key keyboard is attached
;40:0097   1  AT Keyboard flag for LED 'key lock' display
;             bits 0-2 are ScrollLock, NumLock, CapsLock
;
;40:0098   4  AT Pointer to 8-bit user wait flag; see INT 15H 86H
;40:009c   4  AT Microseconds before user wait is done
;40:00a0   1  AT User wait activity flag:
;                01H=busy, 80H=posted, 00H=acknowledged
;
;40:00a1   7  AT Reserved for network adapters
;               40:00a1: 4 bytes far pointer to mouse callback (HandlerPtr)
;               40:00a5: 3 bytes mouse buffer (DataBuffer)
;
;40:00a8   4  EGA Address of table of pointers; see EgaSavePtrRec
;40:00ac  68  Reserved
;40:00f0  16  (IAC) Inter-Aapplication Communication area.  Programs may use
;             this area to store status, etc.  Might get overwritten by
;             another program.

; http://www.ctyme.com/intr/int.htm

; video memory: 8 physical segments at 0a000h, 0b000h, 0c000h, 0d000h, 0e000h, 0f000h, 10000h, 11000h
; Memory segments mapping
; 1Mb virtual seg address   physical seg address
;       0000h                   0000h
;       1000h                   1000h
;       2000h                   2000h
;       3000h                   3000h
;       4000h                   4000h
;       5000h                   5000h
;       6000h                   6000h
;       7000h                   7000h
;       8000h                   8000h
;       9000h                   9000h
;       a000h                   a000h       - video
;       b000h                   b000h       - video
;       c000h                   12000h
;       d000h                   13000h
;       e000h                   14000h
;       f000h                   15000h


        org 0e000h
bios:        
biosmsg     db 'Next186 Spartan3AN SoC PC BIOS (C) 2013 Nicolae Dumitrache', 0
msgmb       db 'MB SD Card', 13, 10, 0
msgkb       db 'PS2 KB detected', 13, 10, 0


; Graphics character set
font8x8:         ; TODO define and place font
font8x16:        ; TODO define and place font
        
        org 0e05bh
coldboot:
warmboot:
        cli
        cld
        mov     ax, 30h
        mov     ss, ax
        mov     sp, 100h
        
        push    0
        popf
        
        mov     al, 36h
        out     43h, al
        xor     ax, ax
        out     40h, al
        out     40h, al      ; 18Hz PIT CH0
        out     61h, al      ; speaker off
        not     al
        out     21h, al      ; disable all interrupts
        

; ------------------ MAP init
        call    flush
        mov     ax, 15h     ; BIOS physical segment 15h mapped on virtual segment 0ch
        out     8ch, ax
        push    0c000h
        pop     es
        push    0f000h
        pop     ds
        xor     si, si
        xor     di, di
        mov     cx, 8000h
        rep     movsw       ; copy BIOS virtual segment 0fh over physical segment 15h

        call    flush
        mov     dx, 80h      
        xor     ax, ax
mapi:        
        out     dx, ax
        inc     ax
        inc     dx
        cmp     al, 0ch
        jne     short mapi1
        add     al, 6
mapi1:        
        cmp     al, 16h
        jne     short mapi
        
; -------------------- Interrupt table init
        push    0
        pop     ds
        push    ds
        pop     es
        xor     si, si
        mov     di, 4
        mov     word ptr [si], offset defint
        mov     word ptr [si+2], cs
        mov     cx, 256-2
        rep     movsw
        mov     word ptr ds:[7*4], offset int07
        mov     word ptr ds:[8*4], offset int08
        mov     word ptr ds:[9*4], offset int09
        mov     word ptr ds:[10h*4], offset int10        
        mov     word ptr ds:[11h*4], offset int11        
        mov     word ptr ds:[12h*4], offset int12        
        mov     word ptr ds:[13h*4], offset int13        
        mov     word ptr ds:[15h*4], offset int15
        mov     word ptr ds:[16h*4], offset int16
        mov     word ptr ds:[18h*4], offset int18
        mov     word ptr ds:[19h*4], offset int19
        mov     word ptr ds:[1ah*4], offset int1a
        mov     word ptr ds:[70h*4], offset int70
        mov     word ptr ds:[74h*4], offset int74

; ------------------- BDA init
        push    40h
        pop     ds
        push    ds
        pop     es
        xor     di, di
        xor     si, si
        xor     ax, ax
        mov     cl, 80h
        rep     stosw
        mov     byte ptr [si+10h], 24h   ; equipment word (color 80x25, PS2 mouse present)
        mov     word ptr [si+13h], 640   ; memory size in KB
        add     word ptr [si+1ah], 1eh   ; next char pointer in kb buffer
        add     word ptr [si+1ch], 1eh   ; last char pointer in kb buffer
        mov     word ptr [si+60h], 0e0fh ; cursor shape
        mov     word ptr [si+63h], 3d4h  ; video port address
        add     word ptr [si+80h], 1eh   ; start kb buffer
        add     word ptr [si+82h], 3eh   ; end kb buffer
        mov     word ptr [si+87h], 0940h ; video adapter options (512Kb video)
        mov     word ptr [si+89h], 0b71h ; VGA video flags: 400 line text mode, default palette loading on (0), blinking on
        mov     byte ptr [si+96h], 10h   ; 101 keyboard installed
 
; ------------------- Graph mode init
        mov     ax, 3
        int     10h

 ; ------------------- KB init ----------------
        mov     al, 0aeh
        out     64h, al     ; enable kb
        mov     al, 0a7h
        out     64h, al     ; disable mouse
        mov     cx, 25
kbi1:       
        call    getps2byte
        loop    short kbi1  ; wait for kb timeout
        mov     ah, 0ffh    ; reset kb
        clc                 ; kb command
        call    sendcmd   
        jc      short nokb
        mov     cl, 25
kbi2:        
        dec     cx
        jcxz    short nokb
        call    getps2byte
        jc      short kbi2  ; wait for BAT
        cmp     al, 0aah
        jne     short nokb
        mov     ah, 0f2h    ; kb id
        call    sendcmd     ; CF = 0
        jc      short nokb
        call    getps2byte
        cmp     al, 0abh
        jne     short nokb
        call    getps2byte
        cmp     al, 83h
; set scan code 1
IFDEF SCANCODE1
        jne     short nokb
        mov     ah, 0f0h    ; kb scan set
        call    sendcmd   
        jc      short nokb
        mov     ah, 1       ; scan set 1
        call    sendcmd   
        jnc     short kbok
ELSE
        je     short kbok
ENDIF        

nokb:   
        mov     byte ptr KbdFlags3, 0   ; kb not present
kbok:
        mov     al, 0adh
        out     64h, al      ; disable kb interface

; ------------------- Mouse init ----------------
        mov     al, 0a8h
        out     64h, al      ; enable mouse
mousei0:        
        call    getps2byte
        jnc     short mousei0
        mov     ah, 0ffh
        call    sendcmd      ; reset mouse (CF = 1)
        jc      short nomouse
        mov     cl, 25
mousei1:        
        dec     cx
        jcxz    short nomouse
        call    getps2byte
        jc      short mousei1
        cmp     al, 0aah     ; BAT
        jne     short nomouse
        call    getps2byte
        cmp     al, 0        ; mouse ID
        je      short mouseok
nomouse:
        mov     al, 0a7h        
        out     64h, al      ; disable mouse
        and     byte ptr EquipmentWord, not 4 ; ps2 mouse not present in equipement word
mouseok:
        call    enableKbIfPresent

        mov     al, 20h
        out     64h, al
        in      al, 60h
        or      al, 3
        mov     ah, al
        mov     al, 60h
        out     64h, al
        mov     al, ah
        out     60h, al     ; enable 8042 mouse and kb interrupts

        mov     ax,1000-1   ; 1ms
        out     70h, ax     ; set RTC frequency

        mov     al, 0e4h
        out     21h, al     ; enable all PIC interrupts (8h, 9h, 70h, 74h)
        sti                 ; enable CPU interrupts

; ---------------------   HDD init
        call    sdinit
        mov     HDSize, ax
        push    cs
        pop     es
        mov     si, offset biosmsg
        call    prts
        mov     si, offset bioscont
        call    prts
        mov     ax, HDSize
        shr     ax, 1
        call    dispAX
        mov     si, offset msgmb
        call    prts
        test    byte ptr KbdFlags3, 10h
        jz      nokbmsg
        mov     si, offset msgkb
        call    prts
nokbmsg:
        test    byte ptr EquipmentWord, 4
        jz      nomousemsg
        mov     si, offset msgmouse
        call    prts
nomousemsg:

;-------------- HD bootstrap
        mov     ax, 305h
        xor     bx, bx
        int     16h     ; set typematic rate and delay to fastest
        int     19h

msgmouse    db 'PS2 Mouse detected', 13, 10, 0        
bioscont    db 13, 10, 'CPU: 80186 33Mhz (33MIPS, 66Mhz 32bit bus)', 13, 10
            db 'RAM: 64MB DDR2 133Mhz', 13, 10
            db 'Cache: 8x256 bytes data/inst', 13, 10
            db 'HD0: ', 0

; ---------------------------- INT 07 ---------------------
int07 proc near ; coprocessor ESC sequence
        push    ax
        push    bx
        push    ds
        push    bp
        mov     bp, sp
        lds     bx, [bp+8]  
int07_pfx:        
        mov     al, [bx]
        inc     bx
        and     al, 0f8h
        cmp     al, 0d8h        ; ESC code
        jne     short int07_pfx
              
        cmp     byte ptr [bx], 0c0h ; mod reg r/m of ESC 8087 instruction
        sbb     al, al
        and     al, [bx]
        and     ax, 0c7h
        cmp     al, 6
        jne     int072
        mov     al, 80h
int072:
        shr     al, 6
        inc     ax
        add     ax, bx
        mov     [bp+8], ax
        pop     bp
        pop     ds
        pop     bx
        pop     ax
        iret
int07 endp


; ---------------------------- INT 08 ---------------------
int08 proc near
        push    ds
        push    bx
        push    40h
        pop     ds
        mov     bx, 6ch
        add     word ptr [bx], 1
        adc     word ptr [bx+2], 0
        cmp     word ptr [bx+2], 18h
        jne     short int081
        cmp     word ptr [bx], 0b0h
        jne     short int081
        mov     word ptr [bx], 0
        mov     word ptr [bx+2], 0
        mov     byte ptr [bx+4], 1
int081:
        int     1ch
        sti
        push    ax
        mov     ah, 4
kloop:        
        in      al, 64h
        test    al, 1
        jz      short nokey
        dec     ah
        jnz     short kloop
        test    al, 20h
        jz      short kbdata
        int     74h
        jmp     short nokey
kbdata:
        int     9h        
nokey:
        pop     ax
        pop     bx
        pop     ds
        iret
int08 endp

; --------------------- INT 09 - keyboard ------------------
KbdFlags1       equ     <ds:[17h]>
KbdFlags2       equ     <ds:[18h]>
AltKpd          equ     <ds:[19h]>
CtrlBreak       equ     <ds:[71h]>
KbdFlags3       equ     <ds:[96h]>
KbdFlags4       equ     <ds:[97h]>

; Bits for the KbdFlags1
RShfDown        equ     1
LShfDown        equ     2
CtrlDown        equ     4
AltDown         equ     8
ScrLock         equ     10h
NumLock         equ     20h
CapsLock        equ     40h
Insert          equ     80h

; Bits for the KbdFlags2
LCtrDown        equ     1
LAltDown        equ     2
SysReqDown      equ     4
Pause           equ     8
ScrLockDown     equ     10h
NumLockDown     equ     20h
CapsLockDown    equ     40h
InsDown         equ     80h
 
; Bits for the KbdFlags3
LastE1          equ     1
LastE0          equ     2
RCtrDown        equ     4
RAltDown        equ     8
LastF0          equ     20h

; Bits for the KbdFlags4
ScrLockLED      equ     1
NumLockLED      equ     2
CapsLockLED     equ     4
SetRepeat       equ     8       ; Set auto repeat command in progress
AckReceived     equ     10h
LEDUpdate       equ     40h

IFDEF SCANCODE1

int09 proc near
        pusha
        push    ds
        push    es
        push    40h
        pop     ds
        in      al, 60h         ; al contains the scan code
        mov     dx, KbdFlags1
        mov     cx, KbdFlags3
        cmp     al, 0fah        ; ACK
        jne     short noACK
; ------------ manage ACK response
        test    ch, LEDUpdate
        jz      short ToggleACK ; no LED update
        test    ch, AckReceived
        jnz     short SecondACK ; second ACK received
        mov     ah, ch          ; LED update command sent, ACK received, need to send second byte
        and     ah, ScrLockLED or NumLockLED or CapsLockLED
        mov     bl, 0
        call    sendps2byte
        jmp     short ToggleACK
SecondACK:        
        xor     ch, LEDUpdate   ; second ACK, clear LED update bit
ToggleACK:
        xor     ch, AckReceived ; toggle ACK bit 
SetFlags1:                                  
        jmp     SetFlags               
        
; ------------ no ACK
noACK:
        mov     ah,4fh
        stc
        int     15h
        jnc     int09Exit
        cmp     al, 0e0h
        jne     short noE0
        or      cl, LastE0
        jmp     short SetFlags1
noE0:
        cmp     al, 0e1h
        jne     short noE1
        or      cl, LastE1
        jmp     short SetFlags1
noE1:   
        cmp     al, 53h     ; is DEL?
        jne     short noDEL
        mov     ah, dl
        and     ah, CtrlDown or AltDown
        cmp     ah, CtrlDown or AltDown
        jne     NormalKey   ; is DEL, but no CTRL+ALt+DEL
        mov     word ptr ds:[72h], 1234h    ; warm boot flag
        db      0eah
        dw      0, 0ffffh       ; reboot
noDEL:
        test    cl, LastE0
        jnz     short noRSUp    ; ignore fake shifts
        cmp     al, 2ah         ; left shift
        jne     short noLSDown
        or      dl, LShfDown
        jmp     short SetFlagsKey2
noLSDown:
        cmp     al, 2ah or 80h
        jne     short noLSUp
        and     dl, not LShfDown
        jmp     short SetFlagsKey2
noLSUp:
        cmp     al, 36h         ; right shift
        jne     short noRSDown
        or      dl, RShfDown
        jmp     short SetFlagsKey2
noRSDown:
        cmp     al, 36h or 80h
        jne     short noRSUP
        and     dl, not RShfDown
        jmp     short SetFlagsKey2
noRSUp:
        cmp     al, 38h         ; ALT
        jne     short noALTDown
        test    cl, LastE0
        jz      short LALTDn
        or      cl, RAltDown
        or      dl, AltDown
        jmp     short SetFlagsKey2
LALTDn:
        or      dx, (LAltDown shl 8) or AltDown
        jmp     short SetFlagsKey2
noALTDown:
        cmp     al, 38h or 80h
        jne     short noALTUp
        test    cl, LastE0
        jz      short LALTUp
        and     cl, not RAltDown
        and     dl, not AltDown
        jmp     short ALTup
LALTUp:
        and     dx, not ((LAltDown shl 8) or AltDown)
ALTUp:
        xor     ax, ax
        xchg    al, AltKpd
        test    al, al
        jz      short SetFlagsKey2     
        jmp     pushKey
noALTUp:
        cmp     al, 1dh         ; CTL
        jne     short noCTLDown
        test    cl, lastE0
        jz      short LCTLDn
        or      cl, RCtrDown
        or      dl, CtrlDown
SetFlagsKey2:        
        jmp     short SetFlagsKey1
LCTLDn:
        or      dx, (LCtrDown shl 8) or CtrlDown
        jmp     short SetFlagsKey1
noCTLDown:
        cmp     al, 1dh or 80h
        jne     short noCTLUp
        test    cl, LastE0
        jz      short LCTLUp
        and     cl, not RCtrDown
        and     dl, not CtrlDown
        jmp     short SetFlagsKey1
LCTLUp:
        and     dx,  not ((LCtrDown shl 8) or CtrlDown)
        jmp     short SetFlagsKey1
noCTLUp:
        mov     bx, 3a00h + CapsLock
        call    KeyLock
        jnc     short SetFlagsKey1
        
        mov     bx, 4600h + ScrLock
        push    dx          ; save ScrLock state bit (dl)
        call    KeyLock
        pop     bx          ; restore ScrLock state bit (bl)
        jc      short noScrLock
        test    dl, CtrlDown
        jz      short SetFlagsKey1; no break, just ScollLock
        mov     dl, bl      ; restore ScrLock flag
        test    bh, ScrLockDown
        jnz     short SetFlagsKey1 
        mov     byte ptr CtrlBreak, 80h   ; CTRL+BREAK flag
        mov     ax, Buffer
        mov     HeadPtr, ax
        mov     TailPtr, ax
        int     1bh
        xor     ax, ax
        jmp     pushkey
noScrLock:        
        test    cl, LastE0  ; INS
        jnz     short testINS
        test    dl, RShfDown or LShfDown
        jnz     short testINS
        test    dl, NumLock
        jnz     short NoIns      
testINS:
        mov     bx, 5200h + Insert
        call    KeyLock  
noIns:
        mov     bx, 4500h + NumLock
        push    dx          ; save NumLock state bit (dl)
        call    KeyLock
        pop     bx          ; restore NumLock state bit (bl)
        jc      short NormalKey   ; CTRL+NumLock = Pause
        test    dl, CtrlDown
        jz      short SetFlagsKey1
        mov     dl, bl      ; restore NumLock flag
        or      dh, Pause   ; set Pause bit
SetFlagsKey1:
        jmp     SetFlagsKey
E0Key:
        mov     di, offset E0KeyList
        push    cx
        mov     cx, E0KeyIndex - E0KeyList
        cld
        push    cs
        pop     es
        repne   scasb
        pop     cx
        jne     short SetFlagsKey
        mov     al, es:[di + E0KeyIndex - E0KeyList - 1]
        jmp     short KeyDown
NormalKey:
        test    al, 80h
        jnz     short SetFlagsKey ; key up
        test    cl, LastE0
        jnz     short E0Key
        cmp     al, 59h
        sbb     ah, ah
        and     al, ah
        mov     bx, offset KeyIndex
        xlat    cs:[bx]
KeyDown:
        xor     bx, bx 
        test    dl, RShfDown or LShfDown
        jz      short noShift
        mov     bl, 2
noShift:
        cmp     al, 26
        ja      short noCaps
        test    dl, CapsLock
        jz      short noNum
        xor     bl, 2
        jmp     short noNum 
noCaps:
        cmp     al, 37
        ja      short noNum
        test    dl, NumLock
        jnz     short NumDown
        mov     bl, 2
NumDown:
        xor     bl, 2
noNum:        
        test    dl, CtrlDown
        jz      short noCtrl
        mov     bl, 4
noCtrl:
        test    dl, AltDown
        jz      short noAlt
        mov     bl, 6
noAlt:
        cbw
        shl     ax, 3
        add     bx, ax
        mov     ax, cs:KeyCode[bx]
        cmp     ax, 000ah
        ja      short pushKey
        dec     ax
        js      short SetFlagsKey     ; ax was 0
        mov     ah, AltKpd
        aad
        mov     AltKpd, al
        jmp     short SetFlagsKey
pushKey:                
        push    cx
        mov     cx, ax
        mov     ah, 5
        int     16h
        pop     cx
        and     dh, not Pause    ; clear Pause bit
SetFlagsKey:
        and     cl, not (LastE0 or LastE1)    ; not prefix key code, clear all prefixes
SetFlags:
        mov     al, dl
        shr     al, 4
        xor     al, ch
        and     al, 7
        jz      short SF1   ; no LEDs to update
        test    ch, SetRepeat or AckReceived or LEDUpdate
        jnz     short SF1   ; can not update LEDS, so just write the flags and exit
        or      al, LEDUpdate
        xor     ch, al      ; insert the LEDs in KbdFlags4
        mov     ah, 0edh    ; set LED
        mov     bl, 0
        call    sendps2byte
SF1:        
        mov     KbdFlags1, dx
        mov     KbdFlags3, cx
        
int09Exit:
        pop     es
        pop     ds
        popa
        iret
int09 endp

ELSE    ; SCANCODE2

int09 proc near
        pusha
        push    ds
        push    es
        push    40h
        pop     ds
        in      al, 60h         ; al contains the scan code
        mov     dx, KbdFlags1
        mov     cx, KbdFlags3
        cmp     al, 0fah        ; ACK
        jne     short noACK
; ------------ manage ACK response
        test    ch, LEDUpdate
        jz      short ToggleACK ; no LED update
        test    ch, AckReceived
        jnz     short SecondACK ; second ACK received
        mov     ah, ch          ; LED update command sent, ACK received, need to send second byte
        and     ah, ScrLockLED or NumLockLED or CapsLockLED
        mov     bl, 0
        call    sendps2byte
        jmp     short ToggleACK
SecondACK:        
        xor     ch, LEDUpdate   ; second ACK, clear LED update bit
ToggleACK:
        xor     ch, AckReceived ; toggle ACK bit 
SetFlags1:                                  
        jmp     SetFlags               
        
; ------------ no ACK
noACK:
        cmp     al, 0e0h
        jne     short noE0
        or      cl, LastE0
        jmp     short SetFlags1
noE0:
        cmp     al, 0e1h
        jne     short noE1
        or      cl, LastE1
        jmp     short SetFlags1
noE1:   
        cmp     al, 0f0h
        jne     short noF0
        or      cl, LastF0
        jmp     short SetFlags1
noF0:   
        cmp     al, 71h     ; is DEL?
        jne     short noDEL
        mov     ah, dl
        and     ah, CtrlDown or AltDown
        cmp     ah, CtrlDown or AltDown
        je      short noF01
NormalKey1:        
        jmp     NormalKey
noF01:        
        mov     word ptr ds:[72h], 1234h    ; warm boot flag
        db      0eah
        dw      0, 0ffffh       ; reboot
noDEL:
        cmp     al, 83h         ; is F7
        je      short NormalKey1
        ja      short SetFlags1
        test    cl, LastF0      ; key up?
        jz      short noKeyUp
        or      al, 80h         ; key up flag
noKeyUp:
        test    cl, LastE0
        jnz     short noRSUp    ; ignore fake shifts      
        cmp     al, 12h         ; left shift
        jne     short noLSDown
        or      dl, LShfDown
        jmp     short SetFlagsKey2
noLSDown:
        cmp     al, 12h or 80h
        jne     short noLSUp
        and     dl, not LShfDown
        jmp     short SetFlagsKey2
noLSUp:
        cmp     al, 59h         ; right shift
        jne     short noRSDown
        or      dl, RShfDown
        jmp     short SetFlagsKey2
noRSDown:
        cmp     al, 59h or 80h
        jne     short noRSUP
        and     dl, not RShfDown
        jmp     short SetFlagsKey2
noRSUp:
        cmp     al, 11h         ; ALT
        jne     short noALTDown
        test    cl, LastE0
        jz      short LALTDn
        or      cl, RAltDown
        or      dl, AltDown
        jmp     short SetFlagsKey2
LALTDn:
        or      dx, (LAltDown shl 8) or AltDown
        jmp     short SetFlagsKey2
noALTDown:
        cmp     al, 11h or 80h
        jne     short noALTUp
        test    cl, LastE0
        jz      short LALTUp
        and     cl, not RAltDown
        and     dl, not AltDown
        jmp     short ALTup
LALTUp:
        and     dx, not ((LAltDown shl 8) or AltDown)
ALTUp:
        xor     ax, ax
        xchg    al, AltKpd
        test    al, al
        jz      short SetFlagsKey2     
        jmp     pushKey
noALTUp:
        cmp     al, 14h         ; CTL
        jne     short noCTLDown
        test    cl, lastE0
        jz      short LCTLDn
        or      cl, RCtrDown
        or      dl, CtrlDown
SetFlagsKey2:        
        jmp     short SetFlagsKey1
LCTLDn:
        or      dx, (LCtrDown shl 8) or CtrlDown
        jmp     short SetFlagsKey1
noCTLDown:
        cmp     al, 14h or 80h
        jne     short noCTLUp
        test    cl, LastE0
        jz      short LCTLUp
        and     cl, not RCtrDown
        and     dl, not CtrlDown
        jmp     short SetFlagsKey1
LCTLUp:
        and     dx,  not ((LCtrDown shl 8) or CtrlDown)
        jmp     short SetFlagsKey1
noCTLUp:
        mov     bx, 5800h + CapsLock
        call    KeyLock
        jnc     short SetFlagsKey1
        
        mov     bx, 7e00h + ScrLock
        push    dx          ; save ScrLock state bit (dl)
        call    KeyLock
        pop     bx          ; restore ScrLock state bit (bl)
        jc      short noScrLock
        test    dl, CtrlDown
        jz      short SetFlagsKey1; no break, just ScollLock
        mov     dl, bl      ; restore ScrLock flag
        test    bh, ScrLockDown
        jnz     short SetFlagsKey1 
        mov     byte ptr CtrlBreak, 80h   ; CTRL+BREAK flag
        mov     ax, Buffer
        mov     HeadPtr, ax
        mov     TailPtr, ax
        int     1bh
        xor     ax, ax
        jmp     pushkey
noScrLock:        
        test    cl, LastE0  ; INS
        jnz     short testINS
        test    dl, RShfDown or LShfDown
        jnz     short testINS
        test    dl, NumLock
        jnz     short NoIns      
testINS:
        mov     bx, 7000h + Insert
        call    KeyLock  
noIns:
        mov     bx, 7700h + NumLock
        push    dx          ; save NumLock state bit (dl)
        call    KeyLock
        pop     bx          ; restore NumLock state bit (bl)
        jc      short noPause
        test    dl, CtrlDown
        jz      short SetFlagsKey1
        mov     dl, bl      ; restore NumLock flag
        or      dh, Pause   ; set Pause bit
SetFlagsKey1:
        jmp     SetFlagsKey
E0Key:
        mov     di, offset E0KeyList
        push    cx
        mov     cx, E0KeyIndex - E0KeyList
        cld
        push    cs
        pop     es
        repne   scasb
        pop     cx
        jne     short SetFlagsKey
        mov     al, es:[di + E0KeyIndex - E0KeyList - 1]
        jmp     short KeyDown
noPause:
        and     al, 07fh    ; delete up bit
NormalKey:
        test    cl, LastF0
        jnz     short SetFlagsKey ; key up
        test    cl, LastE0
        jnz     short E0Key
        mov     bx, offset KeyIndex
        xlat    cs:[bx]
KeyDown:
        xor     bx, bx 
        test    dl, RShfDown or LShfDown
        jz      short noShift
        mov     bl, 2
noShift:
        cmp     al, 26
        ja      short noCaps
        test    dl, CapsLock
        jz      short noNum
        xor     bl, 2
        jmp     short noNum 
noCaps:
        cmp     al, 37
        ja      short noNum
        test    dl, NumLock
        jnz     short NumDown
        mov     bl, 2
NumDown:
        xor     bl, 2
noNum:        
        test    dl, CtrlDown
        jz      short noCtrl
        mov     bl, 4
noCtrl:
        test    dl, AltDown
        jz      short noAlt
        mov     bl, 6
noAlt:
        cbw
        shl     ax, 3
        add     bx, ax
        mov     ax, cs:KeyCode[bx]
        cmp     ax, 000ah
        ja      short pushKey
        dec     ax
        js      short SetFlagsKey     ; ax was 0
        mov     ah, AltKpd
        aad
        mov     AltKpd, al
        jmp     short SetFlagsKey
pushKey:                
        push    cx
        mov     cx, ax
        mov     al, ah      ; scan code
        mov     ah,4fh
        stc
        int     15h
        jnc     nopush
        mov     ah, 5
        int     16h
nopush:        
        pop     cx
        and     dh, not Pause    ; clear Pause bit
SetFlagsKey:
        and     cl, not (LastE0 or LastE1 or LastF0)    ; not prefix key code, clear all prefixes
SetFlags:
        mov     al, dl
        shr     al, 4
        xor     al, ch
        and     al, 7
        jz      short SF1   ; no LEDs to update
        test    ch, SetRepeat or AckReceived or LEDUpdate
        jnz     short SF1   ; can not update LEDS, so just write the flags and exit
        or      al, LEDUpdate
        xor     ch, al      ; insert the LEDs in KbdFlags4
        mov     ah, 0edh    ; set LED
        mov     bl, 0
        call    sendps2byte
SF1:        
        mov     KbdFlags1, dx
        mov     KbdFlags3, cx
        
int09Exit:
        pop     es
        pop     ds
        popa
        iret
int09 endp

ENDIF

KeyLock proc near   ; input: BH = expected scan code, al = scan code, BL = key lock flag. Returns CF=1 to continue, CF=0 to exit
        xor     bh, al
        jnz     short s2
        mov     ah, dh
        or      dh, bl      ; set flag
        xor     ah, dh      ; get flag difference
        xor     dl, ah      ; toggle only if key was not already down
        ret
s2:     cmp     bh, 80h
        stc
        jne     short exit
        xor     dh, bl      ; key up
exit:
        ret
KeyLock endp


; --------------------- INT 10h - Video ----------------
ActiveVideoMode     equ <ds:[49h]>  ; 1  byte
ScreenWidth         equ <ds:[4ah]>  ; 2  Screen width in text columns
RegenLength         equ <ds:[4ch]>  ; 2  Length (in bytes) of video area (regen size)
PageOffset          equ <ds:[4eh]>  ; 2  Offset from video segment of active video memory page
CursorPos           equ <ds:[50h]>  ; 16 Cursor location (8 byte-pairs; low byte=col, hi byte=row)
CursorShape         equ <ds:[60h]>  ; 2  Cursor size/shape.  Low byte=end scan line; hi byte=start line.
ActivePage          equ <ds:[62h]>  ; 1  Current active video page number
PortAddress         equ <ds:[63h]>  ; 2  Port address for 6845 video controller chip; see CGA I/O Ports
CrtMode             equ <ds:[65h]>  ; 1  Current value of 6845 video ctrlr CRT_MODE (port 3x8H register)
CrtPalette          equ <ds:[66h]>  ; 1  Current value of 6845 video ctrlr CRT_PALETTE (port 3x9H reg)
ScreenRows          equ <ds:[84h]>  ; 1  EGA text rows-1  (maximum valid row value)
ScanLinesChar       equ <ds:[85h]>  ; 2  EGA bytes per character (scan-lines/char used in active mode)
EgaMiscInfo         equ <ds:[87h]>  ; 1  EGA flags; see EgaMiscInfoRec
EgaMiscInfo2        equ <ds:[88h]>  ; 1  EGA flags; see EgaMiscInfo2Rec
VgaFlags            equ <ds:[89h]>  ; 1  VGA flags; see VgaFlagsRec
VgaFlags2           equ <ds:[8ah]>  ; 1  VGA flags2
PalPaging           equ <ds:[69h]>  ; 1  Palette paging status: bit7=0 for 4x64, 1 for 16x16. bit3:0=active page
PalPagingCounter    equ <ds:[6ah]>  ; 1  Palette paging counter


int10 proc near     
        sti                     ; no interrupt reentrant
        cld
        push    ds
        push    si
        push    40h
        pop     ds
        cmp     ah, 4fh
        je      short svga
        cmp     ah, 1ch
        ja      short exit
        mov     si, ax
        shr     si, 7
        and     si, 1feh
        call    cs:vidtbl[si]
exit:        
        pop     si
        pop     ds
        iret
svga:
        cmp     al, 5
        je      short VESAMemControl
        cmp     al, 1
        jb      short VESAGetInfo
        je      short VESAGetModeInfo
        cmp     al, 3
        jb      short VESASetMode
        je      short VESAGetMode
        mov     ax, 100h
        jmp     short exit

; ---------------- VESA fn00
VESAGetInfo:
        push    cx
        push    di
        mov     si, offset VESAInfo
        mov     cx, 10
        rep     movsw es:[di], cs:[si]
        mov     cl, 118     ; 236 bytes 0
VESASupportedClear:        
        xor     ax, ax
        rep     stosw
        pop     di
        pop     cx     
VESASupported:
        mov     ah, 0       ; success    
VESASupportedErr:
        mov     al, 4fh
        jmp     short exit

; ---------------- VESA fn01
VESAGetModeInfo:
        cmp     cx, 101h
VESAGetModeInfo1:        
        mov     ah, 1       ; error
        jne     short VESASupportedErr
        push    cx
        push    di
        mov     cx, 9
        mov     si, offset VESAModeInfo
        rep     movsw es:[di], cs:[si]
        mov     cl, 119       
        jmp     short VESASupportedClear

; ---------------- VESA fn02
VESASetMode:
        imul    ax, bx, 2
        cmp     ax, 101h*2
        jne     short VESASetMode1      
        lea     ax, [bx+23ffh]
        xchg    ah, al
        int     10h
        jmp     short VESASupported   
VESASetMode1:
        mov     al, bl
        mov     ah, 0
        int     10h
        jmp     short VESASupported

; ---------------- VESA fn03
VESAGetMode:
        mov     bh, EgaMiscInfo
        and     bh, 80h
        mov     bl, ActiveVideoMode
        cmp     bl, 25h
        je      short VESAGetMode1
        or      bl, bh
        mov     bh, 0
        jmp     short VESASupported
VESAGetMode1:
        add     bx, 257-25        
        jmp     short VESASupported

; ---------------- VESA fn05
VESAMemControl:
;        test    bx, not 101h                ; BX validation
;        jnz     short VESAGetModeInfo1      ; error
        push    cs
        push    offset VESASupported
;        call    VESAMemControlCB
;        jmp     short VESASupported
VESAMemControlCB:
        pushf
        cli
        push    ax
        push    dx
        mov     ax, bx
        and     ax, 1
        add     al, 8ah
        xchg    ax, dx
        and     ax, 7
        add     al, 0ah
        test    bh, bh
        jnz     getpageinfo
        call    flush
        out     dx, ax          
        pop     dx
        pop     ax
        popf
        retf
getpageinfo:
        in      ax, dx
        sub     al, 0ah
        and     ax, 7
        xchg    ax, dx
        pop     ax
        pop     ax                
        popf
        retf
   
VESAInfo    db  'VESA'
            dw  100h, VESAOEM, 0f000h, 2, 0, VESAModes, 0f000h, 8
VESAOEM     db  'Nicolae Dumitrache', 0
VESAModes   dw  101h, 0ffffh
VESAModeInfo:
;Bit(s)  Description - mode attributes 
;0      mode supported by present hardware configuration
;1      optional information available (must be =1 for VBE v1.2+)
;2      BIOS output supported
;3      set if color, clear if monochrome
;4      set if graphics mode, clear if text mode
;---VBE v2.0+ ---
;5      mode is not VGA-compatible
;6      bank-switched mode not supported
;7      linear framebuffer mode supported
;8      double-scan mode available (e.g. 320x200 and 320x240)
;---VBE v3.0 ---
;9      interlaced mode available
;10     hardware supports triple buffering
;11     hardware supports stereoscopic display
;12     dual display start address support
;13-15  reserved
        dw  0000000010011001b       
;Bit(s)  Description - window attributes
;0      exists
;1      readable
;2      writable
;3-7    reserved
        db  00000111b, 00000111b
        dw  64, 64, 0a000h, 0b000h, VESAMemControlCB, 0f000h, 640


; --------------- fn 00h, set video mode
setmode:
        pusha
        push    es
        add     al, al      ; CF = cls bit
        rcl     byte ptr EgaMiscInfo, 1
        ror     byte ptr EgaMiscInfo, 1
        cmp     al, 3*2
        ja      short setmode1
        mov     al, 0b6h        ; reset sound generator
        out     43h, al
        mov     al, 0
        out     42h, al
        out     42h, al
        mov     ax, 0806h   ; text mode (80x25, 16 colors), flash enabled
        mov     word ptr ScreenWidth, 80
        mov     word ptr RegenLength, 1000h
        mov     byte ptr ScreenRows, 25-1
        mov     word ptr ScanLinesChar, 16
        mov     bx, 0b800h  ; segment
        mov     cx, 4000h   ; video len/2
        mov     si, 0720h   ; clear value
        jmp     short setmode2
setmode1:    
        cmp     al, 13h*2
        jne     short setmode3    
        mov     ah, 41h     ; graphic mode, 320x200, 256 colors
        mov     word ptr ScreenWidth, 40
        mov     word ptr RegenLength, 2000h
        jmp     short setmode21
setmode3:
        cmp     al, 25h*2
        jne     short setmodeexit
        mov     ah, 1       ; graphic mode, 640x400, 256 colors
        mov     word ptr ScreenWidth, 80
        mov     word ptr RegenLength, 2000h
setmode21:
        mov     bx, 0a000h  ; segment
        mov     cx, 8000h   ; video len/2 - clears only the first segment (TODO clear full screen)
        xor     si, si      ; clear value
setmode2:
        shr     al, 1
        mov     ActiveVideoMode, al
        push    ax
        push    cx
        push    ds
        pop     es
        xor     ax, ax
        mov     di, offset CursorPos
        mov     cx, 8
        rep     stosw           ; reset cursor position for all pages
        mov     ax, 0500h
        int     10h             ; set page0
        pop     cx
        pop     ax
        test    byte ptr EgaMiscInfo, 80h
        jnz     short setmode4    ; no clear video memory
        mov     es, bx
        xchg    ax, si
        xor     di, di
        rep     stosw        
        xchg    ax, si
        call    palpageset     
        mov     byte ptr PalPaging, cl  ; reset paging        
setmode4:
        mov     dx, 3c0h
        mov     al, 10h
        out     dx, al
        mov     al, ah      
        out     dx, al          ; set video mode
        mov     ax, 1123h
        int     10h             ; set ROM 8x8 font for graphics mode
        mov     ah, 1
        xor     cx, cx
        int     10h             ; show cursor
        test    byte ptr VgaFlags, 8     ; test default palette loading
        jnz     short setmodeexit     ; no default palette
        mov     ax, 1012h
        xor     bx, bx
        mov     cx, 100h    
        mov     dx, offset default_pal
        push    cs
        pop     es
        int     10h             ; set default palette
setmodeexit:
        pop     es
        popa
nullproc:
        ret        

; --------------- fn 01h, set cursor shape and visibility (shape is ignored, always lines 14&15 of text mode char)
cursor:     ; CH bit 6 or 5 -> cursor off
        push    ax
        push    dx
        mov     dx, 3d4h
        mov     al, 0ah
        out     dx, al
        mov     al, ch
        shr     al, 1
        or      al, ch
        inc     dx
        out     dx, al
        pop     dx
        pop     ax
        ret

;---------------- fn 02h, set cursor pos
curpos:
        push    ax
        push    bx
        mov     al, bh
        shr     bx, 7
        and     bx, 0eh
        mov     CursorPos[bx], dx
        cmp     byte ptr ActiveVideoMode, 3
        jne     short curpos1
        cmp     al, ActivePage
        jne     short curpos1
        push    dx
        xor     ax, ax
        xchg    al, dh        
        imul    ax, 80
        add     ax, dx
        mov     dx, 3d4h
        push    ax
        mov     al, 0fh
        out     dx, al
        inc     dx
        pop     ax
        out     dx, al
        dec     dx
        mov     al, 0eh
        out     dx, al
        inc     dx
        mov     al, ah
        out     dx, al
        pop     dx
curpos1:        
        pop     bx
        pop     ax
        ret

;---------------- fn 03h, get cursor pos
getcurpos:
        push    bx
        shr     bx, 7
        and     bx, 0eh
        mov     dx, CursorPos[bx]
        mov     cx, CursorShape
        pop     bx
        ret

;---------------- fn 04h, light pen
lightpen:
        mov     ah, 0   ; not triggered
        ret

;---------------- fn 05h, set active video page
apage:
        pusha
        call    flush
        and     al, 7
        mov     bh, al
        mov     ActivePage, al
        mov     al, ActiveVideoMode
        cmp     al, 3
        jne     short apage1
        mov     ax, 0ah
        out     8ah, ax
        inc     ax
        out     8bh, ax
        mov     ah, 3
        int     10h        ; get cursor pos
        mov     ah, 2
        int     10h        ; set cursor pos
        mov     ax, 200h   ; page size / 8
        jmp     short apage2
apage1:                    ; mode 13h and 25h
        mov     ax, 0ah
        add     al, bh
        out     8ah, ax
        inc     ax
        cmp     al, 12h
        jne     short apage4
        mov     al, 0ah
apage4: out     8bh, ax
        mov     ax, 2000h  ; page size / 8
apage2:
        shr     bx, 8      ; page number
        mul     bx
        push    ax
        shl     ax, 3
        mov     PageOffset, ax
        mov     dx, 3d4h
        mov     al, 0dh
        out     dx, al
        inc     dx
        pop     ax
        out     dx, al
        dec     dx
        mov     al, 0ch
        out     dx, al
        inc     dx
        mov     al, ah
        out     dx, al
        popa
        ret

;---------------- fn 06h, scroll up / clr
scrollup:
        pusha
        push    es
        xchg    cx, dx
        sub     cx, dx
        inc     cx
        cmp     byte ptr ActiveVideoMode, 13h
        jae     short scrollup1       
        call    scr_params
scrollup6:        
        push    0b800h          ; segment
        pop     es
        add     dl, dl
        add     di, di
        add     di, PageOffset  ; di = top left corner address
        xchg    ax, cx          ; ah = 0
        test    bl, bl
        jz      short scrollup3       ; clear
        sub     ah, bl
        jb      short scrollup3       ; clear
        add     si, di
scrollup4:        
        mov     cl, al
        rep     movsw es:[si], es:[di]
        add     si, dx
        add     di, dx
        dec     ah              
        jns     short scrollup4       ; ch = lines - 1
scrollup3:                      
        add     ah, bl          ; clear rectangle: DI=address, ah=lines, al=columns, bh=attribute
        xchg    ax, bx
        mov     al, ' '
scrollup5:
        mov     cl, bl
        rep     stosw
        add     di, dx
        dec     bh
        jns     short scrollup5       ; ch = lines - 1
scrollexit:
        pop     es
        popa
        ret
scrollup1:
        ja     short scrollup2
; TODO mode13h scroll up
        jmp     short scrollexit
scrollup2:
; TODO mode25h scroll up
        jmp     short scrollexit

;---------------- fn 07h, scroll dn / clr
scrolldn:
        std
        pusha
        push    es
        neg     cx
        add     cx, dx
        inc     cx
        cmp     byte ptr ActiveVideoMode, 13h
        jae     short scrolldn1
        call    scr_params
        neg     dx
        neg     si
        jmp     short scrollup6

scrolldn1:
        ja     short scrolldn2
; TODO  mode13h scroll down
        jmp     short scrollexit
scrolldn2:
; TODO  mode25h scroll down    
        jmp     short scrollexit

scr_params:
        mov     bl, al          ; lines
        xor     ax, ax
        xchg    al, dh
        imul    di, ax, 80
        add     di, dx
        mov     dl, 80          ; dh = 0
        sub     dl, cl
        mov     al, bl
        imul    si, ax, 160
        ret
;---------------- fn 08h, read char/attr
readchar:
        push    bx
        mov     al, ActiveVideoMode
        cmp     al, 3
        xor     ax, ax
        jne     short readchar1
        call    mode3chaddr
        mov     ax, [bx]
readcharexit:
        pop     bx
        ret
readchar1:
        cmp     al, 13h
        jne     short readchar2
; TODO mode13h
        jmp     short readcharexit
readchar2:
; TODO mode25h
        jmp     short readcharexit

mode3chaddr:    ; returns current char address in mode3 in ds:bx. Input: bh=page, ds=40h 
        push    ax
        and     bx, 700h
        lea     ax, [bx+0b800h]
        shr     bx, 7
        mov     bx, CursorPos[bx]
        mov     ds, ax
        xor     ax, ax
        xchg    al, bh
        imul    ax, 80
        add     bx, ax
        add     bx, bx
        pop     ax
        ret

;---------------- fn 09h, write char/attr
writecharattr:
        push    ax
        push    es
        push    bx
        push    cx
        cmp     byte ptr ActiveVideoMode, 3
        jne     short writecharattr1
        mov     ah, bl
        call    mode3chaddr
        push    ds
        pop     es
        xchg    di, bx
        rep     stosw
        xchg    di, bx
writecharattrexit:        
        pop     cx
        pop     bx
        pop     es
        pop     ax
        ret
writecharattr1:
        cmp     byte ptr ActiveVideoMode, 13h
        jne     short writecharattr2
; TODO mode13h
        jmp     short writecharattrexit
writecharattr2:
; TODO mode25h
        jmp     short writecharattrexit

;---------------- fn 0ah, write char
writechar:
        jcxz    short writecharskip
        push    bx
        push    cx
        cmp     byte ptr ActiveVideoMode, 3
        jne     short writechar1
        call    mode3chaddr
writechar3:        
        mov     [bx], al
        add     bx, 2
        loop    short writechar3
writecharexit:
        pop     cx
        pop     bx
writecharskip:        
        ret
writechar1:
        cmp     byte ptr ActiveVideoMode, 13h
        jne     short writechar2
; TODO mode13h
        jmp     short writecharexit
writechar2:        
; TODO mode25h
        jmp     short writecharexit

;---------------- fn 0eh, write char as TTY
writecharTTY:
        push    ax
        push    bx
        push    dx
        mov     bl, ActivePage
        mov     bh, 0
        add     bx, bx
        mov     dx, CursorPos[bx]
        shl     bx, 7
        mov     ah, 0ah
        call    tty
        mov     ah, 2       ; set cursor pos
        int     10h
        pop     dx
        pop     bx
        pop     ax 
        ret        

tty:    ; dx=xy, bh=page, al=char, bl=attr, ah=0ah(no attr) or 09h(with attr)
        test    word ptr KbdFlags2, Pause
        jnz     short tty
        push    cx
        cmp     al, 7
        je      short bell
        cmp     al, 8
        je      short bs
        cmp     al, 0ah
        je      short cr
        cmp     al, 0dh
        je      short lf
        mov     cx, 1
        int     10h         ; write char at cursor
        inc     dx
        cmp     dl, ScreenWidth
        jae     short crlf
tty1:
        pop     cx
        ret
bell:
; TODO bell code        
        jmp     short tty1
bs:
        sub     dl, 1
        adc     dl, 0      
        jmp     short tty1
lf:
        mov     dl, 0
        jmp     short tty1
crlf:
        mov     dl, 0        
cr:        
        inc     dh
        cmp     dh, ScreenRows
        jbe     short tty1
        dec     dh
;        mov     ah, 8
;        int     10h         ; read attribute at cursor pos
        push    bx          ; save active page in bh
        push    dx
;        xchg    ax, bx
        mov     bh, 7       ; default attribute
        mov     ax, 601h    
        mov     dh, ScreenRows
        mov     dl, ScreenWidth
        dec     dx
        xor     cx, cx
        int     10h         ; scroll up
        pop     dx
        pop     bx          ; restore active page in bh         
        jmp     short tty1
        
;---------------- fn 0fh, read video mode
readmode:
        mov     al, EgaMiscInfo
        and     al, 80h
        or      al, ActiveVideoMode
        mov     ah, ScreenWidth
        mov     bh, ActivePage
        ret


;---------------- fn 10h, palette
paltable    dw  setonereg, palexit, setallreg, setblink, palexit, palexit, palexit, readonereg, readoverscan, readallreg, palexit, palexit, palexit, palexit, palexit, palexit
            dw  setoneDAC, palexit, setblockDAC, paging, palexit, readoneDAC, palexit, readblockDAC, setPELmask, getPELmask, getpaging, grayscale

pal:
        cmp     al, 1bh
        ja      short palexit
        mov     si, ax
        add     si, si
        add     byte ptr PalPagingCounter, ah   ; prevents <palpage> re-entrance on recursive <pal> calls
        call    palpage     
        call    cs:paltable[si-2000h]
        call    palpage
        sub     byte ptr PalPagingCounter, ah
palexit:
        ret

palpage:                    ; executes only if PalPagingCounter == ah
        cmp     byte ptr PalPagingCounter, ah   
        jne     short palpageexit
palpageset:        
        test    byte ptr PalPaging, 0fh
        jz      short palpageexit
        pusha
        mov     bl, byte ptr PalPaging
        add     bl, bl
        jc      short page16
        shl     bl, 2
page16:
        shl     bx, 11  ; bh=target page, bl=0 page
palpage1:
        mov     al, 15h
        int     10h     ; read 0 page DAC reg
        push    cx
        push    dx
        xchg    bl, bh
        int     10h     ; read target page DAC register
        xchg    bl, bh
        mov     al, 10h
        int     10h     ; write 0 page DAC register
        pop     dx
        pop     cx
        xchg    bl, bh
        int     10h     ; write target page DAC register
        xchg    bl, bh
        add     bx, 101h; next DAC reg
        test    bl, 0fh
        jnz     short palpage1                    
        popa
palpageexit:        
        ret

setonereg:
        cmp     bl, 10h
        jae     setonereg1
        pusha
        call    colfrombits
        mov     cl, al
        call    colfrombits
        mov     ch, al
        call    colfrombits
        mov     dh, al
        mov     al, 10h
        int     10h
        popa
setonereg1:        
        ret        

setallreg:
        pusha
        mov     al, 0
        mov     si, dx
        mov     bl, 15
setallreg1:        
        mov     bh, es:[si+15]
        int     10h
        dec     si
        dec     bl
        jns     short setallreg1
        popa
        ret

setblink:
        pusha
        cmp     byte ptr ActiveVideoMode, 3
        jne     short setblink1
        mov     dx, 3c0h
        mov     al, 10h
        out     dx, al
        mov     al, bl
        and     al, 1
        shl     al, 3      
        out     dx, al          ; set video mode (0 or 8)
        shl     al, 2
        xor     al, VgaFlags
        and     al, 20h
        xor     VgaFlags, al
setblink1:
        popa
        ret

readonereg:
        cmp     bl, 10h
        jae     readonereg1
        push    ax
        push    cx
        push    dx
        mov     al, 15h
        int     10h
        mov     al, dh          ; al = R
        and     al, 00110000b
        shr     al, 2
        add     al, 01111000b
        and     al, 10000100b
        mov     bh, al
        xchg    ax, cx          ; ax = GB
        and     ax, 0011000000110000b
        shr     ax, 3
        shr     al, 1
        add     ax, 0011110000011110b
        and     ax, 0100001000100001b
        or      bh, ah
        or      bh, al
        rol     bh, 3
        pop     dx
        pop     cx
        pop     ax
readonereg1:        
        ret

readallreg:
        pusha
        mov     di, dx
        mov     bl, 0
readllreg1:
        mov     al, 7
        int     10h
        mov     al, bh
        stosb
        inc     bx
        cmp     bl, 16
        jne     short readllreg1
        mov     al, 0   ; overscan color
        stosb
        popa
        ret

readoverscan:
        mov     bh, 0
        ret

setoneDAC:
        push    ax
        push    dx
        xchg    ax, dx
        mov     al, bl
        mov     dx, 3c8h
        out     dx, al
        inc     dx
        mov     al, ah
        out     dx, al
        mov     al, ch
        out     dx, al
        mov     al, cl
        out     dx, al
        pop     dx
        pop     ax
        ret

setblockDAC:
        pusha
        mov     si, dx
        mov     dx, 3c8h
        xchg    ax, bx
        out     dx, al
        inc     dx
        imul    cx, 3
        rep     outsb dx, es:[si]
        popa
        ret

paging:
        push    bx
        test    bl, bl
        mov     bl, PalPaging
        jnz     short paging1
        add     bl, bl
        ror     bx, 1
        jmp     short paging2
paging1:
        and     bx, 0f80h       ; bl=old page, bh=new page
        or      bl, bh 
paging2:        
        mov     PalPaging, bl
        pop     bx
        ret

readoneDAC:
        push    ax
        push    dx
        mov     al, bl
        mov     dx, 3c7h
        out     dx, al
        inc     dx
        inc     dx
        in      al, dx
        mov     ah, al
        in      al, dx
        mov     ch, al
        in      al, dx
        mov     cl, al
        pop     dx
        mov     dh, ah
        pop     ax             
        ret

readblockDAC:
        pusha
        mov     di, dx
        mov     dx, 3c7h
        xchg    ax, bx
        out     dx, al
        inc     dx
        inc     dx
        imul    cx, 3
        rep     insb                
        popa
        ret

setPELmask:
        push    dx
        xchg    ax, bx
        mov     dx, 3c6h
        out     dx, al
        xchg    ax, bx
        pop     dx
        ret

getPELmask:
        push    dx
        xchg    ax, bx
        mov     dx, 3c6h
        in      al, dx
        xchg    ax, bx
        pop     dx
        ret

getpaging:
        mov     bh, PalPaging
        mov     bl, 0
        rol     bx, 1
        shr     bh, 1        
        ret

grayscale:
        jcxz    short grayscale2
        pusha
        mov     bh, cl
grayscale1:        
        mov     al, 15h
        int     10h
        shr     dx, 8
        imul    si, dx, 77
        mov     dl, ch
        imul    dx, 151
        mov     ch, 0
        imul    cx, 28
        add     dx, si
        add     dx, cx
        mov     ch, dh
        mov     cl, dh
        mov     al, 10h
        int     10h
        inc     bl
        dec     bh
        jne     short grayscale1        
        popa
grayscale2:        
        ret

colfrombits:    ; input: bh, output: al
        shr     bh, 1
        sbb     al, al
        and     al, 2ah
        test    bh, 4
        jz      short col1
        or      al, 15h
col1:
        ret                


;---------------- fn 11h, character generator
loadUDF:
        cmp     bx, 1000h
        jne     loadUDFexit     ; only 16bytes chars and font block 0 supported
        pusha
        xchg    ax, dx
        mov     dx, 03cbh
        out     dx, ax
        mov     si, bp
        shl     cx, 4
        rep     outsb dx, es:[si]        
        popa
loadUDFexit:        
        ret

chargen:
        test    al, not 10h     ; test for 00h and 10h
        jz      short loadUDF
        test    al, not 11h     ; test for 01h and 11h
        jz      short loadROMfont
        test    al, not 12h     ; test for 02h and 12h
        jz      short loadROMfont
        test    al, not 14h     ; test for 04h and 14h
        jz      short loadROMfont
        cmp     al, 20h
        jb      loadUDFexit
        je      short set1f
        cmp     al, 21h
        je      short setgrUDF
        cmp     al, 24h
        jbe     short setROMgrFont
        cmp     al, 30h
        je      short getfontinfo
        ret

loadROMFont:
        push    es
        pusha
        mov     bx, 1000h       ; 8x16 chars, block 0
        mov     cx, 100h        ; all chars
        xor     dx, dx
        mov     bp, offset font8x16
        push    cs
        pop     es
        mov     al, 0           
;        int     10h             ; loadUDF
        popa
        pop     es
        ret

set1f:
        xor     si, si
        mov     ds, si
        mov     [si+1fh*4], bp
        mov     [si+1fh*4+2], es
        ret
        
setgrUDF:
        pusha
        jcxz    short loadUDFexit
        push    ds
        xor     si, si
        mov     ds, si
        mov     [si+43h*4], bp
        mov     [si+43h*4+2], es
        pop     ds
        mov     ax, 200
        cmp     byte ptr ActiveVideoMode, 13h
        jb      short setgrUDFexit
        je      short setgrUDF1
        mov     ax, 480         ; mode 25h, 480 lines
setgrUDF1:
        mov     ScanLinesChar, cx
        cwd
        div     cx
        dec     ax
        mov     ScreenRows, al
setgrUDFexit:
        popa
        ret

setROMgrFont:       
        pusha
        push    es
        mov     cx, 8
        push    cs
        pop     es
        mov     bp, offset font8x8
        cmp     al, 23h
        je      short setROMgrFont1
        mov     bp, offset font8x16
setROMgrFont1:        
        mov     al, 21h
        int     10h     ; set graphic UDF
        dec     ax
        mov     bp, offset font8x8 + 128*8
        int     10h     ; set INT 1fh
        pop     es
        popa
        ret
        
getfontinfo:
        mov     cx, ScanLinesChar
        mov     dl, ScreenRows
        cmp     bh, 1
        ja      short getfontinfo1
        push    0
        pop     ds
        les     bp, ds:[1fh*4] 
        jb      short getfontinfoexit
        les     bp, ds:[43h*4]
        ret
getfontinfo1:
        cmp     bh, 7
        ja      short getfontinfoexit
        mov     si, bx
        shr     si, 8
        add     si, si
        mov     bp, cs:fontinfo[si-4]
        push    cs
        pop     es                    
getfontinfoexit:
        ret

fontinfo    dw  font8x16, font8x8, font8x8+128*8, font8x16, font8x16, font8x16

;---------------- fn 12h, special functions
special:
        cmp     bl, 10h
        jne     short special1
        mov     cl, EgaMiscInfo2    ; cl = switch settings
        and     cx, 15              ; ch <- 0 (feature bits)
        mov     bx, 3               ; bh <- 0 (color mode), bl = video memory size
        ret
special1:
        cmp     bl, 31h
        jne     short special2
        neg     al
        xor     al, VgaFlags
        and     al, 8       ; transfer palette loading bit to VgaFlags
        xor     VgaFlags, al
        mov     al, 12h     ; supported function
        ret
special2:
        mov     al, 0       ; unsupported function
        ret


;---------------- fn 13h, write string
writestr:
        jcxz    short wstrexit
        pusha
        mov     si, bx
        shr     si, 8
        add     si, si
        push    CursorPos[si]
        mov     ah, 9       ; write tty char/attribute
wstr1:        
        push    ax
        test    al, 2
        mov     al, es:[bp]
        jz      short noattr
        inc     bp
        mov     bl, es:[bp]
noattr:
        inc     bp
        mov     CursorPos[si], dx
        call    tty
        pop     ax
        loop    short wstr1
        pop     CursorPos[si]
        test    al, 1
        jz      short wstr2             
        mov     ah, 2       ; set cursor pos
        int     10h                
wstr2:        
        popa
wstrexit:        
        ret

;---------------- fn 1ah, get/set display combination code
getdcc:
        cmp     al, 1
        ja      short getdccexit
        mov     al, ah
        je      short setdcc
        mov     bx, 08h
dccval  label word        
setdcc:
        mov     cs:[dccval-2], bx
getdccexit:        
        ret        

;---------------- fn 1bh, query status
querystatus:
        pusha
        mov     ax, offset staticfunctable
        stosw
        mov     ax, cs
        stosw
        mov     si, offset ActiveVideoMode
        cmp     byte ptr [si], 13h
        mov     cx, 33          ; info copied from BDA        
        rep     movsb
        mov     ax, 8
        stosw                   ; display info (one VGA analog color monitor)
        mov     bx, 208h        ; 400 scan lines, 8 pages
        mov     al, 10h         ; 16 colors         
        jb      short querystatus1     ; mode03h
        mov     bh, 0           ; scan lines code (0=200, 1=350, 2=400, 3=480), 8 pages
        mov     ax, 100h        ; 256 colors
        je      short querystatus1     ; mode13h
        mov     bx, 301h        ; 480 scan lines, 1 page
querystatus1:
        stosw
        xchg    ax, bx
        stosw
        xor     ax, ax
        stosw                   ; font block info (45)
        mov     al, VgaFlags
        and     al, 00101111b
        stosw        
        stosw
        mov     al, EgaMiscInfo
        shr     al, 4
        and     al, 7           ; video memory size
        stosw
        mov     al, 2
        stosb                   ; color display attached
        mov     cl, 6
        xor     ax, ax
        rep     stosw           ; 12 reserved bytes
        popa
        mov     al, ah          ; supported function
        ret

staticfunctable db  00001100b   ; video mode 2h, 3h supported
                db  00000000b
                db  00001000b   ; video mode 13h supported
                db  00000000b
                db  00100000b   ; video mode 25h supported
                db  0, 0
                db  00000100b   ; 400 scanline supported
                db  1           ; font blocks available in text mode
                db  1           ; max active font blocks available in text mode

;Bit(s)  Description
;0      all modes on all displays function supported
;1      gray summing function supported
;2      character font loading function supported
;3      default palette loading enable/disable supported
;4      cursor emulation function supported
;5      EGA palette present
;6      color palette present
;7      color-register paging function supported
;8      light pen supported (see AH=04h)
;9      save/restore state function 1Ch supported
;10     intensity/blinking function supported (see AX=1003h)
;11     Display Combination Code supported (see #00039)
;12-15  unused (0)
                db  11101111b   ; miscellaneous function support flags 
                db  00001100b   ; miscellaneous function support flags
                 
                db  0, 0        ; reserved
                db  0           ; save pointer function flags
                db  0           ; reserved  

       
vidtbl  dw  setmode, cursor, curpos, getcurpos, lightpen, apage, scrollup, scrolldn, readchar, writecharattr
        dw  writechar, nullproc, nullproc, nullproc, writecharTTY, readmode
        dw  pal, chargen, special, writestr, nullproc, nullproc, nullproc, nullproc, nullproc, nullproc, getdcc, querystatus, nullproc
int10 endp

; --------------------- INT 11h - Equipment ----------------
EquipmentWord       equ     <ds:[10h]>

int11   proc near
        push    ds
        push    40h
        pop     ds
        mov     ax, EquipmentWord
        pop     ds
        iret
int11   endp

; --------------------- INT 12h - Memory size ----------------
MemorySize       equ     <ds:[13h]>

int12   proc near
        push    ds
        push    40h
        pop     ds
        mov     ax, MemorySize
        pop     ds
        iret        
int12   endp

; --------------------- INT 13h - Disk services ----------------
HDLastError       equ     <ds:[74h]>
HDOpStarted       equ     <ds:[92h]>    ; bit 3: in INT13h (all other bits must be 0)
HDSize            equ     <ds:[94h]>

int13   proc near
        push    ds
        push    bp
        push    40h
        pop     ds
        xor     byte ptr HDOpStarted, 8
        jz      short inINT13
        sti                     
        cld
        cmp     ah, 1ah
        jbe     short Disk1
        sub     ah, 41h-1bh     ; extensions
        cmp     ah, 22h
        jbe     short Disk1
        mov     ah, 1           ; bad command error
        jmp     short exit
inINT13:        
        mov     ah, 0aah        ; drive not ready
        jmp     short exit2
Disk1:
        mov     bp, ax
        shr     bp, 7
        and     bp, 1feh
        push    ds
        call    cs:disktbl[bp]
        pop     ds
exit:        
        mov     HDLastError, ah
exit2:
        xor     byte ptr HDOpStarted, 8
        neg     ah              ; CF <- (AH != 0)
exit1:
        mov     bp, sp
        rcr     byte ptr [bp+8], 1
        rol     byte ptr [bp+8], 1  ; insert error CF on stack
        neg     ah
        pop     bp
        pop     ds
        iret

disktbl dw      DiskReset, DiskGetStatus, DiskRead, DiskWrite, DiskVerify, DiskFormat, DiskFormat, DiskFormat, DiskGetParams, DiskInit, DiskRead, DiskWrite, DiskSeek, DiskRst, DiskReadSectBuffer, DiskWriteSectBuffer
        dw      DiskReady, DiskRecalibrate, DiskDiag, DiskDiag, DiskDiag, DiskGetType, DiskChanged, DiskSetDASDType, DiskSetMediaType, DiskPark, DiskFormat,  DiskExtInstCheck, DiskExtRead, DiskExtWrite, DiskExtVerify, DiskExtLock
        dw      DiskExtEject, DiskExtSeek, DiskExtGetParams

DiskGetType:
        cmp     dl, 80h
        jne     short DiskReset ; ah=0, drive not present
        mov     cx, HDSize      
        mov     dx, cx
        test    cx, cx
        jz      short DiskReset ; ah=0, drive not present
        mov     ah, -3      ; HD present
        shr     cx, 6
        shl     dx, 10      ; CX:DX = HDSize * 1024
DiskGetTypeexit:        
        pop     ds          ; discard ret address
        pop     ds          ; discard DS
        xor     byte ptr HDOpStarted, 8     ; CF <- 0 
        jmp     short   exit1        

DiskExtInstCheck:
        xchg    bl, bh
        mov     ah, -1
        mov     cx, 1       ; extended disk access functions (AH=42h-44h,47h,48h) supported
        cmp     dl, 80h
        jne     short notready
        jmp     short DiskGetTypeexit

DiskReset:
DiskChanged:
DiskPark:
        mov     ah, 0       ; success
        ret

DiskGetStatus:
        mov     ah, HDLastError
        ret
      
DiskVerify:
        mov     bp, sdverify
        jmp     short   DiskRead1
DiskWrite:
        mov     bp, sdwrite
        jmp     short   DiskRead1
DiskRead:
        mov     bp, sdread
DiskRead1:        
        test    al, al
        jz      short DiskReset
        cmp     dl, 80h
        jne     short notready
        mov     ah, 4
        test    cl, 3fh
        jz      short DiskReadend   ; bad sector 0
        pusha
        mov     ah, 0
        push    ax
        call    HCStoLBA
        pop     cx
        push    cx        
        call    bp              ; DX:AX sector, ES:BX buffer, CX=sectors, returns AX=read sectors
        pop     cx
        sub     cx, ax
        neg     cx              ; CF=1 if cx != 0
        rcl     ah, 3           ; AH = 4*CF (sector not found / read error)
        mov     ds, ax
        popa
        mov     ax, ds
DiskReadend:
        ret

HCStoLBA:       ; CX = {cyl[7:0], cyl[9:8], sect[5:0]}, DH = head. Returns DX:AX LBA
        mov     al, ch
        mov     ah, cl
        shr     ah, 6
        shr     dx, 8
        imul    dx, 63
        and     cx, 3fh
        add     cx, dx
        dec     cx
        mov     dx, 255*63
        mul     dx
        add     ax, cx
        adc     dx, 0
        ret       
;    unsigned int s = cs & 0x3f;
;    unsigned int c = ((cs & 0xc0) << 2) | (cs >> 8);
;    return (c*255l + h)*63l + s - 1l;

DiskFormat:
DiskInit:
DiskSeek:
DiskRst:
DiskReady:
DiskRecalibrate:
DiskDiag:
DiskExtSeek:
        cmp     word ptr HDSize, 0
        je      short notready
        cmp     dl, 80h
        je      short DiskReset
notready:        
        mov     ah, 0aah        ; disk not ready
        ret

DiskGetParams:
        cmp     dl, 80h
        mov     ah, 7
        jne     short DiskReadend   ; ret
        mov     bl, 0   ; ???
        mov     ax, HDSize
        mov     dx, ax
        shl     ax, 10
        shr     dx, 6
        sub     ax, 30
        sbb     dx, 0
        mov     cx, 63*255
        div     cx
        dec     ax
        cmp     ax, 3feh
        jbe     dgpok
        mov     ax, 3feh
dgpok:        
        xchg    al, ah
        shl     al, 6
        or      al, 3fh
        mov     cx, ax
        mov     dx, 0fe01h
        xor     ax, ax
        ret        

DiskExtVerify:
        mov     bp, sdverify
        jmp     short DiskExtRead1
DiskExtWrite:
        mov     bp, sdwrite
        jmp     short DiskExtRead1
DiskExtRead:
        mov     bp, sdread
DiskExtRead1:
        cmp     dl, 80h
        jne     short notready
        push    es
        push    ax
        pusha
        mov     bx, sp
        mov     ds, ss:[bx+26]
        mov     cx, [si+2]
        les     bx, [si+4]
        mov     ax, [si+8]
        mov     dx, [si+10]
        push    ds
        push    si
        call    bp
        pop     si
        pop     ds
        sub     ax, [si+2]
        add     [si+2], ax
        popa
        pop     ax
        sbb     ah, ah
        and     ah, 4
        pop     es
        ret

DiskExtGetParams:
        cmp     dl, 80h
        jne     short notready
        push    ax
        mov     ax, HDSize   
        mov     bp, sp
        mov     ds, [bp+8]
        xor     bp, bp
        mov     word ptr [si], 1ah      ; size
        mov     word ptr [si+2], 0bh    ; flags
        mov     word ptr [si+4], 1023   ; cylinders
        mov     word ptr [si+6], bp
        mov     word ptr [si+8], 255    ; heads
        mov     word ptr [si+10], bp
        mov     word ptr [si+12], 63     ; sectors/track
        mov     word ptr [si+14], bp
        mov     word ptr [si+16], ax
        shl     word ptr [si+16], 10
        shr     ax, 6
        mov     word ptr [si+18], ax
        mov     word ptr [si+20], bp
        mov     word ptr [si+22], bp
        mov     word ptr [si+24], 512   ; bytes/sector
        pop     ax
        mov     ah, 0
        ret 

DiskReadSectBuffer:
DiskWriteSectBuffer:
DiskSetDASDType:
DiskSetMediaType:
DiskExtLock:
DiskExtEject:
        mov     ah, 1       ; unsupported fn
        ret

int13   endp


; --------------------- INT 15h - Extended services ----------------
UFPtr           equ     <ds:[98h]>
WaitCount       equ     <ds:[9ch]>
UWaitFlag       equ     <ds:[0a0h]>
HandlerPtr      equ     <ds:[0a1h]> ; 4 bytes
DataBuffer      equ     <ds:[0a5h]> ; 3 bytes
DataCounter     equ     <ds:[067h]> ; 1 byte
PacketSize      equ     <ds:[068h]> ; 1 byte, 0->3bytes, 1->4bytes
FreeXMSKb       equ     (1024 - 16 - 6)*64

; ------------ MovExt
IncSeg: ; DX = segment port address
        jnz     short SetSegExit
        in      ax, dx
        and     ax, 3ffh
        inc     ax
        cmp     ax, 12h
        jne     short IncSeg1
        xor     ax, ax
IncSeg1:
        cmp     ax, 0ch
        jne     short SetSeg2
SetSeg: ; DX = segment port address, ax = logical segment (0..1023)    
        and     ax, 3ffh
        cmp     ax, 0ch
        jb      short SetSeg1
        add     ax, 6
SetSeg2:        
        cmp     ax, 400h
        jb      short SetSeg1
        sub     ax, 400h - 0ch
SetSeg1:
        out     dx, ax          
SetSegExit:              
        ret

MovSeg  equ     01h
savess  dw      0
savesp  dw      MovExt, 0 ; tmp stack
; Log(idx) to Phy(val) segment map (1024segs): 0,1,2,3,4,5,6,7,8,9,a,b,12h,13h,...,3feh,3ffh,c,d,e,f,10h,11h, then wrap to 0,1,2,...
MovExt:
        push    es
        push    ds
        pusha
        cli
        mov     cs:savess, ss
        push    cs
        pop     ss
        xchg    sp, cs:savesp
        mov     dx, 80h + MovSeg + 1
        jcxz    short MovExt_exit
        push    es
        pop     ds
        cld
        mov     al, [si+1ch]
        mov     ah, [si+1fh]
        mov     bl, [si+14h]
        mov     bh, [si+17h]
        mov     di, [si+1ah]
        mov     si, [si+12h]
        call    flush   
        call    SetSeg      ; 02000h = destination, DX=82h
        dec     dx
        xchg    ax, bx
        call    SetSeg      ; 01000h = source, DX=81h
        push    MovSeg shl 12 
        pop     ds
        push    (MovSeg + 1) shl 12
        pop     es
        xor     bx, bx
        add     cx, cx
        adc     bx, bx      ; BX:CX = bytes to transfer
; move from 01000h:si to 02000h:di, 2*cx bytes
MovExtLoop:
        inc     dx          ; 82h
        mov     ax, si
        cmp     ax, di
        ja      short MovExt1
        mov     ax, di
MovExt1:
        neg     ax
        adc     bx, -1
        sub     cx, ax
        sbb     bx, 0
        xchg    ax, cx      ; cx = bytes to move, bx:ax = bytes left for the next transfer
        jns     short MovExt2   ; ax <= bx:cx     
        add     cx, ax
        xor     ax, ax
        inc     bx
MovExt2:
        movsb               ; if CX = 0 transfer 10000h bytes
        dec     cx
        jz      short MovExt_next
        test    si, 1       ; read align
        jz      short raligned
        movsb
        dec     cx
raligned:
        shr     cx, 1
        rep     movsw
        jnc     short MovExt_next
        movsb
MovExt_next:
        call    flush
        mov     cx, ax
        or      ax, bx
        jz      short MovExt_exit  ; finalized
        test    di, di
        call    incseg      ; does nothing if ZF == 0, dx = 8bh
        dec     dx          ; 81h
        test    si, si      
        call    incseg      ; dx = 81h
        jmp     short MovExtLoop
MovExt_exit:
        mov     ax, MovSeg + 1
        out     dx, ax      ; 82h
        dec     ax
        dec     dx
        out     dx, ax      ; 81h
        mov     ss, cs:savess
        xchg    sp, cs:savesp
        popa
        pop     ds
        pop     es
        xor     ah, ah
        jmp     short exit_ax
MovExtProxy:
        jmp     MovExt        

int15:
        cmp     ah, 4fh
        je      short exit_iret
        xchg    al, ah
        cmp     al, 80h
        jb      short exit15; CF=1  for <80h
        cmp     al, 83h
        jb      short done  ; no error for 80, 81, 82
        je      short SetEventWait; 83
        cmp     al, 86h
        jb      short exit15; CF=1 for 84, 85
        je      short Wait1 ; 86
        cmp     al, 88h
        jb      short MovExtProxy ; 87
        je      short ExtSize     ; 88
        cmp     al, 90h
        jb      short  exit15; CF=1 for 89..8f
        cmp     al, 92h
        jb      short done  ; no error for 90, 91
        cmp     al, 0c0h
        jb      short exit15; CF=1 for 92..bf
        je      short GetConfig   ; c0
        cmp     al, 0c2h
        jb      short exit15; CF=1 for c1
        je      short Mouse ; c2
done:
        cmc                 ; CF=1 for >c2
exit15:
        mov     ax, 8600h
exit_ax:        
        sti
        retf    2           ; discard flags (need to keep CF)
exit_iret:
        iret        

; ------------ SetEventWait
SetEventWait:
        push    ds
        push    40h
        pop     ds
        xor     ah, 1
        jz      short cancel
        test    ah, byte ptr UWaitFlag ; ah=1
        jnz     short busy  ; CF=0
        mov     ax, 1000-1  ; 1ms
        out     70h, ax     ; restart RTC timer
        mov     UFPtr[0], bx
        mov     UFPtr[2], es
        add     ax, dx
        adc     cx, 0
        mov     WaitCount[0], ax
        mov     WaitCount[2], cx
        mov     ah, 1       ; wait in progress
cancel:
        mov     byte ptr UWaitFlag, ah   
        int     70h
        stc                 ; no error
busy:   
        cmc                 ; eror        
nowait:
        pop     ds
        jmp     short exit15

; ------------ Wait
Wait1:
        push    es
        push    bx
        mov     ax, 8300h
        push    4ah
        pop     es
        xor     bx, bx      ; user wait flag address=0040:00a0
        int     15h         ; returns with IF = 1
        jc      short wbusy
wloop:        
        hlt   
        test    byte ptr es:[bx], 80h
        jz      short wloop
wbusy:        
        pop     bx
        pop     es
        jmp     short exit15
        

; ------------ ExtSize
ExtSize:
        mov     ax, FreeXMSKb
        jmp     short exit_ax
        
; ------------ GetConfig
GetConfig:
        xor     ax, ax
        push    cs
        pop     es
        mov     bx, offset SysParams
        jmp     short exit_ax
        
; ------------ Mouse 
Mouse:
        push    ds
        push    dx
        push    40h
        pop     ds
        test    byte ptr EquipmentWord, 4 ; ps2 mouse equipement word
        jnz     short mouse_present
if_err:
        mov     ax, 03a7h   ; interface error (no mouse present)
        out     64h, al     ; disable mouse
errexit:        
        stc                 ; error
exitok:        
        pushf               ; save CF
        in      al, 21h
        and     al, not 10h     
        out     21h, al     ; enable mouse interrupts
        call    enableKbIfPresent
        popf
        pop     dx
        pop     ds
        jmp     exit_ax
mouse_present:
        mov     al, ah                                  
        mov     ah, 1       ; invalid function
        cmp     al, 7
        ja      short errexit
        push    ax
        in      al, 21h
        or      al, 10h     
        out     21h, al     ; disable mouse interrupts
        sti                 ; allow interrupts for a short time, to flush possible pending KB/mouse requests
        mov     al, 0adh
        out     64h, al     ; disable kb interface
        pop     ax
        cmp     al, 1
        cli                 ; from now on we are working with ints disabled, as the following code is highly non re-entrant
        jb      short en_dis
        je      short reset
        cmp     al, 3
        jb      short sampling
        je      short resolution
        cmp     al, 5
        jb      short gettype
        je      short reset
        cmp     al, 6
        je      short extend

; ------------- set handler
        mov     HandlerPtr[0], bx
        mov     HandlerPtr[2], es
        jmp     short exit_success1        

; ------------- enable/disable
en_dis:
        mov     ax, 02f5h   ; ah = invalid input
        sub     al, bh
        cmp     bh, ah
        jnc     short errexit
        mov     ah, al
        call    sendcmd     ; enable/disable data reporting (CF = 1)
if_err1:        
        jc      short if_err
exit_success:
        mov     byte ptr DataCounter, 0
exit_success1:
        xor     ah, ah      ; success
        jmp     short exitok

; ------------- reset
reset:
        mov     ah, 0f6h    ; set defaults
        stc                 ; mouse command
        call    sendcmd     
        jc      short if_err
        mov     bx, 00aah
        mov     byte ptr PacketSize, bh ; 3bytes packet
        jmp     short exit_success

; ------------- sampling
sampling:
        cmp     bh, 6
badparam:
        mov     ah, 2       ; invalid input
        ja      short errexit
        shr     bx, 8
        mov     ah, cs:sample_tbl[bx]
        push    ax
        mov     ah, 0f3h    ; st sample rate
send2c:
        stc
        call    sendcmd              
        pop     ax
        jc      short if_err1
send1c:
        stc
        call    sendcmd
        jmp     short if_err1

; ------------- resolution
resolution:
        cmp     bh, 3
        ja      short badparam
        push    bx
        mov     ah, 0e8h    ; set resolution
        jmp     short send2c

; ------------- gettype
gettype:
        mov     ah, 0f2h
        stc
        call    sendcmd
        jc      short if_err1
        call    getps2byte
        jc      short if_err1
        mov     bh, al
        neg     al          ; CF=1 if al != 0
        adc     al, bh
        mov     byte ptr PacketSize, al ; 3 or 4 bytes packet
        jmp     short exit_success
        
; ------------- extended commands
extend:
        test    bh, bh
        jnz     short setscaling
        mov     ah, 0e9h    ; status request
        stc
        call    sendcmd
        jc      short if_err1
        call    getps2byte
        jc      short if_err1
        mov     bl, al
        call    getps2byte
        jc      short if_err1
        mov     cl, al
        call    getps2byte
        jc      short if_err1
        pop     dx  
        push    ax          ; replace dx on stack
        jmp     short exit_success
setscaling:    
        cmp     bh, 2
        ja      short badparam
        mov     ah, 0e5h    ; set scaling 1:1 or 2:1
        add     ah, bh
        jmp     short send1c

sample_tbl  db  10, 20, 40, 60, 80, 100, 200
SysParams   db  8, 0, 0fch, 0, 0
;--------------------------------------------------------------------------
; Feature byte 1
; b7: 1=DMA channel 3 used by hard disk
; b6: 1=2 interrupt controllers present
; b5: 1=RTC present
; b4: 1=BIOS calls int 15h/4Fh every key
; b3: 1=wait for extern event supported (Int 15h/41h)
; b2: 1=extended BIOS data area used
; b1: 0=AT or ESDI bus, 1=MicroChannel
; b0: 1=Dual bus (MicroChannel + ISA)
;--------------------------------------------------------------------------
            db      10h
;--------------------------------------------------------------------------
; Feature byte 2
; b7: 1=32-bit DMA supported
; b6: 1=int16h, function 9 supported
; b5: 1=int15h/C6h (get POS data) supported
; b4: 1=int15h/C7h (get mem map info) supported
; b3: 1=int15h/C8h (en/dis CPU) supported
; b2: 1=non-8042 kb controller
; b1: 1=data streaming supported
; b0: reserved
;--------------------------------------------------------------------------
            db      44h
;--------------------------------------------------------------------------
; Feature byte 3
; b7: not used
; b6: reserved
; b5: reserved
; b4: POST supports ROM-to-RAM enable/disable
; b3: SCSI on system board
; b2: info panel installed
; b1: Initial Machine Load (IML) system - BIOS on disk
; b0: SCSI supported in IML
;--------------------------------------------------------------------------
            db      0
;--------------------------------------------------------------------------
; Feature byte 4
; b7: IBM private
; b6: EEPROM present
; b5-3: ABIOS presence (011 = not supported)
; b2: private
; b1: memory split above 16Mb supported
; b0: POSTEXT directly supported by POST
;--------------------------------------------------------------------------
            db      0
;--------------------------------------------------------------------------
; Feature byte 5 (IBM)
; b1: enhanced mouse
; b0: flash EPROM
;--------------------------------------------------------------------------
            db      0                                                


; --------------------- INT 16h - keyboard interface ----------------
;       AH      Description
;       --      ------------------------------------------------
;       00h     Get a key from the keyboard, return code in AX.
;       01h     Test for available key, ZF=1 if none, ZF=0 and
;               AX contains next key code if key available.
;       02h     Get shift status. Returns shift key status in AL.
;       03h     Set Autorepeat rate. BH=0,1,2,3 (delay time in quarter seconds), BL=0..1Fh for 30 char/sec to 2 char/sec repeat rate.
;       05h     Store scan code (in CX) in the type ahead buffer.
;       10h     Get a key (same as 00h in this implementation).
;       11h     Test for key (same as 01h).
;       12h     Get extended key status. Returns status in AX.

AltKpd          equ     <ds:[19h]>
HeadPtr         equ     <ds:[1ah]>
TailPtr         equ     <ds:[1ch]>
Buffer          equ     <ds:[80h]>;1eh
EndBuf          equ     <ds:[82h]>;3eh

int16 proc near
        push    ds
        push    si
        push    40h
        pop     ds
        xchg    al, ah          ;shorter opcodes for al than ah
        dec     ax
        test    al, 0EFh        ;Check for 01h and 11h
        jz      short TestKey   ;TestKey does not need cld
        inc     ax
        cld
        test    al, 0EFh        ;Check for 0h and 10h
        jz      short GetKey
        cmp     al, 3           ;Check for 02h and 03h
        jb      short GetStatus
        je      short SetAutoRpt   
        cmp     al, 5           ;Check for StoreKey function.
        je      short StoreKey
        cmp     al, 9           ;Get KB functionality
        je      short kbfunc     
        cmp     al, 12h         ;Extended status call
        je      short ExtStatus
        cmp     al, 92h         ;stupid keyb.com 
        jne     short Exit
kbfunc:
        mov     al, 24h         ;AL=20h (fn 10h, 12h supported, set typematic supported)        
Exit:        
        pop     si
        pop     ds
        iret                    ; unknown function, Restores flags.

GetKey1:                        ; wait for interrupt
        hlt
GetKey: ; ----------- fn 00h, 10h
        mov     ah, 11h
        int     16h             ;See if key is available (IF becomes 1 after this int)
        jz      short GetKey1   ;Wait for keystroke.
        cli                     ;Critical region! Ints off.
        mov     si, HeadPtr     ;Ptr to next character.
        lodsw                   ;Get the character, Bump up HeadPtr
        cmp     si, EndBuf
        jb      short noWrap
        mov     si, Buffer
noWrap:             
        mov     HeadPtr, si
        jmp     short Exit

TestKey: ; ---------- fn 01h
        mov     si, HeadPtr
        cmp     si, TailPtr     ;ZF=1, if empty buffer
        lodsw                   ;BIOS returns avail keycode.
        sti                     ;Ints back on.
        pop     si
        pop     ds
        retf    2               ;Pop flags (ZF is important!)

StoreKey: ; ---------- fn 05h - Inserts the value in CX into the type ahead buffer.  
        mov     si, TailPtr     ;Address where we can put next key code.
        mov     [si], cx        ;Store the key code away
        inc     si
        inc     si              ;Move on to next entry in buf
        cmp     si, EndBuf
        jb      short NoWrap1
        mov     si, Buffer
 NoWrap1:
        mov     al, 1           ;no room
        cmp     si, HeadPtr     ;Data overrun?
        je      short Exit      ;if so, ignore key entry.
        mov     TailPtr, si
        dec     ax              ;al=0
        jmp     short Exit       

ExtStatus: ; ------- fn 12h - Retrieve the extended keyboard status and return it in AH, and the standard keyboard status in AL.    
        mov     al, KbdFlags2
        and     al, 01110111b   ;Clear final sysreq field, and final right alt bit.
        test    al, 100b        ;Test cur sysreq bit.
        jz      short NoSysReq  ;Skip if it's zero.
        sub     al, 10000100b   ;Set final sysreq bit, clear final right ctl bit.
NoSysReq:
        mov     ah, KbdFlags3
        and     ah, 1100b       ;Grab rt alt/ctrl bits.
        or      ah, al          ;Merge into AH.

GetStatus: ; --------- fn 02h     
        mov     al, KbdFlags1   ;Just return Std Status.
Exit1:
        jmp     short Exit

SetAutoRpt: ; ------ fn 03h
        cmp     ah, 5
        jne     short Exit
        push    dx
        shl     bh, 5
        and     bl, 1fh
        or      bl, bh
        and     bl, 7fh
        mov     ah, 0           ; wait LED update progress to finalize
        call    WaitFlag        ; leaves with IF=0
        jc      short timeout
        or      byte ptr KbdFlags4, SetRepeat    ; set auto repeat in progress
        mov     ah, 0f3h        ; set typematic rate and delay
        push    bx
        xor     bl, bl          ; send to kb
        call    sendps2byte
        pop     bx
        jc      short timeout1  ; send timeout
        mov     ah, SetRepeat or AckReceived ; test if ACK received
        call    WaitFlag
        jc      short timeout1
        mov     ah, bl
        xor     bl, bl          ; send to kb
        call    sendps2byte     ; send data
timeout1:
        and     byte ptr KbdFlags4, not SetRepeat   
timeout:
        pop     dx
        jmp     short Exit1


WaitFlag:   ; ah = desired KbdFlags4 & (AckReceived | LEDUpdate | SetRepeat)
        mov     dx, 3dah
        mov     bh, 8*25    ; wait for max 25 * VGA frame time
wf_loop:
        cli
        mov     al, KbdFlags4
        and     al, AckReceived or LEDUpdate or SetRepeat
        cmp     al, ah
        je      short wf_ok ; flag ok, CF=0
        sti
        in      al, dx      ; get vblank
        xor     al, bh
        and     al, 8h
        sub     bh, al
        jnc     short wf_loop     ; IBF - buffer full, no timeout
wf_ok:
        ret
int16 endp

; --------------------- INT 18h - BIOS Basic ------------------
int18 proc near
        push    cs
        pop     es
        mov     si, offset booterrmsg
        call    prts

;-------------- RS232 bootstrap
        mov     al, 0b4h
        out     43h, al
        mov     ax, 0f000h
        out     42h, al
        out     42h, al      ; 18Hz PIT CH2
	  mov ds,ax
	  mov es,ax

        mov si,100h
	  call srecb
        cli
	  mov bh,ah
	  call srecb
	  mov bl,ah
sloop:	
	  call srecb
	  mov [si],ah
	  inc si
	  dec bx
	  jnz short sloop
	  db 0eah
        dw 100h,0f000h

booterrmsg db   'No boot device available, waiting on RS232 (115200bps, f000:100) ...', 13, 10, 0
int18 endp

; --------------------- INT 19h - OS Bootstrap loader ------------------
int19 proc near
        mov     ax, 201h
        mov     cx, 1
        mov     dx, 80h
        push    0
        pop     es
        mov     bx, 7c00h
        int     13h
        jc      int19err
        db      0eah
        dw      7c00h, 0     ; jmp far 0000h:7c00h
int19err:
        int     18h
int19 endp


; --------------------- INT 1ah - Get System Time ------------------
int1a proc near
        push    ds
        push    40h
        pop     ds
        cmp     ah, 1
        ja      clockexit
        je      setclock
        mov     dx, ds:[6ch]    ; read clock
        mov     cx, ds:[6eh]
        mov     al, ds:[70h]
clockexit1:
        mov     byte ptr ds:[70h], 0
clockexit:
        cmc     ; CF = 1 on error
        pop     ds
        sti
        retf    2

setclock:
        mov     ds:[6ch], dx
        mov     ds:[6eh], cx
        stc
        jmp     short clockexit1    
int1a endp


; --------------------- INT 70h - RTC ------------------
int70 proc near
        push    ds
        push    40h
        pop     ds
        test    byte ptr UWaitFlag, 1    ; is wait in progress?
        jz      short exit
        sub     word ptr WaitCount[0], 1000
        sbb     word ptr WaitCount[2], 0
        jnc     short exit
        mov     byte ptr UWaitFlag, 0
        push    bx
        lds     bx, UFPtr
        or      byte ptr [bx], 80h
        pop     bx
exit: 
        pop     ds
        iret
int70 endp

        
; --------------------- INT 74h - mouse ------------------
int74 proc near
        cld
        pusha
        push    ds
        push    40h
        pop     ds
        mov     ah, 0
        in      al, 60h
        mov     bx, ax
        inc     byte ptr DataCounter
        mov     al, DataCounter
        mov     si, ax
        sub     al, 3
        ja      short docall
        mov     DataBuffer[si-1], bl
        cmp     al, PacketSize
        jne     short nocall
        mov     bl, 0
docall:
        mov     byte ptr DataCounter, bh    ; BH=0
        mov     si, offset DataBuffer-2
        lodsw
        or      ax, [si-4]
        jz      short nocall
        sti
        push    es
        mov     ah, 0
        lodsb
        push    ax
        lodsb
        push    ax
        lodsb
        push    ax
        push    bx
        call    far ptr [si-7]
        add     sp, 8
        pop     es
nocall:        
        pop     ds
        popa
        iret
int74 endp


; ----------------  serial receive byte 115200 bps --------------
srecb:  mov     ah, 80h
        mov     dx, 3dah
        mov     cx, -5aeh ; (half start bit)
srstb:  in      al, dx
	  shr     al, 2
	  jc      short srstb
        in      al, 42h ; lo counter
        add     ch, al
        in      al, 42h ; hi counter, ignore
l1:
        call    dlybit
	  in      al, dx
        shr     al, 2
	  rcr     ah, 1
	  jnc     short l1
dlybit:
        sub     cx, 0a5bh  ;  (full bit)
dly1:
        in      al, 42h
        cmp     al, ch
        in      al, 42h
        jnz     short dly1
        ret

; -------------------- KB/Mouse access ----------------
sendps2byte proc near   ; ah=data, bl!=0 for mouse, 0 for kb. returns cf=1 if timeout (al = 8)
; changes BH, AL
        push    dx
        mov     dx, 3dah
        mov     bh, 8*5
sps2b2:
        in      al, 64h
        test    al, 2
        jz      short sps2b1; buffer empty
        in      al, dx      ; get vblank
        xor     al, bh
        and     al, 8h
        sub     bh, al
        jnc     short sps2b2; IBF - buffer full, no timeout
        jmp     short exit  ; timeout, CF=1
sps2b1:
        test    bl, bl      ; CF=0
        jz      short sps2_kb
        mov     al, 0d4h    ; next mouse
        out     64h, al
sps2_kb:
        mov     al, ah
        out     60h, al     ; send byte
exit:        
        pop     dx
        ret
sendps2byte endp

getps2byte proc near    ; returns al=data, zf=0 for mouse, 1 for kb, cf=1 if timeout (al=8)
; changes BH, DX, AL
        mov     dx, 3dah
        mov     bh, 8*5
gps2b2:
        in      al, 64h
        test    al, 1
        jnz     short gps2b1     ; OBF (buffer full), continue
        in      al, dx     ; get vblank
        xor     al, bh
        and     al, 8
        sub     bh, al
        jnc     short gps2b2     ; buffer empty, no timeout
        ret                ; timeout, CF=1
gps2b1:
        test    al, 20h    ; CF=0, ZF <- !MOBF
        in      al, 60h    ; read byte (if IF=1, this data may be invalid)
        ret
getps2byte endp

sendcmd proc near     ; ah = command, CF=1 for mouse, CF=0 for kb. returns CF=1 on error
        sbb     bl, bl      ; bl <- CF
        call    sendps2byte 
        jc      short exit
retry:        
        call    getps2byte
        jc      short exit        
        cmp     al, 0fah    ; ack (returns CF=1 on error, when al=8)
        jne     short retry
exit:
        ret
sendcmd endp

enableKbIfPresent proc near ; input DS = 40h
; modify AL, flags
        test    byte ptr KbdFlags3, 10h
        jz      short noenablekb
        mov     al, 0aeh
        out     64h, al     ; enable kb interface
noenablekb:        
        ret
enableKbIfPresent endp

; ----------------------- default interrupt handler ---------------
defint  proc near
        iret
defint  endp             

; ------------------------------- flush --------------------------
flush: 
        pop     cs:flushret
flush_nostack:        
        mov     cs:flushbh, bh
        mov     bh, 7       ; flush all 7 cache lines (the 8th one is CS:IP)
flush1:        
        test    bl, cs:[bx + 0e000h]
        dec     bh
        jnz     short flush1
        mov     bh, cs:flushbh
        jmp     word ptr cs:flushret
flushret dw 0
flushbh  db 0          

; ------------------------------- misc --------------------------
dispAX: 
        push    dx
        xor     dx, dx
        div     word ptr cs:ten
        test    ax, ax
        jz      dispAX1
        call    dispAX
dispAX1:
        xchg    ax, dx
        add     ax, 0e00h + '0'
        int     10h
        pop     dx
        ret        
ten     dw      10

prts:   ; es:si = string
        mov     ah, 0eh    
        lodsb   es:[si]
        or      al, al
        jz      short prtse
        int     10h
        jmp     short prts
prtse:
        ret



;---------------------  read/write byte ----------------------
sdrb:   mov al,0ffh
sdsb:               ; in AL=byte, DX = 03dah, out AX=result
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        in      ax, dx
        ret

;---------------------  write block ----------------------
sdwblk proc near              ; in SI=data ptr, DX=03dah, CX=size
        shr     cx, 1
sdwblk1:
        lodsb
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        lodsb
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        add     ax, ax
        out     dx, al
        loop    short sdwblk1
        ret
sdwblk endp

;---------------------  read block ----------------------
sdrblk proc near              ; in DI=data ptr, DX=03dah, CX=size. Returns CF = 0
        mov     al, 0ffh
        out     dx, al
        shr     cx, 1         ; CF = 0
        out     dx, al
        jmp     short sdrblk2 
sdrblk1:
        out     dx, al
        mov     [di], ah
        out     dx, al
        inc     di
sdrblk2:
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        in      ax, dx
        out     dx, al
        mov     [di], ah
        out     dx, al
        inc     di
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        nop
        out     dx, al
        in      ax, dx
        loop    short sdrblk1
        mov     [di], ah
        inc     di
        ret
sdrblk endp

;---------------------  verify block ----------------------
sdvblk:              ; in DI=data ptr, DX=03dah, CX=size. Returns CF=1 on error
        push    bx
        xor     bl, bl
sdvblk1:
        call    sdrb
        sub     ah, [di]
        or      bl, ah
        inc     di
        loop    short sdvblk1
        neg     bl  ; CF=1 if BL != 0
        pop     bx
        ret

;---------------------  write command ----------------------
sdcmd8T:
        call    sdrb
sdcmd:              ; in SI=6 bytes cmd buffer, DX=03dah, out AH = 0ffh on error
        mov     cx, 6
        call    sdwblk
sdresp:
        xor     si, si
sdresp1:
        call    sdrb
        inc     si
        jz      short sdcmd1
        cmp     ah, 0ffh
        je      short sdresp1
sdcmd1: ret         

;---------------------  read ----------------------
sdverify:
        push    sdvblk
        jmp     short sdread1
sdread:   ; DX:AX sector, ES:BX buffer, CX=sectors. returns AX=read sectors
        push    sdrblk   ; push proc address (read or verify) on stack
sdread1:        
        push    ax
        mov     al, dl
        push    ax
        mov     dl, 51h  ; CMD17
        cmp     cx, 1
        je      short sdr1s
        inc     dx      ; CMD18 - multiple sectors
sdr1s:
        push    dx
        mov     si, sp 

        mov     dx, 3dah
        mov     ah, 1
        out     dx, ax       ; CS on
        mov     di, bx
        mov     bx, cx
        mov     bp, cx       ; save sectors number
        push    ss
        pop     ds
        call    sdcmd
        add     sp, 6
        or      ah, ah
        jnz     short sdr11   ; error
        push    es
        pop     ds
sdrms:
        mov     ax, di
        shr     ax, 4
        mov     si, ds
        add     ax, si
        mov     ds, ax
        and     di, 15
        call    sdresp     ; wait for 0feh token
        cmp     ah, 0feh
        jne     short sdr11; read token error 
        mov     ch, 2      ; 512 byte sector
        pop     si
        call    si         ; sdrblk or sdvblk
        push    si
        pushf
        call    sdrb       ; ignore CRC
        call    sdrb       ; ignore CRC
        popf
        jc      short sdr3 ; verify error   
        dec     bx
        jnz     short sdrms; multiple sectors
sdr3:        
        cmp     bp, 1
        je      short sdr11; single sector
        mov     si, offset SD_CMD12 ; stop transfer
        push    cs
        pop     ds
        call    sdcmd
sdr2:
        shr     ah, 1
        jnc     short sdr11
        call    sdrb
        jmp     short sdr2
sdr11:
        pop     ax         ; remove proc address from stack
sdr1:       
        xor     ax, ax
        out     dx, ax
        call    sdrb       ; 8T
        mov     ax, bp
        sub     ax, bx
        ret     

;---------------------  write ----------------------
sdwrite:   ; DX:AX sector, ES:BX buffer, CX=sectors, returns AX=wrote sectors
        push    ax
        mov     al, dl
        push    ax
        mov     dl, 58h  ; CMD24
        cmp     cx, 1
        je      short sdw1s
        inc     dx      ; CMD25 - multiple sectors
sdw1s:
        push    dx
        mov     si, sp 

        mov     dx, 3dah
        mov     ah, 1
        out     dx, ax       ; CS on
        mov     bp, cx       ; save sectors number
        push    ss
        pop     ds
        call    sdcmd
        add     sp, 6
        mov     si, bx
        mov     bx, bp
        or      ah, ah
        jnz     short sdr1   ; error
        push    es
        pop     ds
sdwms:
        mov     ax, si
        shr     ax, 4
        mov     di, ds
        add     ax, di
        mov     ds, ax
        and     si, 15
        mov     al, 0feh      ; start token
        cmp     bp, 1
        je      short sdw1s1
        mov     al, 0fch   ; multiple sectors
sdw1s1:        
        call    sdsb     
        mov     ch, 2      ; 512 byte sector
        call    sdwblk
        call    sdrb       ; ignore CRC
        call    sdrb       ; ignore CRC
        call    sdrb       ; read response byte xxx00101
        and     ah, 0eh
        cmp     ah, 4
        jne     short sdr1 ; write error
sdwwait:
        call    sdrb
        shr     ah, 1
        jnc     short sdwwait     ; wait write completion
        dec     bx
        jnz     short sdwms       ; multiple sectors

        cmp     bp, 1
        je      short sdr1
        mov     al, 0fdh     ; multiple end transfer
        call    sdsb      
sdwwait1:
        call    sdrb
        shr     ah, 1
        jnc     short sdwwait1     ; wait write completion
        jmp     sdr1
        
;---------------------  init SD ----------------------
sdinit  proc near       ; returns AX = num kilosectors
        push    ds
        push    cx
        push    dx
        push    si
        push    di
        mov     dx, 3dah
        mov     cx, 10
sdinit1:                   ; send 80T
        call    sdrb
        loop    short sdinit1

        mov     ah, 1
        out     dx, ax       ; select SD

        mov     si, offset SD_CMD0
        push    cs
        pop     ds
        call    sdcmd
        dec     ah
        jnz     short sdexit ; error
        
        mov     si, offset SD_CMD8
        call    sdcmd8T
        dec     ah
        jnz     short sdexit ; error
        mov     cl, 4
        sub     sp, cx
        mov     di, sp
        push    ss
        pop     ds
        call    sdrblk
        pop     ax
        pop     ax
        cmp     ah, 0aah
        jne     short sdexit ; CMD8 error
repinit:        
        mov     si, offset SD_CMD55
        push    cs
        pop     ds
        call    sdcmd8T
        call    sdrb
        mov     si, offset SD_CMD41
        call    sdcmd
        dec     ah
        jz      short repinit
        
        mov     si, offset SD_CMD58
        call    sdcmd8T
        mov     cl, 4
        sub     sp, cx
        mov     di, sp
        push    ss
        pop     ds
        call    sdrblk
        pop     ax
        test    al, 40h     ; test OCR bit 30 (CCS)
        pop     ax
        jz      short sdexit; no SDHC

        mov     si, offset SD_CMD9 ; get size info
        push    cs
        pop     ds
        call    sdcmd8T
        or      ah, ah
        jnz     short sdexit
        call    sdresp     ; wait for 0feh token
        cmp     ah, 0feh
        jne     short sdexit
        mov     cl, 18       ; 16bytes + 2bytes CRC
        sub     sp, cx
        mov     di, sp
        push    ss
        pop     ds
        call    sdrblk
        mov     cx, [di-10]
        rol     cx, 8
        inc     cx
        mov     sp, di
sdexit: 
        xor     ax, ax       ; raise CS
        out     dx, ax
        call    sdrb
        pop     di
        pop     si
        pop     dx
        mov     ax, cx       
        pop     cx
        pop     ds
        ret
sdinit endp
    
SD_CMD0     db  40h, 0, 0, 0, 0, 95h
SD_CMD8     db  48h, 0, 0, 1, 0aah, 087h
SD_CMD9     db  49h, 0, 0, 0, 0, 0ffh
SD_CMD12    db  4ch, 0, 0, 0, 0, 0ffh
SD_CMD41    db  69h, 40h, 0, 0, 0, 0ffh
SD_CMD55    db  77h, 0, 0, 0, 0, 0ffh
SD_CMD58    db  7ah, 0, 0, 0, 0, 0ffh


default_pal:
        db  00h,00h,00h, 00h,00h,2ah, 00h,2ah,00h, 00h,2ah,2ah, 2ah,00h,00h, 2ah,00h,2ah, 2ah,15h,00h, 2ah,2ah,2ah 
        db  15h,15h,15h, 15h,15h,3fh, 15h,3fh,15h, 15h,3fh,3fh, 3fh,15h,15h, 3fh,15h,3fh, 3fh,3fh,15h, 3fh,3fh,3fh 
        db  00h,00h,00h, 05h,05h,05h, 08h,08h,08h, 0bh,0bh,0bh, 0eh,0eh,0eh, 11h,11h,11h, 14h,14h,14h, 18h,18h,18h 
        db  1ch,1ch,1ch, 20h,20h,20h, 24h,24h,24h, 28h,28h,28h, 2dh,2dh,2dh, 32h,32h,32h, 38h,38h,38h, 3fh,3fh,3fh 
        db  00h,00h,3fh, 10h,00h,3fh, 1fh,00h,3fh, 2fh,00h,3fh, 3fh,00h,3fh, 3fh,00h,2fh, 3fh,00h,1fh, 3fh,00h,10h 
        db  3fh,00h,00h, 3fh,10h,00h, 3fh,1fh,00h, 3fh,2fh,00h, 3fh,3fh,00h, 2fh,3fh,00h, 1fh,3fh,00h, 10h,3fh,00h 
        db  00h,3fh,00h, 00h,3fh,10h, 00h,3fh,1fh, 00h,3fh,2fh, 00h,3fh,3fh, 00h,2fh,3fh, 00h,1fh,3fh, 00h,10h,3fh 
        db  1fh,1fh,3fh, 27h,1fh,3fh, 2fh,1fh,3fh, 37h,1fh,3fh, 3fh,1fh,3fh, 3fh,1fh,37h, 3fh,1fh,2fh, 3fh,1fh,27h 
        db  3fh,1fh,1fh, 3fh,27h,1fh, 3fh,2fh,1fh, 3fh,37h,1fh, 3fh,3fh,1fh, 37h,3fh,1fh, 2fh,3fh,1fh, 27h,3fh,1fh 
        db  1fh,3fh,1fh, 1fh,3fh,27h, 1fh,3fh,2fh, 1fh,3fh,37h, 1fh,3fh,3fh, 1fh,37h,3fh, 1fh,2fh,3fh, 1fh,27h,3fh 
        db  2dh,2dh,3fh, 31h,2dh,3fh, 36h,2dh,3fh, 3ah,2dh,3fh, 3fh,2dh,3fh, 3fh,2dh,3ah, 3fh,2dh,36h, 3fh,2dh,31h 
        db  3fh,2dh,2dh, 3fh,31h,2dh, 3fh,36h,2dh, 3fh,3ah,2dh, 3fh,3fh,2dh, 3ah,3fh,2dh, 36h,3fh,2dh, 31h,3fh,2dh 
        db  2dh,3fh,2dh, 2dh,3fh,31h, 2dh,3fh,36h, 2dh,3fh,3ah, 2dh,3fh,3fh, 2dh,3ah,3fh, 2dh,36h,3fh, 2dh,31h,3fh 
        db  00h,00h,1ch, 07h,00h,1ch, 0eh,00h,1ch, 15h,00h,1ch, 1ch,00h,1ch, 1ch,00h,15h, 1ch,00h,0eh, 1ch,00h,07h 
        db  1ch,00h,00h, 1ch,07h,00h, 1ch,0eh,00h, 1ch,15h,00h, 1ch,1ch,00h, 15h,1ch,00h, 0eh,1ch,00h, 07h,1ch,00h 
        db  00h,1ch,00h, 00h,1ch,07h, 00h,1ch,0eh, 00h,1ch,15h, 00h,1ch,1ch, 00h,15h,1ch, 00h,0eh,1ch, 00h,07h,1ch 
        db  0eh,0eh,1ch, 11h,0eh,1ch, 15h,0eh,1ch, 18h,0eh,1ch, 1ch,0eh,1ch, 1ch,0eh,18h, 1ch,0eh,15h, 1ch,0eh,11h 
        db  1ch,0eh,0eh, 1ch,11h,0eh, 1ch,15h,0eh, 1ch,18h,0eh, 1ch,1ch,0eh, 18h,1ch,0eh, 15h,1ch,0eh, 11h,1ch,0eh 
        db  0eh,1ch,0eh, 0eh,1ch,11h, 0eh,1ch,15h, 0eh,1ch,18h, 0eh,1ch,1ch, 0eh,18h,1ch, 0eh,15h,1ch, 0eh,11h,1ch 
        db  14h,14h,1ch, 16h,14h,1ch, 18h,14h,1ch, 1ah,14h,1ch, 1ch,14h,1ch, 1ch,14h,1ah, 1ch,14h,18h, 1ch,14h,16h 
        db  1ch,14h,14h, 1ch,16h,14h, 1ch,18h,14h, 1ch,1ah,14h, 1ch,1ch,14h, 1ah,1ch,14h, 18h,1ch,14h, 16h,1ch,14h 
        db  14h,1ch,14h, 14h,1ch,16h, 14h,1ch,18h, 14h,1ch,1ah, 14h,1ch,1ch, 14h,1ah,1ch, 14h,18h,1ch, 14h,16h,1ch 
        db  00h,00h,10h, 04h,00h,10h, 08h,00h,10h, 0ch,00h,10h, 10h,00h,10h, 10h,00h,0ch, 10h,00h,08h, 10h,00h,04h 
        db  10h,00h,00h, 10h,04h,00h, 10h,08h,00h, 10h,0ch,00h, 10h,10h,00h, 0ch,10h,00h, 08h,10h,00h, 04h,10h,00h 
        db  00h,10h,00h, 00h,10h,04h, 00h,10h,08h, 00h,10h,0ch, 00h,10h,10h, 00h,0ch,10h, 00h,08h,10h, 00h,04h,10h 
        db  08h,08h,10h, 0ah,08h,10h, 0ch,08h,10h, 0eh,08h,10h, 10h,08h,10h, 10h,08h,0eh, 10h,08h,0ch, 10h,08h,0ah 
        db  10h,08h,08h, 10h,0ah,08h, 10h,0ch,08h, 10h,0eh,08h, 10h,10h,08h, 0eh,10h,08h, 0ch,10h,08h, 0ah,10h,08h 
        db  08h,10h,08h, 08h,10h,0ah, 08h,10h,0ch, 08h,10h,0eh, 08h,10h,10h, 08h,0eh,10h, 08h,0ch,10h, 08h,0ah,10h 
        db  0bh,0bh,10h, 0ch,0bh,10h, 0dh,0bh,10h, 0fh,0bh,10h, 10h,0bh,10h, 10h,0bh,0fh, 10h,0bh,0dh, 10h,0bh,0ch 
        db  10h,0bh,0bh, 10h,0ch,0bh, 10h,0dh,0bh, 10h,0fh,0bh, 10h,10h,0bh, 0fh,10h,0bh, 0dh,10h,0bh, 0ch,10h,0bh 
        db  0bh,10h,0bh, 0bh,10h,0ch, 0bh,10h,0dh, 0bh,10h,0fh, 0bh,10h,10h, 0bh,0fh,10h, 0bh,0dh,10h, 0bh,0ch,10h 
        db  00h,00h,00h, 00h,00h,00h, 00h,00h,00h, 00h,00h,00h, 00h,00h,00h, 00h,00h,00h, 00h,00h,00h, 00h,00h,00h

IFDEF SCANCODE1 ; use SCANCODE1
KeyIndex:
        db	0, 82, 49, 50, 52, 51, 54, 55    ;0-7
        db 56, 57, 60, 59, 65, 68, 72, 47    ;8-f
        db	1,  5,  9, 13, 12, 18, 21, 23    ;10-17
        db 24, 26, 67, 70, 69,  0,  4,  3    ;18-1f
        db	8, 11, 17, 16, 20, 22, 25, 64    ;20-27
        db 66, 48,  0, 71,  2,  7,  6, 10    ;28-2f
        db 15, 14, 19, 58, 61, 62,  0, 87    ;30-37
        db	0, 53,  0, 40, 41, 39, 46, 38    ;38-3f
        db 45, 90, 44, 79, 43,  0, 89, 29    ;40-47
        db 34, 36, 86, 28, 37, 33, 84, 27    ;48-4f
        db 32, 35, 30, 31,  0,  0,	0, 83    ;50-57  
        db 42
E0KeyList:
	db	35h, 1ch, 4fh, 4bh, 47h, 52h, 53h, 50h, 4dh, 48h, 51h, 49h 

ELSE    ; use SCANCODE2

KeyIndex:
        db	0, 79,  0, 38, 39, 40, 41, 42
        db	0, 43, 44, 45, 46, 47, 48,  0
        db	0,  0,  0,  0,  0,  1, 49,  0
        db	0,  0,  2,	3,  4,  5, 50,  0
        db	0,  6,  7,	8,  9, 51, 52,  0
        db	0, 53, 10, 11, 12, 13, 54,  0
        db	0, 14, 15, 16, 17, 18, 55,  0
        db	0,  0, 19, 20, 21, 56, 57,  0
        db	0, 58, 22, 23, 24, 59, 60,  0
        db	0, 61, 62, 25, 64, 26, 65,  0
        db	0,  0, 66,	0, 67, 68,	0,  0
        db	0,  0, 69, 70,  0, 71,	0,  0
        db	0,  0,  0,	0,  0,  0, 72,  0
        db	0, 27,  0, 28, 29,  0,	0,  0
        db 30, 31, 32, 37, 33, 34, 82,  0
        db 83, 84, 35, 86, 87, 36, 89,  0
        db	0,  0,  0,	90 	
E0KeyList:
	db	4ah, 5ah, 69h, 6bh, 6ch, 70h, 71h, 72h, 74h, 75h, 7ah, 7dh 

ENDIF

E0KeyIndex:
	db	63,  69,  73,  74,  75,  76,  77,  78,  80,  81,  85,  88

KeyCode:	  
; Keys affected by CapsLock
;		norm   shft   ctrl   alt
        dw	0000h, 0000h, 0000h, 0000h ;17 - <0>
        dw	1071h, 1051h, 1011h, 1000h ;15 - Q, (E0)PrevTrack <1>
        dw	2c7ah, 2c5ah, 2c1ah, 2c00h ;1a - Z <2>
        dw	1f73h, 1f53h, 1f13h, 1f00h ;1b - S <3>
        dw	1e61h, 1e41h, 1e01h, 1e00h ;1c - A <4>
        dw	1177h, 1157h, 1117h, 1100h ;1d - W <5>
        dw	2e63h, 2e43h, 2e03h, 2e00h ;21 - C, (E0)Volume Down <6>
        dw	2d78h, 2d58h, 2d18h, 2d00h ;22 - X <7>
        dw	2064h, 2044h, 2004h, 2000h ;23 - D, (E0)Mute <8>
        dw	1265h, 1245h, 1205h, 1200h ;24 - E <9>
        dw	2f76h, 2f56h, 2f16h, 2f00h ;2a - V <10>
        dw	2166h, 2146h, 2106h, 2100h ;2b - F, (E0)Calculator <11>
        dw	1474h, 1454h, 1414h, 1400h ;2c - T <12>
        dw	1372h, 1352h, 1312h, 1300h ;2d - R <13>
        dw	316eh, 314eh, 310eh, 3100h ;31 - N <14>
        dw	3062h, 3042h, 3002h, 3000h ;32 - B, (E0)Volume Up <15>
        dw	2368h, 2348h, 2308h, 2300h ;33 - H <16>
        dw	2267h, 2247h, 2207h, 2200h ;34 - G, (E0)Play/Pause <17>
        dw	1579h, 1559h, 1519h, 1500h ;35 - Y <18>
        dw	326dh, 324dh, 320dh, 3200h ;3a - M, (E0)WWW Home <19>
        dw	246ah, 244ah, 240ah, 2400h ;3b - J, (E0)Stop <20>
        dw	1675h, 1655h, 1615h, 1600h ;3c - U <21>
        dw	256bh, 254bh, 250bh, 2500h ;42 - K <22>
        dw	1769h, 1749h, 1709h, 1700h ;43 - I <23>
        dw	186fh, 184fh, 180fh, 1800h ;44 - O <24>
        dw	266ch, 264ch, 260ch, 2600h ;4b - L <25>
        dw	1970h, 1950h, 1910h, 1900h ;4d - P, (E0)Next Track <26>
; keys affected by NumLock	
        dw	4f00h, 4f31h, 7500h, 0002h ;69 - KP1 <27>
        dw	4b00h, 4b34h, 7300h, 0005h ;6b - KP4 <28>
        dw	4700h, 4737h, 7700h, 0008h ;6c - KP7 <29>
        dw	5200h, 5230h, 9200h, 0001h ;70 - KP0 <30>
        dw	5300h, 532eh, 9300h, 0000h ;71 - KP. <31>
        dw	5000h, 5032h, 9100h, 0003h ;72 - KP2 <32>
        dw	4d00h, 4d36h, 7400h, 0007h ;74 - KP6 <33>
        dw	4800h, 4838h, 8d00h, 0009h ;75 - KP8 <34>
        dw	5100h, 5133h, 7600h, 0004h ;7a - KP3 <35>
        dw	4900h, 4939h, 8400h, 000ah ;7d - KP9 <36>
        dw	4c00h, 4c35h, 8f00h, 0006h ;73 - KP5 --- on VMWare, it does not send 4c00 <37>
; keys unaffected by CapsLock or N
        dw	3f00h, 5800h, 6200h, 6c00h ;03 - F5 <38>
        dw	3d00h, 5600h, 6000h, 6a00h ;04 - F3 <39>
        dw	3b00h, 5400h, 5e00h, 6800h ;05 - F1 <40>
        dw	3c00h, 5500h, 5f00h, 6900h ;06 - F2 <41>
        dw	8600h, 8800h, 8a00h, 8c00h ;07 - F12 <42>	
        dw	4400h, 5d00h, 6700h, 7100h ;09 - F10 <43>
        dw	4200h, 5b00h, 6500h, 6f00h ;0a - F8 <44>
        dw	4000h, 5900h, 6300h, 6d00h ;0b - F6 <45>
        dw	3e00h, 5700h, 6100h, 6b00h ;0c - F4 <46>
        dw	0f09h, 0f00h, 9400h, 0000h ;0d - TAB <47>	
        dw	2960h, 297eh, 0000h, 2900h ;0e - ` ~ <48>	
        dw	0231h, 0221h, 0000h, 7800h ;16 - 1 ! <49>	
        dw	0332h, 0340h, 0300h, 7900h ;1e - 2 @ <50>	
        dw	0534h, 0524h, 0000h, 7b00h ;25 - 4 $ <51>
        dw	0433h, 0423h, 0000h, 7a00h ;26 - 3 # <52>
        dw	3920h, 3920h, 3920h, 3920h ;29 - SPC <53>	
        dw	0635h, 0625h, 0000h, 7c00h ;2e - 5 % <54>
        dw	0736h, 075eh, 071eh, 7d00h ;36 - 6 ^ <55>
        dw	0837h, 0826h, 0000h, 7e00h ;3d - 7 & <56>
        dw	0938h, 092ah, 0000h, 7f00h ;3e - 8 * <57>
        dw	332ch, 333ch, 0000h, 3300h ;41 - , < <58>
        dw	0b30h, 0b29h, 0000h, 8100h ;45 - 0 ) <59>
        dw	0a39h, 0a28h, 0000h, 8000h ;46 - 9 ( <60>
        dw	342eh, 343eh, 0000h, 3400h ;49 - . > <61>
        dw	352fh, 353fh, 0000h, 3500h ;4a - / ? <62>
        dw	0e02fh, 0e02fh, 9500h, 0a400h ;4a - (e0)KP/ <63>
        dw	273bh, 273ah, 0000h, 2700h ;4c - ; : <64>
        dw	0c2dh, 0c5fh, 0c1fh, 8200h ;4e - - _ <65>
        dw	2827h, 2822h, 0000h, 2800h ;52 - ’ “ <66>
        dw	1a5bh, 1a7bh, 1a1bh, 1a00h ;54 - [ { <67>
        dw	0d3dh, 0d2bh, 0000h, 8300h ;55 - = + <68>	
        dw	1c0dh, 1c0dh, 1c0ah, 1c00h ;5a - Enter, (E0)KPEnter <69>
        dw	1b5dh, 1b7dh, 1b1dh, 1b00h ;5b - ] } <70>
        dw	2b5ch, 2b7ch, 2b1ch, 2b00h ;5d - \ | <71>
        dw	0e08h, 0e08h, 0e7fh, 0e00h ;66 - BKSP <72>
        dw	4f00h, 4f00h, 7500h, 9f00h ;69 - (E0)END <73>
        dw	4b00h, 4b00h, 7300h, 9b00h ;6b - (E0)LEFT <74>
        dw	4700h, 4700h, 7700h, 9700h ;6c - (E0)HOME <75>
        dw	5200h, 5200h, 9200h, 0a200h ;70 - (E0)INS <76>
        dw	5300h, 5300h, 9300h, 0a300h ;71 - (E0)DEL <77>
        dw	5000h, 5000h, 9100h, 0a000h ;72 - (E0)DOWN <78>
        dw	4300h, 5c00h, 6600h, 7000h ;01 - F9 <79>
        dw	4d00h, 4d00h, 7400h, 9d00h ;74 - (E0)RIGHT <80>
        dw	4800h, 4800h, 8d00h, 9800h ;75 - (E0)UP <81>
        dw	011bh, 011bh, 011bh, 0100h ;76 - ESC <82>
        dw	8500h, 8700h, 8900h, 8b00h ;78 - F11 <83>
        dw	4e2bh, 4e2bh, 9000h, 4e00h ;79 - KP+ <84>
        dw	5100h, 5100h, 7600h, 0a100h ;7a - (E0)PGDN <85>
        dw	4a2dh, 4a2dh, 8e00h, 4a00h ;7b - KP- <86>
        dw	372ah, 372ah, 9600h, 3700h ;7c - KP* --- on VMWare, it does not send 3710h with CTL <87>
        dw	4900h, 4900h, 8400h, 9900h ;7d - (E0)PGUP <88>
        dw	4600h, 4600h, 4600h, 4600h ;7e - SCRL <89>
        dw	4100h, 5a00h, 6400h, 6e00h ;83 - F7 <90>

; ------------------------- POWER ON RESET -----------------------
        org     0fff0h
        
        db      0eah
        dw      coldboot, 0f000h
        db      '02/05/13'
        db      0ffh, 0ffh, 0
end bios