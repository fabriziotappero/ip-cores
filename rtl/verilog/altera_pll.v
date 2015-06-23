
`include "minsoc_defines.v"

module altera_pll (
	inclk0,
	c0);

        parameter FREQ_MULT = 1;
        parameter FREQ_DIV = 1;

	input	  inclk0;
	output	  c0;


`ifdef ARRIA_GX
    localparam FAMILY = "Arria GX";
`elsif ARRIA_II_GX
    localparam FAMILY = "Arria II GX";
`elsif CYCLONE_I
    localparam FAMILY = "Cyclone I";
`elsif CYCLONE_II
    localparam FAMILY = "Cyclone II";
`elsif CYCLONE_III
    localparam FAMILY = "Cyclone III";
`elsif CYCLONE_III_LS
    localparam FAMILY = "Cyclone III LS";
`elsif CYCLONE_IV_E
    localparam FAMILY = "Cyclone IV E";
`elsif CYCLONE_IV_GS
    localparam FAMILY = "Cyclone IV GS";
`elsif MAX_II
    localparam FAMILY = "MAX II";
`elsif MAX_V
    localparam FAMILY = "MAX V";
`elsif MAX3000A
    localparam FAMILY = "MAX3000A";
`elsif MAX7000AE
    localparam FAMILY = "MAX7000AE";
`elsif MAX7000B
    localparam FAMILY = "MAX7000B";
`elsif MAX7000S
    localparam FAMILY = "MAX7000S";
`elsif STRATIX
    localparam FAMILY = "Stratix";
`elsif STRATIX_II
    defapram systemPll.FAMILY = "Stratix II";
`elsif STRATIX_II_GX
    localparam FAMILY = "Stratix II GX";
`elsif STRATIX_III
    localparam FAMILY = "Stratix III"
`endif


	wire [4:0] sub_wire0;
	wire [0:0] sub_wire4 = 1'h0;
	wire [0:0] sub_wire1 = sub_wire0[0:0];
	wire  c0 = sub_wire1;
	wire  sub_wire2 = inclk0;
	wire [1:0] sub_wire3 = {sub_wire4, sub_wire2};

`ifdef ALTERA_FPGA
	altpll	altpll_component (
				.inclk (sub_wire3),
				.clk (sub_wire0),
				.activeclock (),
				.areset (1'b0),
				.clkbad (),
				.clkena ({6{1'b1}}),
				.clkloss (),
				.clkswitch (1'b0),
				.configupdate (1'b0),
				.enable0 (),
				.enable1 (),
				.extclk (),
				.extclkena ({4{1'b1}}),
				.fbin (1'b1),
				.fbmimicbidir (),
				.fbout (),
				.fref (),
				.icdrclk (),
				.locked (),
				.pfdena (1'b1),
				.phasecounterselect ({4{1'b1}}),
				.phasedone (),
				.phasestep (1'b1),
				.phaseupdown (1'b1),
				.pllena (1'b1),
				.scanaclr (1'b0),
				.scanclk (1'b0),
				.scanclkena (1'b1),
				.scandata (1'b0),
				.scandataout (),
				.scandone (),
				.scanread (1'b0),
				.scanwrite (1'b0),
				.sclkout0 (),
				.sclkout1 (),
				.vcooverrange (),
				.vcounderrange ());
	defparam
		altpll_component.bandwidth_type = "AUTO",
		altpll_component.clk0_divide_by = FREQ_DIV,
		altpll_component.clk0_duty_cycle = 50,
		altpll_component.clk0_multiply_by = FREQ_MULT,
		altpll_component.clk0_phase_shift = "0",
		altpll_component.compensate_clock = "CLK0",
		altpll_component.inclk0_input_frequency = 20000,
		altpll_component.intended_device_family = FAMILY,
		altpll_component.lpm_hint = "CBX_MODULE_PREFIX=minsocPll",
		altpll_component.lpm_type = "altpll",
		altpll_component.operation_mode = "NORMAL",
		altpll_component.pll_type = "AUTO",
		altpll_component.port_activeclock = "PORT_UNUSED",
		altpll_component.port_areset = "PORT_UNUSED",
		altpll_component.port_clkbad0 = "PORT_UNUSED",
		altpll_component.port_clkbad1 = "PORT_UNUSED",
		altpll_component.port_clkloss = "PORT_UNUSED",
		altpll_component.port_clkswitch = "PORT_UNUSED",
		altpll_component.port_configupdate = "PORT_UNUSED",
		altpll_component.port_fbin = "PORT_UNUSED",
		altpll_component.port_inclk0 = "PORT_USED",
		altpll_component.port_inclk1 = "PORT_UNUSED",
		altpll_component.port_locked = "PORT_UNUSED",
		altpll_component.port_pfdena = "PORT_UNUSED",
		altpll_component.port_phasecounterselect = "PORT_UNUSED",
		altpll_component.port_phasedone = "PORT_UNUSED",
		altpll_component.port_phasestep = "PORT_UNUSED",
		altpll_component.port_phaseupdown = "PORT_UNUSED",
		altpll_component.port_pllena = "PORT_UNUSED",
		altpll_component.port_scanaclr = "PORT_UNUSED",
		altpll_component.port_scanclk = "PORT_UNUSED",
		altpll_component.port_scanclkena = "PORT_UNUSED",
		altpll_component.port_scandata = "PORT_UNUSED",
		altpll_component.port_scandataout = "PORT_UNUSED",
		altpll_component.port_scandone = "PORT_UNUSED",
		altpll_component.port_scanread = "PORT_UNUSED",
		altpll_component.port_scanwrite = "PORT_UNUSED",
		altpll_component.port_clk0 = "PORT_USED",
		altpll_component.port_clk1 = "PORT_UNUSED",
		altpll_component.port_clk2 = "PORT_UNUSED",
		altpll_component.port_clk3 = "PORT_UNUSED",
		altpll_component.port_clk4 = "PORT_UNUSED",
		altpll_component.port_clk5 = "PORT_UNUSED",
		altpll_component.port_clkena0 = "PORT_UNUSED",
		altpll_component.port_clkena1 = "PORT_UNUSED",
		altpll_component.port_clkena2 = "PORT_UNUSED",
		altpll_component.port_clkena3 = "PORT_UNUSED",
		altpll_component.port_clkena4 = "PORT_UNUSED",
		altpll_component.port_clkena5 = "PORT_UNUSED",
		altpll_component.port_extclk0 = "PORT_UNUSED",
		altpll_component.port_extclk1 = "PORT_UNUSED",
		altpll_component.port_extclk2 = "PORT_UNUSED",
		altpll_component.port_extclk3 = "PORT_UNUSED",
		altpll_component.width_clock = 5;
`endif

endmodule

