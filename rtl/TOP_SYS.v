/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
/* verilator lint_off PINNOCONNECT */
/* verilator lint_off PINMISSING */
/* verilator lint_off IMPLICIT */
/* verilator lint_off WIDTH */


`define dcm

module TOP_SYS(
`ifdef dcm
clk100,
`else
clk,
`endif
TXD,rstn,gpio_in,RXD,
extA,extDB,extWEN,extUB,extLB,extCSN,
extOE,extCLK,extADV,extCRE,
sdin,sdout,sdwp,sdhld,sdcs,
gpioA,gpioB
);

`ifdef dcm
input            clk100;
`else
input            clk;
`endif

input            rstn;
output           TXD;
input      [6:0] gpio_in;
output           extCLK,extCRE;
output          extADV,extUB,extLB,extWEN,extCSN,extOE;
input            RXD;
output           sdout,sdwp,sdhld,sdcs;
input            sdin;
inout     [7:0]  gpioA,gpioB;

// external mem I/F
inout  [15:0] extDB;
output [23:0] extA;


wire [31:0] wb_adr;
wire [31:0] wb_dat_o;
wire  [3:0] wb_sel;
wire        wb_we;
wire        wb_ack;
wire  [2:0] wb_cti;
wire [31:0] wb_dat_i;
wire [15:0] extDBo;

wire  [7:0] gpioA_dir,gpioB_dir,gpioA_out,gpioB_out;
wire [31:0] romA,romQ;
wire        wb_cyc_ram,wb_cyc_rom;
wire        wb_ack_ram,wb_ack_rom;
wire [31:0] wb_dat_ram,wb_dat_rom;

`ifdef dcm
wire        clk;

clk_wiz_v3_6 (.CLK_IN1(clk100) , .CLK_OUT1(clk) );

