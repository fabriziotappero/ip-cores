//
//
//


module cl_line_scan_checker
  (
    input               cl_fval,
    input               cl_lval,
    input               cl_dval,
    input       [63:0]  cl_data,
    input               cl_clk,

    input               cl_reset
  );

  // --------------------------------------------------------------------
  //
  wire [13:0] cl_pixel_counter;
  wire [15:0] cl_frame_x;
  wire [15:0] cl_frame_y;
  wire        cl_fval_fall;
  wire        cl_fval_rise;
  wire        cl_lval_fall;
  wire        cl_lval_rise;
  wire        cl_data_en;
  reg         cl_base_format = 0;
  reg         cl_full_format = 0;

  cl_util
    util
    (
      .cl_fval(cl_fval),
      .cl_lval(cl_lval),
      .cl_dval(cl_dval),
      .cl_data(cl_data),
      .cl_clk(cl_clk),

      .cl_base_format(cl_base_format),
      .cl_full_format(cl_full_format),

      .cl_fval_fall(cl_fval_fall),
      .cl_fval_rise(cl_fval_rise),
      .cl_lval_fall(cl_lval_fall),
      .cl_lval_rise(cl_lval_rise),
      .cl_data_en(cl_data_en),

      .cl_pixel_counter(cl_pixel_counter),
      .cl_frame_x(cl_frame_x),
      .cl_frame_y(cl_frame_y),

      .cl_reset(cl_reset)
    );


  // --------------------------------------------------------------------
  //
  reg [15:0]  cl_base_data_lenght;
  reg [15:0]  cl_base_eod_index;
  reg [15:0]  cl_base_id_index;

  task init;
  input integer fpa_outputs;
  input reg [15:0]  data_lenght;
  input reg [15:0]  eod_index;
  input reg [15:0]  id_index;
    begin

      cl_base_format = 0;
      cl_full_format = 0;
      
      if( (fpa_outputs == 1) | (fpa_outputs == 2) )
        begin
          $display( "-!- %16.t | %m: FPA with %0d outputs. Assuming Base CameraLink Format", $time, fpa_outputs );
          cl_base_format = 1;
        end
      else if( (fpa_outputs == 4) | (fpa_outputs == 8) )
        begin
          $display( "-!- %16.t | %m: FPA with %0d outputs. Assuming Full CameraLink Format", $time, fpa_outputs );
          cl_full_format = 1;
        end
      else
        begin
          $display( "-!- %16.t | %m: FPA with %0d not supported.", $time, fpa_outputs );
          $stop();
        end

      cl_base_data_lenght = data_lenght;
      cl_base_eod_index   = eod_index;
      cl_base_id_index    = id_index;

    end
  endtask
  
  task disable_checker;
    begin

      cl_base_format = 0;
      cl_full_format = 0;

    end
  endtask


  // --------------------------------------------------------------------
  //
  task checker;
  input integer frame_x;
    begin

      if( frame_x < cl_base_data_lenght )
        if( cl_data[15:0] != frame_x )
          begin
            log.inc_fail_count;
            $display( "-!- %16.t | %m: data error at pixel %x. Pixel is %x and should be %x", $time, frame_x, cl_data[15:0], frame_x );
          end
      else if((cl_base_eod_index == frame_x) | ( (cl_base_eod_index + 1) == frame_x ))
        if(cl_data[15:0] != FPA_EOD)
          begin
            log.inc_fail_count;
            $display( "-!- %16.t | %m: EOD error at pixel %x.", $time, frame_x );
          end
      else if( cl_base_id_index <= frame_x )
        if( cl_data[15:0] != ( (frame_x - cl_base_id_index) + 16'h0e00 ) )
          begin
            log.inc_fail_count;
            $display( "-!- %16.t | %m: EOD error at pixel %x.", $time, frame_x );
          end

   end
  endtask


  // --------------------------------------------------------------------
  //
  always @(negedge cl_clk)
    if( cl_data_en )
      checker( cl_frame_x );



endmodule



