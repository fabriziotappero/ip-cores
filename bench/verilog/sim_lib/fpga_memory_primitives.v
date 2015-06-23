
//
//ALTERA_LPM
//
module lpm_ram_dq (
    address,
    inclock,
    outclock,
    data,
    we,
    q
);

parameter lpm_width = 8;
parameter lpm_widthad = 11;
parameter lpm_indata = "REGISTERED";            //This 4 parameters are included only to avoid warnings
parameter lpm_address_control = "REGISTERED";   //they are not accessed inside the module. OR1200 uses this 
parameter lpm_outdata = "UNREGISTERED";         //configuration set on all its instantiations, so this is fine.
parameter lpm_hint = "USE_EAB=ON";              //It may not be fine, if you are adding this library to your 
                                                //own system, which uses this module with another configuration.
localparam dw = lpm_width;
localparam aw = lpm_widthad;

input [aw-1:0] address;
input inclock;
input outclock;
input [dw-1:0] data;
input we;
output [dw-1:0] q;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign q = mem[addr_reg];

//
// RAM address register
//
always @(posedge inclock)
    addr_reg <= #1 address;

//
// RAM write
//
always @(posedge inclock)
	if (we)
		mem[address] <= #1 data;

endmodule

module altqpram (
	wraddress_a,
	inclocken_a,
	wraddress_b,
	wren_a,
	inclocken_b,
	wren_b,
	inaclr_a,
	inaclr_b,
	inclock_a,
	inclock_b,
	data_a,
	data_b,
	q_a,
	q_b 
);

parameter width_write_a = 8;
parameter widthad_write_a = 11;
parameter width_write_b = 8;
parameter widthad_write_b = 11;

localparam dw = width_write_a;
localparam aw = widthad_write_a;

input inclock_a, inaclr_a, inclocken_a, wren_a, inclock_b, inaclr_b, inclocken_b, wren_b;
input [dw-1:0] data_a, data_b;
output [dw-1:0] q_a, q_b;
input [aw-1:0] wraddress_a, wraddress_b;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg_a;		// RAM address register
reg	[aw-1:0]	addr_reg_b;		// RAM address register

//
// Data output drivers
//
assign q_a = mem[addr_reg_a][dw-1:0];
assign q_b = mem[addr_reg_b][dw-1:0];

