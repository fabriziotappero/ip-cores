//***************************************************************//
// Chien Search and Error Evaluator (CSEE) block find            //
// error location (Xi) while determine its error magnitude (Yi). //
// This CSEE block implement Chien search algorithm to find      //
// location of an error and Fourney Formula to compute the error //
// error value. Error value will be outputted serially and has   //
// to be synchronous with output of FIFO Register.               //
//***************************************************************//

module CSEEblock(lambda0, lambda1, lambda2, lambda3, lambda4,
                  lambda5, lambda6, homega0, homega1, homega2,
                  homega3, homega4, homega5, errorvalue, clock1,
                  clock2, active_csee, reset, lastdataout, evalerror,
                  en_outfifo, rootcntr);

input [4:0] lambda0, lambda1, lambda2, lambda3, lambda4,
            lambda5, lambda6;
input [4:0] homega0, homega1, homega2, homega3, homega4, homega5;
input clock1, clock2, active_csee, reset;
input lastdataout, evalerror, en_outfifo;
output [4:0] errorvalue;
output [2:0] rootcntr;

wire [4:0] cs0_out, cs1_out, cs2_out, cs3_out, cs4_out, cs5_out,
           cs6_out;
wire [4:0] fn0_out, fn1_out, fn2_out, fn3_out, fn4_out, fn5_out;
wire [4:0] oddlambda, evenlambda, lambdaval;
wire [4:0] omegaval, fourney_out, inv_oddlambda;
wire zerodetect;
wire [4:0] andtree_out;
reg load;
reg enrootcnt;
reg [2:0] rootcntr;

parameter st0=0, st1=1;
reg state, nxt_state;

//*****//
// FSM //
//*****//
always@(posedge clock2 or negedge reset)
begin
    if(~reset)
       state = st0;
    else
       state = nxt_state;
end
 
always@(state or active_csee or lastdataout)
begin
    case(state)
    st0   : begin
            if(active_csee)
               nxt_state = st1;
            else
               nxt_state = st0;
            end
    st1   : begin
             if(lastdataout)
                nxt_state = st0;
             else
                nxt_state = st1;
            end
    default: nxt_state = st0;
    endcase
end

always@(state)
begin
    case(state)
    st0   : begin
            load = 0;
            enrootcnt = 0;
            end
    st1   : begin
            load = 1;
            enrootcnt = 1;
            end
    default: begin
             load = 0;
             enrootcnt = 0;
             end
    endcase
end

//********************************//
// Counter for roots of lambda(x) //
// with synchronous hold          // 
//********************************//
always@(posedge clock2)
begin
    if(enrootcnt)
       begin
       if(zerodetect)
          rootcntr <= rootcntr + 1;
       else
          rootcntr <= rootcntr;
       end
    else
       rootcntr <= 3'b0;
end

               
//*******************//
// Chien Seach block //
//*******************//
degree0_cell cs0_cell(lambda0, cs0_out, clock1, load, evalerror);                  
degree1_cell cs1_cell(lambda1, cs1_out, clock1, load, evalerror);
degree2_cell cs2_cell(lambda2, cs2_out, clock1, load, evalerror);
degree3_cell cs3_cell(lambda3, cs3_out, clock1, load, evalerror);
degree4_cell cs4_cell(lambda4, cs4_out, clock1, load, evalerror);
degree5_cell cs5_cell(lambda5, cs5_out, clock1, load, evalerror);
degree6_cell cs6_cell(lambda6, cs6_out, clock1, load, evalerror);

assign oddlambda = cs1_out ^ cs3_out ^ cs5_out;
assign evenlambda = (cs0_out ^ cs2_out) ^ (cs4_out ^ cs6_out);
assign lambdaval = oddlambda ^ evenlambda;

//*****************************************//
// Error Evaluator (Fourney Formula) block //
//*****************************************//
degree0_cell fn0_cell(homega0, fn0_out, clock1, load, evalerror);                  
degree1_cell fn1_cell(homega1, fn1_out, clock1, load, evalerror);
degree2_cell fn2_cell(homega2, fn2_out, clock1, load, evalerror);
degree3_cell fn3_cell(homega3, fn3_out, clock1, load, evalerror);
degree4_cell fn4_cell(homega4, fn4_out, clock1, load, evalerror);
degree5_cell fn5_cell(homega5, fn5_out, clock1, load, evalerror);

assign omegaval = (fn0_out ^ fn1_out) ^ (fn2_out ^ fn3_out) ^ 
                  (fn4_out ^ fn5_out);

inverscomb invers(oddlambda, inv_oddlambda);
lcpmult multiplier(inv_oddlambda, omegaval, fourney_out);

