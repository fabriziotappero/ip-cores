-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_channel_selector.vhd
--| Version: 0.31
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Channel Selector
--|   This controls the comunication with the daq module. 
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jul-2009 | First testing
--|   0.2   | jul-2009 | Added generic number of channel
--|   0.3   | jul-2009 | Added signal indicating when it's selecting the first channel
--|   0.31  | aug-2009 | Generic width in channel_number
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


--==================================================================================================
-- TODO
-- · Speed up...
-- OK Generic width in channel_number_O
--==================================================================================================


library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
entity ctrl_channel_selector is
  generic(
    CHANNEL_WIDTH: integer  := 4 -- number of channels 2**CHANNEL_WIDTH, max. 4
  );
  port(
    channels_I:         in  std_logic_vector(integer(2**real(CHANNEL_WIDTH))-1 downto 0);
    channel_number_O:   out std_logic_vector(CHANNEL_WIDTH-1 downto 0);
    first_channel_O:    out std_logic; 
    clk_I:              in  std_logic;
    enable_I:           in  std_logic;
    reset_I:            in  std_logic                                                        
  );
end entity ctrl_channel_selector;


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
architecture ARCH01 of ctrl_channel_selector is
  constant N_CHANNELS: integer := integer(2**real(CHANNEL_WIDTH));
  -- signal channel:               unsigned(CHANNEL_WIDTH-1 downto 0);
  -- signal next_channel:          unsigned(CHANNEL_WIDTH-1 downto 0);
  -- signal next_is_first_channel: std_logic;
  signal channel:               unsigned(CHANNEL_WIDTH-1 downto 0);
  signal next_channel:          unsigned(CHANNEL_WIDTH downto 0);
  signal next_is_first_channel: std_logic;
  signal rotated: unsigned(N_CHANNELS-1 downto 0);
  signal plus: unsigned(CHANNEL_WIDTH downto 0);
begin 
  
  --------------------------------------------------------------------------------------------------
  -- Output
  channel_number_O <= std_logic_vector(channel);
  --channel_number_O <=  std_logic_vector(channel);
  --------------------------------------------------------------------------------------------------
  -- Combinational selection of next channel
  
  -- P_comb: process(channel,channels_I) 
    -- variable j :    integer range 0 to N_CHANNELS-1;
    -- variable index: integer range 0 to N_CHANNELS-1;
  -- begin

      -- for j in 0 to N_CHANNELS-1 loop
        
        -- if (j + to_integer(channel) + 1) > (N_CHANNELS - 1) then
          -- index := j + to_integer(channel) + 1 - N_CHANNELS;
          -- next_is_first_channel <= '1';
        -- else
          -- index := j + to_integer(channel) + 1;
          -- next_is_first_channel <= '0';
        -- end if;
      
        -- if channels_I(index) = '1' then           
          -- next_channel <= to_unsigned(index, CHANNEL_WIDTH);
          -- exit;
        -- else
          -- next_channel <= channel;
        -- end if;
      -- end loop;
  -- end process; 
  
    --100.0 MHz     67.1 MHz  (N_CHANNELS = 16)
    -- 271 of 38400 (1%)     
    
    
    
    
    rotated <= unsigned(channels_I) ror (to_integer(channel));
    next_channel <= ('0' & channel) + plus;
    --next_channel <= channel + plus;
    next_is_first_channel <= next_channel (CHANNEL_WIDTH);
    P_coder: process(rotated)
      variable i: integer range 1 to N_CHANNELS-1;
    begin
      for i in 1 to N_CHANNELS-1 loop
        if rotated(i) = '1' then
          plus <=  to_unsigned(i, CHANNEL_WIDTH+1);
          exit;
        else 
          plus <=  (CHANNEL_WIDTH =>'1') & (CHANNEL_WIDTH - 1 downto 0 => '0');
        end if;
      end loop;
    end process;
    
  --100.0 MHz     70.6 MHz   (N_CHANNELS = 16)
  -- 137 of 38400 (0%)
  
  --------------------------------------------------------------------------------------------------
  -- Clocked selection of actual channel
  
  -- P_clock: process(enable_I, reset_I, next_channel, clk_I) 
  -- begin
    -- if clk_I'event and clk_I = '1' then
      -- if reset_I = '1' then
        -- channel <= (others => '0');
        -- first_channel_O <= '1';
      -- elsif enable_I = '1' then
        -- channel <= next_channel;
        -- first_channel_O <= next_is_first_channel;
      -- end if;
    -- end if;
  -- end process; 
  
    P_clock: process(enable_I, reset_I, next_channel, clk_I) 
  begin
    if clk_I'event and clk_I = '1' then
      if reset_I = '1' then
        channel <= (others => '0');
        first_channel_O <= '1';
      elsif enable_I = '1' then
        channel <= next_channel(CHANNEL_WIDTH-1 downto 0);
        first_channel_O <= next_is_first_channel;
      end if;
    end if;
  end process; 
    

end architecture;