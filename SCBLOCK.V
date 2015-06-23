//*****************************************************************//
// Syndrome Computation                                            // 
// This block consists mainly of 12 cells. Each cell computes      //
// syndrome value Si, for i=0,...,11.                              //
// At the end of received word block, all cells store the syndrome //
// values, while SC block set its flag (errdetect) if one or more  //
// syndrome values are not zero.                                   //
// Ref.: "High-speed VLSI Architecture for Parallel Reed-Solomon   //
//        Decoder", IEEE Trans. on VLSI, April 2003.               //
//*****************************************************************//
module SCblock(recword, clock1, clock2, active_sc, reset, syndvalue0,
               syndvalue1, syndvalue2, syndvalue3, syndvalue4, 
               syndvalue5, syndvalue6, syndvalue7, syndvalue8, 
               syndvalue9, syndvalue10, syndvalue11, errdetect, 
               en_sccell, evalsynd, holdsynd);

input [4:0] recword;
input clock1, clock2, active_sc, reset, evalsynd, holdsynd, en_sccell;
output [4:0] syndvalue0, syndvalue1, syndvalue2, syndvalue3, syndvalue4, 
             syndvalue5, syndvalue6, syndvalue7, syndvalue8, syndvalue9, 
             syndvalue10, syndvalue11;
output errdetect;

reg errdetect;
reg [1:0] state, nxt_state;
parameter [1:0] st0=0, st1=1, st2=2;

always@(state or active_sc or evalsynd)
begin
    case(state)
        st0:   begin
               if(active_sc)
                  nxt_state <= st1;
               else
                  nxt_state <= st0;
               end
        st1:   begin
               if(evalsynd)
                  nxt_state <= st2;
               else
                  nxt_state <= st1;
               end
        st2:   nxt_state <= st0;
        default: nxt_state <= st0;
    endcase
end

always@(posedge clock2 or negedge reset)
begin
   if(~reset)
      state <= st0;
   else
      state <=  nxt_state;
end
 
always@(state or syndvalue0 or syndvalue1 or syndvalue2 or syndvalue3 or 
        syndvalue4 or syndvalue5 or syndvalue6 or syndvalue7 or syndvalue8 or
        syndvalue9 or syndvalue10 or syndvalue11)
begin
    case(state)
        st0:   errdetect <= 0;
        st1:   errdetect <= 0;
        st2:   begin
               if (syndvalue0 || syndvalue1 || syndvalue2 || syndvalue3 ||
                   syndvalue4 || syndvalue5 || syndvalue6 || syndvalue7 ||
                   syndvalue8 || syndvalue9 || syndvalue10 || syndvalue11)
                  errdetect <= 1;
               else
                  errdetect <= 0;
               end
        default:errdetect = 0;
   endcase
end

syndcell_0 cell_0(recword, clock1, en_sccell, holdsynd, syndvalue0);
syndcell_1 cell_1(recword, clock1, en_sccell, holdsynd, syndvalue1);
syndcell_2 cell_2(recword, clock1, en_sccell, holdsynd, syndvalue2);
syndcell_3 cell_3(recword, clock1, en_sccell, holdsynd, syndvalue3);
syndcell_4 cell_4(recword, clock1, en_sccell, holdsynd, syndvalue4);
syndcell_5 cell_5(recword, clock1, en_sccell, holdsynd, syndvalue5);
syndcell_6 cell_6(recword, clock1, en_sccell, holdsynd, syndvalue6);
syndcell_7 cell_7(recword, clock1, en_sccell, holdsynd, syndvalue7);
syndcell_8 cell_8(recword, clock1, en_sccell, holdsynd, syndvalue8);
syndcell_9 cell_9(recword, clock1, en_sccell, holdsynd, syndvalue9);
syndcell_10 cell_10(recword, clock1, en_sccell, holdsynd, syndvalue10);
syndcell_11 cell_11(recword, clock1, en_sccell, holdsynd, syndvalue11);

endmodule    


//*****************************/
// Syndrome Computation Cells //
//****************************//

