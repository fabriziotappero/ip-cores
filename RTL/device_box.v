				
`define HARD_CLOCK							 


`ifndef HARD_CLOCK		
	`define SEG7_CLOCK_MODEL	  
`endif 			   


module led_interface (
input clk,  rst,  wr, rd,
input [7:0] din,
output reg [7:0] dout,
output [7:0]led
);
reg [7:0] led_data;
assign led = led_data;

always @ (posedge clk)
if (rst)
led_data = 0;
else if (wr)
led_data=din;

always@ (posedge clk)
if (rd)
dout=led_data;
else dout = 0; 
	
	
endmodule


module clock_seg7led_interface(
input clk,rst,
input [7:0]din,
output reg [7:0]dout,
input wr,rd ,
input [2:0]wr_addr,input [2:0]rd_addr,
output reg [7:0] seg7_sel,seg7_data
);  
reg [7:0]buff[0:3];
always @ (posedge clk)
if (wr)
buff[wr_addr] = din;

always @(posedge clk)
if (rd)
dout = buff[rd_addr] ;
else dout=0;

	/*the main counter*/
    reg [31:0] seg7_cntr;
    always @(posedge clk)seg7_cntr=seg7_cntr+1;
    wire  [2:0]  sel =seg7_cntr[17:15] ;  
	wire flash_bit = seg7_cntr[21];
    always @(posedge clk)
    case (sel[2:0])
        0:seg7_data=(buff[3][0]&flash_bit)?'hff:seg(buff[0][3:0]);
        1:seg7_data=(buff[3][1]&flash_bit)?'hff:seg(buff[0][3:0]);
        2:seg7_data=(buff[3][2]&flash_bit)?'hff:~8'b01000000;
        3:seg7_data=(buff[3][3]&flash_bit)?'hff:seg(buff[1][3:0]);
        4:seg7_data=(buff[3][4]&flash_bit)?'hff:seg(buff[1][3:0]);
        5:seg7_data=(buff[3][5]&flash_bit)?'hff:~8'b01000000;
        6:seg7_data=(buff[3][6]&flash_bit)?'hff:seg(buff[2][3:0]);
        7:seg7_data=(buff[3][7]&flash_bit)?'hff:seg(buff[2][3:0]);
    endcase

    always @(posedge clk) seg7_sel=~(1<<sel);
		
		
    function [7:0] seg;
        input [3:0] data;
        begin
            case(data)
                0: seg = ~8'b00111111;//b11111100;
                1: seg = ~8'b00000110;//01100000;
                2: seg = ~8'b01011011;//11011010;
                3: seg = ~8'b01001111;//11010010;
                4: seg = ~8'b01100110;//1100110;
                5: seg = ~8'b01101101;//10110110;
                6: seg = ~8'b01111101;//10111110;
                7: seg = ~8'b00000111;//11100000;
                8: seg = ~8'b01111111;//11111110;
                9: seg = ~8'b01101111;//11110110;
                10: seg = ~8'b01110111;//11101110;
                11: seg = ~8'b01111100;//00111110;
                12: seg = ~8'b01011000;//00011010;
                13: seg = ~8'b01011110;//01111010;
                14: seg = ~8'b01111001;//10011110;
                15: seg = ~8'b01110001;//10001110;
            endcase
        end
    endfunction
	
	
endmodule 


module seg7led_interface(
input clk,rst,
input [7:0]din,
output reg [7:0]dout,
input wr,rd ,
input [2:0]wr_addr,
input [2:0]rd_addr,
output reg [7:0] seg7_sel,
output reg [7:0] seg7_data
);  
reg [7:0]buff[0:7];

always @ (posedge clk)if (wr)buff[wr_addr] = din;

always @(posedge clk)if (rd)dout = buff[rd_addr] ;else dout=0;

reg  [22:0] cntr ;
always @ (posedge clk)
cntr = cntr +1;
reg  [2:0]sel ;
always @ (posedge clk)
sel= cntr[22:19];

always @(posedge clk)
  case (sel)
   0:seg7_data=buff[0];
   1:seg7_data=buff[1];
   2:seg7_data=buff[2];
   3:seg7_data=buff[3];
   4:seg7_data=buff[4];
   5:seg7_data=buff[5];
   6:seg7_data=buff[6];
   7:seg7_data=buff[7];   
  endcase   
  always @(posedge clk)  
   seg7_sel = 1<<sel;    

endmodule 


module sw_interface(
input clk,rst,rd,
input [7:0]sw,
output reg[7:0] dout
);
reg [7:0]sw_r;
always @ (posedge clk)sw_r = sw;
always @ (posedge clk)if (rd)dout=sw_r;else dout =0;
endmodule 

module key_interface(
input clk,rst,rd,
input [3:0]key,
output reg [7:0]dout
);
reg [3:0]key_r;
always @ (posedge clk)
key_r=key; 				 

wire [3:0]w_key;	
always @(posedge clk)
begin 
dout[7:4]=0;
if (rd)dout[3:0] = w_key;else dout[3:0]=0;
end		 	

