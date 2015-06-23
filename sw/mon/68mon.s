                ORG     0
                DC.W    0,STACK         ;RESET: initial SSP
                DC.W    0,START         ;RESET: initial PC
                DC.W    0,BUS_ERROR
                DC.W    0,ADRS_ERROR
                DC.W    0,ILLEGAL_INST
                DC.W    0,DIV_ZERO
                DC.W    0,START         ;CHK not implemented
                DC.W    0,TRAP_V
;
                ORG     $7C             ;skip reserved vectors
                DC.W    0,LEVEL_7
                DC.W    0,TO_CHAR_IN    ;TRAP vector 0
                DC.W    0,TO_CHAR_OUT   ;TRAP vector 1
                DC.W    0,TO_CRLF       ;TRAP vector 2
                DC.W    0,TO_PRINT_MSG  ;TRAP vector 3
                DC.W    0,TO_PRINT_BYTE ;TRAP vector 4
                DC.W    0,TO_PRINT_WORD ;TRAP vector 5
                DC.W    0,TO_PRINT_LONG ;TRAP vector 6
                DC.W    0,TO_GET_BYTE   ;TRAP vector 7
                DC.W    0,TO_GET_ADDR   ;TRAP vector 8
                DC.W    0,GETCMD        ;TRAP vector 9
;
                ORG     $400            ;start of monitor
STACK           EQU     $9000
START           MOVEA.L #STACK,A7       ;init stack
                BSR     INIT_ACIA       ;init serial chip
                BSR     SIGN_ON         ;greet user
GETCMD          MOVEA.L #STACK,A7       ;init stack
                BSR     CRLF
                MOVE.B  #'*',D1         ;output command prompt
                BSR     CHAR_OUT
                CLR.L   D2              ;init command-text buffer
                MOVEA.L #$8F00,A6       ;load buffer location
                BSR     GETLINE         ;fill buffer with text
                MOVEA.L #$8F00,A6       ;reset buffer pointer
                BSR     SKIP_BLK        ;skip leading blanks
INCOM           MOVE.B  (A6)+,D1
                BSR     UPPER_CASE
                CMPI.B  #$0D,D1
                BEQ     SEARCH
                CMPI.B  #$20,D1         ;test for SP
                BEQ     SEARCH
                ROL.L   #8,D2           ;prepare D2 for new letter
                MOVE.B  D1,D2           ;insert it into D2
                BRA     INCOM           ;get next letter
SEARCH          MOVE.L  #5,D5           ;number of commands to check
                MOVEA.L #COMMANDS,A2    ;init command text pointer
                MOVEA.L #COM_ADRS,A1    ;init command address pointer
TEST_NEXT       CMP.L   (A2),D2         ;compare command text
                BEQ     DO_JUMP         ;branch if match
                ADDQ.L  #4,A2           ;point to abbreviated command
                CMP.L   (A2),D2         ;test again
                BEQ     DO_JUMP
                ADDQ.L  #4,A2           ;point to next command
                ADDQ.L  #4,A1           ;point to next address
                SUBQ.L  #1,D5           ;all commands checked yet?
                BNE     TEST_NEXT
                BRA     ERROR           ;illegal command entered
DO_JUMP         MOVEA.L (A1),A1         ;get command address
                JMP     (A1)            ;and go execute command
COMMANDS        DC.B   'DUMP'           ;full command name
                DC.B    0,0,0           ;abbreviated name
                DC.B   'D'
                DC.B   'GO  '
                DC.B    0,0,0
                DC.B   'G'
                DC.B   'EDIT'
                DC.B    0,0,0
                DC.B   'E'
                DC.B   'MOVE'
                DC.B    0,0,0
                DC.B   'M'
                DC.B   'HELP'
                DC.B    0,0,0
                DC.B   'H'
COM_ADRS        DC.W    0,DUMP          ;DUMP execution address
                DC.W    0,GO
                DC.W    0,EDIT
                DC.W    0,MOOV
                DC.W    0,HELP
