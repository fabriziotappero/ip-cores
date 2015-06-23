/*file name: synfifo.v    module:synfifo     2004-09-17pm     btltz  from CASIC    btltz@mail.china.com
--    Description:    a synchronous fifo
--     Abbreviations:  sinit -- synchronous initial
                       ack -- acknowledging signal
					        DWIDTH -- data width
					        CWIDTH -- vector counter width
					        CMAX -- maximal vector count value
					        Afull -- almost full
					        Hfull -- half full
					        _itnl -- *_internal
					        rp -- read pointer
                       wp -- write pointer
					   alw -- allow
--     Modification Record:
 	                04-09-17pm : start the draft
		       
*/

`timescale 1ns/10ps
`define reset  1       //WISHBONE style reset

module synfifo #(parameter DEPTH =16, DWIDTH =8,  
                              addr_max      = (DEPTH <=   16 ? 4:
                                               (DEPTH <=   32 ? 5:
                                                (DEPTH <=   64 ? 6 :
                          								 (DEPTH <=  128 ? 7 :
                          								  (DEPTH <=  256 ? 8 :
                          									(DEPTH <=  512 ? 9 :
                          									 (DEPTH <= 1024 ? 10 : 6 )  )))))),
                             CWIDTH = addr_max + 1,
						  has_wr_ack=1, has_rd_ack=1, wr_ack_low=0, rd_ack_low=0, has_count_out=1
					 )  
              (output reg [DWIDTH-1:0] dout,
				   output reg full, Afull, Hfull, empty,
					output reg rd_ack, wr_ack,
					output reg rd_err, wr_err,
					output reg [CWIDTH-1:0] data_count,

				  	input [DWIDTH-1:0] din,
					input wr_en, rd_en,
					input gclk, sinit										
                   );   

               				   

integer m, i_cmax;
begin 
m=0; i_cmax=1;                  
for(m=0, m<addr_max, m=m+1)    i_cmax = i_cmax * 2;
parameter C_MAX = i_cmax;
end 
	
parameter avail_depth =  

output [DWIDTH-1:0] dout;
output full, Afull, Hfull, empty;
output empty;
output rd_ack, wr_ack;
output rd_err, wr_err;

output [CWIDTH-1:0] data_count;   //CWIDTH-1 == addr_max.  So it can also be written as[addr_max:0] 
//----------------- Added outputs for internal obbscope --

//-----------------
input clk;
input sinit;
input [DWIDTH-1:0] din;
input wr_en;
input rd_en;

reg [DWIDTH-1:0] dout;
reg full, Afull, Hfull, empty;
reg rd_err, wr_err;

wire rd_ack_itn,   wr_ack_itn;
wire rd_ack_itnl,  wr_ack_itnl;
assign wd_ack     = (has_wr_ack == 0 ) ? 1'bx : wr_ack_itn;  //x will be treated as none when synthesizing
assign rd_ack     = (has_rd_ack == 0 ) ? 1'bx : rd_ack_itn;
assign wd_ack_itn = ( (wr_ack_low == 0) ? wr_ack_itnl : !wr_ack_itnl );
assign rd_ack_itn = ( (rd_ack_low == 0) ? rd_ack_intl : !rd_ack_itnl );

/*wire*/assign write_alw = (wr_en && !full);  
/*wire*/assign read_alw = (rd_en && !empty); 

reg [addr_max-1:0] wp,rp;

