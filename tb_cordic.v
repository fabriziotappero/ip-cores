`timescale 1ns/1ns
/*
                CORDIC testbench
                
    This testbench assumes the default settings for `defines
    in the cordic.v file.  If you change any of the defaults
    you may have to make modifications to this file as well.
                
    This testbench uses `defines from the cordic.v file
    make sure you have the `include path set correctly for your
    environment.
*/
`include "cordic.v"
module tb ();

  wire [`XY_BITS:0]    x_o,y_o;
  wire [`THETA_BITS:0] theta_o;
  reg  [`XY_BITS:0]    x_i,y_i;
  reg  [`THETA_BITS:0] theta_i;  // angle in radians
  reg  clock,reset;
  reg init;
  
cordic UUT (.clk(clock),.rst(reset),
`ifdef ITERATE
         .init(init),
`endif
          .x_i(x_i),.y_i(y_i),.theta_i(theta_i),
          .x_o(x_o),.y_o(y_o),.theta_o(theta_o));

  integer i,j,k;
  real a_i,a_o,a_e;
  real rx,ry,rex,rey;
  
  reg signed [`XY_BITS:0] ex,ey;

  reg signed [16:0] x [90:0];
  reg signed [16:0] y [90:0];
  reg signed [16:0] z [90:0];
  
  task show_vector_results;
    input integer j;
    input [`THETA_BITS:0] theta;
    begin
      a_i = (j * 3.14) / 180;
      a_o = theta;
      a_o = a_o / 32768;
      if (a_o > a_i) a_e = a_o - a_i; else a_e = a_i - a_o;
      if (a_e > 0.001)
        $display("angle %f computed %f  error %f",a_i,a_o,a_o - a_i);
      else
        $display("angle %f computed %f",a_i,a_o);
    end
  endtask
  
  task show_rotate_results;
    input integer j;
    input [`XY_BITS:0] lx;
    input [`XY_BITS:0] ly;
    begin
      rx = lx;// / 65535;
      ry = ly;// / 65535;
      rx = rx / 32768; //65535;
      ry = ry / 32768; //65535;
      if (lx > x[j]) ex = lx - x[j]; else ex = x[j] - lx;
      if (ly > y[j]) ey = ly - y[j]; else ey = y[j] - ly;
      if (ex > 10 || ey > 10)
        $display("Angle: %d  sin = %f  cos = %f        errors %d %d",j,ry,rx,ey,ex);    
      else
        $display("Angle: %d  sin = %f  cos = %f",j,ry,rx);    
    end
  endtask
  
  task show_results;
    input integer j;
    input [`XY_BITS:0] lx;
    input [`XY_BITS:0] ly;
    input [`THETA_BITS:0] ltheta;
    begin
`ifdef VECTOR
      show_vector_results(j,ltheta);
`endif
`ifdef ROTATE
      show_rotate_results(j,lx,ly);
`endif
    end  
  endtask
  initial begin
  $display("starting simulation");
