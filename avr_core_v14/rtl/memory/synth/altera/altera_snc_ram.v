
module altera_snc_ram(
   clk,
   en,
   we,
   adr,
   din,
   dout
);
   parameter                 adr_width = 10;
   parameter                 data_width = 8;

   input                     clk;
   input                     en;
   input                     we;
   input [(adr_width-1):0]   adr;
   input [(data_width-1):0]  din;
   output [(data_width-1):0] dout;


localparam LP_BYTE_WE_WIDTH = (data_width <=   8) ?  1 :
                              (data_width <=  16) ?  2 :                                
                              (data_width <=  32) ?  4 :                                
                              (data_width <=  64) ?  8 :                                
                              (data_width <= 128) ? 16 :                                
                              (data_width <= 256) ? 32 :                                
                              (data_width <= 512) ? 64 : 0;                                
			      
wire vcc = 1'b1;
wire gnd = 1'b0;


altsyncram #(	
        .address_aclr_a                     ( "UNUSED"),
	.address_aclr_b                     ( "NONE"),
	.address_reg_b                      ( "CLOCK1"),
	.byte_size                          ( 8),
	.byteena_aclr_a                     ( "UNUSED"),
	.byteena_aclr_b                     ( "NONE"),
	.byteena_reg_b                      ( "CLOCK1"),
	.clock_enable_core_a                ( "USE_INPUT_CLKEN"),
	.clock_enable_core_b                ( "USE_INPUT_CLKEN"),
	.clock_enable_input_a               ( "NORMAL"),
	.clock_enable_input_b               ( "NORMAL"),
	.clock_enable_output_a              ( "NORMAL"),
	.clock_enable_output_b              ( "NORMAL"),
	.intended_device_family             ( "unused"),
	.ecc_pipeline_stage_enabled         ( "FALSE"),
	.enable_ecc                         ( "FALSE"),
	.implement_in_les                   ( "OFF"),
	.indata_aclr_a                      ( "UNUSED"),
	.indata_aclr_b                      ( "NONE"),
	.indata_reg_b                       ( "CLOCK1"),
	.init_file                          ( "UNUSED"),
	.init_file_layout                   ( "PORT_A"),
	.maximum_depth                      ( 0),
	.numwords_a                         ( 0),
	.numwords_b                         ( 0),
	.operation_mode                     ( "BIDIR_DUAL_PORT"),
	.outdata_aclr_a                     ( "NONE"),
	.outdata_aclr_b                     ( "NONE"),
	.outdata_reg_a                      ( "UNREGISTERED"),
	.outdata_reg_b                      ( "UNREGISTERED"),
	.power_up_uninitialized             ( "FALSE"),
	.ram_block_type                     ( "AUTO"),
	.rdcontrol_aclr_b                   ( "NONE"),
	.rdcontrol_reg_b                    ( "CLOCK1"),
	.read_during_write_mode_mixed_ports ( "DONT_CARE"),
	.read_during_write_mode_port_a      ( "NEW_DATA_NO_NBE_READ"),
	.read_during_write_mode_port_b      ( "NEW_DATA_NO_NBE_READ"),
	.stratixiv_m144k_allow_dual_clocks  ( "ON"),
	.width_a                            ( data_width),
	.width_b                            ( data_width),
	.width_byteena_a                    ( LP_BYTE_WE_WIDTH),
	.width_byteena_b                    ( LP_BYTE_WE_WIDTH),
	.width_eccstatus                    ( 3),
	.widthad_a                          ( adr_width),
	.widthad_b                          ( adr_width),
	.wrcontrol_aclr_a                   ( "UNUSED"),
	.wrcontrol_aclr_b                   ( "NONE"),
	.wrcontrol_wraddress_reg_b          ( "CLOCK1"),
	.lpm_type                           ( "altsyncram"),
	.lpm_hint                           ( "unused" )
	)
