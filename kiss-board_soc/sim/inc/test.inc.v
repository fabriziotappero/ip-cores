
//`define CLK_PERIOD	100_000
//`define CLK_OFFSET	0_000
//`define MISC_OFFSET 	70_000

`define CLK_PERIOD	50_000
`define CLK_OFFSET	 0_000
`define MISC_OFFSET 	 5_000

	// Terminal
	wire		t_sys_reset_n;
	wire		t_sys_init_n;
	wire		t_sys_clk0;
	wire		t_sys_clk1;
	wire		t_sys_clk2;
	wire		t_sys_clk3;
	//
	//wire		t_jtag_tms;
	//wire		t_jtag_tck;
	//wire		t_jtag_trst;
	//wire		t_jtag_tdi;
	//wire		t_jtag_tdo;
	//
	wire		t_uart_txd;
	wire		t_uart_rxd;
	wire		t_uart_rts_n;
	wire		t_uart_cts_n;
	wire		t_uart_dtr_n;
	wire		t_uart_dsr_n;
	wire		t_uart_dcd_n;
	wire		t_uart_ri_n;
	//
	wire		t_mem_cs2_rstdrv;
	wire		t_mem_cs2_int;
	wire		t_mem_cs2_dir;
	wire		t_mem_cs2_g_n;
	wire		t_mem_cs2_n;
	wire		t_mem_cs2_iochrdy;
	wire		t_mem_cs1_rst_n;
	wire		t_mem_cs1_n;
	wire		t_mem_cs1_rdy;
	wire		t_mem_cs0_n;
	wire		t_mem_we_n;
	wire		t_mem_oe_n;
	wire	[22:0]	t_mem_a;
	wire	[7:0]	t_mem_d;
	//
	//wire		t_sram_r_cen;
	//wire		t_sram_r0_wen;
	//wire		t_sram_r1_wen;
	//wire		t_sram_r_oen;
	//wire	[18:0]	t_sram_r_a;
	//wire	[15:0]	t_sram_r_d;
	//wire		t_sram_l_cen;
	//wire		t_sram_l0_wen;
	//wire		t_sram_l1_wen;
	//wire		t_sram_l_oen;
	//wire	[18:0]	t_sram_l_a;
	//wire	[15:0]	t_sram_l_d;
	//
	wire			t_sdram0_clk;
	wire		#2_000	t_sdram0_cke;
	wire	[1:0]	#2_000	t_sdram0_cs_n;
	wire		#2_000	t_sdram0_ras_n;
	wire		#2_000	t_sdram0_cas_n;
	wire		#2_000	t_sdram0_we_n;
	wire	[1:0]	#2_000	t_sdram0_dqm;
	wire	[1:0]	#2_000	t_sdram0_ba;
	wire	[12:0]	#2_000	t_sdram0_a;
	wire	[15:0]	#2_000	t_sdram0_d;
	//
	wire		t_sdram1_clk;
	wire		#2_000	t_sdram1_cke;
	wire	[1:0]	#2_000	t_sdram1_cs_n;
	wire		#2_000	t_sdram1_ras_n;
	wire		#2_000	t_sdram1_cas_n;
	wire		#2_000	t_sdram1_we_n;
	wire	[1:0]	#2_000	t_sdram1_dqm;
	wire	[1:0]	#2_000	t_sdram1_ba;
	wire	[12:0]	#2_000	t_sdram1_a;
	wire	[15:0]	#2_000	t_sdram1_d;
	//
	wire		t_vga_clkp;
	wire		t_vga_clkn;
	wire		t_vga_hsync;
	wire		t_vga_vsync;
	wire		t_vga_blank;
	wire	[23:0]	t_vga_d;
	//
	wire	[3:0]	t_misc_gpio;
	wire		t_misc_tp;
	
	// Register
	reg		r_clk;
	reg		r_res_n;
	//reg		r_jtag_tms;
	//reg		r_jtag_tck;
	//reg		r_jtag_trst;
	//reg		r_jtag_tdi;
	reg		r_uart_data;
	reg		r_uart_dsr_n;
	always	begin
		r_clk = 1'b1;
		#( `CLK_PERIOD / 2 );
		r_clk = 1'b0;
		#( `CLK_PERIOD - ( `CLK_PERIOD / 2 ) );
	end
	initial begin
	// system
		r_res_n		= 1'b0;
	// jtag
		//r_jtag_tms	= 1'b0;
		//r_jtag_tck	= 1'b0;
		//r_jtag_trst	= 1'b0;
		//r_jtag_tdi	= 1'b0;
	// uart
		r_uart_data	= 1'b1;
		r_uart_dsr_n	= 1'b1;
	end

	// task
	task task_reset;
	begin
		@(posedge r_clk) r_res_n <= 1'b0;
		@(posedge r_clk) r_res_n <= 1'b1;
	end
	endtask

	task task_idle;
		input	[31:0]	n;
		reg	[31:0]	i;
		for (i=0;i<n;i=i+1) @(posedge r_clk);
	endtask

	task task_uart_data;
		input	[7:0]	d;
		integer		i;
	begin
		// start
		r_uart_data <= 1'b0;
		task_idle(1024);
		// data
		for (i=0;i<8;i=i+1) begin
			r_uart_data = d[i];
			task_idle(1024);
		end
		// stop
		r_uart_data <= 1'b1;
		task_idle(1024);
	end
	endtask
	task task_uart_dsr_n;
		input		d;
	begin
		task_idle(1);
		r_uart_dsr_n <= d;
		task_idle(1);
	end
	endtask

