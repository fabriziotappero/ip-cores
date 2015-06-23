/*******************************************************************************************/
/**                                                                                       **/
/** ORIGINAL COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED **/
/** COPYRIGHT (C) 2012, SERGEY BELYASHOV                                                  **/
/**                                                                                       **/
/** define file to make the code more readable                       Rev  0.0  06/18/2012 **/
/**                                                                                       **/
/*******************************************************************************************/

  /*****************************************************************************************/
  /*                                                                                       */
  /* page register control - DO NOT MODIFY                                                 */
  /*                                                                                       */
  /*****************************************************************************************/
  `define MAIN_PG     4'b0000          //no instruction prefix byte(s)
  `define INTR_PG     4'b0001          //interrupt acknowledge
  `define CB_PAGE     4'b0010          //CB instruction prefix
  `define DMA_PG      4'b0011          //dma acknowledge
  `define DD_PAGE     4'b0100          //DD instruction prefix
  `define FD_PAGE     4'b0101          //FD instruction prefix
  `define DDCB_PG     4'b0110          //DD-CB instruction prefix
  `define FDCB_PG     4'b0111          //FD-CB instruction prefix
  `define ED_PAGE     4'b1000          //ED instruction prefix
  `define DEC_MAIN    4'b0x0x          //main page or DD page or FD page
  `define DEC_ED      4'b1xxx          //ED page

  /*****************************************************************************************/
  /*                                                                                       */
  /* program counter register control: pc_sel                                              */
  /*                                                                                       */
  /*****************************************************************************************/
  `define PCCTL_IDX   2
  `define PC_NUL      3'b000           //No operation on PC
  `define PC_LD       3'b001           //PC loaded unconditionally
  `define PC_NILD     3'b011           //PC loaded if no interrupt, sample interrupt
  `define PC_INT      3'b100           //Sample interrupt/dma only
  `define PC_DMA      3'b110           //Sample dma only
  `define PC_NILD2    3'b111           //PC loaded if no latched interrupt

  /*****************************************************************************************/
  /*                                                                                       */
  /* address bus select: add_sel                                                           */
  /*                                                                                       */
  /*****************************************************************************************/
  `define ADCTL_IDX   4
  `define ADD_RSTVAL  5'b00000         //Pipeline register reset value
  `define ADD_PC      5'b00001         //Select address register from PC
  `define ADD_HL      5'b00010         //Select address register from HL
  `define ADD_SP      5'b00100         //Select address register from SP
  `define ADD_ALU     5'b01000         //Select address register from ALU
  `define ADD_ALU8    5'b10000         //Select address register from {8'h0, ALU[7:0]}

  `define AD_PC       0                //Address from PC
  `define AD_HL       1                //Address from HL
  `define AD_SP       2                //Address from SP
  `define AD_ALU      3                //Address from ALU
  `define AD_ALU8     4                //Address from {8'h0, ALU[7:0]}

  /*****************************************************************************************/
  /*                                                                                       */
  /* transaction type select: tran_sel                                                     */
  /*                                                                                       */
  /*****************************************************************************************/
  `define TTYPE_IDX   5
  `define TRAN_RSTVAL 6'b000000        //Transaction type reset value
  `define TRAN_IAK    6'b000001        //Intack transaction
  `define TRAN_IDL    6'b000010        //Idle transaction
  `define TRAN_IF     6'b000100        //Instruction fetch transaction
  `define TRAN_IO     6'b001000        //I/O transaction
  `define TRAN_MEM    6'b010000        //Memory (data) transaction
  `define TRAN_STK    6'b100000        //Memory (stack) transaction

  `define TT_IAK      0                //Interrupt acknowledge transaction
  `define TT_IDL      1                //Idle transaction
  `define TT_IF       2                //Instruction fetch transaction
  `define TT_IO       3                //I/O transaction
  `define TT_MEM      4                //Memory (data) transaction
  `define TT_STK      5                //Memory (stack) transaction

  /*****************************************************************************************/
  /*                                                                                       */
  /* data output control: do_ctl - DO NOT MODIFY                                           */
  /*                                                                                       */
  /*****************************************************************************************/
  `define DO_IDX      2
  `define DO_NUL      3'b000           //No load
  `define DO_IO       3'b010           //Load i/o data from lsb
  `define DO_LSB      3'b100           //Load mem data from lsb
  `define DO_MSB      3'b101           //Load mem data from msb

  /*****************************************************************************************/
  /*                                                                                       */
  /* data input control: di_ctl - DO NOT MODIFY                                            */
  /*                                                                                       */
  /*****************************************************************************************/
  `define DI_IDX      1
  `define DI_NUL      2'b00            //No load
  `define DI_DI0      2'b01            //Load din0
  `define DI_DI1      2'b10            //Load din1
  `define DI_DI10     2'b11            //Load both din0 and din1

  /*****************************************************************************************/
  /*                                                                                       */
  /* interrupt enable control: ief_ctl - DO NOT MODIFY                                     */
  /*                                                                                       */
  /*****************************************************************************************/
  `define IEF_IDX     2
  `define IEF_NUL     3'b000           //No load
  `define IEF_0       3'b010           //Load zero
  `define IEF_1       3'b011           //Load one
  `define IEF_NMI     3'b100           //ief2 <= ief1, ief1 <= 0
  `define IEF_RTN     3'b101           //ief1 <= ief2

  /*****************************************************************************************/
  /*                                                                                       */
  /* int mode control: imd_ctl - DO NOT MODIFY                                             */
  /*                                                                                       */
  /*****************************************************************************************/
  `define IMD_IDX     1
  `define IMD_NUL     2'b00            //No load
  `define IMD_0       2'b01            //Set interrupt mode 0
  `define IMD_1       2'b10            //Set interrupt mode 1
  `define IMD_2       2'b11            //Set interrupt mode 2

  /*****************************************************************************************/
  /*                                                                                       */
  /* half-carry flag control: hflg_ctl - DO NOT MODIFY                                     */
  /*                                                                                       */
  /*****************************************************************************************/
  `define HFLG_IDX    1
  `define HFLG_NUL    2'b00            //No load
  `define HFLG_H      2'b01            //Load half-carry result
  `define HFLG_0      2'b10            //Load zero
  `define HFLG_1      2'b11            //Load one

  /*****************************************************************************************/
  /*                                                                                       */
  /* parity/overflow flag control: pflg_ctl                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  `define PFLG_IDX    2
  `define PFLG_NUL    3'b000           //No load
  `define PFLG_V      3'b001           //Load overflow result
  `define PFLG_0      3'b010           //Load zero
  `define PFLG_1      3'b011           //Load one
  `define PFLG_P      3'b100           //Load parity result
  `define PFLG_B      3'b101           //Load block count zero result
  `define PFLG_F      3'b111           //Load ief

  /*****************************************************************************************/
  /*                                                                                       */
  /* negate flag control: nflg_ctl - DO NOT MODIFY                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  `define NFLG_IDX    1
  `define NFLG_NUL    2'b00            //No load
  `define NFLG_S      2'b01            //Load sign result
  `define NFLG_0      2'b10            //Load zero
  `define NFLG_1      2'b11            //Load one

  /*****************************************************************************************/
  /*                                                                                       */
  /* temporary flag control: tflg_ctl                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  `define TFLG_IDX    1
  `define TFLG_NUL    2'b00            //No load
  `define TFLG_Z      2'b01            //Load zero result
  `define TFLG_1      2'b10            //Load one result (blk out)
  `define TFLG_B      2'b11            //Load blk cp result

  /*****************************************************************************************/
  /*                                                                                       */
  /* write register control: wr_sel - unencoded                                            */
  /*                                                                                       */
  /*****************************************************************************************/
  `define WREG_IDX 16
  `define WREG_BB    17'b11000000000000000       //Select B to write
  `define WREG_BC    17'b11100000000000000       //Select BC to write
  `define WREG_CC    17'b10100000000000000       //Select C to write
  `define WREG_DD    17'b10010000000000000       //Select D to write
  `define WREG_DE    17'b10011000000000000       //Select DE to write
  `define WREG_EE    17'b10001000000000000       //Select E to write
  `define WREG_HH    17'b10000100000000000       //Select H to write
  `define WREG_HL    17'b10000110000000000       //Select HL to write
  `define WREG_LL    17'b10000010000000000       //Select L to write
  `define WREG_DEHL  17'b10011110000000000       //Select DEHL to write (ex case)
  `define WREG_AA    17'b10000001000000000       //Select A to write
  `define WREG_AF    17'b10000001100000000       //Select A and F to write
  `define WREG_FF    17'b10000000100000000       //Select F to write
  `define WREG_SP    17'b10000000010000000       //Select SP to write
  `define WREG_TMP   17'b10000000001000000       //Select TMP register to write
  `define WREG_IXH   17'b10000000000100000       //Select IXH to write
  `define WREG_IX    17'b10000000000110000       //Select IX to write
  `define WREG_IXL   17'b10000000000010000       //Select IXL to write
  `define WREG_IYH   17'b10000000000001000       //Select IYH to write
  `define WREG_IY    17'b10000000000001100       //Select IY to write
  `define WREG_IYL   17'b10000000000000100       //Select IYL to write
  `define WREG_II    17'b10000000000000010       //Select I register to write
  `define WREG_RR    17'b10000000000000001       //Select R register to write
  `define WREG_NUL   17'b00000000000000000       //No register write

  `define WR_REG     16                //register write
  `define WR_BB      15                //BB register index
  `define WR_CC      14                //CC register index
  `define WR_DD      13                //DD register index
  `define WR_EE      12                //EE register index
  `define WR_HH      11                //HH register index
  `define WR_LL      10                //LL register index
  `define WR_AA       9                //AA register index
  `define WR_FF       8                //FF register index
  `define WR_SP       7                //SP register index
  `define WR_TMP      6                //TMP register index
  `define WR_IXH      5                //IXH register index
  `define WR_IXL      4                //IXL register index
  `define WR_IYH      3                //IYH register index
  `define WR_IYL      2                //IYL register index
  `define WR_II       1                //II register index
  `define WR_RR       0                //RR register index

  /*****************************************************************************************/
  /*                                                                                       */
  /* ALU input A control: alua_sel                                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  `define ALUA_IDX 14
  `define ALUA_RSTVAL 15'h0000         //Reset value for pipeline controls
  `define ALUA_ZER    15'h0000         //Select 16'h0000 (default)
  `define ALUA_ONE    15'h0001         //Select 16'h0001
  `define ALUA_M1     15'h0002         //Select 16'hFFFF
  `define ALUA_M2     15'h0004         //Select 16'hFFFE
  `define ALUA_HL     15'h0008         //Select HL register
  `define ALUA_IX     15'h0010         //Select IX register
  `define ALUA_IY     15'h0020         //Select IY register
  `define ALUA_PC     15'h0040         //Select PC register
  `define ALUA_AA     15'h0080         //Select A register
  `define ALUA_BIT    15'h0100         //Select bit select constant
  `define ALUA_DAA    15'h0200         //Select decimal adjust constant
  `define ALUA_II     15'h0400         //Select I register
  `define ALUA_RR     15'h0800         //Select R register
  `define ALUA_INT    15'h1000         //Select interrupt address
  `define ALUA_TMP    15'h2000         //Select TMP register
  `define ALUA_RST    15'h4000         //Select restart address

  `define AA_ONE       0               //alua one
  `define AA_M1        1               //alua -1
  `define AA_M2        2               //alua -2
  `define AA_HL        3               //alua hl
  `define AA_IX        4               //alua ix
  `define AA_IY        5               //alua iy
  `define AA_PC        6               //alua pc
  `define AA_AA        7               //alua aa
  `define AA_BIT       8               //alua bit
  `define AA_DAA       9               //alua daa
  `define AA_II       10               //alua ii
  `define AA_RR       11               //alua rr
  `define AA_INT      12               //alua interrupt
  `define AA_TMP      13               //alua tmp
  `define AA_RST      14               //alua restart

  /*****************************************************************************************/
  /*                                                                                       */
  /* ALU input B control: alub_sel                                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  `define ALUB_IDX 12
  `define ALUB_RSTVAL 13'h1000         //Reset value for pipeline controls
  `define ALUB_AF     13'h1002         //Select A and F registers
  `define ALUB_AA     13'h1003         //Select A register
  `define ALUB_BC     13'h0004         //Select BC register
  `define ALUB_BB     13'h0005         //Select B register
  `define ALUB_CC     13'h0004         //Select C register
  `define ALUB_DE     13'h0008         //Select DE register
  `define ALUB_DD     13'h0009         //Select D register
  `define ALUB_EE     13'h0008         //Select E register
  `define ALUB_HL     13'h0010         //Select HL register
  `define ALUB_HH     13'h0011         //Select H register
  `define ALUB_LL     13'h0010         //Select L register
  `define ALUB_IX     13'h0020         //Select IX register
  `define ALUB_IXH    13'h0021         //Select IX register high byte
  `define ALUB_IXL    13'h0020         //Select IX register low byte
  `define ALUB_IY     13'h0040         //Select IY register
  `define ALUB_IYH    13'h0041         //Select IY register high byte
  `define ALUB_IYL    13'h0040         //Select IY register low byte
  `define ALUB_SP     13'h0080         //Select SP register
  `define ALUB_SPH    13'h0081         //Select SP register high byte
  `define ALUB_DIN    13'h0100         //Select data input register
  `define ALUB_DINH   13'h0101         //Select data input register high byte
  `define ALUB_IO     13'h0200         //Select i/o address
  `define ALUB_TMP    13'h0400         //Select TMP register
  `define ALUB_TMPH   13'h0401         //Select TMP register high byte
  `define ALUB_PC     13'h1800         //Select PC register
  `define ALUB_PCH    13'h1801         //Select PC register high byte

  `define AB_SHR      0                //alub shift right
  `define AB_AF       1                //alub af
  `define AB_BC       2                //alub bc
  `define AB_DE       3                //alub de
  `define AB_HL       4                //alub hl
  `define AB_IX       5                //alub ix
  `define AB_IY       6                //alub iy
  `define AB_SP       7                //alub sp
  `define AB_DIN      8                //alub din
  `define AB_IO       9                //alub io
  `define AB_TMP      10               //alub tmp
  `define AB_PC       11               //alub pc
  `define AB_ADR      12               //alub address pc

  /*****************************************************************************************/
  /*                                                                                       */
  /* ALU operation control: aluop_sel - 2 MSBs fixed for unit sel                          */
  /*                                                                                       */
  /*****************************************************************************************/
  `define ALUOP_IDX 7
  `define ALUOP_RSTVAL 8'b00000000     //Reset Value for pipeline controls
  `define ALUOP_ADD    8'b01000000     //ALU math: add
  `define ALUOP_BADD   8'b01000001     //ALU math: byte add
  `define ALUOP_BDEC   8'b01000011     //ALU math: byte add (decrement)
  `define ALUOP_ADS    8'b01000100     //ALU math: add signed byte
  `define ALUOP_DAA    8'b01000101     //ALU math: byte add (daa)
  `define ALUOP_ADC    8'b01001000     //ALU math: add with carry
  `define ALUOP_BADC   8'b01001001     //ALU math: byte add with carry
  `define ALUOP_SUB    8'b01010000     //ALU math: subtract
  `define ALUOP_BSUB   8'b01010001     //ALU math: subtract
  `define ALUOP_SBC    8'b01100000     //ALU math: subtract with carry
  `define ALUOP_BSBC   8'b01100001     //ALU math: byte subtract with carry

  `define ALUOP_PASS   8'b00000000     //ALU logic: pass b bus
  `define ALUOP_BAND   8'b00000011     //ALU logic: byte and
  `define ALUOP_BOR    8'b00000101     //ALU logic: byte or
  `define ALUOP_BXOR   8'b00001001     //ALU logic: byte or
  `define ALUOP_CCF    8'b00010000     //ALU logic: complement carry
  `define ALUOP_SCF    8'b00010010     //ALU logic: set carry
  `define ALUOP_RLD1   8'b00011000     //ALU logic: rld first step
  `define ALUOP_RLD2   8'b00011010     //ALU logic: rld second step
  `define ALUOP_RRD1   8'b00011100     //ALU logic: rrd first step
  `define ALUOP_RRD2   8'b00011110     //ALU logic: rrd second step
  `define ALUOP_APAS   8'b00100000     //ALU logic: pass a bus

  `define ALUOP_RL     8'b10000000     //ALU shft: rotate left
  `define ALUOP_RLA    8'b10000001     //ALU shft: rotate left acc
  `define ALUOP_RLC    8'b10000010     //ALU shft: rotate left circular
  `define ALUOP_RLCA   8'b10000011     //ALU shft: rotate left circular acc
  `define ALUOP_RR     8'b10000100     //ALU shft: rotate right
  `define ALUOP_RRA    8'b10000101     //ALU shft: rotate right acc
  `define ALUOP_RRC    8'b10001000     //ALU shft: rotate right circular
  `define ALUOP_RRCA   8'b10001001     //ALU shft: rotate right circular acc
  `define ALUOP_SLA    8'b10010000     //ALU shft: shift left arithmetic
  `define ALUOP_SLL    8'b10011000     //ALU shft: shift left logical (x = (x << 1) | 1)
  `define ALUOP_SRL    8'b10100000     //ALU shft: shift right logical
  `define ALUOP_SRA    8'b10101000     //ALU shft: shift right arithmetic

  `define ALUOP_MLT    8'b11000000     //ALU mult: 8 bit multiplication
  /*****************************************************************************************/
  /*                                                                                       */
  /* ALU operation control: 6 encoded                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  `define AOP_IDX 5
  `define AOP_ADD      6'b000000       //ALU math: add
  `define AOP_BADD     6'b000001       //ALU math: byte add
  `define AOP_BDEC     6'b000011       //ALU math: byte add (decrement)
  `define AOP_ADS      6'b000100       //ALU math: add signed byte
  `define AOP_DAA      6'b000101       //ALU math: byte add (daa)
  `define AOP_ADC      6'b001000       //ALU math: add with carry
  `define AOP_BADC     6'b001001       //ALU math: byte add with carry
  `define AOP_SUB      6'b010000       //ALU math: subtract
  `define AOP_BSUB     6'b010001       //ALU math: subtract
  `define AOP_SBC      6'b100000       //ALU math: subtract with carry
  `define AOP_BSBC     6'b100001       //ALU math: byte subtract with carry

  `define AOP_PASS     6'b000000       //ALU logic: pass b bus
  `define AOP_BAND     6'b000011       //ALU logic: byte and
  `define AOP_BOR      6'b000101       //ALU logic: byte or
  `define AOP_BXOR     6'b001001       //ALU logic: byte or
  `define AOP_CCF      6'b010000       //ALU logic: complement carry
  `define AOP_SCF      6'b010010       //ALU logic: set carry
  `define AOP_RLD1     6'b011000       //ALU logic: rld first step
  `define AOP_RLD2     6'b011010       //ALU logic: rld second step
  `define AOP_RRD1     6'b011100       //ALU logic: rrd first step
  `define AOP_RRD2     6'b011110       //ALU logic: rrd second step
  `define AOP_APAS     6'b100000       //ALU logic: pass a bus

  `define AOP_RL       6'b000000       //ALU shft: rotate left
  `define AOP_RLA      6'b000001       //ALU shft: rotate left acc
  `define AOP_RLC      6'b000010       //ALU shft: rotate left circular
  `define AOP_RLCA     6'b000011       //ALU shft: rotate left circular acc
  `define AOP_RR       6'b000100       //ALU shft: rotate right
  `define AOP_RRA      6'b000101       //ALU shft: rotate right acc
  `define AOP_RRC      6'b001000       //ALU shft: rotate right circular
  `define AOP_RRCA     6'b001001       //ALU shft: rotate right circular acc
  `define AOP_SLA      6'b010000       //ALU shft: shift left arithmetic
  `define AOP_SLL      6'b011000       //ALU shft: shift left logical
  `define AOP_SRL      6'b100000       //ALU shft: shift right logical
  `define AOP_SRA      6'b101000       //ALU shft: shift right arithmetic

  `define AOP_MLT      6'b000000       //ALU mult: 8 bit multiplication 
  /*****************************************************************************************/
  /*                                                                                       */
  /* machine state - pseudo-one-hot                                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  `define STATE_IDX 31
  `define sRST   32'b00000000000000000000000000000000   //reset
  `define sDEC1  32'b00000000000000000000000000000011   //decode 1st opcode
  `define sIF2B  32'b00000000000000000000000000000101   //fetch 2nd opcode (2)
  `define sDEC2  32'b00000000000000000000000000001001   //decode 2nd opcode
  `define sOF1B  32'b00000000000000000000000000010001   //fetch 1st operand (2)
  `define sOF2A  32'b00000000000000000000000000100001   //fetch 2nd operand (1)
  `define sOF2B  32'b00000000000000000000000001000001   //fetch 2nd operand (2)
  `define sIF3A  32'b00000000000000000000000010000001   //fetch 3rd opcode (1)
  `define sIF3B  32'b00000000000000000000000100000001   //fetch 3rd opcode (2)
  `define sADR1  32'b00000000000000000000001000000001   //address calculate (1)
  `define sADR2  32'b00000000000000000000010000000001   //address calculate (2)
  `define sRD1A  32'b00000000000000000000100000000001   //read 1st operand (1)
  `define sRD1B  32'b00000000000000000001000000000001   //read 1st operand (2)
  `define sRD2A  32'b00000000000000000010000000000001   //read 2nd operand (1)
  `define sRD2B  32'b00000000000000000100000000000001   //read 2nd operand (2)
  `define sWR1A  32'b00000000000000001000000000000001   //write 1st operand (1)
  `define sWR1B  32'b00000000000000010000000000000001   //write 1st operand (2)
  `define sWR2A  32'b00000000000000100000000000000001   //write 2nd operand (1)
  `define sWR2B  32'b00000000000001000000000000000001   //write 2nd operand (2)
  `define sBLK1  32'b00000000000010000000000000000001   //block instruction (1)
  `define sBLK2  32'b00000000000100000000000000000001   //block instruction (2)
  `define sPCA   32'b00000000001000000000000000000001   //PC adjust
  `define sPCO   32'b00000000010000000000000000000001   //PC output
  `define sIF1A  32'b00000000100000000000000000000001   //fetch 1st opcode (1)
  `define sIF1B  32'b00000001000000000000000000000001   //fetch 1st opcode (2)
  `define sINTA  32'b00000010000000000000000000000001   //interrupt acknowledge (1)
  `define sINTB  32'b00000100000000000000000000000001   //interrupt acknowledge (2)
  `define sHLTA  32'b00001000000000000000000000000001   //halt & sleep (1)
  `define sHLTB  32'b00010000000000000000000000000001   //halt & sleep (2)
  `define sDMA1  32'b00100000000000000000000000000001   //dma transfer (1)
  `define sDMA2  32'b01000000000000000000000000000001   //dma transfer (2)
  `define sRSTE  32'b10000000000000000000000000000001   //reset exit

  `define  RST   32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0   //reset
  `define  DEC1  32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11   //decode 1st opcode
  `define  IF2B  32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x1   //fetch 2nd opcode (2)
  `define  DEC2  32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xx1   //decode 2nd opcode
  `define  OF1B  32'bxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxx1   //fetch 1st operand (2)
  `define  OF2A  32'bxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxx1   //fetch 2nd operand (1)
  `define  OF2B  32'bxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxx1   //fetch 2nd operand (2)
  `define  IF3A  32'bxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxx1   //fetch 3rd opcode (1)
  `define  IF3B  32'bxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxx1   //fetch 3rd opcode (2)
  `define  ADR1  32'bxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxx1   //address calculate (1)
  `define  ADR2  32'bxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxx1   //address calculate (2)
  `define  RD1A  32'bxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx1   //read 1st operand (1)
  `define  RD1B  32'bxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxx1   //read 1st operand (2)
  `define  RD2A  32'bxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx1   //read 2nd operand (1)
  `define  RD2B  32'bxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxx1   //read 2nd operand (2)
  `define  WR1A  32'bxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxx1   //write 1st operand (1)
  `define  WR1B  32'bxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx1   //write 1st operand (2)
  `define  WR2A  32'bxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxx1   //write 2nd operand (1)
  `define  WR2B  32'bxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxx1   //write 2nd operand (2)
  `define  BLK1  32'bxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxx1   //block instruction (1)
  `define  BLK2  32'bxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxx1   //block instruction (2)
  `define  PCA   32'bxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxx1   //PC adjust
  `define  PCO   32'bxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxx1   //PC output
  `define  IF1A  32'bxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx1   //fetch 1st opcode (1)
  `define  IF1B  32'bxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx1   //fetch 1st opcode (2)
  `define  INTA  32'bxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxx1   //interrupt acknowledge (1)
  `define  INTB  32'bxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxx1   //interrupt acknowledge (2)
  `define  HLTA  32'bxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxx1   //halt & sleep (1)
  `define  HLTB  32'bxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxx1   //halt & sleep (2)
  `define  DMA1  32'bxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxx1   //dma transfer (1)
  `define  DMA2  32'bx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx1   //dma transfer (2)
  `define  RSTE  32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1   //reset exit