//
// RAM address register
//
always @(posedge inclock_a or posedge inaclr_a)
    if ( inaclr_a == 1'b1 )
        addr_reg_a <= #1 {aw{1'b0}};
    else if ( inclocken_a )
        addr_reg_a <= #1 wraddress_a;

always @(posedge inclock_b or posedge inaclr_b)
    if ( inaclr_b == 1'b1 )
        addr_reg_b <= #1 {aw{1'b0}};
    else if ( inclocken_b )
        addr_reg_b <= #1 wraddress_b;

//
// RAM write
//
always @(posedge inclock_a)
	if (inclocken_a && wren_a)
		mem[wraddress_a] <= #1 data_a;

always @(posedge inclock_b)
	if (inclocken_b && wren_b)
		mem[wraddress_b] <= #1 data_b;

endmodule
//
// ~ALTERA_LPM
//


//
//XILINX_RAMB16
//
module RAMB16_S36_S36 (
    CLKA,
    SSRA,
    ADDRA,
    DIA,
    DIPA,
    ENA,
    WEA,
    DOA,
    DOPA,

    CLKB,
    SSRB,
    ADDRB,
    DIB,
    DIPB,
    ENB,
    WEB,
    DOB,
    DOPB
);

parameter dw = 32;
parameter dwp = 4;
parameter aw = 9;

input CLKA, SSRA, ENA, WEA, CLKB, SSRB, ENB, WEB;
input [dw-1:0] DIA, DIB;
output [dw-1:0] DOA, DOB;
input [dwp-1:0] DIPA, DIPB;
output [dwp-1:0] DOPA, DOPB;
input [aw-1:0] ADDRA, ADDRB;

reg	[dw+dwp-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg_a;		// RAM address register
reg	[aw-1:0]	addr_reg_b;		// RAM address register

//
// Data output drivers
//
assign DOA = mem[addr_reg_a][dw-1:0];
assign DOPA = mem[addr_reg_a][dwp+dw-1:dw];
assign DOB = mem[addr_reg_b][dw-1:0];
assign DOPB = mem[addr_reg_b][dwp+dw-1:dw];

//
// RAM address register
//
always @(posedge CLKA or posedge SSRA)
    if ( SSRA == 1'b1 )
        addr_reg_a <= #1 {aw{1'b0}};
    else if ( ENA )
        addr_reg_a <= #1 ADDRA;

always @(posedge CLKB or posedge SSRB)
    if ( SSRB == 1'b1 )
        addr_reg_b <= #1 {aw{1'b0}};
    else if ( ENB )
        addr_reg_b <= #1 ADDRB;

//
// RAM write
//
always @(posedge CLKA)
	if (ENA && WEA)
		mem[ADDRA] <= #1 { DIPA , DIA };

always @(posedge CLKB)
	if (ENB && WEB)
		mem[ADDRB] <= #1 { DIPB , DIB };

endmodule


module RAMB16_S9 (
    CLK,
    SSR,
    ADDR,
    DI,
    DIP,
    EN,
    WE,
    DO,
    DOP
);

parameter dw = 8;
parameter dwp = 1;
parameter aw = 11;

input CLK, SSR, EN, WE;
input [dw-1:0] DI;
output [dw-1:0] DO;
input [dwp-1:0] DIP;
output [dwp-1:0] DOP;
input [aw-1:0] ADDR;

reg	[dw+dwp-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign DO = mem[addr_reg][dw-1:0];
assign DOP = mem[addr_reg][dwp+dw-1:dw];

//
// RAM address register
//
always @(posedge CLK or posedge SSR)
    if ( SSR == 1'b1 )
        addr_reg <= #1 {aw{1'b0}};
    else if ( EN )
        addr_reg <= #1 ADDR;

//
// RAM write
//
always @(posedge CLK)
	if (EN && WE)
		mem[ADDR] <= #1 { DIP , DI };

endmodule


module RAMB16_S36 (
    CLK,
    SSR,
    ADDR,
    DI,
    DIP,
    EN,
    WE,
    DO,
    DOP
);

parameter dw = 32;
parameter dwp = 4;
parameter aw = 9;

input CLK, SSR, EN, WE;
input [dw-1:0] DI;
output [dw-1:0] DO;
input [dwp-1:0] DIP;
output [dwp-1:0] DOP;
input [aw-1:0] ADDR;

reg	[dw+dwp-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign DO = mem[addr_reg][dw-1:0];
assign DOP = mem[addr_reg][dwp+dw-1:dw];

//
// RAM address register
//
always @(posedge CLK or posedge SSR)
    if ( SSR == 1'b1 )
        addr_reg <= #1 {aw{1'b0}};
    else if ( EN )
        addr_reg <= #1 ADDR;

//
// RAM write
//
always @(posedge CLK)
	if (EN && WE)
		mem[ADDR] <= #1 { DIP , DI };

endmodule


module RAMB16_S18 (
    CLK,
    SSR,
    ADDR,
    DI,
    DIP,
    EN,
    WE,
    DO,
    DOP
);

parameter dw = 16;
parameter dwp = 2;
parameter aw = 10;

input CLK, SSR, EN, WE;
input [dw-1:0] DI;
output [dw-1:0] DO;
input [dwp-1:0] DIP;
output [dwp-1:0] DOP;
input [aw-1:0] ADDR;

reg	[dw+dwp-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign DO = mem[addr_reg][dw-1:0];
assign DOP = mem[addr_reg][dwp+dw-1:dw];

//
// RAM address register
//
always @(posedge CLK or posedge SSR)
    if ( SSR == 1'b1 )
        addr_reg <= #1 {aw{1'b0}};
    else if ( EN )
        addr_reg <= #1 ADDR;

//
// RAM write
//
always @(posedge CLK)
	if (EN && WE)
		mem[ADDR] <= #1 { DIP , DI };

endmodule
//
//~XILINX_RAMB16
//


//
//XILINX_RAMB4
//
module RAMB4_S16_S16 (
    CLKA,
    RSTA,
    ADDRA,
    DIA,
    ENA,
    WEA,
    DOA,

    CLKB,
    RSTB,
    ADDRB,
    DIB,
    ENB,
    WEB,
    DOB
);

parameter dw = 16;
parameter aw = 8;

input CLKA, RSTA, ENA, WEA, CLKB, RSTB, ENB, WEB;
input [dw-1:0] DIA, DIB;
output [dw-1:0] DOA, DOB;
input [aw-1:0] ADDRA, ADDRB;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg_a;		// RAM address register
reg	[aw-1:0]	addr_reg_b;		// RAM address register

//
// Data output drivers
//
assign DOA = mem[addr_reg_a][dw-1:0];
assign DOB = mem[addr_reg_b][dw-1:0];

//
// RAM address register
//
always @(posedge CLKA or posedge RSTA)
    if ( RSTA == 1'b1 )
        addr_reg_a <= #1 {aw{1'b0}};
    else if ( ENA )
        addr_reg_a <= #1 ADDRA;

always @(posedge CLKB or posedge RSTB)
    if ( RSTB == 1'b1 )
        addr_reg_b <= #1 {aw{1'b0}};
    else if ( ENB )
        addr_reg_b <= #1 ADDRB;

//
// RAM write
//
always @(posedge CLKA)
	if (ENA && WEA)
		mem[ADDRA] <= #1 DIA;

always @(posedge CLKB)
	if (ENB && WEB)
		mem[ADDRB] <= #1 DIB;

endmodule

module RAMB4_S4 (
    CLK,
    RST,
    ADDR,
    DI,
    EN,
    WE,
    DO,
);

parameter dw = 4;
parameter aw = 10;

input CLK, RST, EN, WE;
input [dw-1:0] DI;
output [dw-1:0] DO;
input [aw-1:0] ADDR;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign DO = mem[addr_reg][dw-1:0];

//
// RAM address register
//
always @(posedge CLK or posedge RST)
    if ( RST == 1'b1 )
        addr_reg <= #1 {aw{1'b0}};
    else if ( EN )
        addr_reg <= #1 ADDR;

//
// RAM write
//
always @(posedge CLK)
	if (EN && WE)
		mem[ADDR] <= #1 DI;

endmodule

module RAMB4_S16 (
    CLK,
    RST,
    ADDR,
    DI,
    EN,
    WE,
    DO
);

parameter dw = 16;
parameter aw = 8;

input CLK, RST, EN, WE;
input [dw-1:0] DI;
output [dw-1:0] DO;
input [aw-1:0] ADDR;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign DO = mem[addr_reg][dw-1:0];

//
// RAM address register
//
always @(posedge CLK or posedge RST)
    if ( RST == 1'b1 )
        addr_reg <= #1 {aw{1'b0}};
    else if ( EN )
        addr_reg <= #1 ADDR;

//
// RAM write
//
always @(posedge CLK)
	if (EN && WE)
		mem[ADDR] <= #1 DI;

endmodule

module RAMB4_S2 (
    CLK,
    RST,
    ADDR,
    DI,
    EN,
    WE,
    DO,
);

parameter dw = 2;
parameter aw = 11;

input CLK, RST, EN, WE;
input [dw-1:0] DI;
output [dw-1:0] DO;
input [aw-1:0] ADDR;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign DO = mem[addr_reg][dw-1:0];

//
// RAM address register
//
always @(posedge CLK or posedge RST)
    if ( RST == 1'b1 )
        addr_reg <= #1 {aw{1'b0}};
    else if ( EN )
        addr_reg <= #1 ADDR;

//
// RAM write
//
always @(posedge CLK)
	if (EN && WE)
		mem[ADDR] <= #1 DI;

endmodule

module RAMB4_S8 (
    CLK,
    RST,
    ADDR,
    DI,
    EN,
    WE,
    DO,
);

parameter dw = 8;
parameter aw = 9;

input CLK, RST, EN, WE;
input [dw-1:0] DI;
output [dw-1:0] DO;
input [aw-1:0] ADDR;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign DO = mem[addr_reg][dw-1:0];

//
// RAM address register
//
always @(posedge CLK or posedge RST)
    if ( RST == 1'b1 )
        addr_reg <= #1 {aw{1'b0}};
    else if ( EN )
        addr_reg <= #1 ADDR;

//
// RAM write
//
always @(posedge CLK)
	if (EN && WE)
		mem[ADDR] <= #1 DI;

endmodule
//
// ~XILINX_RAMB4
//


//
// XILINX_RAM32X1D
//
module RAM32X1D (
    DPO,
    SPO,
    A0,
    A1,
    A2,
    A3,
    A4,
    D,
    DPRA0,
    DPRA1,
    DPRA2,
    DPRA3,
    DPRA4,
    WCLK,
    WE
);

parameter dw = 1;
parameter aw = 5;

output DPO, SPO;
input DPRA0, DPRA1, DPRA2, DPRA3, DPRA4;
input A0, A1, A2, A3, A4;
input D;
input WCLK;
input WE;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content

//
// Data output drivers
//
assign DPO = mem[{DPRA4 , DPRA3 , DPRA2 , DPRA1 , DPRA0}][dw-1:0];
assign SPO = mem[{A4 , A3 , A2 , A1 , A0}][dw-1:0];

//
// RAM write
//
always @(posedge WCLK)
	if (WE)
		mem[{A4 , A3 , A2 , A1 , A0}] <= #1 D;

endmodule
//
// ~XILINX_RAM32X1D
//


//
// USE_RAM16X1D_FOR_RAM32X1D
//
module RAM16X1D (
    DPO,
    SPO,
    A0,
    A1,
    A2,
    A3,
    D,
    DPRA0,
    DPRA1,
    DPRA2,
    DPRA3,
    WCLK,
    WE
);

parameter dw = 1;
parameter aw = 4;

output DPO, SPO;
input DPRA0, DPRA1, DPRA2, DPRA3;
input A0, A1, A2, A3;
input D;
input WCLK;
input WE;

reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content

//
// Data output drivers
//
assign DPO = mem[{DPRA3 , DPRA2 , DPRA1 , DPRA0}][dw-1:0];
assign SPO = mem[{A3 , A2 , A1 , A0}][dw-1:0];

//
// RAM write
//
always @(posedge WCLK)
	if (WE)
		mem[{A3 , A2 , A1 , A0}] <= #1 D;

endmodule
//
// ~USE_RAM16X1D_FOR_RAM32X1D
//
