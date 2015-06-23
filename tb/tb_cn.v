`timescale 1ns/10ps

module tb_cn();

localparam NUM_RUNS           = 1000;
localparam ITERATIONS_PER_RUN = 30;
localparam MAX_CONNECTIVITY   = 30;

localparam FOLDFACTOR = 1;
localparam CN_DEPTH   = 2**(7+FOLDFACTOR);

localparam LLRWIDTH          = 4;
localparam MAX_LLR           = 2**(LLRWIDTH-1) -1;
localparam MAX_INTERNAL_LLR  = 2**(LLRWIDTH-2) -1;

localparam MIN_SEPARATION = 5;

localparam CLK_PERIOD = 10ns;
localparam HOLD       = 1ns;

localparam LASTSHIFTDIST = (FOLDFACTOR==1) ? 11 :
                           (FOLDFACTOR==2) ? 5  :
                           (FOLDFACTOR==3) ? 3  :
                           /* 4 */           2;
localparam LASTSHIFTWIDTH  = (FOLDFACTOR==1) ? 4 :
                             (FOLDFACTOR==2) ? 3 :
                             (FOLDFACTOR==3) ? 2 :
                             /* 4 */           2;

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

  rst <= #HOLD 0;

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
    run_source.connections_per_node  = 2 + ({ $random() } % (MAX_CONNECTIVITY -2));
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

    writes_per_iteration = run_dest.connections_per_node*CN_DEPTH;
    iterations           = run_dest.iterations;
    array_len            = iterations*writes_per_iteration;

    data_sequence    = new[array_len];
    sign_sequence    = new[array_len];
    disable_sequence = new[writes_per_iteration];
    address          = new[writes_per_iteration];

    /////////////////////////////////////////////
    // Create data sequence for the entire run //
    /////////////////////////////////////////////
    start_over = 1;

    // assign random data and clear address array
    for( int i=0; i<=writes_per_iteration; i++ )
    begin
      address[i]          = EMPTY;
      disable_sequence[i] = 0;//($random() %100 == 1);
    end

    for( int i=0; i<=array_len; i++ )
    begin
      data_sequence[i] = { $random() } % (MAX_LLR+1);
      sign_sequence[i] = $random();
    end

    while( start_over )
    begin
      bit adjacent_write;
      int try_addr;

      start_over     = 0;
      adjacent_write = 0;
      try_addr       = 0;

      for( int j=0; j<CN_DEPTH; j++ )
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
            try_count++;
            try_addr++;
            try_addr = try_addr % writes_per_iteration;

            // try to group even non-adjacent writes fairly closely, to maximize the
            // likelihood of memory inconsistency
            if( !adjacent_write )
            begin
              try_addr += run_dest.min_separation - 1;
              try_addr += { $random() } % 3;
              try_addr = try_addr % writes_per_iteration;
            end

            // search for an empty address
            while( (address[try_addr]!=EMPTY) && (try_count!=writes_per_iteration) )
            begin
              try_count++;
              try_addr++;
              try_addr = try_addr % writes_per_iteration;
            end

            good_addr = (address[try_addr]==EMPTY);

            // check whether nearby locations contain identical addresses.  A continuous
            // run of identical addresses is allowed
            good_run = run_dest.allow_adjacent_writes;

            for( int test_addr=try_addr-1;
                 (test_addr >= try_addr-run_dest.min_separation) && (test_addr >= 0);
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
                 (try_addr+test_addr < writes_per_iteration);
                 test_addr++ )
            begin
              bit matches2;
              matches2 = j==address[try_addr+test_addr];

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
              int ad;
              int co;
              ad = j;
              co = k;
              $display( "Address %0d / %0d, connection %0d / %0d - couldn't find good placement",
                        ad, CN_DEPTH, co, run_dest.connections_per_node );
              start_over = 1;
            end

            if( good_addr )
              address[try_addr] = j;
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

initial
begin
  load_done = new();

  llr_access  <= 0;
  llr_addr    <= 0;
  llr_din_we  <= 0;

  @(negedge rst);

  forever
  begin
    send_load.get( 1 );
    @(posedge clk);
    llr_access <= #HOLD 1;
    repeat(2) @(posedge clk);

    for( int i=0; i<CN_DEPTH; i++ )
    begin
      llr_addr   <= #HOLD i;
      llr_din_we <= #HOLD 1;
      @(posedge clk);
    end

    llr_access  <= #HOLD 0;
    llr_addr    <= #HOLD 0;
    llr_din_we  <= #HOLD 0;
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
reg                   cn_rd;
reg                   cn_we;
reg                   disable_paritymsg;
reg[7+FOLDFACTOR-1:0] addr_cn;

reg[LLRWIDTH-1:0]  sh_msg;
wire[LLRWIDTH-1:0] cn_msg;

initial
begin
  run_done = new();

  iteration         <= 0;
  first_half        <= 0;
  first_iteration   <= 0;
  cn_rd             <= 0;
  cn_we             <= 0;
  disable_paritymsg <= 0;
  addr_cn           <= 0;
  sh_msg            <= 0;

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
        cn_rd           <= #HOLD half==1;
        cn_we           <= #HOLD half==0;

        for( int i=0; i<writes_per_iteration; i++ )
        begin
          sh_msg[LLRWIDTH-1]   <= #HOLD sign_sequence[base_offset + i];
          sh_msg[LLRWIDTH-2:0] <= #HOLD data_sequence[base_offset + i];
          addr_cn              <= #HOLD address[i];
          disable_paritymsg    <= #HOLD disable_sequence[i];
          @(posedge clk);
        end

        cn_rd <= #HOLD 0;
        cn_we <= #HOLD 0;
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
// Store states based on received and sent messages
localparam CN_MSG_LATENCY = 4;

int recv_counter[0:CN_DEPTH-1];
int send_counter[0:CN_DEPTH-1];
int last_recv_iteration[0:CN_DEPTH-1];
int last_send_iteration[0:CN_DEPTH-1];
int recv_msgs[0:CN_DEPTH-1][0:MAX_CONNECTIVITY-1];
int sent_msgs[0:CN_DEPTH-1][0:MAX_CONNECTIVITY-1];

bit cn_rd_del[0:CN_MSG_LATENCY-1];
int addr_cn_del[0:CN_MSG_LATENCY-1];

always @( posedge clk )
begin
  if( llr_access && llr_din_we )
  begin
    last_recv_iteration[llr_addr] = -1;
    last_send_iteration[llr_addr] = -1;
    for( int i=0; i<MAX_CONNECTIVITY; i++ )
    begin
      recv_msgs[llr_addr][i] = EMPTY;
      sent_msgs[llr_addr][i] = 0;
    end
  end

  // Writes
  if( cn_we & !disable_paritymsg )
  begin
    int new_sign;
    int new_mag;
    int new_msg;
    int sent_msg;

    // increment counter, or reset counter for new iteration
    if( last_recv_iteration[addr_cn]!=iteration )
      recv_counter[addr_cn] = 0;
    else
      recv_counter[addr_cn]++;

    last_recv_iteration[addr_cn] = iteration;

    // stored value = received message - sent message, since a node's own
    // contribution to the LLR needs to be ignored
    new_sign  = sh_msg[LLRWIDTH-1] ? -1 : 1;
    new_mag   = sh_msg[LLRWIDTH-2:0];
    sent_msg  = sent_msgs[addr_cn][ recv_counter[addr_cn] ];

    new_msg = new_sign * new_mag;
    new_msg = new_msg - sent_msg;

    new_sign = new_msg < 0 ? -1 : 1;
    new_mag  = new_sign * new_msg;

    if( new_mag>MAX_INTERNAL_LLR )
      new_mag = MAX_INTERNAL_LLR;

    recv_msgs[addr_cn][ recv_counter[addr_cn] ] = new_sign * new_mag;
  end

  // Reads
  cn_rd_del[0]   <= cn_rd;
  addr_cn_del[0] <= addr_cn;
  for( int i=1; i<CN_MSG_LATENCY; i++ )
  begin
    cn_rd_del[i]   <= cn_rd_del[i-1];
    addr_cn_del[i] <= addr_cn_del[i-1];
  end

  if( cn_rd_del[CN_MSG_LATENCY-1] )
  begin
    int new_sign;
    int new_mag;
    int delayed_addr;
    int min_prev_val;

    delayed_addr = addr_cn_del[CN_MSG_LATENCY-1];

    // increment counter, or reset counter for new iteration
    if( last_send_iteration[delayed_addr]!=iteration )
      send_counter[delayed_addr] = 0;
    else
      send_counter[delayed_addr]++;

    last_send_iteration[delayed_addr] = iteration;

    // store read value in matrix
    new_sign = cn_msg[LLRWIDTH-1] ? -1 : 1;
    new_mag  = cn_msg[LLRWIDTH-2:0];

    sent_msgs[delayed_addr][ send_counter[delayed_addr] ] = new_sign * new_mag;
  end
end

// predict messages
int predicted_msgs[0:CN_DEPTH-1][0:MAX_CONNECTIVITY-1];

always @( posedge cn_rd )
begin
  for( int node=0; node<CN_DEPTH; node++ )
  begin
    // find min, nextmin for each node
    int min, nextmin;
    int sign_product;

    min     = 999999;
    nextmin = 999999;

    for( int msg_num=0; msg_num<=recv_counter[node]; msg_num++ )
    begin
      int msg_sign;
      int msg_mag;
      msg_sign = recv_msgs[node][msg_num] < 0 ? -1 : 1;
      msg_mag  = msg_sign * recv_msgs[node][msg_num];

      if( msg_mag <= min )
      begin
        nextmin = min;
        min     = msg_mag;
      end
      if( (msg_mag<nextmin) && (msg_mag!=min) )
        nextmin = msg_mag;
    end

    if( nextmin==999999 )
      nextmin = min;

    // find XOR of received signs
    sign_product = 1;
    for( int i=0; i<=recv_counter[node]; i++ )
      sign_product *= recv_msgs[node][ i ] < 0 ? -1 : 1;

    // assign EMPTY, or positive or negative min or nextmin to each message
    for( int msg_num=0; msg_num<MAX_CONNECTIVITY; msg_num++ )
    begin
      if( msg_num>recv_counter[node] )
        predicted_msgs[node][msg_num] = EMPTY;
      else
      begin
        int msg_sign;
        int msg_mag;
        msg_sign = recv_msgs[node][msg_num] < 0 ? -1 : 1;
        msg_mag  = msg_sign * recv_msgs[node][msg_num];

        if( msg_mag==min )
          predicted_msgs[node][msg_num] = nextmin;
        else
          predicted_msgs[node][msg_num] = min;

        if( predicted_msgs[node][msg_num]>MAX_LLR )
          predicted_msgs[node][msg_num] = MAX_LLR;
        if( predicted_msgs[node][msg_num]<-1 * MAX_LLR )
          predicted_msgs[node][msg_num] = -1 * MAX_LLR;

        predicted_msgs[node][msg_num] *= msg_sign * sign_product;
      end
    end
  end
end

// Check that sent messages match predicted
int predicted;
int predicted_counter[0:CN_DEPTH-1];

always @( posedge clk )
begin
  // clear counters on rising edge of cn_rd
  if( cn_rd_del[CN_MSG_LATENCY-2] && !cn_rd_del[CN_MSG_LATENCY-1] )
    for( int i=0; i<CN_DEPTH; i++ )
      predicted_counter[i] = 0;
      
  if( cn_rd_del[CN_MSG_LATENCY-1] )
  begin
    int node;
    int msg_num;
    int cn_msg_int;
  
    node    = addr_cn_del[CN_MSG_LATENCY-1];
    msg_num = predicted_counter[node];
    
    cn_msg_int = cn_msg[LLRWIDTH-2:0];
    if( cn_msg[LLRWIDTH-1] )
      cn_msg_int *= -1;
    
    predicted = predicted_msgs[node][msg_num];

    if( predicted!=cn_msg_int )
      $display( "%0t: Mismatch, predicted cn_msg != actual, %0d != %0d",
                $time(), predicted, cn_msg_int );
    
    predicted_counter[node]++;
  end
end

///////////////
// DUT + RAM //
///////////////
wire                         dnmsg_we;
wire[7+FOLDFACTOR-1:0]       dnmsg_wraddr;
wire[7+FOLDFACTOR-1:0]       dnmsg_rdaddr;
wire[17+4*(LLRWIDTH-1)+31:0] dnmsg_din;
wire[17+4*(LLRWIDTH-1)+31:0] dnmsg_dout;

ldpc_cn #( .FOLDFACTOR    ( FOLDFACTOR ),
           .LLRWIDTH      ( LLRWIDTH )
) ldpc_cn_i(
  .clk              (clk),
  .rst              (rst),
  .llr_access       (llr_access),
  .llr_addr         (llr_addr),
  .llr_din_we       (llr_din_we),
  .iteration        (iteration),
  .first_half       (first_half),
  .first_iteration  (first_iteration),
  .cn_we            (cn_we),
  .cn_rd            (cn_rd),
  .disable_paritymsg(disable_paritymsg),
  .addr_cn          (addr_cn),
  .sh_msg           (sh_msg),
  .cn_msg           (cn_msg),
  .dnmsg_we         (dnmsg_we),
  .dnmsg_wraddr     (dnmsg_wraddr),
  .dnmsg_rdaddr     (dnmsg_rdaddr),
  .dnmsg_din        (dnmsg_din),
  .dnmsg_dout       (dnmsg_dout)
);

ldpc_ram_behav #(
  .WIDTH    ( 17+4*(LLRWIDTH-1)+32 ),
  .LOG2DEPTH( 7+FOLDFACTOR )
) ldpc_cnholder_i (
  .clk   ( clk ),
  .we    ( dnmsg_we ),
  .din   ( dnmsg_din ),
  .wraddr( dnmsg_wraddr ),
  .rdaddr( dnmsg_rdaddr ),
  .dout  ( dnmsg_dout )
);

endmodule