`ifdef PIPELINE
  $display("PIPELINE configuration");
`endif
`ifdef ITERATE
  $display("ITERATE configuration");
`endif
`ifdef COMBINATORIAL
  $display("COMBINATORIAL configuration");
`endif  

  // The following table is computed for U(1,15) format numbers
  // The angle data z[] is in radians
  x[0] <= 17'd32768;  y[0] <= 17'd0;      z[0] <= 17'd0;
  x[1] <= 17'd32763;  y[1] <= 17'd571;    z[1] <= 17'd571;
  x[2] <= 17'd32748;  y[2] <= 17'd1143;   z[2] <= 17'd1143;
  x[3] <= 17'd32723;  y[3] <= 17'd1714;   z[3] <= 17'd1715;
  x[4] <= 17'd32688;  y[4] <= 17'd2285;   z[4] <= 17'd2287;
  x[5] <= 17'd32643;  y[5] <= 17'd2855;   z[5] <= 17'd2859;
  x[6] <= 17'd32588;  y[6] <= 17'd3425;   z[6] <= 17'd3431;
  x[7] <= 17'd32523;  y[7] <= 17'd3993;   z[7] <= 17'd4003;
  x[8] <= 17'd32449;  y[8] <= 17'd4560;   z[8] <= 17'd4575;
  x[9] <= 17'd32364;  y[9] <= 17'd5126;   z[9] <= 17'd5147;
  x[10] <= 17'd32270; y[10] <= 17'd5690;  z[10] <= 17'd5719;
  x[11] <= 17'd32165; y[11] <= 17'd6252;  z[11] <= 17'd6291;
  x[12] <= 17'd32051; y[12] <= 17'd6812;  z[12] <= 17'd6862;
  x[13] <= 17'd31928; y[13] <= 17'd7371;  z[13] <= 17'd7434;
  x[14] <= 17'd31794; y[14] <= 17'd7927;  z[14] <= 17'd8006;
  x[15] <= 17'd31651; y[15] <= 17'd8480;  z[15] <= 17'd8578;
  x[16] <= 17'd31498; y[16] <= 17'd9032;  z[16] <= 17'd9150;
  x[17] <= 17'd31336; y[17] <= 17'd9580;  z[17] <= 17'd9722;
  x[18] <= 17'd31164; y[18] <= 17'd10125; z[18] <= 17'd10294;
  x[19] <= 17'd30982; y[19] <= 17'd10668; z[19] <= 17'd10866;
  x[20] <= 17'd30791; y[20] <= 17'd11207; z[20] <= 17'd11438;
  x[21] <= 17'd30591; y[21] <= 17'd11743; z[21] <= 17'd12010;
  x[22] <= 17'd30381; y[22] <= 17'd12275; z[22] <= 17'd12582;
  x[23] <= 17'd30163; y[23] <= 17'd12803; z[23] <= 17'd13153;
  x[24] <= 17'd29935; y[24] <= 17'd13327; z[24] <= 17'd13725;
  x[25] <= 17'd29697; y[25] <= 17'd13848; z[25] <= 17'd14297;
  x[26] <= 17'd29451; y[26] <= 17'd14364; z[26] <= 17'd14869;
  x[27] <= 17'd29196; y[27] <= 17'd14876; z[27] <= 17'd15441;
  x[28] <= 17'd28932; y[28] <= 17'd15383; z[28] <= 17'd16013;
  x[29] <= 17'd28659; y[29] <= 17'd15886; z[29] <= 17'd16585;
  x[30] <= 17'd28377; y[30] <= 17'd16383; z[30] <= 17'd17157;
  x[31] <= 17'd28087; y[31] <= 17'd16876; z[31] <= 17'd17729;
  x[32] <= 17'd27788; y[32] <= 17'd17364; z[32] <= 17'd18301;
  x[33] <= 17'd27481; y[33] <= 17'd17846; z[33] <= 17'd18873;
  x[34] <= 17'd27165; y[34] <= 17'd18323; z[34] <= 17'd19444;
  x[35] <= 17'd26841; y[35] <= 17'd18794; z[35] <= 17'd20016;
  x[36] <= 17'd26509; y[36] <= 17'd19260; z[36] <= 17'd20588;
  x[37] <= 17'd26169; y[37] <= 17'd19720; z[37] <= 17'd21160;
  x[38] <= 17'd25821; y[38] <= 17'd20173; z[38] <= 17'd21732;
  x[39] <= 17'd25465; y[39] <= 17'd20621; z[39] <= 17'd22304;
  x[40] <= 17'd25101; y[40] <= 17'd21062; z[40] <= 17'd22876;
  x[41] <= 17'd24730; y[41] <= 17'd21497; z[41] <= 17'd23448;
  x[42] <= 17'd24351; y[42] <= 17'd21926; z[42] <= 17'd24020;
  x[43] <= 17'd23964; y[43] <= 17'd22347; z[43] <= 17'd24592;
  x[44] <= 17'd23571; y[44] <= 17'd22762; z[44] <= 17'd25164;
  x[45] <= 17'd23170; y[45] <= 17'd23170; z[45] <= 17'd25735;
  x[46] <= 17'd22762; y[46] <= 17'd23571; z[46] <= 17'd26307;
  x[47] <= 17'd22347; y[47] <= 17'd23964; z[47] <= 17'd26879;
  x[48] <= 17'd21926; y[48] <= 17'd24351; z[48] <= 17'd27451;
  x[49] <= 17'd21497; y[49] <= 17'd24730; z[49] <= 17'd28023;
  x[50] <= 17'd21062; y[50] <= 17'd25101; z[50] <= 17'd28595;
  x[51] <= 17'd20621; y[51] <= 17'd25465; z[51] <= 17'd29167;
  x[52] <= 17'd20173; y[52] <= 17'd25821; z[52] <= 17'd29739;
  x[53] <= 17'd19720; y[53] <= 17'd26169; z[53] <= 17'd30311;
  x[54] <= 17'd19260; y[54] <= 17'd26509; z[54] <= 17'd30883;
  x[55] <= 17'd18794; y[55] <= 17'd26841; z[55] <= 17'd31455;
  x[56] <= 17'd18323; y[56] <= 17'd27165; z[56] <= 17'd32026;
  x[57] <= 17'd17846; y[57] <= 17'd27481; z[57] <= 17'd32598;
  x[58] <= 17'd17364; y[58] <= 17'd27788; z[58] <= 17'd33170;
  x[59] <= 17'd16876; y[59] <= 17'd28087; z[59] <= 17'd33742;
  x[60] <= 17'd16384; y[60] <= 17'd28377; z[60] <= 17'd34314;
  x[61] <= 17'd15886; y[61] <= 17'd28659; z[61] <= 17'd34886;
  x[62] <= 17'd15383; y[62] <= 17'd28932; z[62] <= 17'd35458;
  x[63] <= 17'd14876; y[63] <= 17'd29196; z[63] <= 17'd36030;
  x[64] <= 17'd14364; y[64] <= 17'd29451; z[64] <= 17'd36602;
  x[65] <= 17'd13848; y[65] <= 17'd29697; z[65] <= 17'd37174;
  x[66] <= 17'd13327; y[66] <= 17'd29935; z[66] <= 17'd37746;
  x[67] <= 17'd12803; y[67] <= 17'd30163; z[67] <= 17'd38317;
  x[68] <= 17'd12275; y[68] <= 17'd30381; z[68] <= 17'd38889;
  x[69] <= 17'd11743; y[69] <= 17'd30591; z[69] <= 17'd39461;
  x[70] <= 17'd11207; y[70] <= 17'd30791; z[70] <= 17'd40033;
  x[71] <= 17'd10668; y[71] <= 17'd30982; z[71] <= 17'd40605;
  x[72] <= 17'd10125; y[72] <= 17'd31164; z[72] <= 17'd41177;
  x[73] <= 17'd9580;  y[73] <= 17'd31336; z[73] <= 17'd41749;
  x[74] <= 17'd9032;  y[74] <= 17'd31498; z[74] <= 17'd42321;
  x[75] <= 17'd8480;  y[75] <= 17'd31651; z[75] <= 17'd42893;
  x[76] <= 17'd7927;  y[76] <= 17'd31794; z[76] <= 17'd43465;
  x[77] <= 17'd7371;  y[77] <= 17'd31928; z[77] <= 17'd44037;
  x[78] <= 17'd6812;  y[78] <= 17'd32051; z[78] <= 17'd44608;
  x[79] <= 17'd6252;  y[79] <= 17'd32165; z[79] <= 17'd45180;
  x[80] <= 17'd5690;  y[80] <= 17'd32270; z[80] <= 17'd45752;
  x[81] <= 17'd5126;  y[81] <= 17'd32364; z[81] <= 17'd46324;
  x[82] <= 17'd4560;  y[82] <= 17'd32449; z[82] <= 17'd46896;
  x[83] <= 17'd3993;  y[83] <= 17'd32523; z[83] <= 17'd47468;
  x[84] <= 17'd3425;  y[84] <= 17'd32588; z[84] <= 17'd48040;
  x[85] <= 17'd2855;  y[85] <= 17'd32643; z[85] <= 17'd48612;
  x[86] <= 17'd2285;  y[86] <= 17'd32688; z[86] <= 17'd49184;
  x[87] <= 17'd1714;  y[87] <= 17'd32723; z[87] <= 17'd49756;
  x[88] <= 17'd1143;  y[88] <= 17'd32748; z[88] <= 17'd50328;
  x[89] <= 17'd571;   y[89] <= 17'd32763; z[89] <= 17'd50899;
  x[90] <= 17'd0;     y[90] <= 17'd32768; z[90] <= 17'd51471;

  clock   <= 0;
  init    <= 0;
  reset   <= 1;
  x_i     <= 0;
  y_i     <= 0;
  theta_i <= 0;
  #1 clock <= 1;
  #1 clock <= 0;
  reset <= 0;  

  for (j=0;j<=90;j = j+1) begin // test 91 different angles, 0 to 90 degrees
