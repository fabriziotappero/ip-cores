`include "sd_defines.v"
//-------------------------
//-------------------------
module sd_cmd_serial_host ( SD_CLK_IN, RST_IN, SETTING_IN ,CMD_IN, REQ_IN, ACK_OUT, REQ_OUT,ACK_IN, CMD_OUT, STATUS, cmd_dat_i, cmd_out_o, cmd_oe_o, st_dat_t);
//---------------Input ports---------------
input SD_CLK_IN;
input  RST_IN;
input [15:0] SETTING_IN;   
                      
input [39:0] CMD_IN;
input   REQ_IN;
input ACK_IN;
input cmd_dat_i;

//---------------Output ports---------------
output [39:0] CMD_OUT;
output ACK_OUT;
output REQ_OUT;
output [7:0] STATUS;
output reg cmd_oe_o; 
output reg cmd_out_o;
output reg [1:0] st_dat_t;
//---------------Input ports Data Type------  
wire SD_CLK_IN;
wire RST_IN;
wire [15:0] SETTING_IN;
wire [39:0] CMD_IN;
wire REQ_IN;
wire ACK_IN;

//---------------Output ports Data Type------  
reg  [39:0] CMD_OUT;
wire ACK_OUT  ;
reg  [7:0] STATUS;
reg  REQ_OUT;

//-------------Internal Constant-------------

`ifdef SIM
 `define INIT_DELAY 2
`else
  `define INIT_DELAY 64
 `endif
  
`define NCR 2 
parameter SEND_SIZE = 48;
parameter SIZE = 10;
parameter CONTENT_SIZE = 40;
parameter 
    INIT   =  10'b0000_0000_01,
    IDLE   =  10'b0000_0000_10,
    WRITE_WR	    =  10'b0000_0001_00,
    DLY_WR       =  10'b0000_0010_00,
    READ_WR      =  10'b0000_0100_00,
	  DLY_READ    	=  10'b0000_1000_00, 
 	  ACK_WR		     =  10'b0001_0000_00, 
	  WRITE_WO	    =  10'b0010_0000_00, 
	  DLY_WO	      =  10'b0100_0000_00, 
	  ACK_WO	      =  10'b1000_0000_00;
parameter Read_Delay = 7;	
parameter EIGHT_PAD = 8;
//---------------Internal variable----------- 
//-Internal settings/buffers
reg [6:0] Response_Size;
reg [2:0] Delay_Cycler;
reg [CONTENT_SIZE-1:0] In_Buff; 
reg [39:0] Out_Buff;
//-Internal State input
reg Write_Read;
reg Write_Only; 

//-CRC
reg [4:0] word_select_counter;
reg CRC_RST;
reg [6:0]CRC_IN;
wire [6:0] CRC_VAL; 
reg CRC_Enable;
reg CRC_OUT;
reg CRC_Check_On;
reg Crc_Buffering;
reg CRC_Valid;
//-Internal Counterns
  //6 bit sent counter
reg [7:0]Cmd_Cnt; //8 bit recive counter
reg [2:0]Delay_Cnt; //3 bit Delay counter
//-State Variable
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
//Misc
`define Vector_Index  (CONTENT_SIZE-1-Cmd_Cnt) 
`define Bit_Nr (SEND_SIZE-Cmd_Cnt)
	
//TRI-STATE
reg block_write;
reg block_read;


//
reg [1:0]word_select;
reg FSM_ACK;
reg DECODER_ACK;

reg q;
reg Req_internal_in;
reg q1;
reg Ack_internal_in;
//------------------------------------------   
sd_crc_7 CRC_7( 
CRC_OUT,
CRC_Enable,
SD_CLK_IN,
CRC_RST,
CRC_VAL);
//------------------------------------------  
always @ (state or Delay_Cnt or Write_Read or Cmd_Cnt or Write_Only or Ack_internal_in or  cmd_dat_i or Response_Size or Delay_Cycler)
begin : FSM_COMBO
 next_state  = 0;   
case(state)  
INIT: begin
  if (Cmd_Cnt >= `INIT_DELAY )begin
     next_state = IDLE;
  end
 
  else begin
     
      next_state = INIT;
  end
  
