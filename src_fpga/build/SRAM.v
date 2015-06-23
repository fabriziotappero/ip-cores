/* 
  Notes -> We target a ZTB SRAM. It data is presented 2 cycles after the address data is presented.

cyc action 
 1  assign addr.
 2  latch addr.
 3  assign data.
 4  latch data.

*/ 

//`include "FIFOL2.v"

`define NOP    0
`define RD_REQ 1
`define WR_REQ 2

module SRAM(CLK, RST_N,
            // Bluespec method wires
            RD_ADDR, RD_RDY,   RD_EN,
            DOUT,    DOUT_RDY, DOUT_EN,
            WR_ADDR, WR_VAL,   WR_EN, 
            // Physical SRAM wires
            DATA_BUS_O, DATA_BUS_I, DATA_BUS_T,
            ADDR_O, WE_BYTES_N_O, WE_N_O, CE_N_O, 
            OE_N_O, CEN_N_O, ADV_LD_N_O, DUMMY_EN
            );

   // synopsys template   
   parameter                   addr_width = 1;
   parameter                   data_width = 1;
   parameter                   lo = 0;
   parameter                   hi = 1;
   
   input                       CLK;
   input                       RST_N;   

   // Read Port
   // req
   input [addr_width - 1 : 0]  RD_ADDR;
   input                       RD_EN;
   output                      RD_RDY;
   // resp
   output [data_width - 1 : 0] DOUT;
   output                      DOUT_RDY;
   input                       DOUT_EN;

   // Write Port
   // req
   input [addr_width - 1 : 0]  WR_ADDR;
   input [data_width - 1 : 0]  WR_VAL;
   input                       WR_EN;

   //Physical SRAM Wires
   output [31 : 0]               DATA_BUS_O;
   input  [31 : 0]               DATA_BUS_I;
   output                        DATA_BUS_T;
   output [18 : 0]               ADDR_O;
   output [3 : 0]                WE_BYTES_N_O;
   output                        WE_N_O;
   output                        CE_N_O; 
   output                        OE_N_O;
   output                        CEN_N_O; 
   output                        ADV_LD_N_O;
   input                         DUMMY_EN; // this signal is a dummy enable to 
                                           // make bluespec happy.

   
   wire                          RD_REQ_MADE;
   
   //reg  [1:0] CTR;
   reg  [2:0] CTR;


   // Regs to pipeline incoming commands 
   reg [1:0] op_command_pipelined;
   reg [1:0] op_command_active;

   reg [data_width - 1:0] write_data_pipelined;
   reg [data_width - 1:0] write_data_active;   

  SizedFIFO #(.p1width(32),
	      .p2depth(4),
	      .p3cntr_width(2),
	      .guarded(1)) q(.RST_N(RST_N),
				       .CLK(CLK),
				       .D_IN(DATA_BUS_I[data_width-1:0]),
				       .ENQ(RD_REQ_MADE),
				       .DEQ(DOUT_EN),
				       .CLR(1'b0),
				       .D_OUT(DOUT),
				       .FULL_N(),
				       .EMPTY_N(DOUT_RDY));


/*   FIFOL2#(.width(data_width)) q(.RST_N(RST_N),
                                             .CLK(CLK),
                                             .D_IN(DATA_BUS_I[data_width-1:0]),
                                             .ENQ(RD_REQ_MADE),
                                             .DEQ(DOUT_EN),
                                             .CLR(1'b0),
                                             .D_OUT(DOUT),
                                             .FULL_N(),
                                             .EMPTY_N(DOUT_RDY));*/




   assign RD_RDY = (CTR > 0) || DOUT_EN;
   
   // Some lines that enable the SRAM.
   assign ADV_LD_N_O = 0;
   assign CE_N_O = 0; 
   assign OE_N_O = 0;
   assign CEN_N_O = 0; 

   // Tie the WE_N lines to the WR_EN.
   assign WE_N_O = ~WR_EN;
   assign WE_BYTES_N_O = {~WR_EN, ~WR_EN, ~WR_EN, ~WR_EN};
   



   assign ADDR_O = (WR_EN)?(19'h0 | WR_ADDR): (19'h0 | RD_ADDR);
   assign DATA_BUS_O = (op_command_active != `WR_REQ)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: (32'h0 | write_data_active); 
   assign DATA_BUS_T = (op_command_active != `WR_REQ);  // deasserting data_bus_T will allow 
                                                        // data_bus_O to drive the bus, which 
                                                        // need only occur if write requests 
                                                        // have been made.
   // This line enqueues data into the data fifo.
   assign RD_REQ_MADE = (op_command_active == `RD_REQ);    

   always@(posedge CLK)
     begin 
       if(RD_REQ_MADE)
         begin
           $display("SRAM.v: Enqueuing %d", DATA_BUS_I); 
         end
       
       if (!RST_N)
         begin  //Make simulation behavior consistent with Xilinx synthesis
           op_command_pipelined <= `NOP;
           op_command_active <= `NOP;          
           write_data_pipelined <= 0;
           write_data_active <= 0;
           CTR <= 4;
         end
       else
         begin
           write_data_pipelined <= WR_VAL;
           write_data_active <= write_data_pipelined;

           op_command_active <= op_command_pipelined;
           if(RD_EN)
             begin
               op_command_pipelined <= `RD_REQ;
             end
           else if(WR_EN) 
             begin
               op_command_pipelined <= `WR_REQ;
             end
           else 
             begin
               op_command_pipelined <= `NOP;
             end
          
           CTR <= (RD_EN) ?
                    (DOUT_EN) ? CTR : CTR - 1 :
                    (DOUT_EN) ? CTR + 1 : CTR;
         end
     end // always@ (posedge CLK)

endmodule