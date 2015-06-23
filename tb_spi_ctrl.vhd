
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_spi_ctrl is
end test_spi_ctrl;

architecture test of test_spi_ctrl is
  signal rst, clk, sel, rd, wr : std_logic;
  signal addr : std_logic_vector (2 downto 0);
  signal spi_clk, spi_cs, spi_din, spi_dout : std_logic;
  signal d_in, d_out, stat, data : std_logic_vector (7 downto 0);
  -- FLASH commands
  constant NOP  : std_logic_vector (7 downto 0) := x"FF";  -- no cmd to execute
  constant WREN : std_logic_vector (7 downto 0) := x"06";  -- write enable
  constant WRDI : std_logic_vector (7 downto 0) := x"04";  -- write disable
  constant RDSR : std_logic_vector (7 downto 0) := x"05";  -- read status reg
  constant WRSR : std_logic_vector (7 downto 0) := x"01";  -- write stat. reg
  constant RDCMD: std_logic_vector (7 downto 0) := x"03";  -- read data
  constant F_RD : std_logic_vector (7 downto 0) := x"0B";  -- fast read data
  constant PP :   std_logic_vector (7 downto 0) := x"02";  -- page program
  constant SE :   std_logic_vector (7 downto 0) := x"D8";  -- sector erase
  constant BE :   std_logic_vector (7 downto 0) := x"C7";  -- bulk erase
  constant DP :   std_logic_vector (7 downto 0) := x"B9";  -- deep power down
  constant RES :  std_logic_vector (7 downto 0) := x"AB";  -- read signature
  
  -- status register bit masks
  constant STAT_BUSY : std_logic_vector (7 downto 0) := x"01";
  constant STAT_TXE :  std_logic_vector (7 downto 0) := x"02";
  constant STAT_RXR :  std_logic_vector (7 downto 0) := x"04";
  constant STAT_WDAT : std_logic_vector (7 downto 0) := x"08";
