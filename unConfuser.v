/***************************************************************************************/
/*                                                                                                                                                    */
/* Author:- Pratik Mahajan                                                                                                               */
/* Create Date:- Spring 2009						                                                               */
/* Project Name:- Unconfuser for 32 bit data					                                              */
/* Target Devices: ASIC 							                                                              */	
/*Project Description: To build an unconfuser for 32 bit confused data with around 700                     */ 
/* bits of confusion                                                                                                                         */

module unConfuser(Clk, Reset, PushIn, Din, Caddr, Cdata, Cpush, PushOut, StopIn, Dout, inMdin, inAddrw, inWrite, inMdout, inAddrr, opMdin, opAddrw, opWrite, opMdout, opAddrr);

/*Port list for unConfuser */
   input[7:0] Din, Cdata;
   input[6:0] Caddr;
   output[7:0] Dout;
   input PushIn, Clk, Reset, StopIn, Cpush;
   output PushOut;

/* Port list for Fifo and memory interfacing */
   output inWrite, opWrite;
   output [7:0] inMdin, opMdin;
   output [15:0] inAddrr, inAddrw, opAddrr, opAddrw;
   input [7:0] inMdout, opMdout;

/*/Variables and parameters declaration*/
/*Registers being used for CRCs*/
   reg[159:0] rDataPad0;
   reg[160:0] rDataPad1;
   reg[161:0] rDataPad2;
   reg[162:0] rDataPad3;
   reg[31:0]  rDataInjector;
   reg[39:0]  rDataPadSel;
   reg[31:0]  rDataCDATA;

/*Wires/Nets Representing combinational logic (XORing) - i.e. (D input to F/F)*/
   wire[159:0] wXorPad0FW, wXorPad0BW, wXorPad0, wLoadPad0;
   wire[160:0] wXorPad1FW, wXorPad1BW, wXorPad1, wLoadPad1;
   wire[161:0] wXorPad2FW, wXorPad2BW, wXorPad2, wLoadPad2;
   wire[162:0] wXorPad3FW, wXorPad3BW, wXorPad3, wLoadPad3;
   wire[39:0]  wXorPadSelFW, wXorPadSelBW, wXorPadSel, wLoadPadSel;
   wire[31:0]  wXorCDATAFW, wXorCDATABW, wXorCDATABW0, wXorCDATA; //---> Forward moving CDATA is Never been used
   wire[31:0]  wXorInjectorFW, wXorInjectorBW, wXorInjector, wLoadInjector;   //---> Backword moving injector is Never been used
   

/*Control signals for controlling CRCs*/   
   reg rIdle, rDirection, rIdleInjector, rIdleCDATA, rIsBW;

/*Internal signals for design like PRN select lines for pad select MUX etc.*/
   wire[4:0] wSelectPadBit;
   wire[5:0] wPadAmount;
   wire wPRN;
   reg rPRN;
   reg rDataOut;
/*Variables used in for loops and etc*/
   integer unConfuserCnt, ipFifoLoadCnt, opFifoLoadCnt, PadCounter, injectorCounter;
   reg[2:0] nextState;
   reg[5:0] rPadAmount;

/*FIFO signals declaration*/
   wire inPull, inEmpty, inWrite, opWrite;
   wire[7:0] inDout, inMdin, inMdout;
   wire[15:0] inAddrw, inAddrr; 
   wire opPull, opPush, opEmpty, opFull;
   wire[7:0] wopDin, opMdin, opMdout;
   wire[15:0] opAddrw, opAddrr;
   reg[7:0] opDin;

/*Parameters representing Polynomials for all CRCs*/

/* X^160+X^139+X^119+X^98+X^79+X^40+X^20+1     -> Pad0 polynomial*/
   parameter [159:0] pPolyPad0 = 160'H00000800_00800004_00008000_00000100_00100001;

/*  X161+X140+X121+X100+X80+X60+X40+X20+1                 -> Pad1 polynomial*/
   parameter [160:0] pPolyPad1 = 161'H0_00001000_02000010_00010000_10000100_00100001;

