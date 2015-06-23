-------------------------------------------------------------------------------
--
-- Title       : ambpex5_sx50t_wishbone
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 	Top-level module for PCIE_CORE64_WISHBONE_M8
--
-------------------------------------------------------------------------------
--
-- Version 1.0 	20.04.2013
--      		Created from sp605_lx45t_wishbone
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package ambpex5_sx50t_wishbone_pkg is

component ambpex5_sx50t_wishbone is 
generic 
(
    is_simulation       : integer:=0   --! 0 - synthesis, 1 - simulation 
);
port
(
		---- PCI-Express ----
		txp					: out std_logic_vector( 7 downto 0 );
		txn					: out std_logic_vector( 7 downto 0 );
		
		rxp					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		rxn					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		
		mgt251_p			: in  std_logic:='0';   -- reference clock 250 MHz from PCI_Express
		mgt251_n			: in  std_logic:='0';
		
		bperst				: in  std_logic:='0';	-- 0 - reset						   
		
		--btp					: out std_logic_vector(3 downto 1);	   -- testpoint
		
		---- Led ----
		bled1				: out std_logic;
		bled2				: out std_logic;
		bled3				: out std_logic;
		bled4				: out std_logic
    
);

end component ambpex5_sx50t_wishbone;

end package ambpex5_sx50t_wishbone_pkg;
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.ambpex5_sx50t_wishbone_sopc_wb_pkg.all;

entity ambpex5_sx50t_wishbone is 
generic 
(
    is_simulation       : integer:=0   --! 0 - synthesis, 1 - simulation 
);
port
(
		---- PCI-Express ----
		txp					: out std_logic_vector( 7 downto 0 );
		txn					: out std_logic_vector( 7 downto 0 );
		
		rxp					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		rxn					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		
		mgt251_p			: in  std_logic:='0';   -- reference clock 250 MHz from PCI_Express
		mgt251_n			: in  std_logic:='0';
		
		bperst				: in  std_logic:='0';	-- 0 - reset						   
		
		--btp					: out std_logic_vector(3 downto 1);	   -- testpoint
		
		---- Led ----
		bled1				: out std_logic;
		bled2				: out std_logic;
		bled3				: out std_logic;
		bled4				: out std_logic
    
);
end ambpex5_sx50t_wishbone;

architecture rtl of ambpex5_sx50t_wishbone is
-------------------------------------------------------------------------------
-- 
-- PCIE SYS_CON stuff:
signal  mgt250    		: std_logic;
signal  perst     		: std_logic;
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
xled1 :  obuf_s_16 port map( bled1, sv_led_h_p(0) );
xled2 :  obuf_s_16 port map( bled2, sv_led_h_p(1) );
xled3 :  obuf_s_16 port map( bled3, sv_led_h_p(2) );
xled4 :  obuf_s_16 port map( bled4, sv_led_h_p(3) );

-- 									  						  
xmgtclk : IBUFDS  port map (O => mgt250, I => mgt251_p, IB => mgt251_n );	   
xmperst: ibuf port map( perst, bperst );

-------------------------------------------------------------------------------
--
-- Instantiate Wishbone SysteM (with all stuff inside)
--
WB_SOPC :   ambpex5_sx50t_wishbone_sopc_wb
generic map
(
    
    is_simulation   => is_simulation    --! 0 - синтез, 1 - моделирование 
)
port map
(

    ---- PCI-Express ----
    txp             => txp,
    txn             => txn,
    
    rxp             => rxp,
    rxn             => rxn,
 
    --  sys_con
    mgt250          => mgt250,       
    
    perst           => perst,       
      --
    -- GPIO_LED outputs:
    led    			=> sv_led_h
    
);
-------------------------------------------------------------------------------
end rtl;
