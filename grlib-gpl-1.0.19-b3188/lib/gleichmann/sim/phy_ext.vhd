--------------------------------------------------------------------------------
--  Project:         LEON-ARC
--  Entity:          phy_ext
--  Architecture(s): behav
--  Author:          tame@msc-ge.com
--  Company:         Gleichmann Electronics
--
--  Description:
--    This file is based upon the PHY simulation model by Gaisler Research,
--    which is part of the GNU GPL-licensed GRLIB. For details on the GRLIB, go
--    to www.gaisler.com.
--
--    The original design has been extended in respect to logging signals.
--
--------------------------------------------------------------------------------
--
--  Gaisler original comment:
--  Entity:   	 phy
--  File:	     phy.vhd
--  Description: Simulation model of the Intel LXT971A Ethernet PHY
--               Only the MII interface is implemented.
--               Stimuli is read from a file "indata" and response is
--               written to "outdata"
--  Author:      Marko Isomaki
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

library work;
use work.txt_util.all;


entity phy_ext is
  generic (
    infile_name : string := "indata";
    outfile_name : string := "outdata";
    logfile_name : string := "logfile";
    win_size : natural := 3);           -- number of packages that form a window
  port (
    resetn    : in    std_logic;
    led_cfg   : in    std_logic_vector(2 downto 0);
    log_en    : in    std_logic := '1';
    cycle_num : in    integer;
    mdio      : inout std_logic;
    tx_clk    : out   std_logic;
    rx_clk    : out   std_logic;
    rxd       : out   std_logic_vector(3 downto 0);
    rx_dv     : out   std_logic;
    rx_er     : out   std_logic;
    rx_col    : out   std_logic;
    rx_crs    : out   std_logic;
    txd       : in    std_logic_vector(3 downto 0);
    tx_en     : in    std_logic;
    tx_er     : in    std_logic;
    mdc       : in    std_logic);
end entity;


architecture behav of phy_ext is
  --type declarations
  type state_type is (base10h, base10f, base100h, base100f);

  type reg_type is
    record
      crs       : std_logic;
      tx_count  : integer range 0 to 1;
      tx_output : std_logic_vector(3 downto 0);
      rx_dv     : std_logic;
      rx_er     : std_logic;
      prev_txd  : std_logic;
      state     : state_type;
      new_data  : std_logic;
      new_txd   : std_logic;
      counter   : integer range 0 to 400000;
      pcount    : integer range 0 to 64;
    end record;

  --signal declarations
  signal clk_fast : std_logic := '0';
  signal clk_slow : std_logic := '0';
  signal temp_clk : std_logic;
  signal r, rin   : reg_type;

  file indata     : text open read_mode is infile_name;
  file outdata    : text open write_mode is outfile_name;

  -- logfile contains read and write accesses
  file logfile            : text open write_mode is logfile_name;
  shared variable logline : line;
  shared variable logstring : string(1 to 80);

  signal temp_col : std_logic;

