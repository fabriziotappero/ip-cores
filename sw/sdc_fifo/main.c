
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
#include "main.h"
#define SD_REG(REG)  REG32(SD_CONTROLLER_BASE+REG) 
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






//TO do
// Always check if error in repose (CRC, CICE) etc
// Always check for CICM (Command inhibit before senindg)
// Timeout when polling
// Divied into dividing Functions
// Clean up


#define BUSY 0x80
#define CRC_TOKEN 0x29

//SDC_REGISTERS
#define TX_CMD_FIFO 0x00
#define RX_CMD_FIFO 0x04
#define TX_DATA_FIFO 0x08
#define RX_DATA_FIFO 0x0C
#define STATUS 0x10
#define CONTROLL 0x14
#define TIMER_REG 0x18

//Program Defines
#define TRANSMISSION_FAILURE 1
#define TRANSMISSION_SUCCESSFUL 0
#define BYTE_1_MASK 0x000000FF
#define BYTE_2_MASK 0x0000FF00
#define BYTE_3_MASK 0x00FF0000
#define BYTE_4_MASK 0xFF000000
#define MMC_DATA_SIZE 512

BYTE MMCWRData[MMC_DATA_SIZE];
BYTE MMCRDData[MMC_DATA_SIZE];

unsigned char rca[2];

bool mmc_get_cmd_bigrsp (volatile unsigned char *rsp)
{
   unsigned char rtn_reg=0;
   unsigned char rtn_reg_timer=0;
  int arr_cnt=0;
 rtn_reg_timer= SD_REG(TIMER_REG);
  while (rtn_reg_timer != 0)
  {
     rtn_reg = SD_REG(STATUS);
		 if  (( rtn_reg & 0x2) != 0x2) //RX Fifo not Empty
		 {
			 rsp[arr_cnt]=SD_REG(RX_CMD_FIFO);
			 arr_cnt++;			 	
            
		 }
		 if (arr_cnt==15)
				return 1;
      rtn_reg_timer= SD_REG(TIMER_REG);
  }
  return 0;
}

/************************** SD mmc_get_cmd_rsp *********************************/
/*
* Read CMD_RX_FIFO, add to the rsp array, 
* 1 on success, return 0 at timeout
*
*/
bool mmc_get_cmd_rsp (volatile unsigned char *rsp)
{
   volatile unsigned char rtn_reg=0;
   volatile unsigned char rtn_reg_timer=0;
  int arr_cnt=0;
 rtn_reg_timer= SD_REG(TIMER_REG);
  while (rtn_reg_timer != 0)
  {
     rtn_reg = SD_REG(STATUS);
		 if  (( rtn_reg & 0x2) != 0x2) //RX Fifo not Empty
		 {
			 rsp[arr_cnt]=SD_REG(RX_CMD_FIFO);
			 arr_cnt++;			 	
            
		 }
		 if (arr_cnt==5)
				return 1;
      rtn_reg_timer= SD_REG(TIMER_REG);
  }
  return 0;
}






int  mmc_init() 

