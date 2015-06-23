----------
--! @file
--! @brief The test-bench supporting package.
----------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use std.textio.all;

package tb_pack is
		      
  procedure ReadData( constant filename     : in  string;
                      signal   bpsdm_data   : out std_logic_vector;
                      signal   clk          : in  std_ulogic;
                      signal   finished     : out std_ulogic );		
                      
end tb_pack;

package body tb_pack is
  
  procedure ReadData( constant filename   : in  string;
                      signal   bpsdm_data   : out std_logic_vector;
                      signal   clk          : in  std_ulogic;
                      signal   finished     : out std_ulogic ) is
		      
    file inputfile     	: text open read_mode is filename;
    variable inputline 	: line;
    variable data 	: integer;
  begin
    while not endfile(inputfile) loop
      -- read one line of the file
      readline(inputfile, inputline);
      -- read one integer number from that line
      read(inputline, data);
      -- output data at rising clock edge, converting the integer number to a
      -- bit vector using the given vector length and either signed or unsigned
      -- input
      wait until rising_edge(clk);
        bpsdm_data <= std_logic_vector(conv_signed(data, bpsdm_data'length))   after 0 ns;
    end loop;
    -- as soon as last line is reached, output information that finished
    -- reading contents
    finished  <= '1';
  end procedure ReadData;

end tb_pack;
