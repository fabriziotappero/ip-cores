-- Version: 8.5 8.5.0.34

library ieee;
use ieee.std_logic_1164.all;
library APA;
use APA.all;

entity pll is 
    port(GLB, LOCK : out std_logic;  CLK : in std_logic) ;
end pll;


architecture DEF_ARCH of  pll is

    component PLLCORE
        port(SDOUT : out std_logic;  SCLK, SDIN, SSHIFT, SUPDATE : 
        in std_logic := 'U'; GLB : out std_logic;  CLK : in 
        std_logic := 'U'; GLA : out std_logic;  CLKA : in 
        std_logic := 'U'; LOCK : out std_logic;  MODE, FBDIV5, 
        EXTFB, FBSEL0, FBSEL1, FINDIV0, FINDIV1, FINDIV2, FINDIV3, 
        FINDIV4, FBDIV0, FBDIV1, FBDIV2, FBDIV3, FBDIV4, STATBSEL, 
        DLYB0, DLYB1, OBDIV0, OBDIV1, STATASEL, DLYA0, DLYA1, 
        OADIV0, OADIV1, OAMUX0, OAMUX1, OBMUX0, OBMUX1, OBMUX2, 
        FBDLY0, FBDLY1, FBDLY2, FBDLY3, XDLYSEL : in std_logic := 
        'U') ;
    end component;

    component PWR
        port( Y : out std_logic);
    end component;

    component GND
        port( Y : out std_logic);
    end component;

    signal VCC, GND_1_net : std_logic ;
    begin   

    PWR_1_net : PWR port map(Y => VCC);
    GND_2_net : GND port map(Y => GND_1_net);
    Core : PLLCORE
      port map(SDOUT => OPEN , SCLK => GND_1_net, SDIN => 
        GND_1_net, SSHIFT => GND_1_net, SUPDATE => GND_1_net, 
        GLB => GLB, CLK => CLK, GLA => OPEN , CLKA => GND_1_net, 
        LOCK => LOCK, MODE => GND_1_net, FBDIV5 => GND_1_net, 
        EXTFB => GND_1_net, FBSEL0 => VCC, FBSEL1 => GND_1_net, 
        FINDIV0 => GND_1_net, FINDIV1 => GND_1_net, FINDIV2 => 
        GND_1_net, FINDIV3 => GND_1_net, FINDIV4 => GND_1_net, 
        FBDIV0 => GND_1_net, FBDIV1 => GND_1_net, FBDIV2 => 
        GND_1_net, FBDIV3 => GND_1_net, FBDIV4 => GND_1_net, 
        STATBSEL => GND_1_net, DLYB0 => GND_1_net, DLYB1 => 
        GND_1_net, OBDIV0 => VCC, OBDIV1 => VCC, STATASEL => 
        GND_1_net, DLYA0 => GND_1_net, DLYA1 => GND_1_net, 
        OADIV0 => GND_1_net, OADIV1 => GND_1_net, OAMUX0 => 
        GND_1_net, OAMUX1 => GND_1_net, OBMUX0 => GND_1_net, 
        OBMUX1 => GND_1_net, OBMUX2 => VCC, FBDLY0 => GND_1_net, 
        FBDLY1 => GND_1_net, FBDLY2 => GND_1_net, FBDLY3 => 
        GND_1_net, XDLYSEL => GND_1_net);
end DEF_ARCH;
