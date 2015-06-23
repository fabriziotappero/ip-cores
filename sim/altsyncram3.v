/*******************************************************************************

    MODULE NAME: altsyncram3

    DESCRIPTION
        This module is a parametrized dual port ram with a registered output port
        It is optional to define it's input address and output address and it's
        depth.

    REVISION HISTORY
        05FEB03 First Created -ac-
*******************************************************************************/
module altsyncram3
  (
   data,
   byteena,
   rd_aclr,
   rdaddress,
   rdclock,
   rdclocken,
   rden,
   wraddress,
   wrclock,
   wrclocken,
   wren,
   q);

   parameter        A_WIDTH    = 288;
   parameter        A_WIDTHAD  = 9;
   parameter        B_WIDTH    = A_WIDTH;
   parameter        B_WIDTHAD  = A_WIDTHAD;
   parameter        A_NUMWORDS = 1<<A_WIDTHAD;
   parameter        B_NUMWORDS = 1<<B_WIDTHAD;
   parameter        RAM_TYPE   = "AUTO";
   parameter        BYTE_ENA   = 1;
   parameter        USE_RDEN   = 1;

   parameter        TYPE       = RAM_TYPE == "M4K"   | RAM_TYPE == "M9K"?    "M9K":
                                 RAM_TYPE == "M512"  | RAM_TYPE == "MLAB"?   "MLAB":
                                 RAM_TYPE == "M-RAM" | RAM_TYPE == "M144K"?  "M144K":
                                                                             "AUTO";

   parameter        REG_B      = "CLOCK1";

   input  [A_WIDTH-1:0]           data;
   input  [BYTE_ENA-1 :0]         byteena;
   input                          rd_aclr;
   input  [B_WIDTHAD-1:0]         rdaddress;
   input                          rdclock;
   input                          rdclocken;
   input                          rden;
   input  [A_WIDTHAD-1:0]         wraddress;
   input                          wrclock;
   input                          wrclocken;
   input                          wren;
   output [B_WIDTH-1:0]           q;

   wire   [B_WIDTH-1:0]     sub_wire0;
   wire   [B_WIDTH-1:0]     q = sub_wire0[B_WIDTH-1:0];
   wire   [BYTE_ENA-1 :0]   byteena_wire = BYTE_ENA==1 ? 1'b1 : byteena;
   wire                     rden_wire = USE_RDEN ? rden : 1'b1;

   altsyncram   altsyncram_component (
      .clocken0(wrclocken),
      .clocken1(rdclocken),
      .wren_a(wren),
      .clock0(wrclock),
      .aclr1 (rd_aclr),
      .clock1(rdclock),
      .address_a(wraddress),
      .address_b(rdaddress),
      .rden_b(rden_wire),
      .data_a(data),
      .q_b(sub_wire0),
      .aclr0 (1'b0),
      .addressstall_a (1'b0),
      .addressstall_b (1'b0),
      .byteena_a (byteena_wire),
      .byteena_b (1'b1),
      .clocken2 (1'b1),
      .clocken3 (1'b1),
      .data_b ({B_WIDTH{1'b1}}),
      .eccstatus (),
      .q_a (),
      .rden_a (1'b1),
      .wren_b (1'b0));
   defparam
                altsyncram_component.address_aclr_b = "CLEAR1",
                altsyncram_component.address_reg_b = "CLOCK1",
                altsyncram_component.clock_enable_input_a = "NORMAL",
                altsyncram_component.clock_enable_input_b = "NORMAL",
                altsyncram_component.clock_enable_output_b = "NORMAL",
                altsyncram_component.intended_device_family = "Stratix III",
                altsyncram_component.lpm_type = "altsyncram",
                altsyncram_component.numwords_a = A_NUMWORDS,
                altsyncram_component.numwords_b = B_NUMWORDS,
                altsyncram_component.operation_mode = "DUAL_PORT",
                altsyncram_component.outdata_aclr_b = "CLEAR1",
                altsyncram_component.outdata_reg_b = REG_B,
                altsyncram_component.power_up_uninitialized = "FALSE",
                altsyncram_component.ram_block_type = TYPE,
                altsyncram_component.rdcontrol_reg_b = "CLOCK1",
                altsyncram_component.widthad_a = A_WIDTHAD,
                altsyncram_component.widthad_b = B_WIDTHAD,
                altsyncram_component.width_a = A_WIDTH,
                altsyncram_component.width_b = B_WIDTH,
                altsyncram_component.width_byteena_a = BYTE_ENA;
endmodule // altsyncram3
