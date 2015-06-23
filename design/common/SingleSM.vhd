-------------------------------------------------------------------------------
-- File Name :  SingleSM.vhd
--
-- Project   : 
--
-- Module    :
--
-- Content   : 
--
-- Description : 
--
-- Spec.     : 
--
-- Author    : Michal Krepa
-------------------------------------------------------------------------------
-- History :
-- 20080301: (MK): Initial Creation.
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

entity SingleSM is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- from/to SM(m)
        start_i            : in  std_logic;
        idle_o             : out std_logic;
        -- from/to SM(m+1)
        idle_i             : in  std_logic;
        start_o            : out std_logic;
        -- from/to processing block
        pb_rdy_i           : in  std_logic;
        pb_start_o         : out std_logic;
        -- state debug
        fsm_o              : out std_logic_vector(1 downto 0)
    );
end entity SingleSM;   

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture SingleSM_rtl of SingleSM is


-------------------------------------------------------------------------------
-- Architecture: Signal definition.
-------------------------------------------------------------------------------
  type T_STATE is (IDLE, WAIT_FOR_BLK_RDY, WAIT_FOR_BLK_IDLE);
  
  signal state : T_STATE;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  fsm_o <= "00" when state = IDLE else
           "01" when state = WAIT_FOR_BLK_RDY else
           "10" when state = WAIT_FOR_BLK_IDLE else
           "11";

  ------------------------------------------------------------------------------
  -- FSM
  ------------------------------------------------------------------------------
  p_fsm : process(CLK, RST)
  begin
    if RST = '1' then
      idle_o     <= '0';
      start_o    <= '0';
      pb_start_o <= '0';
      state      <= IDLE;
    elsif CLK'event and CLK = '1' then
      idle_o     <= '0';
      start_o    <= '0';
      pb_start_o <= '0';
    
      case state is
        when IDLE =>
          idle_o <= '1';
          -- this fsm is started
          if start_i = '1' then
            state      <= WAIT_FOR_BLK_RDY;
            -- start processing block associated with this FSM
            pb_start_o <= '1';
            idle_o     <= '0';
          end if;       
        
        when WAIT_FOR_BLK_RDY =>
          -- wait until processing block completes
          if pb_rdy_i = '1' then
            -- wait until next FSM is idle before starting it
            if idle_i = '1' then
              state   <= IDLE;
              start_o <= '1';
            else
              state <= WAIT_FOR_BLK_IDLE;
            end if;
          end if;
        
        when WAIT_FOR_BLK_IDLE =>
          if idle_i = '1' then
            state   <= IDLE;
            start_o <= '1';
          end if;
        
        when others =>
          idle_o     <= '0';
          start_o    <= '0';
          pb_start_o <= '0';
          state      <= IDLE;
        
      end case;
      
    end if;
  end process;

end architecture SingleSM_rtl;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------