;
DUMP            BSR     GET_ADDR        ;get the starting address
                ANDI.B  #$F0,D2         ;make lower nibble zero
                MOVEA.L D2,A4           ;A4 is memory read register
                BSR     GET_ADDR        ;get the ending address
                MOVEA.L D2,A5
ADR_OUT         BSR     CRLF            ;new line please
                MOVE.L  A4,D2           ;print address
                BSR     PRINT_LONG
                BSR     BLANK           ;and some blanks
                BSR     BLANK
BYTE_OUT        MOVE.B  (A4)+,D2        ;get a byte and increment A4
                BSR     PRINT_BYTE      ;print the byte
                BSR     BLANK
                MOVE.L  A4,D1           ;done 16 yet?
                ANDI.L  #$0F,D1
                BNE     BYTE_OUT
                SUBA.L  #16,A4          ;back up 16 bytes
                BSR     BLANK
ASCII_OUT       MOVE.B  (A4)+,D1        ;get a byte
                ANDI.B  #$7F,D1
                CMPI.B  #$20,D1         ;is it printable?
                BMI     UN_PRINT
                CMPI.B  #$7D,D1
                BMI     SEND_IT
UN_PRINT        MOVE.B  #$2E,D1         ;use period for unprintables
SEND_IT         BSR     CHAR_OUT        ;print the ASCII equivalent
                MOVE.L  A4,D2           ;done 16 yet?
                ANDI.L  #$0F,D2
                BNE     ASCII_OUT
                BSR     FREEZE          ;hold display?
                CMPA.L  A4,A5           ;done with dump?
                BMI     GETCMD
                BRA     ADR_OUT
;
GO              BSR     GET_ADDR        ;get execution address
                MOVEA.L D2,A1
                JMP     (A1)
;
MOOV            BSR     GET_ADDR        ;get starting address
                MOVEA.L D2,A1
                BSR     GET_ADDR        ;get ending address
                MOVEA.L D2,A2
                ADDA.L  #1,A2           ;include last location
                BSR     GET_ADDR        ;get destination address
                MOVEA.L D2,A3
MOOVEM          MOVE.B  (A1)+,(A3)+     ;move and increment pointers
                CMPA.L  A1,A2           ;at ending address yet?
                BNE     MOOVEM
                BRA     GETCMD
;
EDIT            BSR     GET_ADDR        ;get starting address
                MOVEA.L D2,A2           ;A2 is the memory pointer
NEW_DATA        BSR     CRLF            ;new line please
                MOVE.L  A2,D2           ;print data address
                BSR     PRINT_LONG
                BSR     BLANK
                MOVE.B  (A2),D2         ;get the data
                BSR     PRINT_BYTE      ;and show it
                MOVE.B  #'?',D1         ;output change prompt
                BSR     CHAR_OUT
                BSR     GET_BYTE_T      ;get new data
                CMPI.B  #'*',D2         ;no change requested?
                BNE     ENTER_IT        ;jump if new data entered
                MOVE.B  (A2),D1         ;get old data back
ENTER_IT        MOVE.B  D1,(A2)+        ;save data and increment pointer
                BSR     NEW_DATA
;
INIT_ACIA       MOVEA.L #$10000,A0      ;point to ACIA Control reg.
                MOVE.B  #3,(A0)         ;ACIA master reset
                MOVE.B  #$15,(A0)       ;select options
                RTS
;
INSTAT          MOVEA.L #$10000,A0      ;point to ACIA Status reg.
                MOVE.B  (A0),D0         ;get ACIA status
                ANDI.B  #1,D0           ;test RRDY bit
                RTS
;
CHAR_IN         BSR     INSTAT          ;check receiver status
                BEQ     CHAR_IN         ;loop if no character waiting
                MOVEA.L #$10002,A0      ;point to ACIA Data reg.
                MOVE.B  (A0),D1         ;get the ASCII character
                ANDI.B  #$7F,D1         ;strip off MSB
                RTS
