-------------------------------------------------------------------------------
-- Title      : Counter
-- Project    : Bridge PIF to WISHBONE / WISHBONE to PIF
-------------------------------------------------------------------------------
-- File       : COUNTER.vhd
-- Author     : Edoardo Paone
-- Company    : Politecnico of Torino
-- Last update: 2007/06/09
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: It generates the correct addresses for burst transfers of PIF
--              masters to WISHBONE slaves
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007/04/20  1.0      Edoardo Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Counter is
  generic (
    constant DATA_SIZE_WB : integer := 32;
    constant ADRS_SIZE    : integer := 32 );  -- Address bus length
  port (
    CLK                   : in  std_logic;  -- The clock input
    RST                   : in  std_logic;  -- The reset input
    LOAD_ADDR             : in  std_logic;  -- Address Load Strobe signal
    GO_UP                 : in  std_logic;  -- If '0' indicates there is a cycle pause 
    ADR_INIT              : in  std_logic_vector(ADRS_SIZE-1 downto 0);
                                        -- The address where the read/write transfer starts
    ADR_CNTR              : out std_logic_vector(ADRS_SIZE-1 downto 0);
                                        -- The new address correctly incremented
    N_TRANSFER            : out integer range 0 to 15 );
end Counter;

architecture Behavioral of Counter is

  signal ADR_REG : std_logic_vector(ADRS_SIZE-1 downto 0);
                                        -- The current address value
  signal INC     : std_logic_vector(ADRS_SIZE-1 downto 0);
  -- The increment is dependent on the data array [DAT_O()], [DAT_I()] size
  -- Byte address: Step = DATA_SIZE / 8

  signal N : integer range 0 to 15;

begin  -- Behavioral

  -- purpose: Updates the address register to the new value
  -- type   : sequential
  -- inputs : CLK, RST
  -- outputs: ADR_REG, N_TRANSFER, INC

  INC       <= conv_std_logic_vector(DATA_SIZE_WB/8, ADRS_SIZE);

  Output_Address : process (CLK, RST)
  begin  -- process Output_Address
    if RST = '1' then                     -- asynchronous reset (active high)
      ADR_REG   <= (others => '0');
      N         <= 0;
    elsif (CLK'event and CLK = '1') then  -- rising clock edge
      if(LOAD_ADDR = '1') then            -- Load Base Address into register
        ADR_REG <= ADR_INIT;
        N       <= 0;
      elsif(GO_UP = '1') then
        ADR_REG <= ADR_REG + INC;
        N       <= N + 1;
      end if;
    end if;
  end process Output_Address;

  ADR_CNTR   <= ADR_REG;
  N_TRANSFER <= N;

end Behavioral;
