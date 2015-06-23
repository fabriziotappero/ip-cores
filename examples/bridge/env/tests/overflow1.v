module sample_test;

  integer pcount;
`include "test_tasks.v"
  
  initial
    begin
      wait (env_top.reset === 1'b0);
      #200;

      repeat (`FIB_ENTRIES)
	@(posedge env_top.clk);

      fork
        begin : drv0
          repeat (600)
	    env_top.driver0.send_packet ($random, $random, 64);
        end

        begin : drv1
          repeat (300)
	    env_top.driver1.send_packet ($random, $random, 128);
        end

        begin : drv2
          repeat (450)
	    env_top.driver2.send_packet ($random, $random, 96);
        end
        begin : drv3
          repeat (150)
	    env_top.driver3.send_packet ($random, $random, 256);
        end
      join

      #10000;

      get_packet_count (pcount);
      //check_expected (9, pcount);
      if (pcount <= 1900)
        $display ("ERROR -- Should receive at least 1900 packets");
      $display ("TEST: Received %d packets", pcount);
      $finish;
    end
  
endmodule // sample_test