;
CHAR_OUT        MOVEA.L #$10000,A0      ;point to ACIA Status reg.
CHAR_OUT2       MOVE.B  (A0),D0         ;read the ACIA status
                ANDI.B  #2,D0           ;check the TRDY bit
                BEQ     CHAR_OUT2       ;loop if not ready
                MOVEA.L #$10002,A0      ;point to ACIA Data reg.
                MOVE.B  D1,(A0)         ;send the character
                RTS
;
CRLF            MOVE.B  #$0D,D1         ;send ASCII CR
                BSR     CHAR_OUT
                MOVE.B  #$0A,D1         ;send ASCII LF
                BSR     CHAR_OUT
                RTS
;
BLANK           MOVE.B  #$20,D1         ;send ASCII SP
                BSR     CHAR_OUT
                RTS
;
PRINT_MSG       MOVE.B  (A3),D1         ;get a character
                CMP.B   #0,D1           ;end of message?
                BEQ     PRINT_MSG2
                BSR     CHAR_OUT        ;send character to display
                ADDQ.L  #1,A3           ;point to next character
                BRA     PRINT_MSG
PRINT_MSG2      RTS
;
SIGN_ON         MOVEA.L #HELLO,A3       ;get starting message address
                BSR     PRINT_MSG       ;send the message
                RTS
;
PRINT_BYTE      MOVE.L  D2,D1           ;init conversion register
                ROL.B   #4,D1           ;look at upper nibble first
                BSR     TO_ASCII        ;print ASCII equivalent
                MOVE.L  D2,D1           ;repeat for lower nibble
TO_ASCII        ANDI.B  #$0F,D1         ;strip off upper nibble
                ADDI.B  #$30,D1         ;add ASCII bias
                CMPI.B  #$3A,D1         ;test for alpha conversion
                BMI     NO_ADD
                ADDI.B  #7,D1           ;correct to 41H-47H (A-F)
NO_ADD          BSR     CHAR_OUT        ;send character
                RTS
;
PRINT_WORD      ROL.W   #8,D2           ;get upper 8 bits
                BSR     PRINT_BYTE      ;output first two characters
                ROL.W   #8,D2           ;now do the lower 8 bits
                BSR     PRINT_BYTE
                RTS
;
PRINT_LONG      SWAP    D2              ;get upper 16 bits
                BSR     PRINT_WORD      ;do 4 character conversion
                SWAP    D2              ;and repeat for lower word
                BSR     PRINT_WORD
                RTS
;
VALDIG          CMPI.B  #'G',D1         ;greater than F?
                BPL     ERROR
                CMPI.B  #'0',D1         ;less than 0?
                BMI     ERROR
                CMPI.B  #'9'+1,D1       ;is it now A-F?
                BPL     NEXT_TST
                RTS                     ;range is 0-9
NEXT_TST        CMPI.B  #'A',D1         ;less than A?
                BMI     ERROR
                RTS                     ;range is A-F
;
ERROR           MOVEA.L #WHAT,A3        ;get message pointer
                BSR     PRINT_MSG
                BRA     GETCMD          ;restart monitor program
WHAT            DC.B    $0D,$0A         ;newline
                DC.B   'What?'
                DC.B    $0D,$0A,0       ;newline and end characters
;
TO_HEX          SUBI.B  #$30,D1         ;remove ASCII bias
                CMPI.B  #$0A,D1         ;0-9?
                BMI     FIN_CONV
                SUBI.B  #7,D1           ;remove alpha bias
FIN_CONV        RTS
;
GET_BYTE_T      MOVEA.L #$8F00,A6       ;TRAP entry point
                BSR     GETLINE
                MOVEA.L #$8F00,A6
GET_BYTE        BSR     SKIP_BLK        ;MON entry point
                MOVE.B  (A6)+,D1        ;get first digit
                BSR     UPPER_CASE
                CMPI.B  #$0D,D1         ;test for CR
                BEQ     NO_CHAN
                CMPI.B  #$20,D1         ;test for SP
                BEQ     NO_CHAN
                BSR     VALDIG          ;check for valid digit
                BSR     TO_HEX          ;convert into hex
                ROL.B   #4,D1           ;move first digit
                MOVE.B  D1,D2           ;save first digit
                MOVE.B  (A6)+,D1        ;get second digit
                BSR     UPPER_CASE
                BSR     VALDIG          ;check for valid digit
                BSR     TO_HEX          ;convert into hex
                ADD.B   D2,D1           ;form final result
                MOVE.B  #'0',D2         ;change entered
                RTS
