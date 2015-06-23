; Project
;    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
;    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
;    The increase in speed comes from a relatively deep pipeline. The original
;    AVR core has only two pipeline stages (fetch and execute), while pAVR has
;    6 pipeline stages:
;       1. PM    (read Program Memory)
;       2. INSTR (load Instruction)
;       3. RFRD  (decode Instruction and read Register File)
;       4. OPS   (load Operands)
;       5. ALU   (execute ALU opcode or access Unified Memory)
;       6. RFWR  (write Register File)
; Version
;    0.32
; Date
;    2002 August 07
; Author
;    Doru Cuturela, doruu@yahoo.com
; License
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


; About this file...
;   This tests all instructions, one by one.



.include "m103def.inc"

   ; Initialize some registers.
   rjmp start

.org 400
start:
   LDI R17, 0x90
   MOV R0,  R17
   MOV R1,  R17
   MOV R2,  R17
   MOV R4,  R17
   MOV R7,  R17
   MOV R12, R17
   MOV R14, R17
   MOV R16, R17
   MOV R18, R17
   MOV R20, R17
   MOV R22, R17
   MOV R23, R17
   MOV R24, R17
   MOV R25, R17
   MOV R26, R17
   MOV R29, R17
   MOV R31, R17
   LDI R28, 0xd5
   MOV R3,  R28
   MOV R5,  R28
   MOV R6,  R28
   MOV R8,  R28
   MOV R9,  R28
   MOV R10, R28
   MOV R11, R28
   MOV R13, R28
   MOV R15, R28
   MOV R19, R28
   MOV R21, R28
   MOV R24, R28
   MOV R27, R28
   MOV R30, R28

   ; These replace original nops, for maintaining absolute addresses used for jumping during the test.
   MOV R0, R0
   MOV R0, R0
   MOV R0, R0
   MOV R0, R0
   MOV R0, R0
   MOV R0, R0

   ADD  R28, R17        ; r28 = d5+90=65 (modulo 256)    SREG=19
   ADC  R25, R28        ; r25 = 90+65+1=f6               SREG=14
   ADIW R25:R24, 0x35   ; r25:r24 = f6:d5+65=f7:0a       SREG=14

   SUB  R23, R24        ; r23 = 90-a=86                  SREG=34
   SUBI R23, 0xf6       ; r23 = 86-f6=90                 SREG=15
   SBC  R26, R23        ; r26 = 90-90-1=ff               SREG=35
   SBIW R27:R26, 0x2d   ; r27:r26 = d5:ff-2d=d5:d2       SREG=34

   ; Intermediate result: r26=0xd2

   INC r26              ; r26=d2+1=d3     SREG=34
   INC r26              ; r26=d3+1=d4     SREG=34
   INC r26              ; r26=d4+1=d5     SREG=34
   INC r26              ; r26=d5+1=d6     SREG=34
   INC r26              ; r26=d6+1=d7     SREG=34
   DEC r26              ; r25=d7-1=d6     SREG=34

   AND   r28, r26       ; r28=65&d6=44    SREG=20
   ANDI  r28, 0x43      ; r28=44&43=40    SREG=20
   OR    r31, r28       ; r31=90|40=d0    SREG=34
   ORI   r31, 0x63      ; r31=d0|63=f3    SREG=34
   EOR   r10, r31       ; r10=d5^f3=26    SREG=20

   ; Intermediate result: r10=0x26

   COM   r10            ; r10=com(26)=d9              SREG=35
   NEG   r10            ; r10=neg(d9)=27, set C       SREG=01
   SEZ                  ;                             SREG=03
   CP    r10, r11       ; (r10<r11)=(27<d5)=1         SREG=01
   MOV   r12, r10       ; r12=27
   DEC   r12            ; r12=26
   SEZ                  ;                             SREG=03
   CPC   r10, r12       ; (r10<r12+1)=(27<26+1)=0     SREG=02
   CPI   r17, 0xab      ; (r17<ab)=(90<ab)=1          SREG=35
   SWAP  r12            ; r12=swap(r12)=62

   LSR r12              ; r12=lsr(r12)=31             SREG=20
   ROR r12              ; r12=ror(r12)=18             SREG=39
   ASR r12              ; r12=asr(r12)=c              SREG=20

   ; Intermediate result: r21=0x0c

   ; Multiplications return zero for now. Test timing only.
   MUL    r10, r10
   MULS   r17, r17
   MULSU  r17, r17
   FMUL   r17, r17
   FMULS  r17, r17
   FMULSU r17, r17

   MOV r0, r12             ; r0=r12=c
   MOV r1, r11             ; r1=r11=d5
   SUB r1, r0              ; r1=r1-r0=c-d5=c9         SREG=34

   ; Intermediate result: r1=0xc9

   OUT  SREG, r1           ; SREG=r1=c9
   BCLR 7                  ; SREG(7)=0; SREG=49
   BCLR 3                  ; SREG(3)=0; SREG=41
   BSET 1                  ; SREG(1)=1; SREG=43
   BSET 4                  ; SREG(4)=1; SREG=53

   ; Configure port A as output.
   LDI R27,  0xFF
   OUT DDRA, R27
   IN  R29, SREG           ; R29=SREG=53
   ; Send R29 to port A.
   OUT PORTA, R29          ; PORTA=R29=53
   CBI PORTA, 0            ; PORTA(0)=0; PORTA=52
   CBI PORTA, 6            ; PORTA(6)=0; PORTA=12
   SBI PORTA, 3            ; PORTA(2)=0; PORTA=1a
   SBI PORTA, 5            ; PORTA(7)=0; PORTA=3a
   IN  R30, PORTA          ; R30=PORTA=3a
   LDI  R31, 0x00          ; R31=0
   ; Test if both IN and LDI correctly update the BPU (IN stalls LDI to steal BPU access).
   SBIW R31:R30, 0x3e      ; R31:R30=R31:R30-3e=00:3a-3e=ff:fc    SREG=55
   BST  R30, 1             ; T=R30(1)=0
   BLD  R30, 6             ; R30(6)=T=0; R30=bc
   MOV  R31, R1            ; R31=c9
   ; Test if both BLD and MOV correctly update the BPU (BLD stalls MOV to steal BPU access).
   ADIW R31:R30, 0x2a      ; R31:R30=R31:R30+2a=c9:bc+2a=c9:e6    SREG=14
   ; Test if both bytes of the result update the BPU.
   ADIW R31:R30, 0x18      ; R31:R30=R31:R30+18=c9:e6+18=c9:fe    SREG=14
   MOV R10, R30

   ; Intermediate result: r10=fe

   ; Set up the stack
   LDI R25, 0x01
   OUT SPH, R25
   LDI R26, 0x1c
   OUT SPL, R26

   MOVW R23:R22, R31:R30      ; R23:R22=R31:R30=c9:fe
   PUSH R22                   ; stack=R22=fe
   POP  R21
   ADD  R21, R12
   ADD  R21, R12
   ADD  R21, R12
   ADD  R21, R12              ; R21=2e

   STS 0x0130, R21
   LDS R22, 0x0130            ; R22=2e
   LDI R31, 0x01              ; R31=1
   LDI R30, 0x23              ; R30=23
   INC R22                    ; R22=R22+1=2e+1=2f
   ST  Z, R22                 ; (Z)=(1:23)=R22=2f
   LD  R21, Z                 ; R21=(Z)=(1:23)=2f

   LDI R17, 0xf9
   MOV R0, R17
   INC R0

   ; Load pointer registers for next tests.
   LDI R27, 0x01              ; X=0140
   LDI R26, 0x40              ;
   LDI R29, 0x01              ; Y=0150
   LDI R28, 0x50              ;
   LDI R31, 0x01              ; Z=0160
   LDI R30, 0x60              ;

   ; Load-stores through X pointer
   ST  X+, R0
   ST  X,  R0
   ADIW R27:R26, 0x02
   ST  -X, R0
   LD  R20, X+
   SBIW R27:R26, 0x02
   LD  R21, X
   LD  R22, -X

   INC R0

   ; Load-stores through Y pointer
   ST  Y+, R0
   ST  Y,  R0
   ADIW R29:R28, 0x02
   ST  -Y, R0
   LD  R20, Y+
   SBIW R29:R28, 0x02
   LD  R21, Y
   LD  R22, -Y

   STD Y+0x3b, R0
   LDD R23, Y+0x3b

   INC R0

   ; Load-stores through Z pointer
   ST  Z+, R0
   ST  Z,  R0
   ADIW R31:R30, 0x02
   ST  -Z, R0
   LD  R20, Z+
   SBIW R31:R30, 0x02
   LD  R21, Z
   LD  R22, -Z

   STD Z+0x3c, R0
   LDD R23, Z+0x3c

   ; Store into Register File.
   LDI R20, 0xaa
   LDI R21, 0xbb
   LDI R27, 00
   LDI R26, 21
   ST  X+, R20
   ; Check if R21=0xaa.

   ; Store into IO File.
   LDI R20, 0xcc
   LDI R31, 0x00
   LDI R30, 0x38
   STD Z+3, R20         ; (3b)=R20=cc (note that PORTA has address 0x3b in the Unified Memory, that is 0x1b in IOF)
   ; Check if PORTA=0xcc

   ; Test LPM family instructions.
   LDI R31, 0x03
   LDI R30, 0x74
   LPM
   LPM R17, Z+
   LPM R18, Z+
   LPM R19, Z

   LDI R31, 0x03
   LDI R30, 0x45
   LDI R17, 0x00
   OUT RAMPZ, R17
   ELPM
   ELPM R17, Z+
   ELPM R18, Z+
   ELPM R19, Z

   ; Jumps ----------------------------

   ; RJMP
   RJMP jmp1
   LDI R19, 0xaa
