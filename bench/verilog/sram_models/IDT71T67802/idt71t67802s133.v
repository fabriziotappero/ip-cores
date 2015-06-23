/*******************************************************************************
 *   Copyright 1999 Integrated Device Technology, Inc.
 *   All right reserved.
 *
 *   This program is proprietary and confidential information of
 *   IDT Corp. and may be used and disclosed only as authorized
 *   in a license agreement controlling such use and disclosure. 
 *
 *   IDT reserves the right to make any changes to
 *   the product herein to improve function or design.
 *   IDT does not assume any liability arising out of     
 *   the application or use of the product herein.
 *
 *   WARNING: The unlicensed shipping, mailing, or carring of this
 *   technical data outside the United States, or the unlicensed
 *   disclosure, by whatever means, through visits abroad, or the
 *   unlicensed disclosure to foreign national in the United States,
 *   may violate the United States criminal law.
 *
 *   File Name                 : idt71t67802s133.v
 *   Product                   : IDT71T67802
 *   Function                  : 512Kx18 pipeline burst Static RAM
 *   Simulation Tool/Version   : Verilog-XL 2.5
 *   Revision                  : rev00
 *   Date                      : 23/03/00
 *      
 ******************************************************************************/
      
/*******************************************************************************
 * Module Name: idt71t67802s133
 *
 * Notes                     : This model is believed to be functionally
 *                             accurate.  Please direct any inquiries to
 *                             IDT SRAM Applications at: sramhelp@idt.com
 *                               
 *******************************************************************************/