//**************************************************//
//syndcell_0 computes R(alpha^19) for 31 clock cycles//
//**************************************************//
module syndcell_0(recword, clock, enable, hold, synvalue0);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue0;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^19
assign outmult[0] = outreg[3] ^ outreg[4];
assign outmult[1] = outreg[0] ^ outreg[4];
assign outmult[2] = (outreg[0] ^ outreg[1]) ^ (outreg[3] ^ outreg[4]);
assign outmult[3] = (outreg[1] ^ outreg[2]) ^ outreg[4];
assign outmult[4] = outreg[2] ^ outreg[3];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue0 = outreg;

endmodule

//**************************************************//
//syndcell_1 computes R(alpha^20) for 31 clock cycles//
//**************************************************//
module syndcell_1(recword, clock, enable, hold, synvalue1);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue1;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^20
assign outmult[0] = outreg[2] ^ outreg[3];
assign outmult[1] = outreg[3] ^ outreg[4];
assign outmult[2] = (outreg[0] ^ outreg[4]) ^ (outreg[2] ^ outreg[3]);
assign outmult[3] = (outreg[0] ^ outreg[1]) ^ (outreg[3] ^ outreg[4]);
assign outmult[4] = (outreg[1] ^ outreg[2]) ^ outreg[4];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue1 = outreg;

endmodule

//**************************************************//
//syndcell_2 computes R(alpha^21) for 31 clock cycles//
//**************************************************//
module syndcell_2(recword, clock, enable, hold, synvalue2);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue2;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^21
assign outmult[0] = (outreg[1] ^ outreg[2]) ^ outreg[4];
assign outmult[1] = outreg[2] ^ outreg[3];
assign outmult[2] = (outreg[1] ^ outreg[2]) ^ outreg[3];
assign outmult[3] = (outreg[0] ^ outreg[2]) ^ (outreg[3] ^ outreg[4]);
assign outmult[4] = (outreg[0] ^ outreg[1]) ^ (outreg[3] ^ outreg[4]);

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue2 = outreg;

endmodule

//**************************************************//
//syndcell_3 computes R(alpha^22) for 31 clock cycles//
//**************************************************//
module syndcell_3(recword, clock, enable, hold, synvalue3);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue3;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^22
assign outmult[0] = (outreg[0] ^ outreg[1]) ^ (outreg[3] ^ outreg[4]);
assign outmult[1] = (outreg[1] ^ outreg[2]) ^ outreg[4];
assign outmult[2] = (outreg[0] ^ outreg[1]) ^ (outreg[2] ^ outreg[4]);
assign outmult[3] = (outreg[1] ^ outreg[2]) ^ outreg[3];
assign outmult[4] = (outreg[0] ^ outreg[2]) ^ (outreg[3] ^ outreg[4]);

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue3 = outreg;

endmodule

//***************************************************//
//syndcell_4 computes R(alpha^23) for 31 clock cycles//
//**************************************************//
module syndcell_4(recword, clock, enable, hold, synvalue4);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue4;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^23
assign outmult[0] = (outreg[0] ^ outreg[2]) ^ (outreg[3] ^ outreg[4]);
assign outmult[1] = (outreg[0] ^ outreg[1]) ^ (outreg[3] ^ outreg[4]);
assign outmult[2] = (outreg[0] ^ outreg[1]) ^ outreg[3];
assign outmult[3] = (outreg[0] ^ outreg[1]) ^ (outreg[2] ^ outreg[4]);
assign outmult[4] = (outreg[1] ^ outreg[2]) ^ outreg[3];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue4 = outreg;

endmodule

//***************************************************//
//syndcell_5 computes R(alpha^24) for 31 clock cycles//
//***************************************************//
module syndcell_5(recword, clock, enable, hold, synvalue5);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue5;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^24
assign outmult[0] = (outreg[1] ^ outreg[2]) ^ outreg[3];
assign outmult[1] = (outreg[0] ^ outreg[2]) ^ (outreg[3] ^ outreg[4]);
assign outmult[2] = (outreg[0] ^ outreg[2]) ^ outreg[4];
assign outmult[3] = (outreg[0] ^ outreg[1]) ^ outreg[3];
assign outmult[4] = (outreg[0] ^ outreg[1]) ^ (outreg[2] ^ outreg[4]);

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue5 = outreg;

