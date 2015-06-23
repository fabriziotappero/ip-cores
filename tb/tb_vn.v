`timescale 1ns/1ns

module tb_vn();

localparam NUM_RUNS           = 1000;
localparam ITERATIONS_PER_RUN = 30;
localparam MAX_CONNECTIVITY   = 8;

localparam FOLDFACTOR = 1;
localparam VN_DEPTH   = 2**(7+FOLDFACTOR);

localparam LLRWIDTH         = 4;
localparam MAX_LLR          = (2**(LLRWIDTH-1)) -1;
localparam MAX_INTERNAL_LLR = (2**(LLRWIDTH+3)) -1;

localparam MIN_SEPARATION = 5;

localparam CLK_PERIOD = 10ns;
localparam HOLD       = 1ns;

//////////////////////////////////////////

reg clk;
reg rst;

initial
begin
  clk <= 1;
  rst <= 1;
  #0;

  #(CLK_PERIOD/2) clk <= ~clk;
  #(CLK_PERIOD/2) clk <= ~clk;
  #(CLK_PERIOD/2) clk <= ~clk;

  rst <= 0;

  forever
    #(CLK_PERIOD/2) clk <= ~clk;
end

/////////////////////
// Main controller //
/////////////////////
typedef struct { int iterations;
                 int connections_per_node;
                 int min_separation;
                 bit allow_adjacent_writes;
                 } run;
run run_source;

mailbox #( run ) run_descriptor;
semaphore        generator_done;

initial
begin
  run_descriptor = new();
  @(negedge rst);

  for( int run_num=0; run_num<NUM_RUNS; run_num++ )
  begin
    run_source.iterations            = ITERATIONS_PER_RUN;
    run_source.connections_per_node  = 1 + { $random() } % MAX_CONNECTIVITY;
    run_source.min_separation        = MIN_SEPARATION;
    run_source.allow_adjacent_writes = 1;

    run_descriptor.put( run_source );

    generator_done.get(1);
    $display( "%0t: Run %0d done", $time(), run_num );
  end

  $display( "Done" );
  $stop();
end

////////////////////
// Data generator //
////////////////////
localparam EMPTY    = -999999;

int data_sequence[];
bit sign_sequence[];
bit disable_sequence[];
int address[];

int writes_per_iteration;
int iterations;

semaphore send_load;
semaphore send_run;
semaphore load_done;
semaphore run_done;

initial
begin
  generator_done = new();
  send_load      = new();
  send_run       = new();

  @(negedge rst);

  forever
  begin
    run run_dest;

    int array_len;
    bit start_over;

    run_descriptor.get( run_dest );

    writes_per_iteration = run_dest.connections_per_node*VN_DEPTH;
    iterations           = run_dest.iterations;
    array_len            = iterations*writes_per_iteration;

    data_sequence    = new[array_len];
    sign_sequence    = new[array_len];
    disable_sequence = new[array_len];
    address          = new[array_len];

    /////////////////////////////////////////////
    // Create data sequence for the entire run //
    /////////////////////////////////////////////
    start_over = 1;

    // assign random data and clear address array
    for( int i=0; i<=array_len; i++ )
    begin
      address[i]          = EMPTY;
      disable_sequence[i] =  0;//($random() %100 == 1);

      data_sequence[i] = { $random() } % (MAX_LLR+1);
      sign_sequence[i] = $random();
    end

    while( start_over )
    begin
      start_over = 0;

      for( int i=0; i<iterations; i++ )
      begin
        bit adjacent_write;
        int try_addr;

        int this_iteration_start;

        this_iteration_start = i*writes_per_iteration;

        adjacent_write   = 0;
        try_addr         = 0;

        for( int j=0; j<VN_DEPTH; j++ )
        begin
          for( int k=0; k<run_dest.connections_per_node; k++ )
          begin
            bit good_addr;
            bit good_run;

            int try_count;
            // Assign somewhat random order, but try to group addresses and
            // create "runs" of identical addresses
            try_count = 0;
            good_addr = 0;

            while( !good_addr && !start_over )
            begin
              int this_array_location;
              bit increment_search;

              try_count++;
              try_addr++;

              if( !adjacent_write )
              begin
                try_addr += run_dest.min_separation - 1;
                try_addr += { $random() } % 3;
              end

              try_addr            = try_addr % writes_per_iteration;
              this_array_location = this_iteration_start + try_addr;

              // test whether the selected locaiton is valid
              good_addr        = (address[this_array_location]==EMPTY);
              increment_search = !good_addr;

              // check whether nearby locations contain identical addresses.  A continuous
              // run of identical addresses is allowed
              good_run = run_dest.allow_adjacent_writes;

              for( int test_addr=this_array_location-1;
                   (test_addr >= this_array_location-run_dest.min_separation) &&
                   (test_addr >= this_iteration_start);
                   test_addr-- )
              begin
                bit matches1;
                matches1 = j==address[test_addr];

                good_run  = good_run & matches1;
                good_addr = good_addr & (!matches1 | good_run);
              end

              good_run = run_dest.allow_adjacent_writes;

              for( int test_addr=1;
                   (test_addr < run_dest.min_separation) &&
                   (this_array_location+test_addr < writes_per_iteration);
                   test_addr++ )
              begin
                bit matches2;
                matches2 = j==address[this_array_location+test_addr];

                good_run  = good_run & matches2;
                good_addr = good_addr & (!matches2 | good_run);
              end

              if( good_addr )
                adjacent_write = ({$random()}%3==2) & run_dest.allow_adjacent_writes;
              else // if random jump resulted in bad address, try next address
                adjacent_write = 1;

              // There's a chance we'll have to start all over due to impossible
              // placement.  Detect that here:
              if( !good_addr && (try_count==writes_per_iteration) )
              begin
                int it;
                int ad;
                int co;
                it = i;
                ad = j;
                co = k;
                $display( "Iteration %0d / %0d, address %0d / %0d, connection %0d / %0d - couldn't find good placement",
                          it, iterations, ad, VN_DEPTH, co, run_dest.connections_per_node );
                start_over = 1;
              end

              if( good_addr )
                address[this_array_location] = j;
            end
          end
        end
      end
    end

    // At this point, address and data_sequence contain valid data
    send_load.put(1);
    load_done.get(1);
    send_run.put(1);
    run_done.get(1);

    data_sequence.delete;
    sign_sequence.delete;
    disable_sequence.delete;
    address.delete;

    generator_done.put(1);
  end
end

////////////////////////////
// Load/unload transactor //
////////////////////////////
reg                   llr_access;
reg[7+FOLDFACTOR-1:0] llr_addr;
reg                   llr_din_we;
reg[LLRWIDTH-1:0]     llr_din;

wire[LLRWIDTH-1:0]    llr_dout;

initial
begin
  load_done = new();

  llr_access  <= 0;
  llr_addr    <= 0;
  llr_din_we  <= 0;
  llr_din     <= 0;

  @(negedge rst);

  forever
  begin
    send_load.get( 1 );
    @(posedge clk);
    llr_access <= #HOLD 1;
    repeat(2) @(posedge clk);

    // Fill in random data, in order.  Use data from data_sequence, since it's already
    // in the right format (-2**(LLRWIDTH-1) -1 .. 2**(LLRWIDTH-1) -1)
    for( int i=0; i<VN_DEPTH; i++ )
    begin
      llr_addr   <= #HOLD i;
      llr_din_we <= #HOLD 1;

      llr_din[LLRWIDTH-1]   <= #HOLD $random();
      llr_din[LLRWIDTH-2:0] <= #HOLD data_sequence[ {$random()} % (iterations*writes_per_iteration) ];
      @(posedge clk);
    end

    llr_access  <= #HOLD 0;
    llr_addr    <= #HOLD 0;
    llr_din_we  <= #HOLD 0;
    llr_din     <= #HOLD 0;
    repeat(MIN_SEPARATION) @(posedge clk);

    load_done.put( 1 );
  end
end

////////////////////////////////
// Message passing transactor //
////////////////////////////////
reg                   iteration;
reg                   first_half;
reg                   first_iteration;
reg                   we_vnmsg;
reg                   disable_paritymsg;
reg[7+FOLDFACTOR-1:0] addr_vn;
bit                   start_read;

reg[LLRWIDTH-1:0]  sh_msg;
wire[LLRWIDTH-1:0] vn_msg;

initial
begin
  run_done = new();

  iteration         <= 0;
  first_half        <= 0;
  first_iteration   <= 0;
  we_vnmsg          <= 0;
  disable_paritymsg <= 0;
  addr_vn           <= 0;
  sh_msg            <= 0;
  start_read        <= 0;

  @(negedge rst);

  forever
  begin
    send_run.get( 1 );
    @(posedge clk);

    // downstream
    for( int it=0; it<iterations; it++ )
    begin
      int base_offset;
      base_offset = it * writes_per_iteration;
      
      iteration <= #HOLD it[0];

      for( int half=0; half<2; half++ )
      begin
        first_half      <= #HOLD half==0;
        first_iteration <= #HOLD it==0;
        we_vnmsg        <= #HOLD half==1;
        start_read      <= #HOLD half==0;
        
        for( int i=0; i<writes_per_iteration; i++ )
        begin
          sh_msg[LLRWIDTH-1]   <= #HOLD sign_sequence[base_offset + i];
          sh_msg[LLRWIDTH-2:0] <= #HOLD data_sequence[base_offset + i];
          addr_vn              <= #HOLD address[base_offset + i];
          disable_paritymsg    <= #HOLD disable_sequence[base_offset + i];
          @(posedge clk);
        end

        we_vnmsg          <= #HOLD 0;
        start_read        <= #HOLD 0;
        repeat(2* MIN_SEPARATION) @(posedge clk);
      end
    end

    repeat(2) @(posedge clk);
    run_done.put( 1 );
  end
end

///////////////////////
// Model and checker //
///////////////////////
// Mimic intended behavior of VN
int llr_values[0:VN_DEPTH-1];
int msg_sums[0:VN_DEPTH-1];
int last_msgwrite_iteration[0:VN_DEPTH-1];

int predicted_llr_dout;
int predicted_vn_msg;

always @( posedge clk )
begin
  if( llr_access && llr_din_we )
  begin
    llr_values[llr_addr] = llr_din[LLRWIDTH-2:0];
    if( llr_din[LLRWIDTH-1] )
      llr_values[llr_addr] *= -1;
    msg_sums[llr_addr] = 0;
  end

  if( we_vnmsg & !disable_paritymsg )
  begin
    // clear messages on new iteration, and store current iteration
    if( last_msgwrite_iteration[addr_vn]!=iteration )
      msg_sums[addr_vn] = 0;
    last_msgwrite_iteration[addr_vn] = iteration;

    // add in new message
    if( sh_msg[LLRWIDTH-1] )
      msg_sums[addr_vn] = msg_sums[addr_vn] - sh_msg[LLRWIDTH-2:0];
    else
      msg_sums[addr_vn] = msg_sums[addr_vn] + sh_msg[LLRWIDTH-2:0];

    // Limit sum-of-messages value to a saturation level
    if( msg_sums[addr_vn]>MAX_INTERNAL_LLR )
      msg_sums[addr_vn] = MAX_INTERNAL_LLR;
    if( msg_sums[addr_vn]<-1 * MAX_INTERNAL_LLR )
      msg_sums[addr_vn] = -1 * MAX_INTERNAL_LLR;
  end

  // llr_dout is the sum of the original LLR and the sum of the messages
  predicted_llr_dout = llr_values[llr_addr] + msg_sums[llr_addr];
  if( predicted_llr_dout>MAX_LLR )
    predicted_llr_dout = MAX_LLR;
  if( predicted_llr_dout<-1 * MAX_LLR )
    predicted_llr_dout = -1 * MAX_LLR;

  // llr_dout is the sum of the original LLR and the sum of the messages
  predicted_vn_msg = llr_values[addr_vn] + msg_sums[addr_vn];
  if( predicted_vn_msg>MAX_LLR )
    predicted_vn_msg = MAX_LLR;
  if( predicted_vn_msg<-1 * MAX_LLR )
    predicted_vn_msg = -1 * MAX_LLR;
end

// Add latency and check behavior of VN
localparam LLR_DOUT_LATENCY = 6;
localparam VN_MSG_LATENCY   = 6;

int predicted_llr_dout_del[0:LLR_DOUT_LATENCY-2];
bit check_llr_dout_del[0:LLR_DOUT_LATENCY-2];
int predicted_vn_msg_del[0:VN_MSG_LATENCY-2];
bit check_vn_msg_del[0:VN_MSG_LATENCY-2];

int llr_dout_int;
int vn_msg_int;

always @( posedge rst, posedge clk )
  if( rst )
  begin
    for( int i=0; i<LLR_DOUT_LATENCY-1; i++ )
    begin
      predicted_llr_dout_del[i] <= EMPTY;
      check_llr_dout_del[i]     <= 0;
    end
    for( int i=0; i<VN_MSG_LATENCY-1; i++ )
    begin
      predicted_vn_msg_del[i] <= EMPTY;
      check_vn_msg_del[i]     <= 0;
    end
  end
  else
  begin
    predicted_llr_dout_del[0] <= predicted_llr_dout;
    check_llr_dout_del[0]     <= llr_access & ~llr_din_we;
    
    predicted_vn_msg_del[0] <= predicted_vn_msg;
    check_vn_msg_del[0]     <= start_read;
    
    for( int i=1; i<LLR_DOUT_LATENCY-1; i++ )
    begin
      predicted_llr_dout_del[i] <= predicted_llr_dout_del[i-1];
      check_llr_dout_del[i]     <= check_llr_dout_del[i-1];
    end
    
    for( int i=1; i<VN_MSG_LATENCY-1; i++ )
    begin
      predicted_vn_msg_del[i] <= predicted_vn_msg_del[i-1];
      check_vn_msg_del[i]     <= check_vn_msg_del[i-1];
    end
    
    llr_dout_int = llr_dout[LLRWIDTH-2:0];
    if( llr_dout[LLRWIDTH-1] )
      llr_dout_int *= -1;
      
    vn_msg_int = vn_msg[LLRWIDTH-2:0];
    if( vn_msg[LLRWIDTH-1] )
      vn_msg_int *= -1;
      
    if( check_llr_dout_del[LLR_DOUT_LATENCY-2] &&
        (predicted_llr_dout_del[LLR_DOUT_LATENCY-2]!=EMPTY) &&
        (predicted_llr_dout_del[LLR_DOUT_LATENCY-2]!=llr_dout_int) )
      $display( "%0t: Mismatch, predicted llr_dout != actual, %0d != %0d",
                $time(),
                predicted_llr_dout_del[LLR_DOUT_LATENCY-2],
                llr_dout_int );
      
    if( check_vn_msg_del[VN_MSG_LATENCY-2] &&
        (predicted_vn_msg_del[VN_MSG_LATENCY-2]!=EMPTY) &&
        (predicted_vn_msg_del[VN_MSG_LATENCY-2]!=vn_msg_int) )
      $display( "%0t: Mismatch, predicted vn_msg != actual, %0d != %0d",
                $time(),
                predicted_vn_msg_del[VN_MSG_LATENCY-2],
                vn_msg_int );
  end

///////////////
// DUT + RAM //
///////////////
wire[7+FOLDFACTOR-1:0] vnram_wraddr;
wire[7+FOLDFACTOR-1:0] vnram_rdaddr;
wire                   upmsg_we;
wire[2*LLRWIDTH+4:0]   upmsg_din;
wire[2*LLRWIDTH+4:0]   upmsg_dout;

ldpc_vn #(
  .FOLDFACTOR (FOLDFACTOR),
  .LLRWIDTH   (LLRWIDTH)
) ldpc_vn_i(
  .clk(clk),
  .rst(rst),

  // LLR I/O
  .llr_access( llr_access ),
  .llr_addr  ( llr_addr ),
  .llr_din_we( llr_din_we ),
  .llr_din   ( llr_din ),
  .llr_dout  ( llr_dout ),

  // message control
  .iteration        (iteration),
  .first_half       (first_half),
  .first_iteration  (first_iteration),
  .we_vnmsg         (we_vnmsg),
  .disable_paritymsg(disable_paritymsg),
  .addr_vn          (addr_vn),

  // message I/O
  .sh_msg(sh_msg),
  .vn_msg(vn_msg),

  // Attached RAM holds iteration number original LLR and message sum
  .vnram_wraddr(vnram_wraddr),
  .vnram_rdaddr(vnram_rdaddr),
  .upmsg_we    (upmsg_we),
  .upmsg_din   (upmsg_din),
  .upmsg_dout  (upmsg_dout)
);

ldpc_ram_behav #(
  .WIDTH    ( 2*LLRWIDTH+5 ),
  .LOG2DEPTH(7+FOLDFACTOR)
) ldpc_vn_rami (
  .clk   (clk),
  .we    (upmsg_we),
  .din   (upmsg_din),
  .wraddr(vnram_wraddr),
  .rdaddr(vnram_rdaddr),
  .dout  (upmsg_dout)
);

endmodule

