//Jul.11.2004

`define LONG_ACCESS 2'b00
`define WORD_ACCESS 2'b01
`define BYTE_ACCESS 2'b10



//Shift

//`define SHIFT_NOTHING 2'b00
`define SHIFT_LEFT 2'b01
`define SHIFT_RIGHT_UNSIGNED 2'b10
`define SHIFT_RIGHT_SIGNED 2'b11

//ALU
`define   ALU_NOTHING 4'b0000
`define   ALU_ADD     4'b0001
`define   ALU_SUBTRACT 4'b0010
`define   ALU_LESS_THAN_UNSIGNED 4'b0101 //Jul.5.2004
`define   ALU_LESS_THAN_SIGNED   4'b0100 //Jul.5.2004
`define   ALU_OR  4'b0011
`define   ALU_AND 4'b0110
`define   ALU_XOR 4'b0111
`define   ALU_NOR 4'b1000
//`define   ALU_NOR 4'b0000 //Jul.6.2004

//PC
`define    PC_INC   3'b000
`define    PC_HOLD  3'b001
`define    PC_IMM   3'b010
`define    PC_IMM_PLUS 3'b011
`define    PC_REG 3'b100
//`define    FLAG_SEL 3'b101
`define    PC_FLAG_SEL16 3'b101
`define    PC_DEC 3'b110

//ALU Right SEL
`define    Imm_signed  2'b00
`define    Imm_unsigned 2'b01
`define    A_RIGHT_ERT  2'b10
`define    IMM_26_SEL	2'b11

//ALU_LEFT_SEL
`define    PC_SEL 1'b1

//Shift amount Sel
`define   A_sel 1'b0
`define   Ers_d2_sel

//Memory_Signed_extenstion
`define M_unsigned 1'b0
`define M_signed   1'b1

//RRegSel
`define MOUT_SEL 2'b00
`define NREG_SEL 2'b01

//AREG ALU/MUL_SEL
//2'b00 => ALU_SEL 
`define MUL_hi_SEL  2'b10
`define MUL_lo_SEL  2'b11

//RF_INPUT SEL
`define RF_ALU_sel 2'b00
`define RF_Shifter_sel 2'b01
`define RF_PC_SEL	2'b010
`define SHIFT16_SEL 2'b11

//MUX
//`define STRAIGHT  2'b00
//`define AREG_SEL 2'b01
//`define RREG_SEL 2'b11


//RF INPUT ADDRESS
`define RF_Ert_sel 2'b00
`define RF_Erd_sel 2'b01
`define RF_R15_SEL 2'b10
`define RF_INTR_SEL 2'b11

`define Last_Reg 31
`define Intr_Reg 26 // Jul.7.2004 TRY FOR OS,, Use R26 as Interrput Return address.
//OPCODE

`define add  6'b100000
`define addu 6'b100001  
`define addi 6'b001000 
`define addiu 6'b001001 
`define sub  6'b100010  
`define subu 6'b100011 
      
`define and  6'b100100  
`define andi 6'b001100  
`define nor  6'b100111  
`define or   6'b100101  
`define ori  6'b001101  
       
`define lsl  6'b000000  
`define asr  6'b000011  
`define lsr  6'b000010
`define sllv 6'b000100 
`define srav 6'b000111
`define srlv 6'b000110  
       
`define xor  6'b100110  
`define xori 6'b001110  
       
`define lui  6'b001111       
       
      
     
`define comp_signed  		6'b101010    
`define comp_unsigned  		6'b101011  //Jun.29.2004    
`define comp_im_signed  	6'b001010      
`define comp_im_unsigned  	6'b001011  //Jun.29.2004    
      
`define beq   6'b000100      
`define bgtz  6'b000111   
`define blez  6'b000110    
`define bne   6'b000101      
      
//opecode "000001" =>   [20:16] Special Opecode
`define bltzal  5'b10000  //unsupported
`define bltz 5'b00000
`define bgezal 5'b10001  //unsupportedÅ@
`define bgez	5'b00001
`define bltzall 5'b10010 //unsupprted
`define bltzl   5'b00010 //unsupported
`define bgezall 5'b10011 //unsupported
`define bgezl   5'b00011 //unsupported

`define jump  		  	6'b000010  
`define jump_and_link_im  	6'b000011      
`define jump_and_link_register  6'b001001  
`define jmp_register		6'b001000  

//Load Instructions      
      
`define loadbyte_signed  	6'b100000       
`define loadbyte_unsigned 	6'b100100       
`define loadword_signed 	6'b100001       
`define loadword_unsigned  	6'b100101       
`define	loadlong  		    6'b100011  

//Store Instructions      
      
`define storebyte  6'b101000     
`define storeword  6'b101001      
`define storelong  6'b101011      

//Exception and Interrupt Instructions      
     
`define softwave_interrupt  6'b011010 
`define divs	6'b011010
`define divu	6'b011011
`define muls	6'b011000
`define mulu	6'b011001

`define mfhi	6'b010000
`define mflo	6'b010010

`define MUL_DIV_WORD_ACCESS 1'b1
`define MUL_DIV_BYTE_ACCESS 1'b0
`define MUL_DIV_MUL_SEL	1'b0


`define mult_nothing   4'b0000
`define mult_read_lo   4'b0000
`define mult_read_hi   4'b0001
`define mult_write_lo  4'b0011
`define mult_write_hi  4'b0100
`define mult_mult      4'b1000
`define mult_signed_mult   4'b1010
`define mult_divide        4'b1100
`define mult_signed_divide 4'b1110

`define SHIFT_AMOUNT_IMM_SEL 1'b0
`define SHIFT_AMOUNT_REG_SEL 1'b1


//`define RAM4K
`define RAM16K
//`define RAM32K



//UART PORT RATE SELECT
`define COUNTER_VALUE1 216  //115.2kbps for clock=50MHz
`define COUNTER_VALUE2 (`COUNTER_VALUE1*2+1)
`define COUNTER_VALUE3 (`COUNTER_VALUE1+3)


`define RTL_SIMULATION  //comment out for synthesis
//`define ALTERA //comment out if XILINX is used
`define XILINX  //comment out if Altera is used
//IO  Map
// All access must be 32bit word 
//3f80  usuall SP address (set by program)
//16KRAM
// 3fc0-3fef : AES reserved
// 3ff0 : debug port
// 3ff4 : debug port long
// 3ff8 : interrupt set address
// 3ffc : uart port
// 3ffc : [7:0] write_port/read_port
//		  [8] write_busy
//		  [31:9] :reserved		



   	  `define Print_Port_Address      16'h3ff0  //ATMEL Big Endian
      `define Print_CAHR_Port_Address 16'h3ff1
      `define Print_INT_Port_Address  16'h3ff2  //First ADDRESS
      `define Print_LONG_Port_Address 16'h3ff4  //First ADDRESS

	`define UART_PORT_ADDRESS 16'h3ffc //
	`define INTERUPPT_ADDRESS 16'h3ff8 //		
