`include "sd_defines.v"
`include "timescale.v"
module sd_rx_fifo
  (
   input [4-1:0] d,
   input wr,
   input wclk,
   output [32-1:0] q,
   input rd,
   output full,
   output empty,
   output [1:0] mem_empt,
   input rclk,
   input rst
   );
   reg [32-1:0] ram [0:`FIFO_RX_MEM_DEPTH-1]; //synthesis syn_ramstyle = "no_rw_check
   reg [`FIFO_RX_MEM_ADR_SIZE-1:0] adr_i, adr_o;
   wire ram_we;
   wire [32-1:0] ram_din;
   reg [8-1:0] we;
   reg [4*(8)-1:0] tmp;
   reg ft;
   always @ (posedge wclk or posedge rst)
     if (rst)
       we <= 8'h1;
     else
       if (wr)
	 we <= {we[8-2:0],we[8-1]};
	 
   always @ (posedge wclk or posedge rst)
     if (rst) begin
       tmp <= {4*(8-1){1'b0}};
         ft<=0; 
   end    
     else
       begin
	 `ifdef BIG_ENDIAN
	   
	  if (wr & we[7]) begin
	    tmp[4*1-1:4*0] <= d;	 
	    ft<=1; end 
	  if (wr & we[6])
	    tmp[4*2-1:4*1] <= d; 
	  if (wr & we[5])
	    tmp[4*3-1:4*2] <= d;	  
	  if (wr & we[4])
	    tmp[4*4-1:4*3] <= d;	  
	  if (wr & we[3])
	    tmp[4*5-1:4*4] <= d;	  
	  if (wr & we[2])
	    tmp[4*6-1:4*5] <= d;	  
	  if (wr & we[1]) 
	    tmp[4*7-1:4*6] <= d;	 
 	  if (wr & we[0]) 
	    tmp[4*8-1:4*7] <= d;	 
	 `endif 
	 `ifdef LITTLE_ENDIAN 
	  if (wr & we[0])
	   tmp[4*1-1:4*0] <= d;	 
	  if (wr & we[1])
	    tmp[4*2-1:4*1] <= d;   
	  if (wr & we[2])
	    tmp[4*3-1:4*2] <= d;   
	  if (wr & we[3])
	   tmp[4*4-1:4*3] <= d;	     
	  if (wr & we[4])
	   tmp[4*5-1:4*4] <= d; 
	  if (wr & we[5])
	   tmp[4*6-1:4*5] <= d;	 
	  if (wr & we[6]) 
	   tmp[4*7-1:4*6] <= d;	  	  
	  if (wr & we[7]) begin
	   tmp[4*8-1:4*7] <= d;
	       ft<=1; 
     end
      `endif 
  end
       
   assign ram_we = wr & we[0] &ft;
   assign ram_din = tmp;
   always @ (posedge wclk)
     if (ram_we)
       ram[adr_i[`FIFO_RX_MEM_ADR_SIZE-2:0]] <= ram_din;
   always @ (posedge wclk or posedge rst)
     if (rst)
       adr_i <= `FIFO_RX_MEM_ADR_SIZE'h0;
     else
       if (ram_we)
	 if (adr_i == `FIFO_RX_MEM_DEPTH-1) begin
	   adr_i[`FIFO_RX_MEM_ADR_SIZE-2:0] <=0;	   
	   adr_i[`FIFO_RX_MEM_ADR_SIZE-1]<=~adr_i[`FIFO_RX_MEM_ADR_SIZE-1];
	 end  
	 else
	   adr_i <= adr_i + `FIFO_RX_MEM_ADR_SIZE'h1;
	   
   always @ (posedge rclk or posedge rst)
     if (rst)
       adr_o <= `FIFO_RX_MEM_ADR_SIZE'h0;
     else
       if (!empty & rd)
	
	 if (adr_o == `FIFO_RX_MEM_DEPTH-1) begin
	    adr_o[`FIFO_RX_MEM_ADR_SIZE-2:0] <=0;
	    adr_o[`FIFO_RX_MEM_ADR_SIZE-1] <=~adr_o[`FIFO_RX_MEM_ADR_SIZE-1];
	 end  
	 else
	   adr_o <= adr_o + `FIFO_RX_MEM_ADR_SIZE'h1;
	 
//------------------------------------------------------------------
// Simplified version of the three necessary full-tests:
// assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
// (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
// (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
//------------------------------------------------------------------
	   
   assign full =  (adr_i[`FIFO_RX_MEM_ADR_SIZE-2:0] == adr_o[`FIFO_RX_MEM_ADR_SIZE-2:0] ) & (adr_i[`FIFO_RX_MEM_ADR_SIZE-1] ^ adr_o[`FIFO_RX_MEM_ADR_SIZE-1]) ;
   assign empty = (adr_i == adr_o) ;
   
   assign mem_empt = ( adr_i-adr_o);
   assign q = ram[adr_o[`FIFO_RX_MEM_ADR_SIZE-2:0]];
endmodule
