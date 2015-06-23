/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
module synthetic_op ( clk , sel, opa32, opb32 , res64 );

input clk;
input [2:0] sel;
input [31:0] opa32,opb32;

output        [63:0]  res64;

wire signed [31:0] sopa32,sopb32;
wire        [31:0] uopa32,uopb32;
wire        [31:0] aopa32,aopb32;
wire        [63:0] out_abs;
reg         [47:0] unsign_st1a, unsign_st1b;

// cast
assign sopa32 = (sel[1:0] == 2'b10) ? opa32 :
                (sel[1:0] == 2'b01) ? {{16{opa32[15]}},opa32[15:0]}:
		                 {{24{opa32[7]}},opa32[ 7:0]};

assign sopb32 = (sel[1:0] == 2'b10) ? opb32 :
                (sel[1:0] == 2'b01) ? {{16{opb32[15]}},opb32[15:0]}:
		                 {{24{opb32[7]}},opb32[ 7:0]};

assign uopa32 = (sel[1:0] == 2'b10) ? opa32 :
                (sel[1:0] == 2'b01) ? {16'b0,opa32[15:0]}:
		                 {24'b0,opa32[ 7:0]};

assign uopb32 = (sel[1:0] == 2'b10) ? opb32 :
                (sel[1:0] == 2'b01) ? {16'b0,opb32[15:0]}:
		                 {24'b0,opb32[ 7:0]};
				 
// absolute value if needed
assign aopa32 = ({sel[2],sopa32[31]} == 2'b11 ) ? ( ~sopa32 + 1 ) : uopa32;
assign aopb32 = ({sel[2],sopb32[31]} == 2'b11 ) ? ( ~sopb32 + 1 ) : uopb32;



// stage 1
always @(posedge clk)
begin
unsign_st1a <= aopa32 * aopb32[15:0];
unsign_st1b <= aopa32 * aopb32[31:16];
end

// output
assign out_abs  = unsign_st1a + {unsign_st1b,16'b0};

assign res64 = (( {sel[2],sopa32[31],sopb32[31]} == 3'b110 ) || ( {sel[2],sopa32[31],sopb32[31]} == 3'b101 )) ? ~out_abs + 1 : out_abs;

endmodule