jmp2:
   LDI R19, 0xbb
   LDI R19, 0xcc
   RJMP jmp3
jmp1:
   LDI R19, 0xdd
   LDI R19, 0xee
   RJMP jmp2
jmp3:
   LDI R19, 0xff              ; R19 = dd, ee, bb, cc, ff

   ; IJMP
   LDI R19, 0x11
   LDI R31, 0x02
   LDI R30, 0x58
   IJMP
jmp5:                ; 0254
   LDI R19, 0x22
   LDI R31, 0x02
   LDI R30, 0x5c
   IJMP
jmp4:                ; 0258
   LDI R19, 0x33
   LDI R31, 0x02
   LDI R30, 0x54
   IJMP
jmp6:                ; 025c
   LDI R19, 0x44
   LDI R31, 0x02
   LDI R30, 0x61
   IJMP
   LDI R19, 0x55
jmp7:                ; 0261
   LDI R19, 0x66              ; R19 = 11, 33, 22, 44, 66

   ; EIJMP
   LDI R19, 0x77
   LDI R17, 0x00
   OUT RAMPZ, R17
   LDI R31, 0x02
   LDI R30, 0x6a
   EIJMP
jmp9:                ; 0268
   LDI R19, 0x88
   RJMP jmp10
jmp8:                ; 026a
   LDI R19, 0x99
   LDI R31, 0x02
   LDI R30, 0x68
   EIJMP