// sys assign
	assign #(`MISC_OFFSET) t_sys_reset_n	= r_res_n;
	assign #(`CLK_OFFSET)  t_sys_clk0	= r_clk;
	assign #(`CLK_OFFSET)  t_sys_clk1	= 1'b0;
	assign #(`CLK_OFFSET)  t_sys_clk2	= 1'b0;
	assign #(`CLK_OFFSET)  t_sys_clk3	= 1'b0;

// uart assign
	//assign t_uart_rxd			= t_uart_txd;	// uart loopbacked
	//assign t_uart_rxd			= 1'b1;		// uart clamp
	assign t_uart_rxd			= r_uart_data;	// uart
	assign t_uart_cts_n			= 1'b1;
	assign t_uart_dsr_n			= r_uart_dsr_n;
	assign t_uart_dcd_n			= 1'b1;
	assign t_uart_ri_n			= 1'b1;

// mem assign
	assign t_mem_cs2_int			= 1'b0;
	assign t_mem_cs2_iochrdy		= 1'b0;
	assign t_mem_cs1_rdy			= 1'b0;
	
// misc assign
	assign t_misc_gpio			= 4'b0110;

// jtag assign	
	//assign #(`MISC_OFFSET) t_jtag_tms  = r_jtag_tms;
	//assign #(`MISC_OFFSET) t_jtag_tck  = r_jtag_tck;
	//assign #(`MISC_OFFSET) t_jtag_trst = r_jtag_trst;
	//assign #(`MISC_OFFSET) t_jtag_tdi  = r_jtag_tdi;
	
	//A512Kx8 sram_r0 (
	//	.CE_bar(	t_sram_r_cen),
	//	.OE_bar(	t_sram_r_oen),
	//	.WE_bar(	t_sram_r0_wen),
	//	.dataIO(	t_sram_r_d[7:0]),
	//	.Address(	t_sram_r_a)
	//);
	//A512Kx8 sram_r1 (
	//	.CE_bar(	t_sram_r_cen),
	//	.OE_bar(	t_sram_r_oen),
	//	.WE_bar(	t_sram_r1_wen),
	//	.dataIO(	t_sram_r_d[15:8]),
	//	.Address(	t_sram_r_a)
	//);
	//A512Kx8 sram_l0 (
	//	.CE_bar(	t_sram_l_cen),
	//	.OE_bar(	t_sram_l_oen),
	//	.WE_bar(	t_sram_l0_wen),
	//	.dataIO(	t_sram_l_d[7:0]),
	//	.Address(	t_sram_l_a)
	//);
	//A512Kx8 sram_l1 (
	//	.CE_bar(	t_sram_l_cen),
	//	.OE_bar(	t_sram_l_oen),
	//	.WE_bar(	t_sram_l1_wen),
	//	.dataIO(	t_sram_l_d[15:8]),
	//	.Address(	t_sram_l_a)
	//);
