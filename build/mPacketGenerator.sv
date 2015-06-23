module pkt_gen32 (
clk,
rst,

control,
status,
config_1,
config_2,
i32_Payload1,
i32_Payload2,
i32_Payload3,
i32_Payload4,

pkt_rdy,
pkt_dv,
pkt_sop,
pkt_eop,
pkt_data,
pkt_BE,
pkt_rd,
pkt_len_rdy,
pkt_len,
pkt_len_rd);

input clk;
input rst;
input 	[15:00]	control;
output reg [31:00]	status;
input	[31:00] config_1;
input	[31:00] config_2;
input 	[31:00] i32_Payload1;
input 	[31:00] i32_Payload2;
input 	[31:00] i32_Payload3;
input 	[31:00] i32_Payload4;

output	pkt_rdy;
output	pkt_dv;
output	pkt_sop;
output	pkt_eop;
output	[31:00] pkt_data;
input	pkt_rd;
output	[1:0] pkt_BE;

input pkt_len_rd;
output pkt_len_rdy;
output [15:00] pkt_len;

typedef enum  {IDLE, RDY, END, WAIT} state_type;

parameter MAC_SRC	= 48'h00_1F_02_03_AA_BB;
parameter MAC_DST	= 48'h00_27_0E_1A_46_03;
parameter IP_SRC	= 32'hC0_A8_00_01;
parameter IP_DST	= 32'hC0_A8_01_B0;

reg [15:0] polynomial[16];

state_type st;
wire enable;
wire sw_rst;
wire [31:0] src_ip;
wire [31:0] dst_ip;
reg [31:00] mux_data;
reg [31:00] random_data;
reg [15:00] word_cnt;
reg [15:00] byte_cnt;
reg [31:00] timer;
reg [15:00] i_pkt_length;
reg [15:00] ip_rand;

wire [31:00] shift_random_data;

wire sop;
wire eop;
wire dv;
wire time_exp;

reg pkt_rd_d;
reg one_sec_clk;
reg [31:00] one_sec_tmr;
localparam ONE_SEC_CYCLES = 124_999_999;
reg [31:00] datarate;
reg tmr_en;

