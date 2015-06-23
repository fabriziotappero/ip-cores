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
	env_top.driver0.send_packet (1, 2, 20);
	env_top.driver1.send_packet (2, 3, 64);
	env_top.driver2.send_packet (3, 4, 64);
	env_top.driver3.send_packet (4, 1, 64);
      join

      #2000;

      get_packet_count (pcount);
      check_expected (6, pcount);
      $display ("TEST: Received %d packets", pcount);
      $finish;
    end
  
endmodule // sample_test