begin
  --clock generation
  clk_fast <= not clk_fast after 20 ns;
  clk_slow <= not clk_slow after 200 ns;   
    
  temp_clk <= clk_fast when r.state = base100h or r.state = base100f else
              clk_slow;
    
  rx_clk <= temp_clk;
  tx_clk <= temp_clk;
    
  --unused signals
  mdio <= 'Z';

  comb : process(r, txd, tx_en, tx_er)
    variable v   : reg_type;
    variable col : std_logic;
  begin
    v          := r;
    v.prev_txd := r.new_txd;
    v.crs      := '0';
    v.new_data := '0';
    --transmitter part
    v.new_txd  := tx_en;
    if tx_er = '1' then
      v.tx_output := X"F";
    elsif tx_en = '1' then
      v.tx_output := txd;
    end if;

    if (r.state = base10h or r.state = base100h) and tx_en = '1' then
      v.crs := '1';
    end if;
    --receiver part
    if r.counter > 0 then
      v.counter := r.counter-1;
    end if;

    v.rx_dv := '0';
    v.rx_er := '0';

    if r.counter = 0 then
      if(tx_en = '0' or (r.new_txd = '0' and tx_en = '1') or
          r.state = base100f or r.state = base10f) then
        v.rx_dv    := '1';
        v.new_data := '1';
        v.crs      := '1';
      end if;
    end if;

    --control signals
    if (r.state = base10h or r.state = base100h) and
      tx_en = '1' and r.rx_dv = '1' then
      col := '1';
    else
      col := '0';
    end if;
    --output

    rx_col <= col;
    temp_col <= col;

    rx_crs <= r.crs;
    rx_dv  <= r.rx_dv;
    rx_er  <= r.rx_er;
    --registers
    rin    <= v;
  end process comb;

  log_start : process is
  begin
    if log_en = '1' then
      print(logfile, "#");
      print(logfile, "# RX_TRANSFER CYCLE_NUMBER RX_CLK RX_DV RX_ER COL CRS RXD MDC MDIO");
      print(logfile, "# TX_TRANSFER CYCLE_NUMBER TX_CLK TX_EN TX_ER TXD");
      print(logfile, "#");
    end if;
    wait;
  end process;

  regs : process(resetn, temp_clk)
    variable textline : line;
    variable wline    : line;
    variable din_tmp  : bit_vector(3 downto 0);
    variable din_ok   : boolean;
  begin
    if resetn = '0' then
      case led_cfg is
        when "000"  => r.state <= base10h;
        when "001"  => r.state <= base10f;
        when "010"  => r.state <= base100h;
        when "011"  => r.state <= base100f;
        when others => r.state <= base10h;
      end case;
      r.crs      <= '0';
      r.tx_count <= 0;
      r.new_txd  <= '0';
      r.rx_dv    <= '0';
      r.rx_er    <= '0';
      r.new_data <= '0';
      r.counter  <= 2000;
      r.pcount   <= 0;
    elsif rising_edge(temp_clk) then
      r <= rin;
      if rin.new_data = '1' and not endfile(indata) then
        readline(indata, textline);
        read(textline, din_tmp, din_ok);
        if din_ok then
          rxd <= to_stdlogicvector(din_tmp);
          -- write RX data to logfile
          if log_en = '1' then
            print(logfile,
                  string'("RX ") &
                  str(cycle_num) & " " &  -- current clock cycle number
                  str(temp_clk) & " " &  -- equivalent to rx_clk
                  str(r.rx_dv) & " " &  -- receive data valid
                  str(r.rx_er) & " " &  -- receive error
                  str(temp_col) & " " &  -- equivalent to rx_col
                  str(r.crs) & " " &    -- receive carrier sense
                  hstr(to_stdlogicvector(din_tmp)) & " " &  -- receive data
                  str(mdc) & " " &
                  str(mdio));
          end if;
        else
          report "new-packet" severity note;
          r.pcount <= rin.pcount + 1;
          if rin.pcount + 1 /= win_size then
            if r.state = base100h or r.state = base100f then
              r.counter <= 500;
            else
              r.counter <= 50;
            end if;
          else
            r.counter <= 1000;
            r.pcount  <= 0;
          end if;
          rxd     <= (others => 'U');
          r.rx_dv <= '0';
          r.crs   <= '0';
        end if;
      else
        rxd     <= (others => 'U');
        r.rx_dv <= '0';
        r.crs   <= '0';
      end if;

      if rin.new_txd = '1' then
        write(wline, to_bitvector(rin.tx_output), left, 4);
        writeline(outdata, wline);
        -- write TX data to logfile
        if log_en = '1' then
          print(logfile,
                string'("TX ") &
                str(cycle_num) & " " &  -- current clock cycle number
                str(temp_clk) & " " &   -- equivalent to tx_clk
                str(tx_en) & " " &      -- always enabled here
                str(tx_er) & " " &      -- transmit error
                hstr(txd));             -- transmit data
        end if;
        if r.state = base10h or r.state = base100h then
          r.crs <= '1';
        end if;
      elsif rin.prev_txd = '1' then
        write(wline, string'("end"), left, 3);
        writeline(outdata, wline);
      end if;
    end if;
  end process regs;

end architecture;
