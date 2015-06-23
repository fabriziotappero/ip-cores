library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

-- synopsys synthesis on
library STD;
use STD.TEXTIO.all;
-- synopsys synthesis off

entity gf_multiplier_tb is end gf_multiplier_tb;

architecture structural of gf_multiplier_tb is

component gf_multiplier
  port (
    phi1       : in    std_logic;
    phi2       : in    std_logic;
    reset      : in    std_logic;
    input      : in    std_logic_vector(31 downto 0);
    output_fcs : inout std_logic_vector(15 downto 0);
    output_xor : out   std_logic_vector(15 downto 0));
end component;

signal phi1, phi2, reset : std_logic;
signal input             : std_logic_vector(31 downto 0);
signal output_fcs        : std_logic_vector(15 downto 0);
signal output_xor        : std_logic_vector(15 downto 0);

-- We also specify the files used to get the data and to put the data back
file file_read     : text is in "/h/d1/c/x00jn/CRC_generator/data/data_multiplier_input.dat";
file file_out_fcs  : text is out "/h/d1/c/x00jn/CRC_generator/data/data_multiplier_fcs_out.dat";
file file_out_xor  : text is out "/h/d1/c/x00jn/CRC_generator/data/data_multiplier_xor_out.dat";

begin  -- structural


  -- Important: These parameters have been calculated for a 500MHz
  -- relative clock -2 ns per stage-
  p_phi1: process
  begin  -- process p_phi1
    phi1 <= '1', '0' after 2.1 ns;
    wait for 4.2 ns;
  end process p_phi1;

  p_phi2: process
  begin  -- process p_phi2
    phi2 <= '1', '0' after 0.3 ns, '1' after 1.8 ns;
    wait for 4.2 ns;
  end process p_phi2;

  p_reset: process
  begin  -- process p_reset
    reset <= '0' after 10 ns, '1' after 30 ns;
    wait;
  end process p_reset;

  p_input: process (phi2)
    variable input_file : bit_vector(31 downto 0);
    variable line : line;
  begin  -- process p_input
   if phi2'event and phi2='1' then
    if (not (endfile(file_read))) then
      readline (file_read, line);
      read(line, input_file);
      input <= To_StdLogicVector(input_file);
--      wait for 2 ns;                    -- IMPORTANT!! Modify this to change
                                        -- the speed of the incoming data!
    end if;
   end if;   
  end process p_input;

  p_output: process (phi1)
    variable output_file_fcs : bit_vector(15 downto 0);
    variable output_file_xor : bit_vector(15 downto 0);
    variable line_fcs : line;
    variable line_xor : line;    
  begin  -- process p_output
    if phi1'event and phi1 = '1' then  -- rising clock edge
      output_file_fcs:=To_BitVector(output_fcs);
      write(line_fcs,output_file_fcs);
      writeline(file_out_fcs,line_fcs);

      output_file_xor:=To_BitVector(output_xor);
      write(line_xor,output_file_xor);
      writeline(file_out_xor,line_xor);
    end if;
  end process p_output;
  
  gf_multiplier_1 : gf_multiplier port map (phi1 => phi1, phi2 => phi2, reset => reset,
                                            input => input, output_fcs => output_fcs,
                                            output_xor => output_xor);
  
end structural;

configuration cfg_gf_multiplier_tb_structural of gf_multiplier_tb is

  for structural
    for gf_multiplier_1: gf_multiplier use entity work.gf_multiplier(structural); end for;
  end for;

end cfg_gf_multiplier_tb_structural;
