//---------------------------------------------------------------------------
// Keyboard test bench
//---------------------------------------------------------------------------
//
// Displays the ascii code for the key struck on the seven segment display.
/*
reg kbd_cyc;
reg kbd_stb;
reg kbd_we;
reg [31:0] kbd_adr;
reg [3:0] kstate;
always @(posedge clk25)
if (rst)
	kstate <= 4'd0;
else
case(kstate)
4'd0:
	if (kbd_irq) begin
		kstate <= 4'd1;
	end
4'd1:
	if (!kbd_cyc) begin
		kbd_cyc <= 1'b1;
		kbd_stb <= 1'b1;
		kbd_we <= 1'b0;
		kbd_adr <= 32'hFFDC_0000;
	end
	else if (kbd_ack) begin
		kbd_cyc <= 1'b0;
		kbd_stb <= 1'b0;
		valreg <= kbd_dbo + 6;
		kstate <= 4'd2;
	end
4'd2:
	if (!kbd_cyc) begin
		kbd_cyc <= 1'b1;
		kbd_stb <= 1'b1;
		kbd_adr <= 32'hFFDC_0001;
	end
	else if (kbd_ack) begin
		kbd_cyc <= 1'b0;
		kbd_stb <= 1'b0;
		kstate <= 4'd0;
	end
default:
	kstate <= 4'd0;
endcase
*/

