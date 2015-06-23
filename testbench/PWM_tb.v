//Author: Zhuxu
//Email: m99a1@yahoo.cn
module	PWM_tb();
reg	wb_clk=0,extclk=0;
reg	rst=1;

initial #20 rst=0;

always #10 wb_clk=~wb_clk;

always #1 extclk=~extclk;

///////test cases configuration data///////////
wire	[31:0]configdata[0:20];
//PWM test 0

assign	configdata[0]=32'h40303;
assign	configdata[1]=32'h600ed;
assign	configdata[2]=31'h17;
//continous timer test 0
assign	configdata[3]=32'h80;
assign	configdata[4]=32'h20005;
assign	configdata[5]=32'h401a1;
assign	configdata[6]=32'h1c;
//continous timer test 1
assign	configdata[7]=32'h1c;
//PWM test 1
assign	configdata[8]=32'h41d00;
assign	configdata[9]=32'h61000;
assign	configdata[10]=32'h56;
//discontinous timer test 0

assign	configdata[11]=32'h80;
assign	configdata[12]=32'h20008;
assign	configdata[13]=32'h400aa;
assign	configdata[14]=32'h15;
//discontinous timer test 1
assign	configdata[15]=32'h15;
//continous timer test 2
assign	configdata[16]=32'h80;
assign	configdata[17]=32'h20005;
assign	configdata[18]=32'h401a1;
assign	configdata[19]=32'h15;
//continous timer test 3
assign	configdata[20]=32'h15;



////////////////////////////////////////////////


/////driver///////////////////////////////////
reg	[15:0]wb_data=0;
reg	[15:0]wb_adr=0;
reg	wb_cyc=0,wb_stb=0,wb_we=0;
wire	wb_ack;
wire	[15:0]extDC;
assign	extDC=60;
reg	[4:0]nconfig=0;

task	driver;
	begin
	@(posedge wb_clk);
	wb_cyc<=1;
	wb_stb<=1;
	wb_we<=1;
	wb_adr<=configdata[nconfig][31:16];
	wb_data<=configdata[nconfig][15:0];
	nconfig<=nconfig+1;
	while(!wb_ack)begin
		@(posedge wb_clk);
	end
	wb_cyc<=0;
	wb_stb<=0;
	wb_we<=0;
	end
endtask
//////////////////////////////////////////////

//////////////monitor/////////////////////
wire	pwm;
reg	[63:0]ct_period=0;
reg	[63:0]ct_DC=0;
reg	ready=1;
reg	[3:0]state=0;
reg	[1:0]state_mp=0;
reg	[1:0]state_mt=0;
reg	[3:0]nperiod=0;
reg	pwm_1=0;
always@(posedge extclk)
	if(!rst)begin
		pwm_1<=pwm;
		case(state)
			0:if(wb_stb&&wb_we)begin
				case(wb_adr)
					0:if(wb_data[7])ready<=1;
					else if(wb_data[2])begin
						ready<=0;
						if(wb_data[1])state<=1;
						else state<=2;
					end
					default:ready<=1;
				endcase
			end
			1:begin
				case(state_mp)
					
					0:begin
						if(pwm&&(!pwm_1))begin
							if(nperiod==15)begin
								nperiod<=0;
								state_mp<=1;
							end
							else nperiod<=nperiod+1;
						end
					end
					1:begin
						if(pwm&&pwm_1)begin
							ct_DC<=ct_DC+2;
							ct_period<=ct_period+2;
						end
						else if((!pwm)&&pwm_1)begin
							$display("ct_DC=%d",ct_DC);
							ct_DC<=0;
							ct_period<=ct_period+2;
						end
						else if(pwm&&(!pwm_1))begin
							ct_period<=0;
							$display("ct_period=%d",ct_period);
							state_mp<=0;
							state<=0;
							ready<=1;
						end
						else ct_period<=ct_period+2;
					end
				endcase
			end
			2:begin
				if(!pwm)ct_period<=ct_period+2;
				else if(pwm&&(!pwm_1))begin
					ct_period<=0;
					$display("ct_period=%d",ct_period);
					state<=0;
					ready<=1;
				end
			end
		endcase
	end
////////////////////////////////////////////

////////////////scoreboard/////////////////////
reg	[15:0]ctrl_sb=0;
reg	[15:0]divisor_sb=0;
reg	[15:0]period_sb=0;
reg	[15:0]DC_sb=0;
wire	[15:0]DC;
assign	DC=wb_data[6]?extDC:DC_sb;
wire	[15:0]divisor_sb_1;
assign	divisor_sb_1=(divisor_sb==0)?1:divisor_sb;
always@(posedge wb_clk)
	if(!rst)begin
		if(wb_stb&&wb_we)begin
			case(wb_adr)
				0:begin
				ctrl_sb<=wb_data;
				if(wb_data[2])begin
					if(wb_data[1])begin
						if(wb_data[0])begin
							$display("PWM starts	scoreboard:	period=2*divisor_sb*period_sb=2*%d*%d=%d",divisor_sb_1,period_sb,2*divisor_sb_1*period_sb);
							$display("PWM starts	scoreboard:	DC=2*divisor_sb*DC_sb=2*%d*%d=%d",divisor_sb_1,DC,2*divisor_sb_1*DC);
						end
						else begin
							$display("PWM starts	scoreboard:	period=20*divisor_sb*period_sb=20*%d*%d=%d",divisor_sb_1,period_sb,20*divisor_sb_1*period_sb);
							$display("PWM starts	scoreboard:	DC=20*divisor_sb*DC_sb=20*%d*%d=%d",divisor_sb_1,DC,20*divisor_sb_1*DC);
						end
					end
					else begin
						if(wb_data[3])$write("timer starts	continuous run");
						else $write("timer starts	single run");
						if(wb_data[0])begin
							$write("	scoreboard:	period=2*divisor_sb*period_sb=2*%d*%d=%d\n",divisor_sb_1,period_sb,2*divisor_sb_1*period_sb);
						end
						else begin
							$write("	scoreboard:	period=20*divisor_sb*period_sb=20*%d*%d=%d\n",divisor_sb_1,period_sb,20*divisor_sb_1*period_sb);
						end
						
					end	
				end
				end
				2:divisor_sb<=wb_data;
				4:period_sb<=wb_data;
				6:DC_sb<=wb_data;
			endcase
		end
	end
/////////////////////////////////////////////////


//test process///////////////
initial begin
	while(1)begin
		#1;
		if(ready&&(!rst))driver;
	end
end
/////////////////////////////

wire	[15:0]wb_o_data;

PWM	PWM_0(
wb_clk,
rst,
wb_cyc,
wb_stb,
wb_we,
wb_adr,
wb_data,
wb_o_data,
wb_ack,
extclk,
extDC,
1'b1,
pwm
);






endmodule