
task get_packet_count;
  output [31:0] pcount;
  integer       p;
  begin
    p = 0;
    p = p + env_top.mon0.rxpkt_num;
    p = p + env_top.mon1.rxpkt_num;
    p = p + env_top.mon2.rxpkt_num;
    p = p + env_top.mon3.rxpkt_num;
    pcount = p;
  end
endtask // get_packet_count

task check_expected;
  input [31:0] exp_val, act_val;
  begin
    if (exp_val !== act_val)
      $display ("%t: ERROR:  Expected %x, Actual value %x", $time, exp_val, act_val);
  end
endtask // check_expected
