//import "DPI-C" function
//int gaussian( input int  stddev );
//void gaussian( input int  length,
               //input int  stddev,
               //output int result[64800] );


`timescale 1ns/10ps

module tb_ldpc12();

localparam CLK_PERIOD = 5ns;
localparam HOLD       = 1ns;

localparam EBN0_MIN      = 0.6;
localparam EBN0_MAX      = 2.95;
localparam EBN0_STEP     = 0.1;
localparam CODE_TYPE     = "1_2";

localparam LLRWIDTH = 6;

//////////
// Clocks
//////////
logic clk;
logic rst;

initial
begin
  clk <= 1'b0;
  forever
    #(CLK_PERIOD /2) clk <= ~clk;
end

initial
begin
  rst <= 1'b1;

  repeat(3) @(posedge clk);
  rst <= #HOLD 1'b0;
end

// VCS was crashing with my old testbench, so I simplified dramatically and got rid of
// SystemVerilog classes

int debug_level; // -1=no output, 0=report error, 1=display some info, 2=display lots
string label = CODE_TYPE;

// Data
int n;
int k;
int q;
int word_width;

// Parity function
int h_defs_file;
int h_defs_height;
int h_defs_width;
int h_defs[];

// binary data
int orig_data[64800];
int coded_data[64800];
int decoded_data[64800];

// data after AWGN
real ebn0, N0;
real r[64800];
int  r_quantized[64800];

///////////////
// Functions
///////////////
function void encode();
  int parity_bits[];
  
  parity_bits = new[n-k];

  for( int rownum=0; rownum<h_defs_height; rownum++ )
    for( int colnum=0; colnum<h_defs_width; colnum++ )
    begin
      int base_position;

      base_position = h_defs[rownum*h_defs_width + colnum];

      if( base_position!=-1 )
        for( int local_offset=0; local_offset<360; local_offset++ )
        begin
          int parity_address;
          parity_address = (base_position + local_offset*q) % (n-k);

          parity_bits[parity_address] ^= orig_data[rownum*360 + local_offset];
        end
    end
  
  for( int parityloc=1; parityloc<n-k; parityloc++ )
    parity_bits[parityloc] ^= parity_bits[parityloc-1];

  // Copy input to output
  for( int j=0; j<n; j++ )
  begin
    if( j<k )
      coded_data[j] = -2*orig_data[j] +1;
    else
      coded_data[j] = -2*parity_bits[j-k] +1;
  end

  parity_bits.delete();
endfunction

// Add noise to coded data and store result in r
function void genNoiseVec( output real result[64800], input real ebn0db );
  string filename;
  real rand_noise_vec[10000];
  int noise_file;
  int check_eof;

  int db_int;
  int db_tenths;
  char db_int_char;
  char db_tenths_char;
  if( ebn0db>=2.0 )
    db_int = 2;
  else if( ebn0db>=1.0 )
    db_int = 1;
  else
    db_int = 0;
  db_tenths = int'(10*ebn0db) %10;
  db_int_char    = ( int'("0") + db_int );
  db_tenths_char = ( int'("0") + db_tenths );
  
$display("");
  filename  = { "noise_", CODE_TYPE, "_", db_int_char, "pt", db_tenths_char };
$display( "opening file %s", filename );

  noise_file = $fopen( filename, "r" );

  for( int i=0; i<10000; i++ )
    check_eof = $fscanf( noise_file, "%f", rand_noise_vec[i] );

  for( int i=0; i<n; i++ )
    result[i] = rand_noise_vec[ { $random() } % 10000  ];

for( int i=n-10; i<n; i++ )
  $display( "noise vec: %0d=%0f", i, result[i] );

  $fclose( noise_file );
endfunction

function void AddNoise( real ebn0db );
  real noisevec[64800];
  real rate;

  rate = (1.0*k)/ (1.0*n);

  N0 = 10.0**(-ebn0db/10.0) / rate / 2.0;
  $display( "RATE, N0 = %0f, %0f", rate, N0 );

  genNoiseVec( noisevec, ebn0db );

  // print noise vector
  for( int j=0; j<n; j++ )
    if( debug_level>1 ) $display( "noise %d = %f", j, noisevec[j] );

  // add noise vector
  for( int j=0; j<n; j++ )
    r[j] = 1.0*coded_data[j] + noisevec[j];

  // Convert to LLR
  // Based on IT++: LLR=received * 4 / N0   (I don't know why)
  for( int i=0; i<n; i++ )
    r[i] *= 4.0 / N0;

endfunction

// Quantize LLR to a few bits
function void QuantizeLlr( int llr_bits );
  real MAXVAL;
  int table_range;
  real quant_table[2048]; // only 2*table_range is used!
  
  MAXVAL      = 12.0 / N0;
  table_range = 1<<(llr_bits-1);
  
  // build table
  for( int i=0; i<2*table_range; i++ )
  begin
    quant_table[i] = 0.5*i * MAXVAL / (1.0*table_range-1.0);
    //if( this.debug_level>0 ) $display( "quant table[%0d] = %0f", i, quant_table[i] );
  end
  
  // find correct place in table for all values
  for( int i=0; i<n; i++ )
  begin
    int orig_sign;
    int j;
    
    orig_sign = r[i] < 0.0 ? -1 : 1;
    j=2*table_range-1;
    
    while( (r[i]*orig_sign) < quant_table[j] )
      j--;
    
    j = j>>1;
    
    r_quantized[i] = orig_sign * j;
  end
  
  if( debug_level>1 )
    for( int i=0; i<10; i++ )
      $display( "%0d --> %0d --> %0f --> %0d", orig_data[i], coded_data[i], r[i], r_quantized[i] );
endfunction

// Compare signs of r_quantized and coded_data to return number of errors
function int CountOrigErrs();
  CountOrigErrs = 0;
  
  for( int i=0; i<n; i++ )
    if( ((r_quantized[i]<0)  && (coded_data[i]>=0)) ||
        ((r_quantized[i]>=0) && (coded_data[i]<0)) )
      CountOrigErrs++;
endfunction

// Compare signs of r_quantized and coded_data to return number of errors after decode
function int CountDecodedErrs();
  CountDecodedErrs = 0;
  
  for( int i=0; i<n; i++ )
    if( ((decoded_data[i]<0)  && (coded_data[i]>=0)) ||
        ((decoded_data[i]>=0) && (coded_data[i]<0)) )
      CountDecodedErrs++;
endfunction

  
  

//////////////////////////
// Read matrix from file
//////////////////////////
// Variables for file input
int found_target;
string    oneline;
string    locallabel;
int       temp_i;

initial
begin
  if( debug_level>0 )
    $display( "Creating object" );

  // H is a sparse matrix. The location of each one is stored as an integer.
  // -1 is used to represent unused memory locations.
  h_defs_file = $fopen( "dvbs2_hdef.txt", "r" );

  if( !h_defs_file )
    $stop( "File dvbs2_hdef.txt not found\n" );
  h_defs_width  = 30;

  found_target = 0;

  while( !found_target )
  begin
    temp_i = $fgets( oneline, h_defs_file );
    temp_i = $sscanf( oneline, "label %s lines %d n %d q %d", locallabel, h_defs_height, n, q );

    if( label==locallabel )
      found_target = 1;
    else // discard this group
      for( int linenum=0; linenum<h_defs_height; linenum++ )
        temp_i = $fgets( oneline, h_defs_file );
    
    if( $feof(h_defs_file) )
    begin
      $fclose(h_defs_file);
      $stop( "Didn't find requested code type!" );
    end
  end

  // at this point, the label has been found and the file pointer is at the correct position
  h_defs = new[h_defs_height*h_defs_width];

  // fill array with -1
  for( int hdef_pos=0; hdef_pos<h_defs_height*h_defs_width; hdef_pos++ )
    h_defs[hdef_pos] = -1;

  // put correct values in array
  for( int linenum=0; linenum<h_defs_height; linenum++ )
  begin
    int eol;
    string c;
    string onechar;
    string oneword;
    int word_offset;

    eol         = 0;
    oneword     = "";
    word_offset = 0;

    while( !$feof(h_defs_file) && !eol )
    begin
      c       = $fgetc( h_defs_file );
      // onechar = (string)c;
      eol     = (c=="\n");
      oneword = { oneword, c };

      if( eol || (c==" ") )
      begin
        temp_i = $sscanf( oneword, "%d", h_defs[linenum*h_defs_width + word_offset] );

        word_offset = word_offset + 1;
        oneword     = "";
      end
    end
  end
        
  $fclose(h_defs_file);

  k = n - 360*q;
end

//////////////
// Transactors
//////////////
// Load data into LLR
// LLR I/O
logic      llr_access;
logic[7:0] llr_addr;
logic      llr_din_we;
logic[LLRWIDTH-1:0] llr_din;
bit signed[LLRWIDTH-1:0]  llr_dout;

// start command; completion indicator
logic      start;
logic[4:0] mode;
logic[5:0] iter_limit;
bit        done;

initial
begin
  debug_level = 0;
  label       = CODE_TYPE;

  llr_access  <= 0;
  llr_addr    <= 0;
  llr_din_we  <= 0;
  llr_din     <= 0;
  start       <= 0;
  mode        <= 0;
  iter_limit  <= 30;

  @( posedge rst );
  repeat( 5 ) @( posedge clk );

  for( real ebn0dB=EBN0_MIN; ebn0dB<EBN0_MAX; ebn0dB+=EBN0_STEP )
  begin
    int err_bits;
    int tested_bits;
    real ber_result;
    
    err_bits    = 0;
    tested_bits = 0;

    while( (err_bits<1000) && (tested_bits<1000000) )
    begin
      // create random data
      for( int i=0; i<k; i++ )
        orig_data[i] = {$random()} % 2;

      encode();

      AddNoise( ebn0dB );
      QuantizeLlr( LLRWIDTH );

      // begin testing DUT
      llr_access <= 1;
      @(posedge clk);

      // write normal data bits
      for( int i=0; i<k; i++ )
      begin
        int wr_val;
        int abs_wr_val;

        wr_val = r_quantized[i];
        abs_wr_val = wr_val < 0 ? -1*wr_val : wr_val;
        
        llr_addr   <= #HOLD i/360;
        llr_din_we <= #HOLD (i%360)==359;
        llr_din    <= #HOLD (wr_val<0) ? { 1'b1, abs_wr_val[LLRWIDTH-2:0] }
                                       : { 1'b0, abs_wr_val[LLRWIDTH-2:0] };
        @( posedge clk );
      end

      // write parity bits
      for( int i=0; i<(n-k); i++ )
      begin
        int rotate_pos;
        int wr_val;
        int abs_wr_val;
        
        rotate_pos = k + (i/360) + ((i%360)*q);
        
        llr_addr   <= #HOLD (k + i)/360;
        llr_din_we <= #HOLD (i%360)==359;
        
        wr_val = r_quantized[rotate_pos];
        abs_wr_val = wr_val < 0 ? -1*wr_val : wr_val;
        
        llr_din    <= #HOLD (wr_val<0) ? { 1'b1, abs_wr_val[LLRWIDTH-2:0] }
                                       : { 1'b0, abs_wr_val[LLRWIDTH-2:0] };
        @( posedge clk );
      end

      llr_din_we <= #HOLD 0;
      llr_access <= #HOLD 0;
      @( posedge clk );

      //controls
      start <= #HOLD 1;
      
      case( CODE_TYPE )
        "1_4":    mode <= #HOLD 0;
        "1_3":    mode <= #HOLD 1;
        "2_5":    mode <= #HOLD 2;
        "1_2":    mode <= #HOLD 3;
        "3_5":    mode <= #HOLD 4;
        "2_3":    mode <= #HOLD 5;
        "3_4":    mode <= #HOLD 6;
        "4_5":    mode <= #HOLD 7;
        "5_6":    mode <= #HOLD 8;
        "8_9":    mode <= #HOLD 9;
        "9_10":   mode <= #HOLD 10;
        "1_5s":   mode <= #HOLD 11;
        "1_3s":   mode <= #HOLD 12;
        "2_5s":   mode <= #HOLD 13;
        "4_9s":   mode <= #HOLD 14;
        "3_5s":   mode <= #HOLD 15;
        "2_3s":   mode <= #HOLD 16;
        "11_15s": mode <= #HOLD 17;
        "7_9s":   mode <= #HOLD 18;
        "37_45s": mode <= #HOLD 19;
        "8_9s":   mode <= #HOLD 20;
        default: $stop( "Illegal code type!" );
      endcase
      @( posedge clk );
      start <= #HOLD 0;
      @( posedge clk );

      // read data out
      @(posedge done);
      @(posedge clk);

      llr_addr   <= #HOLD 0;
      llr_access <= #HOLD 1;
      @(posedge clk);

      // read normal data bits
      for( int i=0; i<k; i++ )
      begin
        int result;
        
        if( (i%360)==0 )
        begin
          llr_addr   <= #HOLD i/360;
          repeat(2) @(posedge clk);
          llr_din_we <= #HOLD 1; //load up from RAM
          @( posedge clk );
          llr_din_we <= #HOLD 0;
          @( posedge clk );
        end

        llr_din <= #HOLD { LLRWIDTH{1'bX} };
        
        result = llr_dout[LLRWIDTH-1] ? -1 * llr_dout[LLRWIDTH-2:0]
                                      : llr_dout[LLRWIDTH-2:0];
        decoded_data[i] = result;
        //if( i<10 ) $display( "After decode: pos=%0d, result=%0d", i, result );
        @( posedge clk );
      end
      
      $display( "Begin read parity bits" );
      // read parity bits
      for( int i=0; i<(n-k); i++ )
      begin
        int result;
        int rotate_pos;
        
        if( ((k + i)%360)==0 )
        begin
          llr_addr <= #HOLD (k + i)/360;
          repeat(2) @(posedge clk);
          llr_din_we <= #HOLD 1; //load up from RAM
          @( posedge clk );
          llr_din_we <= #HOLD 0;
          @( posedge clk );
        end
        
        rotate_pos = k + (i/360) + ((i%360)*q);
        
        llr_din    <= #HOLD { LLRWIDTH{1'bX} };
        
        result = llr_dout[LLRWIDTH-1] ? -1 * llr_dout[LLRWIDTH-2:0]
                                      : llr_dout[LLRWIDTH-2:0];
        decoded_data[rotate_pos] = result;
        @( posedge clk );
      end

      llr_din_we <= #HOLD 0;
      llr_access <= #HOLD 0;
      @( posedge clk );
      
      tested_bits += 64800;
      err_bits    += CountDecodedErrs();
    end
      
    $write( "EbN0 = %0fdB: ", ebn0dB );
    ber_result = 1.0*err_bits / (1.0*tested_bits);
    $write( "%0d errs / %0d bits ==> BER = %0f\n", err_bits, tested_bits, ber_result );
  end
    
  h_defs.delete();
  $finish();
end

////////////
// Instance
////////////
ldp_top ldp_top_i(
  .clk(clk),
  .rst(rst),

  .llr_access (llr_access),
  .llr_addr   (llr_addr),
  .llr_din_we (llr_din_we),
  .llr_din    (llr_din),
  .llr_dout   (llr_dout),

  .start     (start),
  .mode      (mode),
  .iter_limit(iter_limit),
  .done      (done)
);

endmodule