`define KEY_FSM
`ifdef KEY_FSM
key_fsm ukey0(.clk(clk),.rst(rst),.key_i(key_r[0]),.key_o(w_key[0]),.rd(rd));	
key_fsm ukey1(.clk(clk),.rst(rst),.key_i(key_r[1]),.key_o(w_key[1]),.rd(rd));	
key_fsm ukey2(.clk(clk),.rst(rst),.key_i(key_r[2]),.key_o(w_key[2]),.rd(rd));	
key_fsm ukey3(.clk(clk),.rst(rst),.key_i(key_r[3]),.key_o(w_key[3]),.rd(rd));	 
`else  
	assign w_key = key_r;
`endif 
endmodule 	  

module beep_interface(
	input clk,rst,rd,wr,
	output reg [7:0]dout ,
	input [7:0]din,
	output  beep
	);		   
	
	reg beep_en;
	always @ (posedge clk)
		if (rst)beep_en=0;
		else if (wr)
			beep_en=din[0];
			
	always @(posedge clk)
		if (rd)
			dout ={7'b0, beep_en}; 
		else dout=0;  
			
  BELL uu(
        .sys_clk(clk),
		    .beep(beep),
		    .beep_en(beep_en)
		    );				
			
endmodule 	
	 
`define ADDR_LED 8
`define ADDR_SEG 0
`define ADDR_SW  9
`define ADDR_KEY  10  
`define ADDR_BEEP 11
`define ADDR_SECGEN 12
 
module devices_box(
input clk,rst,wr,rd,
input [7:0]din,
input [7:0]sw ,
input [3:0] key,
input [7:0]wr_addr,
input [7:0]rd_addr,
output  [7:0]dout ,
output  [7:0]seg7_sel,
output [7:0]seg7_data, 
output [7:0]led
);					  			   						   
									  

wire [7:0]dout_key;
wire sel_key_wr = wr_addr==`ADDR_KEY;
wire sel_key_rd = rd_addr==`ADDR_KEY;
key_interface u1(
 .clk(clk),
 .rst(rst),
 .rd(rd&sel_key_rd),
 .key(key),
 .dout(dout_key)
);

wire [7:0]dout_sw;
			  
wire sel_sw_wr  = wr_addr==`ADDR_SW;	
wire sel_sw_rd  = rd_addr==`ADDR_SW;
 sw_interface u2(
.clk(clk),
.rst(rst),
.rd(rd&sel_sw_rd),
.sw(sw),
.dout(dout_sw)
);

wire [7:0]dout_seg7led;
										   								 
wire sel_seg7_wr = (wr_addr&(~7))== 0;	  
wire sel_seg7_rd = (rd_addr&(~7))== 0;	 

`ifdef HARD_CLOCK	   
hard_clock 	   
`else	   	  
	`ifdef SEG7_CLOCK_MODEL
	clock_seg7led_interface	  
	`else
	seg7led_interface 
	`endif	  
`endif	   

clock(
.clk(clk),
.rst(rst),
.din(din ),
.dout(dout_seg7led),
.wr(wr&sel_seg7_wr ),
.rd(rd&sel_seg7_rd ) ,
.rd_addr(rd_addr[2:0]),
.wr_addr(wr_addr[2:0]),
.seg7_sel(seg7_sel),
.seg7_data(seg7_data)
);  


wire [7:0] dout_led;
wire sel_led_wr = rd_addr==`ADDR_LED;
wire sel_led_rd = wr_addr==`ADDR_LED;
led_interface u4(
.clk(clk),  
.rst(rst),  
.wr(wr&sel_led_wr), 
.rd(rd&sel_led_rd),
.din(din),
.dout(dout_led),
.led(led)
);	

wire [7:0]dout_beep;

wire sel_beep_rd = rd_addr==`ADDR_BEEP;
wire sel_beep_wr = wr_addr==`ADDR_BEEP;    

beep_interface u5(
.clk(clk),
.rst(rst),
.rd(rd&sel_beep_rd),
.wr(wr&sel_beep_wr),
.dout(dout_beep) ,
.din(din),
.beep(beep)
);		 

wire [7:0] dout_secgen ;
wire sel_secgen_rd = rd_addr==`ADDR_SECGEN;
wire sel_secgen_wr = wr_addr==`ADDR_SECGEN;	  

second_gen secgen(
.clk(clk),
.rst(rst),
.rd(rd&sel_secgen_rd),
.din(din),
.wr(wr&sel_secgen_wr),
.dout(dout_secgen) 
);

assign dout = dout_key | dout_sw |dout_seg7led | dout_led | dout_beep | dout_secgen;

endmodule				   			  

`define CLK_HZ 25000000		 

module second_gen(
	input clk,rst,
	input rd,
	input [7:0]din,
	input wr,
	output reg [7:0]dout 
	);
reg [31:0] cntr;
wire time_out =  cntr==(`CLK_HZ-1);

