//
//
//


module cl_util
  (
    input               cl_fval,
    input               cl_lval,
    input               cl_dval,
    input       [63:0]  cl_data,
    input               cl_clk,

    input               cl_base_format,
    input               cl_full_format,

    output              cl_fval_fall,
    output              cl_fval_rise,
    output              cl_lval_fall,
    output              cl_lval_rise,
    output              cl_data_en,

    output reg  [13:0]  cl_pixel_counter,
    output reg  [15:0]  cl_frame_x,
    output reg  [15:0]  cl_frame_y,

    input               cl_reset
  );

  // --------------------------------------------------------------------
  //
  task get_frames;
  input integer count;
    begin

      repeat(count) @(negedge cl_fval);

      $display( "-!- %16.t | %m: got %0d frames.", $time, count );

   end
  endtask


  // --------------------------------------------------------------------
  //  cl_fval & cl_lval edge detector
  reg     cl_fval_r;
  assign  cl_fval_fall = ~cl_fval & cl_fval_r;
  assign  cl_fval_rise = cl_fval & ~cl_fval_r;

  always @(posedge cl_clk)
    cl_fval_r <= cl_fval;

  reg     cl_lval_r;
  assign  cl_lval_fall = ~cl_lval & cl_lval_r;
  assign  cl_lval_rise = cl_lval & ~cl_lval_r;

  always @(posedge cl_clk)
    cl_lval_r <= cl_lval;


  // --------------------------------------------------------------------
  //  pixel counter
  always @(posedge cl_clk)
    if( ~cl_fval | cl_reset | (cl_pixel_counter > 14'h3ff0) )
      cl_pixel_counter <= 0;
    else if( cl_data_en )
      if( cl_base_format )
        cl_pixel_counter <= cl_pixel_counter + 1;
      else if( cl_full_format )
        cl_pixel_counter <= cl_pixel_counter + 4;


  // --------------------------------------------------------------------
  //  frame x coordinate
  always @(posedge cl_clk)
    if( ~cl_fval | ~cl_lval | cl_reset )
      cl_frame_x <= 0;
    else if( cl_data_en )
      if( cl_base_format )
        cl_frame_x <= cl_frame_x + 1;
      else if( cl_full_format )
        cl_frame_x <= cl_frame_x + 4;


  // --------------------------------------------------------------------
  //  frame y coordinate
  always @(posedge cl_clk)
    if( ~cl_fval | cl_reset )
      cl_frame_y <= 0;
    else if( cl_lval_fall )
      cl_frame_y <= cl_frame_y + 1;


  // --------------------------------------------------------------------
  //
  integer cl_line_width;
  integer cl_height;
  integer cl_width;

  always @(posedge cl_clk)
    if( cl_fval_rise | cl_reset )
      cl_line_width <= 0;
    else if( cl_lval_fall )
      cl_line_width <= cl_frame_x;

  always @(posedge cl_clk)
    if( cl_fval_fall )
      cl_height <= cl_frame_y;

  always @(posedge cl_clk)
    if( cl_fval_fall )
      cl_width <= cl_line_width;

  task display_frame_size;
    begin

      $display( "-!- %16.t | %m: last frame size was %0dX%0d.", $time, cl_width, cl_height );

   end
  endtask

  task validate_frame_size;
  input integer width;
  input integer height;
    begin

      if( (height != cl_height) | (width != cl_width) )
        begin
          log.inc_fail_count;
          $display( "-!- %16.t | %m: last frame size should be %0dX%0d but was %0dX%0d", $time, width, height, cl_width, cl_height );
        end

   end
  endtask


  // --------------------------------------------------------------------
  //  outputs
  assign cl_data_en = cl_dval & cl_lval & cl_fval;


endmodule



