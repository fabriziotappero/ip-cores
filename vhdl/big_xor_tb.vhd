library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

-- synopsys synthesis on
library STD;
use STD.TEXTIO.all;
-- synopsys synthesis off

entity big_xor_tb is end big_xor_tb;

architecture structural of big_xor_tb is

component big_xor
  port (
    phi2        : in std_logic;
    reset       : in std_logic;
    input_input : in std_logic_vector(15 downto 0);
    fcs_input   : in std_logic_vector(15 downto 0);
    gf_input    : in std_logic_vector(15 downto 0);
    output      : out std_logic_vector(31 downto 0));
end component;

signal phi2, reset : std_logic;
signal input_input : std_logic_vector(15 downto 0);
signal fcs_input   : std_logic_vector(15 downto 0);
signal gf_input    : std_logic_vector(15 downto 0);
signal output      : std_logic_vector(31 downto 0);

signal phi1        : std_logic; 
-- Necessary to be able to run the process that generates phi1

-- We also specify the files used to get the data and to put the data back
file file_read_input : text is in "/h/d1/c/x00jn/CRC_generator/data/data_xor_input.dat";
file file_read_fcs   : text is in "/h/d1/c/x00jn/CRC_generator/data/data_xor_fcs.dat";
file file_read_gf    : text is in "/h/d1/c/x00jn/CRC_generator/data/data_xor_gf.dat";
file file_out        : text is out "/h/d1/c/x00jn/CRC_generator/data/data_xor_out.dat";

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

  p_input: process (phi1)
    variable line_input : line;
    variable line_fcs : line;
    variable line_gf : line;
    variable file_input : bit_vector(15 downto 0);
    variable file_fcs : bit_vector(15 downto 0);
    variable file_gf : bit_vector(15 downto 0);
  begin  -- process p_input
   if phi1'event and phi1='1' then
    -- We just verify the end of a file (the files will be done of the same length)
    if (not (endfile(file_read_input))) then
      readline (file_read_input, line_input);
      read(line_input, file_input);
      input_input <= To_StdLogicVector(file_input);

      readline (file_read_fcs, line_fcs);
      read(line_fcs, file_fcs);
      fcs_input <= To_StdLogicVector(file_fcs);

      readline (file_read_gf, line_gf);
      read(line_gf, file_gf);
      gf_input <= To_StdLogicVector(file_gf);
      -- wait for 2 ns;                    -- IMPORTANT!! Modify this to change
                                        -- the speed of the incoming data!
    end if;
   end if;
  end process p_input;

  p_output: process (phi2)
    variable output_file : bit_vector(31 downto 0);
    variable line : line;
  begin  -- process p_output
    if phi2'event and phi2 = '1' then  -- rising clock edge
      output_file:=To_BitVector(output);
      write(line,output_file);
      writeline(file_out,line);
    end if;
  end process p_output;
  
  big_xor_1 : big_xor port map (phi2 => phi2, reset => reset, gf_input => gf_input,
                                input_input => input_input, fcs_input => fcs_input,
                                output => output);
  
end structural;

configuration cfg_big_xor_structural of big_xor_tb is

  for structural
    for big_xor_1: big_xor use entity work.big_xor(behavior); end for;
  end for;

end cfg_big_xor_structural;