`timescale 1ns/10ps

module  idt71t67802s133(A, D, DP, oe_, ce_, cs0, cs1_, lbo_, 
                      gw_, bwe_, bw2_, bw1_, adsp_, adsc_, adv_, clk);
initial
begin
   $write("\n********************************************************\n");
   $write("   idt71t67802s133			                     \n");
   $write("   Rev: 01    July '99                                    \n"); 
   $write("   copyright 1997,1998,1999 by IDT, Inc.                  \n");
   $write("**********************************************************\n");
end

parameter addr_msb = 18;
parameter mem_top = 524287;

parameter regdelay = 1;

inout [15:0] D;
inout [1:0] DP;
input [addr_msb:0] A;
input oe_, ce_, cs0, cs1_, lbo_, gw_, bwe_, bw2_, bw1_,
      adsp_, adsc_, adv_, clk;

//internal registers for data, address, burst counter

reg [15:0] din, dout;
reg [1:0] dpin, dpout;
reg [addr_msb:0] reg_addr;
reg [1:0] brst_cnt;

wire[addr_msb:0] m_ad;
wire[15:0] data_out;
wire[1:0] dp_out;

reg wr_b1_, wr_b2_, deselr, deselrr; 

wire check_data =  (~adsc_ & adsp_ & ~ce_ & cs0 & ~cs1_ 
                           & (~gw_ | ~bwe_ & (~bw1_ | ~bw2_)))
                 | (~deselr & adsc_ & (adsp_ | ce_) 
                            & (~gw_ | ~bwe_ & (~bw1_ | ~bw2_)));

wire check_addr =   (~adsp_ & ~ce_ & cs0 & ~cs1_)
                  | ( adsp_ & ~adsc_ & ~ce_ & cs0 & ~cs1_);

specify
specparam

//Clock Parameters
   tCYC  = 7.5, //clock cycle time
   tCH   = 3,   //clock high time
   tCL   = 3,   //clock low time
//Output Parameters
   tCD   = 4.2, //clk to data
   tCDC  = 1.5, //output hold from clock
   tCLZ  = 0,   //CLK to output Low-Z
   tCHZ  = 4.2, //CLK to output Hi-Z
   tOE   = 4.2, //OE to output valid
   tOLZ  = 0,   //OE to output Hi-Z
   tOHZ  = 4.2, //OE to output Hi-Z
//Set up times   
   tSA   = 1.5, //address set-up
   tSS   = 1.5, //address status set-up
   tSD   = 1.5, //data set-up
   tSW   = 1.5, //write set-up
   tSAV  = 1.5, //address advance set-up
   tSC   = 1.5, //chip enable and chip select set-up
//Hold times
   tHA   = 0.5, //Address hold
   tHS   = 0.5, //address status hold
   tHD   = 0.5, //data hold
   tHW   = 0.5, //write hold
   tHAV  = 0.5, //address advance hold
   tHC   = 0.5; //chip enable and chip select hold

   (oe_ *> D) = (tOE,tOE,tOHZ,tOLZ,tOHZ,tOLZ); //(01,10,0z,z1,1z,z0)
   (clk *> D) = (tCD,tCD,tCHZ,tCLZ,tCHZ,tCLZ); //(01,10,0z,z1,1z,z0)

   (oe_ *> DP) = (tOE,tOE,tOHZ,tOLZ,tOHZ,tOLZ); //(01,10,0z,z1,1z,z0)
   (clk *> DP) = (tCD,tCD,tCHZ,tCLZ,tCHZ,tCLZ); //(01,10,0z,z1,1z,z0)

//timing checks

   $period(posedge clk, tCYC );
   $width (posedge clk, tCH );
   $width (negedge clk, tCL );

   $setuphold(posedge clk, adsp_, tSS, tHS);
   $setuphold(posedge clk, adsc_, tSS, tHS);
   $setuphold(posedge clk, adv_, tSAV, tHAV);
   $setuphold(posedge clk, gw_, tSW, tHW);
   $setuphold(posedge clk, bwe_, tSW, tHW);
   $setuphold(posedge clk, bw1_, tSW, tHW);
   $setuphold(posedge clk, bw2_, tSW, tHW);
   $setuphold(posedge clk, ce_, tSC, tHC);
   $setuphold(posedge clk, cs0, tSC, tHC);
   $setuphold(posedge clk, cs1_, tSC, tHC);
   
   $setuphold(posedge clk &&& check_addr, A, tSA, tHA);
   $setuphold(posedge clk &&& check_data, D, tSD, tHD);
   $setuphold(posedge clk &&& check_data, DP, tSD, tHD);

endspecify

//////////////memory array//////////////////////////////////////////////

reg [7:0] memb1[0:mem_top];
reg [7:0] memb2[0:mem_top];

reg memb1p[0:mem_top], memb2p[0:mem_top];

wire doe, baddr1, baddr0, dsel;

task mem_fill;
input	x;

integer		a, n, x;

begin

a=0;
for(n=0;n<x;n=n+1)
   begin
	memb1[n] = a[7:0];
	a=a+1;
	memb2[n] = a[7:0];
	a=a+1;
   end

end
endtask

/////////////////////////////////////////////////////////////////////////
//
//Output buffers: using a bufif1 has the same effect as...
//
//	assign D = doe ? data_out : 32'hz;
//	
//It was coded this way to support SPECIFY delays in the specparam section.
//
/////////////////////////////////////////////////////////////////////////

bufif1 (D[0],data_out[0],doe);
bufif1 (D[1],data_out[1],doe);
bufif1 (D[2],data_out[2],doe);
bufif1 (D[3],data_out[3],doe);
bufif1 (D[4],data_out[4],doe);
bufif1 (D[5],data_out[5],doe);
bufif1 (D[6],data_out[6],doe);
bufif1 (D[7],data_out[7],doe);
bufif1 (DP[0], dp_out[0],doe);

bufif1 (D[8],data_out[8],doe);
bufif1 (D[9],data_out[9],doe);
bufif1 (D[10],data_out[10],doe);
bufif1 (D[11],data_out[11],doe);
bufif1 (D[12],data_out[12],doe);
bufif1 (D[13],data_out[13],doe);
bufif1 (D[14],data_out[14],doe);
bufif1 (D[15],data_out[15],doe);
bufif1 (DP[1], dp_out[1],doe);

assign doe = ~deselr & ~deselrr & ~oe_ & wr_b1_ & wr_b2_ ; 

assign dsel = (ce_ | ~cs0 | cs1_);

always @(posedge clk)
begin
   if ( ~adsc_ || ( ~adsp_ && ~ce_ ))
     deselr <=  dsel;
end

always @(posedge clk)
begin
   deselrr <= deselr;
end

/////////////////////////////////////////////////////////////////////////
//
//write enable generation
//
/////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin
   if (  (~adsc_ & adsp_ & ~ce_ & cs0 & ~cs1_ & (~gw_ | ~bwe_ & ~bw1_))
       | (~deselr & adsc_ & (adsp_ | ce_) & (~gw_ | ~bwe_ & ~bw1_)))
      wr_b1_ <= 0;
   else wr_b1_ <= 1;
   if (  (~adsc_ & adsp_ & ~ce_ & cs0 & ~cs1_ & (~gw_ | ~bwe_ & ~bw2_))
       | (~deselr & adsc_ & (adsp_ | ce_) & (~gw_ | ~bwe_ & ~bw2_)))
      wr_b2_ <= 0;
   else wr_b2_ <= 1;
end

/////////////////////////////////////////////////////////////////////////
//
//input address register
//
/////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin
   if (  (~adsp_ & ~ce_ & cs0 & ~cs1_)
       | ( adsp_ & ~adsc_ & ~ce_ & cs0 & ~cs1_)) reg_addr[addr_msb:0] <= A[addr_msb:0];
end

/////////////////////////////////////////////////////////////////////////
//
// burst counter
//
/////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin
   if (lbo_ & (  (~adsp_ & ~ce_ & cs0 & ~cs1_)
               | ( adsp_ & ~adsc_ & ~ce_ & cs0 & ~cs1_))) brst_cnt <= 0;
   else if (~lbo_ & (  (~adsp_ & ~ce_ & cs0 & ~cs1_)
                     | ( adsp_ & ~adsc_ & ~ce_ & cs0 & ~cs1_))) brst_cnt <= A[1:0];
   else if ((adsp_ | ce_) & adsc_ & ~adv_) brst_cnt <= brst_cnt + 1;
end

//////////////////////////////////////////////////////////////////////////
//
//determine the memory address
//
//////////////////////////////////////////////////////////////////////////

assign baddr1 = lbo_ ? (brst_cnt[1] ^ reg_addr[1]) : brst_cnt[1];
assign baddr0 = lbo_ ? (brst_cnt[0] ^ reg_addr[0]) : brst_cnt[0];

assign #regdelay m_ad[addr_msb:0] = {reg_addr[addr_msb:2], baddr1, baddr0};

//////////////////////////////////////////////////////////////////////////
//
//data output register
//
//////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin
    dout[15:8]  <= memb2[m_ad];
    dpout[1]    <= memb2p[m_ad];

    dout[7:0]   <= memb1[m_ad];
    dpout[0]    <= memb1p[m_ad];
end

assign data_out = dout;
assign dp_out = dpout;

//////////////////////////////////////////////////////////////////////////
//
//data input register
//
//////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin
   din  <= #regdelay D;
   dpin <= #regdelay DP;
end

//////////////////////////////////////////////////////////////////////////
//
// write to ram
//
//////////////////////////////////////////////////////////////////////////

wire #1 wrb1 = ~wr_b1_ & ~clk;
wire #1 wrb2 = ~wr_b2_ & ~clk;

always @(clk)
begin
   if (wrb1) begin
      memb1[m_ad]  = din[7:0];
      memb1p[m_ad] = dpin[0];
   end
   if (wrb2) begin
      memb2[m_ad]  = din[15:8];
      memb2p[m_ad] = dpin[1];
   end
end

endmodule
