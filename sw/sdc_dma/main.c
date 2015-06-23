

/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : Development Board Debugger Example 
// File Name                      : main.c
// Prepared By                    : jb
// Project Start                  : 2009-01-01


/*$$COPYRIGHT NOTICE*/
/******************************************************************************/
/*                                                                            */
/*                      C O P Y R I G H T   N O T I C E                       */
/*                                                                            */
/******************************************************************************/

// Copyright (c) ORSoC 2009 All rights reserved.

// The information in this document is the property of ORSoC.
// Except as specifically authorized in writing by ORSoC, the receiver of
// this document shall keep the information contained herein confidential and
// shall protect the same in whole or in part thereof from disclosure and
// dissemination to third parties. Disclosure and disseminations to the receiver's
// employees shall only be made on a strict need to know basis.


/*$$DESCRIPTION*/
/******************************************************************************/
/*                                                                            */
/*                           D E S C R I P T I O N                            */
/*                                                                            */
/******************************************************************************/

// Perform some simple functions, used as an example when first using the 
// debug cable and proxy with GDB.

/*$$CHANGE HISTORY*/
/******************************************************************************/
/*                                                                            */
/*                         C H A N G E  H I S T O R Y                         */
/*                                                                            */
/******************************************************************************/

// Date		Version	Description
//------------------------------------------------------------------------
// 090101	1.0	First version				jb

/*$$INCLUDE FILES*/
/******************************************************************************/
/*                                                                            */
/*                      I N C L U D E   F I L E S                             */
/*                                                                            */
/******************************************************************************/

#define INCLUDED_FROM_C_FILE

#include "orsocdef.h"
#include "board.h"
#include "uart.h"
#include "sd_controller.h"
/*$$PRIVATE MACROS*/
/******************************************************************************/
/*                                                                            */
/*                      P R I V A T E   M A C R O S                           */
/*                                                                            */
/******************************************************************************/

/*$$GLOBAL VARIABLES*/
/******************************************************************************/
/*                                                                            */
/*                   G L O B A L   V A R I A B L E S                          */
/*                                                                            */
/******************************************************************************/

/*$$PRIVATE VARIABLES*/
/******************************************************************************/
/*                                                                            */
/*                  P R I V A T E   V A R I A B L E S                         */
/*                                                                            */
/******************************************************************************/


/*$$FUNCTIONS*/
/******************************************************************************/
/*                                                                            */
/*                          F U N C T I O N S                                 */
/*                                                                            */
/******************************************************************************/


/******************************************************************************/
/*                        W R I T E  T O EXTERNAL SDRAM 1                     */
/******************************************************************************/

// Write to External SDRAM  
void Write_External_SDRAM_1(void)
{   
   uint32      i;
   uint32      read;
   uint32      range;
   uint32      adr_offset;

   range      = 0x7ff;        // Max range: 0x7fffff
   adr_offset = 0x00000000;  // External memory offset
   
   for (i=0x0; i < range; i=i+4) {
      REG32(adr_offset + i)   = (adr_offset + i);
   }

   for (i=0x0; i < range; i=i+4) {
     read = REG32(adr_offset + i);
     if (read != (adr_offset + i)) {
       while(TRUE){            //ERROR=HALT PROCESSOR 
       }       
     }
   }
}


/*$$EXTERNAL EXEPTIONS*/
/******************************************************************************/
/*                  E X T E R N A L   E X E P T I O N S                       */
/******************************************************************************/


void external_exeption()
{      
  REG uint8 i;
  REG uint32 PicSr,sr;

}
 
/*$$MAIN*/
/******************************************************************************/
/*                                                                            */
/*                       M A I N   P R O G R A M                              */
/*                                                                            */
/******************************************************************************/

struct sd_card_csr {
unsigned int PAD:18;
unsigned  int CMDI:6;
unsigned  int CMDT:2;
unsigned  int DPS:1;
unsigned  int CICE_s:1;
unsigned  int CRCE_s:1;
unsigned  int  RSVD:1;
unsigned  int RTS:2;
} ;





