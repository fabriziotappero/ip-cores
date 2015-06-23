/*Author: Zhuxu 
	m99a1@yahoo.cn
Pulse Width Generators/timers with 16-bit main counter.
Period or timers target number is controlled by register [15:0]period.
Duty cycle is controlled by register [15:0]DC.
Clock used for PWM signal generation can be switched between Wishbone Bus clock and external clock. It is down clocked first.
o_pwm outputs PWM signal or timers interrupt.

control register [7:0]ctrl:
bit 0:	When set, external clock is chosen for PWM/timer. When cleared, wb clock is used for PWM/timer.
bit 1:	When set,  PWM is enabled. When cleared,  timer is enabled.
bit 2:	When set,  PWM/timer starts. When cleared, PWM/timer stops.
bit 3:	When set, timer runs continuously. When cleared, timer runs one time.
bit 4:	When set, o_pwm enabled.
bit 5:	timer interrupt bit	When it is written with 0, interrupt request is cleared. 
bit 6:	When set, a 16-bit external signal i_DC is used as duty cycle. When cleared, register DC is used.
bit 7:	When set, counter reset for PWM/timer, it's output and bit 5 will also be cleared. When changing from PWM mode to timer mode reset is needed before timer starts.
*/
module	PWM(
//wishbone slave interface
input	i_wb_clk,
input	i_wb_rst,
input	i_wb_cyc,
input	i_wb_stb,
input	i_wb_we,
input	[15:0]i_wb_adr,
input	[15:0]i_wb_data,
output	[15:0]o_wb_data,
output	o_wb_ack,

input	i_extclk,
input	[15:0]i_DC,
input	i_valid_DC,
output	o_pwm

);

////////////////////control logic////////////////////////////
parameter	adr_ctrl=0,
		adr_divisor=2,
		adr_period=4,
		adr_DC=6;
reg	[7:0]ctrl;
reg	[15:0]period;
reg	[15:0]DC;
reg	[15:0]divisor;	//for down clocking. If(divisor==0)To=Ti;	else To=Ti/divisor;
integer	i;
wire	write;
assign	write=i_wb_cyc&i_wb_stb&i_wb_we;
assign	o_wb_ack=i_wb_stb;
always@(posedge i_wb_clk or posedge i_wb_rst)
	if(i_wb_rst)begin
		ctrl[4:0]<=0;
		ctrl[7:6]<=0;
		DC<=0;
		period<=0;
		divisor<=0;	
	end
	else if(write)begin
		case(i_wb_adr)
			adr_ctrl:begin
				ctrl[4:0]<=i_wb_data[4:0];
				ctrl[7:6]<=i_wb_data[7:6];
			end
			adr_divisor:divisor<=i_wb_data;
			adr_period:period<=i_wb_data;
			adr_DC:DC<=i_wb_data;
		endcase
	end

//interrupt bit control
wire	pwm;
assign	pwm=ctrl[1];
reg	[1:0]state;
reg	clrint;		//signal to pwm/timer  logic
wire	ack_clrint;	//signal from pwm/timer  logic
wire	int;		//signal from pwm/timer  logic
always@(posedge i_wb_clk or posedge i_wb_rst)
	if(i_wb_rst)begin
		ctrl[5]<=0;
		state<=0;
		clrint<=0;
	end
	else begin
		case(state)			
			1:begin
				if(write)begin
					if(i_wb_data[7])begin
						ctrl[5]<=0;
						state<=0;
					end
					else if(!i_wb_data[5])begin
						ctrl[5]<=0;
						if(!pwm)begin
							clrint<=1;
							state<=2;
						end
						else state<=0;
					end
				end
			end
			2:if(ack_clrint)begin
				clrint<=0;
				state<=0;	
			end
			default:begin
				if(!pwm)ctrl[5]<=int;
				if(int)state<=1;
			end
		endcase
	end


///////////////////////////////////////////////////////////

//////down clocking for pwm/timer///////////////////
wire	clk_source;
wire	eclk,oclk;
assign	clk_source=ctrl[0]?i_extclk:i_wb_clk;
down_clocking_even	down_clocking_even_0(
clk_source,
(!i_wb_rst),
{1'b0,divisor[15:1]},
eclk
);
down_clocking_odd	down_clocking_odd_0(
clk_source,
(!i_wb_rst),
{1'b0,divisor[15:1]},
oclk
);
wire	clk;
assign	clk=divisor[0]?oclk:eclk;
///////////////////////////////////////////////////////

/////////////////main counter //////////////////////////
reg	[15:0]ct;
reg	pts;	//PWM signal or timer interrupt signal
reg	[15:0]extDC;
wire	[15:0]DC_1;
assign	DC_1=ctrl[6]?extDC:DC;	//external or internal duty cycle toggle
wire	[15:0]period_1;
assign	period_1=(period==0)?0:(period-1);
reg	switch_ack_clrint;
wire	state_timer;
assign	state_timer=ctrl[3];
wire	rst_ct;
assign	rst_ct=i_wb_rst|ctrl[7];
assign	int=pwm?0:pts;
assign	ack_clrint=switch_ack_clrint?clrint:0;
always@(posedge clk or posedge rst_ct)
	if(rst_ct)begin
		pts<=0;
		ct<=0;
		switch_ack_clrint<=0;
		extDC<=0;
	end
	else begin
	if(i_valid_DC)extDC<=i_DC;
	if(switch_ack_clrint&&(!clrint))switch_ack_clrint<=0;
	if(ctrl[2])begin
		case(pwm)
			1:begin
				if(ct>=period_1)ct<=0;
				else ct<=ct+1;

				if(ct<DC_1)pts<=1;
				else pts<=0;
			end
			0:begin

				case(state_timer)
					0:begin
						if(clrint)switch_ack_clrint<=1;
						if(ct>=period_1)begin
							if(clrint)begin
								pts<=0;
								ct<=0;	
							end
							else pts<=1;
							
						end
						else ct<=ct+1;
					end
					1:begin
						if(ct>=period_1)begin
							pts<=1;
							ct<=0;
						end
						else begin
							if(clrint)begin
								switch_ack_clrint<=1;
								pts<=0;
							end
							ct<=ct+1;
						end
					end
				endcase
			end
		endcase
	end
	else if(clrint)begin
		switch_ack_clrint<=1;
		if(!pwm)begin
			pts<=0;
			ct<=0;
		end
	end
	end
//////////////////////////////////////////////////////////

assign	o_pwm=ctrl[4]?pts:0;
assign	o_wb_data=	i_wb_adr==adr_ctrl?{8'h0,ctrl}:
			i_wb_adr==adr_divisor?divisor:
			i_wb_adr==adr_period?period:
			i_wb_adr==adr_DC?DC:0;


endmodule