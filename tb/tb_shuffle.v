`timescale 1ns/10ps

module tb_shuffle();

localparam CLK_PERIOD = 10ns;
localparam HOLD  = 1ns;

localparam FOLDFACTOR     = 4;
localparam NUMINSTANCES   = 360 / FOLDFACTOR;
localparam LOG2INSTANCES = (FOLDFACTOR==1) ? 9 :
                           (FOLDFACTOR==2) ? 8 :
                           (FOLDFACTOR==3) ? 7 :
                           /* 4 */           7;
localparam LLRWIDTH       = 4;

localparam LASTSHIFTDIST = (FOLDFACTOR==1) ? 11 :
                           (FOLDFACTOR==2) ? 5  :
                           (FOLDFACTOR==3) ? 3  :
                           /* 4 */           2;
localparam LASTSHIFTWIDTH  = (FOLDFACTOR==1) ? 4 :
                             (FOLDFACTOR==2) ? 3 :
                             (FOLDFACTOR==3) ? 2 :
                             /* 4 */           2;
reg clk;
reg rst;

initial
begin
  clk <= 0;
  rst <= 1;
  #0;

  #(CLK_PERIOD/2) clk <= ~clk;
  #(CLK_PERIOD/2)clk <= ~clk;
  #(CLK_PERIOD/2)clk <= ~clk;

  rst <= 0;

  forever
    #(CLK_PERIOD/2) clk <= ~clk;
end

////////////////////
reg                       vnmsg0_cnmsg1;
reg                       first_half;
integer                   shiftval;
integer                   shiftval_del1;
integer                   shiftval_del2;
wire[1:0]                 shift0;
wire[2:0]                 shift1;
wire[LASTSHIFTWIDTH-1:0]  shift2;


reg[LLRWIDTH-1:0] vn_2d[NUMINSTANCES-1:0];
reg[LLRWIDTH-1:0] cn_2d[NUMINSTANCES-1:0];
reg[LLRWIDTH-1:0] vn_pipe[0:2][NUMINSTANCES-1:0];
reg[LLRWIDTH-1:0] cn_pipe[0:2][NUMINSTANCES-1:0];

reg[NUMINSTANCES*LLRWIDTH-1:0]  vn_concat;
reg[NUMINSTANCES*LLRWIDTH-1:0]  cn_concat;
wire[NUMINSTANCES*LLRWIDTH-1:0] sh_concat;
////////////////////

localparam SHIFTFACTOR0 = FOLDFACTOR==1 ? 90 :
                          FOLDFACTOR==2 ? 45 :
                          FOLDFACTOR==3 ? 30 :
                                          23;
localparam SHIFTFACTOR1 = (FOLDFACTOR==1) ? 12 :
                          (FOLDFACTOR==2) ? 6  :
                          (FOLDFACTOR==3) ? 4  :
                          /* 4 */           3;     

assign shift0 = shiftval / SHIFTFACTOR0;
assign shift1 = (shiftval_del1 % SHIFTFACTOR0) / SHIFTFACTOR1;
assign shift2 = (shiftval_del2 % SHIFTFACTOR0) % SHIFTFACTOR1;

always @( posedge clk, posedge rst )
  if( rst )
  begin
    shiftval_del1 <= 0;
    shiftval_del2 <= 0;
  end
  else
  begin
    shiftval_del1 <= #HOLD shiftval;
    shiftval_del2 <= #HOLD shiftval_del1;
  end

// shift random distances (1 million iterations)
initial
begin
  first_half <= 1;
  shiftval   <= 0;

  for( int j=0; j<NUMINSTANCES; j++ )
  begin
    vn_2d[j] <= #HOLD 0;
    cn_2d[j] <= #HOLD 0;
  end

  @( negedge rst );
  @( posedge clk );

  // a few corner cases
  for( int j=0; j<NUMINSTANCES; j++ )
  begin
    vn_2d[j] <= #HOLD j % (2**LLRWIDTH);
    cn_2d[j] <= #HOLD j % (2**LLRWIDTH);
  end
  
  shiftval <= #HOLD NUMINSTANCES - 1;
  @( posedge clk );
  shiftval <= #HOLD 0;
  @( posedge clk );
  shiftval <= #HOLD 1;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/8 - 1;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/8;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/8 + 1;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/4 - 1;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/4;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/4 + 1;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/2 - 1;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/2;
  @( posedge clk );
  shiftval <= #HOLD NUMINSTANCES/2 + 1;
  @( posedge clk );

  for( int i=0; i<1000000; i++ )
  begin
    // random shift
    shiftval = #HOLD {$random()} % NUMINSTANCES;
    
    // random data
    for( int j=0; j<NUMINSTANCES; j++ )
    begin
      vn_2d[j] <= #HOLD $random();
      cn_2d[j] <= #HOLD $random();
    end

    @( posedge clk );
  end

  $stop();
end

generate
  genvar inst;
  
  for( inst=0; inst<NUMINSTANCES; inst=inst+1 )
  begin: twodto1d
    assign vn_concat[inst*LLRWIDTH+LLRWIDTH-1:inst*LLRWIDTH] = vn_2d[inst];
    assign cn_concat[inst*LLRWIDTH+LLRWIDTH-1:inst*LLRWIDTH] = cn_2d[inst];
  end
endgenerate

task rotate_ldpc( output reg[LLRWIDTH-1:0] out_array[NUMINSTANCES-1:0],
                  input  reg[LLRWIDTH-1:0] inp_array[NUMINSTANCES-1:0],
                  input  int               shift_distance );
begin
  for( int inst=0; inst<NUMINSTANCES; inst++ )
    out_array[(NUMINSTANCES+inst+shift_distance) % NUMINSTANCES] = inp_array[inst];
end
endtask

// simulate shuffle behavior
int shift_pipe[0:2];
reg[LLRWIDTH-1:0] shuffle_result[NUMINSTANCES-1:0];

initial
begin
  for( int i=0; i<4; i++ )
  begin
    shift_pipe[i] <= 0;
    for( int j=0; j<NUMINSTANCES; j++ )
    begin
      vn_pipe[i][j] <= 0;
      cn_pipe[i][j] <= 0;
    end
  end

  @(negedge rst);
  @(posedge clk);

  forever
  begin
    shift_pipe[0] <= shiftval;
    shift_pipe[1] <= shift_pipe[0];
    shift_pipe[2] <= shift_pipe[1];

    vn_pipe[0] <= vn_2d;
    vn_pipe[1] <= vn_pipe[0];
    rotate_ldpc( shuffle_result, vn_pipe[1], shift_pipe[1] );
    vn_pipe[2] <= shuffle_result;

    cn_pipe[0] <= cn_2d;
    cn_pipe[1] <= cn_pipe[0];
    rotate_ldpc( shuffle_result, cn_pipe[1], NUMINSTANCES - shift_pipe[1] );
    cn_pipe[2] <= shuffle_result;
    @(posedge clk);
  end
end

// assert that shuffler always returns correct result
logic[LLRWIDTH-1:0] local_result;

initial
begin
  @(negedge rst);
  repeat( 3 ) @(posedge clk);

  forever
  begin
    for( int i=NUMINSTANCES-1; i>=0; i-- )
    begin
      local_result = sh_concat[(i+1)*LLRWIDTH-1 -: LLRWIDTH];
      
      if( first_half )
      begin
        if( local_result!=vn_pipe[2][i] )
          $display( "%0t: Shuffle mismatch: position %0d: expected %0h: result %0h", $time, i, local_result, vn_pipe[2][i] );
      end
      else
        if( local_result!=cn_pipe[2][i] )
          $display( "%0t: Shuffle mismatch: position %0d: expected %0h: result %0h", $time, i, local_result, cn_pipe[2][i] );
    end
    @( posedge clk );
  end
end

ldpc_shuffle #( .FOLDFACTOR(FOLDFACTOR),
                .NUMINSTANCES(NUMINSTANCES),
                .LOG2INSTANCES(LOG2INSTANCES),
                .LLRWIDTH(LLRWIDTH),
                .LASTSHIFTWIDTH(LASTSHIFTWIDTH),
                .LASTSHIFTDIST(LASTSHIFTDIST)
 ) ldpc_shufflei(
  .clk          (clk),
  .rst          (rst),
  .first_half   (first_half),
  .shift0       (shift0),
  .shift1       (shift1),
  .shift2       (shift2),
  .incpoint     (incpoint),
  .vn_concat    (vn_concat),
  .cn_concat    (cn_concat),
  .sh_concat    (sh_concat),
  .increment    (increment)
);

endmodule