{

	 volatile unsigned char rtn_reg=0;     
	 volatile unsigned int spv_2_0 =0;
	 volatile unsigned char response[15];
	 volatile unsigned char out_cmd[5];
	 response[0]=0; 	
	 //Reset the hardware
	 /* initialise the MMC card into SD-Bus mode, is performed in HW*/
	 SD_REG(CONTROLL)=1;
	 SD_REG(CONTROLL)=0;

     //Reset SD Card. CMD 0, Arg 0. 
	 //No response, wait for timeout
	 SD_REG(TX_CMD_FIFO)=0x40;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;

	 while ( SD_REG(TIMER_REG) != 0){}

     //Check for SD 2.0 Card, 
	 SD_REG(TX_CMD_FIFO)=0x48;
	 SD_REG(TX_CMD_FIFO)=0x00;
	  SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x01;
	 SD_REG(TX_CMD_FIFO)=0xAA;	

     //if response, card is v2.0 compatible, else reset card.
     if (mmc_get_cmd_rsp(&response[0]) )
       spv_2_0 = 1;
	 else
	 {
	   SD_REG(CONTROLL)=1;
	   SD_REG(CONTROLL)=0;
       SD_REG(TX_CMD_FIFO)=0x40;
	   SD_REG(TX_CMD_FIFO)=0x00;
	   SD_REG(TX_CMD_FIFO)=0x00;
	   SD_REG(TX_CMD_FIFO)=0x00;
	   SD_REG(TX_CMD_FIFO)=0x00;

	   while ( SD_REG(TIMER_REG) != 0){}
	 }
	 
	 if(spv_2_0==0)
	 {  
		//Send CMD55+ACMD41 until Busy bit is cleared (Response[0][8]==1)
		while ( (rtn_reg & BUSY) != BUSY )
		{	SD_REG(TX_CMD_FIFO)=0x77;
			SD_REG(TX_CMD_FIFO)=0x00;
			SD_REG(TX_CMD_FIFO)=0x00;
			SD_REG(TX_CMD_FIFO)=0x00;
			SD_REG(TX_CMD_FIFO)=0x00;
			if ( mmc_get_cmd_rsp(&response[0]) && response[4]==0) 
			{
				SD_REG(TX_CMD_FIFO)=0x69;
				SD_REG(TX_CMD_FIFO)=0x00;
				SD_REG(TX_CMD_FIFO)=0x00;
				SD_REG(TX_CMD_FIFO)=0x00;
				SD_REG(TX_CMD_FIFO)=0x00;
				if (mmc_get_cmd_rsp(&response[0]))
					rtn_reg = response[0];
				else
					return TRANSMISSION_FAILURE;
	  }
	  else
		 return TRANSMISSION_FAILURE; 
	 }

	 }
	 //else Physical Specification Version 2.00
	 //Check response
	 //Initialization (ACMD41 HCS=1)
	 //Check for High Capacity or Standrd Capacity,  Ver.2.00 Card
     
     //CMD 2- get CSD, 136 bit response (Bit-40 this)
	 SD_REG(TX_CMD_FIFO)=0xC2;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 
     if (!mmc_get_cmd_bigrsp(&response[0]))
		return TRANSMISSION_FAILURE;

	 //CMD 3- get RCA nr		
	 SD_REG(TX_CMD_FIFO)=0x43;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
	 SD_REG(TX_CMD_FIFO)=0x00;
     if (mmc_get_cmd_rsp(&response[0]))
	 {
		 rca[0] = response[0];
		 rca[1] = response[1];	
	 }
	 else
		return TRANSMISSION_FAILURE;

     //Put card in transfer state, CMD 7
	 SD_REG(TX_CMD_FIFO)=0x47;
	 SD_REG(TX_CMD_FIFO)= rca[0] ;
	 SD_REG(TX_CMD_FIFO)= rca[1] ;
	 SD_REG(TX_CMD_FIFO)=0x0f;
	 SD_REG(TX_CMD_FIFO)=0x0f;
	 if (!mmc_get_cmd_rsp(&response[0]))
	   return TRANSMISSION_FAILURE;
      
	 //Set block size 512. CMD 16
	 SD_REG(TX_CMD_FIFO)=0x50;
	  SD_REG(TX_CMD_FIFO)=0;
	   SD_REG(TX_CMD_FIFO)=0;
	 SD_REG(TX_CMD_FIFO)=0x02;
	 SD_REG(TX_CMD_FIFO)=0;
	 if (!mmc_get_cmd_rsp(&response[0]))
	    return TRANSMISSION_FAILURE;

	  //Set bus width to 4. CMD 55 + ACMD 6	  
	  SD_REG(TX_CMD_FIFO)=0x77;
	  SD_REG(TX_CMD_FIFO)= rca[0] ;
	  SD_REG(TX_CMD_FIFO)= rca[1] ;
	   SD_REG(TX_CMD_FIFO)=0;
	    SD_REG(TX_CMD_FIFO)=0;
	  if (!mmc_get_cmd_rsp(&response[0]))
		return TRANSMISSION_FAILURE;
	  // ACMD 6
	  SD_REG(TX_CMD_FIFO)=0x46;
	   SD_REG(TX_CMD_FIFO)=0;
	    SD_REG(TX_CMD_FIFO)=0;
		 SD_REG(TX_CMD_FIFO)=0;
	  SD_REG(TX_CMD_FIFO)=0x02;  
	  if (!mmc_get_cmd_rsp(&response[0]))
	  		return TRANSMISSION_FAILURE;

   return TRANSMISSION_SUCCESSFUL;
}