assign enable = control[0];
assign sw_rst = control[1];

	always@(posedge clk or posedge rst)
	begin
	if(rst) begin
		one_sec_tmr <= 0;
		one_sec_clk <= 0; 
		datarate <= 0;
		end
	else begin
		if(one_sec_tmr==ONE_SEC_CYCLES) begin
			one_sec_tmr <= 0;
			one_sec_clk <= 1'b1;
			end
		else 
			begin
			one_sec_tmr <= one_sec_tmr+1;
			one_sec_clk <= 1'b0;	
			end
		if(one_sec_clk) begin
				datarate <= 0;
				status <= datarate; end
		else if(dv) 
				datarate <= datarate+1;			
		end
	end

	always@(posedge clk or posedge rst)
	if(rst)
		st <= IDLE;
	else
		begin
			if((sw_rst) || (~enable))
				st<= IDLE;
			else
				case(st)
					IDLE: st <= RDY;
					RDY : if(eop) st<= END;
					END : st <= WAIT;
					WAIT: if(time_exp) st <= IDLE;
				endcase
		end
	
	assign pkt_rdy = (st==RDY);
	assign pkt_len_rdy = enable;
	assign pkt_len = i_pkt_length;
	assign eop = (byte_cnt<=4 && byte_cnt>0 && dv ==1'b1);
	assign sop = (byte_cnt == i_pkt_length && dv == 1'b1);
	assign pkt_eop = eop;
	assign pkt_dv  = dv;
	assign pkt_sop = sop;
	assign dv = pkt_rd_d && (st==RDY);
	assign pkt_BE = byte_cnt[1:0];
	
	always@(posedge clk)
	begin
		if(st==IDLE||st==END) begin
			word_cnt <= 0; 
			byte_cnt <= config_1[15:0];	
			i_pkt_length <= config_1[15:0];
			end
		else		  
		if(dv) begin
			word_cnt <= word_cnt+1;
			if(byte_cnt>4) 
				byte_cnt <= byte_cnt-4;
			else
				byte_cnt <= 0;
		end
		
		if(st==IDLE)	
		    tmr_en <= 1'b0;
		else if(sop)
		    tmr_en <= 1'b1;
		
		if(st==IDLE)
				timer <= config_2;
		else if(tmr_en && (timer!=0))		timer <= timer - 1;
		  
		if(st==RDY)
			pkt_rd_d <= pkt_rd; else 
			pkt_rd_d <= 1'b0;
	end
	
	/*always@(*)
	begin
    case(word_cnt)
		0: mux_data <= MAC_DST[47:16];
		1: mux_data <= {MAC_DST[15:00], MAC_SRC[47:32]};
		2: mux_data <= MAC_SRC[31:00];
		3: mux_data <= {config_1[15:0],16'h0000};//{16'h0800,16'h0000};
		4: mux_data <= 32'h00;//{config_1[15:0],16'h0000};
		5: mux_data <= {16'h0000,16'h0000};
		6: mux_data <= {16'h0000,src_ip[31:16]};
		7: mux_data <= {src_ip[15:0],IP_DST[31:16]};
		8: mux_data <= {IP_DST[15:0],16'h0000};
		default: mux_data <= {byte_cnt,byte_cnt};//random_data;
		endcase  
	end*/
	always@(*)
	begin
    case(word_cnt)
		0: mux_data <= MAC_DST[47:16];
		1: mux_data <= {MAC_DST[15:00], MAC_SRC[47:32]};
		2: mux_data <= MAC_SRC[31:00];
		3: mux_data <= {(config_1[15:0]-16'd14),16'h0000};//{16'h0800,16'h0000};
		4: mux_data <= i32_Payload1;
		5: mux_data <= i32_Payload2;
		6: mux_data <= i32_Payload3;
		7: mux_data <= i32_Payload4;
		default: mux_data <= {32'h0102_0304};//random_data;
		endcase  
	end
	  
	
	assign time_exp = (timer==0);
	assign pkt_data = mux_data;
	
	//random data generation
	assign shift_random_data = {random_data[30:0],^(random_data&32'h1034_BCFE)};
	always@(posedge clk)
	begin
		if(word_cnt==3 && dv==1'b1)
			random_data <= MAC_DST[31:00];
		else
			if(dv) begin
				random_data <= random_data[31]?shift_random_data:(~shift_random_data);
	end	
	end
	
	always@(posedge clk or posedge rst)
	begin
		if(rst) begin			
		  ip_rand <= 16'h1;
		  //For this polynomial, look for maxim-ic.com/app-notes/index.mvp/id/1743
		  polynomial[00] = 16'h0;
		  polynomial[01] = 16'h0;
 		  polynomial[02] = 16'h0005;
		  polynomial[03] = 16'h0009;
		  polynomial[04] = 16'h0012;
  		  polynomial[05] = 16'h0021;
  		  polynomial[06] = 16'h0041;
  		  polynomial[07] = 16'h008E;
 		  polynomial[08] = 16'h0108;
		  polynomial[09] = 16'h0204;
		  polynomial[10] = 16'h0402;
  		  polynomial[11] = 16'h0829;
  		  polynomial[12] = 16'h100D;
  		  polynomial[13] = 16'h2015;
  		  polynomial[14] = 16'h4001;
  		  polynomial[15] = 16'h8016;  		  
			end
		else
			begin
				if(eop & dv)		begin
					ip_rand = {ip_rand[15:0],^(ip_rand&(polynomial[config_1[19:16]]))};			
				  ip_rand[(config_1[19:16]+1)] = 1'b0;
				  //synthesis_off
				  $display("IPRAND = %d",ip_rand);
				  //synthesis_on
				end
			end
	end
	
	assign src_ip = {IP_SRC[31:16],ip_rand};
	
	//synthesis_off
	/*
	always@(posedge clk or posedge rst)
	begin
	  integer found[];
	  integer i;
	  integer cnt;
		if(rst) begin
		  cnt = 0;
		  for(i=0;i<5000;i++)
		  begin
		    found[i]=0;		    
	    end		  
		end		
		else
			begin
			if(sop & dv)		begin
					if(found[ip_rand]==0) begin 
					   cnt++;
					   found[ip_rand]=1;
					   $display("Total Streams %d",cnt);
					  end
				end
			end
	end*/
	
	//synthesis_on

endmodule
