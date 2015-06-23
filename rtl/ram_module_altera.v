//Jun.29.2004 w0,w1,w2,w3 bug fix
//Jun.30.2004 endian bug fix
//Jul.1.2004 endian bug fix
//Apr.2.2005 Change Port Address
`include "define.h"
`define COMB_MOUT
`define COMB_MOUT_IR


`define NO_SIGNED_MOUT
module ram_module_altera(clock,sync_reset,IR,MOUT,Paddr,Daddr,wren,datain,access_mode,M_signed,
	 uread_port,write_busy);
	input clock,sync_reset;
	input wren;
	input [31:0] datain;
	input M_signed;
	input [7:0] uread_port;
	input write_busy;//Apr.2.2005
`ifdef RAM32K

	input [14:0] Paddr,Daddr;//4KB address
	reg  [14:0] DaddrD;

  
`endif

`ifdef 	RAM16K

	input [13:0] Paddr,Daddr;//4KB address
	reg  [13:0] DaddrD;


`endif

`ifdef RAM4K
	input [11:0] Paddr,Daddr;//4KB address
      reg  [11:0] DaddrD;

`endif

	output [31:0] IR;//Instrcuntion Register
	output [31:0] MOUT;//data out
	input [1:0] access_mode;

	reg [31:0] IR;
	reg [31:0] MOUT;
	reg [1:0] access_modeD;
	
	wire [7:0] a0,a1,a2,a3;
	wire [7:0] b0,b1,b2,b3;
	wire [7:0] dport0,dport1,dport2,dport3;
	wire w0,w1,w2,w3;
	wire uread_port_access=`UART_PORT_ADDRESS==Daddr;
	
	reg  uread_access_reg;

	assign dport0=datain[7:0] ;
	assign dport1=access_mode !=`BYTE_ACCESS ? datain[15:8] : datain[7:0];
	assign dport2=access_mode==`LONG_ACCESS ? datain[23:16] : datain[7:0];
	assign dport3=access_mode==`LONG_ACCESS ? datain[31:24] : 
		      access_mode==`WORD_ACCESS ? datain[15:8]  : datain[7:0];
	

`ifdef RAM32K
ram8192x8_3 ram0(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[14:2]),
		      .data_b(dport0),.address_b(Daddr[14:2]),.wren_b(w0),.clock(clock),
		      .q_a(a0),.q_b(b0));

ram8192x8_2 ram1(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[14:2]),
		      .data_b(dport1),.address_b(Daddr[14:2]),.wren_b(w1),.clock(clock),
		      .q_a(a1),.q_b(b1));

ram8192x8_1  ram2(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[14:2]),
		      .data_b(dport2),.address_b(Daddr[14:2]),.wren_b(w2),.clock(clock),
		      .q_a(a2),.q_b(b2));

ram8192x8_0 ram3(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[14:2]),
		      .data_b(dport3),.address_b(Daddr[14:2]),.wren_b(w3),.clock(clock),
		      .q_a(a3),.q_b(b3));

`endif
`ifdef 	RAM16K
`ifdef ALTERA
ram4096x8_3 ram0(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[13:2]),
		      .data_b(dport0),.address_b(Daddr[13:2]),.wren_b(w0),.clock(clock),
		      .q_a(a0),.q_b(b0));

ram4096x8_2 ram1(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[13:2]),
		      .data_b(dport1),.address_b(Daddr[13:2]),.wren_b(w1),.clock(clock),
		      .q_a(a1),.q_b(b1));

ram4092x8_1  ram2(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[13:2]),
		      .data_b(dport2),.address_b(Daddr[13:2]),.wren_b(w2),.clock(clock),
		      .q_a(a2),.q_b(b2));

ram4092x8_0 ram3(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[13:2]),
		      .data_b(dport3),.address_b(Daddr[13:2]),.wren_b(w3),.clock(clock),
		      .q_a(a3),.q_b(b3));
`else
		ram1k3 ram0(.addra(Paddr[13:2]),
		      .dinb(dport0),.addrb(Daddr[13:2]),.web(w0),.clka(clock),.clkb(clock),
		      .douta(a0),.doutb(b0));
		ram1k2 ram1(.addra(Paddr[13:2]),
		      .dinb(dport1),.addrb(Daddr[13:2]),.web(w1),.clka(clock),.clkb(clock),
		      .douta(a1),.doutb(b1));
		ram1k1 ram2(.addra(Paddr[13:2]),
		      .dinb(dport2),.addrb(Daddr[13:2]),.web(w2),.clka(clock),.clkb(clock),
		      .douta(a2),.doutb(b2));
		ram1k0 ram3(.addra(Paddr[13:2]),
		      .dinb(dport3),.addrb(Daddr[13:2]),.web(w3),.clka(clock),.clkb(clock),
		      .douta(a3),.doutb(b3));
