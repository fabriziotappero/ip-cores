//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:51:27 10/29/2009 
// Design Name: 
// Module Name:    minsoc_spartan_3a_starter_kit_ios 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module minsoc_spartan_3a_starter_kit_ios
(
    // Signals from GPIO Core
    ext_pad_o,
    ext_pad_oe,
    ext_pad_i,
	 
	 // Signals driving external pins
    i_pins,
    o_pins,
    io_pins
);
	 parameter gpio_num = 32;
	 parameter i_line_num = 8;
	 parameter o_line_num = 8;
	 parameter io_line_num= 8;
	 
    input  [gpio_num-1:0] ext_pad_o;
    input  [gpio_num-1:0] ext_pad_oe;
    output [gpio_num-1:0] ext_pad_i;
	 
    input  [i_line_num-1:0] i_pins;
    output [o_line_num-1:0] o_pins;
    inout  [io_line_num-1:0] io_pins;
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_0 (
          .O(ext_pad_i[0]),     // Buffer output
          .IO(io_pins[0]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[0]),     // Buffer input
          .T(~ext_pad_oe[0])      // 3-state enable input 
    );
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_1 (
          .O(ext_pad_i[1]),     // Buffer output
          .IO(io_pins[1]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[1]),     // Buffer input
          .T(~ext_pad_oe[1])      // 3-state enable input 
    );
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_2 (
          .O(ext_pad_i[2]),     // Buffer output
          .IO(io_pins[2]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[2]),     // Buffer input
          .T(~ext_pad_oe[2])      // 3-state enable input 
    );
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_3 (
          .O(ext_pad_i[3]),     // Buffer output
          .IO(io_pins[3]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[3]),     // Buffer input
          .T(~ext_pad_oe[3])      // 3-state enable input 
    );
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_4 (
          .O(ext_pad_i[4]),     // Buffer output
          .IO(io_pins[4]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[4]),     // Buffer input
          .T(~ext_pad_oe[4])      // 3-state enable input 
    );
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_5 (
          .O(ext_pad_i[5]),     // Buffer output
          .IO(io_pins[5]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[5]),     // Buffer input
          .T(~ext_pad_oe[5])      // 3-state enable input 
    );
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_6 (
          .O(ext_pad_i[6]),     // Buffer output
          .IO(io_pins[6]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[6]),     // Buffer input
          .T(~ext_pad_oe[6])      // 3-state enable input 
    );
	 
	 IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for the buffer, "0"-"16" (Spartan-3E only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst_7 (
          .O(ext_pad_i[7]),     // Buffer output
          .IO(io_pins[7]),   // Buffer inout port (connect directly to top-level port)
          .I(ext_pad_o[7]),     // Buffer input
          .T(~ext_pad_oe[7])      // 3-state enable input 
    );
	 
	 
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_0 (
      .O(ext_pad_i[8]),     // Buffer output
      .I(i_pins[0])      // Buffer input (connect directly to top-level port)
    );
	 
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_1 (
      .O(ext_pad_i[9]),     // Buffer output
      .I(i_pins[1])      // Buffer input (connect directly to top-level port)
    );
	 
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_2 (
      .O(ext_pad_i[10]),     // Buffer output
      .I(i_pins[2])      // Buffer input (connect directly to top-level port)
    );
	 
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_3 (
      .O(ext_pad_i[11]),     // Buffer output
      .I(i_pins[3])      // Buffer input (connect directly to top-level port)
    );
	 
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_4 (
      .O(ext_pad_i[12]),     // Buffer output
      .I(i_pins[4])      // Buffer input (connect directly to top-level port)
    );
	 
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_5 (
      .O(ext_pad_i[13]),     // Buffer output
      .I(i_pins[5])      // Buffer input (connect directly to top-level port)
    );
	 
	 /* PUSH Button NORTH is RESET.
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_6 (
      .O(ext_pad_i[14]),     // Buffer output
      .I(i_pins[6])      // Buffer input (connect directly to top-level port)
    );
	 */
	 
	 IBUF #(
      .IBUF_DELAY_VALUE("0"),   // Specify the amount of added input delay for                                //   the buffer, "0"-"16" (Spartan-3E/3A only)
      .IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input                                //   register, "AUTO", "0"-"8" (Spartan-3E/3A only)
      .IOSTANDARD("DEFAULT")    // Specify the input I/O standard
    )IBUF_inst_7 (
      .O(ext_pad_i[15]),     // Buffer output
      .I(i_pins[7])      // Buffer input (connect directly to top-level port)
    );
endmodule
