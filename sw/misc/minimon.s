*        Simplified version of a 68000 monitor
*        Designed to run with the Teesside 68K simulator
*        Version of 3 October 1996
*                                   Symbol equates 
BS       EQU      $08               Back_space 
CR       EQU      $0D               Carriage_return 
LF       EQU      $0A               Line_feed 
SPACE    EQU      $20               Space 
WAIT     EQU      'W'               Wait character (to suspend output) 
CTRL_A   EQU      $01               Control_A forces return to monitor 
*                                   Device addresses 
X_BASE   EQU      $08               Start of exception vector table 
TRAP_14  EQU      $4E4E             Code for TRAP #14 
MAXCHR   EQU      64                Length of input line buffer  
* 
DATA     EQU      $00000400         Data origin 
LNBUFF   DS.B     MAXCHR            Input line buffer
BUFFEND  EQU      LNBUFF+MAXCHR-1   End of line buffer 
BUFFPT   DS.L     1                 Pointer to line buffer 
PARAMTR  DS.L     1                 Last parameter from line buffer 
ECHO     DS.B     1                 When clear this enable input echo 
U_CASE   DS.B     1                 Flag for upper case conversion 
TSK_T    DS.W     37                Frame for D0-D7, A0-A6, USP, SSP, SW, PC 
BP_TAB   DS.W     24                Breakpoint table 
* 
************************************************************************* 
* 
*  This is the main program which assembles a command in the line 
*  buffer, removes leading/embedded spaces and interprets it by matching 
*  it with a command in the user table or the built-in table COMTAB 
*  All variables are specified with respect to A6 
* 
         ORG      $00001000         Monitor origin 
RESET    EQU      *                 Cold entry point for monitor 
         LEA.L    DATA,A6           A6 points to data area 
         MOVE.B   #1,ECHO(A6)       No automatic character echo 
         CLR.B    U_CASE(A6)        Clear case conversion flag (UC<-LC) 
         BSR      X_SET             Setup exception table 
         LEA.L    BANNER(PC),A4     Point to banner 
         BSR.S    HEADING           and print heading 
WARM     CLR.L    D7                Warm entry point - clear error flag 
         BSR.S    NEWLINE           Print a newline 
         BSR.S    GETLINE           Get a command line 
         BSR      EXECUTE           Interpret command 
         BRA      WARM              Repeat indefinitely 
* 
************************************************************************* 
* 
*  Some initialization and basic routines 
* 
NEWLINE  EQU      *                 Move cursor to start of newline 
         MOVEM.L  A4,-(A7)          Save A4 
         LEA.L    CRLF(PC),A4       Point to CR/LF string 
         BSR.S    PSTRING           Print it 
         MOVEM.L  (A7)+,A4          Restore A4 
         RTS                        Return 
* 
PSTRING  EQU      *                 Display the string pointed at by A4 
         MOVE.L   D0,-(A7)          Save D0 
PS1      MOVE.B   (A4)+,D0          Get character to be printed 
         BEQ.S    PS2               If null then return 
         BSR      PUTCHAR           Else print it 
         BRA      PS1               Continue 
PS2      MOVE.L   (A7)+,D0          Restore D0 and exit 
         RTS 
* 
HEADING  BSR      NEWLINE           Same as PSTRING but with newline 
         BSR      PSTRING 
         BRA      NEWLINE 
* 
************************************************************************* 
* 
*  GETLINE  inputs a string of characters into a line buffer 
*           A3 points to next free entry in line buffer 
*           A2 points to end of buffer 
*           A1 points to start of buffer 
*           D0 holds character to be stored 
* 
GETLINE  LEA.L    LNBUFF(A6),A1     A1 points to start of line buffer 
         LEA.L    (A1),A3           A3 points to start (initially) 
         LEA.L    MAXCHR(A1),A2     A2 points to end of buffer 
GETLN2   BSR      GETCHAR           Get a character 
         CMP.B    #CTRL_A,D0        If control_A then reject this line 
         BEQ.S    GETLN5            and get another line 
         CMP.B    #BS,D0            If back_space then move back pointer 
         BNE.S    GETLN3            Else skip past wind-back routine 
         CMP.L    A1,A3             First check for empty buffer 
         BEQ      GETLN2            If buffer empty then continue 
         LEA      -1(A3),A3         Else decrement buffer pointer 
         BRA      GETLN2            and continue with next character 
GETLN3   MOVE.B   D0,(A3)+          Store character and update pointer 
         CMP.B    #CR,D0            Test for command terminator 
         BNE.S    GETLN4            If not CR then skip past exit 
         BRA      NEWLINE           Else new line before next operation 
GETLN4   CMP.L    A2,A3             Test for buffer overflow 
         BNE      GETLN2            If buffer not full then continue 
GETLN5   BSR      NEWLINE           Else move to next line and 
         BRA      GETLINE           repeat this routine 
* 
************************************************************************* 
* 
*  EXECUTE matches the first command in the line buffer with the 
*  commands in a command table.
* 
EXECUTE  LEA.L    COMTAB(PC),A3     Try built-in command table 
         BSR.S    SEARCH            Look for command in built-in table 
         BCS.S    EXEC2             If found then execute command 
         LEA.L    ERMES2(PC),A4     Else print "invalid command" 
         BRA.L    PSTRING           and return 
EXEC2    MOVE.L   (A3),A3           Get the relative command address 
         LEA.L    COMTAB(PC),A4     pointed at by A3 and add it to 
         ADD.L    A4,A3             the PC to generate the actual 
*        JMP      (A3)              command address. Then execute it.
         LEA      LNBUFF,A2