/*
	ram sram_r0 (
		.cex(		t_sram_r_cen),
		.oex(		t_sram_r_oen),
		.wex(		t_sram_r0_wen),
		.data(		t_sram_r_d[7:0]),
		.address(	t_sram_r_a)
	);
	ram sram_r1 (
		.cex(		t_sram_r_cen),
		.oex(		t_sram_r_oen),
		.wex(		t_sram_r1_wen),
		.data(		t_sram_r_d[15:8]),
		.address(	t_sram_r_a)
	);
	ram sram_l0 (
		.cex(		t_sram_l_cen),
		.oex(		t_sram_l_oen),
		.wex(		t_sram_l0_wen),
		.data(		t_sram_l_d[7:0]),
		.address(	t_sram_l_a)
	);
	ram sram_l1 (
		.cex(		t_sram_l_cen),
		.oex(		t_sram_l_oen),
		.wex(		t_sram_l1_wen),
		.data(		t_sram_l_d[15:8]),
		.address(	t_sram_l_a)
	);
*/
/*
	SDRAM i0_H_SDRAM (
		.SD_BA(		t_sdram0_ba),
		.SD_ADR(	t_sdram0_a),
		.SD_CS(		t_sdram0_cs_n[0]),
		.SD_RAS(	t_sdram0_ras_n),
		.SD_CAS(	t_sdram0_cas_n),
		.SD_WE(		t_sdram0_we_n),
		.SD_DQM(	t_sdram0_dqm[1]),
		.SD_CKE(	t_sdram0_cke),
		.SD_CLK(	t_sdram0_clk),
		.SD_DAT(	t_sdram0_d[15:8])
	);
	SDRAM i0_L_SDRAM (
		.SD_BA(		t_sdram0_ba),
		.SD_ADR(	t_sdram0_a),
		.SD_CS(		t_sdram0_cs_n[0]),
		.SD_RAS(	t_sdram0_ras_n),
		.SD_CAS(	t_sdram0_cas_n),
		.SD_WE(		t_sdram0_we_n),
		.SD_DQM(	t_sdram0_dqm[0]),
		.SD_CKE(	t_sdram0_cke),
		.SD_CLK(	t_sdram0_clk),
		.SD_DAT(	t_sdram0_d[7:0])
	);
	SDRAM i1_H_SDRAM (
		.SD_BA(		t_sdram1_ba),
		.SD_ADR(	t_sdram1_a),
		.SD_CS(		t_sdram1_cs_n[0]),
		.SD_RAS(	t_sdram1_ras_n),
		.SD_CAS(	t_sdram1_cas_n),
		.SD_WE(		t_sdram1_we_n),
		.SD_DQM(	t_sdram1_dqm[1]),
		.SD_CKE(	t_sdram1_cke),
		.SD_CLK(	t_sdram1_clk),
		.SD_DAT(	t_sdram1_d[15:8])		
	);
	SDRAM i1_L_SDRAM (
		.SD_BA(		t_sdram1_ba),
		.SD_ADR(	t_sdram1_a),
		.SD_CS(		t_sdram1_cs_n[0]),
		.SD_RAS(	t_sdram1_ras_n),
		.SD_CAS(	t_sdram1_cas_n),
		.SD_WE(		t_sdram1_we_n),
		.SD_DQM(	t_sdram1_dqm[0]),
		.SD_CKE(	t_sdram1_cke),
		.SD_CLK(	t_sdram1_clk),
		.SD_DAT(	t_sdram1_d[7:0])		
	);
*/
	initial force i_sdram0_cs0.Debug = 0;
	mt48lc8m16a2 i_sdram0_cs0 (
		.Dq(	t_sdram0_d),
		.Addr(	t_sdram0_a[11:0]),
		.Ba(	t_sdram0_ba),
		.Clk(	t_sdram0_clk),
		.Cke(	t_sdram0_cke),
		.Cs_n(	t_sdram0_cs_n[0]),
		.Ras_n(	t_sdram0_ras_n),
		.Cas_n(	t_sdram0_cas_n),
		.We_n(	t_sdram0_we_n),
		.Dqm(	t_sdram0_dqm)
	);
	initial force i_sdram0_cs1.Debug = 0;
	mt48lc8m16a2 i_sdram0_cs1 (
		.Dq(	t_sdram0_d),
		.Addr(	t_sdram0_a[11:0]),
		.Ba(	t_sdram0_ba),
		.Clk(	t_sdram0_clk),
		.Cke(	t_sdram0_cke),
		.Cs_n(	t_sdram0_cs_n[1]),
		.Ras_n(	t_sdram0_ras_n),
		.Cas_n(	t_sdram0_cas_n),
		.We_n(	t_sdram0_we_n),
		.Dqm(	t_sdram0_dqm)
	);
	initial force i_sdram1_cs0.Debug = 0;
	mt48lc8m16a2 i_sdram1_cs0 (
		.Dq(	t_sdram1_d),
		.Addr(	t_sdram1_a[11:0]),
		.Ba(	t_sdram1_ba),
		.Clk(	t_sdram1_clk),
		.Cke(	t_sdram1_cke),
		.Cs_n(	t_sdram1_cs_n[0]),
		.Ras_n(	t_sdram1_ras_n),
		.Cas_n(	t_sdram1_cas_n),
		.We_n(	t_sdram1_we_n),
		.Dqm(	t_sdram1_dqm)
	);
	initial force i_sdram1_cs1.Debug = 0;
	mt48lc8m16a2 i_sdram1_cs1 (
		.Dq(	t_sdram1_d),
		.Addr(	t_sdram1_a[11:0]),
		.Ba(	t_sdram1_ba),
		.Clk(	t_sdram1_clk),
		.Cke(	t_sdram1_cke),
		.Cs_n(	t_sdram1_cs_n[1]),
		.Ras_n(	t_sdram1_ras_n),
		.Cas_n(	t_sdram1_cas_n),
		.We_n(	t_sdram1_we_n),
		.Dqm(	t_sdram1_dqm)
	);
