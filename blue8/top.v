/*
    This file is part of Blue8.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Blue8.  If not, see <http://www.gnu.org/licenses/>.

    Blue8 by Al Williams alw@al-williams.com

*/

// OK this is the blue CPU -- Williams

 `default_nettype	 none


 module blue(input wire clear,input wire clkin, output [15:0] accout, input wire start,
             input wire stop, input wire exam, input wire deposit, output wire [11:0] pcout,
				 input wire [15:0] swreg, input wire swloadpc, output wire [15:0] irout, output wire running,
				 /* memory interface */
				 output wire [11:0] xmaddress, inout wire [15:0] xmdata, output wire xmwrite, 
				 output wire xmsend,
				 output wire clk, output reg Q
				 
				 );
   wire [15:0] 	 bus;
   wire [15:0] 	 mabus;  // memory address bus (11:0 significant)
   wire [15:0] 	 aluzbus;
   wire [15:0] 	 aluybus;
   wire [8:1] 	 cp;  // clock pulses
	wire [8:1] cpw;  // write clock pulses
   wire [15:0] 	 ibus;
   wire [15:0] 	 accbus;
   wire mclear;
	wire sendxor, sendx2, sendhalf;
	wire ihlt, ophlt, opxor, opand, opior, opnot, oplda, opsta, opsrj, opjmp, opldx;
	wire opral, opnop, opinc, opdec, opskip, opspn, opq, opqtog, opsub, opcmp, opldi, oprar, opidx;
	wire opstx, opjmpa, opswap, oplds, oppush, oppop, opframe, opldxa;

	   
   
   
   wor 		 sendpc,writemar, writeZ,msend,mwrite, sendone,writeY, sendsum, senddiff;
   wor 		 sendir, sendbar, sendand, sendacc;
   wor 		  writeacc, sendor, sendffff, sendidx, writeidx;
	wire writeir;
   wire 	 DTA, ARITH, REF;
   wor s2bus, writepc;
  	wire doexam, dodep;
	wire sendzero;
	wor abortcycle;
	wire opadd; // ought to provide the others here too
	wire overflow, aluzero, carry;   
	reg zflag, oflag, cflag;
	wire [11:0] idxbus;
	wor writesp, sendsp;


   assign 	 accout=accbus;
	assign	 irout=ibus;


   // make the data path items
   register IR(clk,bus,writeir,bus,sendir,ibus,mclear);
   aregister MAR(clk,bus,writemar,,1'b1,mabus[11:0],mclear);
	aregister INDEX(clk,bus,writeidx,bus,sendidx,idxbus,mclear);
	aregister SP(clk,bus,writesp,bus,sendsp,,mclear);
   register Y(clk,bus,writeY,,1'b0,aluybus,mclear);
   register Z(clk,bus,writeZ,,1'b0,aluzbus,mclear);
//   mem core(clk,mabus,bus,mwrite,bus,msend);
   assign xmaddress=mabus;
	assign xmdata=mwrite?bus:16'bz;
	assign bus=xmsend?xmdata:16'bz;
   assign xmwrite=mwrite;
	assign xmsend=msend;

   register acc(clk,bus,writeacc,bus,sendacc,accbus,mclear);
   aregister pc(clk,bus,writepc,bus,sendpc,pcout,mclear);
   one One(sendone,bus);
   ffff Ffff(sendffff,bus);
	zero Zero(sendzero,bus);
   
   alu alu(aluybus,aluzbus,bus,sendsum,sendor,sendand,sendxor,sendbar,sendx2,senddiff,sendhalf, overflow,aluzero,carry,cflag);

   wire coverflow, writezf, writecf, writeflag;
	wire writepc1;
	assign writepc=writepc1;
//	assign coverflow=overflow & opadd;  // only overflow on adding
 assign coverflow=1'b0;  // we don't halt on overflow anymore
   
   // TODO: Tried to add abort cycle to let short instructions recycle faster. Doesn't seem to work (yet)
	
	control ctl(clkin,start,stop,exam,deposit,ihlt,coverflow,cp,cpw,clear,mclear,s2bus,writepc1,swloadpc, doexam,dodep,running,clk,abortcycle);
   idecode decoder(ibus,ophlt,opadd,opxor,opand,opior,opnot,oplda,opsta,
		   opsrj, opjmp, opldx,  opral, opnop,opinc,opdec, opskip, opspn,opq,opqtog,opsub,opcmp,
			opldi, oprar, opidx, opstx, opjmpa, opswap, oplds, oppush, oppop, opframe, opldxa);


   always @(posedge clk or posedge mclear) begin			  // manage Q output
	  if (mclear) Q<=0;
	  else if (cpw[5]) begin
	    if (opq) Q<=ibus[0];
	    else if (opqtog) Q<=~Q;
     end
	  else Q<=Q;
	end

   always @(posedge clk or posedge mclear) begin		 // manage z flag (not Z register)
	  if (mclear) zflag<=1'b0;
	  else if (writeflag) zflag<=bus[1]; 
	  else if ((sendsum|senddiff|sendor|sendand|sendxor|sendbar|sendx2)&(writeacc|writezf)) zflag<=aluzero;
	  else zflag<=zflag;
	end   

	always @(posedge clk or posedge mclear) begin		// manage overflow flag
	  if (mclear) oflag<=1'b0;
	  else if (writeflag) oflag<=bus[0]; 
	  else if (sendsum&writeacc) oflag<=overflow;
	  else oflag<=oflag;
	end 

	always @(posedge clk or posedge mclear) begin	  // manage carry flag
	  if (mclear) cflag<=1'b0;
	  else if (writeflag) cflag<=bus[2]; 
	  else if ((sendsum|sendx2|senddiff|sendhalf)&(writeacc|writecf)) cflag<=carry;
	  else cflag<=cflag;
	end 

// load pc (switch)
   assign bus=s2bus?swreg:16'bz;

   // instructions
// first part of F cycle
    assign sendpc=cp[1];
	 assign writemar=cpw[1];
	 assign writeZ=cpw[1];

	
	// So here this was in cp[6] but I moved things and will move this to cp2
// which leaves cp5,6,7,8/F free for processing.. placing it before PC++
// means the async decoder can be pretty sloppy since the result is not needed until cp5
   and u7(msend,cp[2],~(doexam|dodep));
	and u7z(sendzero, cp[2],(doexam|dodep));		// assumes NOP or HALT=0
   assign writeir=cpw[2];
	

	 assign sendone=cp[3];
	 assign writeY=cpw[3];
	 
// writeback PC... cycles 5-8 are free for execute

    assign sendsum=cp[4];
	 assign writepc=cpw[4];


// do an exam 
   and uex1(msend,cp[5],doexam);
	and uex2(writeacc,cpw[5],doexam);


// do a deposit
   and udep1(s2bus,cp[5],dodep);
	and udep2(mwrite,cpw[5],dodep);


// halt instruction 
   and u9(ihlt,cp[7],ophlt);

// 2 jump instruction
   and u12(sendir,opjmp,cp[5]);
   and u13(writepc,opjmp,cpw[5]);

	// abort 6 cycle instructions
 	and u13x(abortcycle,opjmp|opldx|opstx|opjmpa|opswap|oplds|opnop|opframe|opq|opqtog,cp[5]);
	// abort 7 cycle instructions
	and u13y(abortcycle, opskip|opspn|opnot|opral|oprar|opidx,cp[6]);

// RAL, NOT, CSA
// don't need the next 3 anymore
// because I preload ACC to Z in CP5/F
//   or u16(nr1,opnot,opral);
//   and u17a(sendacc,nr1,cp[7]);
//   and u17b(writeZ,nr1,cp[7]);
// update: changed CP5/F to execute cycle so now Ido this later 

   
// not (pt 2)
   and u19a(sendbar,opnot,cp[6]);
   and u19b(writeacc,opnot,cpw[6]);
// ral, rar
   and u20a(sendx2,opral,cp[6]);
   and u20c(sendhalf,oprar,cp[6]);
   and u20b(writeacc,opral|oprar,cpw[6]);

// skipped input/output TODO

// ARITH, DTA, REF (internal)
   assign 	 ARITH=opand|opxor|opior|opadd|opsub|opcmp;
   assign 	 DTA=ARITH | oplda;
   assign 	 REF=DTA | opsta;

  // for some reason, asserting estate on cp[8] worked in simulation, but 
  // in real life, single stepping would halt before E state in a two cycle
  // instruction. So that implies an async stop could hold the machine in E state
  // moving estate assert to cp[7] fixed this even though sim says no difference

  //V3 moves all 2 cycle instructions to 1 cycle, 
//   and u21(estate,REF,F,cp[7]);		  // was cp[8] but no REF instruction uses cp[7] for anything
   and u22a(sendir,cp[5], ARITH|((opsta|oplda) & ~ibus[15]));		// ir[15] = 1 for ldax, stax
   assign bus=((opsta|oplda) & cp[5]  & ibus[15])?ibus[11:0]+idxbus:16'bz;      
   and u22b(writemar,REF,cpw[5]);		  


   and u23a(sendacc,REF,cp[6]);	  // These could be ARITH? DTA/REF don't use Z register, but harmless
   and u23b(writeZ,REF,cpw[6]);

//   and u24(msend,DTA,E,cp[5]);
// my design does not use cp5/F so I am going to use that
// cycle to load Acc to Z in case we want it for future
// So in execute phase ACC ->Z 1->Y and no need to do it over
// However, since then I have changed the design so that cp5 is
// a regular execute slot so this is now specific to the INCA, DECA
// NOT and RAL instructions
   and u40a(sendacc,opinc|opdec|opnot|opral|oprar,cp[5]);
   and u40b(writeZ,opinc|opdec|opnot|opral|oprar,cpw[5]);
   
   
   and u25a(sendacc,opsta,cp[8]);
   and u25b(mwrite,opsta,cpw[8]);

   and u26a(msend,oplda,cp[8]);
   and u27a(writeacc,oplda,cpw[8]);

   and u28a(msend,ARITH,cp[7]);
   and u28b(writeY,ARITH,cpw[7]);

   and u29a(sendsum,opadd,cp[8]);
   and u29b(writeacc,opadd,cpw[8]);

   and u29c(senddiff,opsub|opcmp,cp[8]);  
   and u29d(writeacc,opsub,cpw[8]);
	and u29e(writezf, opcmp,  cpw[8]);   
	and u29f(writecf, opcmp, cpw[8]);


   and u30a(sendxor,opxor,cp[8]);
   and u30b(writeacc,opxor,cpw[8]);

   and u31a(sendor,opior,cp[8]);
   and u31b(writeacc,opior,cpw[8]);

   and u32a(sendand,opand,cp[8]);
   and u32b(writeacc,opand,cpw[8]);

// Increment and dec instruction -- we already made cp5/F copy ACC->Z
   // and Y still has 1 in it, so...
// for decrement cp7/F needs to load -1 instead of 1
   and u42a(sendffff,opdec,cp[7]);
   and u42b(writeY,opdec,cpw[7]);

   and u41a(sendsum,opinc|opdec,cp[8]);
   and u41b(writeacc,opinc|opdec,cpw[8]);
   
 
	// skip instructions	(note OK to reuse ALU because C Z and O are latched on specific instructions
	wire [2:0] flags;
	assign flags={cflag, zflag, oflag};
	and u43a(sendpc,opskip,cp[5]);   
	and u43b(writeZ,opskip,cpw[5]);
	and u44a(sendsum,opskip,((ibus[3]?~flags:flags)&ibus[2:0])!=0,cp[6]);
// -- another way:   assign bus=opskip & cp[6]?skippc:16'bz;
	and u44b(writepc,opskip,((ibus[3]?~flags:flags)&ibus[2:0])!=0,cpw[6]);

// Could write skip on sign and get rid of JMA
   and u45a(sendpc,opspn,cp[5]);
	and u45b(writeZ, opspn,cpw[5]);
	and u46a(sendsum,opspn,ibus[0]?~accbus[15]:accbus[15],cp[6]);
// -- another way   assign bus=(opspn & cp[6])?skippc:16'bz;
	and u46b(writepc,opspn,ibus[0]?~accbus[15]:accbus[15],cpw[6]);

// LDI
   and u47a(sendpc,cp[5],opldi);
   and u47b(writemar,cpw[5],opldi);
   and u47c(writeZ,cpw[5],opldi);
   and u48a(sendsum,cp[6],opldi);
   and u48b(writepc,cpw[6],opldi);
   and u49a(msend,opldi,cp[7]);
   and u49b(writeacc,opldi,cpw[7]);

// LDX
   and u50a(sendir,cp[5],opldx);
	and u50aa(sendacc,cp[5],opldxa);
	and u50b(writeidx,cpw[5],opldx|opldxa);


// INCX/DECX
	and u51a(sendidx,cp[5],opidx);
	and u51b(writeZ,cpw[5],opidx);
	and u52a(sendsum,cp[6],opidx,~ibus[0]);
	and u52b(senddiff,cp[6],opidx,ibus[0]);
	and u52c(writeidx,cpw[6],opidx);

// STX
   and u53a(sendidx,cp[5],opstx);
	and u53b(writeacc,cpw[5],opstx);

// JMPA
   and u54a(sendacc,cp[5],opjmpa);
	and u54b(writepc,cpw[5],opjmpa);   

// SWAP
   assign bus[15:8]=opswap&cp[5]?accbus[7:0]:8'bz;
	assign bus[7:0]=opswap&cp[5]?accbus[15:8]:8'bz;
	and u55(writeacc,cpw[5],opswap);

// LDS
   and u56a(sendir,cp[5],oplds);
	and u56b(writesp,cpw[5],oplds);

// PUSH and CALL
   wire pushcall;
	assign pushcall=oppush|opsrj;
	and u57a(sendsp,cp[5],pushcall);
	and u57b(writemar,cpw[5],pushcall);
	and u57c(writeZ,cpw[5],pushcall);
	and u58a(sendacc,cp[6],oppush, ibus[1:0]==2'b00);
	and u58aa(sendidx,cp[6],oppush, ibus[1:0]==2'b10);
   assign bus=(cp[6]&oppush&ibus[1:0]==2'b11)?({13'b0, flags}):16'bz;
	and u58b(sendpc, cp[6], opsrj);
	and u58c(mwrite, cpw[6], pushcall);
	and u59a(senddiff,cp[7], pushcall);
	and u59b(writesp,cpw[7], pushcall);
	and u59c(sendir,cp[8],opsrj);
	and u59d(writepc, cpw[8],opsrj);

// POP and RET

   and u60a(sendsp,cp[5],oppop);
	and u60b(writeZ,cpw[5], oppop);
	and u61a(sendsum,cp[6],oppop);
	and u61b(writesp, cpw[6], oppop);
	and u61c(writemar,cpw[6], oppop);
	and u62a(msend, cp[7], oppop);
	and u62b(writeacc, cpw[7], oppop, ibus[1:0]==2'b00); 
	and u62c(writepc, cpw[7], oppop, ibus[1:0]==2'b01);
	and u62d(writeidx, cpw[7], oppop, ibus[1:0]==2'b10);	
	and u63a(writeflag, cp[7], oppop, ibus[1:0]==2'b11);  // pop flag -- not sure this works?  

 // frame
   and u64a(sendsp,cp[5],opframe);
	and u64b(writeidx,cpw[5],opframe);
   
endmodule
   