E3       MOVE.B   (A2)+,D0
         CMP.B    #$20,D0
         BNE      E3
         MOVE.L   A2,BUFFPT(A6)
         JMP      (A3)
* 
SEARCH   EQU      *                 Match the command in the line buffer 
         CLR.L    D0                with command table pointed at by A3 
         MOVE.B   (A3),D0           Get the first character in the 
         BEQ.S    SRCH7             current entry. If zero then exit 
         LEA.L    6(A3,D0.W),A4     Else calculate address of next entry 
         MOVE.B   1(A3),D1          Get number of characters to match 
         LEA.L    LNBUFF(A6),A5     A5 points to command in line buffer 
         MOVE.B   2(A3),D2          Get first character in this entry 
         CMP.B    (A5)+,D2          from the table and match with buffer 
         BEQ.S    SRCH3             If match then try rest of string 
SRCH2    MOVE.L   A4,A3             Else get address of next entry 
         BRA      SEARCH            and try the next entry in the table 
SRCH3    SUB.B    #1,D1             One less character to match 
         BEQ.S    SRCH6             If match counter zero then all done 
         LEA.L    3(A3),A3          Else point to next character in table 
SRCH4    MOVE.B   (A3)+,D2          Now match a pair of characters 
         CMP.B    (A5)+,D2 
         BNE      SRCH2             If no match then try next entry 
         SUB.B    #1,D1             Else decrement match counter and 
         BNE      SRCH4             repeat until no chars left to match 
SRCH6    LEA.L    -4(A4),A3         Calculate address of command entry 
         OR.B     #1,CCR            point. Mark carry flag as success 
         RTS                        and return 
SRCH7    AND.B    #$FE,CCR          Fail - clear carry to indicate 
         RTS                        command not found and return 
* 
************************************************************************* 
* 
*  Basic input routines 
*  HEX    =  Get one   hexadecimal character  into D0 
*  BYTE   =  Get two   hexadecimal characters into D0 
*  WORD   =  Get four  hexadecimal characters into D0 
*  LONGWD =  Get eight hexadecimal characters into D0 
*  PARAM  =  Get a longword from the line buffer into D0 
*  Bit 0 of D7 is set to indicate a hexadecimal input error 
* 
HEX      BSR      GETCHAR           Get a character from input device 
         SUB.B    #$30,D0           Convert to binary 
         BMI.S    NOT_HEX           If less than $30 then exit with error 
         CMP.B    #$09,D0           Else test for number (0 to 9) 
         BLE.S    HEX_OK            If number then exit - success 
         SUB.B    #$07,D0           Else convert letter to hex 
         CMP.B    #$0F,D0           If character in range "A" to "F" 
         BLE.S    HEX_OK            then exit successfully 
NOT_HEX  OR.B     #1,D7             Else set error flag 
HEX_OK   RTS                        and return 
* 
BYTE     MOVE.L   D1,-(A7)          Save D1 
         BSR      HEX               Get first hex character 
         ASL.B    #4,D0             Move it to MS nybble position 
         MOVE.B   D0,D1             Save MS nybble in D1 
         BSR      HEX               Get second hex character 
         ADD.B    D1,D0             Merge MS and LS nybbles 
         MOVE.L   (A7)+,D1          Restore D1 
         RTS 
* 
WORD     BSR      BYTE              Get upper order byte 
         ASL.W    #8,D0             Move it to MS position 
         BRA      BYTE              Get LS byte and return 
* 
LONGWD   BSR      WORD              Get upper order word 
         SWAP     D0                Move it to MS position 
         BRA      WORD              Get lower order word and return 
* 
*  PARAM reads a parameter from the line buffer and puts it in both 
*  PARAMTR(A6) and D0. Bit 1 of D7 is set on error. 
* 
PARAM    MOVE.L   D1,-(A7)          Save D1 
         CLR.L    D1                Clear input accumulator 
         MOVE.L   BUFFPT(A6),A0     A0 points to parameter in buffer 
PARAM1   MOVE.B   (A0)+,D0          Read character from line buffer 
         CMP.B    #SPACE,D0         Test for delimiter 
         BEQ.S    PARAM4            The permitted delimiter is a 
         CMP.B    #CR,D0            space or a carriage return 
         BEQ.S    PARAM4            Exit on either space or C/R 
         ASL.L    #4,D1             Shift accumulated result 4 bits left 
         SUB.B    #$30,D0           Convert new character to hex 
         BMI.S    PARAM5            If less than $30 then not-hex 
         CMP.B    #$09,D0           If less than 10 
         BLE.S    PARAM3            then continue 
         SUB.B    #$07,D0           Else assume $A - $F 
         CMP.B    #$0F,D0           If more than $F 
         BGT.S    PARAM5            then exit to error on not-hex 
PARAM3   ADD.B    D0,D1             Add latest nybble to total in D1 
         BRA      PARAM1            Repeat until delimiter found 
PARAM4   MOVE.L   A0,BUFFPT(A6)     Save pointer in memory 
         MOVE.L   D1,PARAMTR(A6)    Save parameter in memory 
         MOVE.L   D1,D0             Put parameter in D0 for return 
         BRA.S    PARAM6            Return without error 
PARAM5   OR.B     #2,D7             Set error flag before return 
PARAM6   MOVE.L   (A7)+,D1          Restore working register 
         RTS                        Return with error 
