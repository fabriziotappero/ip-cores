
module minsoc_wb_32_8_bridge(
    wb_32_sel_i,
    wb_32_dat_i, wb_32_dat_o, wb_32_adr_i,

    wb_8_dat_i, wb_8_dat_o, wb_8_adr_i
);

input [3:0] wb_32_sel_i;

input [31:0] wb_32_dat_i;
output reg [31:0] wb_32_dat_o;
input [31:0] wb_32_adr_i;

output reg [7:0] wb_8_dat_i;
input [7:0] wb_8_dat_o;
output [31:0] wb_8_adr_i;

reg [1:0] wb_8_adr;

// put output to the correct byte in 32 bits using select line
always @(wb_32_sel_i or wb_8_dat_o)
    case (wb_32_sel_i)
        4'b0001: wb_32_dat_o <= #1 {24'b0, wb_8_dat_o};
        4'b0010: wb_32_dat_o <= #1 {16'b0,  wb_8_dat_o , 8'b0};
        4'b0100: wb_32_dat_o <= #1 {8'b0, wb_8_dat_o , 16'b0};
        4'b1000: wb_32_dat_o <= #1 {wb_8_dat_o , 24'b0};
        4'b1111: wb_32_dat_o <= #1 {24'b0, wb_8_dat_o};
        default: wb_32_dat_o <= #1 0;
    endcase // case(wb_sel_i)

always @(wb_32_sel_i or wb_32_dat_i)
begin
	case (wb_32_sel_i)
		4'b0001 : wb_8_dat_i = wb_32_dat_i[7:0];
		4'b0010 : wb_8_dat_i = wb_32_dat_i[15:8];
		4'b0100 : wb_8_dat_i = wb_32_dat_i[23:16];
		4'b1000 : wb_8_dat_i = wb_32_dat_i[31:24];
		default : wb_8_dat_i = wb_32_dat_i[7:0];
	endcase // case(wb_sel_i)
	case (wb_32_sel_i)
		4'b0001 : wb_8_adr = 2'h3;
		4'b0010 : wb_8_adr = 2'h2;
		4'b0100 : wb_8_adr = 2'h1;
		4'b1000 : wb_8_adr = 2'h0;
		default : wb_8_adr = 2'h0;
	endcase // case(wb_sel_i)
end

assign wb_8_adr_i = { wb_32_adr_i[31:2] , wb_8_adr };

endmodule