STARTUPE2 #(
   .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
   .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
)
STARTUPE2_inst (
   .CFGCLK(),       // 1-bit output: Configuration main clock output
   .CFGMCLK(),     // 1-bit output: Configuration internal oscillator clock output
   .EOS(),             // 1-bit output: Active high output signal indicating the End Of Startup.
   .PREQ(),           // 1-bit output: PROGRAM request to fabric output
   .CLK(1'b0),             // 1-bit input: User start-up clock input
   .GSR(1'b0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
   .GTS(1'b0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
   .KEYCLEARB(1'b0), // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
   .PACK(1'b0),           // 1-bit input: PROGRAM acknowledge input
   .USRCCLKO(sdclk),   // 1-bit input: User CCLK input
   .USRCCLKTS(1'b0), // 1-bit input: User CCLK 3-state enable input
   .USRDONEO(1'b1),   // 1-bit input: User DONE pin output control
   .USRDONETS(1'b1)  // 1-bit input: User DONE 3-state enable output
);
`endif


v586 v586 (
.rstn(rstn),.clk(clk),.cfg(gpio_in[6:0]),
// spi
.spi_mosi(sdout),
.spi_miso(sdin),
.spi_clk(sdclk),
.spi_cs(sdcs),
// wb interface 16bit
.wb_dat_o(wb_dat_o),.wb_adr_o(wb_adr),.wb_dat_i(wb_dat_i), .wb_cti_o(wb_cti),
.wb_sel_o(wb_sel),.wb_stb_o(wb_stb),.wb_ack_i(wb_ack), .wb_we_o(wb_we),
// interrupts
.int1(1'b0),.int2(1'b0),.int3(1'b0),.int5(1'b0),.int6(1'b0),.int7(1'b0),
// gpio
.gpioA_in(gpioA),.gpioB_in(gpioB),
.gpioA_out(gpioA_out),.gpioB_out(gpioB_out),
.gpioA_dir(gpioA_dir),.gpioB_dir(gpioB_dir),
//uart
.RXD(RXD),
.TXD(TXD)
);

assign sdwp = 1'b1;
assign sdhld = 1'b1;
//
// MEMORY CONTROL : Internal ROM/External RAM arbitration
//                  External RAM State Machine REQ/ACK/busrt on whishbone bus

asram_core #(.SRAM_DATA_WIDTH(16),
             .SRAM_ADDR_WIDTH(24),
             .READ_LATENCY(4),
             .WRITE_LATENCY(4)
    ) asram_core (
   .clk_i(clk),
   .rst_i(~rstn),
   // Wishbone side interface
   .cti_i(wb_cti),
   .bte_i(2'b00),
   .addr_i(wb_adr),
   .dat_i(wb_dat_o),
   .sel_i(wb_sel),
   .we_i(wb_we),
   .stb_i(wb_stb),
   .cyc_i(wb_cyc_ram),
   .ack_o(wb_ack_ram),
   .dat_o(wb_dat_ram),
   // SRAM side interface
   .sram_addr(extA),
   .sram_data_in(extDB),
   .sram_data_out(extDBo),
   .sram_csn(extCSN),
   .sram_be({extUB,extLB}),
   .sram_wen(extWEN),
   .sram_oen(extOE)
   );
   
assign extDB = extOE ? extDBo : 32'bz ; 

assign extCLK = 1'b0;
assign extCRE = 1'b0;
assign extADV = 1'b0;


asram_core #(.SRAM_DATA_WIDTH(32),
             .SRAM_ADDR_WIDTH(32),
             .READ_LATENCY(2),
             .WRITE_LATENCY(2)
    ) bootrom (
   .clk_i(clk),
   .rst_i(~rstn),
   // Wishbone side interface
   .cti_i(wb_cti),
   .bte_i(2'b00),
   .addr_i(wb_adr),
   .dat_i(wb_dat_o),
   .sel_i(wb_sel),
   .we_i(wb_we),
   .stb_i(wb_stb),
   .cyc_i(wb_cyc_rom),
   .ack_o(wb_ack_rom),
   .dat_o(wb_dat_rom),
   // SRAM side interface
   .sram_addr(romA),
   .sram_data_in(romQ),
   .sram_data_out(),
   .sram_csn(),
   .sram_be(),
   .sram_wen(),
   .sram_oen()
   );
   
extrom extrom (.clk(clk) , .Q(romQ) , .A(romA) );

assign wb_ack     = (wb_adr[31:12]==20'h000ff) ? wb_ack_rom : wb_ack_ram;
assign wb_dat_i   = (wb_adr[31:12]==20'h000ff) ? wb_dat_rom : wb_dat_ram;
assign wb_cyc_ram = (wb_adr[31:12]==20'h000ff) ? 1'b0 : wb_stb;
assign wb_cyc_rom = (wb_adr[31:12]==20'h000ff) ? wb_stb : 1'b0;



assign gpioA[0] = (gpioA_dir[0] == 0) ? 1'bz : gpioA_out[0];
assign gpioA[1] = (gpioA_dir[1] == 0) ? 1'bz : gpioA_out[1];
assign gpioA[2] = (gpioA_dir[2] == 0) ? 1'bz : gpioA_out[2];
assign gpioA[3] = (gpioA_dir[3] == 0) ? 1'bz : gpioA_out[3];
assign gpioA[4] = (gpioA_dir[4] == 0) ? 1'bz : gpioA_out[4];
assign gpioA[5] = (gpioA_dir[5] == 0) ? 1'bz : gpioA_out[5];
assign gpioA[6] = (gpioA_dir[6] == 0) ? 1'bz : gpioA_out[6];
assign gpioA[7] = (gpioA_dir[7] == 0) ? 1'bz : gpioA_out[7];
assign gpioB[0] = (gpioB_dir[0] == 0) ? 1'bz : gpioB_out[0];
assign gpioB[1] = (gpioB_dir[1] == 0) ? 1'bz : gpioB_out[1];
assign gpioB[2] = (gpioB_dir[2] == 0) ? 1'bz : gpioB_out[2];
assign gpioB[3] = (gpioB_dir[3] == 0) ? 1'bz : gpioB_out[3];
assign gpioB[4] = (gpioB_dir[4] == 0) ? 1'bz : gpioB_out[4];
assign gpioB[5] = (gpioB_dir[5] == 0) ? 1'bz : gpioB_out[5];
assign gpioB[6] = (gpioB_dir[6] == 0) ? 1'bz : gpioB_out[6];
assign gpioB[7] = (gpioB_dir[7] == 0) ? 1'bz : gpioB_out[7];


endmodule
