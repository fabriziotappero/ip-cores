
/*
Include this file after module
*/
integer ErrorCnt=0;
integer ErrorCode=0;	
	initial begin
		ErrorCnt=0;
		ErrorCode=0;
	end
`define Info(Message) $display("I@(%d):%s",$time,Message);
`define CheckE(Signal,Value,SignalName) if(Signal!==Value) begin \
				$display("E@(%d): expect %x, actual %x (%s,%s,%d)",$time,Value,Signal,SignalName,`__FILE__,`__LINE__); \
				ErrorCnt=ErrorCnt+1;\
				end
`define CheckF(Signal,Value,SignalName) if(Signal!==Value) begin \
				$display("F@(%d): expect %x, actual %x (%s,%s,%d)",$time,Value,Signal,SignalName,`__FILE__,`__LINE__); \
				$stop(1);\
				end
`define CheckW(Signal,Value,SignalName) if(Signal!==Value) begin \
				$display("W@(%d): expect %x, actual %x (%s,%s,%d)",$time,Value,Signal,SignalName,`__FILE__,`__LINE__); \
				end

`define WaitTil(Signal,Value,Clk,Message)	while(Signal!==Value) begin @(posedge Clk);#0.001;end \
				$display(Message);
`define WaitTilRise(Signal)	@(posedge Signal);#0.001;
`define WaitTilRall(Signal)	@(negedge Signal);#0.001;

