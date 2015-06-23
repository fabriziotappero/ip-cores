//*******************************************************************//
// This Key Equation Solver (KES) block implements reformulated      //
// inverse-free Berlekamp-Massey algorithm. The inverse-free         //
// Berlekamp-Massey is described by Irving S. Reed, M.T. Smith       //
// and T.K. Truong in their paper entitled "VLSI design of           //
// inverse-free Berlekamp-Massey (BM) algorithm" in Proc. IEEE,      //
// Sept 1991. With the algorithm, inverse/division operation is not  //
// needed. Hence, it simplifies the implementation of                //
// Berlekamp-Massey algorithm.                                       //
// Then, in the paper entitled "High speed architectures for         //
// Reed-Solomon Decoders" in IEEE Trans. VLSI Systems, October 2001, //
// Dilip P. Sarwate and Naresh R. Shanbhag proposed a reformulated   //
// version of the inverse-free algorithm. The reformulated algorithm //
// is aimed mainly to reduce critical path delay and also to         //
// simplify inverse-free algorithm implementation even more.         //
//*******************************************************************//

module KES_block(active_kes, clock1, clock2, reset, syndvalue0, syndvalue1, 
                syndvalue2, syndvalue3, syndvalue4, syndvalue5, syndvalue6, 
                syndvalue7, syndvalue8, syndvalue9, syndvalue10, syndvalue11, 
                lambda0, lambda1, lambda2, lambda3, lambda4, lambda5, 
                lambda6, homega0, homega1, homega2, homega3, homega4, 
                homega5, lambda_degree, finish);

input active_kes, clock1, clock2, reset;
input [4:0] syndvalue0, syndvalue1, syndvalue2, 
            syndvalue3, syndvalue4, syndvalue5, syndvalue6, syndvalue7,
            syndvalue8, syndvalue9, syndvalue10, syndvalue11;
output [4:0] lambda0, lambda1, lambda2, lambda3, lambda4, lambda5, lambda6;
output [4:0] homega0, homega1, homega2, homega3, homega4, homega5;
output [2:0] lambda_degree;
output finish;

wire load, hold, init, iter_control;
wire [4:0] delta0, delta1, delta2, delta3, delta4, delta5, delta6, 
           delta7, delta8, delta9, delta10, delta11, delta12, delta13, 
           delta14, delta15, delta16, delta17, delta18;
wire [4:0] gamma, delta;
wire koefcomp1, koefcomp2, koefcomp3, koefcomp4, koefcomp5, koefcomp6;


PE PE0(delta1, syndvalue0, gamma, delta, clock1, load, init, 
       hold, iter_control, delta0);
PE PE1(delta2, syndvalue1, gamma, delta, clock1, load, init, 
           hold, iter_control, delta1);
PE PE2(delta3, syndvalue2, gamma, delta, clock1, load, init, 
       hold, iter_control, delta2);
PE PE3(delta4, syndvalue3, gamma, delta, clock1, load, init, 
       hold, iter_control, delta3);
PE PE4(delta5, syndvalue4, gamma, delta, clock1, load, init, 
       hold, iter_control, delta4);
PE PE5(delta6, syndvalue5, gamma, delta, clock1, load, init, 
       hold, iter_control, delta5);
PE PE6(delta7, syndvalue6, gamma, delta, clock1, load, init, 
       hold, iter_control, delta6);
PE PE7(delta8, syndvalue7, gamma, delta, clock1, load, init, 
       hold, iter_control, delta7);
PE PE8(delta9, syndvalue8, gamma, delta, clock1, load, init, 
       hold, iter_control, delta8);
PE PE9(delta10, syndvalue9, gamma, delta, clock1, load, init, 
       hold, iter_control, delta9);
PE PE10(delta11, syndvalue10, gamma, delta, clock1, load, init, 
       hold, iter_control, delta10);
PE PE11(delta12, syndvalue11, gamma, delta, clock1, load, init, 
       hold, iter_control, delta11);