begin
  dut : entity work.spi_ctrl port map (
    clk_in => clk,
    rst => rst,
    spi_clk => spi_clk,
    spi_cs => spi_cs,
    spi_din => spi_din,
    spi_dout => spi_dout,
    sel => sel,
    wr => wr,
    addr => addr,
    d_in => d_in,
    d_out => d_out
  );

  process is
  begin
    clk <= '0'; wait for 20 ns;
    clk <= '1'; wait for 20 ns;
  end process;

  process is
  begin
    rst <= '0'; wait for 50 ns;
    rst <= '1'; wait for 120 ns;
    rst <= '0';
    wait;
  end process;

  process
  begin
    -- initial condition
    sel <= '0'; addr <= "000"; rd <= '0'; wr <= '0'; d_in <= x"FF";
    wait for 1420 ns;

    -- write command WREN
    sel <= '1'; addr <= "001"; d_in <= WREN; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 2 us;

    -- write command WRDI
    sel <= '1'; addr <= "001"; d_in <= WRDI; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 2 us;

    -- write command WRSR: data
    sel <= '1'; addr <= "000"; d_in <= x"55"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- the command
    sel <= '1'; addr <= "001"; d_in <= WRSR; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 4 us;

    -- write command SE:
    -- address low
    sel <= '1'; addr <= "010"; d_in <= x"AB"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    --address mid
    sel <= '1'; addr <= "011"; d_in <= x"CD"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- address high
    sel <= '1'; addr <= "100"; d_in <= x"EF"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- the command
    sel <= '1'; addr <= "001"; d_in <= SE; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 6.5 us;

    -- write command PP:
    -- address low
    sel <= '1'; addr <= "010"; d_in <= x"45"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- address mid
    sel <= '1'; addr <= "011"; d_in <= x"67"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- address high
    sel <= '1'; addr <= "100"; d_in <= x"89"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- the command
    sel <= '1'; addr <= "001"; d_in <= PP; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 100 ns;
    -- some data
    for i in 0 to 20 loop
      -- wait for tx_empty
      stat <= x"00"; wait for 10 ns;
      while (stat and STAT_WDAT) /= STAT_WDAT loop
        sel <= '1'; addr <= "001"; wait for 5 ns;
        rd <= '1'; wait for 100 ns;
        stat <= d_out; rd <= '0'; wait for 5 ns;
        sel <= '0'; wait for 1 us;
      end loop;
      -- write new data
      sel <= '1'; addr <= "000";
      d_in <= std_logic_vector(TO_UNSIGNED(i, d_in'Length)); wait for 5 ns;
      wr <= '1'; wait for 100 ns;
      wr <= '0'; wait for 5 ns;
      sel <= '0'; d_in <= x"FF"; wait for 1 us;
    end loop;
    -- send one more byte
    wait for 10 us;
    sel <= '1'; addr <= "000"; d_in <= x"AA"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 1 us;
    -- write the NOP command to terminate
    sel <= '1'; addr <= "001"; d_in <= NOP; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 100 ns;

    wait for 40 us;

    -- now receive something, cmd RDSR
    sel <= '1'; addr <= "001"; d_in <= RDSR; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF";
    -- poll for rx_ready
    stat <= x"00"; wait for 10 ns;
    while (stat and STAT_RXR) /= STAT_RXR loop
      wait for 200 ns;
      sel <= '1'; addr <= "001"; wait for 5 ns;
      rd <= '1'; wait for 100 ns;
      stat <= d_out; rd <= '0'; wait for 5 ns;
      sel <= '0';
    end loop;
    wait for 100 ns;
    -- read the data            
    sel <= '1'; addr <= "000"; wait for 5 ns;
    rd <= '1'; wait for 100 ns;
    data <= d_out; rd <= '0'; wait for 5 ns;
    sel <= '0'; wait for 1.5 us;

    -- RES command
    sel <= '1'; addr <= "001"; d_in <= RES; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF";
    -- poll for rx_ready
    stat <= x"00"; wait for 10 ns;
    while (stat and STAT_RXR) /= STAT_RXR loop
      wait for 200 ns;
      sel <= '1'; addr <= "001"; wait for 5 ns;
      rd <= '1'; wait for 100 ns;
      stat <= d_out; rd <= '0'; wait for 5 ns;
      sel <= '0';
    end loop;
    wait for 100 ns;
    -- read the data
    sel <= '1'; addr <= "000"; wait for 5 ns;
    rd <= '1'; wait for 100 ns;
    data <= d_out; rd <= '0'; wait for 5 ns;
    sel <= '0'; wait for 1.5 us;

    -- READ command
    -- address low
    sel <= '1'; addr <= "010"; d_in <= x"12"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- address mid
    sel <= '1'; addr <= "011"; d_in <= x"34"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- address high
    sel <= '1'; addr <= "100"; d_in <= x"56"; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF"; wait for 10 ns;
    -- the command
    sel <= '1'; addr <= "001"; d_in <= RDCMD; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF";
    -- read data
    for i in 1 to 10 loop
      -- poll for rx_ready
      stat <= x"00"; wait for 10 ns;
      while (stat and STAT_RXR) /= STAT_RXR loop
        wait for 200 ns;
        sel <= '1'; addr <= "001"; wait for 5 ns;
        rd <= '1'; wait for 100 ns;
        stat <= d_out; rd <= '0'; wait for 5 ns;
        sel <= '0';
      end loop;
      wait for 100 ns;
      -- read the data
      sel <= '1'; addr <= "000"; wait for 5 ns;
      rd <= '1'; wait for 100 ns;
      data <= d_out; rd <= '0'; wait for 5 ns;
      sel <= '0';
    end loop;
    wait for 1 us;
    -- write the NOP command to terminate
    sel <= '1'; addr <= "001"; d_in <= NOP; wait for 5 ns;
    wr <= '1'; wait for 100 ns;
    wr <= '0'; wait for 5 ns;
    sel <= '0'; d_in <= x"FF";

    wait;
  end process;

  process
  begin
    spi_din <= '1'; wait for 144.880 us;

    -- input data for RDSR cmd 0x54
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;

    spi_din <= '1'; wait for 7.68 us;

    -------------------------------

    -- input data for RES cmd 0xAB
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;

    spi_din <= '1'; wait for 8.0 us;

    -------------------------------

    -- input data for RD cmd 0x01
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x02
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x03
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x04
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x05
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x06
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;

    spi_din <= '1'; wait for 640 ns;

    -- input data for RD cmd 0x07
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x08
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x09
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;

    spi_din <= '1'; wait for 480 ns;

    -- input data for RD cmd 0x0A
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;
    spi_din <= '1'; wait for 160 ns;
    spi_din <= '0'; wait for 160 ns;

    spi_din <= '1';

    wait;
  end process;
end test;
