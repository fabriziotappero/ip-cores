module	Reset_Delay(iCLK,oRESET);
input		iCLK;
output reg	oRESET;
reg	[15:0]	Cont;

always@(posedge iCLK)
begin
	if(Cont!=16'hFFFF)
	begin
		Cont	<=	Cont+1;
		oRESET	<=	1'b0;
	end
	else
	oRESET	<=	1'b1;
end

endmodule