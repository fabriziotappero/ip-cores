

module k68_sasc (/*AUTOARG*/
   // Outputs
   tx_o, rts_o, dat_o, 
   // Inputs
   clk_i, rst_i, cts_i, rx_i, dat_i, cs_i, we_i
   ) ;

   // Change these to set the baud rate for the SASC
   parameter div0 = 8'd1;
   parameter div1 = 8'd217;
      
   input clk_i,rst_i;

   // IO
   output tx_o, rts_o;
   input  cts_i, rx_i;

   // Mem
   //input add_i;
   input [23:0] dat_i;
   input       cs_i, we_i;
   output [9:0] dat_o;
   //reg [7:0] 	dat_o;
   
   wire [7:0] 	din;
   wire [7:0] 	dout;
   
   wire 	empty_o,full_o,sio_ce,sio_ce_x4;
   //reg 		we,wen;
   wire 	nrst;
   wire [7:0] 	brg0,brg1;
   wire 	re;
   
   assign 	re = cs_i & !we_i;
      
   assign 	{brg1,brg0,din} = dat_i;
   assign 	dat_o = {full_o,empty_o,dout};
   assign 	nrst = ~rst_i;
 
   sasc_top sasc_top0(
		      .rxd_i(rx_i),
		      .txd_o(tx_o),
		      .cts_i(cts_i),
		      .rts_o(rts_o),
		      
		      .sio_ce(sio_ce),
		      .sio_ce_x4(sio_ce_x4),
		      
		      .din_i(din),
		      .dout_o(dout),
		      
		      .re_i(re),
		      .we_i(we_i),
		      
		      .full_o(full_o),
		      .empty_o(empty_o),
		      
		      .clk(clk_i),.rst(nrst)
		      );
   
   sasc_brg sasc_brg0(
		      .sio_ce(sio_ce),
		      .sio_ce_x4(sio_ce_x4),
		      .div0(brg0),
		      .div1(brg1),
		      .clk(clk_i), .rst(nrst)
		      );
   
   
endmodule // k68_sasc