* 
************************************************************************* 
* 
*  Output routines 
*  OUT1X   = print one   hexadecimal character 
*  OUT2X   = print two   hexadecimal characters 
*  OUT4X   = print four  hexadecimal characters 
*  OUT8X   = print eight hexadecimal characters 
*  In each case, the data to be printed is in D0 
* 
OUT1X    MOVE.W   D0,-(A7)          Save D0 
         AND.B    #$0F,D0           Mask off MS nybble 
         ADD.B    #$30,D0           Convert to ASCII 
         CMP.B    #$39,D0           ASCII = HEX + $30 
         BLS.S    OUT1X1            If ASCII <= $39 then print and exit 
         ADD.B    #$07,D0           Else ASCII := HEX + 7 
OUT1X1   BSR      PUTCHAR           Print the character 
         MOVE.W   (A7)+,D0          Restore D0 
         RTS 
* 
OUT2X    ROR.B    #4,D0             Get MS nybble in LS position 
         BSR      OUT1X             Print MS nybble 
         ROL.B    #4,D0             Restore LS nybble 
         BRA      OUT1X             Print LS nybble and return 
* 
OUT4X    ROR.W    #8,D0             Get MS byte in LS position 
         BSR      OUT2X             Print MS byte 
         ROL.W    #8,D0             Restore LS byte 
         BRA      OUT2X             Print LS byte and return 
* 
OUT8X    SWAP     D0                Get MS word in LS position 
         BSR      OUT4X             Print MS word 
         SWAP     D0                Restore LS word 
         BRA      OUT4X             Print LS word and return 
* 
************************************************************************* 
* 
* JUMP causes execution to begin at the address in the line buffer 
* 
JUMP     BSR     PARAM              Get address from buffer 
         TST.B   D7                 Test for input error 
         BNE.S   JUMP1              If error flag not zero then exit 
         TST.L   D0                 Else test for missing address 
         BEQ.S   JUMP1              field. If no address then exit 
         MOVE.L  D0,A0              Put jump address in A0 and call the 
         JMP     (A0)               subroutine. User to supply RTS!! 
JUMP1    LEA.L   ERMES1(PC),A4      Here for error - display error 
         BRA     PSTRING            message and return 
* 
************************************************************************* 
* 
*  Display the contents of a memory location and modify it 
* 
MEMORY   BSR      PARAM             Get start address from line buffer 
         TST.B    D7                Test for input error 
         BNE.S    MEM3              If error then exit 
         MOVE.L   D0,A3             A3 points to location to be opened 
MEM1     BSR      NEWLINE 
         BSR.S    ADR_DAT           Print current address and contents 
         BSR.S    PSPACE             update pointer, A3, and O/P space 
         BSR      GETCHAR           Input char to decide next action 
         CMP.B    #CR,D0            If carriage return then exit 
         BEQ.S    MEM3              Exit 
         CMP.B    #'-',D0           If "-" then move back 
         BNE.S    MEM2              Else skip wind-back procedure 
         LEA.L    -4(A3),A3         Move pointer back 2+2 
         BRA      MEM1              Repeat until carriage return 
MEM2     CMP.B    #SPACE,D0         Test for space (= new entry) 
         BNE.S    MEM1              If not space then repeat 
         BSR      WORD              Else get new word to store 
         TST.B    D7                Test for input error 
         BNE.S    MEM3              If error then exit 
         MOVE.W   D0,-2(A3)         Store new word 
         BRA      MEM1              Repeat until carriage return 
MEM3     RTS 
* 
ADR_DAT  MOVE.L   D0,-(A7)          Print the contents of A3 and the 
         MOVE.L   A3,D0             word pointed at by A3. 
         BSR      OUT8X              and print current address 
         BSR.S    PSPACE            Insert delimiter 
         MOVE.W   (A3),D0           Get data at this address in D0 
         BSR      OUT4X              and print it 
         LEA.L    2(A3),A3          Point to next address to display 
         MOVE.L   (A7)+,D0          Restore D0 
         RTS 
* 
PSPACE   MOVE.B   D0,-(A7)          Print a single space 
         MOVE.B   #SPACE,D0 
         BSR      PUTCHAR 
         MOVE.B   (A7)+,D0 
         RTS 
* 
************************************************************************* 
* 
*  LOAD  Loads data formatted in hexadecimal "S" format 
*         
LOAD     MOVE.L   BUFFPT(A6),A4     Any string in the line buffer is 
LOAD1    MOVE.B   (A4)+,D0          transmitted to the host computer 
         BSR      PUTCHAR           before the loading begins 
         CMP.B    #CR,D0            Read from the buffer until EOL 
         BNE      LOAD1 
         BSR      NEWLINE           Send newline before loading 
LOAD2    BSR      GETCHAR           Records from the host must begin 
         CMP.B    #'S',D0           with S1/S2 (data) or S9/S8 (term) 
         BNE.S    LOAD2             Repeat GETCHAR until char = "S" 
         BSR      GETCHAR           Get character after "S" 
         CMP.B    #'9',D0           Test for the two terminators S9/S8 
         BEQ.S    LOAD3             If S9 record then exit else test 
         CMP.B    #'8',D0           for S8 terminator. Fall through to 
         BNE.S    LOAD6             exit on S8 else continue search 
LOAD3    EQU      *                 Exit point from LOAD 
         BTST.B   #0,D7             Test for input errors 
         BEQ.S    LOAD4             If no I/P error then look at checksum 
         LEA.L    ERMES1(PC),A4     Else point to error message 
         BSR      PSTRING           Print it 
LOAD4    BTST.B   #3,D7             Test for checksum error 
         BEQ.S    LOAD5             If clear then exit 
         LEA.L    ERMES3(PC),A4     Else point to error message 
         BSR      PSTRING           Print it and return 
