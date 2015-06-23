
#include "orsocdef.h"
#include "board.h"
#include "sd_controller.h"

#define SD_REG(REG)  REG32(SD_CONTROLLER_BASE+REG) 



int sd_get_rca(sd_card *d)
{
      uint32 rtn_reg=0;
      SD_REG(SD_COMMAND) = CMD3 | CICE | CRCE | RSP_48;  
	  SD_REG(SD_ARG)=0;

      if (sd_wait_rsp() == 0)         
	   return 0;
      else{ 
		  rtn_reg = SD_REG(SD_NORMAL_INT_STATUS);
          if ( (rtn_reg  & EI) == EI)    //Error in response, init failed return.
		   return 0;
		rtn_reg = SD_REG(SD_RESP1);
		d->rca=((rtn_reg&RCA_RCA_MASK)>>16);
	   uart_print_str("rca fine");
		
	  }
	  return 1;

}


//return 0 if no response else return 1.
uint8 sd_wait_rsp()
{  
  volatile unsigned long r1, r2;
 
 //Polling for timeout and command complete
 while (1 ) 
 {
  r1= SD_REG(SD_ERROR_INT_STATUS);
  r2= SD_REG(SD_NORMAL_INT_STATUS) ;
  
   if (( r1 & CMD_TIMEOUT ) == CMD_TIMEOUT) 
	  return 0;
   else if ((r2  & CMD_COMPLETE ) == CMD_COMPLETE) 
	  return 1;
   
 }
  //Later Exception restart module
  return 0;
 
}



int sd_cmd_free() //Return 1 if CMD is busy
{
  unsigned int a= SD_REG(SD_STATUS);
  return (a & 1);
}
 sd_card sd_controller_init ()
{
  sd_card dev;

   volatile unsigned long rtn_reg=0;
   volatile  unsigned long rtn_reg1=0;
   
   REG32(SD_CONTROLLER_BASE+SD_TIMEOUT)=0x00008FF;
	 
   REG32(SD_CONTROLLER_BASE+SD_SOFTWARE_RST)=0x0000001; 
   REG32(SD_CONTROLLER_BASE+SD_CLOCK_D)=0x0000002;
   REG32(SD_CONTROLLER_BASE+SD_SOFTWARE_RST)=0x0000000; 
   
	REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x0000;
	REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000;
    sd_wait_rsp();
	
	SD_REG(SD_COMMAND) = ( CMD8 | CICE | CRCE | RSP_48);
    SD_REG(SD_ARG) = VHS|CHECK_PATTERN;
    
	dev.phys_spec_2_0 = sd_wait_rsp();
	REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x0000;
		REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000;
		    sd_wait_rsp();
     if (dev.phys_spec_2_0)   
	  { 
		// uart_print_str("2_0 CARD /n");
            return dev;
	  }
	  else
	  {
		
		REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x0000;
		REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000;
		while (REG32(SD_CONTROLLER_BASE+SD_STATUS)& 1) {}
			

		rtn_reg=0;
        while ((rtn_reg & BUSY) != BUSY)
	    {
          REG32(SD_CONTROLLER_BASE+SD_COMMAND) = CMD55|RSP_48; 
	      REG32(SD_CONTROLLER_BASE+SD_ARG) =0;
      	  if (!sd_wait_rsp())
			 return dev;
         REG32(SD_CONTROLLER_BASE+SD_COMMAND) =ACMD41 | RSP_48;
		 REG32(SD_CONTROLLER_BASE+SD_ARG)   =0;
    	 if (!sd_wait_rsp())
			 return dev;
		  rtn_reg= REG32(SD_CONTROLLER_BASE+SD_RESP1) ;
		}
	    dev.Voltage_window=rtn_reg&VOLTAGE_MASK;	
		dev.HCS_s = 0;

	}   
	  

		//GET CID
        REG32(SD_CONTROLLER_BASE+SD_COMMAND) =CMD2 | RSP_146;
		REG32(SD_CONTROLLER_BASE+SD_ARG)   =0;
		if (!sd_wait_rsp())
			 return dev;
        //Get RCA
	    SD_REG(SD_COMMAND) = CMD3 | CICE | CRCE | RSP_48;  
		SD_REG(SD_ARG)=0;
		if (!sd_wait_rsp())
			 return dev;
		 rtn_reg = SD_REG(SD_RESP1);
		dev.rca = ((rtn_reg&RCA_RCA_MASK));
   
	dev.Active=1;
    return dev;

}