`ifdef ROTATE // compute sin and cos
    x_i <= `CORDIC_1;
    y_i <= 0;
    theta_i <= z[j];
`endif
`ifdef VECTOR // compute the arctan
    x_i <= x[j];
    y_i <= y[j];
    theta_i <= 0;
`endif


`ifdef ITERATE     
    init <= 1;      // load the value into the rotator
    #1 clock <= 1;
    #1 clock <= 0;
    init <= 0;
    for(i=0;i<`ITERATIONS;i = i+1) begin  // iterate on the value
      #1 clock <= 1;
      #1 clock <= 0;
    end
    show_results(j,x_o,y_o,theta_o);
`endif


`ifdef COMBINATORIAL
    #1; // give a little time to view the waveform...
    show_results(j,x_o,y_o,theta_o);
`endif

`ifdef PIPELINE
    #1 clock <= 1;
    #1 clock <= 0;   
    if (j >= (`ITERATIONS-2)) begin // wait until the results start popping out
      show_results((j-(`ITERATIONS-2)),x_o,y_o,theta_o);
    end
    if (j == 90)  // now flush the pipe
    for(i=0;i<(`ITERATIONS-2);i = i+1) begin
      #1 clock <= 1;
      #1 clock <= 0;
      show_results((90-`ITERATIONS+3+i),x_o,y_o,theta_o);
    end
`endif


  end
  for(i=0;i<16;i=i+1)  // dump a few extra clock just for grins
    #1 clock <= ~clock;
end

endmodule
