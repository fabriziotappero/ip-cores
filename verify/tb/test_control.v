
module test_control();
  
  event        error_detected;
  integer      error_count;
  reg          verbose_msg;
  
  // initialize debug variables 
  initial
    begin
      error_count = 0;
      verbose_msg = 0;
    end


  // count the number error 
  always @(error_detected)
    begin
      error_count = error_count + 1;
    end
  
  
  // enabling/disabling  message
  task msg_enable;
    input [20*8:1] msg_src;
    input msg_enable;
    begin
      verbose_msg = msg_enable;
      if (msg_enable)
        $display("         At time %t ** %s: enabling messages",$time, msg_src);
      else
        $display("         At time %t ** %s: disabling messages",$time, msg_src);
    end
  endtask // msg

  // generating message
  task msg;
    input [20*8:1] msg_src;
    input [40*8:1] msg_text;
    begin
      if (verbose_msg)
        $display("         At time %t ** %s: Msg: %s",$time, msg_src, msg_text);
    end
  endtask // msg

  // generating long message
  task msgl;
    input [40*8:1] msg_src;
    input [80*8:1] msg_text;
    begin
      if (verbose_msg)
        $display("         At time %t ** %s: Msg: %s",$time, msg_src, msg_text);
    end
  endtask // msg

  // generating the error message
  task err;
    input [20*8:1] err_src;
    input [40*8:1] err_text;
    begin
      -> error_detected;
      $display("Time %0d, %s Error: %s",$time, err_src, err_text);
    end
  endtask // err


task finish_test;
begin

   $display("****************************************");
   if ( error_count == 0 )
      $display("* TEST: PASSED");
   else
      $display("* TEST: FAILED\n*\tError(s) = %d", error_count);

   $display("****************************************");
end
endtask


endmodule // debug_proc