int mmc_write_block(uint32 block_number)
{  
   uint32 var;
   volatile unsigned char rtn_reg=0;     
     unsigned char response[4];
   int i;
  
   
    var= block_number << 9 ;

   for (i=0; i < MMC_DATA_SIZE; i++)   
	   SD_REG(TX_DATA_FIFO) = MMCWRData[i];
   

   //Send CMD24, Single block write
    SD_REG(TX_CMD_FIFO)=0x58;
	SD_REG(TX_CMD_FIFO)=(BYTE)((var >> 24) & 0xFF);
	SD_REG(TX_CMD_FIFO)=(BYTE)((var >> 16) & 0xFF);
	SD_REG(TX_CMD_FIFO)=(BYTE)((var >> 8) & 0xFF);
	SD_REG(TX_CMD_FIFO)=(BYTE)(var & 0xFF);
	if (!mmc_get_cmd_rsp(&response[0]))
	  		return TRANSMISSION_FAILURE;
    
    //Wait for TX_DATA_FIFO to get empty		
	while ( (SD_REG(STATUS)& 0x04) == 0x04) {}
    //Wait for RX_DATA_FIFO to not get empty, indicate transmision is complete and CRC token is avaible.	
	while ( (SD_REG(STATUS) & 0x08) == 0x08) {}
	
	//Check for correct CRC repsonse token == 0x29...
	//Busy cehck is performed in HW
	rtn_reg =SD_REG(RX_DATA_FIFO);    
	if ((rtn_reg & CRC_TOKEN) == CRC_TOKEN)
	 return TRANSMISSION_SUCCESSFUL;
	else
	 return TRANSMISSION_FAILURE;
}

