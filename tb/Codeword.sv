class Codeword;
  // Basic descriptors
  string  name;
  string  label;
  int number;
  int debug_level; // -1=no output, 0=report error, 1=display lots of status info

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
  int orig_data[];
  int coded_data[];
  int decoded_data[];

  // data after AWGN
  real ebn0, N0;
  real r[];
  int  r_quantized[];

  // Log file
  int    log_level; // -1=no log file, 0=add to log when function is called, 1=log each iteration
  int    logfile;
  string logfilename;

  // Status
  logic valid_codeword;
  real  certainty_history[];



  /////////////
  // Constructor
  /////////////
  function new( string label,
                int    debug_level  = 0,
                int    log_level    = -1,
                string logfilename  = "",
                int    number       = 0,
                string name         = "Codeword" );

    int found_target;
    string    oneline;
    string    locallabel;
    int       temp_i;

    this.label       = label;
    this.number      = number;
    this.debug_level = debug_level;
    this.debug_level = log_level;
    this.logfilename = logfilename;
    this.name        = name;

    // check for bad settings
    assert( debug_level>-2 ) else disp_error( "Debug level may be -1, 0 or 1" );
    assert( debug_level<2 )  else disp_error( "Debug level may be -1, 0 or 1" );
    assert( log_level>-2 )   else disp_error( "Log level may be -1, 0 or 1" );
    assert( log_level<2 )    else disp_error( "Log level may be -1, 0 or 1" );

    // log filename must be specified unless no log is requested
    assert( (logfilename!="") || (log_level==-1) ) else disp_error( "Specify file name" );

    if( debug_level>0 )
      note( "Creating object" );

    // H is a sparse matrix. The location of each one is stored as an integer.
    // -1 is used to represent unused memory locations.
    h_defs_file = $fopen( "dvbs2_hdef.txt", "r" );

    if( !h_defs_file )
      disp_error( "File dvbs2_hdef.txt not found" );
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
        disp_error( "Didn't find requested code type!" );
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
      byte c;
      string oneword;
      int word_offset;

      eol         = 0;
      oneword     = "";
      word_offset = 0;

      while( !$feof(h_defs_file) && !eol )
      begin
        c       = $fgetc( h_defs_file );
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

    // allocate array memory
    orig_data    = new[k];
    coded_data   = new[n];
    decoded_data = new[n];
    r            = new[n];
    r_quantized  = new[n];

    // Create logfile, if necessary
    if( (log_level>-1) && (logfilename!="") )
    begin
      // check whether file exists
      logfile = $fopen( logfilename, "a" );

      // if file does not exist, create file
      if( logfile==0 )
        logfile = $fopen( logfilename, "w" );

      if( logfile==0 ) // error in file creation
      begin
        if( debug_level!=-1 )
          disp_error( "Could not create or append to file" );
        log_level = -1;  // turn off file output
      end
      else
      begin
        file_write( "New Codeword" );
        $fwrite( logfile, "\n" );
        $fclose( logfile );
      end
    end
  endfunction



  ////////////////////////////////////////////////
  // Screen, file output
  // Use these functions for a consistent output format
  ////////////////////////////////////////////////
  function void note( string note_msg );
    $display( "%0t\t%s\t%d\tnote\t%s", $time, name, number, note_msg );
  endfunction

  function void disp_error( string err_msg );
    if( log_level!=-1 )
      $display( "%0t\t%s\t%d\tERROR\t%s", $time, name, number, err_msg );
  endfunction

  function void file_write( string file_msg );
    $fwrite( logfile, "%0t\t%s\t%d\tERROR\t", $time, name, number );
  endfunction



  ////////////////////////////////////////////////////////
  // read_msg reads a message from a file and stores it in memory
  ////////////////////////////////////////////////////////
  function void read_msg( string inpfilename, int line_number );
    int inp_file;
    int     i; // loop variable
    byte    c;
    int     fgets_result;
    string  unused_line;

    inp_file = $fopen( inpfilename, "r" );

    // set to all 0's by default
    for( i=0; i<k; i++ )
      orig_data[i] = 1;


    if( inp_file==0 ) // error in file creation
    begin
      if( debug_level!=-1 )
        disp_error( "Could not create/append to file" );
    end
    else
    begin
      // read to correct line number
      i = (line_number<1) ? 1 : line_number;
      while( !$feof( inp_file ) && (i!=1) )
      begin
        fgets_result = $fgets( unused_line, inp_file );
        i--;
      end

      i=0;
      while( !$feof( inp_file ) && (i<k) )
      begin
        c = $fgetc( inp_file );
        if( c!="0" )
          orig_data[i] = 1;
        i++;
      end

      $fclose( inp_file );
    end
  endfunction



  ///////////////////////////////////////////////
  // randomize message creates a random input message
  ///////////////////////////////////////////////
  function void create_random_msg( );
    orig_data[0] = $random(0); // does this set the seed?  I hope so.

    for( int i=0; i<k; i++ )
      orig_data[i] = {$random()} % 2;
  endfunction



  ////////////////////
  // Fetch some values
  ////////////////////
  function int GetN( );
    GetN = n;
  endfunction

  function int GetK( );
    GetK = k;
  endfunction

  function int GetQ( );
    GetQ = q;
  endfunction

  function int GetVal( int pos );
    GetVal = r_quantized[pos];
  endfunction

  function void SetDecoded( int pos, int newval );
    //if( ((newval<0)  && (coded_data[pos]>=0)) ||
    //    ((newval>=0) && (coded_data[pos]<0)) )
    //  $display( "Setting pos %0d = %0d, orig = %0d", pos, newval, coded_data[pos] );
    decoded_data[pos] = newval;
  endfunction



  ////////////////////////////////////////////////////////////
  // encode creates the parity bits, according to the
  // procedure described in the standard
  ////////////////////////////////////////////////////////////
  function void encode();
    int h_pointer;
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



  ///////////////////////
  // Add AWGN
  ///////////////////////
  function void genNoiseVec( output real result[64800], input real ebn0db );
    string filename;
    real rand_noise_vec[10000];
    int noise_file;
    int check_eof;

    int db_int;
    int db_tenths;
    int db_int_char;
    int db_tenths_char;
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
    filename  = { "noise_", label, "_", db_int_char, "pt", db_tenths_char };
  $display( "opening file %s", filename );

    noise_file = $fopen( filename, "r" );

    for( int i=0; i<10000; i++ )
      check_eof = $fscanf( noise_file, "%f", rand_noise_vec[i] );

    for( int i=0; i<n; i++ )
      result[i] = rand_noise_vec[ { $random() } % 10000  ];

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


  ///////////////////////
  // Quantize LLR to a few bits
  ///////////////////////
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



  ///////////////////////
  // Count Errors
  ///////////////////////
  function int CountOrigErrs();
    CountOrigErrs = 0;

    for( int i=0; i<n; i++ )
      if( ((r_quantized[i]<0)  && (coded_data[i]>=0)) ||
          ((r_quantized[i]>=0) && (coded_data[i]<0)) )
        CountOrigErrs++;
  endfunction

  function int CountDecodedErrs();
    CountDecodedErrs = 0;

    for( int i=0; i<n; i++ )
      if( ((decoded_data[i]<0)  && (coded_data[i]>=0)) ||
          ((decoded_data[i]>=0) && (coded_data[i]<0)) )
      begin
        if( CountDecodedErrs<500 )
        $display( "mismatch %0d %0d-->%0d", i, r_quantized[i], decoded_data[i] );
        CountDecodedErrs++;
      end
  endfunction

  ///////////////////////
  // Display unencoded data
  ///////////////////////
  function void print_orig();
    string string_msg;

    //note( "Original data" );

    string_msg = "";

    for( int i=0; i<k; i++ )
    begin
      if( orig_data[i] )
        string_msg = {string_msg, "1"};
      else
        string_msg = {string_msg, "0"};
    end
      //note( string_msg );
  endfunction



  //////////////////////
  // Display encoded data
  //////////////////////
  function void print_encoded();
    string string_msg;

    //note( "Encoded data" );

    string_msg = "";

    for( int i=0; i<n; i++ )
    begin
      if( coded_data[i] )
        string_msg = {string_msg, "1"};
      else
        string_msg = {string_msg, "0"};
    end

    note( string_msg );
  endfunction



  //////////////////////////
  // Increment packet number
  //////////////////////////
  function void inc( );
    number++;
  endfunction



  // De-allocate memory
  function void delete();
    orig_data.delete();
    coded_data.delete();
    r.delete();
    r_quantized.delete();
    h_defs.delete();
  endfunction
endclass

