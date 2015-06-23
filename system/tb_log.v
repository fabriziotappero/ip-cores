// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module
  tb_log
  #(
    parameter RESULTS_FILE_NAME = "test_result.txt"
  )
  ( );


  // --------------------------------------------------------------------
  integer test_result = 0;

  task open_result_file;
    begin

      test_result = $fopen( RESULTS_FILE_NAME, "w" );

      if( test_result == 0 )
        begin
          $display( "-!- %16.t | %m: ERROR!!! Failed to open log file, test_result.txt", $time );
          $finish;
        end

    end
  endtask


  // --------------------------------------------------------------------
  integer fail_count = 0;

  task inc_fail_count;
    begin

      fail_count = fail_count + 1;

    end
  endtask


  // --------------------------------------------------------------------
  integer pass_count = 0;

  task inc_pass_count;
    begin

      pass_count = pass_count + 1;

    end
  endtask


  // --------------------------------------------------------------------
  task test_passes;
    begin

      $fdisplay( test_result, "PASS" );
      
      $display( "-!- %16.t | ", $time );
      $display( "-!- %16.t | pass_count = %d", $time, pass_count );
      $display( "-!- %16.t | ", $time );

      $display( "-#- %16.t | ######     #     #####   ##### ", $time );
      $display( "-#- %16.t | #     #   # #   #     # #     #", $time );
      $display( "-#- %16.t | #     #  #   #  #       #      ", $time );
      $display( "-#- %16.t | ######  #     #  #####   ##### ", $time );
      $display( "-#- %16.t | #       #######       #       #", $time );
      $display( "-#- %16.t | #       #     # #     # #     #", $time );
      $display( "-#- %16.t | #       #     #  #####   ##### ", $time );

    end
  endtask


  // --------------------------------------------------------------------
  task test_fails;
    begin

      $fdisplay( test_result, "FAIL" );

      $display( "-!- %16.t | ", $time );
      $display( "-!- %16.t | fail_count = %d", $time, fail_count );
      $display( "-!- %16.t | pass_count = %d", $time, pass_count );
      $display( "-!- %16.t | ", $time );

      $display( "-#- %16.t | #######    #    ### #      ", $time );
      $display( "-#- %16.t | #         # #    #  #      ", $time );
      $display( "-#- %16.t | #        #   #   #  #      ", $time );
      $display( "-#- %16.t | #####   #     #  #  #      ", $time );
      $display( "-#- %16.t | #       #######  #  #      ", $time );
      $display( "-#- %16.t | #       #     #  #  #      ", $time );
      $display( "-#- %16.t | #       #     # ### #######", $time );

    end
  endtask


  // --------------------------------------------------------------------
  task log_fail_count;
    begin

      open_result_file();

      $display( "-#- %16.t | ", $time );

      if( (fail_count == 0) & (pass_count != 0) )
        test_passes();
      else
        test_fails();

      $fclose(test_result);

    end
  endtask


endmodule