//*****************************//
// Zero detect and error value //
//*****************************//
assign zerodetect = ~((lambdaval[0]|lambdaval[1]) | 
                     (lambdaval[2]|lambdaval[3]) | lambdaval[4]);
assign andtree_out[0] = fourney_out[0] & zerodetect;
assign andtree_out[1] = fourney_out[1] & zerodetect;
assign andtree_out[2] = fourney_out[2] & zerodetect;
assign andtree_out[3] = fourney_out[3] & zerodetect;
assign andtree_out[4] = fourney_out[4] & zerodetect;

//assign errorvalue = andtree_out;
register5_wl erroreg(andtree_out, errorvalue, clock2, en_outfifo);

endmodule


//******************************************************//
// Modul-modul chien search cell dibentuk dgn perkalian //

//***********************************************//
// Module for terms whose degree is zero         //
//***********************************************//
module degree0_cell(in, out, clock, load, compute);

input [4:0] in;
output [4:0] out;
input clock, compute, load;
wire [4:0] outmux, outreg;

register5_wl register(outmux, outreg, clock, load);
mux2_to_1 multiplex(in, outreg, outmux, compute);
assign out = outreg;

endmodule


//********************************************************//
// Module that computes term with degree one.             //
// Constructed by a variable-constant multiplier with     //
// alpha^1 as constant.                                   //
//********************************************************//
module degree1_cell(in, out, clock, load, compute);

input [4:0] in;
output [4:0] out;
input clock, load, compute;
wire [4:0] outmux;
wire [0:4] outmult, outreg;

register5_wl register(outmux, outreg, clock, load);
mux2_to_1 multiplexer(in, outmult, outmux, compute);

//Multipy variable-alpha^1
assign outmult[0] = outreg[4];
assign outmult[1] = outreg[0];
assign outmult[2] = outreg[1] ^ outreg[4];
assign outmult[3] = outreg[2];
assign outmult[4] = outreg[3];

assign out = outreg;

endmodule


//********************************************************//
// Module that computes term with degree two.
// Constructed by a variable-constant multiplier with 
// alpha^2 as constant.                                   //
//********************************************************//
module degree2_cell(in, out, clock, load, compute);

input [4:0] in;
output [4:0] out;
input clock, load, compute;
wire [4:0] outmux;
wire [0:4] outmult, outreg;

register5_wl register(outmux, outreg, clock, load);
mux2_to_1 multiplexer(in, outmult, outmux, compute);

//Multipy variable-alpha^2
assign outmult[0] = outreg[3];
assign outmult[1] = outreg[4];
assign outmult[2] = outreg[0] ^ outreg[3];
assign outmult[3] = outreg[1] ^ outreg[4];
assign outmult[4] = outreg[2];

assign out = outreg;

endmodule

//********************************************************//
// Module that computes term with degree three.           //
// Constructed by a variable-constant multiplier with     //
// alpha^3 as constant.                                   //
//********************************************************//
module degree3_cell(in, out, clock, load, compute);

input [4:0] in;
output [4:0] out;
input clock, load, compute;
wire [4:0] outmux;
wire [0:4] outmult, outreg;

register5_wl register(outmux, outreg, clock, load);
mux2_to_1 multiplexer(in, outmult, outmux, compute);

//Multipy variable-alpha^3
assign outmult[0] = outreg[2];
assign outmult[1] = outreg[3];
assign outmult[2] = outreg[2] ^ outreg[4];
assign outmult[3] = outreg[0] ^ outreg[3];
assign outmult[4] = outreg[1] ^ outreg[4];

assign out = outreg;

endmodule


//********************************************************//
// Module that computes term with degree four.           //
// Constructed by a variable-constant multiplier with     //
// alpha^4 as constant.                                   //
//********************************************************//
module degree4_cell(in, out, clock, load, compute);

input [4:0] in;
output [4:0] out;
input clock, load, compute;
wire [4:0] outmux;
wire [0:4] outmult, outreg;

register5_wl register(outmux, outreg, clock, load);
mux2_to_1 multiplexer(in, outmult, outmux, compute);

//Multipy variable-alpha^4
assign outmult[0] = outreg[1] ^ outreg[4];
assign outmult[1] = outreg[2];
assign outmult[2] = outreg[1] ^ outreg[3] ^ outreg[4];
assign outmult[3] = outreg[2] ^ outreg[4];
assign outmult[4] = outreg[0] ^ outreg[3];

assign out = outreg;

endmodule

//********************************************************//
// Module that computes term with degree five.            //
// Constructed by a variable-constant multiplier with     //
// alpha^5 as constant.                                   //
//********************************************************//
module degree5_cell(in, out, clock, load, compute);