/*  X162+X141+X121+X100 +X80+X60+X40+X20+1                -> Pad2 polynomial*/
   parameter [161:0] pPolyPad2 = 162'H0_00002000_02000010_00010000_10000100_00100001;

/*  X163+X142+X122+X102+X82+X61+X41+X20+1                 -> Pad3 polynomial*/
   parameter [162:0] pPolyPad3 = 162'H0_00004000_04000040_00040000_20000200_00100001;

/* X32+X27+X21+X16+X10+X5+1                               -> Injector polynomial*/
   parameter [31:0]  pPolyInjector = 32'H0821_0421;

/* X40+X34+X27+X19+X12+X6+1                               -> PadSelect Polynomial*/
   parameter [39:0] pPolyPadSel = 40'H04_0808_1041;

/* X32+X31+X29+X28+X26+X25+X24+X22+X21+X13+X11+X9+X8+X5+1 -> CRC (unConfuser) polynomial*/
   parameter [31:0] pPolyCDATA = 32'HB760_2B21;

/*Parameters for State Machine*/
   parameter stateReset     = 3'b000;
   parameter stateLoadPads  = 3'b001;
   parameter stateLoad      = 3'b010;
   parameter stateStepFW    = 3'b011;
   parameter stateStepBW    = 3'b100;
   parameter stateCDATABW   = 3'b101;
   parameter stateLoadOut   = 3'b110;
   parameter stateFinalFW   = 3'b111;

/* Forward and Backward flags as parameters*/
   parameter pFW 	    = 1'b1;
   parameter pBW 	    = 1'b0;

