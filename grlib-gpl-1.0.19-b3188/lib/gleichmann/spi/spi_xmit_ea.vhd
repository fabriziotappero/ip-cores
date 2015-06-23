-------------------------------------------------------------------------------
-- Title      : SPI Transmit Core
-- Project    : LEON3MINI
-------------------------------------------------------------------------------
-- $Id: spi_xmit.vhd,v 1.1 2006/08/11 08:55:39 tame Exp $
-------------------------------------------------------------------------------
-- Author     : Thomas Ameseder
-- Company    : Gleichmann Electronics
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- This core is an SPI master that was created in order to be able to
-- access the configuration interface of the Texas Instruments audio
-- codec TLV320AIC23B on the Hpe_mini board.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity spi_xmit is
  generic (
    data_width : integer := 16);
  port(
    clk_i      : in  std_ulogic;
    rst_i      : in  std_ulogic;
    data_i     : in  std_logic_vector(data_width-1 downto 0);
    CODEC_SDIN : out std_ulogic;
    CODEC_CS   : out std_ulogic
    );
end spi_xmit;


architecture rtl of spi_xmit is
  type state_t is (none_e, transmit_e);

  signal state, nextstate     : state_t;
  signal counter, nextcounter : integer range -1 to data_width-1;
  signal cs                   : std_ulogic;
  signal data_reg             : std_logic_vector(data_width-1 downto 0);

begin  -- rtl

  -- hard wired signals
  CODEC_CS   <= cs;

  -- SPI transmit state machine
  comb : process (counter, data_reg, state)
  begin
    nextstate   <= state;
    nextcounter <= counter;

    cs         <= '1';
    CODEC_SDIN <= '-';

    case state is
      when none_e =>
        nextstate   <= transmit_e;
        nextcounter <= data_width-1;

      when transmit_e =>
        cs <= '0';

        if counter = -1 then
          nextstate   <= none_e;
          nextcounter <= data_width-1;
          cs          <= '1';
          CODEC_SDIN  <= '-';
        else
          CODEC_SDIN  <= data_reg(counter);
          nextcounter <= counter - 1;
        end if;

      when others =>
        nextstate   <= none_e;
        nextcounter <= data_width-1;
    end case;
  end process comb;


  seq : process (clk_i, rst_i)
  begin
    if rst_i = '0' then
      state    <= none_e;
      counter  <= data_width-1;
      data_reg <= (others => '0');
    elsif falling_edge(clk_i) then
      state   <= nextstate;
      counter <= nextcounter;
      -- only accept new data when not transmitting
      if state = none_e then
        data_reg <= data_i;
      end if;
    end if;
  end process seq;

end rtl;