reg [CWIDTH-1:0] vector_cnt;    //CWIDTH = addr_max + 1
assign data_count = ( has_count_out == 0 ) ? { CWIDTH{1'bx} } : vector_cnt;

//--------------------------------------------------------------------------------------------
wire [DWIDTH-1:0]    mem_Dout; // Data Out from the  MemBlk
assign [DWIDTH-1:0] wrt_data = data_in;    //data prepare

//------- read /write memory Template ----------------------------------------
       always @(posedge clk) begin 
 	      if (wr_en)  
 		      MEM[wrt_addr] <= wrt_data; 
 	          rd_addr  <= rp; 
			  wrt_addr <= wp;
          end 
//--- asy read for block RAM 
assign mem_Dout = MEM[rd_addr];

//--- registered output
always @(posedge gclk)
begin:MEM_OUTPUT
  if(sinit==`reset)
    dout <= 0;
  else if (rd_en==1'b1)        //change only rd_en==1 ,else hold the data; cause the SRAM's output 
    dout <= mem_Dout;         //is not occurs when write to the MEM.
end


//----------------------------------------------------------------------------------------------

/************************************************************ 
 * HandShaking Signals
**************************************************************/
//--- Read ack logic
always @(posedge gclk)
begin
   if(sinit==`reset)
     wr_ack_itnl <= 1'b0;
   else 
     wr_ack_itnl <= wr_en && !full;
end

//--- write ack logic
always @(posedge gclk)
begin
   if(sinit==`reset)
      rd_ack_itnl <= 1'b0;
   else 
      rd_ack_itnl <= rd_en && !empty;
end

//--- Read error handshake
always @(posedge gclk)
begin
   if(sinit==`reset)
     rd_err <= 1'b0;
   else 
     rd_err <= rd_en && empty;
end
//--- Write error handshake
always @(posedge gclk)
begin
   if(sinit==`reset)
     wr_err <= 1'b0;
   else 
     wr_err <= wr_en && full;
end

/***********************************************************************************
 * Control circuitry for FIFO. 
 * Write only will increments  the vector_cnt, read only decrements the vector_cnt and
 * read && write doen't change the vector_cnt value.
************************************************************************************/
//----- Read Point
always @(posedge gclk)
begin:READ_P
  if (sinit==`reset)
     rp <= 0;
  else if(read_alw)  begin
     if (rp== (avail_depth-1) )   //need to support any arbitrary depth
	    rp <= 0;
	 else 
	    rp <= rp + 1'b1;
  end
end    //end block "READ_P"

//----- Write Point
always @(posedge gclk)
begin:WRITE_P
   if (sinit==`reset)
       wp <= 0;
   else if(write_alw)  begin
      if (wp== (avail_depth-1) )   //need to support any arbitrary depth
	     wp <= 0;
	  else 
	     wp <= wp + 1'b1;
   end
end   //end block "WRITE_P"1

//----- fifo residual vector counter
always @(posedge gclk)
begin:VECTOR_CNT
   if (sinit==`reset)
      vector_cnt <= 0;
   else begin
        case ( {write_alw, read_alw} )	 	
		   2'b01:  vector_cnt <= vector_cnt - 1'b1;
		   2'b10:  vector_cnt <= vector_cnt + 1'b1;
		 	default : vector_cnt <= 'bx;
	    endcase
   end
end    //end block "VECTOR_CNT"

//------------------------- empty fanion ------------------------------------------------
//---------------- when asserted indicating the FIFO is empty -------------------------
always @(posedge gclk)
begin:EMPTY
   if(sinit==`reset)
      empty <= 1'b1;
   else begin
      if(  (vector_cnt==0 ) && ~wr_en   ||
	       || (vector_cnt==0 ) && wr_en && rd_en  
	       (vector_cnt==1 ) && ~wr_en && rd_en   )		  
		 )
      empty <= 1'b1;
	  else
	  empty <= 1'b0;     //imply that if (vector_cnt==0 ) && wr_en && ~rd_en ), empty <= 1'b0 
                         //imply that if (vector_cnt==1 ) && wr_en ), empty <= 1'b0 
   end
end    //end block "EMPTY"

//------------------------- full fanion --------------------------------------------------
//---------------- when asserted indicating the fifo is full ------------------------
always @(posedge gclk)
begin:FULL
   if(sinit==`reset)
      full <= 1'b0;
   else begin
       if (  (vector_cnt==(avail_depth-1) ) && wr_en && ~rd_en   ||   //to indicate early
	         (vector_cnt==avail_depth) && ~rd_en  ) 
			  || vector_cnt==avail_depth) && rd_en && wr_en    //This is the conflict condition:read and write to the same cell
		   )			 
	   full <= 1'b1;
	   else 
	   full <= 1'b0;    //imply that if (vector_cnt==(avail_depth-1) ) && wr_en && rd_en), "full" will not be asserted
                        //imply that if (vector_cnt==avail_depth) && rd_en && ~wr_en), "full" will be cleared 

						
						
						
endmodule
`undef set
`undef reset
