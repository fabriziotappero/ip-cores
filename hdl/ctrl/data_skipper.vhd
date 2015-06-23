-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_data_skipper.vhd
--| Version: 0.12
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Data skipper
--|   It generates an enable signal for write acquisitions in memory.
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jul-2009 | First testing
--|   0.11  | jul-2009 | Added input signal indicating when it's selected the first channel
--|   0.12  | jul-2009 | Optimized
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


--==================================================================================================
-- TO DO
-- · ...
--==================================================================================================





library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

use work.ctrl_pkg.all;


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
entity ctrl_data_skipper is
  generic(
    -- max losses = 2**(2**SELECTOR_WIDTH). (i.e., if SELECTOR_WIDTH = 5: 4.2950e+09)
    SELECTOR_WIDTH: integer := 5 
  );
  port(
    -- enable output signal
    ack_O:            out  std_logic;   
    -- sinal from wishbone interface
    ack_I, stb_I:     in  std_logic;  
    -- selector from register, equation: losses = 2**(selector_I + 1) * enable_skipper_I
    selector_I:       in   std_logic_vector(SELECTOR_WIDTH-1 downto 0);
    -- enable from register 
    enable_skipper_I: in   std_logic;
    -- common signals
    reset_I, clk_I:   in   std_logic;
    
    first_channel_I:  in   std_logic
	);
end entity ctrl_data_skipper;


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
architecture ARCH10 of ctrl_data_skipper is
  signal count:         std_logic_vector( integer(2**real(SELECTOR_WIDTH))-1 downto 0);
  signal decoded:       std_logic_vector( integer(2**real(SELECTOR_WIDTH))-1 downto 0);
  signal anded:         std_logic_vector( integer(2**real(SELECTOR_WIDTH))-1 downto 0);
  signal reset_count:   std_logic;
  signal match:         std_logic;
  signal enable_count:  std_logic;
  
begin 

 U_COUNTER0: generic_counter
  generic map(
    OUTPUT_WIDTH => integer(2**real(SELECTOR_WIDTH)) -- Output width for counter.
  )
  port map(  
    clk_I => clk_I, 
    count_O => count, 
    reset_I => reset_count,
    enable_I => enable_count
  );

  U_DECO0:  generic_decoder 
  generic map(
    INPUT_WIDTH => SELECTOR_WIDTH
  )
  port map(  
    enable_I => enable_skipper_I,
    data_I => selector_I,
    decoded_O => decoded
  );

  anded <= decoded and count;
  match <= '1' when anded = std_logic_vector(to_unsigned(0,integer(2**real(SELECTOR_WIDTH)))) else
           '0' ; 

  reset_count <= reset_I;
  enable_count <= stb_I and ack_I and enable_skipper_I and first_channel_I;
  
  ack_O <= stb_I and ack_I and (match or not(enable_skipper_I)) and not(reset_I);

end architecture;