`endif
`endif

`ifdef RAM4K
ram_1k_3 ram0(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[11:2]),
		      .data_b(dport0),.address_b(Daddr[11:2]),.wren_b(w0),.clock(clock),
		      .q_a(a0),.q_b(b0));

ram_1k_2 ram1(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[11:2]),
		      .data_b(dport1),.address_b(Daddr[11:2]),.wren_b(w1),.clock(clock),
		      .q_a(a1),.q_b(b1));

ram_1k_1 ram2(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[11:2]),
		      .data_b(dport2),.address_b(Daddr[11:2]),.wren_b(w2),.clock(clock),
		      .q_a(a2),.q_b(b2));

ram_1k_0 ram3(.data_a(8'h00),.wren_a(1'b0),.address_a(Paddr[11:2]),
		      .data_b(dport3),.address_b(Daddr[11:2]),.wren_b(w3),.clock(clock),
		      .q_a(a3),.q_b(b3));

`endif

	wire temp=( access_mode==`BYTE_ACCESS &&  Daddr[1:0]==2'b00);


	assign w3= wren && 
		   (  access_mode==`LONG_ACCESS ||   
		   (  access_mode==`WORD_ACCESS && !Daddr[1]    ) ||
		   (  access_mode==`BYTE_ACCESS &&  Daddr[1:0]==2'b00));
	assign w2= wren && 
		   (  access_mode==`LONG_ACCESS ||   
		   (  access_mode==`WORD_ACCESS && !Daddr[1])  ||
		   ( Daddr[1:0]==2'b01));
	assign w1= wren && 
		   (  access_mode==`LONG_ACCESS ||   
		   (  access_mode==`WORD_ACCESS && Daddr[1]) ||
		   (  Daddr[1:0]==2'b10));
	assign w0= wren && 
		   (  access_mode==`LONG_ACCESS ||   
		   (  access_mode==`WORD_ACCESS && Daddr[1]) ||
		   (  Daddr[1:0]==2'b11));


//IR

`ifdef COMB_MOUT_IR

	always @(*) IR={a3,a2,a1,a0};


`else
	always @(posedge clock) begin
		if (sync_reset)      IR <=0;
		else  IR <={a3,a2,a1,a0};
	
	end
`endif

	always @(posedge clock) begin
		if (access_modeD==`LONG_ACCESS) begin
				if(uread_access_reg) begin
							MOUT <={23'h00_0000,write_busy,uread_port};
				end else
							MOUT <={b3,b2,b1,b0};
			
		end else if (access_modeD==`WORD_ACCESS) begin
		     case (DaddrD[1]) 
						1'b0: if(M_signed) MOUT <={{16{b3[7]}},b3,b2};//Jul.1.2004
						      else MOUT <={16'h0000,b3,b2};
					 	1'b1: if(M_signed) MOUT <={{16{b1[7]}},b1,b0};//Jul.1.2004
						      else MOUT <={16'h0000,b1,b0};
		     endcase
		end else  begin//BYTE ACCESSS
			case (DaddrD[1:0]) 
						 	2'b00:if(M_signed) MOUT <={{24{b3[7]}},b3};
										else MOUT <={16'h0000,8'h00,b3};
				  		2'b01:if(M_signed) MOUT <={{24{b2[7]}},b2};
							 	    else MOUT <={16'h0000,8'h00,b2};
							2'b10:if(M_signed) MOUT <={{24{b1[7]}},b1};
									  else MOUT <={16'h0000,8'h00,b1};
							2'b11:if(M_signed) MOUT <={{24{b0[7]}},b0};
										else MOUT <={16'h0000,8'h00,b0};
			endcase
		end
	end 

	always @(posedge clock) begin
		access_modeD<=access_mode;
		DaddrD<=Daddr;
		uread_access_reg<=uread_port_access;//Jul.7.2004
	end
endmodule