LOAD5    RTS 
* 
LOAD6    CMP.B    #'1',D0           Test for S1 record 
         BEQ.S    LOAD6A            If S1 record then read it 
         CMP.B    #'2',D0           Else test for S2 record 
         BNE.S    LOAD2             Repeat until valid header found 
         CLR.B    D3                Read the S2 byte count and address, 
         BSR.S    LOAD8             clear the checksum 
         SUB.B    #4,D0             Calculate size of data field 
         MOVE.B   D0,D2             D2 contains data bytes to read 
         CLR.L    D0                Clear address accumulator 
         BSR.S    LOAD8             Read most sig byte of address 
         ASL.L    #8,D0             Move it one byte left 
         BSR.S    LOAD8             Read the middle byte of address 
         ASL.L    #8,D0             Move it one byte left 
         BSR.S    LOAD8             Read least sig byte of address 
         MOVE.L   D0,A2             A2 points to destination of record 
         BRA.S    LOAD7             Skip past S1 header loader 
LOAD6A   CLR.B    D3                S1 record found - clear checksum 
         BSR.S    LOAD8             Get byte and update checksum 
         SUB.B    #3,D0             Subtract 3 from record length 
         MOVE.B   D0,D2             Save byte count in D2 
         CLR.L    D0                Clear address accumulator 
         BSR.S    LOAD8             Get MS byte of load address 
         ASL.L    #8,D0             Move it to MS position 
         BSR.S    LOAD8             Get LS byte in D2 
         MOVE.L   D0,A2             A2 points to destination of data 
LOAD7    BSR.S    LOAD8             Get byte of data for loading 
         MOVE.B   D0,(A2)+          Store it 
         SUB.B    #1,D2             Decrement byte counter 
         BNE      LOAD7             Repeat until count = 0 
         BSR.S    LOAD8             Read checksum 
         ADD.B    #1,D3             Add 1 to total checksum 
         BEQ      LOAD2             If zero then start next record 
         OR.B     #%00001000,D7     Else set checksum error bit, 
         BRA      LOAD3             restore I/O devices and return 
* 
LOAD8    BSR     BYTE               Get a byte 
         ADD.B   D0,D3              Update checksum 
         RTS                         and return 
* 
************************************************************************* 
* 
*  DUMP   Transmit S1 formatted records 
*         A3 = Starting address of data block 
*         A2 = End address of data block 
*         D1 = Checksum, D2 = current record length 
* 
DUMP     BSR      RANGE             Get start and end address 
         TST.B    D7                Test for input error 
         BEQ.S    DUMP1             If no error then continue 
         LEA.L    ERMES1(PC),A4     Else point to error message, 
         BRA      PSTRING           print it and return 
DUMP1    CMP.L    A3,D0             Compare start and end addresses 
         BPL.S    DUMP2             If positive then start < end 
         LEA.L    ERMES7(PC),A4     Else print error message 
         BRA      PSTRING           and return 
DUMP2    BSR      NEWLINE           Send newline to host and wait
         MOVE.L   BUFFPT(A6),A4     Before dumping, send any string 
DUMP3    MOVE.B   (A4)+,D0          in the input buffer to the host 
         BSR      PUTCHAR           Repeat 
         CMP.B    #CR,D0            Transmit char from buffer to host 
         BNE      DUMP3             Until char = C/R 
         BSR      NEWLINE 
         ADDQ.L   #1,A2             A2 contains length of record + 1 
DUMP4    MOVE.L   A2,D2             D2 points to end address 
         SUB.L    A3,D2             D2 contains bytes left to print 
         CMP.L    #17,D2            If this is not a full record of 16 
         BCS.S    DUMP5             then load D2 with record size 
         MOVEQ    #16,D2            Else preset byte count to 16 
DUMP5    LEA.L    HEADER(PC),A4     Point to record header 
         BSR      PSTRING           Print header 
         CLR.B    D1                Clear checksum 
         MOVE.B   D2,D0             Move record length to output register 
         ADD.B    #3,D0             Length includes address + count 
         BSR.S    DUMP7             Print number of bytes in record 
         MOVE.L   A3,D0             Get start address to be printed 
         ROL.W    #8,D0             Get MS byte in LS position 
         BSR.S    DUMP7             Print MS byte of address 
         ROR.W    #8,D0             Restore LS byte 
         BSR.S    DUMP7             Print LS byte of address 
DUMP6    MOVE.B   (A3)+,D0          Get data byte to be printed 
         BSR.S    DUMP7             Print it 
         SUB.B    #1,D2             Decrement byte count 
         BNE      DUMP6             Repeat until all this record printed 
         NOT.B    D1                Complement checksum 
         MOVE.B   D1,D0             Move to output register 
         BSR.S    DUMP7             Print checksum 
         BSR      NEWLINE 
         CMP.L    A2,A3             Have all records been printed? 
         BNE      DUMP4             Repeat until all done 
         LEA.L    TAIL(PC),A4       Point to message tail (S9 record) 
         BSR      PSTRING           Print it 
         RTS                        and return 
* 
DUMP7    ADD.B    D0,D1             Update checksum, transmit byte 
         BRA      OUT2X             to host and return 
* 
RANGE    EQU      *                 Get the range of addresses to be 
         CLR.B    D7                transmitted from the buffer 
         BSR      PARAM             Get starting address 
         MOVE.L   D0,A3             Set up start address in A3 
         BSR      PARAM             Get end address 
         MOVE.L   D0,A2             Set up end address in A2 
         RTS 
