/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The request crossbar in the VC allocator of VC routers. 
 
 History:
 04/04/2010  Initial version. <wsong83@gmail.com>
 01/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module rcb_vc (/*AUTOARG*/
   // Outputs
   ro, srt, nrt, lrt, wrt, ert, wctla, ectla, lctla, sctla, nctla,
   // Inputs
   ri, go, wctl, ectl, lctl, sctl, nctl
   );

   parameter VCN = 2;		// the number of VCs per direction

   input [4:0][VCN-1:0][1:0] ri; // the request input from all inputs
   output [4:0][VCN-1:0]     ro; // the request output to all output port arbiters
   input [4:0][VCN-1:0]      go; // the granted VC info from all output port arbiters
   output [VCN-1:0][3:0]     srt, nrt, lrt; // routing guide to all input ports
   output [VCN-1:0][1:0]     wrt, ert;
   input [VCN*4*VCN-1:0]     wctl, ectl, lctl; // the configuration from VCA
   input [VCN*2*VCN-1:0]     sctl, nctl;
   output [VCN*4*VCN-1:0]    wctla, ectla, lctla; // the ack to VCA, fire when the frame is sent
   output [VCN*2*VCN-1:0]    sctla, nctla;
     

   wire [VCN*4*VCN-1:0][1:0] wri, eri, lri;
   wire [VCN*4*VCN-1:0]      wgi, wgo, wro, egi, ego, ero, lgi, lgo, lro;
   wire [VCN*2*VCN-1:0][1:0] sri, nri;
   wire [VCN*2*VCN-1:0]      sgi, sgo, sro, ngi, ngo, nro;
   wire [4*VCN*VCN-1:0]      wgis, egis, lgis;
   wire [2*VCN*VCN-1:0]      sgis, ngis;     
   
   genvar 		  i,j;
 
   generate
      for(i=0; i<VCN; i++) begin:RI
	 // shuffle the input requests to all output ports
	 for(j=0; j<VCN; j++) begin: J
	    assign sri[i*2*VCN+0*VCN+j] = ri[2][j];
	    assign sri[i*2*VCN+1*VCN+j] = ri[4][j];
	    assign wri[i*4*VCN+0*VCN+j] = ri[0][j];
	    assign wri[i*4*VCN+1*VCN+j] = ri[2][j];
	    assign wri[i*4*VCN+2*VCN+j] = ri[3][j];
	    assign wri[i*4*VCN+3*VCN+j] = ri[4][j];
	    assign nri[i*2*VCN+0*VCN+j] = ri[0][j];
	    assign nri[i*2*VCN+1*VCN+j] = ri[4][j];
	    assign eri[i*4*VCN+0*VCN+j] = ri[0][j];
	    assign eri[i*4*VCN+1*VCN+j] = ri[1][j];
	    assign eri[i*4*VCN+2*VCN+j] = ri[2][j];
	    assign eri[i*4*VCN+3*VCN+j] = ri[4][j];
	    assign lri[i*4*VCN+0*VCN+j] = ri[0][j];
	    assign lri[i*4*VCN+1*VCN+j] = ri[1][j];
	    assign lri[i*4*VCN+2*VCN+j] = ri[2][j];
	    assign lri[i*4*VCN+3*VCN+j] = ri[3][j];
	 end

	 // generate the requests to output port arbiters
	 assign ro[0][i] = |sro[i*2*VCN +: 2*VCN];
	 assign ro[1][i] = |wro[i*4*VCN +: 4*VCN];
	 assign ro[2][i] = |nro[i*2*VCN +: 2*VCN];
	 assign ro[3][i] = |ero[i*4*VCN +: 4*VCN];
	 assign ro[4][i] = |lro[i*4*VCN +: 4*VCN];

	 // demux to duplicate the grant to all input ports
	 assign sgo[i*2*VCN +: 2*VCN] = {2*VCN{go[0][i]}};
	 assign wgo[i*4*VCN +: 4*VCN] = {4*VCN{go[1][i]}};
	 assign ngo[i*2*VCN +: 2*VCN] = {2*VCN{go[2][i]}};
	 assign ego[i*4*VCN +: 4*VCN] = {4*VCN{go[3][i]}};
	 assign lgo[i*4*VCN +: 4*VCN] = {4*VCN{go[4][i]}};

	 // generate the routing guide from output grants (sgo -- lgo)
	 assign srt[i] = {|lgis[(0*VCN+i)*VCN +: VCN], |egis[(0*VCN+i)*VCN +: VCN], |ngis[(0*VCN+i)*VCN +: VCN], |wgis[(0*VCN+i)*VCN +: VCN]};
	 assign wrt[i] = {|lgis[(1*VCN+i)*VCN +: VCN], |egis[(1*VCN+i)*VCN +: VCN]};
	 assign nrt[i] = {|lgis[(2*VCN+i)*VCN +: VCN], |egis[(2*VCN+i)*VCN +: VCN], |wgis[(1*VCN+i)*VCN +: VCN], |sgis[(0*VCN+i)*VCN +: VCN]};
	 assign ert[i] = {|lgis[(3*VCN+i)*VCN +: VCN], |wgis[(2*VCN+i)*VCN +: VCN]};
	 assign lrt[i] = {|egis[(3*VCN+i)*VCN +: VCN], |ngis[(1*VCN+i)*VCN +: VCN], |wgis[(3*VCN+i)*VCN +: VCN], |sgis[(1*VCN+i)*VCN +: VCN]};

	 // part of the routing guide process
	 for(j=0; j<4*VCN; j++) begin:SB
	    assign wgis[j*VCN+i] = wgi[i*4*VCN+j];
	    assign egis[j*VCN+i] = egi[i*4*VCN+j];
	    assign lgis[j*VCN+i] = lgi[i*4*VCN+j];
	 end

	 for(j=0; j<2*VCN; j++) begin:SL
	    assign sgis[j*VCN+i] = sgi[i*2*VCN+j];
	    assign ngis[j*VCN+i] = ngi[i*2*VCN+j];
	 end
      end

      // cross points
      for(i=0; i<VCN*4*VCN; i++) begin:BB
	 RCBB W (.ri(wri[i]), .ro(wro[i]), .go(wgo[i]), .gi(wgi[i]), .ctl(wctl[i]), .ctla(wctla[i]));
	 RCBB E (.ri(eri[i]), .ro(ero[i]), .go(ego[i]), .gi(egi[i]), .ctl(ectl[i]), .ctla(ectla[i]));
	 RCBB L (.ri(lri[i]), .ro(lro[i]), .go(lgo[i]), .gi(lgi[i]), .ctl(lctl[i]), .ctla(lctla[i]));	 
      end
      for(i=0; i<VCN*2*VCN; i++) begin:BL
	 RCBB S (.ri(sri[i]), .ro(sro[i]), .go(sgo[i]), .gi(sgi[i]), .ctl(sctl[i]), .ctla(sctla[i]));
	 RCBB N (.ri(nri[i]), .ro(nro[i]), .go(ngo[i]), .gi(ngi[i]), .ctl(nctl[i]), .ctla(nctla[i]));
      end
   endgenerate

endmodule // rcb_vc

// Request CrossBar cross point Block
module RCBB (ri, ro, go, gi, ctl, ctla);
   input [1:0] ri;		// requests from input ports (0: data and head, 1: eof)
   output      ro;		// requests to output ports
   input       go;		// grant from output ports
   output      gi;		// grant to input ports, later translated into routing guide
   input       ctl;		// configuration from VCA
   output      ctla;		// configuration ack to VCA, fire after ri[1] fires

   wire [1:0]  m;
   

   c2  I0 (.a0(ri[1]), .a1(ctl), .q(m[1]));
   and I1 ( m[0], ri[0], ctl);
   or  I2 ( ro, m[0], m[1]);
   c2  I3 ( .a0(ro), .a1(go), .q(gi));
   c2  IA ( .a0(m[1]), .a1(go), .q(ctla));
   
endmodule // RCBB


