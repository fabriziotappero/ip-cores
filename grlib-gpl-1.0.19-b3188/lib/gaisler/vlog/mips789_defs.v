/******************************************************************
 *                                                                * 
 *    Author: Liwei                                               * 
 *                                                                * 
 *    This file is part of the "mips789" project.                 * 
 *    Downloaded from:                                            * 
 *    http://www.opencores.org/pdownloads.cgi/list/mips789        * 
 *                                                                * 
 *    If you encountered any problem, please contact me via       * 
 *    Email:mcupro@opencores.org  or mcupro@163.com               * 
 *                                                                * 
 ******************************************************************/

`ifndef INCLUDE_H
`define INCLUDE_H

`define SZWORD 2'b10
`define SZHALF 2'b01
`define SZBYTE 2'b00

 `define   FRQ                    50000000  
 `define   SER_RATE               19200

 `define   FW_ALU                 3'b001              
 `define   FW_MEM                 3'b010              
 `define   FW_NOP                 3'b100     

 `define   ALU_MFHI               6                   
 `define   ALU_MFLO               7                   
 `define   ALU_MULTTU             8                   
 `define   ALU_MULT               9                   
 `define   ALU_DIVU               10                  
 `define   ALU_DIV                11   


 `define   DMEM_SB                1                   
 `define   DMEM_LBS               2                   
 `define   DMEM_LB                3                   
 `define   DMEM_LBU               4                   
 `define   DMEM_SW                5                   
 `define   DMEM_LW                6                   
 `define   DMEM_SH                7                   
 `define   DMEM_LHS               8                   
 `define   DMEM_LH                9                   
 `define   DMEM_LHU               10                  
 `define   DMEM_NOP               0 

 `define   ALU_SRL                1                   
 `define   ALU_SLL                2                   
 `define   ALU_SRA                4  

 `define   WB_ALU                 0                   
 `define   WB_MEM                 1                   
 `define   WB_NOP                 0  

 `define   RD_RD                  1                   
 `define   RD_RT                  2                   
 `define   RD_R31                 3                   
 `define   RD_NOP                 0                   
 `define   RD_ZR                  0 

 `define   EXT_CTL_LEN            3                   
 `define   RD_SEL_LEN             2                   
 `define   CMP_CTL_LEN            3                   
 `define   PC_GEN_CTL_LEN         3                   
 `define   FSM_CTL_LEN            3                   
 `define   MUXA_CTL_LEN           2                   
 `define   MUXB_CTL_LEN           2                   
 `define   ALU_FUNC_LEN           5                   
 `define   ALU_WE_LEN             1                   
 `define   DMEM_CTL_LEN           5                   
 `define   WB_MUX_CTL_LEN         1                   
 `define   WB_WE_LEN              1                   
 `define   INS_LEN                32                  
 `define   PC_LEN                 32                  
 `define   SPC_LEN                32                  
 `define   R32_LEN                32                  
 `define   R5_LEN                 5                   
 `define   R1_LEN                 1                   
 `define   R2_LEN                 2                   
 `define   R3_LEN                 3                   
 `define   R4_LEN                 4    

 `define   ALU_ADD                12                  
 `define   ALU_ADDU               13                  
 `define   ALU_SUB                14                  
 `define   ALU_SUBU               15                  
 `define   ALU_SLTU               16                  
 `define   ALU_SLT                17                  
 `define   ALU_OR                 18                  
 `define   ALU_AND                19                  
 `define   ALU_XOR                20                  
 `define   ALU_NOR                21                  
 `define   ALU_PA                 22                  
 `define   ALU_PB                 23 

 `define   D2_MUL_DLY             4'b0000             
 `define   IDLE                   4'b0001             
 `define   MUL                    4'b0010             
 `define   CUR                    4'b0011             
 `define   RET                    4'b0100             
 `define   IRQ                    4'b0101             
 `define   RST                    4'b0110             
 `define   LD                     4'b0111             
 `define   NOI                    4'b1000             


 `define   ALU_NOP                0                   
 `define   ALU_MTLO               30                  
 `define   ALU_MTHI               31                  
 `define   ALU_MULTU              8  

 `define   PC_IGN                 1                   
 `define   PC_KEP                 2                   
 `define   PC_IRQ                 4                   
 `define   PC_RST                 8    

 `define   PC_J                   1                   
 `define   PC_JR                  2                   
 `define   PC_BC                  4                   
 `define   PC_NEXT                5                   
 `define   PC_NOP                 0                   
 `define   PC_RET                 6                   
 `define   PC_SPC                 6  

 `define   RF                     13                  
 `define   EXEC                   10                  
 `define   DMEM                   4                   
 `define   WB                     2                   
 `define   MUXA_PC                1                   
 `define   MUXA_RS                2                   
 `define   MUXA_EXT               3                   
 `define   MUXA_SPC               0                   
 `define   MUXA_NOP               0                   
 `define   MUXB_RT                1                   
 `define   MUXB_EXT               2                   
 `define   MUXB_NOP               0                   

 `define   CMP_BEQ                1                   
 `define   CMP_BNE                2                   
 `define   CMP_BLEZ               3                   
 `define   CMP_BGEZ               4                   
 `define   CMP_BGTZ               5                   
 `define   CMP_BLTZ               6                   
 `define   CMP_NOP                0                   

 `define   FSM_CUR                1                   
 `define   FSM_MUL                2                   
 `define   FSM_RET                4                   
 `define   FSM_NOP                0                   
 `define   FSM_LD                 5                   
 `define   FSM_NOI                6                   

 `define   REG_NOP                0                   
 `define   REG_CLR                1                   
 `define   REG_KEP                2                   

 `define   EXT_SIGN               1                   
 `define   EXT_UNSIGN             2                   
 `define   EXT_J                  3                   
 `define   EXT_B                  4                   
 `define   EXT_SA                 5                   
 `define   EXT_S2H                6                   
 `define   EXT_NOP                0                   

 `define   EN                     1                   
 `define   DIS                    0                   
 `define   IGN                    0                   

 `define   UART_DATA_ADDR         'H80_00_00_28       
 `define   CMD_ADDR               'H80_00_00_14       
 `define   STATUS_ADDR            'H80_00_00_18       
 `define   SEG7LED_ADDR           'H80_00_00_1C       
 `define   SIM_DIS_ADDR           'H80_00_00_20       
 `define   LCD_DATA_ADDR          'H80_00_00_24       
 `define   IRQ_MASK_ADDR          'H80_00_00_34       
 `define   TMR_IRQ_ADDR           'H80_00_00_28       
 `define   TMR_DATA_ADDR          'H80_00_00_34       
 `define   KEY1_IRQ_ADDR          'H80_00_00_2C       
 `define   KEY2_IRQ_ADDR          'H80_00_00_30       

 `define   COUNTER_VALUE1         (`FRQ/`SER_RATE/2-1)
 `define   COUNTER_VALUE2         (`COUNTER_VALUE1*2+1)
 `define   COUNTER_VALUE3         (`COUNTER_VALUE1+3)  

 `define DEFAULT_IRQ_ADDR 		  'H00_00_00_5C

   `define ALTERA

`else 


`endif
