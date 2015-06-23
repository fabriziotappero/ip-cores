// --------------------------------------------------------------------
//

typedef struct
  {
    int pixel[];
  } line_s;


class video_frame_class;
  rand int  frame_id;
  rand int  pixels_per_line;
  rand int  lines_per_frame;
  rand int  bits_per_pixel;
  line_s    lines[];

  constraint default_pixels_per_line
  {
    pixels_per_line >= 4;
    pixels_per_line % 2 == 0;
    pixels_per_line <= 16384;
  }

  constraint default_lines_per_frame
  {
    lines_per_frame >= 4;
    lines_per_frame % 2 == 0;
    lines_per_frame <= 16384;
  }

  constraint default_bits_per_pixel
  {
    bits_per_pixel >= 1 && bits_per_pixel <= 16;
  }


  //--------------------------------------------------------------------
  function new;
    this.frame_id = 0;
  endfunction: new

  extern virtual function void init
  (
    input int  pixels_per_line,
    input int  lines_per_frame,
    input int  bits_per_pixel
  );

  extern virtual function void make_constant
  (
    input int  pixel
  );

  extern virtual function void make_counting();

  extern virtual function void make_random();

  extern virtual function void copy
  (
    ref video_frame_class to
  );

  extern virtual function int compare
  (
    input int max_mismatches,
    ref video_frame_class to
  );
  
  extern virtual function void print_line
  (
    input int line,
    input int pixel,
    input int count
  );

endclass: video_frame_class


  // --------------------------------------------------------------------
  //
  function void video_frame_class::init
  (
    input int  pixels_per_line,
    input int  lines_per_frame,
    input int  bits_per_pixel
  );
  
    $display("^^^ %16.t | %m", $time);
  
    this.pixels_per_line = pixels_per_line;
    this.lines_per_frame = lines_per_frame;
    this.bits_per_pixel = bits_per_pixel;
    
    this.make_constant( 0 );
    
  endfunction: init


  // --------------------------------------------------------------------
  //
  function void video_frame_class::make_constant
  (
    input int  pixel
  );
  
    $display("^^^ %16.t | %m", $time);

    this.lines = new[lines_per_frame];

    foreach( this.lines[l] )
    begin

      this.lines[l].pixel = new[pixels_per_line];

      foreach( this.lines[l].pixel[p] )
        this.lines[l].pixel[p] = pixel;

    end

  endfunction: make_constant


  // --------------------------------------------------------------------
  //
  function void video_frame_class::make_counting();
  
    $display("^^^ %16.t | %m", $time);

    this.lines = new[lines_per_frame];

    foreach( this.lines[l] )
    begin

      this.lines[l].pixel = new[pixels_per_line];

      foreach( this.lines[l].pixel[p] )
        this.lines[l].pixel[p] = (pixels_per_line * l) + p;

    end

  endfunction: make_counting


  // --------------------------------------------------------------------
  //
  function void video_frame_class::make_random();
  
    $display("^^^ %16.t | %m", $time);

    this.lines = new[lines_per_frame];

    foreach( this.lines[l] )
    begin

      this.lines[l].pixel = new[pixels_per_line];

      foreach( this.lines[l].pixel[p] )
        this.lines[l].pixel[p] = $urandom_range( ((2 ** bits_per_pixel) - 1), 0 );

    end

  endfunction: make_random


  // --------------------------------------------------------------------
  //
  function void video_frame_class::copy
  (
    ref video_frame_class to
  );
  
    $display("^^^ %16.t | %m", $time);

    to.frame_id = this.frame_id;
    to.pixels_per_line = this.pixels_per_line;
    to.lines_per_frame = this.lines_per_frame;
    to.bits_per_pixel =this.bits_per_pixel ;

    to.lines = new[lines_per_frame];

    foreach( this.lines[l] )
    begin

      to.lines[l].pixel = new[pixels_per_line];

      foreach( this.lines[l].pixel[p] )
        to.lines[l].pixel[p] = this.lines[l].pixel[p];

    end
  endfunction: copy


  // --------------------------------------------------------------------
  //
  function int video_frame_class::compare
  (
    input int max_mismatches,
    ref video_frame_class to
  );

    int mismatch_count = 0;
  
    $display("^^^ %16.t | %m", $time);

    if( to.pixels_per_line != this.pixels_per_line )
    begin
      $display( "^^^ %16.t | to.pixels_per_line != this.pixels_per_line", $time );
      return( -1 );
    end

    if( to.lines_per_frame != this.lines_per_frame )
    begin
      $display( "^^^ %16.t | to.lines_per_frame != this.lines_per_frame", $time );
      return( -2 );
    end

    if( to.bits_per_pixel != this.bits_per_pixel )
    begin
      $display( "^^^ %16.t | to.bits_per_pixel != this.bits_per_pixel", $time );
      return( -3 );
    end

      foreach( this.lines[l] )
      begin
        foreach( this.lines[l].pixel[p] )
          if( to.lines[l].pixel[p] != this.lines[l].pixel[p] )
          begin

            if( max_mismatches > 0 )
              mismatch_count++;

              $display( "^^^ %16.t | mismatch @ frame[%4h][%4h] | to == %4h | this == %4h ", $time, l, p, to.lines[l].pixel[p], this.lines[l].pixel[p] );

            if( mismatch_count > max_mismatches )
              return( mismatch_count );

          end
      end

      return( mismatch_count );

  endfunction: compare


  // --------------------------------------------------------------------
  //
  function void video_frame_class::print_line
  (
    input int line,
    input int pixel,
    input int count
  );

    $display("^^^ %16.t | %m", $time);
  
    for( int i = 0; i < count; i++ )
      $display( "^^^ %16.t |  %4h @ frame[%4h][%4h]", $time, this.lines[line].pixel[(pixel + i)], line, pixel );

  endfunction: print_line


