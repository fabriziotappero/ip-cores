/*PID controller testbench
Author: Zhu Xu
Email: m99a1@yahoo.cn
*/


module	PID_tb;
reg	clk=0;
reg	rst=1;

always #1 clk=~clk;

initial begin
	#10 rst=0;
end

//scoreboard
reg	[15:0]kp=0;
reg	[15:0]ki=0;
reg	[15:0]kd=0;
reg	[15:0]sp=0;
reg	[15:0]pv=0;
reg	[15:0]kpd;
reg	[15:0]err[0:1];
reg	[31:0]sigma=0;
reg	[31:0]un=0;
reg	[31:0]a=0;
reg	[31:0]p=0;
reg	[4:0]of=0;
reg	[31:0]s=0;
initial begin
	err[0]=0;
	err[1]=0;
end

wire	[31:0]value_sb[0:10];
assign	value_sb[0]={{16{kp[15]}},kp};
assign	value_sb[1]={{16{ki[15]}},ki};
assign	value_sb[2]={{16{kd[15]}},kd};
assign	value_sb[3]={{16{sp[15]}},sp};
assign	value_sb[4]={{16{pv[15]}},pv};
assign	value_sb[5]={{16{kpd[15]}},kpd};
assign	value_sb[6]={{16{err[0][15]}},err[0]};
assign	value_sb[7]={{16{err[1][15]}},err[1]};
assign	value_sb[8]=un;
assign	value_sb[9]=sigma;
assign	value_sb[10]={27'b0,of};

function of_check_16bit;
	input 	[15:0]a,b;
	begin
		s=a+b;
		of_check_16bit=(a[15]&b[15]&(~s[15]))|((~a[15])&(~b[15])&s[15]);
	end
endfunction

function of_check_32bit;
	input	[31:0]a,b;
	begin
		s=a+b;
		of_check_32bit=(a[31]&b[31]&(~s[31]))|((~a[31])&(~b[31])&s[31]);	
	end	
endfunction	

task	update_sb;
	input	[15:0]adr;
	input	[15:0]data;
	begin
		case(adr[15:2])
			0:begin
				kp=data;
				kpd=kp+kd;
				of[0]=of_check_16bit(kp,kd);
			end
			1:begin
				ki=data;
			end
			2:begin
				kd=data;
				kpd=kp+kd;
				of[0]=of_check_16bit(kp,kd);
			end
			3:begin
				sp=data;
			end
			4:begin
				pv=data;
				err[1]=(~err[0])+1;
				of[2]=of[1];
				err[0]=sp+(~pv)+1;
				of[1]=of_check_16bit(sp,((~pv)+1));
				p={{16{err[0][15]}},err[0]}*{{16{ki[15]}},ki};
				of[4]=of[4]|of_check_32bit(sigma,p);
				sigma=sigma+p;
				p={{16{err[0][15]}},err[0]}*{{16{kpd[15]}},kpd};
				of[3]=of[4]|of_check_32bit(sigma,p);
				a=sigma+p;
				p={{16{err[1][15]}},err[1]}*{{16{kd[15]}},kd};
				of[3]=of[3]|of_check_32bit(a,p);
				un=a+p;
			end						
		endcase
	end
endtask

//wishbone master
wire	[3:0]TAG_s2m;
wire	[3:0]TAG_m2s;
wire	ACK_s2m;
wire	[31:0]ADR_m2s;
wire	CYC_m2s;
wire	[31:0]DAT_s2m;
wire	[31:0]DAT_m2s;
wire	ERR_s2m,RTY_s2m,STB_m2s,WE_m2s;
wire	[3:0]SEL_m2s;

wb_master	wb_master_0(
clk,
rst,
TAG_s2m,
TAG_m2s,
ACK_s2m,
ADR_m2s,
CYC_m2s,
DAT_s2m,
DAT_m2s,
ERR_s2m,
RTY_s2m,
SEL_m2s,
STB_m2s,
WE_m2s
);


reg	[31:0]rdata;
task	check_sb;
	input	[31:0]adr;
	begin
		wb_master_0.rd(adr,rdata);
		if(adr<=10*4)begin
			if(rdata==value_sb[adr[15:2]])begin
				$display("%8dns	read correct value from address=%8h	data=%8h",$time,adr,rdata);
			end
			else begin
				$display("%8dns	read incorrect value from address=%8h	rdata=%8h	scoreboard=%8h",$time,adr,rdata,value_sb[adr[15:2]]);
			end
		end
		else begin
			if(rdata==0)begin
				$display("%8dns	read correct value from address=%8h	data=%8h",$time,adr,rdata);
			end
			else begin
				$display("%8dns	read incorrect value from address=%8h	rdata=%8h	scoreboard=0",$time,adr,rdata);
			end
		end
	
	end
endtask



//instantiation of PID
wire	[31:0]o_un;
wire	valid;

PID	PID_0(
clk,
rst,
CYC_m2s,
STB_m2s,
WE_m2s,
ADR_m2s[15:0],
DAT_m2s,
ACK_s2m,
DAT_s2m,
o_un,
valid
);


//test procedure
reg	signed[31:0]rdata_1=0;
initial begin
	while(rst)begin
		@(posedge clk);
	end
	wb_master_0.wr(0*4,32'h80,4'b1111);
	update_sb(0*4,16'h80);
	wb_master_0.wr(1*4,32'h5,4'b1111);
	update_sb(1*4,16'h5);
	wb_master_0.wr(2*4,32'h5,4'b1111);
	update_sb(2*4,16'h5);
	wb_master_0.wr(3*4,32'hf87,4'b1111);
	update_sb(3*4,16'hf87);
	wb_master_0.wr(4*4,32'h0,4'b1111);
	update_sb(4*4,0);
	repeat(1000)begin
		wb_master_0.rd(8*4,rdata_1);
		check_sb(8*4);
		rdata_1=rdata_1>>>8;
		wb_master_0.wr(4*4,rdata_1,4'b1111);
		update_sb(4*4,rdata_1[15:0]);
		
	end
	#10 $finish;
end






endmodule