/*Instatiate input and output fifos*/
   fifooneflag ipfifo (Clk, Reset, PushIn, Din, inPull, inEmpty, inDout, inAddrw, inMdin, inWrite, inAddrr, inMdout);
   assign inPull 	  = (inEmpty == 1'b0 && nextState == stateLoad); //When CDATA is begin loaded
   fifotwoflag opfifo (Clk, Reset, opPush, opFull, opDin, opPull, opEmpty, Dout, opAddrw, opMdin, opWrite, opAddrr, opMdout);
   assign opPush 	  = (opFull == 1'b0 && rDataOut == 1'b1);             //when not full
   assign opPull 	  = (StopIn == 1'b0);

   assign PushOut 	  = (opEmpty == 1'b0);
   assign wopDin 	  = (opPush==1'b1 && opFifoLoadCnt==1) ? rDataCDATA[31:24] :
                            ((opPush==1'b1 && opFifoLoadCnt==2) ? rDataCDATA[23:16] :
			    ((opPush==1'b1 && opFifoLoadCnt==3) ? rDataCDATA[15:8]  :
			    ((opPush==1'b1 && opFifoLoadCnt==4) ? rDataCDATA[7:0] : opDin)));
   
			 /*Logic starts here*/
			 /*All CRC going forward :-*/
   assign wXorPad0FW 	  = {rDataPad0[158:0],1'b0}   ^ (rDataPad0[159] ? pPolyPad0  : 160'h0);
   assign wXorPad1FW 	  = {rDataPad1[159:0],1'b0}   ^ (rDataPad1[160] ? pPolyPad1  : 161'h0);
   assign wXorPad2FW 	  = {rDataPad2[160:0],1'b0}   ^ (rDataPad2[161] ? pPolyPad2  : 162'h0);
   assign wXorPad3FW 	  = {rDataPad3[161:0],1'b0}   ^ (rDataPad3[162] ? pPolyPad3  : 163'h0);
   assign wXorPadSelFW 	  = {rDataPadSel[38:0],1'b0}  ^ (rDataPadSel[39]? pPolyPadSel : 40'h0);
/*CDATA will never move forward*/
   assign wXorCDATAFW 	  = {rDataCDATA[30:0],1'b0}   ^ (rDataCDATA[31] ? pPolyCDATA : 32'h0);
   assign wXorInjectorFW  = {rDataInjector[30:0],1'b0}^ (rDataInjector[31] ? pPolyInjector : 32'h0);

/*All CRC going Backword*/
   assign wXorPad0BW[158:0]    = {rDataPad0[159:1]}   ^ (rDataPad0[0] ? pPolyPad0[159:1]  : 159'h0); assign wXorPad0BW[159] = rDataPad0[0];
   assign wXorPad1BW[159:0]    = {rDataPad1[160:1]}   ^ (rDataPad1[0] ? pPolyPad1[160:1]  : 160'h0); assign wXorPad1BW[160] = rDataPad1[0];
   assign wXorPad2BW[160:0]    = {rDataPad2[161:1]}   ^ (rDataPad2[0] ? pPolyPad2[161:1]  : 161'h0); assign wXorPad2BW[161] = rDataPad2[0];
   assign wXorPad3BW[161:0]    = {rDataPad3[162:1]}   ^ (rDataPad3[0] ? pPolyPad3[162:1]  : 162'h0); assign wXorPad3BW[162] = rDataPad3[0];
   assign wXorPadSelBW[38:0]   = {rDataPadSel[39:1]}  ^ (rDataPadSel[0]? pPolyPadSel[39:1]: 39'h0); assign wXorPadSelBW[39]= rDataPadSel[0];
   assign wXorCDATABW[30:0]    = {rDataCDATA[31:1]}   ^ ((rDataCDATA[0] ^ wPRN) ? pPolyCDATA[31:1] : 31'h0); assign wXorCDATABW[31] = (rDataCDATA[0] ^ wPRN); /*We need datain(wPRN) input to provide PRN from MUX*/
   assign wXorCDATABW0[30:0]   = {rDataCDATA[31:1]}   ^ (rDataCDATA[0] ? pPolyCDATA[31:1] : 31'h0); assign wXorCDATABW0[31] = rDataCDATA[0];
/*Injector Backward never need to be used*/
   assign wXorInjectorBW[30:0] = {rDataInjector[31:1]}^ (rDataInjector[0] ? pPolyInjector[31:1] : 31'h0); assign wXorInjectorBW[31] = rDataInjector[0]; 

/*Chosing out of Reset, Idle, Forward or Backward Condition Make RESET asynchronous*/
   assign wXorPad0 	   = Cpush ? wLoadPad0 : (rIdle ? rDataPad0 : (rDirection ? wXorPad0FW : wXorPad0BW));
   assign wXorPad1 	   = Cpush ? wLoadPad1 : (rIdle ? rDataPad1 : (rDirection ? wXorPad1FW : wXorPad1BW));
   assign wXorPad2 	   = Cpush ? wLoadPad2 : (rIdle ? rDataPad2 : (rDirection ? wXorPad2FW : wXorPad2BW));
   assign wXorPad3 	   = Cpush ? wLoadPad3 : (rIdle ? rDataPad3 : (rDirection ? wXorPad3FW : wXorPad3BW));
   assign wXorPadSel 	   = Cpush ? wLoadPadSel : (rIdle ? rDataPadSel : (rDirection ? wXorPadSelFW : wXorPadSelBW));
   assign wXorCDATA 	   = rIdleCDATA ? rDataCDATA : (rIsBW ? wXorCDATABW0 : wXorCDATABW);            //Direction will always be Backward
   assign wXorInjector 	   = Cpush ? wLoadInjector : (rIdleInjector ? rDataInjector : wXorInjectorFW );             //Direction will always be Forward

/*Implementation of configuration register for loading each register*/
   //loadPad0:
     assign wLoadPad0 	   = {Caddr=='d19 ? Cdata : rDataPad0[159:152],
                         Caddr=='d18 ? Cdata : rDataPad0[151:144],
                         Caddr=='d17 ? Cdata : rDataPad0[143:136],
                         Caddr=='d16 ? Cdata : rDataPad0[135:128],
                         Caddr=='d15 ? Cdata : rDataPad0[127:120],
                         Caddr=='d14 ? Cdata : rDataPad0[119:112],
                         Caddr=='d13 ? Cdata : rDataPad0[111:104],
                         Caddr=='d12 ? Cdata : rDataPad0[103:96],
                         Caddr=='d11 ? Cdata : rDataPad0[95:88],
                         Caddr=='d10 ? Cdata : rDataPad0[87:80],
                         Caddr=='d09 ? Cdata : rDataPad0[79:72],
                         Caddr=='d08 ? Cdata : rDataPad0[71:64],
                         Caddr=='d07 ? Cdata : rDataPad0[63:56],
                         Caddr=='d06 ? Cdata : rDataPad0[55:48],
                         Caddr=='d05 ? Cdata : rDataPad0[47:40],
                         Caddr=='d04 ? Cdata : rDataPad0[39:32],
                         Caddr=='d03 ? Cdata : rDataPad0[31:24],
                         Caddr=='d02 ? Cdata : rDataPad0[23:16],
                         Caddr=='d01 ? Cdata : rDataPad0[15:08],
                         Caddr=='d00 ? Cdata : rDataPad0[07:00]};

   //loadPad1:
     assign wLoadPad1 	   = {Caddr=='d41 ? Cdata[0] : rDataPad1[160],
                         Caddr=='d40 ? Cdata : rDataPad1[159:152],
                         Caddr=='d39 ? Cdata : rDataPad1[151:144],
                         Caddr=='d38 ? Cdata : rDataPad1[143:136],
                         Caddr=='d37 ? Cdata : rDataPad1[135:128],
                         Caddr=='d36 ? Cdata : rDataPad1[127:120],
                         Caddr=='d35 ? Cdata : rDataPad1[119:112],
                         Caddr=='d34 ? Cdata : rDataPad1[111:104],
                         Caddr=='d33 ? Cdata : rDataPad1[103:96],
                         Caddr=='d32 ? Cdata : rDataPad1[95:88],
                         Caddr=='d31 ? Cdata : rDataPad1[87:80],
                         Caddr=='d30 ? Cdata : rDataPad1[79:72],
                         Caddr=='d29 ? Cdata : rDataPad1[71:64],
                         Caddr=='d28 ? Cdata : rDataPad1[63:56],
                         Caddr=='d27 ? Cdata : rDataPad1[55:48],
                         Caddr=='d26 ? Cdata : rDataPad1[47:40],
                         Caddr=='d25 ? Cdata : rDataPad1[39:32],
                         Caddr=='d24 ? Cdata : rDataPad1[31:24],
                         Caddr=='d23 ? Cdata : rDataPad1[23:16],
                         Caddr=='d22 ? Cdata : rDataPad1[15:08],
                         Caddr=='d21 ? Cdata : rDataPad1[07:00]};
   
   //loadPad2:
     assign wLoadPad2 	   = {Caddr=='d62 ? Cdata[1:0] : rDataPad2[161:160],
                         Caddr=='d61 ? Cdata : rDataPad2[159:152],
                         Caddr=='d60 ? Cdata : rDataPad2[151:144],
                         Caddr=='d59 ? Cdata : rDataPad2[143:136],
                         Caddr=='d58 ? Cdata : rDataPad2[135:128],
                         Caddr=='d57 ? Cdata : rDataPad2[127:120],
                         Caddr=='d56 ? Cdata : rDataPad2[119:112],
                         Caddr=='d55 ? Cdata : rDataPad2[111:104],
                         Caddr=='d54 ? Cdata : rDataPad2[103:96],
                         Caddr=='d53 ? Cdata : rDataPad2[95:88],
                         Caddr=='d52 ? Cdata : rDataPad2[87:80],
                         Caddr=='d51 ? Cdata : rDataPad2[79:72],
                         Caddr=='d50 ? Cdata : rDataPad2[71:64],
                         Caddr=='d49 ? Cdata : rDataPad2[63:56],
                         Caddr=='d48 ? Cdata : rDataPad2[55:48],
                         Caddr=='d47 ? Cdata : rDataPad2[47:40],
                         Caddr=='d46 ? Cdata : rDataPad2[39:32],
                         Caddr=='d45 ? Cdata : rDataPad2[31:24],
                         Caddr=='d44 ? Cdata : rDataPad2[23:16],
                         Caddr=='d43 ? Cdata : rDataPad2[15:08],
                         Caddr=='d42 ? Cdata : rDataPad2[07:00]};

   //loadPad3:
     assign wLoadPad3 	   = {Caddr=='d83 ? Cdata[2:0] : rDataPad3[162:160],
                         Caddr=='d82 ? Cdata : rDataPad3[159:152],
                         Caddr=='d81 ? Cdata : rDataPad3[151:144],
                         Caddr=='d80 ? Cdata : rDataPad3[143:136],
                         Caddr=='d79 ? Cdata : rDataPad3[135:128],
                         Caddr=='d78 ? Cdata : rDataPad3[127:120],
                         Caddr=='d77 ? Cdata : rDataPad3[119:112],
                         Caddr=='d76 ? Cdata : rDataPad3[111:104],
                         Caddr=='d75 ? Cdata : rDataPad3[103:96],
                         Caddr=='d74 ? Cdata : rDataPad3[95:88],
                         Caddr=='d73 ? Cdata : rDataPad3[87:80],
                         Caddr=='d72 ? Cdata : rDataPad3[79:72],
                         Caddr=='d71 ? Cdata : rDataPad3[71:64],
                         Caddr=='d70 ? Cdata : rDataPad3[63:56],
                         Caddr=='d69 ? Cdata : rDataPad3[55:48],
                         Caddr=='d68 ? Cdata : rDataPad3[47:40],
                         Caddr=='d67 ? Cdata : rDataPad3[39:32],
                         Caddr=='d66 ? Cdata : rDataPad3[31:24],
                         Caddr=='d65 ? Cdata : rDataPad3[23:16],
                         Caddr=='d64 ? Cdata : rDataPad3[15:08],
                         Caddr=='d63 ? Cdata : rDataPad3[07:00]};

   //loadInjector:
     assign wLoadInjector  = {
                         Caddr=='d87 ? Cdata : rDataInjector[31:24],
                         Caddr=='d86 ? Cdata : rDataInjector[23:16],
                         Caddr=='d85 ? Cdata : rDataInjector[15:08],
                         Caddr=='d84 ? Cdata : rDataInjector[07:00]};


   //loadPadSel:
     assign wLoadPadSel    = {
                         Caddr=='d92 ? Cdata : rDataPadSel[39:32],
                         Caddr=='d91 ? Cdata : rDataPadSel[31:24],
                         Caddr=='d90 ? Cdata : rDataPadSel[23:16],
                         Caddr=='d89 ? Cdata : rDataPadSel[15:08],
                         Caddr=='d88 ? Cdata : rDataPadSel[07:00]};

/*Logic for generating PRN by selcting pad values with the help of pad select*/
   assign wSelectPadBit    = {rDataPadSel[31], rDataPadSel[3], rDataPadSel[5], rDataPadSel[19], rDataPadSel[8]};
   assign wPadAmount 	   = {1'b1, rDataInjector[30], rDataInjector[5], rDataInjector[9], rDataInjector[2], rDataInjector[27]};  

assign wPRN =
      (wSelectPadBit == 5'd00) ? rDataPad1[15] :
      (wSelectPadBit == 5'd01) ? rDataPad0[37] :
      (wSelectPadBit == 5'd02) ? rDataPad2[73] :
      (wSelectPadBit == 5'd03) ? rDataPad3[99] :
      (wSelectPadBit == 5'd04) ? rDataPad0[121] :
      (wSelectPadBit == 5'd05) ? rDataPad1[130] :
      (wSelectPadBit == 5'd06) ? rDataPad3[15] :
      (wSelectPadBit == 5'd07) ? rDataPad2[9] :
      (wSelectPadBit == 5'd08) ? rDataPad3[97] :
      (wSelectPadBit == 5'd09) ? rDataPad2[140] :
      (wSelectPadBit == 5'd10) ? rDataPad1[4] :
      (wSelectPadBit == 5'd11) ? rDataPad0[88] :
      (wSelectPadBit == 5'd12) ? rDataPad0[33] :
      (wSelectPadBit == 5'd13) ? rDataPad1[75] :
      (wSelectPadBit == 5'd14) ? rDataPad2[35] :
      (wSelectPadBit == 5'd15) ? rDataPad3[155] :
      (wSelectPadBit == 5'd16) ? rDataPad2[28] :
      (wSelectPadBit == 5'd17) ? rDataPad1[150] :
      (wSelectPadBit == 5'd18) ? rDataPad3[29] :
      (wSelectPadBit == 5'd19) ? rDataPad0[144] :
      (wSelectPadBit == 5'd20) ? rDataPad0[127] :
      (wSelectPadBit == 5'd21) ? rDataPad1[125] :
      (wSelectPadBit == 5'd22) ? rDataPad2[0] :
      (wSelectPadBit == 5'd23) ? rDataPad3[5] : 
      (wSelectPadBit == 5'd24) ? rDataPad0[110] :
      (wSelectPadBit == 5'd25) ? rDataPad3[87] :
      (wSelectPadBit == 5'd26) ? rDataPad1[19] :
      (wSelectPadBit == 5'd27) ? rDataPad2[82] :
      (wSelectPadBit == 5'd28) ? rDataPad0[48] :
      (wSelectPadBit == 5'd29) ? rDataPad1[47] :
      (wSelectPadBit == 5'd30) ? rDataPad2[46] :
                                 rDataPad3[51];

always @(posedge Clk or posedge Reset) begin
  if(Reset == 1'b1) begin
     rDataPad0 	    <= 'b0;
     rDataPad1 	    <= 'b0;
     rDataPad2 	    <= 'b0;
     rDataPad3 	    <= 'b0;
     rDataPadSel    <= 'b0;
     rDataCDATA     <= 'b0;
     rDataInjector  <= 'b0;
     nextState <= stateReset;
  end
  else 
  begin
      rDataPad0     <= wXorPad0;
      rDataPad1     <= wXorPad1;
      rDataPad2     <= wXorPad2;
      rDataPad3     <= wXorPad3;
      rDataPadSel   <= wXorPadSel;
      rDataCDATA    <= wXorCDATA;
      rDataInjector <= wXorInjector;
      opDin         <= wopDin;
/*State Machine code*/

    case(nextState)
     
      stateReset: begin
	 rIdle 	       <= 1'b1;
	 rIdleInjector <= 1'b1;
	 rIdleCDATA    <= 1'b1;
	 rIsBW 	       <= 1'b0;
	 rDataOut      <= 1'b0;
	 nextState     <= stateLoadPads;
      end

      stateLoadPads: begin
	 rIdle 		  <= 1'b1;
	 rIdleInjector 	  <= 1'b1;
	 rIdleCDATA 	  <= 1'b1;
	 rIsBW	  	  <= 1'b0;
	 if(inEmpty == 1'b1)
	   nextState 	  <= stateLoadPads;
	 else begin
	    ipFifoLoadCnt  = 0;
	    nextState 	  <= stateLoad;
	 end
	 
	 end

       stateLoad: begin
	  rIdle 	<= 1'b1;
	  rIdleInjector <= 1'b1;
	  rIdleCDATA 	<= 1'b1;
	  rIsBW 	<= 1'b0;
	  rPadAmount 	<= wPadAmount;
	  if(inEmpty == 1'b0) begin
	     case(ipFifoLoadCnt)
	       0: rDataCDATA[31:24] <= inDout;
	       1: rDataCDATA[23:16] <= inDout;
	       2: rDataCDATA[15:8]  <= inDout;
	       3: rDataCDATA[7:0]   <= inDout;
	     endcase // case (ipFifoLoadCnt)
	  ipFifoLoadCnt = ipFifoLoadCnt+1;
	  end
	  if(ipFifoLoadCnt == 4) begin
	    nextState     <= stateStepFW;
	    PadCounter     = 0;
	    injectorCounter= 0;
	    rIdle 	  <= 1'b0;
	    rDirection    <= 1'b1;
	    rIdleCDATA    <= 1'b1;
	    rIdleInjector <= 1'b0;
	    rIsBW	  <= 1'b0;
	  end
	  else
	    nextState <= stateLoad;
	 
       end // case: (stateLoad)

      stateStepFW: begin
	 ipFifoLoadCnt 	= 0;
	 rIdle 	       <= 1'b0;
	 rDirection    <= 1'b1;
	 rIdleCDATA    <= 1'b1;
	 rIsBW	       <= 1'b0;
	 unConfuserCnt 	= 0;
	 if(PadCounter == rPadAmount-1) begin
	   nextState   <= stateStepBW;
	   rDirection  <= 1'b0;
	   rIsBW       <= 1'b1;
	   rPRN        <= 1'b0;
//	   rIdleCDATA  <= 1'b0;
	   PadCounter   = PadCounter-1;
	 end
	 else
	   nextState   <= stateStepFW;
	 if(injectorCounter >= 38) begin
	   rIdleInjector <= 1'b1;
 	 end
	 else rIdleInjector <= 1'b0;
 	 PadCounter 	= PadCounter+1;
	 injectorCounter= injectorCounter+1;
      end // case: (stateStepFW)

      stateStepBW: begin
	 rIdle 	       <= 1'b0;
 	 if(PadCounter == rPadAmount-1) begin
	  rIsBW        <= 1'b0;
	  rPRN	       <= 1'b0;
	 end
	 else begin
	  rIsBW	       <= 1'b0;
	  rPRN 	       <= wPRN;
 	 end
	 if(injectorCounter >= 38) begin
	  rIdleInjector <= 1'b1;
	  //injectorCounter = injectorCounter+1;
	 end
	 else begin
	  rIdleInjector <= 1'b0;
	  injectorCounter= injectorCounter+1;
	 end
	 rDirection    <= 1'b0;
	 rIsBW 	       <= 1'b0;
	 rIdleCDATA  <= 1'b0;
	 PadCounter = PadCounter - 1;
	 unConfuserCnt 	   = unConfuserCnt+1;
	 if(PadCounter == -1) begin
	    nextState 	  <= stateCDATABW;
	    opFifoLoadCnt  = 0;
	    rIdle         <= 1'b1;
	    rIdleInjector <= 1'b1;
	    rIdleCDATA    <= 1'b0;
 	    rIsBW 	  <= 1'b0;
	 end
	 else
	   nextState 	  <= stateStepBW;
      end // case: (stateStepBW)

      stateCDATABW: begin
         rIdle         <= 1'b1;
	 rIdleCDATA    <= 1'b1;
	 rIdleInjector <= 1'b1;
	 rIsBW         <= 1'b0;
	 nextState     <= stateLoadOut;
      end

      stateLoadOut: begin
	 rIdle 	       <= 1'b1;
	 rIdleCDATA    <= 1'b1;
	 rIdleInjector <= 1'b1;
	 rIsBW 	       <= 1'b0;
	 rDataOut      <= 1'b1;
	 if(opFull == 1'b0)
	   opFifoLoadCnt = opFifoLoadCnt+1;
	 
	 if(opFifoLoadCnt == 4) begin
 	  rIdle        <= 1'b0;
	  rDirection   <= 1'b1;
	  PadCounter    = 0;
	  rIdleCDATA   <= 1'b1;
  	  rIdleInjector<= 1'b1;
	  nextState    <= stateFinalFW;
	 end 
      end // case: (stateLoadOut)

      stateFinalFW: begin
	 rIdle 	       <= 1'b0;
	 rDirection    <= 1'b1;
	 rIdleCDATA    <= 1'b1;
	 rIdleInjector <= 1'b1;
	 rDataOut      <= 1'b0;
	 if(PadCounter == rPadAmount-2) begin
	  if(inEmpty == 1'b1)
	   nextState   <= stateLoadPads;
	  else begin
	   ipFifoLoadCnt = 0;
	   nextState    <= stateLoad; end
	 end
	 else
	   nextState   <= stateFinalFW;
	PadCounter = PadCounter+1;
       end
      default: $display("Wrong CHoice");
      
    endcase // case (nextState)
   end
 end // always @ (posedge Clk or wReset)
endmodule
