// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "../../../src/video_frame_class.sv"


module the_test(
                input tb_clk,
                input tb_rst
              );

  // --------------------------------------------------------------------
  //
  video_frame_class f_h;
  video_frame_class fc_h;
  int return_code;

  initial
  begin

    f_h = new;

    f_h.init
    (
      .pixels_per_line('h100),
      .lines_per_frame('h080),
      .bits_per_pixel(14)
    );

    f_h.make_random();

    fc_h = new;
    f_h.copy(fc_h);

    return_code = f_h.compare( 16, fc_h );

    if( return_code == 0 )
      $display("^^^ %16.t | f_h == fc_h", $time );
    else
      $display("^^^ %16.t | f_h != fc_h | mismatches = %0d", $time, return_code );

    $display("^^^ %16.t | inserting error @ fc_h[11][22]", $time );
    fc_h.lines['h11].pixel['h22] = ~(fc_h.lines['h11].pixel['h22]);

    $display("^^^ %16.t | inserting error @ fc_h[33][44]", $time );
    fc_h.lines['h33].pixel['h44] = ~(fc_h.lines['h33].pixel['h44]);

    return_code = f_h.compare( 16, fc_h );

    if( return_code == 0 )
      $display("^^^ %16.t | f_h == fc_h", $time );
    else
      $display("^^^ %16.t | f_h != fc_h | mismatches = %0d", $time, return_code );

  end


  // --------------------------------------------------------------------
  //
  task run_the_test;
    begin

// --------------------------------------------------------------------
// insert test below
// --------------------------------------------------------------------

  $display("^^^---------------------------------");
  $display("^^^ %16.t | Testbench begun.\n", $time);
  $display("^^^---------------------------------");


  repeat(1000) @(posedge tb_clk);


// --------------------------------------------------------------------
// insert test above
// --------------------------------------------------------------------

   end
  endtask


endmodule