endmodule

//***************************************************//
//syndcell_6 computes R(alpha^25) for 31 clock cycles//
//***************************************************//
module syndcell_6(recword, clock, enable, hold, synvalue6);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue6;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^25
assign outmult[0] = (outreg[0] ^ outreg[1]) ^ (outreg[2] ^ outreg[4]);
assign outmult[1] = (outreg[1] ^ outreg[2]) ^ outreg[3];
assign outmult[2] = outreg[1] ^ outreg[3];
assign outmult[3] = (outreg[0] ^ outreg[2]) ^ outreg[4];
assign outmult[4] = (outreg[0] ^ outreg[1]) ^ outreg[3];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue6 = outreg;

endmodule

//***************************************************//
//syndcell_7 computes R(alpha^26) for 31 clock cycles//
//***************************************************//
module syndcell_7(recword, clock, enable, hold, synvalue7);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue7;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^26
assign outmult[0] = (outreg[0] ^ outreg[1]) ^ outreg[3];
assign outmult[1] = (outreg[0] ^ outreg[1]) ^ (outreg[2] ^ outreg[4]);
assign outmult[2] = outreg[0] ^ outreg[2];
assign outmult[3] = outreg[1] ^ outreg[3];
assign outmult[4] = (outreg[0] ^ outreg[2]) ^ outreg[4];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue7 = outreg;

endmodule

//***************************************************//
//syndcell_8 computes R(alpha^27) for 31 clock cycles//
//***************************************************//
module syndcell_8(recword, clock, enable, hold, synvalue8);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue8;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^27
assign outmult[0] = (outreg[0] ^ outreg[2]) ^ outreg[4];
assign outmult[1] = (outreg[0] ^ outreg[1]) ^ outreg[3];
assign outmult[2] = outreg[1];
assign outmult[3] = outreg[0] ^ outreg[2];
assign outmult[4] = outreg[1] ^ outreg[3];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue8 = outreg;

endmodule

//***************************************************//
//syndcell_9 computes R(alpha^28) for 31 clock cycles//
//***************************************************//
module syndcell_9(recword, clock, enable, hold, synvalue9);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue9;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^28
assign outmult[0] = outreg[1] ^ outreg[3];
assign outmult[1] = (outreg[0] ^ outreg[2]) ^ outreg[4];
assign outmult[2] = outreg[0];
assign outmult[3] = outreg[1];
assign outmult[4] = outreg[0] ^ outreg[2];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue9 = outreg;

endmodule

//****************************************************//
//syndcell_10 computes R(alpha^29) for 31 clock cycles//
//****************************************************//
module syndcell_10(recword, clock, enable, hold, synvalue10);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue10;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^29
assign outmult[0] = outreg[0] ^ outreg[2];
assign outmult[1] = outreg[1] ^ outreg[3];
assign outmult[2] = outreg[4];
assign outmult[3] = outreg[0];
assign outmult[4] = outreg[1];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue10 = outreg;

endmodule

//****************************************************//
//syndcell_11 computes R(alpha^30) for 31 clock cycles//
//****************************************************//
module syndcell_11(recword, clock, enable, hold, synvalue11);

input [0:4] recword;
input clock;
input enable, hold;
output [0:4] synvalue11;

wire [0:4] outreg;
wire [0:4] outadder;
wire [0:4] outmult;

//multiply recword with constant alpha^30
assign outmult[0] = outreg[1];
assign outmult[1] = outreg[0] ^ outreg[2];
assign outmult[2] = outreg[3];
assign outmult[3] = outreg[4];
assign outmult[4] = outreg[0];

register5_wlh register5bit(outadder, outreg, enable, hold, clock);
gfadder   adder(recword, outmult, outadder);
assign synvalue11 = outreg;

endmodule
