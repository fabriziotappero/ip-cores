-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_output_manager.vhd
--| Version: 0.54
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Output manager
--|   Reads a memory incrementaly under certain parameters.
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jun-2009 | First testing
--|   0.2   | jul-2009 | Two levels internal buffer
--|   0.3   | jul-2009 | One level internal buffer and only one clock
--|   0.31  | jul-2009 | Internal WE signals
--|   0.5   | jul-2009 | Architecture completely renovated (reduced)
--|   0.54  | aug-2009 | New finish_O and init flag behavior
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


--==================================================================================================
-- TO DO
-- · (NO) Speed up address_counter
-- · (OK) Full test of new architecture
-- · (OK) Fix default value of s_finish signal 
-- · General speed up
--==================================================================================================


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
entity ctrl_output_manager is
  generic(
    MEM_ADD_WIDTH: integer :=  14
  );
  port(
    ------------------------------------------------------------------------------------------------
    -- MASTER (to memory) 
    DAT_I_mem: in std_logic_vector (15 downto 0);
    --DAT_O_mem: out std_logic_vector (15 downto 0);
    ADR_O_mem: out std_logic_vector (MEM_ADD_WIDTH - 1  downto 0);   
    CYC_O_mem: out std_logic;  
    STB_O_mem: out std_logic;  
    ACK_I_mem: in std_logic ;
    WE_O_mem:  out std_logic;
    
    ------------------------------------------------------------------------------------------------
    -- SLAVE (to I/O ports) 
    --DAT_I_port: in std_logic_vector (15 downto 0);
    DAT_O_port: out std_logic_vector (15 downto 0);
    --ADR_I_port: in std_logic_vector (7 downto 0); 
    CYC_I_port: in std_logic;  
    STB_I_port: in std_logic;  
    ACK_O_port: out std_logic ;
    WE_I_port:  in std_logic;
    
    
    ------------------------------------------------------------------------------------------------
    -- Common signals 
    RST_I: in std_logic;  
    CLK_I: in std_logic;  
    
    ------------------------------------------------------------------------------------------------
    -- Internal
    
    load_I:             in std_logic;                     
    -- load initial address
    
    enable_I:           in std_logic;                     
    -- continue reading from the actual address ('0' means pause, '1' means continue)
    
    initial_address_I:  in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    -- buffer starts and ends here 
    
    biggest_address_I:  in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    -- when the buffer arrives here, address is changed to 0 (buffer size)
    
    pause_address_I:    in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    -- address wich is being writed by control
    
    finish_O:           out std_logic
    -- it is set when communication ends and remains until next restart or actual address change                                                    
    
	);
end entity ctrl_output_manager;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
architecture ARCH22 of ctrl_output_manager is 
 
  signal address_counter: std_logic_vector(MEM_ADD_WIDTH - 1  downto 0);
  signal enable_read: std_logic;
  signal enable_count: std_logic;
  signal enable_strobe: std_logic;
  signal s_finish: std_logic; -- register previous (and equal) to output
  signal init: std_logic;     -- register
  signal same_address: std_logic;

begin 
  
  --------------------------------------------------------------------------------------------------
  -- Wishbone signals
  DAT_O_port <= DAT_I_mem;
  CYC_O_mem <= CYC_I_port;
  STB_O_mem <= STB_I_port and enable_read;
  ACK_O_port <= ACK_I_mem;
  ADR_O_mem <= address_counter;
  WE_O_mem <= '0' ;
  
  --------------------------------------------------------------------------------------------------
  -- Status signals  
  -- there is an init signal because in the first read, address_counter may be = to pause_address_I
  P_pause: process (CLK_I, RST_I, address_counter, pause_address_I)
  begin
    if CLK_I'event and CLK_I = '1' then
      if RST_I = '1' then
        same_address <= '0';
      elsif address_counter = pause_address_I then
        same_address <= '1';
      else 
        same_address <= '0';
      end if;   
    end if;
  end process;
  
  P_flags: process(CLK_I, RST_I, enable_I, enable_count, load_I)
  begin
    if CLK_I'event and CLK_I = '1' and CLK_I'LAST_VALUE = '0' then      
      -- when enable is '0', finish_O must be 0 again
      if RST_I = '1' or enable_I = '0' then
        init <= '1';
        enable_strobe <= '0';
      elsif (load_I = '1' and enable_I = '1') then
        enable_strobe <= '1';
        init <= '1';
      elsif  enable_count = '1' then
        init <= '0';
      end if;
    end if;
  end process;
  
  
  enable_read <= '1'  when  WE_I_port = '0' and s_finish = '0' and 
                            (same_address = '0' or init = '1') and enable_strobe = '1'
            else '0'; 
  
  enable_count <= CYC_I_port and STB_I_port and ACK_I_mem and enable_read;
  
  
  s_finish <= '1' when address_counter = initial_address_I and init = '0' else 
              '0';
  finish_O <= s_finish;
  
  --------------------------------------------------------------------------------------------------
  -- Address counter
  P_count: process(CLK_I, RST_I, address_counter, enable_count, load_I)
  begin
    if CLK_I'event and CLK_I = '1' and CLK_I'LAST_VALUE = '0' then      
      if RST_I = '1' then
        address_counter <= (others => '0');
      elsif load_I = '1' and enable_I = '1' then
        address_counter <= initial_address_I;
      elsif enable_count = '1' and address_counter >= biggest_address_I then
        address_counter <= (others => '0');
      elsif  enable_count = '1' then
        address_counter <= address_counter + 1;
      end if;
    end if;
  end process;

end architecture;