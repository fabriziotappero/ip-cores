///////////////////////////////////////////////////////////
//
//    Test fixture for IDT 9Meg Synchronous Burst SRAMs
//              (for 512K x 18 configurations)
//
//////////////////////////////////////////////////////////

`timescale 1ns / 10ps

`define Max 16
`define Max1 8
`define Max2 16

module main;

parameter addr_msb = 18;


/////// Remove comments for specific device under test ////


//////////////////////////////////////////////
//
//Pipelined sync burst SRAMs
//
/////////////////////////////////////////////

/////// 2.5v I/O ////////////
parameter pipe = 1, Tcyc = 7.5, Tsu = 1.5, Tdh = 0.5, Tcd = 4.2, Toe = 4.2; 
          `define device idt71t67802s133
//parameter pipe = 1, Tcyc = 6.7, Tsu = 1.5, Tdh = 0.5, Tcd = 3.8, Toe = 3.8; 
//          `define device idt71t67802s150
//parameter pipe = 1, Tcyc = 6.0, Tsu = 1.5, Tdh = 0.5, Tcd = 3.5, Toe = 3.5; 
//          `define device idt71t67802s166

//////////////////////////////////////////////
//
//Flow-through sync burst SRAMs
//
//////////////////////////////////////////////

/////// 2.5v I/O ////////////
//parameter pipe = 0, Tcyc = 11.5, Tsu = 2.0, Tdh = 0.5, Tcd = 8.5, Toe = 3.5; 
//          `define device idt71t67902s85
//parameter pipe = 0, Tcyc = 10.0, Tsu = 2.0, Tdh = 0.5, Tcd = 8.0, Toe = 3.5; 
//          `define device idt71t67902s80
//parameter pipe = 0, Tcyc = 8.5,  Tsu = 1.5, Tdh = 0.5, Tcd = 7.5, Toe = 3.5; 
//          `define device idt71t67902s75

reg   [addr_msb:0] A;
reg          CLK;
reg          ADSP_;
reg          ADV_;
reg          LBO_;
reg          ADSC_;
reg    [2:1] BW_;
reg          BWE_;
reg          GW_;
reg          CE_;
reg          CS0;
reg          CS1_;
reg          OE_;

reg   [17:0] DataOut;
reg   [17:0] TempReg;

reg   [17:0] DQ;
wire  [15:0] DQbus = {DQ[16:9], DQ[7:0]};
wire  [2:1]  DQPbus = {DQ[17], DQ[8]};
reg   [17:0] Dstore[0:`Max-1];              //temp data store
reg   [17:0] data;
reg   [addr_msb:0] lastaddr;
reg          tempcs1_;
reg          tempcs0;
reg          tempce_;

reg   [17:0] RandomData[0:`Max-1];
reg   [17:0] BurstData[0:`Max-1];

reg  [8*4:1] status;                       //data read pass/fail

//internal

reg check_data_m1, qual_ads;
reg check_data;

integer   i,j,addrb,counter,
          result;

// Output files
initial begin
  $recordfile ("idt_sram_67802.trn");
  $recordvars;

//  $dumpfile ("idt_sram_67802.vcd");
//  $dumpvars;

  result = $fopen("idt_sram.res"); if (result == 0) $finish;
end

always begin
  @(posedge CLK) 
    $fdisplay(result,
      "%b",  ADSC_,
      "%b",  ADSP_,
      "%b",  BWE_,
      "%b",  CE_,
      "%b",  CS0,
      "%b",  CS1_,
      "%b",  LBO_,
      "%b",  OE_,
      "%b",  BW_,  // 2 bits
      "%b",  ADV_,
      "%b ", GW_,
      "%h ", {DQPbus[2], DQbus[15:8], DQPbus[1], DQbus[7:0]},
      "%h ", A,
      "%d", $stime
      );
end

initial begin
  ADSC_ = 1;
  ADSP_ = 1;
  BWE_  = 1;
  CE_   = 0;
  CS0   = 1;
  CS1_  = 0;
  LBO_  = 0;
  OE_   = 1;
  CLK   = 0;
  BW_   = 2'hf;
  ADV_  = 1;
  GW_   = 1;
  counter = 0;

  for (i=0;i<`Max;i=i+1) begin           // Generate random data for testing
    RandomData[i] = $random;
  end

//****************
//disable_ce;
//disable_cs0;

