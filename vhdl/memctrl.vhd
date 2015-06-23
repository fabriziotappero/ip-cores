-- File: dmem.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Entity for accessing data memory.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use WORK.RISE_PACK.all;
use WORK.CONF_PACK.all;


entity memctrl is
  
  port (
    clk   : in std_logic;
    reset : in std_logic;
    wr_enable : in  std_logic;
    addr      : in  MEM_ADDR_T;
    data_in   : in  MEM_DATA_T;
    data_out  : out MEM_DATA_T;
    uart_txd : out std_logic;
    uart_rxd : in std_logic);

end memctrl;

architecture memctrl_rtl of memctrl is

  component dmem
    port (
      addr  : in  std_logic_vector(DMEM_ADDR_WIDTH-1 downto 0);
      clk   : in  std_logic;
      data_in   : in  MEM_DATA_T;
      data_out  : out MEM_DATA_T;
      wr_enable : in  std_logic);
  end component;
  
  component sc_uart is
                      generic (ADDR_BITS : integer;
                               CLK_FREQ  : integer;
                               BAUD_RATE : integer;
                               TXF_DEPTH : integer;
                               TXF_THRES : integer;
                               RXF_DEPTH : integer;
                               RXF_THRES : integer);
                    port (CLK     : in  std_logic;
                          RESET   : in  std_logic;
                          ADDRESS : in  std_logic_vector(addr_bits-1 downto 0);
                          WR_DATA : in  std_logic_vector(15 downto 0);
                          RD, WR  : in  std_logic;
                          RD_DATA : out std_logic_vector(15 downto 0);
                          RDY_CNT : out unsigned(1 downto 0);
                          TXD     : out std_logic;
                          RXD     : in  std_logic;
                          NCTS    : in  std_logic;
                          NRTS    : out std_logic);
  end component;


  signal uart_address 		: std_logic_vector(1 downto 0);
  signal uart_wr_data 		:std_logic_vector(15 downto 0);
  signal uart_rd 			: std_logic;
  signal uart_wr 			: std_logic;
  signal uart_rd_data		: std_logic_vector(15 downto 0);

  signal uart_txd_sig 		: std_logic;
  signal uart_rxd_sig 		: std_logic;
  
  signal mem_addr : std_logic_vector (11 downto 0);
  signal mem_data_in :MEM_DATA_T;
  signal mem_data_out :MEM_DATA_T;
  signal mem_wr_enable:  std_logic;

  signal last_address_int : MEM_ADDR_T;
  signal last_address_next : MEM_ADDR_T;

  signal rdy_cnt_sig		: IEEE.NUMERIC_STD.unsigned(1 downto 0);
begin  -- dmem_rtl

  -- Uart modul einbinden
  UART : sc_uart generic map (
    ADDR_BITS => 2,
    CLK_FREQ  => CLK_FREQ,
    BAUD_RATE => 115200,
    TXF_DEPTH => 2,
    TXF_THRES => 1,
    RXF_DEPTH => 2,
    RXF_THRES => 1
    )
    port map(
      CLK     => clk,
      RESET   => reset,
      ADDRESS => uart_address(1 downto 0),
      WR_DATA => uart_wr_data,
      RD      => uart_rd,
      WR      => uart_wr,
      RD_DATA => uart_rd_data,
      RDY_CNT => rdy_cnt_sig,
      TXD     => uart_txd_sig,
      RXD     => uart_rxd_sig,
      NCTS    => '0',
      NRTS    => open
      );

  DATA_MEM : dmem
    port map (
      addr  => mem_addr,
      clk   => clk,
      din   => mem_data_in,
      dout  => mem_data_out,
      sinit => reset,
      we    => mem_wr_enable);


  uart_txd 		<= uart_txd_sig;
  uart_rxd_sig          <= uart_rxd;

  store_address: process (clk, reset)
  begin  -- process data_out
    if reset='0' then
      last_address_int <= (others => '0');    
    elsif clk'event and clk='1' then
      last_address_int <= last_address_next;
    end if;
  end process store_address;

  process (last_address_int, mem_data_out, uart_rd_data)
  begin
    if last_address_int = CONST_UART_STATUS_ADDRESS 
      or last_address_int = CONST_UART_DATA_ADDRESS then
      data_out <= uart_rd_data;
    else
      data_out <= mem_data_out;
    end if;
  end process;

  process (wr_enable, addr, data_in, uart_rd_data, mem_data_out)
  begin

    mem_addr <= (others => '0');
    mem_data_in <= (others => '0');
    mem_wr_enable <= '0';
	 uart_address <= (others => '0');

    uart_wr <= '0';
    uart_wr_data <= (others => '0');
    uart_rd <= '0';

    last_address_next <= addr;
    
    if addr = CONST_UART_STATUS_ADDRESS 
      or addr = CONST_UART_DATA_ADDRESS then
      -- accessing UART

      uart_address <= addr (1 downto 0);
      
		if wr_enable = '1' then
        uart_wr <= '1';
        uart_wr_data <= data_in;
      else
        uart_rd <= '1';
      end if;	
    else
      -- accessing data memory
      mem_addr <= addr(11 downto 0);
      mem_data_in <= data_in;
      mem_wr_enable <= wr_enable;
    end if;

  end process;

end memctrl_rtl;