* 
************************************************************************* 
* 
*  GETCHAR gets a character 
* 
GETCHAR  MOVE.B  D0,D1
         MOVE.B  #5,D0
         TRAP    #15
         MOVE.B  D1,D0
         AND.B   #$7F,D0         Strip msb of input 
         TST.B   U_CASE(A6)      Test for upper -> lower case conversion 
         BNE.S   GETCH2          If flag not zero do not convert case 
         BTST.B  #6,D0           Test input for lower case 
         BEQ.S   GETCH2          If upper case then skip conversion 
         AND.B   #%11011111,D0   Else clear bit 5 for upper case conv 
GETCH2   TST.B   ECHO(A6)        Do we need to echo the input? 
         BNE.S   GETCH3          If ECHO not zero then no echo 
         BSR.S   PUTCHAR         Else echo the input 
GETCH3   RTS                     and return 
* 
************************************************************************* 
* 
*  PUTCHAR sends a character to the console device 
*  The name of the output device is in CN_OVEC. 
* 
PUTCHAR  MOVE.L  D1,-(A7)        Save working register
         MOVE.B  D0,D1
         MOVE.B  #6,D0
         TRAP    #15
         MOVE.L  (A7)+,D1        Restore working register 
         RTS 
* 
************************************************************************* 
* 
*  Exception vector table initialization routine 
*  All vectors not setup are loaded with uninitialized routine vector 
* 
X_SET   LEA.L   X_BASE,A0         Point to base of exception table 
        MOVE.W  #253,D0           Number of vectors -  3 
X_SET1  CMPA.L  #188,A0           Avoid TRAP #15 (required by the simulator)
        BEQ     X_SET2
        MOVE.L  #X_UN,(A0)        Store uninitialized exception vector
X_SET2  ADDA.L  #4,A0
        DBRA    D0,X_SET1         Repeat until all entries preset
        SUB.L   A0,A0             Clear A0 (points to vector table) 
        MOVE.L  #BUS_ER,8(A0)     Setup bus error vector 
        MOVE.L  #ADD_ER,12(A0)    Setup address error vector 
        MOVE.L  #IL_ER,16(A0)     Setup illegal instruction error vect 
        MOVE.L  #TRACE,36(A0)     Setup trace exception vector 
        MOVE.L  #BRKPT,184(A0)    Setup TRAP #14 vector = breakpoint 
        MOVE.W  #7,D0             Now clear the breakpoint table 
        LEA.L   BP_TAB(A6),A0     Point to table 
X_SET3  CLR.L   (A0)+             Clear an address entry 
        CLR.W   (A0)+             Clear the corresponding data 
        DBRA    D0,X_SET3         Repeat until all 8 cleared 
        RTS 
* 
* 
************************************************************************* 
* 
*  Display exception frame (D0 - D7, A0 - A6, USP, SSP, SR, PC) 
*  EX_DIS prints registers saved after a breakpoint or exception 
*  The registers are saved in TSK_T 
* 
EX_DIS  LEA.L   TSK_T(A6),A5      A5 points to display frame 
        LEA.L   MES3(PC),A4       Point to heading 
        BSR     HEADING           and print it 
        MOVE.W  #7,D6             8 pairs of registers to display 
        CLR.B   D5                D5 is the line counter 
EX_D1   MOVE.B  D5,D0             Put current register number in D0 
        BSR     OUT1X             and print it 
        BSR     PSPACE            and a space 
        ADD.B   #1,D5             Update counter for next pair 
        MOVE.L  (A5),D0           Get data register to be displayed 
        BSR     OUT8X             from the frame and print it 
        LEA.L   MES4(PC),A4       Print string of spaces 
        BSR.L   PSTRING           between data and address registers 
        MOVE.L  32(A5),D0         Get address register to be displayed 
        BSR     OUT8X             which is 32 bytes on from data reg 
        BSR     NEWLINE 
        LEA.L   4(A5),A5          Point to next pair (ie Di, Ai) 
        DBRA    D6,EX_D1          Repeat until all displayed 
        LEA.L   32(A5),A5         Adjust pointer by 8 longwords 
        BSR     NEWLINE           to point to SSP 
        LEA.L   MES2A(PC),A4      Point to "SS =" 
        BSR     PSTRING           Print it 
        MOVE.L  (A5)+,D0          Get SSP from frame 
        BSR     OUT8X             and display it 
        BSR     NEWLINE 
        LEA.L   MES1(PC),A4       Point to 'SR =' 
        BSR     PSTRING           Print it 
        MOVE.W  (A5)+,D0          Get status register 
        BSR     OUT4X             Display status 
        BSR     NEWLINE 
        LEA.L   MES2(PC),A4       Point to 'PC =' 
        BSR     PSTRING           Print it 
        MOVE.L  (A5)+,D0          Get PC 
        BSR     OUT8X             Display PC 
        BRA     NEWLINE           Newline and return 
* 
************************************************************************* 
* 
*  Exception handling routines 
* 
IL_ER   EQU      *                Illegal instruction exception 
        MOVE.L  A4,-(A7)          Save A4 
        LEA.L   MES10(PC),A4      Point to heading 
        BSR     HEADING           Print it 
        MOVE.L  (A7)+,A4          Restore A4 
        BSR.S   GROUP2            Save registers in display frame 
        BSR     EX_DIS            Display registers saved in frame 
        BRA     WARM              Abort from illegal instruction 
* 
BUS_ER  EQU     *                 Bus error (group 1) exception 
        MOVE.L  A4,-(A7)          Save A4 
        LEA.L   MES8(PC),A4       Point to heading 
        BSR     HEADING           Print it 
        MOVE.L  (A7)+,A4          Restore A4 
        BRA.S   GROUP1            Deal with group 1 exception 
