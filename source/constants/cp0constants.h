#ifndef _CP0CONSTANTS_H
#define _CP0CONSTANTS_H



//! Reset exception constant
/*!
  The RESET exception vector is at address 0xbfc00000
*/
#define EXCEPTION_RESET "10111111110000000000000000000000"

//! UTLB exception constant
/*!
  The UTLB Miss exception vection is at address 0x80000000
  This exception is not implemented in this version og the risc cpu
*/
#define EXCEPTION_UTLB  "10000000000000000000000000000000"

//! UTLB exception (Bootstrap Exception Vector)
/*
  If BEV bit in the Status register is set to 1 the UTLB exception vector is changed to 0xbfc00100.
  This exception is not implemented in this version og the risc cpu
*/
#define EXCEPTION_ULTB_BEV "10111111110000000000000100000000"

//! General exception
/*!
  The General exception vector which i used for all other types of exception is at address 0x80000080
*/
#define EXCEPTION_GENERAL "10000000000000000000000010000000"

//! General exception vector for integer overflow
/*!
  0x80000080 + 0x180 = 0x80000200
 */
#define EXCEPTION_GENERAL_INT_OVF "10000000000000000000001000000000"

//! General exception (Bootstrap Exception Vector)
/*
  If BEV bit in the Status register is set to 1 the General exception vector is changed to 0xbfc00180
*/
#define EXCEPTION_GENERAL_BEV "10111111110000000000000110000000"

//! Int cause
/*!
  External interrupt
*/
#define CAUSE_INT "0000"

//! MOD
/*!
  TLB modification exception - NOT Implemented
*/
#define CAUSE_MOD "0001"

//! TLBL
/*!
  TLB miss exception (Load or instruction fetch) - NOT Implemented
*/
#define CAUSE_TLBL "0010"

//! TLBS
/*!
  TLB miss exception (Store) - NOT Implemented
*/
#define CAUSE_TLBS "0011"

//! AdEL
/*!
  Address error exception (Load or instruction fetch)
*/
#define CAUSE_ADEL "0100"

//! AdES
/*!
  Address error exception (Store)
*/
#define CAUSE_ADES "0101"

//! IBE
/*!
 Bus error exception (for an instruction fetch) - NOT Implemented
*/
#define CAUSE_IBE "0110"

//! DBE
/*!
  Bus error exception (for a data load or store) - NOT Implemented
*/
#define CAUSE_DBE "0111"

//! Sys
/*!
  Syscall exception
*/
#define CAUSE_SYS "1000"

//! Bp
/*!
  Breakpoint exception
*/
#define CAUSE_BP "1001"

//! RI
/*! 
  Reserved Instruction exception - NOT Implemented
*/
#define CAUSE_RI "1010"

//! CpU
/*! 
  Coprocessor Unusable expection
*/
#define CAUSE_CPU "1011"

//! Ovf
/*!
  Arithmetic overflow exception
*/
#define CAUSE_OVF "1100"

  //! The Context register (4)
  /*!
    [31,21] PTEBase
    [20,2] BadVPN
  */
  // sc_signal<sc_lv<32> > context_register;


  //! Proccesor cycle count (9)
  /*!
    [31,0] Count
  */
  // sc_signal<sc_lv<32> > count_register;

  //! Timer interrupt control (11)
  /*!
    [31,0] Compare 
  */
  // sc_signal<sc_lv<32> > compare_register;

  //! The Status register (12)
  /*!
     [31,28] CU3-CU0
     [27] RP
     [26] FR
     [25] RE
     [24] MX
     [23] PX
     [22] BEV
     [21] TS
     [20] SR
     [19] NMI
     [15,8] IM7-IM0 
     [7] KX
     [6] SX
     [5] UX
     [4,3] KSU
     [2] ERL
     [1] EXL
     [0] IE
     Note: To enable interrupt => IE=1, EXL=0, ERL=0 (and Debug_DM=0 OBS: not implemented). 
  */
  // sc_signal<sc_lv<32> > status_register;

  //! The Cause register (13)
  /*!
    0[31] BD                             
    [29,28] CE
    [23] IV
    [22] WP
    [15,8] IP (6 hardware IP[7,2] and 2 software IP[1,0])
    [5,2] ExcCode 
  */
  // sc_signal<sc_lv<32> > cause_register;


  //! The EPC (Exception Program Counter) register (14)
  /*!
    [31,0] EPC
  */
  // sc_signal<sc_lv<32> > epc_register;


  //! The PRID (Processor Revision Identifier) register (15)
  /*!
    [31,24] Company Option
    [23,16] CompanyID
    [15,8] ProcessorID
    [7,0] Revision
  */
  /// sc_signal<sc_lv<32> > prid_register;


  //! Configuration Register, Selection 0(16) 
  /*!
    [31] M
    [30,16] Impl
    [15] BE
    [14,13] AT
    [12,10] AR
    [9,7] MT
    [2,0] K0
  */
  // sc_signal<sc_lv<32> > config_register;


  //! Old Instruction addr
  /*!
    This register is used to store previous instruction address.
  */
  // sc_signal<sc_lv<32> > id_ex_pc_in;


#endif
