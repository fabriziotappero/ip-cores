-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_memory_writer.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Memory writer
--|   Read data and write it in a memory (it's a simple wishbone bridge)
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jul-2009 | First release
--|   0.12  | aug-2009 | Disable strobe output when enable = '0'
--|   0.13  | aug-2009 | End in 0 when continuous (better integration)
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


--==================================================================================================
-- TODO
-- · Test new enable function (for stb and cyc)
-- · Clean!
--==================================================================================================


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.ctrl_pkg.all;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
entity ctrl_memory_writer is
  generic(
    MEM_ADD_WIDTH: integer :=  14
  );
  port(
    ------------------------------------------------------------------------------------------------
    -- to memory
    DAT_O_mem: out std_logic_vector (15 downto 0);
    ADR_O_mem: out std_logic_vector (MEM_ADD_WIDTH - 1  downto 0);   
    CYC_O_mem: out std_logic;  
    STB_O_mem: out std_logic;  
    ACK_I_mem: in std_logic ;
    WE_O_mem:  out std_logic;
    
    ------------------------------------------------------------------------------------------------
    -- to acquistion module
    DAT_I_adc: in std_logic_vector (15 downto 0);
    -- Using an address generator, commented
    -- ADR_O_adc: out std_logic_vector (ADC_ADD_WIDTH - 1  downto 0); 
    CYC_O_adc: out std_logic;  
    STB_O_adc: out std_logic;  
    ACK_I_adc: in std_logic ;
    --WE_O_adc:  out std_logic;
    
    ------------------------------------------------------------------------------------------------
    -- Common signals 
    RST_I: in std_logic;  
    CLK_I: in std_logic;  
    
    ------------------------------------------------------------------------------------------------
    -- Internal
    -- reset memory address to 0
    reset_I:            in std_logic;                     
    -- read in clk edge from the actual address ('0' means pause, '1' means continue)
    enable_I:           in std_logic;                     
    final_address_I:    in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    -- it is set when communication ends and remains until next restart or actual address change
    finished_O:         out std_logic;
    -- when counter finishes, restart
    continuous_I:       in  std_logic
  );
end entity ctrl_memory_writer;


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
architecture ARCH12 of ctrl_memory_writer is
    
  type DataStatusType is (
          FINISHED,
        --  INIT,
          WORKING
          );
  
  signal data_status: DataStatusType; 
  
  signal count: std_logic_vector(MEM_ADD_WIDTH-1  downto 0);
  signal enable_count:std_logic;
  signal reset_count: std_logic;
  signal data: std_logic_vector(15 downto 0);
  
  signal s_finished, s_STB_adc, s_STB_mem: std_logic; -- previous to outputs
  
begin 
  --------------------------------------------------------------------------------------------------
  -- Instances
  U_COUNTER0: generic_counter
  generic map(
    OUTPUT_WIDTH => MEM_ADD_WIDTH -- Output width for counter.
  )
  port map(  
    clk_I => CLK_I, 
    count_O => count, 
    reset_I => reset_count,
    enable_I => enable_count
  );
   
  
  --------------------------------------------------------------------------------------------------
  -- Combinational
  
  -- counter
  s_finished <= '1' when count >= final_address_I else '0';
  enable_count <= '1' when enable_I = '1' and 
                           data_status = WORKING  and 
                           s_STB_mem = '1' and 
                           ACK_I_mem = '1' 
                      else
                  '0';
  reset_count <= '1' when reset_I = '1' or (s_finished = '1' and enable_count = '1') else
                 '0';

  -- outputs
  finished_O <= s_finished;
  STB_O_adc <= s_STB_adc and enable_I;  -- !
  STB_O_mem <= s_STB_mem and enable_I;  -- !
  DAT_O_mem <= data;
  ADR_O_mem <= count;
  --WE_O_adc <= '0';
  WE_O_mem <= '1';
  
  --------------------------------------------------------------------------------------------------
  -- Clocked
  
  
  -- Lock interface when working
  P_cyc_signals: process (CLK_I, enable_I, reset_I)
  begin
    if CLK_I'event and CLK_I = '1' then
      if enable_I = '0' or reset_I = '1' then
        CYC_O_adc <= '0';   CYC_O_mem <= '0';
      else
        CYC_O_adc <= '1';  CYC_O_mem <= '1';
      end if;
    end if;  
  end process;
  
  
  P_stb_signals: process (CLK_I, reset_I, data_status, s_STB_adc, s_STB_mem, ACK_I_adc, ACK_I_mem)
  begin

    if CLK_I'event and CLK_I = '1' then
      if reset_I = '1' or RST_I = '1' then
        data_status <= WORKING;
        s_STB_adc <= '0';
        s_STB_mem <= '0';
        data <= (others => '0');
      elsif enable_I = '1' then
        case data_status is 
--           when INIT =>
--             -- this state is only necessary when there are adc convertions in every clock
--             -- (for the first convertion)
--             s_STB_adc <= '1';
--             s_STB_mem <= '1';
--             data_status <= WORKING;
--             data <= DAT_I_adc; -- save data
            
          when WORKING =>
            if ACK_I_adc = '1' then
              s_STB_mem <= '1'; -- strobe when adc ack
              data <= DAT_I_adc; -- save data
            elsif s_STB_mem = '1' and ACK_I_mem = '1' then
              s_STB_mem <= '0';        
            end if;
              
--             if s_STB_mem = '1' and ACK_I_mem = '1' then
               s_STB_adc <= '1'; -- strobe when mem ack
--             elsif s_STB_adc = '1' and ACK_I_adc = '1' then
--               s_STB_adc <= '0';
--             end if;
            
            if continuous_I = '0' and reset_count = '1' then
              data_status <= FINISHED;
            end if;
          
          when others => -- FINISHED
            s_STB_adc <= '0';
            s_STB_mem <= '0';
          
        end case;
      end if;
    end if;
  
  end process;
    

  


end architecture;