NO_CHAN         MOVE.B  #'*',D2         ;no change character
                RTS
;
GET_ADDR_T      MOVEA.L #$8F00,A6
                BSR     GETLINE
                MOVEA.L #$8F00,A6
GET_ADDR        BSR     SKIP_BLK
                CLR.L   D1              ;init temp register
                CLR.L   D2              ;init result register
NEXT_CHAR       MOVE.B  (A6)+,D1        ;get a character
                BSR     UPPER_CASE
                CMPI.B  #$0D,D1         ;exit if CR
                BEQ     EXIT_ADR
                CMPI.B  #$20,D1         ;exit if SP
                BEQ     EXIT_ADR
                BSR     VALDIG          ;test for valid digit
                BSR     TO_HEX          ;convert digit into hex
                ROL.L   #4,D2           ;prepare D2 for new digit
                ANDI.B  #$F0,D2
                ADD.B   D1,D2           ;insert new digit
                BRA     NEXT_CHAR       ;and continue
EXIT_ADR        RTS
;
PANIC           BSR     INSTAT          ;check for key
                BEQ     EXIT_BRK        ;return if none hit
TEST_KEY        BSR     CHAR_IN         ;get key
TEST_KEY2       CMPI.B  #3,D1           ;Control-C?
                BEQ     GETCMD          ;if yes, restart monitor
EXIT_BRK        RTS
;
FREEZE          BSR     INSTAT          ;check for key
                BEQ     EXIT_FREZ       ;return if none hit
                BSR     CHAR_IN         ;get key
                CMPI.B  #$13,D1         ;Control-S?
                BEQ     HOLD_IT
                BRA     TEST_KEY2       ;Control-C?
EXIT_FREZ       RTS
HOLD_IT         BSR     INSTAT          ;wait for another key
                BEQ     HOLD_IT
                BRA     TEST_KEY        ;let PANIC check for Control-C
;
UPPER_CASE      CMPI.B  #'a',D1         ;check for lower case
                BMI     NO_CHG
                CMPI.B  #'z'+1,D1       ;first code after 'z'
                BPL     NO_CHG
                ANDI.B  #$DF,D1         ;switch to upper case
NO_CHG          RTS
;
GETLINE         MOVEA.L A6,A5           ;copy pointer
GETLINE2        MOVEA.L A5,A6           ;reset pointer and
                CLR.B   D6              ;counter for scraped lines
GET_CHARS       BSR     CHAR_IN         ;get character
                CMPI.B  #$0D,D1         ;CR ends get line
                BEQ     EXIT
                CMPI.B  #$08,D1         ;back space key and the
                BEQ     BKSPS           ;delete key are
CHECK_DELETE    CMPI.B  #$7F,D1         ;back space keys
                BEQ     BKSPS
                CMPI.B  #$15,D1         ;check for ^U and scrap the
                BEQ     LINE_REDO       ;line if encountered
                MOVE.B  D1,(A6)+        ;otherwise place character
                ADDQ.B  #1,D6           ;in buffer, update counter and
                BSR     CHAR_OUT            ;echo it to the screen
                BRA     GET_CHARS       ;get another character
EXIT            MOVE.B  D1,(A6)         ;on exit place $0D in buffer and
                ADDQ.B  #1,D6           ;count it
                BSR     CRLF
                RTS
LINE_REDO       BSR     CRLF            ;clean up the screen
                BRA     GETLINE2        ;start over
BKSPS           CMPI.B  #0,D6
                BEQ     GET_CHARS
                SUBQ.B  #1,D6
                SUBA.L  #1,A6
                MOVE.B  #8,D1
                BSR     CHAR_OUT
                MOVE.B  #' ',D1
                BSR     CHAR_OUT
                MOVE.B  #8,D1
                BSR     CHAR_OUT
                BRA     GET_CHARS
