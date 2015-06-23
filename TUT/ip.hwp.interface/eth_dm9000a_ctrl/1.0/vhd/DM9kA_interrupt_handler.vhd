-------------------------------------------------------------------------------
-- Title      : DM9000A controller, interrupt handler module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DM9kA_interrupt_handler.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Company    : TUT
-- Last update: 2012-04-04
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Activates with interrupt signal and finds out the source of it:
-- tx completion or new rx packet received.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/26  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.DM9kA_ctrl_pkg.all;


entity DM9kA_interrupt_handler is

  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    interrupt_in            : in  std_logic;
    comm_req_out            : out std_logic;
    comm_grant_in           : in  std_logic;

    -- Reasons for interrupt
    rx_waiting_out          : out std_logic;
    tx_ready_out            : out std_logic;

    reg_addr_out            : out std_logic_vector(7 downto 0);
    config_data_out         : out std_logic_vector(7 downto 0);
    read_not_write_out      : out std_logic;
    config_valid_out        : out std_logic;
    data_from_comm_in       : in  std_logic_vector(data_width_c-1 downto 0);
    data_from_comm_valid_in : in  std_logic;
    comm_busy_in            : in  std_logic
    );

end DM9kA_interrupt_handler;



architecture rtl of DM9kA_interrupt_handler is

  -- State machine
  type   check_state_type is (idle, get_status, check_status, clear_isr);
  signal check_state_r : check_state_type;

  signal comm_req_r     : std_logic;
  signal isr_status_r   : std_logic_vector(7 downto 0);
  signal comm_working_r : std_logic;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  comm_req_out <= comm_req_r;

  --
  -- Sequential process for state machine
  --  
  check_int : process (clk, rst_n)
  begin  -- process check_int
    if rst_n = '0' then                 -- asynchronous reset (active low)

      comm_req_r         <= '0';
      rx_waiting_out     <= '0';
      tx_ready_out       <= '0';
      reg_addr_out       <= (others => '0');
      config_data_out    <= (others => '0');
      read_not_write_out <= '0';
      config_valid_out   <= '0';
      check_state_r      <= idle;
      isr_status_r       <= (others => '0');
      comm_working_r     <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- these are allowed to be up only one cycle
      tx_ready_out   <= '0';
      rx_waiting_out <= '0';

      case check_state_r is
        when idle =>

          if interrupt_in = '1' then
            -- "We have an interrupt! What are you waiting for, magget??! Do
            -- something, move like you got a pair!"

            -- "Sir yes sir!"
            comm_req_r <= '1';

            if comm_grant_in = '1' and comm_req_r = '1' then
              -- our turn to act
              check_state_r <= get_status;
            end if;
          else
            comm_req_r <= '0';
          end if;

          
        when get_status =>
          -- Read eth chip's interrupt register
          
          reg_addr_out       <= ISR_c;
          read_not_write_out <= '1';
          config_valid_out   <= '1';

          if data_from_comm_valid_in = '1' then
            isr_status_r     <= data_from_comm_in(7 downto 0);
            check_state_r    <= check_status;
            config_valid_out <= '0';
          end if;

          
        when check_status =>
          -- Decode the interrupt's reason
          
          if isr_status_r(0) = '1' then
            -- packet received bit
            rx_waiting_out <= '1';
          end if;

          if isr_status_r(1) = '1' then
            -- packet transmitted bit
            tx_ready_out <= '1';
          end if;

          -- Currently, bits 2:3=rx overflow is not handled. ES 2012-04-04

          
          -- clear the ISR
          reg_addr_out       <= ISR_c;
          read_not_write_out <= '0';
          -- the interrupt status bits are cleared by writing 1
          config_data_out    <= x"3F";
          config_valid_out   <= '1';
          check_state_r      <= clear_isr;
          comm_working_r     <= '0';

        when clear_isr =>

          if comm_busy_in = '1' then
            -- comm is clearing the ISR
            comm_working_r <= '1';
          elsif comm_working_r = '1' then
            -- comm_busy_in is down and comm has been working -> back to idle
            check_state_r    <= idle;
            comm_req_r       <= '0';
            config_valid_out <= '0';
          end if;

        when others => null;
      end case;
      
    end if;
  end process check_int;



end rtl;
