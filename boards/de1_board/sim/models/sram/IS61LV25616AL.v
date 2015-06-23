// IS61LV25616 Asynchronous SRAM, 256K x 16 = 4M; speed: 10ns.
// Note; 1) Please include "+define+ OEb" in running script if you want to check
//          timing in the case of OE_ being set.
//       2) Please specify access time by defining tAC_10 or tAC_12.

// `define OEb
`define tAC_10
`timescale 1ns/10ps

module IS61LV25616 (A, IO, CE_, OE_, WE_, LB_, UB_);

parameter dqbits = 16;
parameter memdepth = 262143;
parameter addbits = 18;
parameter Toha  = 2;

parameter Tsa   = 2;

`ifdef tAC_10
  parameter Taa   = 10,
            Thzce = 3,
	    Thzwe = 5;
`endif

`ifdef tAC_12
  parameter Taa   = 12,
	    Thzce = 5,
	    Thzwe = 6;
`endif

input CE_, OE_, WE_, LB_, UB_;
input [(addbits - 1) : 0] A;
inout [(dqbits - 1) : 0] IO;
 
wire [(dqbits - 1) : 0] dout;
reg  [(dqbits/2 - 1) : 0] bank0 [0 : memdepth];
reg  [(dqbits/2 - 1) : 0] bank1 [0 : memdepth];
// wire [(dqbits - 1) : 0] memprobe = {bank1[A], bank0[A]};

wire r_en = WE_ & (~CE_) & (~OE_);
wire w_en = (~WE_) & (~CE_) & ((~LB_) | (~UB_));
assign #(r_en ? Taa : Thzce) IO = r_en ? dout : 16'bz;   

initial
  $timeformat (-9, 0.1, " ns", 10);

assign dout [(dqbits/2 - 1) : 0]        = LB_ ? 8'bz : bank0[A];
assign dout [(dqbits - 1) : (dqbits/2)] = UB_ ? 8'bz : bank1[A];

always @(A or w_en)
  begin
    #Tsa
    if (w_en)
      #Thzwe
      begin
	bank0[A] = LB_ ? bank0[A] : IO [(dqbits/2 - 1) : 0];
	bank1[A] = UB_ ? bank1[A] : IO [(dqbits - 1)   : (dqbits/2)];
      end
  end
 
// Timing Check
`ifdef tAC_10
  specify
    specparam
      tSA   = 0,
      tAW   = 8,
      tSCE  = 8,
      tSD   = 6,
      tPWE2 = 10,
      tPWE1 = 8,
      tPBW  = 8;
`else

`ifdef tAC_10
  specify
    specparam
      tSA   = 0,
      tAW   = 8,
      tSCE  = 8,
      tSD   = 6,
      tPWE2 = 12,
      tPWE1 = 8,
      tPBW  = 8;
`endif
`endif

    $setup (A, negedge CE_, tSA);
//     $setup (A, posedge CE_, tAW);
//     $setup (IO, posedge CE_, tSD);
    $setup (A, negedge WE_, tSA);
//     $setup (IO, posedge WE_, tSD);
    $setup (A, negedge LB_, tSA);
    $setup (A, negedge UB_, tSA);

    $width (negedge CE_, tSCE);
    $width (negedge LB_, tPBW);
    $width (negedge UB_, tPBW);
    `ifdef OEb
    $width (negedge WE_, tPWE1);
    `else
    $width (negedge WE_, tPWE2);
    `endif 

  endspecify

endmodule