void Start()
{
  struct sd_card_csr *sd_set_reg = (struct sd_card_csr *)  (SD_CONTROLLER_BASE+SD_COMMAND);

  volatile unsigned long rtn_reg=0;
  volatile  unsigned long rtn_reg1=0;
   
  int i;
  unsigned char block[512];
  unsigned char blocka[512];
  unsigned char blockb[512];
		
  unsigned char rec_block[512];
  unsigned char rec_blocka[512];
  unsigned char rec_blockb[512];
  
  //Generate som data to be writen

  for  (i =0; i<512;i++)
   block[i]=i;
   
  for  (i =0; i<512;i++)
   blocka[i]=i+8;
   
  for  (i =0; i<512;i++)
   blockb[i]=0xb6;    

  unsigned long b=0x0001;
   sd_card sd_card_0;
  
   
   uart_init();

	sd_card_0 = sd_controller_init(); 
    if (sd_card_0.Active==1)
	{
		uart_print_str("Init 2 succes!\n");
		uart_print_str("\nvoltage_windows:\n");
		uart_print_long(sd_card_0.Voltage_window);
		uart_print_str("\nRCA_Nr:\n");
		uart_print_long(sd_card_0.rca);
		uart_print_str("\nphys_spec_2_0 Y/N 1/0? :\n");
		uart_print_long(sd_card_0.phys_spec_2_0);
		uart_print_str("\nHCS? :\n");
		uart_print_long(sd_card_0.phys_spec_2_0);
			uart_print_str(":\n");
	}
	else
		uart_print_str("Init2  failed :/!\n");

	   	   
        SD_REG(SD_COMMAND) = CMD9  |WORD_0| CICE | CRCE | RSP_146;  
		SD_REG(SD_ARG)=sd_card_0.rca | 0xf0f0;
           if (!sd_wait_rsp())
			 	uart_print_str(" send failed :/!\n");
		 else{
		 	  uart_print_str("CSD 0 \n");
		  uart_print_long( SD_REG(SD_RESP1)  ) ;
	        	  uart_print_str("  \n");
		}		
  
  	      uart_print_str("error?  \n");
		  uart_print_long( SD_REG( SD_ERROR_INT_STATUS)  ) ;
 

     //Put in transfer state

 
	    SD_REG(SD_COMMAND) = CMD7 | CICE | CRCE | RSP_48;  
		SD_REG(SD_ARG)=sd_card_0.rca | 0xf0f0;
		if (!sd_wait_rsp())
			 	uart_print_str("Go send failed :/!\n");
		
		else if (   SD_REG(SD_RESP1) == (CARD_STATUS_STB  |  READY_FOR_DATA ) )
			uart_print_str("Ready to transfer data!\n");
		
     //Set block size
			
		SD_REG(SD_COMMAND) = CMD16 | CICE | CRCE | RSP_48;  
		SD_REG(SD_ARG)=512;
		if (!sd_wait_rsp())
			 	uart_print_str("Go send failed :/!\n");	
	 	uart_print_str("Card Status reg CMD16: \n");
    	  uart_print_long( SD_REG(SD_RESP1)  ) ; 

	//Set Bus width to 4, CMD55 followed by ACMD 6
		 REG32(SD_CONTROLLER_BASE+SD_COMMAND) = CMD55|RSP_48; 
		 REG32(SD_CONTROLLER_BASE+SD_ARG) =sd_card_0.rca | 0xf0f0;
	 		if (!sd_wait_rsp())
			 		uart_print_str("CMD55 send failed :/!\n");
		 
		 SD_REG(SD_COMMAND) = ACMD6 | CICE | CRCE | RSP_48;  
		 SD_REG(SD_ARG)=0x2;
			if (!sd_wait_rsp())
			 		uart_print_str("ACMD6 send failed :/!\n");
					
		 uart_print_str("Card Status reg ACMD6: \n");
		 uart_print_long( SD_REG(SD_RESP1)  ) ; 	
		 uart_print_str("\n");	
		
		 		int cnt=0;
		
  	      uart_print_str("FREE BD beg: \n");
		  uart_print_long( SD_REG(BD_STATUS)  ) ; 
		  uart_print_str("\n");
 
		SD_REG(BD_TX)  = &block;
		  SD_REG(BD_TX)  = 512;
		  SD_REG(BD_TX)  = &blocka;
		  SD_REG(BD_TX)  = 1024;
		  SD_REG(BD_TX)  = &blockb;
		  SD_REG(BD_TX)  = 2048; 
		 
		  SD_REG(BD_RX)  = &rec_block;
		  SD_REG(BD_RX)  = 512;
		  SD_REG(BD_RX)  = &rec_blocka;
		  SD_REG(BD_RX)  = 1024;
		  SD_REG(BD_RX)  = &rec_blockb;
		  SD_REG(BD_RX)  = 2048;
	
		//Check data transfer complete statusbit
		//(An easier way is to check the BD_STATUS and wait for it to get Empty and then check for transfer errors)    
		while (  (( SD_REG(BD_ISR)  &1)  !=1  ) ){
		rtn_reg= SD_REG(BD_ISR) ;
		}
		 SD_REG(BD_ISR) =0;				
		while (  (( SD_REG(BD_ISR)  &1)  !=1  ) ){
		rtn_reg= SD_REG(BD_ISR) ;
		}		
		SD_REG(BD_ISR) =0;
		while (  (( SD_REG(BD_ISR)  &1)  !=1  ) ){
		rtn_reg= SD_REG(BD_ISR) ;
		} 
		 SD_REG(BD_ISR) =0;
		while (  (( SD_REG(BD_ISR)  &1)  !=1  ) ){
		rtn_reg= SD_REG(BD_ISR) ;
		}
		SD_REG(BD_ISR) =0;
		while (  (( SD_REG(BD_ISR)  &1)  !=1  ) ){
		rtn_reg= SD_REG(BD_ISR) ;
		}
		 SD_REG(BD_ISR) =0;
		while (  (( SD_REG(BD_ISR)  &1)  !=1  ) ){
		rtn_reg= SD_REG(BD_ISR) ;
		}
		SD_REG(BD_ISR) =0;
			
			
			
		 uart_print_str("FREE BD: \n");
		 uart_print_long( SD_REG(BD_STATUS)  ) ; 
		 uart_print_str("\n");
		 SD_REG(BD_ISR) =0;
		 uart_print_str("\n"); 
		   for  (i =0; i<512;i++) {
		   	uart_print_short (rec_block[i]);
			uart_print_str("."); 
			} 
				uart_print_str("\n"); 
				   for  (i =0; i<512;i++) {
		   	uart_print_short (rec_blocka[i]);
			uart_print_str("."); 
			} 
				uart_print_str("\n"); 
		   for  (i =0; i<512;i++) {
		   	uart_print_short (rec_blockb[i]);
			uart_print_str("."); 
			} 
			
		
  		uart_print_str("done"); 
  
  
  
  
    #endif
  
  
  
  


}

