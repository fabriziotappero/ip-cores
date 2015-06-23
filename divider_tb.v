module	divider_tb();

reg	clk=0,rst=0;
always #1 clk=~clk;

initial #10 rst=1;

/// driver
reg	[31:0]dividend=0,divisor=0;
reg	start=0;
wire	ready;
reg	state_driver=0;
always@(posedge clk)
	if(rst)begin
		case(state_driver)
			0:begin
				start<=1;
				state_driver<=1;
				dividend<=$random;
				divisor<=$random;	
			end	
			1:if(ready)begin
				start<=0;
				state_driver<=0;
			end
		endcase
	end

///

/// monitor
wire	[31:0]quotient,remainder;
reg	state_m=0;

always@(posedge clk)
	if(rst)begin
		case(state_m)
			0:if(start)begin
				if(dividend[31])$write("%6d	dividend=-%d",$time,(~dividend)+1);
				else	$write("%6d	dividend=%d",$time,dividend);
				if(divisor[31])$write("	divisor=-%d\n",(~divisor)+1);
				else	$write("	divisor=%d\n",divisor);
				state_m<=1;
			end
			1:if(ready)begin
				state_m<=0;
				if(quotient[31])$write("%6d	quotient=-%d",$time,(~quotient)+1);
				else	$write("%6d	quotient=%d",$time,quotient);
				if(remainder[31])$write("	remainder=-%d\n",(~remainder)+1);
				else	$write("	remainder=%d\n",remainder);
			end
		endcase
	end
///


/// score board

// test vector record
integer	DD_FH,DR_FH,Q_FH,R_FH;
initial begin
	DD_FH=$fopen("F:/work/divider/test pattern/dividend.txt");
	DR_FH=$fopen("F:/work/divider/test pattern/divisor.txt");
	Q_FH=$fopen("F:/work/divider/test pattern/quotient.txt");
	R_FH=$fopen("F:/work/divider/test pattern/remainder.txt");
end
//
wire	sign_q,sign_r;
assign	sign_q=dividend[31]^divisor[31];
assign	sign_r=dividend[31];

reg	[62:0]PR=0;
wire	[31:0]DR;
assign	DR=divisor[31]?(~divisor)+1:divisor;

reg	[31:0]q_tb=0,r_tb=0;
integer	i;
always@* begin
	PR={31'd0,dividend[31]?(~dividend)+1:dividend};
	for(i=31;i>=0;i=i-1)begin
		if(PR[62:31]>=DR)begin
			PR[62:31]=PR[62:31]-DR;
			if(i!=0)PR=PR<<1;
			q_tb[i]=1;
		end
		else begin
			q_tb[i]=0;
			if(i!=0)PR=PR<<1;
		end
	end
	q_tb=sign_q?(~q_tb)+1:q_tb;
	r_tb=sign_r?(~PR[62:31])+1:PR[62:31];
	$fwrite(DD_FH,",0x%h",dividend);
	$fwrite(DR_FH,",0x%h",divisor);
	$fwrite(Q_FH,",0x%h",q_tb);
	$fwrite(R_FH,",0x%h",r_tb);
end
///

/// checker
always@(posedge clk)
	if(rst)begin
		if(ready)begin
			if(quotient==q_tb)$write("quotient match");
			else begin
				$write("quotient mismatch");
				if(q_tb[31])$write(" q_tb=-%d",(~q_tb)+1);
				else $write(" q_tb=%d",q_tb);
			end
			if(remainder==r_tb)$write("	remainder match\n");
			else begin
				$write("	remainder mismatch");
				if(r_tb[31])$write(" r_tb=-%d\n",(~r_tb)+1);
				else $write(" r_tb=%d\n",r_tb);
			end
		end
	end
///


///DUT
divider_dshift	divider_0(
clk,
rst,
dividend,
divisor,
start,
ready,
quotient,
remainder
);


///
endmodule