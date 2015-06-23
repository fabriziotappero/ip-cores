// ********************************************************************************
//
// Module:       tb_gldbl
//
// Functional Description:
//
// This module has tasks for global statistics,test-pass/fail messages
//
// ********************************************************************************

module tb_glbl;
  reg [31:0] err_count;
  reg [31:0] warn_count;


  task init;
  begin
    err_count = 32'h0;
    warn_count = 32'h0;
  end
  endtask

  task test_pass;
  begin
   $display ("\n=========");
   $display ("Test Status: TEST PASSED");
   $display ("=========\n");   
  end
  endtask

  task test_fail;
  begin
   $display ("\n=========");
   $display ("Test Status: TEST FAILED");
   $display ("=========\n");   
 end
  endtask
  
  
  task test_err;
	begin
        err_count = err_count + 1;
        $display ("A200 TB => %t ns ERROR :: %m ERROR detected %d ",$time, err_count );
	end	  
  endtask

  task test_warn;
	begin
    warn_count = warn_count + 1;
    $display ("A200 TB => %t ns WARNING :: %m Warning %d ",$time, warn_count );
	end	
  endtask

  task test_stats;
  begin
     $display ("\n-------------------------------------------------");
     $display ("Test Status");	  
     $display ("warnings: %0d, errors: %0d",warn_count,err_count);
  end
  endtask

  task test_finish;
   begin
     test_stats;
     if (err_count > 0) begin
       test_fail;
     end else begin
       test_pass;
     end
     #1 $finish;
   end
  endtask

endmodule
