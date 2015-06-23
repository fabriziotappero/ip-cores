module rtf65002_tb();

integer n;
reg rst;
reg clk;
reg nmi;
wire wr;
wire [5:0] bl;
wire [3:0] sel;
wire [33:0] a;
tri [31:0] d;
wire [31:0] dato;
wire [31:0] dati;
wire [2:0] cti;
wire cyc;
wire stb;
wire ack;
wire [7:0] udo;
wire btrm_ack;
wire [31:0] btrm_dato;
wire bas_ack;
wire [31:0] bas_dato;
wire tc_ack;
wire [31:0] tc_dato;
wire sema_ack;
wire [31:0] sema_dat;
wire ga_ack;
wire [31:0] ga_dat;

initial begin
	clk = 1;
	rst = 0;
	nmi = 0;
	#100 rst = 1;
	#100 rst = 0;
	#500 nmi = 0;
	#10 nmi = 0;
end

always #1 clk = ~clk;	// 500 MHz

rtf65002d cpu0 (
	.rst_i(rst),
	.clk_i(clk),
	.nmi_i(nmi),
	.irq_i(1'b0),
	.bte_o(),
	.cti_o(cti),
	.bl_o(bl),
	.lock_o(),
	.cyc_o(cyc),
	.stb_o(stb),
	.ack_i(ack),
	.we_o(wr),
	.sel_o(sel),
	.adr_o(a),
	.dat_i(dati),
	.dat_o(dato)
);

wire uartcs = cyc && stb && a[33:8]==26'h00000BF;
wire romcs = ~(cyc && stb && a[33:20]==14'h0FFF);
wire ramcs = ~(cyc && stb && (a[33:14]==20'h00 || (a[33:28]!=6'h3F && a[33:28]!=6'h0 && a[33:28]!=6'h0F)));
wire romcs1 = 1'b1;//~(cyc && stb && a[33:13]==21'h07);	// E000
wire bas_cs = (cyc && stb && a[33:14]==20'h03);
wire tc_cs = (cyc && stb && (a[33:18]==16'hFFD0 || a[33:18]==16'hFFDA ||a[33:18]==16'hFFD1 || a[33:18]==16'hFFD2));
wire leds_cs = (cyc && stb && a[33:2]==32'hFFDC0600);
wire configrec_cs = (cyc && stb && a[33:6]==28'hFFDCFFF);

assign d = wr ? dato : 32'bz;
assign dati = ~romcs ? btrm_dato : 32'bz;
assign dati = ~ramcs ? d : 32'bz;
assign dati = uartcs ? {4{udo}} : 32'bz;
assign dati = ~romcs1 ? d : 32'bz;
assign dati = bas_cs ? bas_dato : 32'bz;
assign dati = tc_cs ? tc_dato : 32'bz;
assign dati = configrec_cs ? 32'h00000FDF : 32'bz;
assign dati = sema_ack ? sema_dat : 32'bz;
assign dati = ga_ack ? ga_dat : 32'bz;

assign ack =
	configrec_cs |
	leds_cs |
	tc_ack |
	sema_ack |
	ga_ack |
	bas_ack |
	btrm_ack |
	~ramcs |
	~romcs1 |
	uartcs
	;

//rom2Kx32 #(.MEMFILE("t65c.mem")) rom0(.ce(romcs), .oe(wr), .addr(a[12:2]), .d(d));
rom2Kx32 #(.MEMFILE("t65c.mem")) rom1(.ce(romcs1), .oe(wr), .addr(a[12:2]), .d(d));
ram8Kx32 ram0 (.clk(clk), .ce(ramcs), .oe(wr), .we(~wr), .sel(sel), .addr(a[14:2]), .d(d));
uart uart0(.clk(clk), .cs(uartcs), .wr(wr), .a(a[2:0]), .di(dato[7:0]), .do(udo));
bootrom ubr1 (.rst_i(rst), .clk_i(clk), .cti_i(cti), .cyc_i(cyc), .stb_i(stb), .ack_o(btrm_ack), .adr_i(a), .dat_o(btrm_dato), .perr());
basic_rom ubas1(.rst_i(rst), .clk_i(clk), .cti_i(cti), .cyc_i(cyc), .stb_i(stb), .ack_o(bas_ack), .adr_i(a), .dat_o(bas_dato), .perr());
rtfTextController tc1 (
	.rst_i(rst),
	.clk_i(clk),
	.cyc_i(cyc),
	.stb_i(stb),
	.ack_o(tc_ack),
	.we_i(wr),
	.adr_i(a),
	.dat_i(dato),
	.dat_o(tc_dato),
	.lp(),
	.curpos(),
	.vclk(1'b0),
	.hsync(1'b0),
	.vsync(1'b0),
	.blank(1'b0),
	.border(1'b0),
	.rgbIn(),
	.rgbOut()
);

sema_mem usm1
(
	.rst_i(rst),
	.clk_i(clk),
	.cyc_i(cyc),
	.stb_i(stb),
	.ack_o(sema_ack),
	.we_i(wr),
	.adr_i(a),
	.dat_i(dato),
	.dat_o(sema_dat)
);

rtfGraphicsAccelerator uga1 (
.rst_i(rst),
.clk_i(clk),

.s_cyc_i(cyc),
.s_stb_i(stb),
.s_we_i(wr),
.s_ack_o(ga_ack),
.s_sel_i(sel),
.s_adr_i(a),
.s_dat_i(dato),
.s_dat_o(ga_dat),

.m_cyc_o(),
.m_stb_o(),
.m_we_o(),
.m_ack_i(1'b1),
.m_sel_o(),
.m_adr_o(),
.m_dat_i(),
.m_dat_o()
);

always @(posedge clk) begin
	if (rst)
		n = 0;
	else
		n = n + 1;
	if ((n & 7)==0)
		$display("t   n  cti cyc we   addr din adnx do re vma wr ird sync vma nmi irq  PC  IR A  X  Y  SP nvmdizcb\n");
	$display("%d %d %b  %b%b  %c  %h %h %h %h %h pc=%h ir=%h acc=%h x=%h y=%h sp=%h sp8=%h %b%b%b%b%b%b%b%b %s %b %b %b %b %b %b",
		$time, n, cpu0.cti_o, cpu0.cyc_o, cpu0.ack_i, cpu0.we_o?"W":" ", cpu0.adr_o, cpu0.dat_i, cpu0.dat_o, cpu0.res, cpu0.res8, cpu0.pc, cpu0.ir,
		cpu0.acc, cpu0.x, cpu0.y, cpu0.isp, cpu0.sp, 
		cpu0.nf, cpu0.vf, cpu0.df, cpu0.im, cpu0.zf, cpu0.cf, cpu0.bf, cpu0.em, cpu0.fnStateName(cpu0.state), cpu0.imiss, cpu0.ihit,cpu0.hit0,cpu0.hit1,cpu0.imiss,ubr1.cs);
end
	
endmodule

/* ---------------------------------------------------------------
	rom2kx32.v -- external async 8Kx8 ROM Verilog model
	(simulation only)

  	Note this module is a functional model, with no timing, and
  is only suitable for simulation, not synthesis.
--------------------------------------------------------------- */

module rom2Kx32(ce, oe, addr, d);
parameter MEMFILE = "t65002d.mem";
	input			ce;	// active low chip enable
	input			oe;	// active low output enable
	input	[10:0]	addr;	// byte address
	output	[31:0]	d;		// tri-state data I/O
	tri [31:0] d;

	reg		[7:0]	mem [0:8191];

	initial begin
		$readmemh (MEMFILE, mem);
//		$readmemh ("t65c.mem", mem);
		$display ("Loaded t65002d.mem");
		$display (" 000000: %h %h %h %h %h %h %h %h", 
			mem[0], mem[1], mem[2], mem[3], mem[4], mem[5], mem[6], mem[7]);
	end

	assign d = (~oe & ~ce) ? {mem[{addr,2'b11}],mem[{addr,2'b10}],mem[{addr,2'b01}],mem[{addr,2'b00}]} : 32'bz;
/*
	always @(oe or ce or addr) begin
//		$display (" 000000: %h %h %h %h %h %h %h %h %h %h", 
//			mem[0], mem[1], mem[2], mem[3], mem[4], mem[5], mem[6], mem[7], mem[8], mem[9]);
		$display (" read %h: %h", addr, mem[addr]);
	end
*/
endmodule

/* ---------------------------------------------------------------
	ram32kx8.v -- external sync 32Kx8 RAM Verilog model
	(simulation only)

  	Note this module is a functional model, with no timing, and
  is only suitable for simulation, not synthesis.
--------------------------------------------------------------- */

module ram8Kx32(clk, ce, oe, we, sel, addr, d);
	input clk;
	input			ce;		// active low chip enable
	input			oe;		// active low output enable
	input			we;		// active low write enable
	input [3:0] sel;		// byte lane selects
	input	[12:0]	addr;	// byte address
	output	[31:0]	d;		// tri-state data I/O
	tri [31:0] d;

	reg		[31:0]	mem [0:65535];
	integer nn;

	initial begin
		for (nn = 0; nn < 8192; nn = nn + 1)
			mem[nn] <= 32'b0;
	end

	assign d = (~oe & ~ce & we) ? mem[addr] : 32'bz;

	always @(posedge clk) begin
		if (clk) begin
			if (~ce & ~we) begin
				if (sel[0]) mem[addr][7:0] <= d[7:0];
				if (sel[1]) mem[addr][15:8] <= d[15:8];
				if (sel[2]) mem[addr][23:16] <= d[23:16];
				if (sel[3]) mem[addr][31:24] <= d[31:24];
				$display (" wrote: %h with %h", addr, d);
			end
			if (~ce & we & ~oe)
				$display (" read: %h val %h", addr, d);
		end
	end
/*
	always @(we or oe or ce or addr) begin
		if (ce==0)
			$display (" 000000: %h %h %h %h %h %h %h %h %h %h", 
				mem[0], mem[1], mem[2], mem[3], mem[4], mem[5], mem[6], mem[7], mem[8], mem[9]);
	end
*/
endmodule

module uart(clk, cs, wr, a, di, do);
	input clk;
	input cs;
	input wr;
	input [2:0] a;
	input [7:0] di;
	output reg [7:0] do;
//	reg [7:0] do;

	reg [127:0] msg;
	integer msgn;
	integer logf,r;
	
	initial begin
		msgn <= 0;
	end

	always @(posedge clk)
		if (cs & wr) begin
			if (di==8'h0A) begin
				$display(" ");
				$display("%s", msg);
				$display (" ");
				$stop;
				msgn <= 0;
				msg <= 0;
			end
			else begin
				case(msgn)
				0: msg[127:120] <= di;
				1: msg[119:112] <= di;
				2:	msg[111:104] <= di;
				3:	msg[103:96] <= di;
				4:	msg[95:88] <= di;
				5:	msg[87:80] <= di;
				6:	msg[79:72] <= di;
				7:	msg[71:64] <= di;
				endcase
				msgn <= msgn + 1;
			end
		end
			
//	always @(posedge clk)
//		if (cs & wr) begin
//			logf = $fopen("uart_in", "a");
//			r = $fdisplay(logf, "%h", di);
//			$fclose(logf);
//		end

	always @(a)
	begin
		case(a)
		default:
			do <= 8'h00;
		endcase
	end

//	assign do = 8'h00;

endmodule