altsyncram_inst(	
	.aclr0          (gnd),                      // input	wire	aclr0,
	.aclr1          (gnd),                      // input	wire	aclr1,
	.address_a      (adr[(adr_width-1):0]),     // input	wire	[widthad_a-1:0] address_a,
	.address_b      ({adr_width{1'b0}}),        // input	wire	[widthad_b-1:0] address_b,
	.addressstall_a (gnd),                      // input	wire	addressstall_a,
	.addressstall_b (gnd),                      // input	wire	addressstall_b,
	.byteena_a      ({LP_BYTE_WE_WIDTH{1'b1}}), // input	wire	[width_byteena_a-1:0]	byteena_a,
	.byteena_b      ({LP_BYTE_WE_WIDTH{1'b0}}), // input	wire	[width_byteena_b-1:0]	byteena_b,
	.clock0         (clk),                      // input	wire	clock0,
	.clock1         (gnd),                      // input	wire	clock1,
	.clocken0       (vcc),                      // input	wire	clocken0,
	.clocken1       (gnd),                      // input	wire	clocken1,
	.clocken2       (gnd),                      // input	wire	clocken2,
	.clocken3       (gnd),                      // input	wire	clocken3,
	.data_a         (din[(data_width-1):0]),    // input	wire	[width_a-1:0]	data_a,
	.data_b         ({data_width{1'b0}}),       // input	wire	[width_b-1:0]	data_b,
	.eccstatus      (),                         // output  wire	[width_eccstatus-1:0]	eccstatus,
	.q_a            (dout[(data_width-1):0]),   // output  wire	[width_a-1:0]	q_a,
	.q_b            (),                         // output  wire	[width_b-1:0]	q_b,
	.rden_a         (vcc),                      // input	wire	rden_a,
	.rden_b         (gnd),                      // input	wire	rden_b,
	.wren_a         (we),                       // input	wire	wren_a,
	.wren_b         (gnd)                       // input	wire	wren_b
	);

/*

module	altsyncram
#(	parameter	address_aclr_a = "UNUSED",
	parameter	address_aclr_b = "NONE",
	parameter	address_reg_b = "CLOCK1",
	parameter	byte_size = 8,
	parameter	byteena_aclr_a = "UNUSED",
	parameter	byteena_aclr_b = "NONE",
	parameter	byteena_reg_b = "CLOCK1",
	parameter	clock_enable_core_a = "USE_INPUT_CLKEN",
	parameter	clock_enable_core_b = "USE_INPUT_CLKEN",
	parameter	clock_enable_input_a = "NORMAL",
	parameter	clock_enable_input_b = "NORMAL",
	parameter	clock_enable_output_a = "NORMAL",
	parameter	clock_enable_output_b = "NORMAL",
	parameter	intended_device_family = "unused",
	parameter	ecc_pipeline_stage_enabled = "FALSE",
	parameter	enable_ecc = "FALSE",
	parameter	implement_in_les = "OFF",
	parameter	indata_aclr_a = "UNUSED",
	parameter	indata_aclr_b = "NONE",
	parameter	indata_reg_b = "CLOCK1",
	parameter	init_file = "UNUSED",
	parameter	init_file_layout = "PORT_A",
	parameter	maximum_depth = 0,
	parameter	numwords_a = 0,
	parameter	numwords_b = 0,
	parameter	operation_mode = "BIDIR_DUAL_PORT",
	parameter	outdata_aclr_a = "NONE",
	parameter	outdata_aclr_b = "NONE",
	parameter	outdata_reg_a = "UNREGISTERED",
	parameter	outdata_reg_b = "UNREGISTERED",
	parameter	power_up_uninitialized = "FALSE",
	parameter	ram_block_type = "AUTO",
	parameter	rdcontrol_aclr_b = "NONE",
	parameter	rdcontrol_reg_b = "CLOCK1",
	parameter	read_during_write_mode_mixed_ports = "DONT_CARE",
	parameter	read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
	parameter	read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
	parameter	stratixiv_m144k_allow_dual_clocks = "ON",
	parameter	width_a = 1,
	parameter	width_b = 1,
	parameter	width_byteena_a = 1,
	parameter	width_byteena_b = 1,
	parameter	width_eccstatus = 3,
	parameter	widthad_a = 1,
	parameter	widthad_b = 1,
	parameter	wrcontrol_aclr_a = "UNUSED",
	parameter	wrcontrol_aclr_b = "NONE",
	parameter	wrcontrol_wraddress_reg_b = "CLOCK1",
	parameter	lpm_type = "altsyncram",
	parameter	lpm_hint = "unused")
(	input	wire	aclr0,
	input	wire	aclr1,
	input	wire	[widthad_a-1:0]	address_a,
	input	wire	[widthad_b-1:0]	address_b,
	input	wire	addressstall_a,
	input	wire	addressstall_b,
	input	wire	[width_byteena_a-1:0]	byteena_a,
	input	wire	[width_byteena_b-1:0]	byteena_b,
	input	wire	clock0,
	input	wire	clock1,
	input	wire	clocken0,
	input	wire	clocken1,
	input	wire	clocken2,
	input	wire	clocken3,
	input	wire	[width_a-1:0]	data_a,
	input	wire	[width_b-1:0]	data_b,
	output	wire	[width_eccstatus-1:0]	eccstatus,
	output	wire	[width_a-1:0]	q_a,
	output	wire	[width_b-1:0]	q_b,
	input	wire	rden_a,
	input	wire	rden_b,
	input	wire	wren_a,
	input	wire	wren_b
	);

*/

endmodule // altera_snc_ram
