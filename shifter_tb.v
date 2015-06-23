module	shifter_tb();
reg	clk=0,rst=0;
always #1 clk=~clk;
initial #100 rst=1;

// driver
reg	signed[31:0]data=0,data_1=0;
reg	state=0;
reg	[4:0]ct=0;
always@(posedge clk)begin
	if(rst)begin
		case(state)
			0:begin
				data<=$random;
				state<=1;
			end
			1:begin
				if(ct==31)begin
					state<=0;

					ct<=0;
				end
				else begin
					ct<=ct+1;
					data<=data>>>1;
				end
			end
		endcase
	end
end

// score board
reg	signd=0;
reg	[31:0]data_tb=0;
reg	[4:0]shifted_tb=0;
always@* begin
	if(data[31]==0)begin
		data_1=~data;
		signd=1;
	end
	else begin
		signd=0;
		data_1=data;
	end
	casex(data_1)
		32'b10??????????????????????????????:begin
			data_tb=data_1[31:0];
			shifted_tb=0;
		end
		32'b110?????????????????????????????:begin
			data_tb={data_1[30:0],{1{signd}}};
			shifted_tb=1;
		end
		32'b1110????????????????????????????:begin
			data_tb={data_1[29:0],{2{signd}}};
			shifted_tb=2;
		end
		32'b11110???????????????????????????:begin
			data_tb={data_1[28:0],{3{signd}}};
			shifted_tb=3;
		end
		32'b111110??????????????????????????:begin
			data_tb={data_1[27:0],{4{signd}}};
			shifted_tb=4;
		end
		32'b1111110?????????????????????????:begin
			data_tb={data_1[26:0],{5{signd}}};
			shifted_tb=5;
		end
		32'b11111110????????????????????????:begin
			data_tb={data_1[25:0],{6{signd}}};
			shifted_tb=6;
		end
		32'b111111110???????????????????????:begin
			data_tb={data_1[24:0],{7{signd}}};
			shifted_tb=7;
		end
		32'b1111111110??????????????????????:begin
			data_tb={data_1[23:0],{8{signd}}};
			shifted_tb=8;
		end
		32'b11111111110?????????????????????:begin
			data_tb={data_1[22:0],{9{signd}}};
			shifted_tb=9;
		end
		32'b111111111110????????????????????:begin
			data_tb={data_1[21:0],{10{signd}}};
			shifted_tb=10;
		end
		32'b1111111111110???????????????????:begin
			data_tb={data_1[20:0],{11{signd}}};
			shifted_tb=11;
		end
		32'b11111111111110??????????????????:begin
			data_tb={data_1[19:0],{12{signd}}};
			shifted_tb=12;
		end
		32'b111111111111110?????????????????:begin
			data_tb={data_1[18:0],{13{signd}}};
			shifted_tb=13;
		end
		32'b1111111111111110????????????????:begin
			data_tb={data_1[17:0],{14{signd}}};
			shifted_tb=14;
		end
		32'b11111111111111110???????????????:begin
			data_tb={data_1[16:0],{15{signd}}};
			shifted_tb=15;
		end
		32'b111111111111111110??????????????:begin
			data_tb={data_1[15:0],{16{signd}}};
			shifted_tb=16;
		end
		32'b1111111111111111110?????????????:begin
			data_tb={data_1[14:0],{17{signd}}};
			shifted_tb=17;
		end
		32'b11111111111111111110????????????:begin
			data_tb={data_1[13:0],{18{signd}}};
			shifted_tb=18;
		end
		32'b111111111111111111110???????????:begin
			data_tb={data_1[12:0],{19{signd}}};
			shifted_tb=19;
		end
		32'b1111111111111111111110??????????:begin
			data_tb={data_1[11:0],{20{signd}}};
			shifted_tb=20;
		end
		32'b11111111111111111111110?????????:begin
			data_tb={data_1[10:0],{21{signd}}};
			shifted_tb=21;
		end
		32'b111111111111111111111110????????:begin
			data_tb={data_1[9:0],{22{signd}}};
			shifted_tb=22;
		end
		32'b1111111111111111111111110???????:begin
			data_tb={data_1[8:0],{23{signd}}};
			shifted_tb=23;
		end
		32'b11111111111111111111111110??????:begin
			data_tb={data_1[7:0],{24{signd}}};
			shifted_tb=24;
		end
		32'b111111111111111111111111110?????:begin
			data_tb={data_1[6:0],{25{signd}}};
			shifted_tb=25;
		end
		32'b1111111111111111111111111110????:begin
			data_tb={data_1[5:0],{26{signd}}};
			shifted_tb=26;
		end
		32'b11111111111111111111111111110???:begin
			data_tb={data_1[4:0],{27{signd}}};
			shifted_tb=27;
		end
		32'b111111111111111111111111111110??:begin
			data_tb={data_1[3:0],{28{signd}}};
			shifted_tb=28;
		end
		32'b1111111111111111111111111111110?:begin
			data_tb={data_1[2:0],{29{signd}}};
			shifted_tb=29;
		end
		32'b11111111111111111111111111111110:begin
			data_tb={data_1[1:0],{30{signd}}};
			shifted_tb=30;
		end
		32'b11111111111111111111111111111111:begin
			data_tb={data_1[31],{31{signd}}};
			shifted_tb=31;
		end
	endcase
	if(signd)data_tb=~data_tb;
end

// checker
wire	[31:0]data_o;
wire	[4:0]shifted_o;
always@(negedge clk)
	if(rst)begin
		if(data_o==data_tb)$display("%6d	correct	data_o=%h",$time,data_o);
		else $display("%6d	error	data_o=%h	data_tb=%h",$time,data_o,data_tb);
		if(shifted_o==shifted_tb)$display("%6d	correct	shifted_o=%d",$time,shifted_o);
		else $display("%6d	error	shifted_o=%d	shifted_tb=%d",$time,shifted_o,shifted_tb);
	end


shifter	shifter_0(
data,
data_o,
shifted_o
);
endmodule