wire clr = wr&(din[0]==0);

always @(posedge clk)
	if (rst)cntr=0;	  
	else 
		if (time_out)
			cntr=0;	  	   
		else 	 
			cntr=cntr+1;  		
			
reg int_req;
always @ (posedge clk)				 
	if (clr)
	int_req=0; 
	else  
		int_req = int_req|time_out  ;	 

always @ (posedge clk)
	if(rd)
		dout={7'b0,int_req};
	else dout=0;
		
endmodule 	   		

module hard_clock(
	input clk,
	input rst,
	input wr,
	input rd,
	input [2:0]rd_addr,
	input [2:0]wr_addr,
	output reg [7:0] seg7_data,
	output reg [7:0] seg7_sel,
	input [7:0]din,
	output reg[7:0]dout
	);						 			 
	
	`define CTL_ADDR  3
	`define HOUR_ADDR 2
	`define MIN_ADDR  1
	`define SEC_ADDR  0	
	
	reg [7:0]hour;
	reg [7:0]min;
	reg [7:0]sec; 		
	reg [7:0]ctl;	   	
	
	always @ (posedge clk)if (rst)hour=0; else if (wr&wr_addr==`HOUR_ADDR)hour=din;			
	always @ (posedge clk)if (rst)min=0; else  if (wr&wr_addr==`MIN_ADDR)min=din;  	
	always @ (posedge clk)if (rst)sec=0; else if (wr&wr_addr==`SEC_ADDR)sec=din;
					
	always @(posedge clk)  if (rd)
		case  (rd_addr[2:0])
			`SEC_ADDR:dout = sec;
			`MIN_ADDR :dout = min;
			`HOUR_ADDR:dout = hour;
			`CTL_ADDR:dout = ctl;
		endcase	 else dout=0;					   				 
		
	/*the main counter*/
    reg [31:0] seg7_cntr;
    always @(posedge clk)seg7_cntr=seg7_cntr+1;
    wire  [2:0]  sel =seg7_cntr[17:15] ;  
	wire flash_bit = seg7_cntr[23];
    always @(posedge clk)
    case (sel[2:0])
        0:seg7_data=(ctl[0]&flash_bit)?'hff:seg(sec[3:0]);
        1:seg7_data=(ctl[1]&flash_bit)?'hff:seg(sec[7:4]);
        2:seg7_data=(ctl[2]&flash_bit)?'hff:~8'b01000000;
        3:seg7_data=(ctl[3]&flash_bit)?'hff:seg(min[3:0]);
        4:seg7_data=(ctl[4]&flash_bit)?'hff:seg(min[7:4]);
        5:seg7_data=(ctl[5]&flash_bit)?'hff:~8'b01000000;
        6:seg7_data=(ctl[6]&flash_bit)?'hff:seg(hour[3:0]);
        7:seg7_data=(ctl[7]&flash_bit)?'hff:seg(hour[7:4]);
    endcase

    always @(posedge clk) seg7_sel=~(1<<sel);	 
    function [7:0] seg;
        input [3:0] data;
        begin
            case(data)
                0: seg = ~8'b00111111;//b11111100;
                1: seg = ~8'b00000110;//01100000;
                2: seg = ~8'b01011011;//11011010;
                3: seg = ~8'b01001111;//11010010;
                4: seg = ~8'b01100110;//1100110;
                5: seg = ~8'b01101101;//10110110;
                6: seg = ~8'b01111101;//10111110;
                7: seg = ~8'b00000111;//11100000;
                8: seg = ~8'b01111111;//11111110;
                9: seg = ~8'b01101111;//11110110;
                10: seg = ~8'b01110111;//11101110;
                11: seg = ~8'b01111100;//00111110;
                12: seg = ~8'b01011000;//00011010;
                13: seg = ~8'b01011110;//01111010;
                14: seg = ~8'b01111001;//10011110;
                15: seg = ~8'b01110001;//10001110;
            endcase
        end
    endfunction				 
endmodule			  		  


`define KEY_ACTIVE_LEVEL 1
`define TIME_OUT_VALUE 25000000/2

module key_fsm(
	input clk,rst,
	input key_i,
	output reg key_o,
	input rd
	);	
					 
	reg [3:0]curr_state,next_state;
	reg [31:0] cntr ; 
	
	always @ (posedge clk)	
		if (rst)cntr =0;
		else if (curr_state==1)
			cntr=cntr+1;
		else cntr=0;
	
	always @ (posedge clk)
		if (rst)curr_state=0;
		else
			curr_state = next_state; 
			
	always @*
	   case (curr_state)
		   0:if (key_i==`KEY_ACTIVE_LEVEL&rd) 
			   //read a active key value ,then we need delay for a period
			   next_state = 1;else next_state = 0;
		   1:if(cntr==`TIME_OUT_VALUE)
			   next_state = 0;else next_state = 1;
	   endcase 
		   
always @* 
	key_o=key_i&(~curr_state);	 
	
endmodule