;
MACLIB	  Z80
;
	  ORG	    0
;
START	  JMP	    STARTU
	  ;
	  DB	    0FFH
	  DW	    (CHPEND-4)
	  DW	    3212
;
CHIP1ID   DB	    1	      ;CHIP I.D. NUMBER
;
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
	  NOP
	  NOP
	  NOP
	  NOP
	  NOP
	  NOP
	  NOP
	  NOP
	  JMP	    SFTSTART0
;
;
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
	  NOP
	  JMP	    SFTSTART2
;
;
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
	  NOP
	  NOP
IBMVECT
	  DW	    COMMAIN    ;WAS CRTINP    ;ARECEIVE
;
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;
;	  NON MASKABLE INT.
;
	  ORG	    66H       ;TRAP
;
	  JMP	    POWERF
;
;******************************
;
	  ORG	    72H
;

SFTSTART0
SFTSTART2
;
;    POWER UP START UP
;
; @ @ @ USED TO TEST COMM @ @ @
;
STARTU
	  DI

	  LXI	    SP,0DFEAH

	  IM2		      ; SET Z80 INT MODE

	  LXI	    B,0
MAINLOOP
	  EI

	  CALL	    DELAY
	  CALL	    DELAY
	  CALL	    DELAY


	  MOV	    A,C
	  INR	    C

	  OUT	    10H 		; HEX DISPLAY 0,1

	  OUT	    024H		; COMPORT

	  OUT	    002H		; LEDR

	  JMP	    MAINLOOP

;
;
POWERF	  PUSH	    PSW       ;+1  NMSK INT 60 TIMES A SEC
	  PUSH	    B	      ;+2
	  PUSH	    D	      ;+3
	  PUSH	    H	      ;+4
;
	  POP	    H
	  POP	    D
	  POP	    B
	  POP	    PSW
	  RETN
;


;4CH
COMMAIN
	  IN	    24H       ; COMMPORT
	  OUT	    11H       ; HEX DISPLAY
	  EI
	  RET



DELAY	  PUSH	    B
	  LXI	    B,4000H
DELLOP
	  DCR	    C
	  JNZ	    DELLOP
	  DCR	    B
	  JNZ	    DELLOP
	  POP	    B
	  RET

CHPEND	  DW	    0FFFFH
;
	  END	    START