int mmc_read_block(uint32 block_number)
{
    volatile int i = 0;
    volatile unsigned char response[4];
	volatile unsigned char rsp;
   uint32 var;   
   WORD Checksum;
  
    var= block_number << 9;
 
    SD_REG(TX_CMD_FIFO)=0x51;
	SD_REG(TX_CMD_FIFO)=(BYTE)((var >> 24) & 0xFF);
	SD_REG(TX_CMD_FIFO)=(BYTE)((var >> 16) & 0xFF);
	SD_REG(TX_CMD_FIFO)=(BYTE)((var >> 8) & 0xFF);
	SD_REG(TX_CMD_FIFO)=(BYTE)(var & 0xFF);
   if (!mmc_get_cmd_rsp(&response[0]))
	  		return TRANSMISSION_FAILURE;

rsp =  SD_REG(STATUS) & 0x08;
while ( rsp == 0x08) {
rsp =  SD_REG(STATUS) & 0x08;}
  //Checksum is notread

i=0;
  
 /* while (i<MMC_DATA_SIZE){
   
  MMCRDData[i]=SD_REG(RX_DATA_FIFO);
  i++;
  } 
   */
     
	 BYTE *p;
  p=&MMCRDData[0];
  
   register int  RX_REG asm ("r0") ;
    register int RSP asm ("r6") ;
    register int  LOOP_END asm ("r2") ;
	register int  DAT_RSP asm ("r3") ;
	
	 register int  SAVE_RX_REG asm ("r18") ;
	 register int  SAVE_RSP asm ("r19") ;
	 register int  SAVE_LOOP_END asm ("r20") ;
	 register int  SAVE_DAT_RSP asm ("r21") ;
	
    //  asm volatile ("l.mtspr %0,%1, %2" : "=r"(RSP) : "m"(p), "i"(0));
	// 10007f8:	19 80 01 00 	l.movhi r12,0x100
  //10007fc:	a9 8c 34 10 	l.ori r12,r12,0x3410
	
	asm volatile ("l.addi %0,%1, %2" : "=r"(SAVE_RSP ) : "r"(RSP), "i"(0));
	asm volatile ("l.addi %0,%1, %2" : "=r"(SAVE_RX_REG ) : "r"(RX_REG), "i"(0));
	asm volatile ("l.addi %0,%1, %2" : "=r"(SAVE_LOOP_END ) : "r"(LOOP_END), "i"(0));
	asm volatile ("l.addi %0,%1, %2" : "=r"(SAVE_DAT_RSP ) : "r"(DAT_RSP), "i"(0));
	
	
	RSP=&MMCRDData[0];
  // asm volatile ("l.movhi %0,%1" : "=r"(RSP) : "i"(0x100) );
   //asm volatile ("l.ori %0,%1, %2" : "=r"(RSP) :  "r"(RSP)  , "i"(0x4db0) );
     
  
    asm volatile ("l.movhi %0,%1" : "=r"(RX_REG) : "i"(0xa000) );
    asm volatile ("l.ori %0,%1, %2" : "=r"(RX_REG) :  "r"(RX_REG)  , "i"(0xc) );

    
   asm volatile ("l.addi %0,%1,%2" : "=r"(LOOP_END) : "r"(RSP) , "i"(0x200) );
   
   asm ("label:");
   asm volatile ("l.lwz %0,%1 %2" : "=r"(DAT_RSP) : "i"(0), "r"(RX_REG) );
   asm volatile ("l.sb  %0 %1, %2" :  : "i"(0), "r"(RSP) , "r"(DAT_RSP) );
   asm volatile ("l.addi %0,%1,%2" : "=r"(RSP) : "r"(RSP), "i"(0x1) );

	asm volatile ("l.sfne %0,%1" : "=r"(RSP) :"r"(LOOP_END) ); 
	
	asm volatile ("l.bf  label" ); 

	asm volatile ("l.nop");
	asm volatile ("l.addi %0,%1, %2" : "=r"(RSP) : "r"(SAVE_RSP ), "i"(0));
	asm volatile ("l.addi %0,%1, %2" : "=r"(RX_REG) : "r"(SAVE_RX_REG ), "i"(0));
   	asm volatile ("l.addi %0,%1, %2" : "=r"(LOOP_END ) : "r"(SAVE_LOOP_END), "i"(0));
	asm volatile ("l.addi %0,%1, %2" : "=r"(DAT_RSP ) : "r"(SAVE_DAT_RSP), "i"(0));
	
	
  return TRANSMISSION_SUCCESSFUL;
}
void Start()
{
     volatile unsigned char rtn_reg=0;
    volatile unsigned char response[16];
     volatile int a;
	 volatile int i;
	 
	 for (i=0;i<512;i++)
	    MMCWRData[i]=i;
	
	uart_init();
	a=mmc_init();
	if (a)
	   	 uart_print_str("1");
	 else
	   	 uart_print_str("0");
		 
//	 mmc_write_block(0); 
    mmc_read_block(0); 
	 for (i=0;i<512;i++)
	uart_print_long(  MMCRDData[i]);
	
		 mmc_read_block(1); 
	 for (i=0;i<512;i++)
	  uart_print_long(  MMCRDData[i]);
	
		 
}