PE_12 PE12(delta13, gamma, delta, clock1, load, init, 
           hold, iter_control, delta12);
PE_12 PE13(delta14, gamma, delta, clock1, load, init, 
           hold, iter_control, delta13);
PE_12 PE14(delta15, gamma, delta, clock1, load, init, 
           hold, iter_control, delta14);
PE_12 PE15(delta16, gamma, delta, clock1, load, init, 
           hold, iter_control, delta15);
PE_12 PE16(delta17, gamma, delta, clock1, load, init, 
           hold, iter_control, delta16);
PE_12 PE17(delta18, gamma, delta, clock1, load, init, 
           hold, iter_control, delta17);
PE_18 PE18(delta, clock1, load, init, hold, iter_control,
           delta18);
control mcontrol(delta0, gamma, active_kes, reset, delta, iter_control,
                  finish, load, init, hold, clock1, clock2);

assign homega0 = delta0;
assign homega1 = delta1;
assign homega2 = delta2;
assign homega3 = delta3;
assign homega4 = delta4;
assign homega5 = delta5;

assign lambda0 = delta6;
assign lambda1 = delta7;
assign lambda2 = delta8;
assign lambda3 = delta9;
assign lambda4 = delta10;
assign lambda5 = delta11;
assign lambda6 = delta12;

// this statements below counts degree of error location polynomial 
// (lambda)
assign koefcomp1 = (lambda1[0]|lambda1[1])|(lambda1[2]|lambda1[3])|
                    lambda1[4];
assign koefcomp2 = (lambda2[0]|lambda2[1])|(lambda2[2]|lambda2[3])|
                    lambda2[4];
assign koefcomp3 = (lambda3[0]|lambda3[1])|(lambda3[2]|lambda3[3])|
                    lambda3[4];
assign koefcomp4 = (lambda4[0]|lambda4[1])|(lambda4[2]|lambda4[3])|
                    lambda4[4];
assign koefcomp5 = (lambda5[0]|lambda5[1])|(lambda5[2]|lambda5[3])|
                    lambda5[4];
assign koefcomp6 =  (lambda6[0]|lambda6[1])|(lambda6[2]|lambda6[3])|
                    lambda6[4];
priority_encoder pencoder(koefcomp1,koefcomp2,koefcomp3,koefcomp4,
                          koefcomp5,koefcomp6, lambda_degree);

endmodule
                  


//************************************************************//
module control(delta0_in, gamma, active_kes, reset, delta0_out, 
               iter_control, finish, load, init, hold, 
               clock1, clock2);

input [4:0] delta0_in;
input clock1, clock2, active_kes, reset;
output [4:0] delta0_out, gamma;
output iter_control, finish, load, hold, init;

reg [3:0] cntr;
reg load, hold, init, finish;
wire [4:0] kr, inv_kr, outadder;
wire [4:0] outmux1, outmux2;
wire zerodetect, negdetect;

wire [4:0] incr;
wire carrybit;

parameter [2:0] st0=0, st1=1, st2=2, st3=3, st4=4, st5=5;
reg [2:0] state, nxt_state;

// Counter //
always@(posedge clock1)
begin
    if(load)
       cntr <= cntr + 1;
    else
       cntr <= 4'b0;
end

//******//
// FSM  //
//******//
always@(active_kes or cntr or state)
begin
    case(state)
        st0 : begin
               if(active_kes)
                  nxt_state = st1;
               else
                  nxt_state = st0;
              end
        st1 : nxt_state = st2;
        st2 : begin
               if(cntr == 12)
                  nxt_state = st3;
               else
                  nxt_state = st2;
              end
        st3 : nxt_state = st4;
        st4 : begin
              if(active_kes)
                 nxt_state = st4;
              else
                 nxt_state = st0;
              end
        default: nxt_state = st0;
    endcase
end

always@(posedge clock2 or negedge reset)
begin
   if(~reset)
      state = st0;
   else
      state = nxt_state;
end

