-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_trigger_manager.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Trigger manager
--|   
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jul-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


--==================================================================================================
-- TODO
-- · (OK) Test offset sum
-- · Speed up
-- · Compare performance with address_O = actual trigger address - 1
--==================================================================================================

library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ctrl_trigger_manager is
  generic (
    MEM_ADD_WIDTH:  integer := 14;
    DATA_WIDTH:     integer := 10;
    CHANNELS_WIDTH: integer := 4
  );
  port (
    data_I:           in  std_logic_vector (DATA_WIDTH - 1 downto 0);
    channel_I:        in  std_logic_vector (CHANNELS_WIDTH -1 downto 0);
    trig_channel_I:   in  std_logic_vector (CHANNELS_WIDTH -1 downto 0);
    address_I:        in  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    final_address_I:  in  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    -- offset from trigger address (signed). MUST BE: -final_address_I < offset_I < final_address_I
    offset_I:         in std_logic_vector (MEM_ADD_WIDTH  downto 0);
    -- trigger level (from max to min, not signed)
    level_I:          in  std_logic_vector (DATA_WIDTH - 1 downto 0);
    -- use falling edge when falling_I = '1', else rising edge
    falling_I:        in  std_logic; 
    clk_I:            in  std_logic;
    reset_I:          in  std_logic;
    enable_I:         in  std_logic;
    -- it is set when trigger condition occurs
    trigger_O:        out std_logic;
    -- address when trigger plus offset
    address_O:        out std_logic_vector (MEM_ADD_WIDTH - 1 downto 0)
  );

end entity ctrl_trigger_manager;

architecture arch01_trigger of ctrl_trigger_manager is
  -- trigger process signals
  signal higher, higher_reg: std_logic;
  signal pre_trigger: std_logic;
  
  -- signals for output address selection
  --signal final_address_sign: std_logic_vector (MEM_ADD_WIDTH downto 0);
  signal add_plus_off: unsigned (MEM_ADD_WIDTH downto 0);
  signal add_plus_off_plus_fa: unsigned (MEM_ADD_WIDTH downto 0);
  signal add_plus_off_sign: std_logic;
  signal add_plus_off_plus_fa_sign: std_logic;
  signal offset_sign: std_logic;
  signal truncate: std_logic;
  signal selected_address: std_logic_vector(MEM_ADD_WIDTH -1 downto 0);
  signal selected_address_reg: std_logic_vector(MEM_ADD_WIDTH -1 downto 0);
  
  signal full_buffer: std_logic;
  
begin
  
  --------------------------------------------------------------------------------------------------
  -- Output address selection
  
  -- Output addess must be between 0 and final_address_I (buffer size), wich may be less than 
  -- (others -> '1'). For this reaeson, it must be truncated. 
  
  add_plus_off <= unsigned(address_I) + unsigned(offset_I);
  add_plus_off_sign <= add_plus_off(MEM_ADD_WIDTH);
  offset_sign <= offset_I(MEM_ADD_WIDTH);
  
  add_plus_off_plus_fa <= add_plus_off - unsigned(final_address_I) when offset_sign = '0' else
                           add_plus_off + unsigned(final_address_I);


  add_plus_off_plus_fa_sign <= add_plus_off_plus_fa (MEM_ADD_WIDTH);
  
  truncate <= (offset_sign and  add_plus_off_sign) or 
              (not(offset_sign) and not(add_plus_off_plus_fa_sign));
  
  with truncate select
    selected_address <= std_logic_vector(add_plus_off_plus_fa(MEM_ADD_WIDTH - 1 downto 0))
                          when '1',
                        std_logic_vector(add_plus_off(MEM_ADD_WIDTH - 1 downto 0)) 
                          when others;

  address_O <=  selected_address_reg;
  
  --------------------------------------------------------------------------------------------------
  -- Trigger 
  higher <= '1' when data_I >= level_I  else '0';
  
  P_trigger: process (clk_I, reset_I, enable_I, channel_I, trig_channel_I, higher_reg,
  falling_I, higher, address_I, offset_sign, selected_address)
  begin
    if clk_I'event and clk_I = '1' then
      if reset_I = '1' then
        pre_trigger <= '0';
        higher_reg <= '0';
        trigger_O <= '0';
        selected_address_reg <= (others => '0');
      elsif enable_I = '1' then 

        if channel_I = trig_channel_I then 
          if  (higher_reg = '0' xor falling_I = '1') and 
              (higher = '1' xor falling_I = '1') and pre_trigger = '0' and full_buffer = '1' 
              then -- trigger!
            pre_trigger <= '1';            
            selected_address_reg <= selected_address;
            if offset_sign = '1' or unsigned(offset_I) = 0 then
              trigger_O <= '1';
            end if;
          end if;
          higher_reg <= higher; -- higher_reg will be the previous higher 
        end if;   
        
        if pre_trigger = '1' and selected_address_reg = address_I then 
          -- if offset > 0 then trigger will wait until address_I equals trigger address plus offset
            trigger_O <= '1';
        end if;
           
      end if;
    end if;
  end process;
 
  -- When using negative offset for buffer, buffer must be filled before set trigger 
  P_wait_buffer_full: process (clk_I)
  begin
    if clk_I'event and clk_I = '1' then
      if reset_I = '1' then
        full_buffer <= '0';
      elsif enable_I = '1' and (offset_sign = '0' or add_plus_off_sign = '0') and 
      full_buffer <= '0' then
        full_buffer <= '1';
      end if;
    end if;
  end process;
  
  -- t pt f /f xor1 xor2 and
  -- 000 1 0 1 
  -- 001 0 1 0 
  -- 010 1 0 0     
  -- 011 0 1 1 1 
  -- 100 1 1 1 1 
  -- 101 0 0 0  
  -- 110 1 1 0  
  -- 111 0 0 1  
  
end architecture;