jmp10:               ; 026e
   LDI R19, 0xaa              ; R19 = 77, 99, 88, aa

   ; JMP
   LDI R19, 0x10
   JMP jmp11
   LDI R19, 0x11
jmp12:
   LDI R19, 0x12
   ; Stress the JMP a little bit.
   INC R11
   INC R10
   LDI R17, 0x09
   LDI R20, 0xa2
   LDI R29, 0x00
   LDI R28, 20
   ST Y, R17      ; R20=9
   LD R21, Y      ; R21=9
   JMP jmp13
   LDI R19, 0x13
   LDI R19, 0x14
jmp11:
   LDI R19, 0x15
   ; Stress the JMP a little bit.
   INC R11
   INC R10
   MOVW R11:R10, R25:R24
   JMP jmp12
jmp13:
   LDI R19, 0x16              ; R19 = 10, 15, 12, 16

   ; Skips ----------------------------

   ; CPSE
   LDI R20, 0x10
   LDI R21, 0x10
   LDI R22, 0x11
   LDI R19, 0x21              ; R19 = 21
   CPSE R20, R21
   LDI R19, 0x22
   LDI R19, 0x23              ; R19 = 23
   CPSE R20, R22
   LDI R19, 0x24              ; R19 = 24
   ; Stress CPSE a little bit.
   LDI R31, 0x00
   LDI R30, 19
   CPSE R20, R21
   ST Z+, R0
   ST Z+, R24                 ; R19 = a
   DEC R19                    ; R19 = 9
   CPSE R20, R21
   LD R6, -Z
   LD R7, -Z                  ; R7 = 9
   CPSE R20, R21
   MOVW R19:R18, R5:R4
   LDI R19, 0x25              ; R19 = 25
   CPSE R20, R21
   JMP jmp13
   LDI R19, 0x26              ; R19 = 26
   CPSE R20, R21
   STD Z+0, R23
   STD Z+0, R25               ; R19 = 1

   ; SBRC
   LDI R20, 0x41              ; R20 = 41
   SBRC R20, 6
   LDI R19, 0x30              ; R19 = 30
   SBRC R20, 7
   LDI R19, 0x28
   LDI R19, 0x31              ; R19 = 31
   SBRC R20, 7
   LD R18, Z
   SBRC R20, 7
   STD Z+0, R20
   LDI R19, 0x32              ; R19 = 32
   SBRC R20, 7
   JMP jmp13
   LDI R19, 0x33              ; R19 = 33
   SBRC R20, 7
   MOVW R19:R18, R1:R0
   LDI R19, 0x3d              ; R19 = 3d

   ; SBRS
   LDI R20, 0x92              ; R20 = 92
   SBRS R20, 6
   LDI R19, 0x40              ; R19 = 40
   SBRS R20, 7
   LDI R19, 0x28
   LDI R19, 0x41              ; R19 = 41
   SBRS R20, 7
   LD R18, Z
   SBRS R20, 7
   STD Z+0, R20
   LDI R19, 0x42              ; R19 = 42
   SBRS R20, 7
   JMP jmp13
   LDI R19, 0x43              ; R19 = 43
   SBRS R20, 7
   MOVW R19:R18, R1:R0
   LDI R19, 0x44              ; R19 = 44

   ; SBIC
   LDI R20, 0x41              ; R20 = 41
   OUT PORTA, R20
   SBIC PORTA, 6
   LDI R19, 0x50              ; R19 = 50
   SBIC PORTA, 7
   LDI R19, 0x28
   LDI R19, 0x51              ; R19 = 51
   SBIC PORTA, 7
   LD R18, Z
   SBIC PORTA, 7
   STD Z+0, R20
   LDI R19, 0x52              ; R19 = 52
   SBIC PORTA, 7
   JMP jmp13
   LDI R19, 0x53              ; R19 = 53
   SBIC PORTA, 7
   MOVW R19:R18, R1:R0
   LDI R19, 0x54              ; R19 = 54

   ; SBIS
   LDI R20, 0x92              ; R20 = 92
   OUT PORTA, R20
   SBIS PORTA, 6
   LDI R19, 0x60              ; R19 = 60
   SBIS PORTA, 7
   LDI R19, 0x28
   LDI R19, 0x61              ; R19 = 61
   SBIS PORTA, 7
   LD R18, Z
   SBIS PORTA, 7
   STD Z+0, R20
   LDI R19, 0x62              ; R19 = 62
   SBIS PORTA, 7
   JMP jmp13
   LDI R19, 0x63              ; R19 = 63
   SBIS PORTA, 7
   MOVW R19:R18, R1:R0
   LDI R19, 0x64              ; R19 = 64

   ; Branches -------------------------

   LDI R31, 0x01
   LDI R30, 0x4e
   LDI R16, 0x45
   MOV R3, R16
   LDI R16, 0x03
   MOV R4, R16

   ; BRBC
   LDI R19, 0x70
   OUT SREG, R4
   STD Z+5, R3
   LDD R19, Z+5
   BRBC 2, jmp14
   LDI R19, 0x71