//####
init;
$display($time,"(1)  write        adsp_ = 0");
for(i=0; i<`Max1; i=i+1) begin
write(i,i,0,1,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
end
$display($time,"     read         adsp_ = 0");
for(i=0; i<`Max1; i=i+1) begin
read(i,0,1,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
end
dummy_cyc(1);
$display($time,"                  status = %s",status);
 
//####
init;
$display($time,"(2)  write        adsc_ = 0");
for(i=0; i<`Max1; i=i+1) begin
write(i,i,1,0,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
end
$display($time,"     read         adsc_ = 0");
for(i=0; i<`Max1; i=i+1) begin
read(i,1,0,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(3)  write        adsp_ = 0");
for(i=0; i<`Max1; i=i+1) begin
write(i,i,0,1,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
end
$display($time,"     read         adsp_ = 0 cs1_ = 1 - every other cyc");
for(i=0; i<`Max1; i=i+2) begin
read(i,0,1,0,1,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
read(i+1,0,1,0,0,1);                     //addr,adsp_,adsc_,ce_,cs1_,cs0
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(4)  write/read   adsp_ = 0");
for(i=0; i<`Max1; i=i+1) begin
write(i,i,0,1,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
read(i,0,1,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(5)  write/read   adsc_ = 0");
for(i=0; i<`Max1; i=i+1) begin
write(i,i,1,0,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
read(i,1,0,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
dummy_cyc(1);
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(6)  burst_write  adsp_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_write(i,i,0,1,0,0,0,1,4);          //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0,nburst
end
$display($time,"     burst_read   adsp_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_read(i,0,1,0,0,1,4);               //addr,adsp_,adsc_,ce_,cs1_,cs0,nburst
end
dummy_cyc(1);
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(7)  burst_write  adsc_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_write(i,i,1,0,0,0,0,1,4);          //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0,nburst
end
$display($time,"     burst_read   adsc_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_read(i,1,0,0,0,1,4);               //addr,adsp_,adsc_,ce_,cs1_,cs0,nburst
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(8)  write        adsp_ = 0 cs1_ = 1 - every other cyc");
for(i=0; i<`Max1; i=i+2) begin
write(i,i,0,1,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
write(i+1,9,0,1,0,0,1,1);                //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
end
$display($time,"     read         adsp_ = 0");
for(i=0; i<`Max1; i=i+2) begin
read(i,0,1,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(9)  write        adsp_ = 0 cs0  = 0 - every other cyc");
for(i=0; i<`Max1; i=i+2) begin
write(i,i,0,1,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
write(i+1,9,0,1,0,0,0,0);                //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
end
$display($time,"     read         adsc_ = 0");
for(i=0; i<`Max1; i=i+2) begin
read(i,1,0,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(10) write        adsp_ = 0 ce_  = 1 - every other cyc");
for(i=0; i<`Max1; i=i+2) begin
write(i,i,0,1,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
write(i+1,i,0,1,0,1,0,1);                //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
end
write(i,i,0,1,0,0,0,1);                  //this will write last address to Dstore
$display($time,"     read         adsp_ = 0");
for(i=0; i<`Max1; i=i+2) begin
read(i,0,1,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(11) write        adsc_ = 0 ce_  = 1 - every other cyc");
for(i=0; i<`Max1; i=i+2) begin
write(i,i,1,0,0,0,0,1);                  //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
write(i+1,i+1,1,0,0,1,0,1);              //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
end
write(i,i,1,0,0,0,0,1);                  //this will write last address to Dstore
$display($time,"     read         adsc_ = 0");
for(i=0; i<`Max1; i=i+2) begin
read(i,1,0,0,0,1);                       //addr,adsp_,adsc_,ce_,cs1_,cs0
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(12) burst_write_adv  adsc_ = 0 adv_ = 1 - 2nd cyc");
for(i=0; i<`Max2; i=i+4) begin
burst_write_adv(i,i,1,0,0,0,0,1,1,0);     //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0,adv_,tempcounter
burst_write_adv(i,i,1,0,0,0,0,1,1,1);     
burst_write_adv(i+1,i+1,1,0,0,0,0,1,0,2); 
burst_write_adv(i+2,i+2,1,0,0,0,0,1,0,3); 
burst_write_adv(i+3,i+3,1,0,0,0,0,1,0,4); 
end
$display($time,"     burst_read   adsc_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_read(i,1,0,0,0,1,4);               //addr,adsp_,adsc_,ce_,cs1_,cs0,nburst
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(13) burst_write_adv  adsp_ = 0 adv_ = 1 - 2nd cyc");
for(i=0; i<`Max2; i=i+4) begin
burst_write_adv(i,i,0,1,0,0,0,1,1,0);     //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0,adv_,tempcounter
burst_write_adv(i,i,0,0,0,1,0,1,1,1);     
burst_write_adv(i+1,i+1,0,1,0,0,0,1,0,2); 
burst_write_adv(i+2,i+2,0,1,0,0,0,1,0,3); 
burst_write_adv(i+3,i+3,0,1,0,0,0,1,0,4); 
end
$display($time,"     burst_read   adsc_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_read(i,1,0,0,0,1,4);               //addr,adsp_,adsc_,ce_,cs1_,cs0,nburst
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(14) burst_write  adsp_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_write(i,i,0,1,0,0,0,1,4);          //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0,nburst
end
$display($time,"     burst_read_adv   adsp_ = 0 adv_ = 1 - 3rd cyc");
for(i=0; i<`Max2; i=i+4) begin
burst_read_adv(i,  0,1,0,0,1,1,0);       //addr,adsp_,adsc_,ce_,cs1_,cs0,adv_,tempcounter
burst_read_adv(i+1,1,1,0,0,1,0,1);       
burst_read_adv(i+2,1,1,0,0,1,1,2);      
burst_read_adv(i+3,1,1,0,0,1,0,3);     
end
$display($time,"                  status = %s",status);

//####
init;
$display($time,"(15) burst_write  adsp_ = 0");
for(i=0; i<`Max2; i=i+4) begin
burst_write(i,i,0,1,0,0,0,1,4);          //addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0,nburst
end
$display($time,"     burst_read_adv   adsp_=1/ce_=0 - 2/3 cyc, adsp = 0/ce_=1 - 4/5 cyc");
for(i=0; i<`Max2; i=i+4) begin
burst_read_adv(i,  0,1,0,0,1,1,0);       //addr,adsp_,adsc_,ce_,cs1_,cs0,adv_,tempcounter
burst_read_adv(i+1,1,1,0,0,1,0,1);       
burst_read_adv(i+2,1,1,0,0,1,0,2);       
burst_read_adv(i+3,0,1,1,0,1,0,3);       
burst_read_adv(i,  0,1,1,0,1,0,4);       
end
$display($time,"                  status = %s",status);
//####


@( negedge CLK );
@( negedge CLK );
@( negedge CLK );

//*****************
CE_ = 0;
CS0 = 1;
CS1_ = 0;

  $display($time,,"Simple read/write test");
  for (i=0;i<`Max;i=i+1) begin      // Test straight write/read
    write_random(i, RandomData[i]);
  $display($time,,"Simple read test");
    read_random(i, DataOut, RandomData[i]);
  end

 $display($time,,"CE_ disable - random data");
 read_random(3, DataOut, RandomData[3]);
 disable_ce;
 read_random(7, DataOut, RandomData[7]);
 disable_cs0;
 read_random(2, DataOut, RandomData[2]);
  for (i=0;i<`Max;i=i+1) begin      // Fill RAM with zero's
    write_random(i, 0);
  end

  $display($time,,"Byte mode read/write test - random data");
//  GW_ = 1;                        // Disable global write
//  BWE_  = 0;                      // Enable byte write
  for (i=0;i<`Max;i=i+1) begin    // Test byte write/read
    BW_ = $random;
    TempReg = RandomData[i];
    byte_write_random(i, TempReg);
    if ( BW_[1] == 1 ) TempReg[8:0] = 0;
    if ( BW_[2] == 1 ) TempReg[17:9] = 0;
    read_random(i, DataOut, TempReg);
  end
  BWE_  = 1;                      // Disable byte write


  // Test burst mode write/read
  $display($time,,"Burst mode read/write test - random data");
  for (i=0;i<`Max;i=i+1) begin      // Test byte write/read
      BurstData[i] = RandomData[i];
  end

  GW_ = 0;                       // Enable global write
  for (i=0;i<`Max;i=i+4) begin   // Write data from BurstData buffer
    burst_write_random(i,4); 
  end
  GW_ = 1;                       // Disable global write

  for (i=0;j<`Max;i=i+1) begin   // Clear data buffer
      BurstData[i] = 0;
  end
  
  for (i=0;i<`Max;i=i+4) begin
    burst_read_random(i,4); 
//    for (j=i;j<i+4;j=j+1) begin      // verify read data
//      if ( BurstData[j] != RandomData[j] )
//          $display("%d  Burst error: Addr %h Exp %h Act %h", $stime, j, RandomData[j], BurstData[j]);
//    end
  end
  burst_wrap_random(0);
  disable_ce;
  burst_rd_pipe_random(0,4);

  $finish;
end
/////////////////////////////////////////////////////////////////

always @(posedge CLK) begin
   if ((~ADSC_ | ~ADSP_) & ~CE_ & CS0 & ~CS1_) qual_ads <= #1 1;
   else qual_ads <= #1 0;
   check_data_m1 <= #1 ~ADV_;

   if (pipe == 0) check_data = #1 (qual_ads | ~ADV_);
   else check_data = #1 (qual_ads | check_data_m1);
end

always #(Tcyc/2) CLK = ~CLK;

`device  dut (
    .A        (A), 
    .D        (DQbus), 
    .DP       (DQPbus), 
    .oe_      (OE_),
    .ce_      (CE_),
    .cs0      (CS0),
    .cs1_     (CS1_),
    .lbo_     (LBO_),
    .gw_      (GW_),
    .bwe_     (BWE_),
    .bw2_     (BW_[2]),
    .bw1_     (BW_[1]),
    .adsp_    (ADSP_),
    .adsc_    (ADSC_),
    .adv_     (ADV_),
    .clk      (CLK)
    );

//================ test bench tasks

task disable_ce;
begin
    OE_ = 0;
    if (CLK)
        @( negedge CLK );
    ADSC_ = 0;
    CE_   = 1;
    @( posedge CLK );
    @( negedge CLK );
    ADSC_ = 1;
    CE_   = 0;
end
endtask

task disable_cs0;
begin
    OE_ = 0;
    if (CLK)
        @( negedge CLK );
    ADSP_ = 0;
    CS0   = 0;
    @( posedge CLK );
    @( negedge CLK );
    ADSP_ = 1;
    CS0   = 1;
end
endtask

task dummy_cyc;
input oe;
begin
@(posedge CLK);
  @(negedge CLK);
   #Tcd;
   OE_ = oe;
end
endtask

task init;
begin
  for(i=0; i<`Max2; i=i+1) begin         // fill memory with 0 data
    write(i,0,0,1,0,0,0,1);              // addr,data,adsp_,adsc_,gw_,ce_,cs1_,cs0
    Dstore[i] = 18'hx;                   // fill temp memory with xx data
  end
end
endtask

task read;                   // ADSP|ADSC controlled PL - adsp_/adsc_ 2cycle read
input  [addr_msb:0] addr;    // ADSP|ADSC controlled FT - adsp_/adsc_ 1cycle read
input  adsp_;
input  adsc_;
input  ce_; 
input  cs1_;
input  cs0; 
begin
   @( negedge CLK );
    #(Tcyc/2 - Tsu);
    A     = addr;
    ADV_  = 1;
    GW_   = 1;
    BWE_  = 1;
    ADSP_ = adsp_;
    ADSC_ = adsc_;
    CE_   = ce_;
    CS1_  = cs1_;
    CS0   = cs0;
      assign data = {DQPbus[2], DQbus[15:8], DQPbus[1], DQbus[7:0]};
   @( posedge CLK );           // SRAM latches Address and begins internal read
     tempcs0  <= cs0; tempcs1_  <= cs1_; tempce_  <= ce_;
     lastaddr <= addr;
     A <= #Tdh 19'hz;
     ADSP_ <= #Tdh 1;
     ADSC_ <= #Tdh 1;
     CE_ <= #Tdh 1;
     CS1_<= #Tdh 1;
     CS0 <= #Tdh 0;
     if(pipe == 1)
       OE_ <= #(Tcyc+Tcd-Toe) 0;
     else if(pipe == 0) 
       OE_ <= #(Tcd-Toe) 0;
     if(counter != 0)
       if ( data !== Dstore[lastaddr] ) begin
         if (tempcs0 & ~tempce_ & ~tempcs1_) begin
         status = "FAIL";
            $display("%d Read error: Addr %h Exp %h Act %h", $stime, lastaddr, 
                      Dstore[lastaddr], data);
         end
         end
       else if (tempcs0 & ~tempce_ & ~tempcs1_)
               status = "PASS";
    DQ = 18'hz;
    if(pipe == 1)
      #(Tcyc/2);
    counter = counter+1;
end
endtask

task burst_read;             // ADSP|ADSC controlled - adsp/adsc 3-1-1-1 PL read
input  [addr_msb:0] addr;    //                        adsp/adsc 2-1-1-1 FT read
input  adsp_;
input  adsc_;
input  ce_; 
input  cs1_;
input  cs0; 
input  [3:0] nburst;
integer tempaddr,tempcounter;
begin
tempcounter = 0;
 for (tempaddr=addr; tempaddr<addr+nburst; tempaddr=tempaddr+1) begin
   @( negedge CLK );
   if (tempaddr == addr) begin           // 1st address
      #(Tcyc/2 - Tsu);
      A     = addr;
      GW_   = 1;
      BWE_  = 1;
      ADSP_ = adsp_;
      ADSC_ = adsc_;
      ADV_  = 1;
      CE_   = ce_;
      CS1_  = cs1_;
      CS0   = cs0;
   end
   else begin
      #(Tcyc/2 - Tsu);                  // after 2nd address
      A     = 19'hz;
      ADV_ = 0;  
   end
    assign data = {DQPbus[2], DQbus[15:8], DQPbus[1], DQbus[7:0]};
   @( posedge CLK );      // SRAM latches Address and begins internal read
   lastaddr <= #(Tcyc) tempaddr;
   if (tempaddr == addr) begin           // 1st address
      A <= #Tdh 19'hz;
      ADSP_ <= #Tdh 1;
      ADSC_ <= #Tdh 1;
      CE_   <= #Tdh ~ce_;
      CS1_  <= #Tdh ~cs1_;
      CS0   <= #Tdh ~cs0;
      if(pipe == 1)
        OE_ <= #(Tcyc+Tcd-Toe) 0;
      if(pipe == 0)
        OE_ <= #(Tcd-Toe) 0;
   end
   else begin                            // after 2nd address
      ADV_  <= #Tdh 1;
   end
      if(pipe == 1)
        if(tempcounter > 1 )
          if ( data !== Dstore[lastaddr] ) begin
               status = "FAIL";
               $display("%d Read error: Addr %h Exp %h Act %h", $stime, lastaddr, 
                         Dstore[lastaddr], data);
          end
          else status = "PASS";
      else if(pipe == 0)
        if(tempcounter > 0 )
          if ( data !== Dstore[lastaddr] ) begin
               status = "FAIL";
               $display("%d Read error: Addr %h Exp %h Act %h", $stime, lastaddr, 
                         Dstore[lastaddr], data);
          end
          else status = "PASS";
    DQ = 18'hz;
    #Tdh;
    tempcounter = tempcounter+1;
 end
end
endtask

task burst_read_adv;       // ADSP|ADSC controlled - adsp/adsc 3-1-1-1 PL read
input  [addr_msb:0] addr;        //                        adsp/adsc 2-1-1-1 FT read
input  adsp_;
input  adsc_;
input  ce_; 
input  cs1_;
input  cs0; 
input  adv_;
input  [3:0] tempcounter;
begin
   @( negedge CLK );
   if (tempcounter == 0) begin            // 1st address
      #(Tcyc/2 - Tsu);
      A     = addr;
      GW_   = 1;
      BWE_  = 1;
      ADSP_ = adsp_;
      ADSC_ = adsc_;
      ADV_  = adv_;
      CE_   = ce_;
      CS1_  = cs1_;
      CS0   = cs0;
   end
   else begin
      #(Tcyc/2 - Tsu);                  // after 2nd address
      A     = 19'hz;
      ADSP_ = adsp_;
      ADSC_ = adsc_;
      CE_   = ce_;
      ADV_ = adv_;  
   end
    assign data = {DQPbus[2], DQbus[15:8], DQPbus[1], DQbus[7:0]};
   @( posedge CLK );      // SRAM latches Address and begins internal read
   lastaddr <= #(Tcyc) addr;
   if (tempcounter == 0) begin           // 1st address
      A <= #Tdh 19'hz;
      ADSP_ <= #Tdh ~adsp_;
      ADSC_ <= #Tdh ~adsc_;
      CE_   <= #Tdh ~ce_;
      CS1_  <= #Tdh ~cs1_;
      CS0   <= #Tdh ~cs0;
      if(pipe == 1)
        OE_ <= #(Tcyc+Tcd-Toe) 0;
      if(pipe == 0)
        OE_ <= #(Tcd-Toe) 0;
   end
   else begin                            // after 2nd address
      ADSP_ <= #Tdh ~adsp_;
      ADSC_ <= #Tdh ~adsc_;
      CE_   <= #Tdh ~ce_;
      ADV_  <= #Tdh ~adv_;
   end
      if(pipe == 1)
        if(tempcounter > 1 )
          if ( data !== Dstore[lastaddr] ) begin
               status = "FAIL";
               $display("%d Read error: Addr %h Exp %h Act %h", $stime, lastaddr, 
                         Dstore[lastaddr], data);
          end
          else status = "PASS";
      else if(pipe == 0)
        if(tempcounter > 0 )
          if ( data !== Dstore[lastaddr] ) begin
               status = "FAIL";
               $display("%d Read error: Addr %h Exp %h Act %h", $stime, lastaddr, 
                         Dstore[lastaddr], data);
          end
          else status = "PASS";
    DQ = 18'hz;
end
endtask

task read_random;
input  [addr_msb:0] addr;
output [17:0] data;
input  [17:0] exp;
begin
    if (CLK )
        @( negedge CLK );
//    DQ = 18'hz;
    ADV_  = 1;
    A = addr;
    ADSP_ = 0;
    @( posedge CLK );      // SRAM latches Address and begins internal read
    @( negedge CLK );
    ADSP_ = 1;
    OE_   = 0;
    if (pipe == 1) @( posedge CLK );      // SRAM begins placing data onto bus
    @( posedge CLK );      // Data sampled by reading device
                           // Hopefully the SRAM has an output hold time
    data = {DQPbus[2], DQbus[15:8], DQPbus[1], DQbus[7:0]};
    if ( data !== exp )
        $display("%d Read_random error: Addr %h Exp %h Act %h", $stime, addr, exp, data);
    @( negedge CLK ); 
    OE_   = 1;

end
endtask

task burst_read_random;   
input  [addr_msb:0] addr;
input  [17:0] n;
integer       i;
begin
    DQ = 18'hz;
    if ( CLK )
        @( negedge CLK );
    #1 A = addr;
       ADSP_ = 0;
    @( posedge CLK );           // Address latched by SRAM, begins internal read
    #(Tcyc/2) ADSP_ = 1;       // SRAM starts driving bus (flow-through)
    #1 OE_   = 0;
       ADV_  = 0;
    if (pipe == 1) @(posedge CLK); //SRAM starts driving bus (pipelined)
 
    for (i=addr;i<addr+n;i=i) begin
       @( posedge CLK ) begin
          if (check_data == 1) 
BurstData[i] = {DQPbus[2], DQbus[15:8], DQPbus[1], DQbus[7:0]};
          if ( BurstData[i] !== RandomData[i] && check_data == 1 )
             $display("%d task burst_read_random read error: Addr %h Exp %h Act %h", $stime, i, RandomData[i], BurstData[i]);
       end
       @( negedge CLK );
       if (check_data) i=i+1;
       if ( ($random & 3) === 2'b11 ) // suspend burst 25% of the time
           ADV_ = 1;
       else begin
           ADV_ = 0;
       end
    end

    OE_   = 1;
    ADV_  = 1;
end
endtask

task burst_wrap_random; //checks burst counter wrap-around
input  [addr_msb:0] addr;
integer i,j;
begin
    DQ = 18'hz;
    if ( CLK )
       @( negedge CLK );
    #1 A = addr;
       ADSP_ = 0;
    @(posedge CLK);           // Address latched by SRAM, begins internal read
    #(Tcyc/2) ADSP_ = 1;
    #1 OE_   = 0;
       ADV_  = 0;
    if (pipe == 1) @(posedge CLK);
 
   for (i=0;i<2;i=i+1) begin
      for (j=0;j<4;j=j+1) begin
         @( posedge CLK ) begin
            if (check_data == 1) 
BurstData[j] = {DQPbus[2], DQbus[15:8], DQPbus[1], DQbus[7:0]};
            if ( BurstData[j] !== RandomData[j] && check_data == 1 )
               $display("%d task burst_wrap_random read error: Addr %h Exp %h Act %h", $stime, i, RandomData[i], BurstData[i]);
         end
      end
   end
   #1 OE_   = 1;
      ADV_  = 1;
end
endtask

task burst_rd_pipe_random;
input  [addr_msb:0] addr1;
input  [addr_msb:0] addr2;

integer       i;

begin
   DQ = 18'hz;
   for (i=0;i<12;i=i+1) begin
      @(posedge CLK);

      if (i == 0 | i == 4) begin
         #(Tcyc/2) ADSP_ <= 0;
         if (i == 0) A = addr1;       
         if (i == 4) A = addr2;
      end   
      else #(Tcyc/2) ADSP_ <= 1;

      if (i >= 1 && i <=10) OE_ = 0;
      else OE_ = 1;

      if (i >= 1 && i <= 3 || i >= 5 && i<= 7) ADV_ <= 0;
      else ADV_ <= 1;
   end
end   
endtask

task write;        //ADSP|ADSC controlled PL|FT - adsp 2cycle/adsc 1cycle write   
input  [addr_msb:0] addr;
input  [17:0] data;
input  adsp_;  
input  adsc_; 
input  gw_;  
input  ce_; 
input  cs1_;
input  cs0; 
begin
   @( negedge CLK );
    A <= #(Tcyc/2-Tsu) addr;
    ADSP_ <= #(Tcyc/2-Tsu) adsp_;
    ADSC_ <= #(Tcyc/2-Tsu) adsc_;
    DQ = 18'hz;
    ADV_  = 1;
    CE_   <= #(Tcyc/2-Tsu) ce_;
    CS1_  <= #(Tcyc/2-Tsu) cs1_;
    CS0   <= #(Tcyc/2-Tsu) cs0;
    OE_   <= #(Tcyc/2-Tsu) 1;
    if (adsp_ == 0)                               // if adsp_ controlled
      GW_ = ~gw_;    
    else if (adsp_ == 1 & adsc_ == 0) begin       // if adsc_ controlled
      #(Tcyc/2-Tsu)
      GW_ = gw_;
      DQ  = data;
        if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
          Dstore[addr] = data;
    end
    else
      DQ  = 18'hz;
   @( posedge CLK );
    counter = 0;
    A <= #Tdh 19'hz;
    ADSP_ <= #Tdh 1;
    ADSC_ <= #Tdh 1;
//    OE_   <= #Tdh 1;
    CE_   <= #Tdh 1;
    CS1_  <= #Tdh 1;
    CS0   <= #Tdh 0;
    if (adsp_ == 0) begin                         // if adsp controlled
      #(Tcyc - Tsu);
      GW_ = gw_;
      DQ = data;
//$display($time, "DQ    %h data  %d  addr %d", DQ, data, addr);
      GW_ <= #(Tsu + Tdh) ~gw_;
      DQ  <= #(Tsu + Tdh) 18'hz;
        if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
          Dstore[addr] = data;
    end
    else if (adsp_ == 1 & adsc_ == 0) begin       // if adsc_ controlled
      GW_ <= #Tdh ~gw_;
      DQ  <= #Tdh 18'hz;
    end 
    else
      DQ  = 18'hz;
end
endtask

task burst_write;     //ADSP&ADSC controlled PL|FT - adsp_ 2-1-1-1/adsc_ 1-1-1-1 write   
input  [addr_msb:0] addr;
input  [17:0] data;
input  adsp_;
input  adsc_;
input  gw_;
input  ce_; 
input  cs1_;
input  cs0; 
input  [3:0] nburst;
integer tempaddr,tempcounter;
begin
tempcounter = 0;
 for (tempaddr=addr; tempaddr<addr+nburst; tempaddr=tempaddr+1) begin
   @( negedge CLK );
    DQ = 18'hz;
    if (tempaddr == addr) begin
        A <= #(Tcyc/2-Tsu) addr;
        ADSP_ <= #(Tcyc/2-Tsu) adsp_;
        ADSC_ <= #(Tcyc/2-Tsu) adsc_;
        ADV_   = 1;
        CE_   <= #(Tcyc/2-Tsu) ce_;
        CS1_  <= #(Tcyc/2-Tsu) cs1_;
        CS0   <= #(Tcyc/2-Tsu) cs0;
         if (adsp_ == 0) begin                        // if adsp_ controlled
           ADV_ = 1;
           GW_ = ~gw_;    
         end
         else if (adsp_ == 1 & adsc_ == 0) begin       // if adsc_ controlled
           #(Tcyc/2-Tsu);
           GW_ = gw_;
           DQ  = data;
           if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
             Dstore[tempaddr] = data;
         end
         else
           DQ  = 18'hz;
    end
    else begin                                       // burst after 2nd cycle
        ADSP_ = 1;
        ADSC_ = 1;
        #(Tcyc/2-Tsu);
        GW_ = gw_;
        data = data+1;
        DQ  = data;
        if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
          Dstore[tempaddr] = data;
       if (tempcounter == 0) ADV_ = 1;
       else ADV_ = 0;
    end 
   @( posedge CLK );
    counter = 0;
    if (tempaddr == addr) begin
        A <= #Tdh 19'hz;
        ADSP_ <= #Tdh 1;
        ADSC_ <= #Tdh 1;
        OE_   <= #Tdh 1;
        CE_   <= #Tdh ~ce_;
        CS1_  <= #Tdh ~cs1_;
        CS0   <= #Tdh ~cs0;
         if (adsp_ == 0) begin                       // if adsp_ controlled
           #(Tcyc - Tsu);
           GW_ = gw_;
           DQ = data;
           ADV_ <= #(Tsu + Tdh) 1;
           GW_  <= #(Tsu + Tdh) ~gw_;
           DQ   <= #(Tsu + Tdh) 18'hz;
           if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
             Dstore[tempaddr] = data;
          if (tempcounter == 0) ADV_ = 1;
          else ADV_ = 0;
        end
        else if (adsp_ == 1 & adsc_ == 0) begin       // if adsc_ controlled
           ADV_ <= #Tdh 1;
           GW_  <= #Tdh ~gw_;
           DQ   <= #Tdh 18'hz;
        end 
        else
           DQ  = 18'hz;
    end
    else begin                                        // burst after 2nd cycle
        ADV_ <= #Tdh 1;
        GW_  <= #Tdh ~gw_;
        DQ   <= #Tdh 18'hz;
    end
        tempcounter = tempcounter+1;
 end 
end
endtask

task burst_write_adv;   //ADSP|ADSC controlled PL|FT - adsp_ 2-1-1-1/adsc_ 1-1-1-1 write
input  [addr_msb:0] addr;
input  [17:0] data;
input  adsp_;
input  adsc_;
input  gw_;
input  ce_; 
input  cs1_;
input  cs0; 
input  adv_;
input  [3:0] tempcounter;
begin
   @( negedge CLK );
    DQ = 18'hz;
    if (tempcounter == 0) begin
        A <= #(Tcyc/2-Tsu) addr;
        ADSP_ <= #(Tcyc/2-Tsu) adsp_;
        ADSC_ <= #(Tcyc/2-Tsu) adsc_;
        ADV_   = adv_;
        CE_   <= #(Tcyc/2-Tsu) ce_;
        CS1_  <= #(Tcyc/2-Tsu) cs1_;
        CS0   <= #(Tcyc/2-Tsu) cs0;
         if (adsp_ == 0) begin                        // if adsp_ controlled
           ADV_ = adv_;
           GW_ = ~gw_;    
         end
         else if (adsp_ == 1 & adsc_ == 0) begin       // if adsc_ controlled
           #(Tcyc/2-Tsu);
           GW_ = gw_;
           DQ  = data;
           if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
             Dstore[addr] = data;
         end
         else
           DQ  = 18'hz;
    end
    else begin                                       // burst after 2nd cycle
        ADSP_ = 1;
        ADSC_ = 1;
        #(Tcyc/2-Tsu);
        GW_ = gw_;
        ADV_ = adv_;
        DQ  = data;
        if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
          Dstore[addr] = data;
    end 
   @( posedge CLK );
    counter = 0;
    if (tempcounter == 0) begin
        A <= #Tdh 19'hz;
        ADSP_ <= #Tdh 1;
        ADSC_ <= #Tdh 1;
        OE_   <= #Tdh 1;
        CE_   <= #Tdh ~ce_;
        CS1_  <= #Tdh ~cs1_;
        CS0   <= #Tdh ~cs0;
         if (adsp_ == 0) begin                       // if adsp_ controlled
           #(Tcyc - Tsu);
           GW_ = gw_;
           DQ = data;
           ADV_ <= #(Tsu + Tdh) ~adv_;
           GW_  <= #(Tsu + Tdh) ~gw_;
           DQ   <= #(Tsu + Tdh) 18'hz;
           if (cs1_ == 0 & cs0 == 1 & ce_ == 0)
             Dstore[addr] = data;
           ADV_ = adv_;
        end
        else if (adsp_ == 1 & adsc_ == 0) begin       // if adsc_ controlled
           ADV_ <= #Tdh 1;
           GW_  <= #Tdh ~gw_;
           DQ   <= #Tdh 18'hz;
        end 
        else
           DQ  = 18'hz;
    end
    else begin                                        // burst after 2nd cycle
        ADV_ <= #Tdh 1;
        GW_  <= #Tdh ~gw_;
        DQ   <= #Tdh 18'hz;
    end
end
endtask

task write_random;
input  [addr_msb:0] addr;
input  [17:0] data;
begin
    if ( CLK )
        @( negedge CLK ); 
    OE_ = 1;
    ADV_  = 1;
    A = addr;
    ADSP_ = 0;
    @( negedge CLK );
    ADSP_ = 1;
    GW_ = 0;
    #(Tcyc/2-Tsu) DQ = data;
    @( posedge CLK );
    #Tdh
    DQ = 18'hz;
    @( negedge CLK );
    GW_ = 1;
end
endtask

task burst_write_random;
input  [addr_msb:0] addr;
input  [17:0] n;
integer       i;
begin
    if ( CLK )
        @( negedge CLK );
    #1 A = addr;
       ADSP_ = 0;
    for (i=addr;i<addr+n;i=i+1) begin
        @( negedge CLK );
        ADSP_ = 1;
        if (addr!=i) ADV_  = 0;
        #(Tcyc/2-Tsu) DQ = BurstData[i];
        @( posedge CLK );
    end
    @( negedge CLK );
    ADV_  = 1;
end
endtask

task byte_write_random;
input  [addr_msb:0] addr;
input  [17:0] data;
begin
    if ( CLK )
        @( negedge CLK );
    ADV_  = 1;
    A = addr;
    ADSP_ = 0;
    @( negedge CLK );
    ADSP_ = 1;
    BWE_ = 0;
    #(Tcyc/2-Tsu) DQ = data;
    @( posedge CLK );
    #Tdh
    DQ = 18'hz;
    @( negedge CLK );
    BWE_ = 1;
end
endtask

endmodule

