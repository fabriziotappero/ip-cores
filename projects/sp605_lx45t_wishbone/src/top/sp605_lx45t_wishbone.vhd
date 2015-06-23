-------------------------------------------------------------------------------
--
-- Title       : sp605_lx45t_wishbone
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 	Проверка ядра PCI Express на модуле SP605
--
-------------------------------------------------------------------------------
--
-- Version 1.1 (15.10.2011) : Kuzmi4
--      Update TOP stuct + WB_SOPC
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package sp605_lx45t_wishbone_pkg is

component sp605_lx45t_wishbone is 
generic 
(
    is_simulation       : integer:=0    -- 0 - синтез, 1 - моделирование ADM
);
port
(
    ---- PCI-Express ----
    pci_exp_txp         : out std_logic_vector(0 downto 0);
    pci_exp_txn         : out std_logic_vector(0 downto 0);
    pci_exp_rxp         : in std_logic_vector(0 downto 0);
    pci_exp_rxn         : in std_logic_vector(0 downto 0);
    
    sys_clk_p           : in std_logic;
    sys_clk_n           : in std_logic;
    sys_reset_n         : in std_logic;
    
    ---- Светодиоды ----
    gpio_led0           : out std_logic;
    gpio_led1           : out std_logic; 
    gpio_led2           : out std_logic; 
    gpio_led3           : out std_logic
    
);

end component sp605_lx45t_wishbone;

end package sp605_lx45t_wishbone_pkg;
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.sp605_lx45t_wishbone_sopc_wb_pkg.all;

entity sp605_lx45t_wishbone is 
generic 
(
    is_simulation       : integer:=0    -- 0 - синтез, 1 - моделирование ADM
);
port
(
    ---- PCI-Express ----
    pci_exp_txp         : out std_logic_vector(0 downto 0);
    pci_exp_txn         : out std_logic_vector(0 downto 0);
    pci_exp_rxp         : in std_logic_vector(0 downto 0);
    pci_exp_rxn         : in std_logic_vector(0 downto 0);
    
    sys_clk_p           : in std_logic;
    sys_clk_n           : in std_logic;
    sys_reset_n         : in std_logic;
    
    ---- Светодиоды ----
    gpio_led0           : out std_logic;
    gpio_led1           : out std_logic; 
    gpio_led2           : out std_logic; 
    gpio_led3           : out std_logic
    
);
end sp605_lx45t_wishbone;

architecture rtl of sp605_lx45t_wishbone is
-------------------------------------------------------------------------------
-- 
-- PCIE SYS_CON stuff:
signal  s_clk_125MHz    : std_logic;
signal  s_sys_rst_n     : std_logic;
-------------------------------------------------------------------------------
--
-- OUTRPUT LED stuff:
signal  sv_led_h        : std_logic_vector(3 downto 0);
signal  sv_led_h_p      : std_logic_vector(3 downto 0);
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
--
-- Module In/Out deal:
--
--
sv_led_h_p <= not sv_led_h;
-- 
xled0 :  obuf_s_16 port map( gpio_led0, sv_led_h_p(0) );
xled1 :  obuf_s_16 port map( gpio_led1, sv_led_h_p(1) );
xled2 :  obuf_s_16 port map( gpio_led2, sv_led_h_p(2) );
xled3 :  obuf_s_16 port map( gpio_led3, sv_led_h_p(3) );

-- 
refclk_ibuf : ibufds    port map (O => s_clk_125MHz, I => sys_clk_p, IB => sys_clk_n );
xmperst     : ibuf      port map (O => s_sys_rst_n,  I => sys_reset_n                );
-------------------------------------------------------------------------------
--
-- Instantiate Wishbone SysteM (with all stuff inside)
--
WB_SOPC :   sp605_lx45t_wishbone_sopc_wb
generic map
(
    
    is_simulation   => is_simulation    --! 0 - синтез, 1 - моделирование 
)
port map
(
    -- 
    -- PCIE x1 bus:
    --  data
    ov_pci_exp_txp  => pci_exp_txp,
    ov_pci_exp_txn  => pci_exp_txn,
    
    iv_pci_exp_rxp  => pci_exp_rxp,
    iv_pci_exp_rxn  => pci_exp_rxn,
    --  sys_con
    i_sys_clk       => s_clk_125MHz,
    i_sys_reset_n   => s_sys_rst_n,
    --
    -- GPIO_LED outputs:
    ov_gpio_led     => sv_led_h
    
);
-------------------------------------------------------------------------------
end rtl;