jmp15:
   LDI R19, 0x72
   BRBC 1, jmp14
   LDI R19, 0x73
   rjmp jmp16
jmp14:
   INC R3
   OUT SREG, R4
   STD Z+5, R3
   LDD R19, Z+5
   LDI R19, 0x74
   BRBC 3,  jmp15
   LDI R19, 0x75
jmp16:
   LDI R19, 0x76              ; R19 = 70, 45, 46, 74, 72, 73, 76

   ; BRBS
   LDI R19, 0x80
   OUT SREG, R4
   STD Z+5, R3
   LDD R19, Z+5
   BRBS 1, jmp17
   LDI R19, 0x81
jmp18:
   LDI R19, 0x82
   BRBS 4, jmp14
   LDI R19, 0x83
   rjmp jmp19
jmp17:
   INC R3
   OUT SREG, R4
   STD Z+5, R3
   LDD R19, Z+5
   LDI R19, 0x84
   BRBS 1,  jmp18
   LDI R19, 0x85
jmp19:
   LDI R19, 0x86              ; R19 = 80, 46, 47, 84, 82, 83, 86


   ; Calls and returns ----------------
   RCALL jmp20
   LDI R19, 0xa0
   CALL jmp21
   JMP jmp26

jmp20:
   LDI R19, 0xa1
   STD Z+5, R3
   RET
   STD Z+5, R3

jmp21:
   LDI R19, 0xa3
   RET
   JMP jmp21

jmp22:
   LDI R19, 0xa4
   ADIW R25:R24, 0x35
   RET
   BRBS 4, jmp14

jmp23:
   LDI R19, 0xa5
   CLR R0
   OUT SREG, R0
   BRBS 4, jmp23
   RET
   BRBS 4, jmp23

jmp24:
   LDI R19, 0xa6
   JMP jmp24bis
jmp24bis:
   RET
   JMP jmp24

jmp25:
   LDI R19, 0xa7
   CLR R17
   ELPM R17, Z+
   RET
   CPSE R20, R21

jmp26:
   LDI R19, 0xa8           ; R19 = a1, a0, a3, a8

   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
forever:
   RJMP forever
