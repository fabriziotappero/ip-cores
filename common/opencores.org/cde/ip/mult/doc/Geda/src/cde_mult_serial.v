 module 
  cde_mult_serial 
    #( parameter 
      WIDTH=32)
     (
 input   wire                 alu_op_mul,
 input   wire                 clk,
 input   wire                 ex_freeze,
 input   wire                 reset,
 input   wire    [ WIDTH-1 :  0]        a_in,
 input   wire    [ WIDTH-1 :  0]        b_in,
 output   reg    [ 2*WIDTH-1 :  0]        mul_prod_r,
 output   wire                 mul_stall);
   //
   // Internal wires and regs
   //
   reg [5:0] 				serial_mul_cnt;   
   reg 					mul_free;   
   wire [WIDTH-1:0] 			x;
   wire [WIDTH-1:0] 			y;
   reg ex_freeze_r;
   always @( posedge clk)
     if (reset) ex_freeze_r <= 1'b1;
     else       ex_freeze_r <= ex_freeze;
   //
   // Combinatorial logic
   //
   assign x = a_in;
   assign y = b_in; 
always@(posedge clk)
if((serial_mul_cnt == 6'b000000) && ex_freeze && ex_freeze_r)
begin
   $display("%t %m mul (%x,%x,%x);",$realtime,a_in,b_in,mul_prod_r );
end
   always @( posedge clk)
     if (reset) begin
	mul_prod_r <=  64'h0000_0000_0000_0000;
	serial_mul_cnt <= 6'd0;
	mul_free <= 1'b1;
     end
     else if (|serial_mul_cnt) begin
	serial_mul_cnt <= serial_mul_cnt - 6'd1;
	if (mul_prod_r[0])
	  mul_prod_r[(WIDTH*2)-1:WIDTH-1] <= mul_prod_r[(WIDTH*2)-1:WIDTH] + x;
	else
	  mul_prod_r[(WIDTH*2)-1:WIDTH-1] <= {1'b0,mul_prod_r[(WIDTH*2)-1: WIDTH]};
	mul_prod_r[WIDTH-2:0] <= mul_prod_r[WIDTH-1:1];
     end
     else if (alu_op_mul && mul_free) begin
	mul_prod_r <= {32'd0, y};
	mul_free <= 0;
	serial_mul_cnt <= 6'b10_0000;
     end
     else if (!ex_freeze | mul_free) begin
	mul_free <= 1'b1;	
     end
   assign mul_stall = (|serial_mul_cnt) | (alu_op_mul & !ex_freeze_r);
  endmodule
