module EppStartAddress(rst, clk, wr, ad, dbi, dbo, myad, trigger, startAddress);
input rst;
input clk;
input wr;
input [7:0] ad;
input [7:0] dbi;
output [7:0] dbo;
reg [7:0] dbo;
output myad;
output trigger;
output [47:0] startAddress;
reg [47:0] startAddress;

reg loadedBit;
assign trigger = loadedBit;

always @(posedge clk)
if (rst) begin
	loadedBit <= 1'b0;
	startAddress <= 48'd0;
end
else begin
	if (wr) begin
		case (ad)
		8'h80:	loadedBit <= |dbi;
		8'h81:	startAddress[ 7: 0] <= dbi;
		8'h82:	startAddress[15: 8] <= dbi;
		8'h83:	startAddress[23:16] <= dbi;
		8'h84:	startAddress[31:24] <= dbi;
		8'h85:	startAddress[39:32] <= dbi;
		8'h86:	startAddress[47:40] <= dbi;
		endcase
	end
end

wire myad =
	ad==8'h80 ||
	ad==8'h81 ||
	ad==8'h82 ||
	ad==8'h83 ||
	ad==8'h84 ||
	ad==8'h85 ||
	ad==8'h86
	;
always @(ad or loadedBit or startAddress)
	case (ad)
	8'h80:	dbo <= {8{loadedBit}};
	8'h81:	dbo <= startAddress[7:0];
	8'h82:	dbo <= startAddress[15:8];
	8'h83:	dbo <= startAddress[23:16];
	8'h84:	dbo <= startAddress[31:24];
	8'h85:	dbo <= startAddress[39:32];
	8'h86:	dbo <= startAddress[47:40];
	default:	dbo <= 8'h00;
	endcase

endmodule