always@(state)
begin
    case(state)
        st0 :  begin     //start state
               init = 0;
               finish = 0;
               load = 0;
               hold = 0;
               end
        st1 :  begin      //initialization state
               init = 1;
               finish = 0;
               load = 0;
               hold = 0;
               end
        st2 :  begin      //computation state
               finish = 0;
               load = 1;
               hold = 0;
               init = 0;
               end
        st3 :  begin      //finish state
               finish = 1;
               load = 0;
               hold = 1;
               init = 0;
               end
        st4 :  begin      //hold output data
               finish = 0;
               load = 0;
               hold = 1;
               init = 0;
               end
        default:  begin
                  finish = 0;
                  load = 0;
                  hold = 0;
                  init = 0;
                  end
    endcase
end
               
assign incr = 1;
assign carrybit = 0;

assign zerodetect = (delta0_in[0]|delta0_in[1])|(delta0_in[2]|delta0_in[3])|delta0_in[4];
assign negdetect = ~kr[4];
assign iter_control = zerodetect & negdetect;
assign inv_kr = ~kr;
assign delta0_out = delta0_in;

mux2_to_1 multiplexer1(gamma, delta0_in, outmux1, iter_control);
mux2_to_1 multiplexer2(outadder, inv_kr, outmux2, iter_control);
fulladder adder(kr, incr, carrybit, outadder);
regamma reggamma(outmux1, gamma, load, init, clock1);
regkr regkr(outmux2, kr, load, init, clock1);

endmodule


//****************************************//
// Full Adder 5 bit                       //
// carry bit for MSB cell is discarded    //
//****************************************//
module fulladder(in1, in2, carryin, out);
input [4:0] in1, in2;
input carryin;
output [4:0] out;
    
wire carry0, carry1, carry2, carry3;
    
assign carry0 = ((in1[0] ^ in2[0])&carryin) | (in1[0]&in2[0]);
assign carry1 = ((in1[1] ^ in2[1])&carry0) | (in1[1]&in2[1]);
assign carry2 = ((in1[2] ^ in2[2])&carry1) | (in1[2]&in2[2]);
assign carry3 = ((in1[3] ^ in2[3])&carry2) | (in1[3]&in2[3]);

assign out[0] = in1[0] ^ in2[0] ^ carryin;
assign out[1] = in1[1] ^ in2[1] ^ carry0;
assign out[2] = in1[2] ^ in2[2] ^ carry1;
assign out[3] = in1[3] ^ in2[3] ^ carry2;
assign out[4] = in1[4] ^ in2[4] ^ carry3;

endmodule


//*********************************************//
// register for storing gamma with synchronous //
// load and initialize                         //
//*********************************************//
module regamma(datain, dataout, load, initialize, clock);

input [4:0] datain;
input load, initialize;
input clock;
output [4:0] dataout;
reg [4:0] out;

always @(posedge clock)
begin
    if(initialize)
       out <= 5'b10000;
    else if(load)
       out <= datain;
    else
       out <= 5'b0;
end

assign dataout = out;

endmodule

//********************************************//
// register for storing k(r) with synchronous //
// load and initialize                        //
//********************************************//
module regkr(datain, dataout, load, initialize, clock);

input [4:0] datain;
input load, initialize;
input clock;
output [4:0] dataout;
reg [4:0] out;

always @(posedge clock)
begin
    if(initialize)
       out <= 5'b0;
    else if(load)
       out <= datain;
    else
       out <= 5'b0;
end

assign dataout = out;

endmodule


//******************//
// Priority Encoder //
//******************//
module priority_encoder(in1,in2,in3,in4,in5,in6,out);

input in1, in2, in3, in4, in5, in6;
output [2:0] out;
reg [2:0] out;

always@({in6,in5,in4,in3,in2,in1})
begin
	if(in6==1)					  out = 6;
	else if(in5==1)  out = 5;
	else if(in4==1)  out = 4;
	else if(in3==1)  out = 3;
	else if(in2==1)  out = 2;
	else if(in1==1)  out = 1;
	else out = 3'b0;
