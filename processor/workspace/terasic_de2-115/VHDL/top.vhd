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

use work.top_pkg.all;
use work.scarts_pkg.all;
use work.scarts_amba_pkg.all;
use work.pkg_dis7seg.all;

entity top is
  port(
    db_clk      : in  std_ulogic;
    rst         : in  std_ulogic;
    -- Debug Interface
    D_RxD       : in  std_logic; 
    D_TxD       : out std_logic;
    -- 7Segment Anzeige
    digits      : out digit_vector_t(7 downto 0)
    );
end top;

architecture behaviour of top is
  
  signal scarts_i    : scarts_in_type;
  signal scarts_o    : scarts_out_type;

  signal debugi_if : debug_if_in_type;
  signal debugo_if : debug_if_out_type;

  signal exti      : module_in_type;
  signal ahbmi     : ahb_master_in_type;
  
  signal syncrst     : std_ulogic;
  signal sysrst      : std_ulogic;
  signal clk         : std_logic;
  signal dis7segsel  : std_ulogic;
  signal dis7segexto : module_out_type;
  
  component altera_pll IS
    PORT
      (
        areset		: IN STD_LOGIC  := '0';
        inclk0		: IN STD_LOGIC  := '0';
        c0		: OUT STD_LOGIC ;
        locked		: OUT STD_LOGIC 
        );
   END component;

begin
	
  altera_pll_inst : altera_pll PORT MAP (
    areset	 => '0',
    inclk0	 => db_clk,
    c0	         => clk,
    locked	 => open
    );

  scarts_unit: scarts
    generic map (
    CONF => (
      tech => work.scarts_pkg.ALTERA,
      word_size => 32,
      boot_rom_size => 12,
      instr_ram_size => 16,
      data_ram_size => 17,
      use_iram => true,
      use_amba => false,
      amba_shm_size => 8,
      amba_word_size => 32,
      gdb_mode => 0,
      bootrom_base_address => 29
      ))
    port map(
      clk    => clk,
      sysrst => sysrst,
      extrst => syncrst,
      scarts_i => scarts_i,
      scarts_o => scarts_o,
      ahbmi  => ahbmi,
      ahbmo  => open,
      debugi_if => debugi_if,
      debugo_if => debugo_if
      );
 
  ahbmi <= AMBA_MASTER_IN_VOID;
    
  dis7seg_unit: ext_dis7seg
    generic map (
      DIGIT_COUNT => 8,
      MULTIPLEXED => 0)
    port map(
      clk        => clk,
      extsel     => dis7segsel,
      exti       => exti,
      exto       => dis7segexto,
      digits     => digits,
      DisEna     => open,
      PIN_select => open
      );

  comb : process(scarts_o, debugo_if, D_RxD, dis7segexto)
    variable extdata : std_logic_vector(31 downto 0);
  begin   
    exti.reset    <= scarts_o.reset;
    exti.write_en <= scarts_o.write_en;
    exti.data     <= scarts_o.data;
    exti.addr     <= scarts_o.addr;
    exti.byte_en  <= scarts_o.byte_en;

    dis7segsel <= '0';
    
    if scarts_o.extsel = '1' then
      case scarts_o.addr(14 downto 5) is
        when "1111110111" => -- (-288)
          --DIS7SEG Module
          dis7segsel <= '1';
        when others =>
          null;
      end case;
    end if;
    
    extdata := (others => '0');
    for i in extdata'left downto extdata'right loop
      extdata(i) := dis7segexto.data(i); 
    end loop;

    scarts_i.data <= (others => '0');
    scarts_i.data <= extdata;
    scarts_i.hold <= '0';
    scarts_i.interruptin <= (others => '0');
    

    --Debug interface
    D_TxD             <= debugo_if.D_TxD;
    debugi_if.D_RxD   <= D_RxD;
  end process;


  reg : process(clk)
  begin
    if rising_edge(clk) then
      --
      -- input flip-flops
      --
      syncrst <= rst;
    end if;
  end process;


end behaviour;
