reg  dumping;

initial
  dumping = 0;
  
task test_pass;
    begin
      $display ("%t: --- TEST PASSED ---", $time);
      #100;
      $finish;
    end
endtask // test_pass

task test_fail;
    begin
      $display ("%t: !!! TEST FAILED !!!", $time);
      #100;
      $finish;
    end
endtask // test_fail

task dumpon;
    begin
      if (!dumping)
	begin
`ifdef VCS
          $vcdpluson;
          $vcdplusmemon;
`else
	  $dumpfile (`DUMPFILE_NAME);
	  $dumpvars;
`endif
	  dumping = 1;
	end
    end
endtask // dumpon

task dumpoff;
    begin
`ifdef VCS
      $vcdplusoff;
      $vcdplusmemoff;
`else
      // ???
`endif
    end
endtask // dumpoff

task clear_ram;
    integer i;
    begin
/* -----\/----- EXCLUDED -----\/-----
      for (i=0; i<32768; i=i+1)
        tb_top.ram.mem[i] = 0;
 -----/\----- EXCLUDED -----/\----- */
    end
endtask