end

                                                
IDLE: begin        
	 if (Write_Read ) begin 
        next_state = WRITE_WR;
      end   
      else if (Write_Only  ) begin
        next_state = WRITE_WO;
      end
      else begin
         next_state = IDLE;
      end
end
WRITE_WR: 
      if (Cmd_Cnt >=SEND_SIZE-1) begin
        next_state = DLY_WR;
      end      
      else begin
        next_state = WRITE_WR; 
      end 
WRITE_WO: 
      if (Cmd_Cnt >= SEND_SIZE-1) begin
        next_state = DLY_WO;
      end      
      else begin
        next_state = WRITE_WO; 
      end 	  
DLY_WR : 
      if ( (Delay_Cnt >= `NCR) && ( !cmd_dat_i)) begin
        next_state = READ_WR;
      end      
      else begin
        next_state = DLY_WR; 
      end 	  
DLY_WO :
       if (Delay_Cnt >= Delay_Cycler) begin
        next_state = ACK_WO;
      end      
      else begin
        next_state = DLY_WO; 
      end 
READ_WR : 
      if (Cmd_Cnt >= (Response_Size+EIGHT_PAD)) begin
        next_state = DLY_READ;
      end      
      else begin
        next_state = READ_WR; 
      end 
		
ACK_WO : 
      next_state = IDLE; 
             
DLY_READ :
     if (Ack_internal_in ) begin
        next_state = ACK_WR;
      end      
      else begin
        next_state = DLY_READ; 
      end 	  
      
ACK_WR  :
        next_state = IDLE; 


default : next_state  = INIT;
 
 endcase     
end 
  //----
    	 
always @ (posedge SD_CLK_IN or posedge RST_IN)
begin : REQ_SYNC
	if  (RST_IN ) begin
		Req_internal_in <=1'b0;
		q <=1'b0;
	end
	else begin  
		q<=REQ_IN;
		Req_internal_in<=q;
	end


end

always @ (posedge SD_CLK_IN or posedge RST_IN)
begin :ACK_SYNC
	if  (RST_IN ) begin
		Ack_internal_in <=1'b0;
		q1 <=1'b0;
	end
	else begin  
		q1<=ACK_IN;
		Ack_internal_in<=q1;
	end


end





		 
		 
always @ (posedge SD_CLK_IN or posedge RST_IN )
  begin:COMMAND_DECODER
  if (RST_IN ) begin
		  Delay_Cycler <=3'b0;
		  Response_Size <=7'b0; 
		  DECODER_ACK <= 1;
		  Write_Read<=1'b0;
	    Write_Only<=1'b0;
	    CRC_Check_On <=0;
	    In_Buff <=0;
	    block_write<=0;
	    block_read <=0;
	    word_select<=0;
   end
   else begin
			if (Req_internal_in == 1) begin
				Response_Size[6:0] <=  SETTING_IN [6:0];
				CRC_Check_On <= SETTING_IN [7];
				Delay_Cycler[2:0] <= SETTING_IN [10:8];
				block_write <= SETTING_IN [11];
				block_read <= SETTING_IN [12];
				word_select <=SETTING_IN [14:13];
				In_Buff <= CMD_IN;
				DECODER_ACK<=0;	
				if (SETTING_IN [6:0]>0) begin
				   Write_Read<=1'b1;
				   Write_Only<=1'b0;
				end
				else begin
					Write_Read<=1'b0;
				  Write_Only<=1'b1;
				end
			end
			else begin
				Write_Read<=1'b0;
				Write_Only<=1'b0;
				DECODER_ACK <= 1;			
			end	
    end
 end
//End block COMMAND_DECODER  

//-------Function for Combo logic-----------------



assign ACK_OUT = FSM_ACK & DECODER_ACK;

//----------------Seq logic------------
always @ (posedge SD_CLK_IN or posedge RST_IN   )
begin : FSM_SEQ
  if (RST_IN ) begin
    state <= #1 INIT;
 end 

 else begin
    state <= #1 next_state;
 end
end

//-------------OUTPUT_LOGIC-------
always @ (posedge SD_CLK_IN or posedge RST_IN   )
begin : FSM_OUT
 if (RST_IN ) begin    
	    CRC_Enable=0;
	    word_select_counter<=0;
	    Delay_Cnt =0;
	   	cmd_oe_o=1; 		
	    cmd_out_o = 1;  
	  	 Out_Buff =0;
	   	FSM_ACK=1;
		REQ_OUT =0;
		  CRC_RST =1;
		  CRC_OUT =0;
		  CRC_IN =0;
		  CMD_OUT =0;	
	   	Crc_Buffering =0; 
	   	STATUS = 0;
	   	CRC_Valid=0;
	   	Cmd_Cnt=0;
	   	st_dat_t<=0;
	   
   	
 end 
 else begin
  case(state)
	INIT : begin
		Cmd_Cnt=Cmd_Cnt+1;
		cmd_oe_o=1; 		
		cmd_out_o = 1;  
	end
    
	IDLE : begin
		cmd_oe_o=0;      //Put CMD to Z  
		Delay_Cnt =0;
		Cmd_Cnt =0;
		CRC_RST =1;
		CRC_Enable=0; 
		CMD_OUT=0;
		st_dat_t<=0;
		word_select_counter<=0;		   
	end  
	
	WRITE_WR:   begin 
	   FSM_ACK=0;
       CRC_RST =0;
	   CRC_Enable=1;  
     
   
    
     if (Cmd_Cnt==0) begin
       STATUS = 16'b0000_0000_0000_0001;
       REQ_OUT=1;
     end 
     else if (Ack_internal_in) begin
       REQ_OUT=0;
     end 
         
        //Wait one cycle before sending, for setting up the CRC unit.
     if (Crc_Buffering==1)  begin
        cmd_oe_o =1;
        if (`Bit_Nr > 8 ) begin  // 1->40 CMD, (41 >= CNT && CNT <=47) CRC, 48 stop_bit
				   cmd_out_o = In_Buff[`Vector_Index]; 
				   if (`Bit_Nr > 9 ) begin //1 step ahead
			       CRC_OUT = In_Buff[`Vector_Index-1];
			     end else begin
			       CRC_Enable=0;  
				   end    
			  end
			  else if ( (`Bit_Nr <=8) && (`Bit_Nr >=2) ) begin			 	
				  CRC_Enable=0; 
				  cmd_out_o = CRC_VAL[(`Bit_Nr)-2];	
				  
		    	  if (block_read & block_write)
		    	    st_dat_t<=2'b11;
		    	  else  if  (block_read)
		    	    st_dat_t<=2'b10;    				
			  end
			  else begin        
				  cmd_out_o =1'b1;
			  end		
			  Cmd_Cnt = Cmd_Cnt+1 ;
		end		
	  else begin //Pre load CRC
		    Crc_Buffering=1;
	   	  CRC_OUT = In_Buff[`Vector_Index];
	  end	  
 	end 	

	WRITE_WO:  begin 
	   FSM_ACK=0;
     CRC_RST =0;
	   CRC_Enable=1;  
         
    
     if (Cmd_Cnt==0) begin
       STATUS[3:0] = 16'b0000_0000_0000_0010;
       REQ_OUT=1;
     end 
     else if (Ack_internal_in) begin
       REQ_OUT=0;
     end 
       
    
        
        //Wait one cycle before sending, for setting up the CRC unit.
     if (Crc_Buffering==1)  begin
        cmd_oe_o =1;  
        if (`Bit_Nr > 8 ) begin  // 1->40 CMD, (41 >= CNT && CNT <=47) CRC, 48 stop_bit
			     cmd_out_o = In_Buff[`Vector_Index]; 
			     if (`Bit_Nr > 9 ) begin //1 step ahead
			        CRC_OUT = In_Buff[`Vector_Index-1];
			     end 
           else begin
			        CRC_Enable=0;  
			     end    
		    end
		    else if( (`Bit_Nr <=8) && (`Bit_Nr >=2) ) begin			 	
			     CRC_Enable=0; 
		       cmd_out_o = CRC_VAL[(`Bit_Nr)-2];	
		       if  (block_read)
		    	    st_dat_t<=2'b10;			
		    end		 
	  	   else begin        
		  	    cmd_out_o =1'b1;
		    end		
			  Cmd_Cnt = Cmd_Cnt+1;	
		end		
		else begin //Pre load CRC
		   Crc_Buffering=1;
	   	 CRC_OUT = In_Buff[`Vector_Index];
	  end	  
 	end 	
	
	DLY_WR :  begin 
	   if (Delay_Cnt==0) begin
         STATUS[3:0] = 4'b0011;
         REQ_OUT=1;
      end  
      else if (Ack_internal_in) begin
       REQ_OUT=0;
     end      
		  CRC_Enable=0;
		  CRC_RST =1;
		  Cmd_Cnt = 1; 
		  cmd_oe_o=0; 	
		  if (Delay_Cnt<3'b111)
		    Delay_Cnt =Delay_Cnt+1;  
		  Crc_Buffering=0;
    end
	
    DLY_WO :  begin  
      if (Delay_Cnt==0) begin
         STATUS[3:0] = 4'b0100;
         STATUS[5] = 0;
         STATUS[6] = 1;
         REQ_OUT=1;
      end  
      else if (Ack_internal_in) begin
       REQ_OUT=0;
     end   
		  CRC_Enable=0;
		  CRC_RST =1;
		  Cmd_Cnt = 0; 
		  cmd_oe_o=0;
	    Delay_Cnt =Delay_Cnt+1;  
	    Crc_Buffering=0;     
    end	
    
    READ_WR :  begin
      Delay_Cnt =0;
      CRC_RST =0;
	    CRC_Enable=1;        
      cmd_oe_o =0;
      
	   if (Cmd_Cnt==1) begin
       STATUS[3:0] = 16'b0000_0000_0000_0101;
       REQ_OUT=1;
       Out_Buff[39]=0; //startbit (0)
     end 
     else if (Ack_internal_in) begin
       REQ_OUT=0;
     end  
	     
	     
	     
      if (Cmd_Cnt < (Response_Size))begin
        
        if (Cmd_Cnt<8 ) //1+1+6 (S,T,Index)          
          Out_Buff[39-Cmd_Cnt] = cmd_dat_i; 
        else begin
          
          if (word_select == 2'b00) begin
            if(Cmd_Cnt<40) begin
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
		         end 
		      end    
          else if (word_select == 2'b01) begin
            if ( (Cmd_Cnt>=40) && (Cmd_Cnt<72) )begin
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
		         end 
		      
		      end 
          else if  (word_select == 2'b10) begin
           if ( (Cmd_Cnt>=72) && (Cmd_Cnt<104) )begin
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
		         end 
		      end	     
          else if  (word_select == 2'b11) begin
           if ( (Cmd_Cnt>=104) && (Cmd_Cnt<128) )begin
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
		         end 
		      end	  
          
          
		    end
		    CRC_OUT = cmd_dat_i;  
		        
      end       
      else if ( Cmd_Cnt - Response_Size <=6 ) begin
			  CRC_IN [(Response_Size+6)-(Cmd_Cnt)] = cmd_dat_i;
			  CRC_Enable=0;  
      end
      else begin
			   if ((CRC_IN != CRC_VAL) && ( CRC_Check_On == 1)) begin
				   CRC_Valid=0;	
				   CRC_Enable=0;			  			
		    	end  
		    	else begin
		    	CRC_Valid=1;
		    	CRC_Enable=0;
		    	end 
		    	if (block_read & block_write)
		    	    st_dat_t<=2'b11;
		    	else if (block_write)
		    	  st_dat_t<=2'b01;
		    	 
      end        
       Cmd_Cnt = Cmd_Cnt+1;
   end
    
   DLY_READ:  begin
     
     if (Delay_Cnt==0) begin
       STATUS[3:0] = 4'b0110;
       STATUS[5] = CRC_Valid;
       STATUS[6] = 1;
       REQ_OUT=1;
     end 
     else if (Ack_internal_in) begin
       REQ_OUT=0;
     end  
        
		  CRC_Enable=0;
		  CRC_RST =1;
		  Cmd_Cnt = 0; 		 
		  cmd_oe_o=0; 
      
      CMD_OUT[39:0]=Out_Buff;
		  Delay_Cnt =Delay_Cnt+1;       
    end	
    
	ACK_WO:  begin    
		  FSM_ACK=1;
    end	
	
	ACK_WR:  begin    
		  FSM_ACK=1;
		  REQ_OUT =0;	
		
    end	
	
   endcase
  end
end
  
  
endmodule


