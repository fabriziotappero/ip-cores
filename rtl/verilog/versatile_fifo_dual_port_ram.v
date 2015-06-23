// true dual port RAM, sync

`ifdef ACTEL
	`define SYN /*synthesis syn_ramstyle = "no_rw_check"*/
`endif
module vfifo_dual_port_ram_`TYPE
  (
   // A side
   d_a,
`ifdef DW   
   q_a,
`endif
   adr_a, 
   we_a,
`ifdef DC
   clk_a,
`endif
   // B side
   q_b,
   adr_b,
`ifdef DW 
   d_b, 
   we_b,
`endif
`ifdef DC
   clk_b
`else
   clk
`endif
   );
   
   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 8;
   
   input [(DATA_WIDTH-1):0]      d_a;
   input [(ADDR_WIDTH-1):0] 	 adr_a;
   input [(ADDR_WIDTH-1):0] 	 adr_b;
   input 			 we_a;
   output [(DATA_WIDTH-1):0] 	 q_b;
`ifdef DW
   input [(DATA_WIDTH-1):0] 	 d_b;
   output reg [(DATA_WIDTH-1):0] q_a;
   input 			 we_b;
`endif
`ifdef DC
   input 			 clk_a, clk_b;
`else
   input 			 clk;   
`endif

`ifndef DW
   reg [(ADDR_WIDTH-1):0] 	 adr_b_reg;
`else
   reg [(DATA_WIDTH-1):0] 	 q_b;   
`endif
   
   // Declare the RAM variable
   reg [DATA_WIDTH-1:0] ram [(1<<ADDR_WIDTH)-1:0] `SYN;

`ifdef DC   
   always @ (posedge clk_a)
`else
   always @ (posedge clk)
`endif
`ifdef DW
     begin // Port A
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
`else
   if (we_a)
     ram[adr_a] <= d_a;
`endif
	
`ifdef DC   
   always @ (posedge clk_b)
`else
   always @ (posedge clk)
`endif
`ifdef DW
     begin // Port b
	  q_b <= ram[adr_b];
	if (we_b)
	  ram[adr_b] <= d_b;
     end
`else // !`ifdef DW
   adr_b_reg <= adr_b;   
   
   assign q_b = ram[adr_b_reg];
`endif // !`ifdef DW
   
endmodule // true_dual_port_ram_sync