;
SKIP_BLK        CMPI.B  #' ',(A6)
                BNE     EXIT_SKIP
                ADDA.L  #1,A6
                BRA     SKIP_BLK
EXIT_SKIP       RTS
;
BUS_ERROR       MOVEA.L #MSG_1,A3
                BRA     REPORT
ADRS_ERROR      MOVEA.L #MSG_2,A3
                BRA     REPORT
ILLEGAL_INST    MOVEA.L #MSG_3,A3
                BRA     REPORT
DIV_ZERO        MOVEA.L #MSG_4,A3
                BRA     REPORT
TRAP_V          MOVEA.L #MSG_5,A3
                BRA     REPORT
LEVEL_7         MOVEA.L #MSG_6,A3
                BRA     REPORT
TO_CHAR_IN      BSR     CHAR_IN
                RTE
TO_CHAR_OUT     BSR     CHAR_OUT
                RTE
TO_CRLF         BSR     CRLF
                RTE
TO_PRINT_MSG    BSR     PRINT_MSG
                RTE
TO_PRINT_BYTE   BSR     PRINT_BYTE
                RTE
TO_PRINT_WORD   BSR     PRINT_WORD
                RTE
TO_PRINT_LONG   BSR     PRINT_LONG
                RTE
TO_GET_BYTE     BSR     GET_BYTE_T
                RTE
TO_GET_ADDR     BSR     GET_ADDR_T
                RTE
HELP            MOVEA.L #H_MSG1,A3
REPORT          BSR     CRLF            ;new line thank you
                BSR     PRINT_MSG       ;print message pointed to by A3
                BSR     CRLF
                BRA     GETCMD

MSG_1           DC.B    'Bus Error',0
MSG_2           DC.B    'Address Error',0
MSG_3           DC.B    'Illegal Instruction Error',0
MSG_4           DC.B    'Divide by Zero Error',0
MSG_5           DC.B    'TRAPV Overflow',0
MSG_6           DC.B    'Level-7 Interrupt',0

HELLO           DC.B    $0D,$0A         ;newline
                DC.B   '68000 Monitor, Version 7.5, C1995 JLACD'
                DC.B    $0D,$0A,0       ;newline and end characters

H_MSG1          DC.B    $0D,$0A,$0D,$0A
                DC.B    '*** 68000 Cpu-based Single Board Computer ***'
                DC.B    $0D,$0A
                DC.B    'Command Syntax         Action'
                DC.B    $0D,$0A,$0D,$0A
                DC.B    'DUMP 400 44F           Display memory contents'
                DC.B    $0D,$0A
                DC.B    '                       Ctrl-S freezes display'
                DC.B    $0D,$0A
                DC.B    '                       Any key restarts display'
                DC.B    $0D,$0A
                DC.B    '                       Ctrl-C cancels dump'
                DC.B    $0D,$0A,$0D,$0A
                DC.B    'EDIT 8000              Load RAM starting at 8000'
                DC.B    $0D,$0A
                DC.B    '                       Use CR or blank to keep data'
                DC.B    $0D,$0A
                DC.B    '                       Ctrl-C cancels patching'
                DC.B    $0D,$0A,$0D,$0A
                DC.B    'GO 8000                Execute program at 8000'
                DC.B    $0D,$0A,$0D,$0A
                DC.B    'MOVE 8000 80FF 8100    Move memory contents'
                DC.B    $0D,$0A,$0D,$0A
                DC.B    'All commands may be shortened to single letters.'
                DC.B    $0D,$0A
                DC.B    'Use D, E, G, M, or H. Lower case characters'
                DC.B    $0D,$0A
                DC.B    'as well.'
                DC.B    $0D,$0A,$0D,$0A
                DC.B    'This 68000 system was designed and programmed by'
                DC.B    $0D,$0A
                DC.B    'James Antonakos, Alan Dixon and Donovan McCarty.'
                DC.B    $0D,$0A,0
                END     START

