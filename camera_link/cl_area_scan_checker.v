//
//
//


module cl_area_scan_checker
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

  task init;
  input integer fpa_outputs;
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
  input integer pixel_counter;
    begin

      if( cl_base_format )
        begin
          if( cl_data[15:0] != pixel_counter )
            begin
              log.inc_fail_count;
              $display( "-!- %16.t | %m: data error at pixel 0x%4x. Pixel is 0x%4x and should be 0x%4x", $time, pixel_counter, cl_data[15:0], pixel_counter );
            end
        end
      else if( cl_full_format )
        begin
          if( (cl_data[15:0] != pixel_counter) | (cl_data[31:16] != (pixel_counter + 1)) | (cl_data[47:32] != (pixel_counter + 2)) | (cl_data[63:48] != (pixel_counter + 3)) )
            begin
              log.inc_fail_count;
              $display( "-!- %16.t | %m: data error somewhere between pixel 0x%4x and 0x%4x.", $time, pixel_counter, pixel_counter + 4 );
            end
        end

   end
  endtask


  // --------------------------------------------------------------------
  //
  always @(negedge cl_clk)
    if( cl_data_en )
      checker( cl_pixel_counter );



endmodule