* 
ADD_ER  EQU     *                 Address error (group 1) exception 
        MOVE.L  A4,-(A7)          Save A4 
        LEA.L   MES9(PC),A4       Point to heading 
        BSR     HEADING           Print it 
        MOVE.L  (A7)+,A4          Restore A4 
        BRA.S   GROUP1            Deal with group 1 exception 
* 
BRKPT   EQU     *                   Deal with breakpoint 
        MOVEM.L D0-D7/A0-A6,-(A7)   Save all registers 
        BSR     BR_CLR              Clear breakpoints in code 
        MOVEM.L (A7)+,D0-D7/A0-A6   Restore registers 
        BSR.S   GROUP2            Treat as group 2 exception 
        LEA.L   MES11(PC),A4      Point to heading 
        BSR     HEADING           Print it 
        BSR     EX_DIS            Display saved registers 
        BRA     WARM              Return to monitor 
* 
*       GROUP1 is called by address and bus error exceptions 
*       These are "turned into group 2" exceptions (eg TRAP) 
*       by modifying the stack frame saved by a group 1 exception 
* 
GROUP1  MOVEM.L D0/A0,-(A7)       Save working registers 
        MOVE.L  18(A7),A0         Get PC from group 1 stack frame 
        MOVE.W  14(A7),D0         Get instruction from stack frame 
        CMP.W   -(A0),D0          Now backtrack to find the "correct PC" 
        BEQ.S   GROUP1A           by matching the op-code on the stack 
        CMP.W   -(A0),D0          with the code in the region of the 
        BEQ.S   GROUP1A           PC on the stack 
        CMP.W   -(A0),D0 
        BEQ.S   GROUP1A 
        CMP.W   -(A0),D0 
        BEQ.S   GROUP1A 
        SUBQ.L  #2,A0 
GROUP1A MOVE.L  A0,18(A7)          Restore modified PC to stack frame 
        MOVEM.L (A7)+,D0/A0        Restore working registers 
        LEA.L   8(A7),A7           Adjust stack pointer to group 1 type 
        BSR.S   GROUP2             Now treat as group 1 exception 
        BSR     EX_DIS             Display contents of exception frame 
        BRA     WARM               Exit to monitor - no RTE from group 2 
* 
GROUP2  EQU     *                 Deal with group 2 exceptions 
        MOVEM.L A0-A7/D0-D7,-(A7) Save all registers on the stack 
        MOVE.W  #14,D0            Transfer D0 - D7, A0 - A6 from 
        LEA.L   TSK_T(A6),A0      the stack to the display frame 
GROUP2A MOVE.L  (A7)+,(A0)+       Move a register from stack to frame 
        DBRA    D0,GROUP2A        and repeat until D0-D7/A0-A6 moved 
        MOVE.L  USP,A2            Get the user stack pointer and put it 
        MOVE.L  A2,(A0)+          in the A7 position in the frame 
        MOVE.L  (A7)+,D0          Now transfer the SSP to the frame, 
        SUB.L   #10,D0            remembering to account for the 
        MOVE.L  D0,(A0)+          data pushed on the stack to this point 
        MOVE.L  (A7)+,A1          Copy TOS (return address) to A1 
        MOVE.W  (A7)+,(A0)+       Move SR to display frame 
        MOVE.L  (A7)+,D0          Get PC in D0 
        SUBQ.L  #2,D0             Move back to current instruction 
        MOVE.L  D0,(A0)+          Put adjusted PC in display frame 
        JMP     (A1)              Return from subroutine 
* 
************************************************************************* 
* 
*  GO executes a program either from a supplied address or 
*  by using the data in the display frame 
GO       BSR     PARAM               Get entry address (if any) 
         TST.B   D7                  Test for error in input 
         BEQ.S   GO1                 If D7 zero then OK 
         LEA.L   ERMES1(PC),A4       Else point to error message, 
         BRA     PSTRING             print it and return 
GO1      TST.L   D0                  If no address entered then get 
         BEQ.S   GO2                 address from display frame 
         MOVE.L  D0,TSK_T+70(A6)     Else save address in display frame 
         MOVE.W  #$2700,TSK_T+68(A6) Store dummy status in frame 
GO2      BRA.S   RESTORE             Restore volatile environment and go 
* 
GB       BSR     BR_SET              Same as go but presets breakpoints 
         BRA.S   GO                  Execute program 
* 
*        RESTORE moves the volatile environment from the display 
*        frame and transfers it to the 68000's registers. This 
*        re-runs a program suspended after an exception 
* 
RESTORE  LEA.L   TSK_T(A6),A3        A3 points to display frame 
         LEA.L   74(A3),A3           A3 now points to end of frame + 4 
         LEA.L   4(A7),A7            Remove return address from stack 
         MOVE.W  #36,D0              Counter for 37 words to be moved 
REST1    MOVE.W  -(A3),-(A7)         Move word from display frame to stack 
         DBRA    D0,REST1            Repeat until entire frame moved 
         MOVEM.L (A7)+,D0-D7         Restore old data registers from stack 
         MOVEM.L (A7)+,A0-A6         Restore old address registers 
         LEA.L   8(A7),A7            Except SSP/USP - so adjust stack 
         RTE                         Return from exception to run program 
* 
TRACE    EQU     *                   TRACE exception (rudimentary version) 
         MOVE.L  MES12(PC),A4        Point to heading 
         BSR     HEADING             Print it 
         BSR     GROUP1              Save volatile environment 
         BSR     EX_DIS              Display it 
         BRA     WARM                Return to monitor 
