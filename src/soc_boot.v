// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module soc_boot
  (
    input   [31:0]  mem_data_i,
    output  [31:0]  mem_data_o,
    input   [31:0]  mem_addr_i,
    input   [3:0]   mem_sel_i,
    input           mem_we_i,
    input           mem_cyc_i,
    input           mem_stb_i,
    output          mem_ack_o,
    output          mem_err_o,
    output          mem_rty_o,
  
    input 	[1:0]   boot_select,
  
    input           mem_clk_i,
    input           mem_rst_i
  );

	parameter USE_BOOT_ROM_0 	    = 1;
// 	parameter BOOT_ROM_0_FILE 	= "../../../../../sw/load_this_to_ram/boot_rom_0.txt";
	parameter BOOT_ROM_0_DEPTH 	  = 8;
	
	parameter USE_BOOT_ROM_1 	    = 0;
// 	parameter BOOT_ROM_1_FILE 	= "../../../../../sw/load_this_to_ram/boot_rom_1.txt";
// 	parameter BOOT_ROM_1_DEPTH 	= 15;
	parameter BOOT_ROM_1_DEPTH 	  = 0;
	
	parameter USE_BOOT_ROM_2 	    = 0;
	parameter BOOT_ROM_2_FILE 	  = 0;
	parameter BOOT_ROM_2_DEPTH 	  = 0;

  //---------------------------------------------------
  // slave muxes
  reg  [1:0]   slave_select;

  always @(*)
    casez( {mem_addr_i[27:26], boot_select} )
      4'b00_00: slave_select = 2'b00;
      4'b00_01: slave_select = 2'b01;
      4'b00_10: slave_select = 2'b10;
      4'b00_11: slave_select = 2'b11;
      4'b01_??: slave_select = 2'b01;
      4'b10_??: slave_select = 2'b10;
      4'b11_??: slave_select = 2'b11;
    endcase

  // data_o mux
  wire  [31:0]  slave_0_data_o, slave_1_data_o, slave_2_data_o, slave_3_data_o;
  reg   [31:0]  slave_mux_data_o;

  assign mem_data_o = slave_mux_data_o;

  always @(*)
    case( slave_select )
      2'b00: slave_mux_data_o = slave_0_data_o;
      2'b01: slave_mux_data_o = slave_1_data_o;
      2'b10: slave_mux_data_o = slave_2_data_o;
      2'b11: slave_mux_data_o = slave_3_data_o;
    endcase

  assign mem_ack_o        = mem_cyc_i & mem_stb_i;
  assign mem_err_o 				= 1'b0;
  assign mem_rty_o 				= 1'b0;  
  

  //---------------------------------------------------
  // boot_vector_rom
  wire slave_0_we_i = mem_we_i & (slave_select == 2'b00);

  boot_vector_rom #( 	.DATA_WIDTH(32), .ADDR_WIDTH(2) )
    i_boot_vector_rom		(
		                    .data(mem_data_i),
		                    .addr( mem_addr_i[3:2] ),
		                    .we(slave_0_we_i),
		                    .clk(~mem_clk_i),
		                    .q(slave_0_data_o)
		                  );

  //---------------------------------------------------
  // boot_rom_0
  wire slave_1_we_i = mem_we_i & (slave_select == 2'b01);
  
	generate 
		if( USE_BOOT_ROM_0 )
		  boot_rom_0 #( 	.DATA_WIDTH(32), .ADDR_WIDTH(BOOT_ROM_0_DEPTH) )
		    i_boot_rom_0				(
				                    .data(mem_data_i),
				                    .addr( mem_addr_i[(BOOT_ROM_0_DEPTH + 1):2] ),
				                    .we(slave_1_we_i),
				                    .clk(~mem_clk_i),
				                    .q(slave_1_data_o)
				                  );
		else
			assign slave_1_data_o = 32'h1bad_c0de;		                  
	endgenerate		    

  //---------------------------------------------------
  // boot_rom_1
  wire slave_2_we_i = mem_we_i & (slave_select == 2'b10);
  
	generate 
		if( USE_BOOT_ROM_1 )
		  boot_rom_1 #( 	.DATA_WIDTH(32), .ADDR_WIDTH(BOOT_ROM_1_DEPTH) )
  		  i_boot_rom_1				(
  				                    .data(mem_data_i),
  				                    .addr( mem_addr_i[(BOOT_ROM_1_DEPTH + 1):2] ),
  				                    .we(slave_2_we_i),
  				                    .clk(~mem_clk_i),
  				                    .q(slave_2_data_o)
  				                  );
		else
			assign slave_2_data_o = 32'h1bad_c0de;		                  
	endgenerate		    

  //---------------------------------------------------
  // boot_rom_2
  wire slave_3_we_i = mem_we_i & (slave_select == 2'b11);
  
	generate 
		if( USE_BOOT_ROM_2 )
		  boot_rom_2 #( 	.DATA_WIDTH(32), .ADDR_WIDTH(BOOT_ROM_2_DEPTH) )
  		  i_boot_rom_2				(
  				                    .data(mem_data_i),
  				                    .addr( mem_addr_i[(BOOT_ROM_2_DEPTH + 1):2] ),
  				                    .we(slave_3_we_i),
  				                    .clk(~mem_clk_i),
  				                    .q(slave_3_data_o)
  				                  );
		else
			assign slave_3_data_o = 32'h1bad_c0de;		                  
	endgenerate		    

endmodule