/*
	sdram i_sdram0_cs0 (
		.dqi(	t_sdram0_d),
		.ad(	t_sdram0_a[11:0]),
		.ba(	t_sdram0_ba),
		.clk(	t_sdram0_clk),
		.cke(	t_sdram0_cke),
		.csb(	t_sdram0_cs_n[0]),
		.rasb(	t_sdram0_ras_n),
		.casb(	t_sdram0_cas_n),
		.web(	t_sdram0_we_n),
		.dqm(	t_sdram0_dqm)
	);
	sdram i_sdram0_cs1 (
		.dqi(	t_sdram0_d),
		.ad(	t_sdram0_a[11:0]),
		.ba(	t_sdram0_ba),
		.clk(	t_sdram0_clk),
		.cke(	t_sdram0_cke),
		.csb(	t_sdram0_cs_n[1]),
		.rasb(	t_sdram0_ras_n),
		.casb(	t_sdram0_cas_n),
		.web(	t_sdram0_we_n),
		.dqm(	t_sdram0_dqm)
	);
	sdram i_sdram1_cs0 (
		.dqi(	t_sdram1_d),
		.ad(	t_sdram1_a[11:0]),
		.ba(	t_sdram1_ba),
		.clk(	t_sdram1_clk),
		.cke(	t_sdram1_cke),
		.csb(	t_sdram1_cs_n[0]),
		.rasb(	t_sdram1_ras_n),
		.casb(	t_sdram1_cas_n),
		.web(	t_sdram1_we_n),
		.dqm(	t_sdram1_dqm)
	);
	sdram i_sdram1_cs1 (
		.dqi(	t_sdram1_d),
		.ad(	t_sdram1_a[11:0]),
		.ba(	t_sdram1_ba),
		.clk(	t_sdram1_clk),
		.cke(	t_sdram1_cke),
		.csb(	t_sdram1_cs_n[1]),
		.rasb(	t_sdram1_ras_n),
		.casb(	t_sdram1_cas_n),
		.web(	t_sdram1_we_n),
		.dqm(	t_sdram1_dqm)
	);
*/	
	//i28f016s3 flash (
	//	.rpb(		t_flash_rstn),
	//	.ceb(		t_flash_cen),
	//	.oeb(		t_flash_oen),
	//	.web(		t_flash_wen),
	//	.ryby(		t_flash_rdy),
	//	.dq(		t_flash_d),
	//	.addr(		t_flash_a),
	//	.vpp(		32'h00002ee0/* flash_vpp */),
	//	.vcc(		32'h00001388/* flash_vcc */),
	//	.rpblevel(	2'b10/*flash_rpblevel*/)
	//);
	rom i_flash (
		.cex(		t_mem_cs0_n),
		.oex(		t_mem_oe_n),
		.data(		t_mem_d),
		.address(	t_mem_a[20:0])
	);

	tessera_top i_tessera_top (
		//
		.sys_reset_n(		t_sys_reset_n),
		.sys_init_n(		t_sys_init_n),
		.sys_clk0(		t_sys_clk0),
		.sys_clk1(		t_sys_clk1),
		.sys_clk2(		t_sys_clk2),
		.sys_clk3(		t_sys_clk3),
		//
		//.jtag_tms(		t_jtag_tms),
		//.jtag_tck(		t_jtag_tck),
		//.jtag_trst(		t_jtag_trst),
		//.jtag_tdi(		t_jtag_tdi),
		//.jtag_tdo(		t_jtag_tdo),
		//
		.uart_txd(		t_uart_txd),
		.uart_rxd(		t_uart_rxd),
		.uart_rts_n(		t_uart_rts_n),
		.uart_cts_n(		t_uart_cts_n),
		.uart_dtr_n(		t_uart_dtr_n),
		.uart_dsr_n(		t_uart_dsr_n),
		.uart_dcd_n(		t_uart_dcd_n),
		.uart_ri_n(		t_uart_ri_n),
		//
		.mem_cs2_rstdrv(	t_mem_cs2_rstdrv),
		.mem_cs2_int(		t_mem_cs2_int),
		.mem_cs2_dir(		t_mem_cs2_dir),
		.mem_cs2_g_n(		t_mem_cs2_g_n),
		.mem_cs2_n( 		t_mem_cs2_n),
		.mem_cs2_iochrdy(	t_mem_cs2_iochrdy),
		.mem_cs1_rst_n(		t_mem_cs1_rst_n),
		.mem_cs1_n(		t_mem_cs1_n),
		.mem_cs1_rdy(		t_mem_cs1_rdy),
		.mem_cs0_n(		t_mem_cs0_n),
		.mem_we_n(		t_mem_we_n),
		.mem_oe_n(		t_mem_oe_n),
		.mem_a( 		t_mem_a),
		.mem_d(			t_mem_d),
		//	
		.sdram0_clk(		t_sdram0_clk),
		.sdram0_cke(		t_sdram0_cke),
		.sdram0_cs_n(		t_sdram0_cs_n),
		.sdram0_ras_n(		t_sdram0_ras_n),
		.sdram0_cas_n(		t_sdram0_cas_n),
		.sdram0_we_n(		t_sdram0_we_n),
		.sdram0_dqm(		t_sdram0_dqm),
		.sdram0_ba(		t_sdram0_ba),
		.sdram0_a(		t_sdram0_a),
		.sdram0_d(		t_sdram0_d),
		//
		.sdram1_clk(		t_sdram1_clk),
		.sdram1_cke(		t_sdram1_cke),
		.sdram1_cs_n(		t_sdram1_cs_n),
		.sdram1_ras_n(		t_sdram1_ras_n),
		.sdram1_cas_n(		t_sdram1_cas_n),
		.sdram1_we_n(		t_sdram1_we_n),
		.sdram1_dqm(		t_sdram1_dqm),
		.sdram1_ba(		t_sdram1_ba),
		.sdram1_a(		t_sdram1_a),
		.sdram1_d(		t_sdram1_d),
		//
		.vga_clkp(		t_vga_clkp),
		.vga_clkn(		t_vga_clkn),
		.vga_hsync(		t_vga_hsync),
		.vga_vsync(		t_vga_vsync),
		.vga_blank(		t_vga_blank),
		.vga_d(			t_vga_d),
		//
		.misc_gpio(		t_misc_gpio),
		.misc_tp(		t_misc_tp)
	);
	//dbg_comm2 dbg_comm2(
	//	.P_TMS(		t_jtag_tms),
	//	.P_TCK(		t_jtag_tck),
	//	.P_TRST(	t_jtag_trst),
	//	.P_TDI(		t_jtag_tdi),
	//	.P_TDO(		t_jtag_tdo)
	//);