input [4:0] in;
output [4:0] out;
input clock, load, compute;
wire [4:0] outmux;
wire [0:4] outmult, outreg;

register5_wl register(outmux, outreg, clock, load);
mux2_to_1 multiplexer(in, outmult, outmux, compute);

//Multipy variable-alpha^5
assign outmult[0] = outreg[0] ^ outreg[3];
assign outmult[1] = outreg[1] ^ outreg[4];
assign outmult[2] = outreg[0] ^ outreg[2] ^ outreg[3];
assign outmult[3] = outreg[1] ^ outreg[3] ^ outreg[4];
assign outmult[4] = outreg[2] ^ outreg[4];

assign out = outreg;

endmodule

//********************************************************//
// Module that computes term with degree six.            //
// Constructed by a variable-constant multiplier with     //
// alpha^6 as constant.                                   //
//********************************************************//
module degree6_cell(in, out, clock, load, compute);

input [4:0] in;
output [4:0] out;
input clock, load, compute;
wire [4:0] outmux;
wire [0:4] outmult, outreg;

register5_wl register(outmux, outreg, clock, load);
mux2_to_1 multiplexer(in, outmult, outmux, compute);

//Multipy variable-alpha^6
assign outmult[0] = outreg[2] ^ outreg[4];
assign outmult[1] = outreg[0] ^ outreg[3];
assign outmult[2] = outreg[1] ^ outreg[2];
assign outmult[3] = outreg[0] ^ outreg[2] ^ outreg[3];
assign outmult[4] = outreg[1] ^ outreg[3] ^ outreg[4];

assign out = outreg;

endmodule


//***********************************************************//
// Invers Multiplication module for GF(2^5) is formed by AND //
// and XOR gates. This module is derived directly from       //
// Fermat Theorem, which state that                          //
// beta^(-1) = beta^2.beta^(2^2).beta^(2^3).beta^(2^4),      //
// for beta member of GF(2^5).                               //
// Note: this module is only used in CSEE block              //
//***********************************************************//
module inverscomb(in, out);

input [0:4] in;
output [0:4] out;

//form product consists of AND gates
wire p0, p1, p2, p3, p4 , p5 , p6, p7, p8, p9,
    p10, p11, p12, p13, p14, p15, p16, p17, p18,
    p19, p20, p21, p22, p23, p24;
//form intermediate sum of the product that can be reused
wire s0, s1, s2, s3, s4, s5, s6;

//form intermediate sum of product that is only used by single function
wire t0, t1, t2;

assign p0 = in[0]&in[1];
assign p1 = in[0]&in[2];
assign p2 = in[0]&in[3];
assign p3 = in[0]&in[4];
assign p4 = in[1]&in[2];
assign p5 = in[1]&in[3];
assign p6 = in[1]&in[4];
assign p7 = in[2]&in[4];
assign p8 = in[3]&in[4];
assign p9 = in[2]&in[3];
assign p10 = p0&in[2];
assign p11 = p0&in[4];
assign p12 = p2&in[4];
assign p13 = p9&in[0];
assign p14 = p4&in[3];
assign p15 = p8&in[2];
assign p16 = p7&in[1];
assign p17 = p2&in[1];
assign p18 = p3&in[2];
assign p19 = p6&in[3];
assign p20 = p4&p8;
assign p21 = p1&p5;
assign p22 = p3&p5;
assign p23 = p2&p7;
assign p24 = p1&p6;

assign s0 = p1 ^ p15;
assign s1 = ((p6 ^ p12) ^ p14);
assign s2 = (in[4] ^ p0) ^ p21;
assign s3 = (in[1] ^ in[3]) ^ (p2 ^ p3) ^ (p24 ^ p10);
assign s4 = (p4 ^ p5) ^ (p20 ^ p7) ^ p17;
assign s5 = (in[2] ^ p5) ^ (p22 ^ p23);
assign s6 = p11 ^ p20;

assign t0 = (in[0] ^ p2) ^ (p4 ^ p10);
assign t1 = (in[3] ^ p0) ^ p24;
assign t2 = p19 ^ p23;

assign out[0] = ((s0 ^ s1) ^ (s2 ^ s5)) ^ ((s6 ^ p13) ^ t0);
assign out[1] = ((s0 ^ s1) ^ s2) ^ (s3 ^ (s6 ^ p16));
assign out[2] = (s0 ^ s4) ^ ((p13 ^ p8) ^ t1);
assign out[3] = ((s0 ^ s1) ^ (s2 ^ s5)) ^ ((p16 ^ p8) ^ (p9 ^ p18) ^ p7);
assign out[4] = (s0 ^ s1) ^ (s3 ^ s4) ^ (p9 ^ t2);

endmodule