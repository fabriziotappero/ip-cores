-------------------------------------------------------------------------------
--* 
--* @short Shift-Register
--* 
--* Control Register Description:
--* @li Bit0: DGE  :  Global Device Enable
--* @li Bit1: TX_EN:  Transmit enable
--* @li Bit2: RX_EN:  Receive enable
--*
--* Generics described in top entity.
--* @port opb_ctl_reg Control Register
--*
--* @see opb_spi_slave
--*    @author: Daniel Köthe
--*   @version: 1.1
--* @date: 2007-11-11
--/
-- Version 1.0 Initial Release
-- Version 1.1 rx_cnt/tx_cnt only increment if < C_SR_WIDTH
-- Version 1.2 removed delays for simulation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

library work;
use work.opb_spi_slave_pack.all;

entity shift_register is
  
  generic (
    C_SR_WIDTH  : integer              := 8;
    C_MSB_FIRST : boolean              := true;
    C_CPOL      : integer range 0 to 1 := 0;
    C_PHA       : integer range 0 to 1 := 0);

  port (
    rst         : in  std_logic;
    -- control register
    opb_ctl_reg : in  std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
    -- external 
    sclk        : in  std_logic;
    ss_n        : in  std_logic;
    mosi        : in  std_logic;
    miso_o      : out std_logic;
    miso_i      : in  std_logic;
    miso_t      : out std_logic;
    -- transmit fifo
    sr_tx_clk   : out std_logic;
    sr_tx_en    : out std_logic;
    sr_tx_data  : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
    -- receive fifo
    sr_rx_clk   : out std_logic;
    sr_rx_en    : out std_logic;
    sr_rx_data  : out std_logic_vector(C_SR_WIDTH-1 downto 0));    
end shift_register;


architecture behavior of shift_register is
  --* Global
  signal sclk_int     : std_logic;
  signal sclk_int_inv : std_logic;
  signal rx_cnt       : integer range 0 to 31 := 0;

  -- RX
  signal rx_sr_reg      : std_logic_vector(C_SR_WIDTH-2 downto 0);
  signal sr_rx_en_int   : std_logic;
  signal sr_rx_data_int : std_logic_vector(C_SR_WIDTH-1 downto 0);

  -- tx
  signal miso_int       : std_logic;
  signal tx_cnt         : integer range 0 to 31 := 0;
  signal sr_tx_en_int   : std_logic;
  signal sr_tx_data_int : std_logic_vector(C_SR_WIDTH-1 downto 0);

  
begin  -- behavior

  miso_t <= ss_n;                       -- tristate


  sclk_int <= sclk when (C_PHA = 0 and C_CPOL = 0) else
              sclk when (C_PHA = 1 and C_CPOL = 1) else
              not sclk;


  sr_rx_en <= sr_rx_en_int;
  sr_tx_en <= sr_tx_en_int;

  --* reorder received bits if not "MSB_First"
  reorder_rx_bits : process(sr_rx_data_int)
  begin
    for i in 0 to C_SR_WIDTH-1 loop
      if C_MSB_FIRST then
        sr_rx_data(i) <= sr_rx_data_int(i);
      else
        sr_rx_data(C_SR_WIDTH-1-i) <= sr_rx_data_int(i);
      end if;
    end loop;  -- i
  end process reorder_rx_bits;

  --* reorder transmit bits if not "MSB_First" 
  reorder_tx_bits : process(sr_tx_data)
  begin
    for i in 0 to C_SR_WIDTH-1 loop
      if C_MSB_FIRST then
        sr_tx_data_int(i) <= sr_tx_data(i);
      else
        sr_tx_data_int(C_SR_WIDTH-1-i) <= sr_tx_data(i);
      end if;
    end loop;  -- i
  end process reorder_tx_bits;


  -----------------------------------------------------------------------------

  sr_rx_clk <= sclk_int;

  sr_rx_data_int <= rx_sr_reg & mosi;

  --* RX-Shift-Register
  rx_shift_proc : process(rst, opb_ctl_reg, sclk_int)
  begin
    if (rst = '1' or opb_ctl_reg(C_OPB_CTL_REG_DGE) = '0' or opb_ctl_reg(C_OPB_CTL_REG_RX_EN) = '0') then
      rx_cnt       <= 0;
      sr_rx_en_int <= '0';
      rx_sr_reg    <= (others => '0');
      
    elsif rising_edge(sclk_int) then
      if (ss_n = '0') then
        rx_sr_reg <= rx_sr_reg(C_SR_WIDTH-3 downto 0) & mosi;
        if (rx_cnt = C_SR_WIDTH-2) then
          rx_cnt       <= rx_cnt +1;
          sr_rx_en_int <= '1';
          elsif (rx_cnt = C_SR_WIDTH-1) then
            rx_cnt       <= 0;
            sr_rx_en_int <= '0';
          else
            rx_cnt <= rx_cnt +1;
          end if;
        else
          -- ss_n high
          -- assert framing error if cnt != 0?
          sr_rx_en_int <= '0';
          rx_cnt       <= 0;
        end if;
      end if;
    end process rx_shift_proc;

-------------------------------------------------------------------------------
      -- TX Shift Register
      sr_tx_clk    <= sclk_int_inv;
      sclk_int_inv <= not sclk_int;

      miso_o <= sr_tx_data_int(C_SR_WIDTH-1) when (tx_cnt = 0) else
                miso_int;


      --* TX Shift-Register
      tx_shift_proc : process(rst, opb_ctl_reg, sclk_int_inv)
      begin
        if (rst = '1' or opb_ctl_reg(C_OPB_CTL_REG_DGE) = '0' or opb_ctl_reg(C_OPB_CTL_REG_TX_EN) = '0') then
          tx_cnt       <= 0;
          sr_tx_en_int <= '0';
          miso_int     <= '0';
        elsif rising_edge(sclk_int_inv) then
          if (ss_n = '0') then
            if (tx_cnt /= C_SR_WIDTH-1) then
              miso_int <= sr_tx_data_int(C_SR_WIDTH-1-(tx_cnt+1));
            end if;
            if (tx_cnt = C_SR_WIDTH-2) then
              sr_tx_en_int <= '1';
              tx_cnt       <= tx_cnt +1;
              elsif (tx_cnt = C_SR_WIDTH-1) then
                tx_cnt       <= 0;
                sr_tx_en_int <= '0';
              else
                tx_cnt <= tx_cnt +1;
              end if;
            else
              -- ss_n high
              -- assert framing error if cnt != 0?
              sr_tx_en_int <= '0';
              tx_cnt       <= 0;
            end if;
          end if;
        end process tx_shift_proc;
-------------------------------------------------------------------------------

        end behavior;