// sim
	integer	sim_cycle_current;
	initial sim_cycle_current = 0;
	parameter sim_cycle_max = 30000000;
	always @(posedge r_clk) sim_cycle_current <= sim_cycle_current + 1;
	always @(posedge r_clk) if (sim_cycle_max==sim_cycle_current) $stop;

// monitor VGA-RAM
	wire			vga_triger;
	wire			vga_clk;
	wire			vga_clk_delay1;
	wire			vga_clk_delay2;
	wire	[31:0]		vga_address;
	wire	[15:0]		vga_data;
	wire	[(32+16)-1:0]	vga_dump;
	// risky routin
	assign vga_clk			= i_sdram1_cs0.Sys_clk;
	assign #1 vga_clk_delay1	= vga_clk;
	assign #1 vga_clk_delay2	= vga_clk_delay1;
	assign vga_triger		= (vga_clk_delay1&&!vga_clk_delay2) && i_sdram1_cs0.Data_in_enable;
	assign vga_address		= {i_sdram1_cs0.Bank,i_sdram1_cs0.Row,i_sdram1_cs0.Col};
	assign vga_data			= i_sdram1_cs0.Dq_dqm;
	assign vga_dump			= {vga_address,vga_data};
	initial #1 $pan(vga_triger,vga_dump,"./c/ram/ram monitor_ram"/*"cat - >./vga.log"*/);
	//initial #1 $pan(vga_triger,vga_dump,"cat - >./vga.log");

