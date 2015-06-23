library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity tb_edge_detector is
  --empty
end tb_edge_detector;


architecture beh of tb_edge_detector is

  component edge_detector
        port(
                din   :  in  std_logic;
                clk   :  in  std_logic;
                rst_n :  in  std_logic;
                dout  :  out std_logic
            );
  end component edge_detector;


  --signal declaration

     signal clk_net        : std_logic;
     signal rst_n_net      : std_logic;
     signal din_net        : std_logic;
     signal dout_net       : std_logic;

 begin
        inst_1: edge_detector
          port map(
                  din   =>  din_net,
                  clk   =>  clk_net,
                  rst_n =>  rst_n_net,
                  dout  =>  dout_net
                  );

 
    clk_p : process
    begin
      clk_net <= '0';
      wait for 2 ns;
      clk_net <= '1';
      wait for 2 ns;
    end process clk_p;

    input_data : process
        begin
            din_net <= '0';
                wait for 7 ns;
            din_net <= '1';
                wait for 10 ns;
            din_net <= '0';
                wait for 20 ns;
        end process input_data;

    test_bench : process
        begin

          rst_n_net <= '0';
          wait for 1 ns;
          rst_n_net <= '1';
          wait for 100 ns;

          assert false
          report "End of Simulation"
          severity failure;

        end process test_bench;

end beh;


