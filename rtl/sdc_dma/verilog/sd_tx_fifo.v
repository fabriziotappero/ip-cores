
`include "timescale.v"
`include "sd_defines.v"
module sd_tx_fifo
  (
   input [32-1:0] d,
   input wr,
   input wclk,
   output [32-1:0] q,
   input rd,
   output full,
   output empty,
   output [5:0] mem_empt,
   input rclk,
   input rst
   );
   
   reg [32-1:0] ram [0:`FIFO_TX_MEM_DEPTH-1]; //synthesis syn_ramstyle = "no_rw_check"
   reg [`FIFO_TX_MEM_ADR_SIZE-1:0] adr_i, adr_o;
   wire ram_we;
   wire [32-1:0] ram_din;
    

       
   assign ram_we = wr & ~full;
   assign ram_din = d;
   
   always @ (posedge wclk)
     if (ram_we)
       ram[adr_i[`FIFO_TX_MEM_ADR_SIZE-2:0]] <= ram_din;
   
   always @ (posedge wclk or posedge rst)
     if (rst)
       adr_i <= `FIFO_TX_MEM_ADR_SIZE'h0;
     else
       if (ram_we)
      	 if (adr_i == `FIFO_TX_MEM_DEPTH-1) begin
	        adr_i[`FIFO_TX_MEM_ADR_SIZE-2:0] <=0;	   
	        adr_i[`FIFO_TX_MEM_ADR_SIZE-1]<=~adr_i[`FIFO_TX_MEM_ADR_SIZE-1];
	    end  
	     else
	      adr_i <= adr_i + `FIFO_TX_MEM_ADR_SIZE'h1;
	   
	   
   always @ (posedge rclk or posedge rst)
     if (rst)
       adr_o <= `FIFO_TX_MEM_ADR_SIZE'h0;
     else
       if (!empty & rd) begin
	
	 if (adr_o == `FIFO_TX_MEM_DEPTH-1) begin
	    adr_o[`FIFO_TX_MEM_ADR_SIZE-2:0] <=0;
	    adr_o[`FIFO_TX_MEM_ADR_SIZE-1] <=~adr_o[`FIFO_TX_MEM_ADR_SIZE-1];
	 end  
	 else
	   adr_o <= adr_o + `FIFO_TX_MEM_ADR_SIZE'h1;
	 end
//------------------------------------------------------------------
// Simplified version of the three necessary full-tests:
// assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
// (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
// (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
//------------------------------------------------------------------
	   
	   
   assign full=  ( adr_i[`FIFO_TX_MEM_ADR_SIZE-2:0] == adr_o[`FIFO_TX_MEM_ADR_SIZE-2:0] ) &  (adr_i[`FIFO_TX_MEM_ADR_SIZE-1] ^ adr_o[`FIFO_TX_MEM_ADR_SIZE-1]) ;
   assign empty = (adr_i == adr_o) ;
   
   assign mem_empt = ( adr_i-adr_o);
   assign q = ram[adr_o[`FIFO_TX_MEM_ADR_SIZE-2:0]];
endmodule