//
// debug
//
	reg			stack_push;
	always @(posedge i_tessera_top.i_tessera_core.sys_wb_clk)
		stack_push <=
       			i_tessera_top.i_tessera_core.wb_ram1s_cyc_i &
       			i_tessera_top.i_tessera_core.wb_ram1s_stb_i &
       			i_tessera_top.i_tessera_core.wb_ram1s_we_i &
			(i_tessera_top.i_tessera_core.wb_ram1s_adr_i<=32'h0100_2000) &
			(i_tessera_top.i_tessera_core.wb_ram1s_adr_i>=32'h0100_1000);
	reg			stack_pop;
	always @(posedge i_tessera_top.i_tessera_core.sys_wb_clk)
		stack_pop <=
       			i_tessera_top.i_tessera_core.wb_ram1s_cyc_i &
       			i_tessera_top.i_tessera_core.wb_ram1s_stb_i &
       			!i_tessera_top.i_tessera_core.wb_ram1s_we_i &
			(i_tessera_top.i_tessera_core.wb_ram1s_adr_i<=32'h0100_2000) &
			(i_tessera_top.i_tessera_core.wb_ram1s_adr_i>=32'h0100_1000);
	reg			stack_check;
	always @(posedge i_tessera_top.i_tessera_core.sys_wb_clk)
		stack_check <=
       			i_tessera_top.i_tessera_core.wb_ram1s_cyc_i &
       			i_tessera_top.i_tessera_core.wb_ram1s_stb_i &
			(i_tessera_top.i_tessera_core.wb_ram1s_adr_i==32'h0100_1fb0);
		
//
//
//
/*	wire			debug_triger;
	wire			debug_clk;
	wire			debug_clk_delay1;
	wire			debug_clk_delay2;
	wire	[31:0]		debug_address;
	wire	[15:0]		debug_data;
	reg			debug_hit;
	assign debug_clk		= i_sdram0_cs0.Sys_clk;
	assign #1 debug_clk_delay1	= debug_clk;
	assign #1 debug_clk_delay2	= debug_clk_delay1;
	assign debug_triger		= (debug_clk_delay1&&!debug_clk_delay2) && i_sdram0_cs0.Data_in_enable;
	assign debug_address		= {i_sdram0_cs0.Bank,i_sdram0_cs0.Row,i_sdram0_cs0.Col};
	assign debug_data		= i_sdram0_cs0.Dq_dqm;
	always @(posedge debug_clk)
		debug_hit <= (debug_address==32'h0000_0004);
*/	
