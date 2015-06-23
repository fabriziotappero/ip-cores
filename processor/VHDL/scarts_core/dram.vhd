-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

entity scarts_dram is
  generic (
    CONF : scarts_conf_type);
  port (
    clk     : in  std_ulogic;
    hold    : in  std_ulogic;
    dramsel : in  std_ulogic;

    write_en  : in  std_ulogic;
    byte_en   : in  std_logic_vector(3 downto 0);
    data_in   : in  std_logic_vector(31 downto 0);
    addr      : in  std_logic_vector(CONF.data_ram_size-1 downto 2);

    data_out  : out std_logic_vector(31 downto 0));
end scarts_dram;


architecture behaviour of scarts_dram is

  constant WORD_W : natural := CONF.word_size;

  subtype WORD is std_logic_vector(WORD_W-1 downto 0);

  signal ram0i_wdata   : std_logic_vector(7 downto 0);
  signal ram0i_waddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);
  signal ram0i_wen     : std_ulogic;
  signal ram0i_raddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);

  signal ram1i_wdata   : std_logic_vector(7 downto 0);
  signal ram1i_waddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);
  signal ram1i_wen     : std_ulogic;
  signal ram1i_raddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);

  signal ram2i_wdata   : std_logic_vector(7 downto 0);
  signal ram2i_waddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);
  signal ram2i_wen     : std_ulogic;
  signal ram2i_raddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);

  signal ram3i_wdata   : std_logic_vector(7 downto 0);
  signal ram3i_waddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);
  signal ram3i_wen     : std_ulogic;
  signal ram3i_raddr   : std_logic_vector((CONF.data_ram_size-3) downto 0);
  
  signal ram0o_rdata    : std_logic_vector(7 downto 0);
  signal ram1o_rdata    : std_logic_vector(7 downto 0);
  signal ram2o_rdata    : std_logic_vector(7 downto 0);
  signal ram3o_rdata    : std_logic_vector(7 downto 0);

  signal enable : std_ulogic;

begin


  comb : process(dramsel, byte_en, write_en, addr, data_in,
                 ram0o_rdata, ram1o_rdata, ram2o_rdata, ram3o_rdata)
  begin
  
    ram0i_wdata <= (others => '0');
    ram1i_wdata <= (others => '0');
    ram2i_wdata <= (others => '0');
    ram3i_wdata <= (others => '0');
    ram0i_raddr <= (others => '0');
    ram1i_raddr <= (others => '0');
    ram2i_raddr <= (others => '0');
    ram3i_raddr <= (others => '0');
    ram0i_waddr <= (others => '0');
    ram1i_waddr <= (others => '0');
    ram2i_waddr <= (others => '0');
    ram3i_waddr <= (others => '0');
    
    if (dramsel = '1') then
      ram0i_wen <= byte_en(0) and write_en;
      ram1i_wen <= byte_en(1) and write_en;
      ram2i_wen <= byte_en(2) and write_en;
      ram3i_wen <= byte_en(3) and write_en;
    else
      ram0i_wen <= not MEM_WR;
      ram1i_wen <= not MEM_WR;
      ram2i_wen <= not MEM_WR;
      ram3i_wen <= not MEM_WR;
    end if;

    ram0i_raddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    ram1i_raddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    ram2i_raddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    ram3i_raddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    ram0i_waddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    ram1i_waddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    ram2i_waddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    ram3i_waddr(CONF.data_ram_size-3 downto 0) <= addr(CONF.data_ram_size-1 downto 2);
    
    ram0i_wdata <= data_in( 7 downto  0);
    ram1i_wdata <= data_in(15 downto  8);
    ram2i_wdata <= data_in(23 downto 16);
    ram3i_wdata <= data_in(31 downto 24);
    
    data_out( 7 downto  0) <= ram0o_rdata;
    data_out(15 downto  8) <= ram1o_rdata;
    data_out(23 downto 16) <= ram2o_rdata;
    data_out(31 downto 24) <= ram3o_rdata;
    
  end process;

  enable <= not hold;

  ram0 : scarts_byteram
    generic map (CONF => CONF)
    port map (wclk   => clk,
              rclk   => clk,
              enable => enable,
              wdata  => ram0i_wdata,
              waddr  => ram0i_waddr,
              wen    => ram0i_wen,
              raddr  => ram0i_raddr,
              rdata  => ram0o_rdata);
  
  ram1 : scarts_byteram
    generic map (CONF => CONF)
    port map (wclk   => clk,
              rclk   => clk,
              enable => enable,
              wdata  => ram1i_wdata,
              waddr  => ram1i_waddr,
              wen    => ram1i_wen,
              raddr  => ram1i_raddr,
              rdata  => ram1o_rdata);

  ram2 : scarts_byteram
    generic map (CONF => CONF)
    port map (wclk   => clk,
              rclk   => clk,
              enable => enable,
              wdata  => ram2i_wdata,
              waddr  => ram2i_waddr,
              wen    => ram2i_wen,
              raddr  => ram2i_raddr,
              rdata  => ram2o_rdata);

  ram3 : scarts_byteram
    generic map (CONF => CONF)
    port map (wclk   => clk,
              rclk   => clk,
              enable => enable,
              wdata  => ram3i_wdata,
              waddr  => ram3i_waddr,
              wen    => ram3i_wen,
              raddr  => ram3i_raddr,
              rdata  => ram3o_rdata);

--  xilinx_gen : if (TECH_C = XILINX) generate
--    data_ram_inst: xilinx_data_ram
--      port map (
--        clk     => clk,
--        enable  => enable,
--        ram0i    => ram0i,
--        ram0o    => ram0o,
--        ram1i    => ram1i,
--        ram1o    => ram1o,
--        ram2i    => ram2i,
--        ram2o    => ram2o,
--        ram3i    => ram3i,
--        ram3o    => ram3o
--      );
--  end generate;

--  altera_gen : if (TECH_C = ALTERA) generate
--    ram0 : scarts_byteram
--    port map (clk, clk, enable, ram0i, ram0o);
  
--    ram1 : scarts_byteram
--    port map (clk, clk, enable, ram1i, ram1o);
  
--    ram2 : scarts_byteram
--    port map (clk, clk, enable, ram2i, ram2o);

--    ram3 : scarts_byteram
--    port map (clk, clk, enable, ram3i, ram3o);
--  end generate;

							

end behaviour;