end
endmodule


//****************************************************************//
module PE(delta_cflex_in, syndval, gamma, delta, clock, load, init, 
           hold, iter_control, delta_cflex_out);

input [4:0] delta_cflex_in, syndval;
input [4:0] gamma;
input [4:0] delta;
input clock, load, hold, iter_control, init;
output [4:0] delta_cflex_out;

wire [4:0] outmult1, outmult2, outreg1, outreg2, outmux, outadder;

lcpmult multiplier1(delta_cflex_in, gamma, outmult1);
lcpmult multiplier2(delta, outreg1, outmult2);
register_pe reg1(outadder, syndval, outreg2 , load, init, hold, clock);
register_pe reg2(outmux, syndval, outreg1 , load, init, hold, clock);
mux2_to_1 multiplexer(outreg1, delta_cflex_in, outmux, iter_control);

assign outadder[4] = outmult2[4] ^ outmult1[4];
assign outadder[3] = outmult2[3] ^ outmult1[3];
assign outadder[2] = outmult2[2] ^ outmult1[2];
assign outadder[1] = outmult2[1] ^ outmult1[1];
assign outadder[0] = outmult2[0] ^ outmult1[0];

assign delta_cflex_out = outreg2;

endmodule

//***********************************************************//
module PE_12(delta_cflex_in, gamma, delta, clock, load, init, 
           hold, iter_control, delta_cflex_out);

input [4:0] delta_cflex_in;
input [4:0] gamma;
input [4:0] delta;
input clock, load, hold, iter_control, init;
output [4:0] delta_cflex_out;

wire [4:0] outmult1, outmult2, outreg1, outreg2, outmux, outadder;
wire [4:0] initdata;

assign initdata = 5'b0;

lcpmult multiplier1(delta_cflex_in, gamma, outmult1);
lcpmult multiplier2(delta, outreg1, outmult2);
register_pe reg1(outadder, initdata, outreg2 , load, init, hold, clock);
register_pe reg2(outmux, initdata, outreg1 , load, init, hold, clock);
mux2_to_1 multiplexer(outreg1, delta_cflex_in, outmux, iter_control);

assign outadder[4] = outmult2[4] ^ outmult1[4];
assign outadder[3] = outmult2[3] ^ outmult1[3];
assign outadder[2] = outmult2[2] ^ outmult1[2];
assign outadder[1] = outmult2[1] ^ outmult1[1];
assign outadder[0] = outmult2[0] ^ outmult1[0];

assign delta_cflex_out = outreg2;

endmodule 


//******************************************************//
module PE_18(delta, clock, load, init, hold, iter_control,
             delta_cflex_out);

input [4:0] delta;
input clock, load, init, hold, iter_control;
output [4:0] delta_cflex_out;

wire [4:0] outmult, outreg1, outreg2, outmux; 
wire [4:0] initdata;
wire [4:0] delta_cflex_19;

assign initdata = 5'b10000;
assign delta_cflex_19 = 5'b0;

lcpmult multiplier(delta, outreg1, outmult);
register_pe reg1(outmult, initdata, outreg2 , load, init, hold, clock);
register_pe reg2(outmux, initdata, outreg1 , load, init, hold, clock);
mux2_to_1 multiplexer(outreg1, delta_cflex_19, outmux, iter_control);

assign delta_cflex_out = outreg2;

endmodule


//*****************************************************//
//PE Register with synchronous load, intialize, hold //
module register_pe(datain, initdata, dataout, load, initialize, hold, clock);

input [4:0] datain, initdata;
input load, hold, initialize;
input clock;
output [4:0] dataout;
reg [4:0] out;

always @(posedge clock)
begin
    if(initialize)
       out <= initdata;
    else if(load)
       out <= datain;
    else if(hold)
       out <= out;
    else
       out <= 5'b0;
end

assign dataout = out;

endmodule