* 
************************************************************************* 
*  Breakpoint routines: BR_GET gets the address of a breakpoint and 
*  puts it in the breakpoint table. It does not plant it in the code. 
*  BR_SET plants all breakpoints in the code. NOBR removes one or all 
*  breakpoints from the table. KILL removes breakpoints from the code. 
* 
BR_GET   BSR     PARAM               Get breakpoint address in table 
         TST.B   D7                  Test for input error 
         BEQ.S   BR_GET1             If no error then continue 
         LEA.L   ERMES1(PC),A4       Else display error 
         BRA     PSTRING             and return 
BR_GET1  LEA.L   BP_TAB(A6),A3       A6 points to breakpoint table 
         MOVE.L  D0,A5               Save new BP address in A5 
         MOVE.L  D0,D6               and in D6 because D0 gets corrupted 
         MOVE.W  #7,D5               Eight entries to test 
BR_GET2  MOVE.L  (A3)+,D0            Read entry from breakpoint table 
         BNE.S   BR_GET3             If not zero display existing BP 
         TST.L   D6                  Only store a non-zero breakpoint 
         BEQ.S   BR_GET4 
         MOVE.L  A5,-4(A3)           Store new breakpoint in table 
         MOVE.W  (A5),(A3)           Save code at BP address in table 
         CLR.L   D6                  Clear D6 to avoid repetition 
BR_GET3  BSR     OUT8X               Display this breakpoint 
         BSR     NEWLINE 
BR_GET4  LEA.L   2(A3),A3            Step past stored op-code 
         DBRA    D5,BR_GET2          Repeat until all entries tested 
         RTS                         Return 
* 
BR_SET   EQU     *                   Plant any breakpoints in user code 
         LEA.L   BP_TAB(A6),A0       A0 points to BP table 
         LEA.L   TSK_T+70(A6),A2     A2 points to PC in display frame 
         MOVE.L  (A2),A2             Now A2 contains value of PC 
         MOVE.W  #7,D0               Up to eight entries to plant 
BR_SET1  MOVE.L  (A0)+,D1            Read breakpoint address from table 
         BEQ.S   BR_SET2             If zero then skip planting 
         CMP.L   A2,D1               Don't want to plant BP at current PC 
         BEQ.S   BR_SET2             location, so skip planting if same 
         MOVE.L  D1,A1               Transfer BP address to address reg 
         MOVE.W  #TRAP_14,(A1)       Plant op-code for TRAP #14 in code 
BR_SET2  LEA.L   2(A0),A0            Skip past op-code field in table 
         DBRA    D0,BR_SET1          Repeat until all entries tested 
         RTS 
* 
NOBR     EQU     *                   Clear one or all breakpoints 
         BSR     PARAM               Get BP address (if any) 
         TST.B   D7                  Test for input error 
         BEQ.S   NOBR1               If no error then skip abort 
         LEA.L   ERMES1(PC),A4       Point to error message 
         BRA     PSTRING             Display it and return 
NOBR1    TST.L   D0                  Test for null address (clear all) 
         BEQ.S   NOBR4               If no address then clear all entries 
         MOVE.L  D0,A1               Else just clear breakpoint in A1 
         LEA.L   BP_TAB(A6),A0       A0 points to BP table 
         MOVE.W  #7,D0               Up to eight entries to test 
NOBR2    MOVE.L  (A0)+,D1            Get entry and 
         LEA.L   2(A0),A0            skip past op-code field 
         CMP.L   A1,D1               Is this the one? 
         BEQ.S   NOBR3               If so go and clear entry 
         DBRA    D0,NOBR2            Repeat until all tested 
         RTS 
NOBR3    CLR.L   -6(A0)              Clear address in BP table 
         RTS 
NOBR4    LEA.L   BP_TAB(A6),A0       Clear all 8 entries in BP table 
         MOVE.W  #7,D0               Eight entries to clear 
NOBR5    CLR.L   (A0)+               Clear breakpoint address 
         CLR.W   (A0)+               Clear op-code field 
         DBRA    D0,NOBR5            Repeat until all done 
         RTS 
* 
BR_CLR   EQU     *                   Remove breakpoints from code 
         LEA.L   BP_TAB(A6),A0       A0 points to breakpoint table 
         MOVE.W  #7,D0               Up to eight entries to clear 
BR_CLR1  MOVE.L  (A0)+,D1            Get address of BP in D1 
         MOVE.L  D1,A1               and put copy in A1 
         TST.L   D1                  Test this breakpoint 
         BEQ.S   BR_CLR2             If zero then skip BP clearing 
         MOVE.W  (A0),(A1)           Else restore op-code 
BR_CLR2  LEA.L   2(A0),A0            Skip past op-code field 
         DBRA    D0,BR_CLR1          Repeat until all tested 
         RTS 
* 
*  REG_MOD modifies a register in the display frame. The command 
*  format is REG <reg> <value>. E.g. REG D3 1200 
* 
REG_MOD  CLR.L   D1                  D1 to hold name of register 
         LEA.L   BUFFPT(A6),A0       A0 contains address of buffer pointer 
         MOVE.L  (A0),A0             A0 now points to next char in buffer 
         MOVE.B  (A0)+,D1            Put first char of name in D1 
         ROL.W   #8,D1               Move char one place left 
         MOVE.B  (A0)+,D1            Get second char in D1 
         LEA.L   1(A0),A0            Move pointer past space in buffer 
         MOVE.L  A0,BUFFPT(A6)       Update buffer pointer 
         CLR.L   D2                  D2 is the character pair counter 
         LEA.L   REGNAME(PC),A0      A0 points to string of character pairs 
         LEA.L   (A0),A1             A1 also points to string 
REG_MD1  CMP.W   (A0)+,D1            Compare a char pair with input 
         BEQ.S   REG_MD2             If match then exit loop 
         ADD.L   #1,D2               Else increment match counter 
         CMP.L   #19,D2              Test for end of loop 
         BNE     REG_MD1             Continue until all pairs matched 
         LEA.L   ERMES1(PC),A4       If here then error 
         BRA     PSTRING             Display error and return 
REG_MD2  LEA.L   TSK_T(A6),A1        A1 points to display frame 
         ASL.L   #2,D2               Multiply offset by 4 (4 bytes/entry) 
         CMP.L   #72,D2              Test for address of PC 
         BNE.S   REG_MD3             If not PC then all is OK 
         SUB.L   #2,D2               else dec PC pointer as Sr is a word 
REG_MD3  LEA.L   (A1,D2),A2          Calculate address of entry in disptable 
         MOVE.L  (A2),D0             Get old contents 
         BSR     OUT8X               Display them 
         BSR     NEWLINE 
         BSR     PARAM               Get new data 
         TST.B   D7                  Test for input error 
         BEQ.S   REG_MD4             If no error then go and store data 
         LEA.L   ERMES1(PC),A4       Else point to error message 
         BRA     PSTRING             print it and return 
REG_MD4  CMP.L   #68,D2              If this address is the SR then 
         BEQ.S   REG_MD5             we have only a word to store 
         MOVE.L  D0,(A2)             Else store new data in display frame 
         RTS 
REG_MD5  MOVE.W  D0,(A2)             Store SR (one word) 
         RTS 
* 
************************************************************************* 
* 
X_UN    EQU     *                 Uninitialized exception vector routine 
        LEA.L   ERMES6(PC),A4     Point to error message 
        BSR     PSTRING           Display it 
        BSR     EX_DIS            Display registers 
        BRA     WARM              Abort 
* 
************************************************************************* 
* 
*  All strings and other fixed parameters here 
* 
BANNER   DC.B     'TSBUG  Version 3.10.96',0,0 
CRLF     DC.B     CR,LF,'?',0 
HEADER   DC.B     CR,LF,'S','1',0,0 
TAIL     DC.B     'S9  ',0,0 
MES1     DC.B     ' SR  =  ',0 
MES2     DC.B     ' PC  =  ',0 
MES2A    DC.B     ' SS  =  ',0 
MES3     DC.B     '  Data reg       Address reg',0,0 
MES4     DC.B     '        ',0,0 
MES8     DC.B     'Bus error   ',0,0 
MES9     DC.B     'Address error   ',0,0 
MES10    DC.B     'Illegal instruction ',0,0 
MES11    DC.B     'Breakpoint  ',0,0 
MES12    DC.B     'Trace   ',0 
REGNAME  DC.B     'D0D1D2D3D4D5D6D7' 
         DC.B     'A0A1A2A3A4A5A6A7' 
         DC.B     'SSSR' 
         DC.B     'PC  ',0 
ERMES1   DC.B     'Non-valid hexadecimal input  ',0 
ERMES2   DC.B     'Invalid command  ',0 
ERMES3   DC.B     'Loading error',0 
ERMES4   DC.B     'Table full  ',0,0 
ERMES5   DC.B     'Breakpoint not active   ',0,0 
ERMES6   DC.B     'Uninitialized exception ',0,0 
ERMES7   DC.B     ' Range error',0 
* 
*  COMTAB is the built-in command table. All entries are made up of 
*         a string length + number of characters to match + the string 
*         plus the address of the command relative to COMTAB 
* 
         DC.L     0                Force table to even address
COMTAB   DC.B     4,4              JUMP <address> causes execution to
         DC.B     'JUMP'           begin at <address> 
         DC.L     JUMP-COMTAB                                          n 
         DC.B     6,3              MEMORY <address> examines contents of 
         DC.B     'MEMORY'         <address> and allows them to be changed 
         DC.L     MEMORY-COMTAB 
         DC.B     4,2              LOAD <string> loads S1/S2 records 
         DC.B     'LOAD'           from the host. <string> is sent to host 
         DC.L     LOAD-COMTAB 
         DC.B     4,2              DUMP <string> sends S1 records to the 
         DC.B     'DUMP'           host and is preceeded by <string>. 
         DC.L     DUMP-COMTAB 
         DC.B     4,2              NOBR <address> removes the breakpoint 
         DC.B     'NOBR'           at <address> from the BP table. If 
         DC.L     NOBR-COMTAB      no address is given all BPs are removed. 
         DC.B     4,2              DISP displays the contents of the 
         DC.B     'DISP'           pseudo registers in TSK_T. 
         DC.L     EX_DIS-COMTAB 
         DC.B     4,2              GO <address> starts program execution 
         DC.B    'GO'              at <address> and loads regs from TSK_T 
         DC.L     GO-COMTAB 
         DC.B     2,2               BRGT puts a breakpoint in the BP 
         DC.B    'BRGT'            table - but not in the code 
         DC.L    BR_GET-COMTAB 
         DC.B    4,2               PLAN puts the breakpoints in the code 
         DC.B    'PLAN' 
         DC.L    BR_SET-COMTAB 
         DC.B    4,4               KILL removes breakpoints from the code 
         DC.B    'KILL' 
         DC.L    BR_CLR-COMTAB 
         DC.B    4,2               GB <address> sets breakpoints and 
         DC.B    'GB  '            then calls GO. 
         DC.L    GB-COMTAB 
         DC.B    4,3               REG <reg> <value> loads <value> 
         DC.B    'REG '            into <reg> in TASK_T. Used to preset 
         DC.L    REG_MOD-COMTAB    registers before a GO or GB 
         DC.B    0,0 
* 
         END $1000 



 

 


