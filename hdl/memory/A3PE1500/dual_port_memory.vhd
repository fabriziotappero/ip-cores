----------------------------------------------------------------------------------------------------
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: dual_port_memory.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   MEMORY - Dual Port Memory
--|   Generated with Actel SmartGen tool. It will not work with other Actel FPGA than A3PE1500 
--|		or similar.
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.10  | jan-2009 | First release
----------------------------------------------------------------------------------------------------


-- Libero Project Manager Version: 8.5 SP1 8.5.1.13
-- Copyright 1989-2009  Actel Corporation


-- · Parámetros 
---- Generales
-- Reset: Not inverted
-- Double clock
-- High Speed
---- Both ports
-- Depth: 15360
-- Width: 16
-- BLKx: Not Inverted
-- CLKA: Rising
-- Pipeline: no
-- DOUT type: DINA0


-- Version: 8.5 8.5.0.34

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity dual_port_memory is 
  port( 
    DINA:   in    std_logic_vector(15 downto 0); 
    DOUTA:  out   std_logic_vector(15 downto 0);  
    ADDRA:  in    std_logic_vector(13 downto 0);  -- Only available until 15360
    RWA:    in    std_logic;                      -- '1' Read, '0' Write
    BLKA:   in    std_logic;                      -- '1' Block select
    CLKA:   in    std_logic;                      -- Rising edge

    DINB:   in    std_logic_vector(15 downto 0); 
    DOUTB:  out   std_logic_vector(15 downto 0); 
    ADDRB:  in    std_logic_vector(13 downto 0);
    RWB:    in    std_logic; 
    BLKB:   in    std_logic; 
    CLKB:   in    std_logic;

    RESET:  in    std_logic                       -- '1' Reset
  ) ;
  
end dual_port_memory;


architecture DEF_ARCH of  dual_port_memory is

    component BUFF
        port(A : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component RAM4K9
    generic (MEMORYFILE:string := "");

        port(ADDRA11, ADDRA10, ADDRA9, ADDRA8, ADDRA7, ADDRA6, 
        ADDRA5, ADDRA4, ADDRA3, ADDRA2, ADDRA1, ADDRA0, ADDRB11, 
        ADDRB10, ADDRB9, ADDRB8, ADDRB7, ADDRB6, ADDRB5, ADDRB4, 
        ADDRB3, ADDRB2, ADDRB1, ADDRB0, DINA8, DINA7, DINA6, 
        DINA5, DINA4, DINA3, DINA2, DINA1, DINA0, DINB8, DINB7, 
        DINB6, DINB5, DINB4, DINB3, DINB2, DINB1, DINB0, WIDTHA0, 
        WIDTHA1, WIDTHB0, WIDTHB1, PIPEA, PIPEB, WMODEA, WMODEB, 
        BLKA, BLKB, WENA, WENB, CLKA, CLKB, RESET : in std_logic := 
        'U'; DOUTA8, DOUTA7, DOUTA6, DOUTA5, DOUTA4, DOUTA3, 
        DOUTA2, DOUTA1, DOUTA0, DOUTB8, DOUTB7, DOUTB6, DOUTB5, 
        DOUTB4, DOUTB3, DOUTB2, DOUTB1, DOUTB0 : out std_logic) ;
    end component;

    component OR2
        port(A, B : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component MX2
        port(A, B, S : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component NAND2
        port(A, B : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component DFN1
        port(D, CLK : in std_logic := 'U'; Q : out std_logic) ;
    end component;

    component INV
        port(A : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component AND2A
        port(A, B : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component NOR2
        port(A, B : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component AND2
        port(A, B : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component VCC
        port( Y : out std_logic);
    end component;

    component GND
        port( Y : out std_logic);
    end component;

    signal WEAP, WEBP, RESETP, ADDRA_FF2_0_net, ADDRA_FF2_1_net, 
        ADDRA_FF2_2_net, ADDRA_FF2_3_net, ADDRB_FF2_0_net, 
        ADDRB_FF2_1_net, ADDRB_FF2_2_net, ADDRB_FF2_3_net, 
        ENABLE_ADDRA_0_net, ENABLE_ADDRA_1_net, 
        ENABLE_ADDRA_2_net, ENABLE_ADDRA_3_net, 
        ENABLE_ADDRA_4_net, ENABLE_ADDRA_5_net, 
        ENABLE_ADDRA_6_net, ENABLE_ADDRA_7_net, 
        ENABLE_ADDRA_8_net, ENABLE_ADDRA_9_net, 
        ENABLE_ADDRA_10_net, ENABLE_ADDRA_11_net, 
        ENABLE_ADDRA_12_net, ENABLE_ADDRA_13_net, 
        ENABLE_ADDRA_14_net, ENABLE_ADDRB_0_net, 
        ENABLE_ADDRB_1_net, ENABLE_ADDRB_2_net, 
        ENABLE_ADDRB_3_net, ENABLE_ADDRB_4_net, 
        ENABLE_ADDRB_5_net, ENABLE_ADDRB_6_net, 
        ENABLE_ADDRB_7_net, ENABLE_ADDRB_8_net, 
        ENABLE_ADDRB_9_net, ENABLE_ADDRB_10_net, 
        ENABLE_ADDRB_11_net, ENABLE_ADDRB_12_net, 
        ENABLE_ADDRB_13_net, ENABLE_ADDRB_14_net, BLKA_EN_0_net, 
        BLKB_EN_0_net, BLKA_EN_1_net, BLKB_EN_1_net, 
        BLKA_EN_2_net, BLKB_EN_2_net, BLKA_EN_3_net, 
        BLKB_EN_3_net, BLKA_EN_4_net, BLKB_EN_4_net, 
        BLKA_EN_5_net, BLKB_EN_5_net, BLKA_EN_6_net, 
        BLKB_EN_6_net, BLKA_EN_7_net, BLKB_EN_7_net, 
        BLKA_EN_8_net, BLKB_EN_8_net, BLKA_EN_9_net, 
        BLKB_EN_9_net, BLKA_EN_10_net, BLKB_EN_10_net, 
        BLKA_EN_11_net, BLKB_EN_11_net, BLKA_EN_12_net, 
        BLKB_EN_12_net, BLKA_EN_13_net, BLKB_EN_13_net, 
        BLKA_EN_14_net, BLKB_EN_14_net, QBX_TEMPR0_0_net, 
        QBX_TEMPR0_1_net, QBX_TEMPR0_2_net, QBX_TEMPR0_3_net, 
        QBX_TEMPR1_0_net, QBX_TEMPR1_1_net, QBX_TEMPR1_2_net, 
        QBX_TEMPR1_3_net, QBX_TEMPR2_0_net, QBX_TEMPR2_1_net, 
        QBX_TEMPR2_2_net, QBX_TEMPR2_3_net, QBX_TEMPR3_0_net, 
        QBX_TEMPR3_1_net, QBX_TEMPR3_2_net, QBX_TEMPR3_3_net, 
        QBX_TEMPR4_0_net, QBX_TEMPR4_1_net, QBX_TEMPR4_2_net, 
        QBX_TEMPR4_3_net, QBX_TEMPR5_0_net, QBX_TEMPR5_1_net, 
        QBX_TEMPR5_2_net, QBX_TEMPR5_3_net, QBX_TEMPR6_0_net, 
        QBX_TEMPR6_1_net, QBX_TEMPR6_2_net, QBX_TEMPR6_3_net, 
        QBX_TEMPR7_0_net, QBX_TEMPR7_1_net, QBX_TEMPR7_2_net, 
        QBX_TEMPR7_3_net, QBX_TEMPR8_0_net, QBX_TEMPR8_1_net, 
        QBX_TEMPR8_2_net, QBX_TEMPR8_3_net, QBX_TEMPR9_0_net, 
        QBX_TEMPR9_1_net, QBX_TEMPR9_2_net, QBX_TEMPR9_3_net, 
        QBX_TEMPR10_0_net, QBX_TEMPR10_1_net, QBX_TEMPR10_2_net, 
        QBX_TEMPR10_3_net, QBX_TEMPR11_0_net, QBX_TEMPR11_1_net, 
        QBX_TEMPR11_2_net, QBX_TEMPR11_3_net, QBX_TEMPR12_0_net, 
        QBX_TEMPR12_1_net, QBX_TEMPR12_2_net, QBX_TEMPR12_3_net, 
        QBX_TEMPR13_0_net, QBX_TEMPR13_1_net, QBX_TEMPR13_2_net, 
        QBX_TEMPR13_3_net, QBX_TEMPR14_0_net, QBX_TEMPR14_1_net, 
        QBX_TEMPR14_2_net, QBX_TEMPR14_3_net, QAX_TEMPR0_0_net, 
        QAX_TEMPR0_1_net, QAX_TEMPR0_2_net, QAX_TEMPR0_3_net, 
        QAX_TEMPR1_0_net, QAX_TEMPR1_1_net, QAX_TEMPR1_2_net, 
        QAX_TEMPR1_3_net, QAX_TEMPR2_0_net, QAX_TEMPR2_1_net, 
        QAX_TEMPR2_2_net, QAX_TEMPR2_3_net, QAX_TEMPR3_0_net, 
        QAX_TEMPR3_1_net, QAX_TEMPR3_2_net, QAX_TEMPR3_3_net, 
        QAX_TEMPR4_0_net, QAX_TEMPR4_1_net, QAX_TEMPR4_2_net, 
        QAX_TEMPR4_3_net, QAX_TEMPR5_0_net, QAX_TEMPR5_1_net, 
        QAX_TEMPR5_2_net, QAX_TEMPR5_3_net, QAX_TEMPR6_0_net, 
        QAX_TEMPR6_1_net, QAX_TEMPR6_2_net, QAX_TEMPR6_3_net, 
        QAX_TEMPR7_0_net, QAX_TEMPR7_1_net, QAX_TEMPR7_2_net, 
        QAX_TEMPR7_3_net, QAX_TEMPR8_0_net, QAX_TEMPR8_1_net, 
        QAX_TEMPR8_2_net, QAX_TEMPR8_3_net, QAX_TEMPR9_0_net, 
        QAX_TEMPR9_1_net, QAX_TEMPR9_2_net, QAX_TEMPR9_3_net, 
        QAX_TEMPR10_0_net, QAX_TEMPR10_1_net, QAX_TEMPR10_2_net, 
        QAX_TEMPR10_3_net, QAX_TEMPR11_0_net, QAX_TEMPR11_1_net, 
        QAX_TEMPR11_2_net, QAX_TEMPR11_3_net, QAX_TEMPR12_0_net, 
        QAX_TEMPR12_1_net, QAX_TEMPR12_2_net, QAX_TEMPR12_3_net, 
        QAX_TEMPR13_0_net, QAX_TEMPR13_1_net, QAX_TEMPR13_2_net, 
        QAX_TEMPR13_3_net, QAX_TEMPR14_0_net, QAX_TEMPR14_1_net, 
        QAX_TEMPR14_2_net, QAX_TEMPR14_3_net, QBX_TEMPR0_4_net, 
        QBX_TEMPR0_5_net, QBX_TEMPR0_6_net, QBX_TEMPR0_7_net, 
        QBX_TEMPR1_4_net, QBX_TEMPR1_5_net, QBX_TEMPR1_6_net, 
        QBX_TEMPR1_7_net, QBX_TEMPR2_4_net, QBX_TEMPR2_5_net, 
        QBX_TEMPR2_6_net, QBX_TEMPR2_7_net, QBX_TEMPR3_4_net, 
        QBX_TEMPR3_5_net, QBX_TEMPR3_6_net, QBX_TEMPR3_7_net, 
        QBX_TEMPR4_4_net, QBX_TEMPR4_5_net, QBX_TEMPR4_6_net, 
        QBX_TEMPR4_7_net, QBX_TEMPR5_4_net, QBX_TEMPR5_5_net, 
        QBX_TEMPR5_6_net, QBX_TEMPR5_7_net, QBX_TEMPR6_4_net, 
        QBX_TEMPR6_5_net, QBX_TEMPR6_6_net, QBX_TEMPR6_7_net, 
        QBX_TEMPR7_4_net, QBX_TEMPR7_5_net, QBX_TEMPR7_6_net, 
        QBX_TEMPR7_7_net, QBX_TEMPR8_4_net, QBX_TEMPR8_5_net, 
        QBX_TEMPR8_6_net, QBX_TEMPR8_7_net, QBX_TEMPR9_4_net, 
        QBX_TEMPR9_5_net, QBX_TEMPR9_6_net, QBX_TEMPR9_7_net, 
        QBX_TEMPR10_4_net, QBX_TEMPR10_5_net, QBX_TEMPR10_6_net, 
        QBX_TEMPR10_7_net, QBX_TEMPR11_4_net, QBX_TEMPR11_5_net, 
        QBX_TEMPR11_6_net, QBX_TEMPR11_7_net, QBX_TEMPR12_4_net, 
        QBX_TEMPR12_5_net, QBX_TEMPR12_6_net, QBX_TEMPR12_7_net, 
        QBX_TEMPR13_4_net, QBX_TEMPR13_5_net, QBX_TEMPR13_6_net, 
        QBX_TEMPR13_7_net, QBX_TEMPR14_4_net, QBX_TEMPR14_5_net, 
        QBX_TEMPR14_6_net, QBX_TEMPR14_7_net, QAX_TEMPR0_4_net, 
        QAX_TEMPR0_5_net, QAX_TEMPR0_6_net, QAX_TEMPR0_7_net, 
        QAX_TEMPR1_4_net, QAX_TEMPR1_5_net, QAX_TEMPR1_6_net, 
        QAX_TEMPR1_7_net, QAX_TEMPR2_4_net, QAX_TEMPR2_5_net, 
        QAX_TEMPR2_6_net, QAX_TEMPR2_7_net, QAX_TEMPR3_4_net, 
        QAX_TEMPR3_5_net, QAX_TEMPR3_6_net, QAX_TEMPR3_7_net, 
        QAX_TEMPR4_4_net, QAX_TEMPR4_5_net, QAX_TEMPR4_6_net, 
        QAX_TEMPR4_7_net, QAX_TEMPR5_4_net, QAX_TEMPR5_5_net, 
        QAX_TEMPR5_6_net, QAX_TEMPR5_7_net, QAX_TEMPR6_4_net, 
        QAX_TEMPR6_5_net, QAX_TEMPR6_6_net, QAX_TEMPR6_7_net, 
        QAX_TEMPR7_4_net, QAX_TEMPR7_5_net, QAX_TEMPR7_6_net, 
        QAX_TEMPR7_7_net, QAX_TEMPR8_4_net, QAX_TEMPR8_5_net, 
        QAX_TEMPR8_6_net, QAX_TEMPR8_7_net, QAX_TEMPR9_4_net, 
        QAX_TEMPR9_5_net, QAX_TEMPR9_6_net, QAX_TEMPR9_7_net, 
        QAX_TEMPR10_4_net, QAX_TEMPR10_5_net, QAX_TEMPR10_6_net, 
        QAX_TEMPR10_7_net, QAX_TEMPR11_4_net, QAX_TEMPR11_5_net, 
        QAX_TEMPR11_6_net, QAX_TEMPR11_7_net, QAX_TEMPR12_4_net, 
        QAX_TEMPR12_5_net, QAX_TEMPR12_6_net, QAX_TEMPR12_7_net, 
        QAX_TEMPR13_4_net, QAX_TEMPR13_5_net, QAX_TEMPR13_6_net, 
        QAX_TEMPR13_7_net, QAX_TEMPR14_4_net, QAX_TEMPR14_5_net, 
        QAX_TEMPR14_6_net, QAX_TEMPR14_7_net, QBX_TEMPR0_8_net, 
        QBX_TEMPR0_9_net, QBX_TEMPR0_10_net, QBX_TEMPR0_11_net, 
        QBX_TEMPR1_8_net, QBX_TEMPR1_9_net, QBX_TEMPR1_10_net, 
        QBX_TEMPR1_11_net, QBX_TEMPR2_8_net, QBX_TEMPR2_9_net, 
        QBX_TEMPR2_10_net, QBX_TEMPR2_11_net, QBX_TEMPR3_8_net, 
        QBX_TEMPR3_9_net, QBX_TEMPR3_10_net, QBX_TEMPR3_11_net, 
        QBX_TEMPR4_8_net, QBX_TEMPR4_9_net, QBX_TEMPR4_10_net, 
        QBX_TEMPR4_11_net, QBX_TEMPR5_8_net, QBX_TEMPR5_9_net, 
        QBX_TEMPR5_10_net, QBX_TEMPR5_11_net, QBX_TEMPR6_8_net, 
        QBX_TEMPR6_9_net, QBX_TEMPR6_10_net, QBX_TEMPR6_11_net, 
        QBX_TEMPR7_8_net, QBX_TEMPR7_9_net, QBX_TEMPR7_10_net, 
        QBX_TEMPR7_11_net, QBX_TEMPR8_8_net, QBX_TEMPR8_9_net, 
        QBX_TEMPR8_10_net, QBX_TEMPR8_11_net, QBX_TEMPR9_8_net, 
        QBX_TEMPR9_9_net, QBX_TEMPR9_10_net, QBX_TEMPR9_11_net, 
        QBX_TEMPR10_8_net, QBX_TEMPR10_9_net, QBX_TEMPR10_10_net, 
        QBX_TEMPR10_11_net, QBX_TEMPR11_8_net, QBX_TEMPR11_9_net, 
        QBX_TEMPR11_10_net, QBX_TEMPR11_11_net, QBX_TEMPR12_8_net, 
        QBX_TEMPR12_9_net, QBX_TEMPR12_10_net, QBX_TEMPR12_11_net, 
        QBX_TEMPR13_8_net, QBX_TEMPR13_9_net, QBX_TEMPR13_10_net, 
        QBX_TEMPR13_11_net, QBX_TEMPR14_8_net, QBX_TEMPR14_9_net, 
        QBX_TEMPR14_10_net, QBX_TEMPR14_11_net, QAX_TEMPR0_8_net, 
        QAX_TEMPR0_9_net, QAX_TEMPR0_10_net, QAX_TEMPR0_11_net, 
        QAX_TEMPR1_8_net, QAX_TEMPR1_9_net, QAX_TEMPR1_10_net, 
        QAX_TEMPR1_11_net, QAX_TEMPR2_8_net, QAX_TEMPR2_9_net, 
        QAX_TEMPR2_10_net, QAX_TEMPR2_11_net, QAX_TEMPR3_8_net, 
        QAX_TEMPR3_9_net, QAX_TEMPR3_10_net, QAX_TEMPR3_11_net, 
        QAX_TEMPR4_8_net, QAX_TEMPR4_9_net, QAX_TEMPR4_10_net, 
        QAX_TEMPR4_11_net, QAX_TEMPR5_8_net, QAX_TEMPR5_9_net, 
        QAX_TEMPR5_10_net, QAX_TEMPR5_11_net, QAX_TEMPR6_8_net, 
        QAX_TEMPR6_9_net, QAX_TEMPR6_10_net, QAX_TEMPR6_11_net, 
        QAX_TEMPR7_8_net, QAX_TEMPR7_9_net, QAX_TEMPR7_10_net, 
        QAX_TEMPR7_11_net, QAX_TEMPR8_8_net, QAX_TEMPR8_9_net, 
        QAX_TEMPR8_10_net, QAX_TEMPR8_11_net, QAX_TEMPR9_8_net, 
        QAX_TEMPR9_9_net, QAX_TEMPR9_10_net, QAX_TEMPR9_11_net, 
        QAX_TEMPR10_8_net, QAX_TEMPR10_9_net, QAX_TEMPR10_10_net, 
        QAX_TEMPR10_11_net, QAX_TEMPR11_8_net, QAX_TEMPR11_9_net, 
        QAX_TEMPR11_10_net, QAX_TEMPR11_11_net, QAX_TEMPR12_8_net, 
        QAX_TEMPR12_9_net, QAX_TEMPR12_10_net, QAX_TEMPR12_11_net, 
        QAX_TEMPR13_8_net, QAX_TEMPR13_9_net, QAX_TEMPR13_10_net, 
        QAX_TEMPR13_11_net, QAX_TEMPR14_8_net, QAX_TEMPR14_9_net, 
        QAX_TEMPR14_10_net, QAX_TEMPR14_11_net, QBX_TEMPR0_12_net, 
        QBX_TEMPR0_13_net, QBX_TEMPR0_14_net, QBX_TEMPR0_15_net, 
        QBX_TEMPR1_12_net, QBX_TEMPR1_13_net, QBX_TEMPR1_14_net, 
        QBX_TEMPR1_15_net, QBX_TEMPR2_12_net, QBX_TEMPR2_13_net, 
        QBX_TEMPR2_14_net, QBX_TEMPR2_15_net, QBX_TEMPR3_12_net, 
        QBX_TEMPR3_13_net, QBX_TEMPR3_14_net, QBX_TEMPR3_15_net, 
        QBX_TEMPR4_12_net, QBX_TEMPR4_13_net, QBX_TEMPR4_14_net, 
        QBX_TEMPR4_15_net, QBX_TEMPR5_12_net, QBX_TEMPR5_13_net, 
        QBX_TEMPR5_14_net, QBX_TEMPR5_15_net, QBX_TEMPR6_12_net, 
        QBX_TEMPR6_13_net, QBX_TEMPR6_14_net, QBX_TEMPR6_15_net, 
        QBX_TEMPR7_12_net, QBX_TEMPR7_13_net, QBX_TEMPR7_14_net, 
        QBX_TEMPR7_15_net, QBX_TEMPR8_12_net, QBX_TEMPR8_13_net, 
        QBX_TEMPR8_14_net, QBX_TEMPR8_15_net, QBX_TEMPR9_12_net, 
        QBX_TEMPR9_13_net, QBX_TEMPR9_14_net, QBX_TEMPR9_15_net, 
        QBX_TEMPR10_12_net, QBX_TEMPR10_13_net, 
        QBX_TEMPR10_14_net, QBX_TEMPR10_15_net, 
        QBX_TEMPR11_12_net, QBX_TEMPR11_13_net, 
        QBX_TEMPR11_14_net, QBX_TEMPR11_15_net, 
        QBX_TEMPR12_12_net, QBX_TEMPR12_13_net, 
        QBX_TEMPR12_14_net, QBX_TEMPR12_15_net, 
        QBX_TEMPR13_12_net, QBX_TEMPR13_13_net, 
        QBX_TEMPR13_14_net, QBX_TEMPR13_15_net, 
        QBX_TEMPR14_12_net, QBX_TEMPR14_13_net, 
        QBX_TEMPR14_14_net, QBX_TEMPR14_15_net, QAX_TEMPR0_12_net, 
        QAX_TEMPR0_13_net, QAX_TEMPR0_14_net, QAX_TEMPR0_15_net, 
        QAX_TEMPR1_12_net, QAX_TEMPR1_13_net, QAX_TEMPR1_14_net, 
        QAX_TEMPR1_15_net, QAX_TEMPR2_12_net, QAX_TEMPR2_13_net, 
        QAX_TEMPR2_14_net, QAX_TEMPR2_15_net, QAX_TEMPR3_12_net, 
        QAX_TEMPR3_13_net, QAX_TEMPR3_14_net, QAX_TEMPR3_15_net, 
        QAX_TEMPR4_12_net, QAX_TEMPR4_13_net, QAX_TEMPR4_14_net, 
        QAX_TEMPR4_15_net, QAX_TEMPR5_12_net, QAX_TEMPR5_13_net, 
        QAX_TEMPR5_14_net, QAX_TEMPR5_15_net, QAX_TEMPR6_12_net, 
        QAX_TEMPR6_13_net, QAX_TEMPR6_14_net, QAX_TEMPR6_15_net, 
        QAX_TEMPR7_12_net, QAX_TEMPR7_13_net, QAX_TEMPR7_14_net, 
        QAX_TEMPR7_15_net, QAX_TEMPR8_12_net, QAX_TEMPR8_13_net, 
        QAX_TEMPR8_14_net, QAX_TEMPR8_15_net, QAX_TEMPR9_12_net, 
        QAX_TEMPR9_13_net, QAX_TEMPR9_14_net, QAX_TEMPR9_15_net, 
        QAX_TEMPR10_12_net, QAX_TEMPR10_13_net, 
        QAX_TEMPR10_14_net, QAX_TEMPR10_15_net, 
        QAX_TEMPR11_12_net, QAX_TEMPR11_13_net, 
        QAX_TEMPR11_14_net, QAX_TEMPR11_15_net, 
        QAX_TEMPR12_12_net, QAX_TEMPR12_13_net, 
        QAX_TEMPR12_14_net, QAX_TEMPR12_15_net, 
        QAX_TEMPR13_12_net, QAX_TEMPR13_13_net, 
        QAX_TEMPR13_14_net, QAX_TEMPR13_15_net, 
        QAX_TEMPR14_12_net, QAX_TEMPR14_13_net, 
        QAX_TEMPR14_14_net, QAX_TEMPR14_15_net, BUFF_22_Y, 
        BUFF_26_Y, BUFF_10_Y, BUFF_35_Y, BUFF_27_Y, MX2_117_Y, 
        MX2_291_Y, MX2_82_Y, MX2_362_Y, MX2_351_Y, MX2_276_Y, 
        MX2_90_Y, MX2_327_Y, MX2_36_Y, MX2_218_Y, MX2_118_Y, 
        MX2_363_Y, MX2_22_Y, MX2_146_Y, MX2_301_Y, MX2_384_Y, 
        MX2_371_Y, MX2_170_Y, MX2_101_Y, MX2_168_Y, MX2_216_Y, 
        MX2_37_Y, MX2_86_Y, MX2_163_Y, MX2_243_Y, MX2_309_Y, 
        MX2_317_Y, MX2_322_Y, MX2_110_Y, MX2_181_Y, MX2_271_Y, 
        MX2_124_Y, MX2_231_Y, MX2_346_Y, MX2_178_Y, MX2_235_Y, 
        MX2_98_Y, MX2_383_Y, MX2_40_Y, MX2_388_Y, MX2_305_Y, 
        MX2_413_Y, MX2_365_Y, MX2_128_Y, MX2_17_Y, MX2_31_Y, 
        MX2_237_Y, MX2_228_Y, MX2_132_Y, MX2_28_Y, MX2_268_Y, 
        MX2_334_Y, BUFF_12_Y, BUFF_6_Y, BUFF_3_Y, BUFF_29_Y, 
        BUFF_25_Y, MX2_134_Y, MX2_386_Y, MX2_249_Y, MX2_342_Y, 
        MX2_254_Y, MX2_10_Y, MX2_66_Y, MX2_340_Y, MX2_355_Y, 
        MX2_171_Y, MX2_201_Y, MX2_52_Y, MX2_325_Y, MX2_114_Y, 
        MX2_250_Y, MX2_133_Y, MX2_12_Y, MX2_385_Y, MX2_255_Y, 
        MX2_344_Y, MX2_222_Y, MX2_293_Y, MX2_32_Y, MX2_353_Y, 
        MX2_329_Y, MX2_211_Y, MX2_230_Y, MX2_119_Y, MX2_273_Y, 
        MX2_298_Y, MX2_205_Y, MX2_366_Y, MX2_277_Y, MX2_368_Y, 
        MX2_292_Y, MX2_196_Y, MX2_64_Y, MX2_65_Y, MX2_349_Y, 
        MX2_27_Y, MX2_4_Y, MX2_219_Y, MX2_415_Y, MX2_373_Y, 
        MX2_315_Y, MX2_109_Y, MX2_313_Y, MX2_112_Y, MX2_137_Y, 
        MX2_144_Y, MX2_20_Y, MX2_300_Y, NOR2_2_Y, AND2A_4_Y, 
        AND2A_2_Y, AND2_2_Y, NOR2_3_Y, AND2A_5_Y, AND2A_3_Y, 
        AND2_3_Y, BUFF_34_Y, BUFF_28_Y, BUFF_39_Y, BUFF_1_Y, 
        BUFF_19_Y, MX2_100_Y, MX2_360_Y, MX2_227_Y, MX2_321_Y, 
        MX2_233_Y, MX2_406_Y, MX2_57_Y, MX2_210_Y, MX2_331_Y, 
        MX2_405_Y, MX2_176_Y, MX2_159_Y, MX2_198_Y, MX2_80_Y, 
        MX2_229_Y, MX2_95_Y, MX2_407_Y, MX2_357_Y, MX2_234_Y, 
        MX2_323_Y, MX2_69_Y, MX2_275_Y, MX2_279_Y, MX2_330_Y, 
        MX2_19_Y, MX2_56_Y, MX2_215_Y, MX2_84_Y, MX2_252_Y, 
        MX2_278_Y, MX2_194_Y, MX2_341_Y, MX2_257_Y, MX2_225_Y, 
        MX2_272_Y, MX2_14_Y, MX2_49_Y, MX2_184_Y, MX2_212_Y, 
        MX2_3_Y, MX2_401_Y, MX2_204_Y, MX2_393_Y, MX2_347_Y, 
        MX2_299_Y, MX2_76_Y, MX2_188_Y, MX2_77_Y, MX2_372_Y, 
        MX2_111_Y, MX2_116_Y, MX2_164_Y, BUFF_23_Y, BUFF_33_Y, 
        BUFF_5_Y, BUFF_36_Y, BUFF_7_Y, MX2_283_Y, MX2_145_Y, 
        MX2_411_Y, MX2_85_Y, MX2_0_Y, MX2_190_Y, MX2_236_Y, 
        MX2_232_Y, MX2_103_Y, MX2_224_Y, MX2_336_Y, MX2_200_Y, 
        MX2_157_Y, MX2_270_Y, MX2_414_Y, MX2_281_Y, MX2_191_Y, 
        MX2_141_Y, MX2_1_Y, MX2_87_Y, MX2_104_Y, MX2_43_Y, 
        MX2_89_Y, MX2_102_Y, MX2_58_Y, MX2_18_Y, MX2_395_Y, 
        MX2_274_Y, MX2_21_Y, MX2_47_Y, MX2_352_Y, MX2_121_Y, 
        MX2_23_Y, MX2_258_Y, MX2_41_Y, MX2_247_Y, MX2_226_Y, 
        MX2_213_Y, MX2_182_Y, MX2_202_Y, MX2_180_Y, MX2_376_Y, 
        MX2_173_Y, MX2_131_Y, MX2_61_Y, MX2_265_Y, MX2_208_Y, 
        MX2_267_Y, MX2_203_Y, MX2_289_Y, MX2_165_Y, MX2_115_Y, 
        BUFF_11_Y, BUFF_20_Y, BUFF_14_Y, BUFF_31_Y, BUFF_32_Y, 
        MX2_140_Y, MX2_304_Y, MX2_107_Y, MX2_379_Y, MX2_370_Y, 
        MX2_290_Y, MX2_122_Y, MX2_78_Y, MX2_53_Y, MX2_394_Y, 
        MX2_142_Y, MX2_35_Y, MX2_263_Y, MX2_162_Y, MX2_314_Y, 
        MX2_400_Y, MX2_392_Y, MX2_186_Y, MX2_129_Y, MX2_185_Y, 
        MX2_380_Y, MX2_54_Y, MX2_266_Y, MX2_177_Y, MX2_320_Y, 
        MX2_158_Y, MX2_333_Y, MX2_337_Y, MX2_138_Y, MX2_199_Y, 
        MX2_288_Y, MX2_148_Y, MX2_248_Y, MX2_106_Y, MX2_197_Y, 
        MX2_410_Y, MX2_127_Y, MX2_55_Y, MX2_282_Y, MX2_402_Y, 
        MX2_319_Y, MX2_9_Y, MX2_387_Y, MX2_150_Y, MX2_33_Y, 
        MX2_48_Y, MX2_409_Y, MX2_246_Y, MX2_295_Y, MX2_46_Y, 
        MX2_350_Y, MX2_187_Y, BUFF_24_Y, BUFF_2_Y, BUFF_16_Y, 
        BUFF_4_Y, BUFF_13_Y, MX2_256_Y, MX2_94_Y, MX2_381_Y, 
        MX2_62_Y, MX2_390_Y, MX2_160_Y, MX2_214_Y, MX2_286_Y, 
        MX2_68_Y, MX2_6_Y, MX2_311_Y, MX2_60_Y, MX2_302_Y, 
        MX2_242_Y, MX2_382_Y, MX2_253_Y, MX2_161_Y, MX2_93_Y, 
        MX2_391_Y, MX2_63_Y, MX2_175_Y, MX2_8_Y, MX2_297_Y, 
        MX2_67_Y, MX2_339_Y, MX2_192_Y, MX2_359_Y, MX2_245_Y, 
        MX2_404_Y, MX2_13_Y, MX2_324_Y, MX2_74_Y, MX2_408_Y, 
        MX2_307_Y, MX2_7_Y, MX2_34_Y, MX2_206_Y, MX2_72_Y, 
        MX2_318_Y, MX2_172_Y, MX2_152_Y, MX2_343_Y, MX2_143_Y, 
        MX2_83_Y, MX2_38_Y, MX2_238_Y, MX2_259_Y, MX2_241_Y, 
        MX2_396_Y, MX2_261_Y, MX2_30_Y, MX2_269_Y, NOR2_1_Y, 
        AND2A_1_Y, AND2A_7_Y, AND2_1_Y, NOR2_0_Y, AND2A_0_Y, 
        AND2A_6_Y, AND2_0_Y, BUFF_37_Y, BUFF_15_Y, BUFF_9_Y, 
        BUFF_8_Y, BUFF_30_Y, MX2_91_Y, MX2_280_Y, MX2_70_Y, 
        MX2_345_Y, MX2_335_Y, MX2_262_Y, MX2_75_Y, MX2_126_Y, 
        MX2_24_Y, MX2_358_Y, MX2_92_Y, MX2_209_Y, MX2_294_Y, 
        MX2_125_Y, MX2_287_Y, MX2_367_Y, MX2_356_Y, MX2_156_Y, 
        MX2_81_Y, MX2_154_Y, MX2_412_Y, MX2_25_Y, MX2_239_Y, 
        MX2_149_Y, MX2_71_Y, MX2_189_Y, MX2_306_Y, MX2_312_Y, 
        MX2_88_Y, MX2_167_Y, MX2_260_Y, MX2_97_Y, MX2_220_Y, 
        MX2_151_Y, MX2_166_Y, MX2_378_Y, MX2_79_Y, MX2_221_Y, 
        MX2_308_Y, MX2_369_Y, MX2_296_Y, MX2_399_Y, MX2_348_Y, 
        MX2_105_Y, MX2_2_Y, MX2_16_Y, MX2_26_Y, MX2_217_Y, 
        MX2_264_Y, MX2_11_Y, MX2_108_Y, MX2_207_Y, BUFF_18_Y, 
        BUFF_21_Y, BUFF_0_Y, BUFF_38_Y, BUFF_17_Y, MX2_135_Y, 
        MX2_303_Y, MX2_99_Y, MX2_374_Y, MX2_364_Y, MX2_285_Y, 
        MX2_113_Y, MX2_44_Y, MX2_50_Y, MX2_338_Y, MX2_136_Y, 
        MX2_153_Y, MX2_73_Y, MX2_155_Y, MX2_310_Y, MX2_397_Y, 
        MX2_389_Y, MX2_183_Y, MX2_123_Y, MX2_179_Y, MX2_326_Y, 
        MX2_51_Y, MX2_223_Y, MX2_174_Y, MX2_15_Y, MX2_375_Y, 
        MX2_328_Y, MX2_332_Y, MX2_130_Y, MX2_195_Y, MX2_284_Y, 
        MX2_139_Y, MX2_244_Y, MX2_59_Y, MX2_193_Y, MX2_361_Y, 
        MX2_120_Y, MX2_169_Y, MX2_96_Y, MX2_398_Y, MX2_316_Y, 
        MX2_5_Y, MX2_377_Y, MX2_147_Y, MX2_29_Y, MX2_42_Y, 
        MX2_354_Y, MX2_240_Y, MX2_251_Y, MX2_39_Y, MX2_45_Y, 
        MX2_403_Y, VCC_1_net, GND_1_net : std_logic ;
    begin   

    VCC_2_net : VCC port map(Y => VCC_1_net);
    GND_2_net : GND port map(Y => GND_1_net);
    BUFF_8 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_8_Y);
    dual_port_memory_R0C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_0_net, 
        BLKB => BLKB_EN_0_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR0_15_net, DOUTA2 => 
        QAX_TEMPR0_14_net, DOUTA1 => QAX_TEMPR0_13_net, DOUTA0 => 
        QAX_TEMPR0_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR0_15_net, DOUTB2 => QBX_TEMPR0_14_net, 
        DOUTB1 => QBX_TEMPR0_13_net, DOUTB0 => QBX_TEMPR0_12_net);
    ORB_GATE_11_inst : OR2
      port map(A => ENABLE_ADDRB_11_net, B => WEBP, Y => 
        BLKB_EN_11_net);
    MX2_113 : MX2
      port map(A => QAX_TEMPR6_3_net, B => QAX_TEMPR7_3_net, S => 
        BUFF_0_Y, Y => MX2_113_Y);
    MX2_279 : MX2
      port map(A => QBX_TEMPR10_10_net, B => QBX_TEMPR11_10_net, 
        S => BUFF_39_Y, Y => MX2_279_Y);
    ORB_GATE_4_inst : OR2
      port map(A => ENABLE_ADDRB_4_net, B => WEBP, Y => 
        BLKB_EN_4_net);
    dual_port_memory_R9C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_9_net, 
        BLKB => BLKB_EN_9_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR9_3_net, DOUTA2 => 
        QAX_TEMPR9_2_net, DOUTA1 => QAX_TEMPR9_1_net, DOUTA0 => 
        QAX_TEMPR9_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR9_3_net, DOUTB2 => QBX_TEMPR9_2_net, 
        DOUTB1 => QBX_TEMPR9_1_net, DOUTB0 => QBX_TEMPR9_0_net);
    MX2_319 : MX2
      port map(A => QAX_TEMPR2_9_net, B => QAX_TEMPR3_9_net, S => 
        BUFF_11_Y, Y => MX2_319_Y);
    MX2_226 : MX2
      port map(A => MX2_41_Y, B => MX2_247_Y, S => BUFF_36_Y, 
        Y => MX2_226_Y);
    MX2_304 : MX2
      port map(A => QAX_TEMPR2_11_net, B => QAX_TEMPR3_11_net, 
        S => BUFF_14_Y, Y => MX2_304_Y);
    MX2_382 : MX2
      port map(A => QBX_TEMPR2_14_net, B => QBX_TEMPR3_14_net, 
        S => BUFF_2_Y, Y => MX2_382_Y);
    MX2_183 : MX2
      port map(A => MX2_397_Y, B => MX2_389_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_183_Y);
    dual_port_memory_R13C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_13_net, 
        BLKB => BLKB_EN_13_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR13_15_net, DOUTA2 => 
        QAX_TEMPR13_14_net, DOUTA1 => QAX_TEMPR13_13_net, 
        DOUTA0 => QAX_TEMPR13_12_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR13_15_net, DOUTB2 => 
        QBX_TEMPR13_14_net, DOUTB1 => QBX_TEMPR13_13_net, 
        DOUTB0 => QBX_TEMPR13_12_net);
    dual_port_memory_R6C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_6_net, 
        BLKB => BLKB_EN_6_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR6_15_net, DOUTA2 => 
        QAX_TEMPR6_14_net, DOUTA1 => QAX_TEMPR6_13_net, DOUTA0 => 
        QAX_TEMPR6_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR6_15_net, DOUTB2 => QBX_TEMPR6_14_net, 
        DOUTB1 => QBX_TEMPR6_13_net, DOUTB0 => QBX_TEMPR6_12_net);
    MX2_389 : MX2
      port map(A => MX2_123_Y, B => MX2_179_Y, S => BUFF_17_Y, 
        Y => MX2_389_Y);
    MX2_405 : MX2
      port map(A => QBX_TEMPR10_11_net, B => QBX_TEMPR11_11_net, 
        S => BUFF_39_Y, Y => MX2_405_Y);
    MX2_377 : MX2
      port map(A => MX2_29_Y, B => MX2_42_Y, S => BUFF_38_Y, Y => 
        MX2_377_Y);
    BUFF_7 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_7_Y);
    MX2_273 : MX2
      port map(A => MX2_230_Y, B => MX2_119_Y, S => BUFF_29_Y, 
        Y => MX2_273_Y);
    NAND2_ENABLE_ADDRA_7_inst : NAND2
      port map(A => AND2_2_Y, B => AND2A_5_Y, Y => 
        ENABLE_ADDRA_7_net);
    MX2_408 : MX2
      port map(A => QBX_TEMPR6_12_net, B => QBX_TEMPR7_12_net, 
        S => BUFF_24_Y, Y => MX2_408_Y);
    MX2_124 : MX2
      port map(A => QAX_TEMPR4_4_net, B => QAX_TEMPR5_4_net, S => 
        BUFF_22_Y, Y => MX2_124_Y);
    MX2_89 : MX2
      port map(A => QBX_TEMPR10_2_net, B => QBX_TEMPR11_2_net, 
        S => BUFF_5_Y, Y => MX2_89_Y);
    MX2_37 : MX2
      port map(A => QAX_TEMPR8_6_net, B => QAX_TEMPR9_6_net, S => 
        BUFF_26_Y, Y => MX2_37_Y);
    MX2_54 : MX2
      port map(A => QAX_TEMPR8_10_net, B => QAX_TEMPR9_10_net, 
        S => BUFF_20_Y, Y => MX2_54_Y);
    MX2_328 : MX2
      port map(A => QAX_TEMPR0_0_net, B => QAX_TEMPR1_0_net, S => 
        BUFF_18_Y, Y => MX2_328_Y);
    MX2_75 : MX2
      port map(A => QAX_TEMPR6_15_net, B => QAX_TEMPR7_15_net, 
        S => BUFF_9_Y, Y => MX2_75_Y);
    dual_port_memory_R3C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_3_net, 
        BLKB => BLKB_EN_3_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR3_7_net, DOUTA2 => 
        QAX_TEMPR3_6_net, DOUTA1 => QAX_TEMPR3_5_net, DOUTA0 => 
        QAX_TEMPR3_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR3_7_net, DOUTB2 => QBX_TEMPR3_6_net, 
        DOUTB1 => QBX_TEMPR3_5_net, DOUTB0 => QBX_TEMPR3_4_net);
    MX2_23 : MX2
      port map(A => QBX_TEMPR6_0_net, B => QBX_TEMPR7_0_net, S => 
        BUFF_23_Y, Y => MX2_23_Y);
    MX2_112 : MX2
      port map(A => QBX_TEMPR8_5_net, B => QBX_TEMPR9_5_net, S => 
        BUFF_6_Y, Y => MX2_112_Y);
    MX2_323 : MX2
      port map(A => QBX_TEMPR6_10_net, B => QBX_TEMPR7_10_net, 
        S => BUFF_28_Y, Y => MX2_323_Y);
    MX2_296 : MX2
      port map(A => QAX_TEMPR2_13_net, B => QAX_TEMPR3_13_net, 
        S => BUFF_37_Y, Y => MX2_296_Y);
    MX2_94 : MX2
      port map(A => QBX_TEMPR2_15_net, B => QBX_TEMPR3_15_net, 
        S => BUFF_16_Y, Y => MX2_94_Y);
    MX2_65 : MX2
      port map(A => MX2_349_Y, B => QBX_TEMPR14_4_net, S => 
        BUFF_29_Y, Y => MX2_65_Y);
    AFF1_0_inst : DFN1
      port map(D => ADDRA(10), CLK => CLKA, Q => ADDRA_FF2_0_net);
    MX2_1 : MX2
      port map(A => QBX_TEMPR4_2_net, B => QBX_TEMPR5_2_net, S => 
        BUFF_33_Y, Y => MX2_1_Y);
    MX2_364 : MX2
      port map(A => MX2_99_Y, B => MX2_374_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_364_Y);
    MX2_182 : MX2
      port map(A => QBX_TEMPR12_0_net, B => QBX_TEMPR13_0_net, 
        S => BUFF_23_Y, Y => MX2_182_Y);
    MX2_414 : MX2
      port map(A => QBX_TEMPR2_2_net, B => QBX_TEMPR3_2_net, S => 
        BUFF_33_Y, Y => MX2_414_Y);
    MX2_278 : MX2
      port map(A => MX2_341_Y, B => MX2_257_Y, S => BUFF_1_Y, 
        Y => MX2_278_Y);
    MX2_251 : MX2
      port map(A => QAX_TEMPR10_1_net, B => QAX_TEMPR11_1_net, 
        S => BUFF_21_Y, Y => MX2_251_Y);
    MX2_257 : MX2
      port map(A => QBX_TEMPR6_8_net, B => QBX_TEMPR7_8_net, S => 
        BUFF_34_Y, Y => MX2_257_Y);
    BUFF_12 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_12_Y);
    MX2_176 : MX2
      port map(A => MX2_331_Y, B => MX2_405_Y, S => BUFF_19_Y, 
        Y => MX2_176_Y);
    dual_port_memory_R7C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_7_net, 
        BLKB => BLKB_EN_7_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR7_11_net, DOUTA2 => 
        QAX_TEMPR7_10_net, DOUTA1 => QAX_TEMPR7_9_net, DOUTA0 => 
        QAX_TEMPR7_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR7_11_net, DOUTB2 => QBX_TEMPR7_10_net, 
        DOUTB1 => QBX_TEMPR7_9_net, DOUTB0 => QBX_TEMPR7_8_net);
    ORA_GATE_12_inst : OR2
      port map(A => ENABLE_ADDRA_12_net, B => WEAP, Y => 
        BLKA_EN_12_net);
    MX2_220 : MX2
      port map(A => QAX_TEMPR6_12_net, B => QAX_TEMPR7_12_net, 
        S => BUFF_37_Y, Y => MX2_220_Y);
    MX2_175 : MX2
      port map(A => MX2_67_Y, B => MX2_339_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_175_Y);
    MX2_121 : MX2
      port map(A => QBX_TEMPR4_0_net, B => QBX_TEMPR5_0_net, S => 
        BUFF_23_Y, Y => MX2_121_Y);
    BUFF_33 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_33_Y);
    BUFF_31 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_31_Y);
    MX2_239 : MX2
      port map(A => QAX_TEMPR10_14_net, B => QAX_TEMPR11_14_net, 
        S => BUFF_9_Y, Y => MX2_239_Y);
    MX2_DOUTB_10_inst : MX2
      port map(A => MX2_357_Y, B => MX2_69_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(10));
    MX2_370 : MX2
      port map(A => MX2_107_Y, B => MX2_379_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_370_Y);
    MX2_100 : MX2
      port map(A => QBX_TEMPR0_11_net, B => QBX_TEMPR1_11_net, 
        S => BUFF_39_Y, Y => MX2_100_Y);
    MX2_DOUTB_4_inst : MX2
      port map(A => MX2_205_Y, B => MX2_368_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(4));
    MX2_194 : MX2
      port map(A => MX2_252_Y, B => MX2_278_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_194_Y);
    RESETBUBBLE : INV
      port map(A => RESET, Y => RESETP);
    BUFF_22 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_22_Y);
    ORB_GATE_6_inst : OR2
      port map(A => ENABLE_ADDRB_6_net, B => WEBP, Y => 
        BLKB_EN_6_net);
    MX2_398 : MX2
      port map(A => QAX_TEMPR0_1_net, B => QAX_TEMPR1_1_net, S => 
        BUFF_18_Y, Y => MX2_398_Y);
    MX2_225 : MX2
      port map(A => MX2_49_Y, B => MX2_184_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_225_Y);
    MX2_393 : MX2
      port map(A => MX2_299_Y, B => MX2_76_Y, S => BUFF_1_Y, Y => 
        MX2_393_Y);
    MX2_147 : MX2
      port map(A => MX2_5_Y, B => MX2_377_Y, S => ADDRA_FF2_2_net, 
        Y => MX2_147_Y);
    MX2_321 : MX2
      port map(A => MX2_406_Y, B => MX2_57_Y, S => BUFF_19_Y, 
        Y => MX2_321_Y);
    MX2_0 : MX2
      port map(A => MX2_411_Y, B => MX2_85_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_0_Y);
    MX2_DOUTB_3_inst : MX2
      port map(A => MX2_0_Y, B => MX2_232_Y, S => ADDRB_FF2_3_net, 
        Y => DOUTB(3));
    BUFF_4 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_4_Y);
    MX2_337 : MX2
      port map(A => QAX_TEMPR2_8_net, B => QAX_TEMPR3_8_net, S => 
        BUFF_11_Y, Y => MX2_337_Y);
    MX2_233 : MX2
      port map(A => MX2_227_Y, B => MX2_321_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_233_Y);
    MX2_21 : MX2
      port map(A => MX2_395_Y, B => MX2_274_Y, S => BUFF_36_Y, 
        Y => MX2_21_Y);
    MX2_14 : MX2
      port map(A => QBX_TEMPR10_8_net, B => QBX_TEMPR11_8_net, 
        S => BUFF_34_Y, Y => MX2_14_Y);
    MX2_33 : MX2
      port map(A => QAX_TEMPR4_9_net, B => QAX_TEMPR5_9_net, S => 
        BUFF_11_Y, Y => MX2_33_Y);
    MX2_290 : MX2
      port map(A => QAX_TEMPR4_11_net, B => QAX_TEMPR5_11_net, 
        S => BUFF_14_Y, Y => MX2_290_Y);
    MX2_129 : MX2
      port map(A => QAX_TEMPR4_10_net, B => QAX_TEMPR5_10_net, 
        S => BUFF_20_Y, Y => MX2_129_Y);
    MX2_28 : MX2
      port map(A => MX2_228_Y, B => MX2_132_Y, S => BUFF_35_Y, 
        Y => MX2_28_Y);
    MX2_191 : MX2
      port map(A => MX2_1_Y, B => MX2_87_Y, S => BUFF_7_Y, Y => 
        MX2_191_Y);
    dual_port_memory_R9C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_9_net, 
        BLKB => BLKB_EN_9_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR9_11_net, DOUTA2 => 
        QAX_TEMPR9_10_net, DOUTA1 => QAX_TEMPR9_9_net, DOUTA0 => 
        QAX_TEMPR9_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR9_11_net, DOUTB2 => QBX_TEMPR9_10_net, 
        DOUTB1 => QBX_TEMPR9_9_net, DOUTB0 => QBX_TEMPR9_8_net);
    MX2_DOUTA_2_inst : MX2
      port map(A => MX2_183_Y, B => MX2_326_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(2));
    MX2_160 : MX2
      port map(A => QBX_TEMPR4_15_net, B => QBX_TEMPR5_15_net, 
        S => BUFF_16_Y, Y => MX2_160_Y);
    MX2_325 : MX2
      port map(A => QBX_TEMPR12_7_net, B => QBX_TEMPR13_7_net, 
        S => BUFF_3_Y, Y => MX2_325_Y);
    MX2_DOUTB_9_inst : MX2
      port map(A => MX2_347_Y, B => MX2_188_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(9));
    NAND2_ENABLE_ADDRA_8_inst : NAND2
      port map(A => NOR2_2_Y, B => AND2A_3_Y, Y => 
        ENABLE_ADDRA_8_net);
    MX2_238 : MX2
      port map(A => QBX_TEMPR6_13_net, B => QBX_TEMPR7_13_net, 
        S => BUFF_2_Y, Y => MX2_238_Y);
    MX2_295 : MX2
      port map(A => QAX_TEMPR10_9_net, B => QAX_TEMPR11_9_net, 
        S => BUFF_20_Y, Y => MX2_295_Y);
    MX2_391 : MX2
      port map(A => QBX_TEMPR4_14_net, B => QBX_TEMPR5_14_net, 
        S => BUFF_2_Y, Y => MX2_391_Y);
    MX2_50 : MX2
      port map(A => QAX_TEMPR8_3_net, B => QAX_TEMPR9_3_net, S => 
        BUFF_0_Y, Y => MX2_50_Y);
    MX2_7 : MX2
      port map(A => QBX_TEMPR8_12_net, B => QBX_TEMPR9_12_net, 
        S => BUFF_24_Y, Y => MX2_7_Y);
    MX2_219 : MX2
      port map(A => MX2_27_Y, B => MX2_4_Y, S => BUFF_29_Y, Y => 
        MX2_219_Y);
    MX2_374 : MX2
      port map(A => MX2_285_Y, B => MX2_113_Y, S => BUFF_17_Y, 
        Y => MX2_374_Y);
    AND2A_7 : AND2A
      port map(A => ADDRB(10), B => ADDRB(11), Y => AND2A_7_Y);
    MX2_403 : MX2
      port map(A => QAX_TEMPR12_1_net, B => QAX_TEMPR13_1_net, 
        S => BUFF_21_Y, Y => MX2_403_Y);
    MX2_136 : MX2
      port map(A => MX2_50_Y, B => MX2_338_Y, S => BUFF_17_Y, 
        Y => MX2_136_Y);
    BUFF_16 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_16_Y);
    NOR2_2 : NOR2
      port map(A => ADDRA(11), B => ADDRA(10), Y => NOR2_2_Y);
    MX2_90 : MX2
      port map(A => QAX_TEMPR6_7_net, B => QAX_TEMPR7_7_net, S => 
        BUFF_10_Y, Y => MX2_90_Y);
    MX2_135 : MX2
      port map(A => QAX_TEMPR0_3_net, B => QAX_TEMPR1_3_net, S => 
        BUFF_0_Y, Y => MX2_135_Y);
    MX2_6 : MX2
      port map(A => QBX_TEMPR10_15_net, B => QBX_TEMPR11_15_net, 
        S => BUFF_16_Y, Y => MX2_6_Y);
    NOR2_3 : NOR2
      port map(A => ADDRA(13), B => ADDRA(12), Y => NOR2_3_Y);
    MX2_289 : MX2
      port map(A => MX2_267_Y, B => MX2_203_Y, S => BUFF_36_Y, 
        Y => MX2_289_Y);
    NAND2_ENABLE_ADDRA_2_inst : NAND2
      port map(A => AND2A_2_Y, B => NOR2_3_Y, Y => 
        ENABLE_ADDRA_2_net);
    MX2_DOUTA_3_inst : MX2
      port map(A => MX2_364_Y, B => MX2_44_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(3));
    dual_port_memory_R11C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_11_net, 
        BLKB => BLKB_EN_11_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR11_11_net, DOUTA2 => 
        QAX_TEMPR11_10_net, DOUTA1 => QAX_TEMPR11_9_net, 
        DOUTA0 => QAX_TEMPR11_8_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR11_11_net, DOUTB2 => 
        QBX_TEMPR11_10_net, DOUTB1 => QBX_TEMPR11_9_net, 
        DOUTB0 => QBX_TEMPR11_8_net);
    MX2_330 : MX2
      port map(A => MX2_275_Y, B => MX2_279_Y, S => BUFF_19_Y, 
        Y => MX2_330_Y);
    BUFF_26 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_26_Y);
    MX2_199 : MX2
      port map(A => MX2_148_Y, B => MX2_248_Y, S => BUFF_31_Y, 
        Y => MX2_199_Y);
    MX2_401 : MX2
      port map(A => QBX_TEMPR2_9_net, B => QBX_TEMPR3_9_net, S => 
        BUFF_34_Y, Y => MX2_401_Y);
    MX2_317 : MX2
      port map(A => QAX_TEMPR0_4_net, B => QAX_TEMPR1_4_net, S => 
        BUFF_22_Y, Y => MX2_317_Y);
    NAND2_ENABLE_ADDRB_14_inst : NAND2
      port map(A => AND2A_7_Y, B => AND2_0_Y, Y => 
        ENABLE_ADDRB_14_net);
    MX2_222 : MX2
      port map(A => MX2_353_Y, B => MX2_329_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_222_Y);
    MX2_213 : MX2
      port map(A => MX2_182_Y, B => QBX_TEMPR14_0_net, S => 
        BUFF_36_Y, Y => MX2_213_Y);
    MX2_42 : MX2
      port map(A => QAX_TEMPR6_1_net, B => QAX_TEMPR7_1_net, S => 
        BUFF_21_Y, Y => MX2_42_Y);
    NAND2_ENABLE_ADDRB_6_inst : NAND2
      port map(A => AND2A_7_Y, B => AND2A_0_Y, Y => 
        ENABLE_ADDRB_6_net);
    MX2_128 : MX2
      port map(A => MX2_413_Y, B => MX2_365_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_128_Y);
    dual_port_memory_R3C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_3_net, 
        BLKB => BLKB_EN_3_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR3_11_net, DOUTA2 => 
        QAX_TEMPR3_10_net, DOUTA1 => QAX_TEMPR3_9_net, DOUTA0 => 
        QAX_TEMPR3_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR3_11_net, DOUTB2 => QBX_TEMPR3_10_net, 
        DOUTB1 => QBX_TEMPR3_9_net, DOUTB0 => QBX_TEMPR3_8_net);
    MX2_387 : MX2
      port map(A => MX2_33_Y, B => MX2_48_Y, S => BUFF_31_Y, Y => 
        MX2_387_Y);
    BUFF_37 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_37_Y);
    MX2_31 : MX2
      port map(A => QAX_TEMPR6_5_net, B => QAX_TEMPR7_5_net, S => 
        BUFF_26_Y, Y => MX2_31_Y);
    MX2_395 : MX2
      port map(A => QBX_TEMPR0_0_net, B => QBX_TEMPR1_0_net, S => 
        BUFF_23_Y, Y => MX2_395_Y);
    MX2_283 : MX2
      port map(A => QBX_TEMPR0_3_net, B => QBX_TEMPR1_3_net, S => 
        BUFF_5_Y, Y => MX2_283_Y);
    MX2_85 : MX2
      port map(A => MX2_190_Y, B => MX2_236_Y, S => BUFF_7_Y, 
        Y => MX2_85_Y);
    MX2_DOUTA_14_inst : MX2
      port map(A => MX2_156_Y, B => MX2_412_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(14));
    MX2_56 : MX2
      port map(A => QBX_TEMPR12_10_net, B => QBX_TEMPR13_10_net, 
        S => BUFF_39_Y, Y => MX2_56_Y);
    MX2_DOUTB_15_inst : MX2
      port map(A => MX2_390_Y, B => MX2_286_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(15));
    MX2_38 : MX2
      port map(A => QBX_TEMPR4_13_net, B => QBX_TEMPR5_13_net, 
        S => BUFF_24_Y, Y => MX2_38_Y);
    MX2_107 : MX2
      port map(A => MX2_140_Y, B => MX2_304_Y, S => BUFF_32_Y, 
        Y => MX2_107_Y);
    ORA_GATE_9_inst : OR2
      port map(A => ENABLE_ADDRA_9_net, B => WEAP, Y => 
        BLKA_EN_9_net);
    MX2_256 : MX2
      port map(A => QBX_TEMPR0_15_net, B => QBX_TEMPR1_15_net, 
        S => BUFF_16_Y, Y => MX2_256_Y);
    MX2_96 : MX2
      port map(A => QAX_TEMPR12_0_net, B => QAX_TEMPR13_0_net, 
        S => BUFF_18_Y, Y => MX2_96_Y);
    MX2_218 : MX2
      port map(A => QAX_TEMPR10_7_net, B => QAX_TEMPR11_7_net, 
        S => BUFF_10_Y, Y => MX2_218_Y);
    NAND2_ENABLE_ADDRB_4_inst : NAND2
      port map(A => NOR2_1_Y, B => AND2A_0_Y, Y => 
        ENABLE_ADDRB_4_net);
    MX2_74 : MX2
      port map(A => QBX_TEMPR4_12_net, B => QBX_TEMPR5_12_net, 
        S => BUFF_24_Y, Y => MX2_74_Y);
    AND2_0 : AND2
      port map(A => ADDRB(13), B => ADDRB(12), Y => AND2_0_Y);
    dual_port_memory_R2C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_2_net, 
        BLKB => BLKB_EN_2_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR2_7_net, DOUTA2 => 
        QAX_TEMPR2_6_net, DOUTA1 => QAX_TEMPR2_5_net, DOUTA0 => 
        QAX_TEMPR2_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR2_7_net, DOUTB2 => QBX_TEMPR2_6_net, 
        DOUTB1 => QBX_TEMPR2_5_net, DOUTB0 => QBX_TEMPR2_4_net);
    MX2_116 : MX2
      port map(A => MX2_164_Y, B => QBX_TEMPR14_9_net, S => 
        BUFF_1_Y, Y => MX2_116_Y);
    MX2_64 : MX2
      port map(A => MX2_292_Y, B => MX2_196_Y, S => BUFF_29_Y, 
        Y => MX2_64_Y);
    MX2_288 : MX2
      port map(A => MX2_138_Y, B => MX2_199_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_288_Y);
    MX2_10 : MX2
      port map(A => QBX_TEMPR4_7_net, B => QBX_TEMPR5_7_net, S => 
        BUFF_3_Y, Y => MX2_10_Y);
    MX2_115 : MX2
      port map(A => QBX_TEMPR12_1_net, B => QBX_TEMPR13_1_net, 
        S => BUFF_33_Y, Y => MX2_115_Y);
    MX2_170 : MX2
      port map(A => MX2_384_Y, B => MX2_371_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_170_Y);
    MX2_292 : MX2
      port map(A => QBX_TEMPR8_4_net, B => QBX_TEMPR9_4_net, S => 
        BUFF_12_Y, Y => MX2_292_Y);
    MX2_224 : MX2
      port map(A => QBX_TEMPR10_3_net, B => QBX_TEMPR11_3_net, 
        S => BUFF_5_Y, Y => MX2_224_Y);
    MX2_49 : MX2
      port map(A => MX2_272_Y, B => MX2_14_Y, S => BUFF_1_Y, Y => 
        MX2_49_Y);
    MX2_241 : MX2
      port map(A => QBX_TEMPR8_13_net, B => QBX_TEMPR9_13_net, 
        S => BUFF_2_Y, Y => MX2_241_Y);
    MX2_247 : MX2
      port map(A => QBX_TEMPR10_0_net, B => QBX_TEMPR11_0_net, 
        S => BUFF_23_Y, Y => MX2_247_Y);
    NAND2_ENABLE_ADDRA_3_inst : NAND2
      port map(A => AND2_2_Y, B => NOR2_3_Y, Y => 
        ENABLE_ADDRA_3_net);
    MX2_334 : MX2
      port map(A => QAX_TEMPR12_5_net, B => QAX_TEMPR13_5_net, 
        S => BUFF_26_Y, Y => MX2_334_Y);
    MX2_186 : MX2
      port map(A => MX2_400_Y, B => MX2_392_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_186_Y);
    MX2_310 : MX2
      port map(A => QAX_TEMPR2_2_net, B => QAX_TEMPR3_2_net, S => 
        BUFF_21_Y, Y => MX2_310_Y);
    MX2_198 : MX2
      port map(A => QBX_TEMPR12_11_net, B => QBX_TEMPR13_11_net, 
        S => BUFF_39_Y, Y => MX2_198_Y);
    MX2_185 : MX2
      port map(A => QAX_TEMPR6_10_net, B => QAX_TEMPR7_10_net, 
        S => BUFF_20_Y, Y => MX2_185_Y);
    MX2_407 : MX2
      port map(A => MX2_234_Y, B => MX2_323_Y, S => BUFF_19_Y, 
        Y => MX2_407_Y);
    MX2_154 : MX2
      port map(A => QAX_TEMPR6_14_net, B => QAX_TEMPR7_14_net, 
        S => BUFF_15_Y, Y => MX2_154_Y);
    NAND2_ENABLE_ADDRA_14_inst : NAND2
      port map(A => AND2A_2_Y, B => AND2_3_Y, Y => 
        ENABLE_ADDRA_14_net);
    NAND2_ENABLE_ADDRB_1_inst : NAND2
      port map(A => AND2A_1_Y, B => NOR2_0_Y, Y => 
        ENABLE_ADDRB_1_net);
    MX2_DOUTA_5_inst : MX2
      port map(A => MX2_128_Y, B => MX2_237_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(5));
    NAND2_ENABLE_ADDRA_1_inst : NAND2
      port map(A => AND2A_4_Y, B => NOR2_3_Y, Y => 
        ENABLE_ADDRA_1_net);
    MX2_380 : MX2
      port map(A => MX2_177_Y, B => MX2_320_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_380_Y);
    MX2_358 : MX2
      port map(A => QAX_TEMPR10_15_net, B => QAX_TEMPR11_15_net, 
        S => BUFF_9_Y, Y => MX2_358_Y);
    NAND2_ENABLE_ADDRA_9_inst : NAND2
      port map(A => AND2A_4_Y, B => AND2A_3_Y, Y => 
        ENABLE_ADDRA_9_net);
    MX2_353 : MX2
      port map(A => MX2_293_Y, B => MX2_32_Y, S => BUFF_25_Y, 
        Y => MX2_353_Y);
    MX2_167 : MX2
      port map(A => MX2_97_Y, B => MX2_220_Y, S => BUFF_8_Y, Y => 
        MX2_167_Y);
    BUFF_6 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_6_Y);
    MX2_DOUTB_6_inst : MX2
      port map(A => MX2_385_Y, B => MX2_222_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(6));
    MX2_DOUTA_1_inst : MX2
      port map(A => MX2_147_Y, B => MX2_354_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(1));
    MX2_406 : MX2
      port map(A => QBX_TEMPR4_11_net, B => QBX_TEMPR5_11_net, 
        S => BUFF_39_Y, Y => MX2_406_Y);
    ORB_GATE_5_inst : OR2
      port map(A => ENABLE_ADDRB_5_net, B => WEBP, Y => 
        BLKB_EN_5_net);
    MX2_16 : MX2
      port map(A => QAX_TEMPR6_13_net, B => QAX_TEMPR7_13_net, 
        S => BUFF_15_Y, Y => MX2_16_Y);
    MX2_294 : MX2
      port map(A => QAX_TEMPR12_15_net, B => QAX_TEMPR13_15_net, 
        S => BUFF_9_Y, Y => MX2_294_Y);
    MX2_250 : MX2
      port map(A => QBX_TEMPR2_6_net, B => QBX_TEMPR3_6_net, S => 
        BUFF_6_Y, Y => MX2_250_Y);
    BUFF_39 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_39_Y);
    MX2_151 : MX2
      port map(A => MX2_79_Y, B => MX2_221_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_151_Y);
    MX2_326 : MX2
      port map(A => MX2_174_Y, B => MX2_15_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_326_Y);
    ORA_GATE_1_inst : OR2
      port map(A => ENABLE_ADDRA_1_net, B => WEAP, Y => 
        BLKA_EN_1_net);
    MX2_57 : MX2
      port map(A => QBX_TEMPR6_11_net, B => QBX_TEMPR7_11_net, 
        S => BUFF_39_Y, Y => MX2_57_Y);
    dual_port_memory_R8C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_8_net, 
        BLKB => BLKB_EN_8_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR8_3_net, DOUTA2 => 
        QAX_TEMPR8_2_net, DOUTA1 => QAX_TEMPR8_1_net, DOUTA0 => 
        QAX_TEMPR8_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR8_3_net, DOUTB2 => QBX_TEMPR8_2_net, 
        DOUTB1 => QBX_TEMPR8_1_net, DOUTB0 => QBX_TEMPR8_0_net);
    dual_port_memory_R8C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_8_net, 
        BLKB => BLKB_EN_8_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR8_11_net, DOUTA2 => 
        QAX_TEMPR8_10_net, DOUTA1 => QAX_TEMPR8_9_net, DOUTA0 => 
        QAX_TEMPR8_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR8_11_net, DOUTB2 => QBX_TEMPR8_10_net, 
        DOUTB1 => QBX_TEMPR8_9_net, DOUTB0 => QBX_TEMPR8_8_net);
    MX2_DOUTB_0_inst : MX2
      port map(A => MX2_352_Y, B => MX2_258_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(0));
    MX2_8 : MX2
      port map(A => QBX_TEMPR8_14_net, B => QBX_TEMPR9_14_net, 
        S => BUFF_2_Y, Y => MX2_8_Y);
    MX2_314 : MX2
      port map(A => QAX_TEMPR2_10_net, B => QAX_TEMPR3_10_net, 
        S => BUFF_20_Y, Y => MX2_314_Y);
    MX2_255 : MX2
      port map(A => QBX_TEMPR4_6_net, B => QBX_TEMPR5_6_net, S => 
        BUFF_6_Y, Y => MX2_255_Y);
    dual_port_memory_R0C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_0_net, 
        BLKB => BLKB_EN_0_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR0_11_net, DOUTA2 => 
        QAX_TEMPR0_10_net, DOUTA1 => QAX_TEMPR0_9_net, DOUTA0 => 
        QAX_TEMPR0_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR0_11_net, DOUTB2 => QBX_TEMPR0_10_net, 
        DOUTB1 => QBX_TEMPR0_9_net, DOUTB0 => QBX_TEMPR0_8_net);
    MX2_351 : MX2
      port map(A => MX2_82_Y, B => MX2_362_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_351_Y);
    MX2_97 : MX2
      port map(A => QAX_TEMPR4_12_net, B => QAX_TEMPR5_12_net, 
        S => BUFF_37_Y, Y => MX2_97_Y);
    BUFF_13 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_13_Y);
    BUFF_11 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_11_Y);
    dual_port_memory_R5C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_5_net, 
        BLKB => BLKB_EN_5_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR5_7_net, DOUTA2 => 
        QAX_TEMPR5_6_net, DOUTA1 => QAX_TEMPR5_5_net, DOUTA0 => 
        QAX_TEMPR5_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR5_7_net, DOUTB2 => QBX_TEMPR5_6_net, 
        DOUTB1 => QBX_TEMPR5_5_net, DOUTB0 => QBX_TEMPR5_4_net);
    ORA_GATE_0_inst : OR2
      port map(A => ENABLE_ADDRA_0_net, B => WEAP, Y => 
        BLKA_EN_0_net);
    ORB_GATE_2_inst : OR2
      port map(A => ENABLE_ADDRB_2_net, B => WEBP, Y => 
        BLKB_EN_2_net);
    AND2A_2 : AND2A
      port map(A => ADDRA(10), B => ADDRA(11), Y => AND2A_2_Y);
    MX2_130 : MX2
      port map(A => MX2_328_Y, B => MX2_332_Y, S => BUFF_38_Y, 
        Y => MX2_130_Y);
    dual_port_memory_R11C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_11_net, 
        BLKB => BLKB_EN_11_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR11_3_net, DOUTA2 => 
        QAX_TEMPR11_2_net, DOUTA1 => QAX_TEMPR11_1_net, DOUTA0 => 
        QAX_TEMPR11_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR11_3_net, DOUTB2 => QBX_TEMPR11_2_net, 
        DOUTB1 => QBX_TEMPR11_1_net, DOUTB0 => QBX_TEMPR11_0_net);
    MX2_384 : MX2
      port map(A => MX2_146_Y, B => MX2_301_Y, S => BUFF_27_Y, 
        Y => MX2_384_Y);
    MX2_322 : MX2
      port map(A => QAX_TEMPR2_4_net, B => QAX_TEMPR3_4_net, S => 
        BUFF_22_Y, Y => MX2_322_Y);
    MX2_123 : MX2
      port map(A => QAX_TEMPR4_2_net, B => QAX_TEMPR5_2_net, S => 
        BUFF_21_Y, Y => MX2_123_Y);
    dual_port_memory_R8C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_8_net, 
        BLKB => BLKB_EN_8_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR8_7_net, DOUTA2 => 
        QAX_TEMPR8_6_net, DOUTA1 => QAX_TEMPR8_5_net, DOUTA0 => 
        QAX_TEMPR8_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR8_7_net, DOUTB2 => QBX_TEMPR8_6_net, 
        DOUTB1 => QBX_TEMPR8_5_net, DOUTB0 => QBX_TEMPR8_4_net);
    AND2A_1 : AND2A
      port map(A => ADDRB(11), B => ADDRB(10), Y => AND2A_1_Y);
    MX2_415 : MX2
      port map(A => MX2_315_Y, B => MX2_109_Y, S => BUFF_29_Y, 
        Y => MX2_415_Y);
    MX2_70 : MX2
      port map(A => MX2_91_Y, B => MX2_280_Y, S => BUFF_30_Y, 
        Y => MX2_70_Y);
    ORB_GATE_14_inst : OR2
      port map(A => ENABLE_ADDRB_14_net, B => WEBP, Y => 
        BLKB_EN_14_net);
    MX2_329 : MX2
      port map(A => MX2_211_Y, B => QBX_TEMPR14_6_net, S => 
        BUFF_25_Y, Y => MX2_329_Y);
    BUFF_23 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_23_Y);
    BUFF_21 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_21_Y);
    BFF1_3_inst : DFN1
      port map(D => ADDRB(13), CLK => CLKB, Q => ADDRB_FF2_3_net);
    MX2_60 : MX2
      port map(A => MX2_302_Y, B => QBX_TEMPR14_15_net, S => 
        BUFF_13_Y, Y => MX2_60_Y);
    MX2_159 : MX2
      port map(A => MX2_198_Y, B => QBX_TEMPR14_11_net, S => 
        BUFF_19_Y, Y => MX2_159_Y);
    MX2_396 : MX2
      port map(A => QBX_TEMPR10_13_net, B => QBX_TEMPR11_13_net, 
        S => BUFF_2_Y, Y => MX2_396_Y);
    MX2_201 : MX2
      port map(A => MX2_355_Y, B => MX2_171_Y, S => BUFF_25_Y, 
        Y => MX2_201_Y);
    MX2_207 : MX2
      port map(A => QAX_TEMPR12_13_net, B => QAX_TEMPR13_13_net, 
        S => BUFF_15_Y, Y => MX2_207_Y);
    ORA_GATE_4_inst : OR2
      port map(A => ENABLE_ADDRA_4_net, B => WEAP, Y => 
        BLKA_EN_4_net);
    MX2_355 : MX2
      port map(A => QBX_TEMPR8_7_net, B => QBX_TEMPR9_7_net, S => 
        BUFF_3_Y, Y => MX2_355_Y);
    MX2_177 : MX2
      port map(A => MX2_54_Y, B => MX2_266_Y, S => BUFF_32_Y, 
        Y => MX2_177_Y);
    NAND2_ENABLE_ADDRB_2_inst : NAND2
      port map(A => AND2A_7_Y, B => NOR2_0_Y, Y => 
        ENABLE_ADDRB_2_net);
    MX2_84 : MX2
      port map(A => QBX_TEMPR2_8_net, B => QBX_TEMPR3_8_net, S => 
        BUFF_34_Y, Y => MX2_84_Y);
    ORA_GATE_14_inst : OR2
      port map(A => ENABLE_ADDRA_14_net, B => WEAP, Y => 
        BLKA_EN_14_net);
    MX2_392 : MX2
      port map(A => MX2_129_Y, B => MX2_185_Y, S => BUFF_32_Y, 
        Y => MX2_392_Y);
    dual_port_memory_R6C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_6_net, 
        BLKB => BLKB_EN_6_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR6_11_net, DOUTA2 => 
        QAX_TEMPR6_10_net, DOUTA1 => QAX_TEMPR6_9_net, DOUTA0 => 
        QAX_TEMPR6_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR6_11_net, DOUTB2 => QBX_TEMPR6_10_net, 
        DOUTB1 => QBX_TEMPR6_9_net, DOUTB0 => QBX_TEMPR6_8_net);
    ORB_GATE_7_inst : OR2
      port map(A => ENABLE_ADDRB_7_net, B => WEBP, Y => 
        BLKB_EN_7_net);
    MX2_193 : MX2
      port map(A => QAX_TEMPR8_0_net, B => QAX_TEMPR9_0_net, S => 
        BUFF_18_Y, Y => MX2_193_Y);
    dual_port_memory_R6C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_6_net, 
        BLKB => BLKB_EN_6_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR6_7_net, DOUTA2 => 
        QAX_TEMPR6_6_net, DOUTA1 => QAX_TEMPR6_5_net, DOUTA0 => 
        QAX_TEMPR6_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR6_7_net, DOUTB2 => QBX_TEMPR6_6_net, 
        DOUTB1 => QBX_TEMPR6_5_net, DOUTB0 => QBX_TEMPR6_4_net);
    AFF1_2_inst : DFN1
      port map(D => ADDRA(12), CLK => CLKA, Q => ADDRA_FF2_2_net);
    MX2_122 : MX2
      port map(A => QAX_TEMPR6_11_net, B => QAX_TEMPR7_11_net, 
        S => BUFF_14_Y, Y => MX2_122_Y);
    MX2_399 : MX2
      port map(A => MX2_369_Y, B => MX2_296_Y, S => BUFF_8_Y, 
        Y => MX2_399_Y);
    MX2_17 : MX2
      port map(A => QAX_TEMPR4_5_net, B => QAX_TEMPR5_5_net, S => 
        BUFF_22_Y, Y => MX2_17_Y);
    MX2_76 : MX2
      port map(A => QBX_TEMPR6_9_net, B => QBX_TEMPR7_9_net, S => 
        BUFF_28_Y, Y => MX2_76_Y);
    MX2_246 : MX2
      port map(A => QAX_TEMPR8_9_net, B => QAX_TEMPR9_9_net, S => 
        BUFF_20_Y, Y => MX2_246_Y);
    dual_port_memory_R13C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_13_net, 
        BLKB => BLKB_EN_13_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR13_3_net, DOUTA2 => 
        QAX_TEMPR13_2_net, DOUTA1 => QAX_TEMPR13_1_net, DOUTA0 => 
        QAX_TEMPR13_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR13_3_net, DOUTB2 => QBX_TEMPR13_2_net, 
        DOUTB1 => QBX_TEMPR13_1_net, DOUTB0 => QBX_TEMPR13_0_net);
    MX2_53 : MX2
      port map(A => QAX_TEMPR8_11_net, B => QAX_TEMPR9_11_net, 
        S => BUFF_14_Y, Y => MX2_53_Y);
    MX2_110 : MX2
      port map(A => MX2_317_Y, B => MX2_322_Y, S => BUFF_35_Y, 
        Y => MX2_110_Y);
    MX2_66 : MX2
      port map(A => QBX_TEMPR6_7_net, B => QBX_TEMPR7_7_net, S => 
        BUFF_3_Y, Y => MX2_66_Y);
    MX2_252 : MX2
      port map(A => MX2_215_Y, B => MX2_84_Y, S => BUFF_1_Y, Y => 
        MX2_252_Y);
    MX2_45 : MX2
      port map(A => MX2_403_Y, B => QAX_TEMPR14_1_net, S => 
        BUFF_38_Y, Y => MX2_45_Y);
    MX2_93 : MX2
      port map(A => MX2_253_Y, B => MX2_161_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_93_Y);
    MX2_261 : MX2
      port map(A => MX2_241_Y, B => MX2_396_Y, S => BUFF_4_Y, 
        Y => MX2_261_Y);
    MX2_267 : MX2
      port map(A => QBX_TEMPR8_1_net, B => QBX_TEMPR9_1_net, S => 
        BUFF_33_Y, Y => MX2_267_Y);
    MX2_158 : MX2
      port map(A => QAX_TEMPR12_10_net, B => QAX_TEMPR13_10_net, 
        S => BUFF_14_Y, Y => MX2_158_Y);
    MX2_180 : MX2
      port map(A => QBX_TEMPR2_1_net, B => QBX_TEMPR3_1_net, S => 
        BUFF_23_Y, Y => MX2_180_Y);
    AND2A_4 : AND2A
      port map(A => ADDRA(11), B => ADDRA(10), Y => AND2A_4_Y);
    dual_port_memory_R9C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_9_net, 
        BLKB => BLKB_EN_9_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR9_7_net, DOUTA2 => 
        QAX_TEMPR9_6_net, DOUTA1 => QAX_TEMPR9_5_net, DOUTA0 => 
        QAX_TEMPR9_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR9_7_net, DOUTB2 => QBX_TEMPR9_6_net, 
        DOUTB1 => QBX_TEMPR9_5_net, DOUTB0 => QBX_TEMPR9_4_net);
    MX2_DOUTB_14_inst : MX2
      port map(A => MX2_93_Y, B => MX2_175_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(14));
    MX2_144 : MX2
      port map(A => MX2_112_Y, B => MX2_137_Y, S => BUFF_29_Y, 
        Y => MX2_144_Y);
    BUFF_17 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_17_Y);
    MX2_348 : MX2
      port map(A => MX2_2_Y, B => MX2_16_Y, S => BUFF_8_Y, Y => 
        MX2_348_Y);
    MX2_192 : MX2
      port map(A => QBX_TEMPR12_14_net, B => QBX_TEMPR13_14_net, 
        S => BUFF_16_Y, Y => MX2_192_Y);
    MX2_343 : MX2
      port map(A => MX2_172_Y, B => MX2_152_Y, S => BUFF_4_Y, 
        Y => MX2_343_Y);
    dual_port_memory_R7C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_7_net, 
        BLKB => BLKB_EN_7_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR7_15_net, DOUTA2 => 
        QAX_TEMPR7_14_net, DOUTA1 => QAX_TEMPR7_13_net, DOUTA0 => 
        QAX_TEMPR7_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR7_15_net, DOUTB2 => QBX_TEMPR7_14_net, 
        DOUTB1 => QBX_TEMPR7_13_net, DOUTB0 => QBX_TEMPR7_12_net);
    MX2_400 : MX2
      port map(A => MX2_162_Y, B => MX2_314_Y, S => BUFF_32_Y, 
        Y => MX2_400_Y);
    dual_port_memory_R14C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_14_net, 
        BLKB => BLKB_EN_14_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR14_3_net, DOUTA2 => 
        QAX_TEMPR14_2_net, DOUTA1 => QAX_TEMPR14_1_net, DOUTA0 => 
        QAX_TEMPR14_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR14_3_net, DOUTB2 => QBX_TEMPR14_2_net, 
        DOUTB1 => QBX_TEMPR14_1_net, DOUTB0 => QBX_TEMPR14_0_net);
    BUFF_27 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_27_Y);
    MX2_137 : MX2
      port map(A => QBX_TEMPR10_5_net, B => QBX_TEMPR11_5_net, 
        S => BUFF_6_Y, Y => MX2_137_Y);
    BUFF_3 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_3_Y);
    MX2_254 : MX2
      port map(A => MX2_249_Y, B => MX2_342_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_254_Y);
    MX2_22 : MX2
      port map(A => QAX_TEMPR12_7_net, B => QAX_TEMPR13_7_net, 
        S => BUFF_10_Y, Y => MX2_22_Y);
    ORA_GATE_6_inst : OR2
      port map(A => ENABLE_ADDRA_6_net, B => WEAP, Y => 
        BLKA_EN_6_net);
    BUFF_38 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_38_Y);
    MX2_51 : MX2
      port map(A => QAX_TEMPR8_2_net, B => QAX_TEMPR9_2_net, S => 
        BUFF_21_Y, Y => MX2_51_Y);
    MX2_240 : MX2
      port map(A => QAX_TEMPR8_1_net, B => QAX_TEMPR9_1_net, S => 
        BUFF_21_Y, Y => MX2_240_Y);
    MX2_413 : MX2
      port map(A => MX2_388_Y, B => MX2_305_Y, S => BUFF_35_Y, 
        Y => MX2_413_Y);
    MX2_13 : MX2
      port map(A => MX2_74_Y, B => MX2_408_Y, S => BUFF_4_Y, Y => 
        MX2_13_Y);
    MX2_91 : MX2
      port map(A => QAX_TEMPR0_15_net, B => QAX_TEMPR1_15_net, 
        S => BUFF_9_Y, Y => MX2_91_Y);
    MX2_141 : MX2
      port map(A => MX2_281_Y, B => MX2_191_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_141_Y);
    MX2_58 : MX2
      port map(A => MX2_18_Y, B => QBX_TEMPR14_2_net, S => 
        BUFF_7_Y, Y => MX2_58_Y);
    dual_port_memory_R1C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_1_net, 
        BLKB => BLKB_EN_1_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR1_15_net, DOUTA2 => 
        QAX_TEMPR1_14_net, DOUTA1 => QAX_TEMPR1_13_net, DOUTA0 => 
        QAX_TEMPR1_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR1_15_net, DOUTB2 => QBX_TEMPR1_14_net, 
        DOUTB1 => QBX_TEMPR1_13_net, DOUTB0 => QBX_TEMPR1_12_net);
    MX2_77 : MX2
      port map(A => QBX_TEMPR8_9_net, B => QBX_TEMPR9_9_net, S => 
        BUFF_28_Y, Y => MX2_77_Y);
    dual_port_memory_R3C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_3_net, 
        BLKB => BLKB_EN_3_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR3_15_net, DOUTA2 => 
        QAX_TEMPR3_14_net, DOUTA1 => QAX_TEMPR3_13_net, DOUTA0 => 
        QAX_TEMPR3_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR3_15_net, DOUTB2 => QBX_TEMPR3_14_net, 
        DOUTB1 => QBX_TEMPR3_13_net, DOUTB0 => QBX_TEMPR3_12_net);
    MX2_98 : MX2
      port map(A => MX2_178_Y, B => MX2_235_Y, S => BUFF_35_Y, 
        Y => MX2_98_Y);
    MX2_80 : MX2
      port map(A => QBX_TEMPR0_10_net, B => QBX_TEMPR1_10_net, 
        S => BUFF_28_Y, Y => MX2_80_Y);
    MX2_245 : MX2
      port map(A => QBX_TEMPR2_12_net, B => QBX_TEMPR3_12_net, 
        S => BUFF_24_Y, Y => MX2_245_Y);
    MX2_229 : MX2
      port map(A => QBX_TEMPR2_10_net, B => QBX_TEMPR3_10_net, 
        S => BUFF_28_Y, Y => MX2_229_Y);
    MX2_341 : MX2
      port map(A => QBX_TEMPR4_8_net, B => QBX_TEMPR5_8_net, S => 
        BUFF_34_Y, Y => MX2_341_Y);
    MX2_DOUTA_11_inst : MX2
      port map(A => MX2_370_Y, B => MX2_78_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(11));
    MX2_411 : MX2
      port map(A => MX2_283_Y, B => MX2_145_Y, S => BUFF_7_Y, 
        Y => MX2_411_Y);
    AND2_1 : AND2
      port map(A => ADDRB(11), B => ADDRB(10), Y => AND2_1_Y);
    ORB_GATE_8_inst : OR2
      port map(A => ENABLE_ADDRB_8_net, B => WEBP, Y => 
        BLKB_EN_8_net);
    MX2_67 : MX2
      port map(A => MX2_8_Y, B => MX2_297_Y, S => BUFF_13_Y, Y => 
        MX2_67_Y);
    NAND2_ENABLE_ADDRB_10_inst : NAND2
      port map(A => AND2A_7_Y, B => AND2A_6_Y, Y => 
        ENABLE_ADDRB_10_net);
    NAND2_ENABLE_ADDRB_11_inst : NAND2
      port map(A => AND2_1_Y, B => AND2A_6_Y, Y => 
        ENABLE_ADDRB_11_net);
    MX2_206 : MX2
      port map(A => MX2_7_Y, B => MX2_34_Y, S => BUFF_4_Y, Y => 
        MX2_206_Y);
    MX2_271 : MX2
      port map(A => MX2_110_Y, B => MX2_181_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_271_Y);
    BUFF_5 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_5_Y);
    MX2_29 : MX2
      port map(A => QAX_TEMPR4_1_net, B => QAX_TEMPR5_1_net, S => 
        BUFF_18_Y, Y => MX2_29_Y);
    MX2_277 : MX2
      port map(A => QBX_TEMPR6_4_net, B => QBX_TEMPR7_4_net, S => 
        BUFF_12_Y, Y => MX2_277_Y);
    dual_port_memory_R1C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_1_net, 
        BLKB => BLKB_EN_1_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR1_3_net, DOUTA2 => 
        QAX_TEMPR1_2_net, DOUTA1 => QAX_TEMPR1_1_net, DOUTA0 => 
        QAX_TEMPR1_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR1_3_net, DOUTB2 => QBX_TEMPR1_2_net, 
        DOUTB1 => QBX_TEMPR1_1_net, DOUTB0 => QBX_TEMPR1_0_net);
    MX2_356 : MX2
      port map(A => MX2_81_Y, B => MX2_154_Y, S => BUFF_30_Y, 
        Y => MX2_356_Y);
    MX2_4 : MX2
      port map(A => QBX_TEMPR2_5_net, B => QBX_TEMPR3_5_net, S => 
        BUFF_12_Y, Y => MX2_4_Y);
    MX2_DOUTA_6_inst : MX2
      port map(A => MX2_170_Y, B => MX2_216_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(6));
    MX2_327 : MX2
      port map(A => MX2_118_Y, B => MX2_363_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_327_Y);
    NAND2_ENABLE_ADDRB_12_inst : NAND2
      port map(A => NOR2_1_Y, B => AND2_0_Y, Y => 
        ENABLE_ADDRB_12_net);
    MX2_149 : MX2
      port map(A => MX2_25_Y, B => MX2_239_Y, S => BUFF_30_Y, 
        Y => MX2_149_Y);
    NOR2_1 : NOR2
      port map(A => ADDRB(11), B => ADDRB(10), Y => NOR2_1_Y);
    MX2_117 : MX2
      port map(A => QAX_TEMPR0_7_net, B => QAX_TEMPR1_7_net, S => 
        BUFF_10_Y, Y => MX2_117_Y);
    dual_port_memory_R2C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_2_net, 
        BLKB => BLKB_EN_2_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR2_15_net, DOUTA2 => 
        QAX_TEMPR2_14_net, DOUTA1 => QAX_TEMPR2_13_net, DOUTA0 => 
        QAX_TEMPR2_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR2_15_net, DOUTB2 => QBX_TEMPR2_14_net, 
        DOUTB1 => QBX_TEMPR2_13_net, DOUTB0 => QBX_TEMPR2_12_net);
    dual_port_memory_R0C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_0_net, 
        BLKB => BLKB_EN_0_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR0_3_net, DOUTA2 => 
        QAX_TEMPR0_2_net, DOUTA1 => QAX_TEMPR0_1_net, DOUTA0 => 
        QAX_TEMPR0_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR0_3_net, DOUTB2 => QBX_TEMPR0_2_net, 
        DOUTB1 => QBX_TEMPR0_1_net, DOUTB0 => QBX_TEMPR0_0_net);
    MX2_223 : MX2
      port map(A => QAX_TEMPR10_2_net, B => QAX_TEMPR11_2_net, 
        S => BUFF_0_Y, Y => MX2_223_Y);
    BUFF_19 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_19_Y);
    dual_port_memory_R13C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_13_net, 
        BLKB => BLKB_EN_13_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR13_11_net, DOUTA2 => 
        QAX_TEMPR13_10_net, DOUTA1 => QAX_TEMPR13_9_net, 
        DOUTA0 => QAX_TEMPR13_8_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR13_11_net, DOUTB2 => 
        QBX_TEMPR13_10_net, DOUTB1 => QBX_TEMPR13_9_net, 
        DOUTB0 => QBX_TEMPR13_8_net);
    MX2_DOUTA_12_inst : MX2
      port map(A => MX2_260_Y, B => MX2_151_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(12));
    MX2_32 : MX2
      port map(A => QBX_TEMPR10_6_net, B => QBX_TEMPR11_6_net, 
        S => BUFF_3_Y, Y => MX2_32_Y);
    MX2_187 : MX2
      port map(A => QAX_TEMPR12_9_net, B => QAX_TEMPR13_9_net, 
        S => BUFF_20_Y, Y => MX2_187_Y);
    BFF1_1_inst : DFN1
      port map(D => ADDRB(11), CLK => CLKB, Q => ADDRB_FF2_1_net);
    MX2_345 : MX2
      port map(A => MX2_262_Y, B => MX2_75_Y, S => BUFF_30_Y, 
        Y => MX2_345_Y);
    AND2A_6 : AND2A
      port map(A => ADDRB(12), B => ADDRB(13), Y => AND2A_6_Y);
    MX2_104 : MX2
      port map(A => MX2_102_Y, B => MX2_58_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_104_Y);
    MX2_299 : MX2
      port map(A => QBX_TEMPR4_9_net, B => QBX_TEMPR5_9_net, S => 
        BUFF_34_Y, Y => MX2_299_Y);
    MX2_352 : MX2
      port map(A => MX2_21_Y, B => MX2_47_Y, S => ADDRB_FF2_2_net, 
        Y => MX2_352_Y);
    MX2_86 : MX2
      port map(A => QAX_TEMPR10_6_net, B => QAX_TEMPR11_6_net, 
        S => BUFF_10_Y, Y => MX2_86_Y);
    MX2_11 : MX2
      port map(A => MX2_217_Y, B => MX2_264_Y, S => BUFF_8_Y, 
        Y => MX2_11_Y);
    MX2_153 : MX2
      port map(A => MX2_73_Y, B => QAX_TEMPR14_3_net, S => 
        BUFF_17_Y, Y => MX2_153_Y);
    MX2_308 : MX2
      port map(A => QAX_TEMPR12_12_net, B => QAX_TEMPR13_12_net, 
        S => BUFF_37_Y, Y => MX2_308_Y);
    BUFF_29 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_29_Y);
    MX2_359 : MX2
      port map(A => QBX_TEMPR0_12_net, B => QBX_TEMPR1_12_net, 
        S => BUFF_24_Y, Y => MX2_359_Y);
    dual_port_memory_R12C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_12_net, 
        BLKB => BLKB_EN_12_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR12_3_net, DOUTA2 => 
        QAX_TEMPR12_2_net, DOUTA1 => QAX_TEMPR12_1_net, DOUTA0 => 
        QAX_TEMPR12_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR12_3_net, DOUTB2 => QBX_TEMPR12_2_net, 
        DOUTB1 => QBX_TEMPR12_1_net, DOUTB0 => QBX_TEMPR12_0_net);
    MX2_303 : MX2
      port map(A => QAX_TEMPR2_3_net, B => QAX_TEMPR3_3_net, S => 
        BUFF_0_Y, Y => MX2_303_Y);
    MX2_228 : MX2
      port map(A => QAX_TEMPR8_5_net, B => QAX_TEMPR9_5_net, S => 
        BUFF_26_Y, Y => MX2_228_Y);
    MX2_402 : MX2
      port map(A => QAX_TEMPR0_9_net, B => QAX_TEMPR1_9_net, S => 
        BUFF_11_Y, Y => MX2_402_Y);
    MX2_18 : MX2
      port map(A => QBX_TEMPR12_2_net, B => QBX_TEMPR13_2_net, 
        S => BUFF_5_Y, Y => MX2_18_Y);
    MX2_266 : MX2
      port map(A => QAX_TEMPR10_10_net, B => QAX_TEMPR11_10_net, 
        S => BUFF_14_Y, Y => MX2_266_Y);
    dual_port_memory_R12C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_12_net, 
        BLKB => BLKB_EN_12_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR12_11_net, DOUTA2 => 
        QAX_TEMPR12_10_net, DOUTA1 => QAX_TEMPR12_9_net, 
        DOUTA0 => QAX_TEMPR12_8_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR12_11_net, DOUTB2 => 
        QBX_TEMPR12_10_net, DOUTB1 => QBX_TEMPR12_9_net, 
        DOUTB0 => QBX_TEMPR12_8_net);
    NAND2_ENABLE_ADDRA_10_inst : NAND2
      port map(A => AND2A_2_Y, B => AND2A_3_Y, Y => 
        ENABLE_ADDRA_10_net);
    NAND2_ENABLE_ADDRA_11_inst : NAND2
      port map(A => AND2_2_Y, B => AND2A_3_Y, Y => 
        ENABLE_ADDRA_11_net);
    MX2_126 : MX2
      port map(A => MX2_92_Y, B => MX2_209_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_126_Y);
    dual_port_memory_R10C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_10_net, 
        BLKB => BLKB_EN_10_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR10_3_net, DOUTA2 => 
        QAX_TEMPR10_2_net, DOUTA1 => QAX_TEMPR10_1_net, DOUTA0 => 
        QAX_TEMPR10_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR10_3_net, DOUTB2 => QBX_TEMPR10_2_net, 
        DOUTB1 => QBX_TEMPR10_1_net, DOUTB0 => QBX_TEMPR10_0_net);
    ORA_GATE_13_inst : OR2
      port map(A => ENABLE_ADDRA_13_net, B => WEAP, Y => 
        BLKA_EN_13_net);
    MX2_125 : MX2
      port map(A => QAX_TEMPR0_14_net, B => QAX_TEMPR1_14_net, 
        S => BUFF_15_Y, Y => MX2_125_Y);
    MX2_397 : MX2
      port map(A => MX2_155_Y, B => MX2_310_Y, S => BUFF_17_Y, 
        Y => MX2_397_Y);
    dual_port_memory_R11C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_11_net, 
        BLKB => BLKB_EN_11_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR11_15_net, DOUTA2 => 
        QAX_TEMPR11_14_net, DOUTA1 => QAX_TEMPR11_13_net, 
        DOUTA0 => QAX_TEMPR11_12_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR11_15_net, DOUTB2 => 
        QBX_TEMPR11_14_net, DOUTB1 => QBX_TEMPR11_13_net, 
        DOUTB0 => QBX_TEMPR11_12_net);
    MX2_73 : MX2
      port map(A => QAX_TEMPR12_3_net, B => QAX_TEMPR13_3_net, 
        S => BUFF_0_Y, Y => MX2_73_Y);
    NAND2_ENABLE_ADDRA_5_inst : NAND2
      port map(A => AND2A_4_Y, B => AND2A_5_Y, Y => 
        ENABLE_ADDRA_5_net);
    MX2_293 : MX2
      port map(A => QBX_TEMPR8_6_net, B => QBX_TEMPR9_6_net, S => 
        BUFF_6_Y, Y => MX2_293_Y);
    MX2_242 : MX2
      port map(A => QBX_TEMPR0_14_net, B => QBX_TEMPR1_14_net, 
        S => BUFF_2_Y, Y => MX2_242_Y);
    MX2_200 : MX2
      port map(A => MX2_157_Y, B => QBX_TEMPR14_3_net, S => 
        BUFF_7_Y, Y => MX2_200_Y);
    MX2_44 : MX2
      port map(A => MX2_136_Y, B => MX2_153_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_44_Y);
    MX2_320 : MX2
      port map(A => MX2_158_Y, B => QAX_TEMPR14_10_net, S => 
        BUFF_32_Y, Y => MX2_320_Y);
    BUFF_34 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_34_Y);
    MX2_DOUTA_9_inst : MX2
      port map(A => MX2_150_Y, B => MX2_409_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(9));
    MX2_DOUTB_2_inst : MX2
      port map(A => MX2_141_Y, B => MX2_104_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(2));
    MX2_63 : MX2
      port map(A => QBX_TEMPR6_14_net, B => QBX_TEMPR7_14_net, 
        S => BUFF_2_Y, Y => MX2_63_Y);
    MX2_39 : MX2
      port map(A => MX2_240_Y, B => MX2_251_Y, S => BUFF_38_Y, 
        Y => MX2_39_Y);
    MX2_148 : MX2
      port map(A => QAX_TEMPR4_8_net, B => QAX_TEMPR5_8_net, S => 
        BUFF_11_Y, Y => MX2_148_Y);
    MX2_101 : MX2
      port map(A => QAX_TEMPR4_6_net, B => QAX_TEMPR5_6_net, S => 
        BUFF_26_Y, Y => MX2_101_Y);
    NAND2_ENABLE_ADDRA_12_inst : NAND2
      port map(A => NOR2_2_Y, B => AND2_3_Y, Y => 
        ENABLE_ADDRA_12_net);
    AND2_3 : AND2
      port map(A => ADDRA(13), B => ADDRA(12), Y => AND2_3_Y);
    MX2_231 : MX2
      port map(A => QAX_TEMPR6_4_net, B => QAX_TEMPR7_4_net, S => 
        BUFF_22_Y, Y => MX2_231_Y);
    MX2_164 : MX2
      port map(A => QBX_TEMPR12_9_net, B => QBX_TEMPR13_9_net, 
        S => BUFF_28_Y, Y => MX2_164_Y);
    MX2_237 : MX2
      port map(A => MX2_28_Y, B => MX2_268_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_237_Y);
    MX2_152 : MX2
      port map(A => QBX_TEMPR2_13_net, B => QBX_TEMPR3_13_net, 
        S => BUFF_24_Y, Y => MX2_152_Y);
    MX2_368 : MX2
      port map(A => MX2_64_Y, B => MX2_65_Y, S => ADDRB_FF2_2_net, 
        Y => MX2_368_Y);
    MX2_205 : MX2
      port map(A => MX2_273_Y, B => MX2_298_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_205_Y);
    dual_port_memory_R1C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_1_net, 
        BLKB => BLKB_EN_1_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR1_11_net, DOUTA2 => 
        QAX_TEMPR1_10_net, DOUTA1 => QAX_TEMPR1_9_net, DOUTA0 => 
        QAX_TEMPR1_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR1_11_net, DOUTB2 => QBX_TEMPR1_10_net, 
        DOUTB1 => QBX_TEMPR1_9_net, DOUTB0 => QBX_TEMPR1_8_net);
    MX2_301 : MX2
      port map(A => QAX_TEMPR2_6_net, B => QAX_TEMPR3_6_net, S => 
        BUFF_26_Y, Y => MX2_301_Y);
    MX2_363 : MX2
      port map(A => MX2_22_Y, B => QAX_TEMPR14_7_net, S => 
        BUFF_27_Y, Y => MX2_363_Y);
    NAND2_ENABLE_ADDRB_5_inst : NAND2
      port map(A => AND2A_1_Y, B => AND2A_0_Y, Y => 
        ENABLE_ADDRB_5_net);
    MX2_298 : MX2
      port map(A => MX2_366_Y, B => MX2_277_Y, S => BUFF_29_Y, 
        Y => MX2_298_Y);
    NAND2_ENABLE_ADDRA_6_inst : NAND2
      port map(A => AND2A_2_Y, B => AND2A_5_Y, Y => 
        ENABLE_ADDRA_6_net);
    NAND2_ENABLE_ADDRB_13_inst : NAND2
      port map(A => AND2A_1_Y, B => AND2_0_Y, Y => 
        ENABLE_ADDRB_13_net);
    MX2_196 : MX2
      port map(A => QBX_TEMPR10_4_net, B => QBX_TEMPR11_4_net, 
        S => BUFF_12_Y, Y => MX2_196_Y);
    AND2A_0 : AND2A
      port map(A => ADDRB(13), B => ADDRB(12), Y => AND2A_0_Y);
    MX2_195 : MX2
      port map(A => MX2_139_Y, B => MX2_244_Y, S => BUFF_38_Y, 
        Y => MX2_195_Y);
    ORB_GATE_10_inst : OR2
      port map(A => ENABLE_ADDRB_10_net, B => WEBP, Y => 
        BLKB_EN_10_net);
    MX2_244 : MX2
      port map(A => QAX_TEMPR6_0_net, B => QAX_TEMPR7_0_net, S => 
        BUFF_18_Y, Y => MX2_244_Y);
    MX2_390 : MX2
      port map(A => MX2_381_Y, B => MX2_62_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_390_Y);
    MX2_260 : MX2
      port map(A => MX2_88_Y, B => MX2_167_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_260_Y);
    MX2_109 : MX2
      port map(A => QBX_TEMPR6_5_net, B => QBX_TEMPR7_5_net, S => 
        BUFF_6_Y, Y => MX2_109_Y);
    MX2_DOUTA_4_inst : MX2
      port map(A => MX2_271_Y, B => MX2_346_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(4));
    MX2_161 : MX2
      port map(A => MX2_391_Y, B => MX2_63_Y, S => BUFF_13_Y, 
        Y => MX2_161_Y);
    MX2_87 : MX2
      port map(A => QBX_TEMPR6_2_net, B => QBX_TEMPR7_2_net, S => 
        BUFF_33_Y, Y => MX2_87_Y);
    MX2_71 : MX2
      port map(A => MX2_189_Y, B => QAX_TEMPR14_14_net, S => 
        BUFF_30_Y, Y => MX2_71_Y);
    ORA_GATE_5_inst : OR2
      port map(A => ENABLE_ADDRA_5_net, B => WEAP, Y => 
        BLKA_EN_5_net);
    WEBUBBLEB : INV
      port map(A => BLKB, Y => WEBP);
    MX2_305 : MX2
      port map(A => QAX_TEMPR2_5_net, B => QAX_TEMPR3_5_net, S => 
        BUFF_22_Y, Y => MX2_305_Y);
    dual_port_memory_R6C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_6_net, 
        BLKB => BLKB_EN_6_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR6_3_net, DOUTA2 => 
        QAX_TEMPR6_2_net, DOUTA1 => QAX_TEMPR6_1_net, DOUTA0 => 
        QAX_TEMPR6_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR6_3_net, DOUTB2 => QBX_TEMPR6_2_net, 
        DOUTB1 => QBX_TEMPR6_1_net, DOUTB0 => QBX_TEMPR6_0_net);
    MX2_324 : MX2
      port map(A => MX2_404_Y, B => MX2_13_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_324_Y);
    MX2_61 : MX2
      port map(A => QBX_TEMPR4_1_net, B => QBX_TEMPR5_1_net, S => 
        BUFF_23_Y, Y => MX2_61_Y);
    MX2_276 : MX2
      port map(A => QAX_TEMPR4_7_net, B => QAX_TEMPR5_7_net, S => 
        BUFF_10_Y, Y => MX2_276_Y);
    MX2_78 : MX2
      port map(A => MX2_142_Y, B => MX2_35_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_78_Y);
    MX2_265 : MX2
      port map(A => QBX_TEMPR6_1_net, B => QBX_TEMPR7_1_net, S => 
        BUFF_33_Y, Y => MX2_265_Y);
    MX2_361 : MX2
      port map(A => QAX_TEMPR10_0_net, B => QAX_TEMPR11_0_net, 
        S => BUFF_18_Y, Y => MX2_361_Y);
    BUFF_9 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_9_Y);
    MX2_211 : MX2
      port map(A => QBX_TEMPR12_6_net, B => QBX_TEMPR13_6_net, 
        S => BUFF_3_Y, Y => MX2_211_Y);
    BUFF_35 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_35_Y);
    MX2_217 : MX2
      port map(A => QAX_TEMPR8_13_net, B => QAX_TEMPR9_13_net, 
        S => BUFF_15_Y, Y => MX2_217_Y);
    BUFF_30 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_30_Y);
    ORB_GATE_3_inst : OR2
      port map(A => ENABLE_ADDRB_3_net, B => WEBP, Y => 
        BLKB_EN_3_net);
    MX2_68 : MX2
      port map(A => QBX_TEMPR8_15_net, B => QBX_TEMPR9_15_net, 
        S => BUFF_16_Y, Y => MX2_68_Y);
    MX2_25 : MX2
      port map(A => QAX_TEMPR8_14_net, B => QAX_TEMPR9_14_net, 
        S => BUFF_15_Y, Y => MX2_25_Y);
    MX2_DOUTB_8_inst : MX2
      port map(A => MX2_194_Y, B => MX2_225_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(8));
    MX2_281 : MX2
      port map(A => MX2_270_Y, B => MX2_414_Y, S => BUFF_7_Y, 
        Y => MX2_281_Y);
    MX2_287 : MX2
      port map(A => QAX_TEMPR2_14_net, B => QAX_TEMPR3_14_net, 
        S => BUFF_15_Y, Y => MX2_287_Y);
    NAND2_ENABLE_ADDRA_13_inst : NAND2
      port map(A => AND2A_4_Y, B => AND2_3_Y, Y => 
        ENABLE_ADDRA_13_net);
    ORA_GATE_2_inst : OR2
      port map(A => ENABLE_ADDRA_2_net, B => WEAP, Y => 
        BLKA_EN_2_net);
    BUFF_1 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_1_Y);
    MX2_169 : MX2
      port map(A => MX2_96_Y, B => QAX_TEMPR14_0_net, S => 
        BUFF_38_Y, Y => MX2_169_Y);
    BUFF_18 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_18_Y);
    MX2_202 : MX2
      port map(A => QBX_TEMPR0_1_net, B => QBX_TEMPR1_1_net, S => 
        BUFF_23_Y, Y => MX2_202_Y);
    MX2_346 : MX2
      port map(A => MX2_98_Y, B => MX2_383_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_346_Y);
    MX2_40 : MX2
      port map(A => QAX_TEMPR12_4_net, B => QAX_TEMPR13_4_net, 
        S => BUFF_22_Y, Y => MX2_40_Y);
    MX2_174 : MX2
      port map(A => MX2_51_Y, B => MX2_223_Y, S => BUFF_17_Y, 
        Y => MX2_174_Y);
    MX2_108 : MX2
      port map(A => MX2_207_Y, B => QAX_TEMPR14_13_net, S => 
        BUFF_8_Y, Y => MX2_108_Y);
    MX2_378 : MX2
      port map(A => QAX_TEMPR10_12_net, B => QAX_TEMPR11_12_net, 
        S => BUFF_37_Y, Y => MX2_378_Y);
    MX2_394 : MX2
      port map(A => QAX_TEMPR10_11_net, B => QAX_TEMPR11_11_net, 
        S => BUFF_14_Y, Y => MX2_394_Y);
    MX2_373 : MX2
      port map(A => MX2_219_Y, B => MX2_415_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_373_Y);
    MX2_365 : MX2
      port map(A => MX2_17_Y, B => MX2_31_Y, S => BUFF_35_Y, Y => 
        MX2_365_Y);
    ORB_GATE_13_inst : OR2
      port map(A => ENABLE_ADDRB_13_net, B => WEBP, Y => 
        BLKB_EN_13_net);
    MX2_259 : MX2
      port map(A => MX2_261_Y, B => MX2_30_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_259_Y);
    BUFF_2 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_2_Y);
    BUFF_28 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_28_Y);
    BUFF_0 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_0_Y);
    MX2_DOUTB_11_inst : MX2
      port map(A => MX2_233_Y, B => MX2_210_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(11));
    MX2_342 : MX2
      port map(A => MX2_10_Y, B => MX2_66_Y, S => BUFF_25_Y, Y => 
        MX2_342_Y);
    dual_port_memory_R1C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_1_net, 
        BLKB => BLKB_EN_1_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR1_7_net, DOUTA2 => 
        QAX_TEMPR1_6_net, DOUTA1 => QAX_TEMPR1_5_net, DOUTA0 => 
        QAX_TEMPR1_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR1_7_net, DOUTB2 => QBX_TEMPR1_6_net, 
        DOUTB1 => QBX_TEMPR1_5_net, DOUTB0 => QBX_TEMPR1_4_net);
    MX2_143 : MX2
      port map(A => MX2_38_Y, B => MX2_238_Y, S => BUFF_4_Y, Y => 
        MX2_143_Y);
    MX2_349 : MX2
      port map(A => QBX_TEMPR12_4_net, B => QBX_TEMPR13_4_net, 
        S => BUFF_12_Y, Y => MX2_349_Y);
    MX2_83 : MX2
      port map(A => MX2_343_Y, B => MX2_143_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_83_Y);
    MX2_270 : MX2
      port map(A => QBX_TEMPR0_2_net, B => QBX_TEMPR1_2_net, S => 
        BUFF_33_Y, Y => MX2_270_Y);
    dual_port_memory_R13C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_13_net, 
        BLKB => BLKB_EN_13_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR13_7_net, DOUTA2 => 
        QAX_TEMPR13_6_net, DOUTA1 => QAX_TEMPR13_5_net, DOUTA0 => 
        QAX_TEMPR13_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR13_7_net, DOUTB2 => QBX_TEMPR13_6_net, 
        DOUTB1 => QBX_TEMPR13_5_net, DOUTB0 => QBX_TEMPR13_4_net);
    MX2_120 : MX2
      port map(A => MX2_193_Y, B => MX2_361_Y, S => BUFF_38_Y, 
        Y => MX2_120_Y);
    MX2_357 : MX2
      port map(A => MX2_95_Y, B => MX2_407_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_357_Y);
    MX2_DOUTA_0_inst : MX2
      port map(A => MX2_284_Y, B => MX2_59_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(0));
    dual_port_memory_R4C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_4_net, 
        BLKB => BLKB_EN_4_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR4_3_net, DOUTA2 => 
        QAX_TEMPR4_2_net, DOUTA1 => QAX_TEMPR4_1_net, DOUTA0 => 
        QAX_TEMPR4_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR4_3_net, DOUTB2 => QBX_TEMPR4_2_net, 
        DOUTB1 => QBX_TEMPR4_1_net, DOUTB0 => QBX_TEMPR4_0_net);
    MX2_171 : MX2
      port map(A => QBX_TEMPR10_7_net, B => QBX_TEMPR11_7_net, 
        S => BUFF_3_Y, Y => MX2_171_Y);
    MX2_253 : MX2
      port map(A => MX2_242_Y, B => MX2_382_Y, S => BUFF_13_Y, 
        Y => MX2_253_Y);
    MX2_204 : MX2
      port map(A => MX2_3_Y, B => MX2_401_Y, S => BUFF_1_Y, Y => 
        MX2_204_Y);
    ORA_GATE_7_inst : OR2
      port map(A => ENABLE_ADDRA_7_net, B => WEAP, Y => 
        BLKA_EN_7_net);
    AFF1_3_inst : DFN1
      port map(D => ADDRA(13), CLK => CLKA, Q => ADDRA_FF2_3_net);
    MX2_236 : MX2
      port map(A => QBX_TEMPR6_3_net, B => QBX_TEMPR7_3_net, S => 
        BUFF_5_Y, Y => MX2_236_Y);
    MX2_262 : MX2
      port map(A => QAX_TEMPR4_15_net, B => QAX_TEMPR5_15_net, 
        S => BUFF_9_Y, Y => MX2_262_Y);
    MX2_46 : MX2
      port map(A => MX2_246_Y, B => MX2_295_Y, S => BUFF_31_Y, 
        Y => MX2_46_Y);
    dual_port_memory_R4C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_4_net, 
        BLKB => BLKB_EN_4_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR4_7_net, DOUTA2 => 
        QAX_TEMPR4_6_net, DOUTA1 => QAX_TEMPR4_5_net, DOUTA0 => 
        QAX_TEMPR4_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR4_7_net, DOUTB2 => QBX_TEMPR4_6_net, 
        DOUTB1 => QBX_TEMPR4_5_net, DOUTB0 => QBX_TEMPR4_4_net);
    MX2_35 : MX2
      port map(A => MX2_263_Y, B => QAX_TEMPR14_11_net, S => 
        BUFF_32_Y, Y => MX2_35_Y);
    MX2_168 : MX2
      port map(A => QAX_TEMPR6_6_net, B => QAX_TEMPR7_6_net, S => 
        BUFF_26_Y, Y => MX2_168_Y);
    MX2_275 : MX2
      port map(A => QBX_TEMPR8_10_net, B => QBX_TEMPR9_10_net, 
        S => BUFF_28_Y, Y => MX2_275_Y);
    MX2_DOUTB_12_inst : MX2
      port map(A => MX2_324_Y, B => MX2_307_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(12));
    MX2_371 : MX2
      port map(A => MX2_101_Y, B => MX2_168_Y, S => BUFF_27_Y, 
        Y => MX2_371_Y);
    MX2_410 : MX2
      port map(A => QAX_TEMPR10_8_net, B => QAX_TEMPR11_8_net, 
        S => BUFF_11_Y, Y => MX2_410_Y);
    NAND2_ENABLE_ADDRA_0_inst : NAND2
      port map(A => NOR2_2_Y, B => NOR2_3_Y, Y => 
        ENABLE_ADDRA_0_net);
    MX2_258 : MX2
      port map(A => MX2_226_Y, B => MX2_213_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_258_Y);
    dual_port_memory_R7C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_7_net, 
        BLKB => BLKB_EN_7_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR7_7_net, DOUTA2 => 
        QAX_TEMPR7_6_net, DOUTA1 => QAX_TEMPR7_5_net, DOUTA0 => 
        QAX_TEMPR7_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR7_7_net, DOUTB2 => QBX_TEMPR7_6_net, 
        DOUTB1 => QBX_TEMPR7_5_net, DOUTB0 => QBX_TEMPR7_4_net);
    MX2_142 : MX2
      port map(A => MX2_53_Y, B => MX2_394_Y, S => BUFF_32_Y, 
        Y => MX2_142_Y);
    MX2_134 : MX2
      port map(A => QBX_TEMPR0_7_net, B => QBX_TEMPR1_7_net, S => 
        BUFF_3_Y, Y => MX2_134_Y);
    MX2_2 : MX2
      port map(A => QAX_TEMPR4_13_net, B => QAX_TEMPR5_13_net, 
        S => BUFF_37_Y, Y => MX2_2_Y);
    MX2_156 : MX2
      port map(A => MX2_367_Y, B => MX2_356_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_156_Y);
    dual_port_memory_R10C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_10_net, 
        BLKB => BLKB_EN_10_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR10_7_net, DOUTA2 => 
        QAX_TEMPR10_6_net, DOUTA1 => QAX_TEMPR10_5_net, DOUTA0 => 
        QAX_TEMPR10_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR10_7_net, DOUTB2 => QBX_TEMPR10_6_net, 
        DOUTB1 => QBX_TEMPR10_5_net, DOUTB0 => QBX_TEMPR10_4_net);
    MX2_DOUTB_1_inst : MX2
      port map(A => MX2_131_Y, B => MX2_208_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(1));
    MX2_190 : MX2
      port map(A => QBX_TEMPR4_3_net, B => QBX_TEMPR5_3_net, S => 
        BUFF_5_Y, Y => MX2_190_Y);
    MX2_155 : MX2
      port map(A => QAX_TEMPR0_2_net, B => QAX_TEMPR1_2_net, S => 
        BUFF_21_Y, Y => MX2_155_Y);
    MX2_179 : MX2
      port map(A => QAX_TEMPR6_2_net, B => QAX_TEMPR7_2_net, S => 
        BUFF_21_Y, Y => MX2_179_Y);
    MX2_338 : MX2
      port map(A => QAX_TEMPR10_3_net, B => QAX_TEMPR11_3_net, 
        S => BUFF_0_Y, Y => MX2_338_Y);
    dual_port_memory_R10C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_10_net, 
        BLKB => BLKB_EN_10_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR10_11_net, DOUTA2 => 
        QAX_TEMPR10_10_net, DOUTA1 => QAX_TEMPR10_9_net, 
        DOUTA0 => QAX_TEMPR10_8_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR10_11_net, DOUTB2 => 
        QBX_TEMPR10_10_net, DOUTB1 => QBX_TEMPR10_9_net, 
        DOUTB0 => QBX_TEMPR10_8_net);
    MX2_333 : MX2
      port map(A => QAX_TEMPR0_8_net, B => QAX_TEMPR1_8_net, S => 
        BUFF_11_Y, Y => MX2_333_Y);
    MX2_350 : MX2
      port map(A => MX2_187_Y, B => QAX_TEMPR14_9_net, S => 
        BUFF_31_Y, Y => MX2_350_Y);
    MX2_264 : MX2
      port map(A => QAX_TEMPR10_13_net, B => QAX_TEMPR11_13_net, 
        S => BUFF_15_Y, Y => MX2_264_Y);
    MX2_52 : MX2
      port map(A => MX2_325_Y, B => QBX_TEMPR14_7_net, S => 
        BUFF_25_Y, Y => MX2_52_Y);
    NAND2_ENABLE_ADDRB_0_inst : NAND2
      port map(A => NOR2_1_Y, B => NOR2_0_Y, Y => 
        ENABLE_ADDRB_0_net);
    MX2_81 : MX2
      port map(A => QAX_TEMPR4_14_net, B => QAX_TEMPR5_14_net, 
        S => BUFF_15_Y, Y => MX2_81_Y);
    MX2_375 : MX2
      port map(A => QAX_TEMPR12_2_net, B => QAX_TEMPR13_2_net, 
        S => BUFF_0_Y, Y => MX2_375_Y);
    MX2_306 : MX2
      port map(A => QAX_TEMPR0_12_net, B => QAX_TEMPR1_12_net, 
        S => BUFF_37_Y, Y => MX2_306_Y);
    BFF1_0_inst : DFN1
      port map(D => ADDRB(10), CLK => CLKB, Q => ADDRB_FF2_0_net);
    MX2_92 : MX2
      port map(A => MX2_24_Y, B => MX2_358_Y, S => BUFF_30_Y, 
        Y => MX2_92_Y);
    dual_port_memory_R12C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_12_net, 
        BLKB => BLKB_EN_12_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR12_15_net, DOUTA2 => 
        QAX_TEMPR12_14_net, DOUTA1 => QAX_TEMPR12_13_net, 
        DOUTA0 => QAX_TEMPR12_12_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR12_15_net, DOUTB2 => 
        QBX_TEMPR12_14_net, DOUTB1 => QBX_TEMPR12_13_net, 
        DOUTB0 => QBX_TEMPR12_12_net);
    MX2_88 : MX2
      port map(A => MX2_306_Y, B => MX2_312_Y, S => BUFF_8_Y, 
        Y => MX2_88_Y);
    MX2_216 : MX2
      port map(A => MX2_163_Y, B => MX2_243_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_216_Y);
    BUFF_14 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_14_Y);
    NAND2_ENABLE_ADDRA_4_inst : NAND2
      port map(A => NOR2_2_Y, B => AND2A_5_Y, Y => 
        ENABLE_ADDRA_4_net);
    MX2_230 : MX2
      port map(A => QBX_TEMPR0_4_net, B => QBX_TEMPR1_4_net, S => 
        BUFF_12_Y, Y => MX2_230_Y);
    MX2_131 : MX2
      port map(A => MX2_376_Y, B => MX2_173_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_131_Y);
    MX2_286 : MX2
      port map(A => MX2_311_Y, B => MX2_60_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_286_Y);
    ORB_GATE_12_inst : OR2
      port map(A => ENABLE_ADDRB_12_net, B => WEBP, Y => 
        BLKB_EN_12_net);
    dual_port_memory_R2C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_2_net, 
        BLKB => BLKB_EN_2_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR2_3_net, DOUTA2 => 
        QAX_TEMPR2_2_net, DOUTA1 => QAX_TEMPR2_1_net, DOUTA0 => 
        QAX_TEMPR2_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR2_3_net, DOUTB2 => QBX_TEMPR2_2_net, 
        DOUTB1 => QBX_TEMPR2_1_net, DOUTB0 => QBX_TEMPR2_0_net);
    MX2_302 : MX2
      port map(A => QBX_TEMPR12_15_net, B => QBX_TEMPR13_15_net, 
        S => BUFF_16_Y, Y => MX2_302_Y);
    MX2_103 : MX2
      port map(A => QBX_TEMPR8_3_net, B => QBX_TEMPR9_3_net, S => 
        BUFF_5_Y, Y => MX2_103_Y);
    BUFF_24 : BUFF
      port map(A => ADDRB_FF2_0_net, Y => BUFF_24_Y);
    MX2_309 : MX2
      port map(A => QAX_TEMPR12_6_net, B => QAX_TEMPR13_6_net, 
        S => BUFF_10_Y, Y => MX2_309_Y);
    MX2_272 : MX2
      port map(A => QBX_TEMPR8_8_net, B => QBX_TEMPR9_8_net, S => 
        BUFF_34_Y, Y => MX2_272_Y);
    MX2_235 : MX2
      port map(A => QAX_TEMPR10_4_net, B => QAX_TEMPR11_4_net, 
        S => BUFF_22_Y, Y => MX2_235_Y);
    MX2_331 : MX2
      port map(A => QBX_TEMPR8_11_net, B => QBX_TEMPR9_11_net, 
        S => BUFF_39_Y, Y => MX2_331_Y);
    MX2_47 : MX2
      port map(A => MX2_121_Y, B => MX2_23_Y, S => BUFF_36_Y, 
        Y => MX2_47_Y);
    MX2_24 : MX2
      port map(A => QAX_TEMPR8_15_net, B => QAX_TEMPR9_15_net, 
        S => BUFF_9_Y, Y => MX2_24_Y);
    MX2_DOUTB_7_inst : MX2
      port map(A => MX2_254_Y, B => MX2_340_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(7));
    MX2_DOUTA_13_inst : MX2
      port map(A => MX2_105_Y, B => MX2_26_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(13));
    dual_port_memory_R14C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_14_net, 
        BLKB => BLKB_EN_14_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR14_7_net, DOUTA2 => 
        QAX_TEMPR14_6_net, DOUTA1 => QAX_TEMPR14_5_net, DOUTA0 => 
        QAX_TEMPR14_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR14_7_net, DOUTB2 => QBX_TEMPR14_6_net, 
        DOUTB1 => QBX_TEMPR14_5_net, DOUTB0 => QBX_TEMPR14_4_net);
    MX2_178 : MX2
      port map(A => QAX_TEMPR8_4_net, B => QAX_TEMPR9_4_net, S => 
        BUFF_22_Y, Y => MX2_178_Y);
    MX2_114 : MX2
      port map(A => QBX_TEMPR0_6_net, B => QBX_TEMPR1_6_net, S => 
        BUFF_6_Y, Y => MX2_114_Y);
    MX2_59 : MX2
      port map(A => MX2_120_Y, B => MX2_169_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_59_Y);
    dual_port_memory_R12C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_12_net, 
        BLKB => BLKB_EN_12_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR12_7_net, DOUTA2 => 
        QAX_TEMPR12_6_net, DOUTA1 => QAX_TEMPR12_5_net, DOUTA0 => 
        QAX_TEMPR12_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR12_7_net, DOUTB2 => QBX_TEMPR12_6_net, 
        DOUTB1 => QBX_TEMPR12_5_net, DOUTB0 => QBX_TEMPR12_4_net);
    dual_port_memory_R5C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_5_net, 
        BLKB => BLKB_EN_5_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR5_15_net, DOUTA2 => 
        QAX_TEMPR5_14_net, DOUTA1 => QAX_TEMPR5_13_net, DOUTA0 => 
        QAX_TEMPR5_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR5_15_net, DOUTB2 => QBX_TEMPR5_14_net, 
        DOUTB1 => QBX_TEMPR5_13_net, DOUTB0 => QBX_TEMPR5_12_net);
    MX2_366 : MX2
      port map(A => QBX_TEMPR4_4_net, B => QBX_TEMPR5_4_net, S => 
        BUFF_12_Y, Y => MX2_366_Y);
    MX2_318 : MX2
      port map(A => QBX_TEMPR12_12_net, B => QBX_TEMPR13_12_net, 
        S => BUFF_24_Y, Y => MX2_318_Y);
    ORA_GATE_8_inst : OR2
      port map(A => ENABLE_ADDRA_8_net, B => WEAP, Y => 
        BLKA_EN_8_net);
    MX2_127 : MX2
      port map(A => MX2_197_Y, B => MX2_410_Y, S => BUFF_31_Y, 
        Y => MX2_127_Y);
    MX2_3 : MX2
      port map(A => QBX_TEMPR0_9_net, B => QBX_TEMPR1_9_net, S => 
        BUFF_34_Y, Y => MX2_3_Y);
    MX2_99 : MX2
      port map(A => MX2_135_Y, B => MX2_303_Y, S => BUFF_17_Y, 
        Y => MX2_99_Y);
    MX2_313 : MX2
      port map(A => MX2_144_Y, B => MX2_20_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_313_Y);
    MX2_184 : MX2
      port map(A => MX2_212_Y, B => QBX_TEMPR14_8_net, S => 
        BUFF_1_Y, Y => MX2_184_Y);
    dual_port_memory_R7C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_7_net, 
        BLKB => BLKB_EN_7_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR7_3_net, DOUTA2 => 
        QAX_TEMPR7_2_net, DOUTA1 => QAX_TEMPR7_1_net, DOUTA0 => 
        QAX_TEMPR7_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR7_3_net, DOUTB2 => QBX_TEMPR7_2_net, 
        DOUTB1 => QBX_TEMPR7_1_net, DOUTB0 => QBX_TEMPR7_0_net);
    MX2_354 : MX2
      port map(A => MX2_39_Y, B => MX2_45_Y, S => ADDRA_FF2_2_net, 
        Y => MX2_354_Y);
    MX2_412 : MX2
      port map(A => MX2_149_Y, B => MX2_71_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_412_Y);
    MX2_388 : MX2
      port map(A => QAX_TEMPR0_5_net, B => QAX_TEMPR1_5_net, S => 
        BUFF_22_Y, Y => MX2_388_Y);
    MX2_139 : MX2
      port map(A => QAX_TEMPR4_0_net, B => QAX_TEMPR5_0_net, S => 
        BUFF_18_Y, Y => MX2_139_Y);
    MX2_383 : MX2
      port map(A => MX2_40_Y, B => QAX_TEMPR14_4_net, S => 
        BUFF_35_Y, Y => MX2_383_Y);
    ORA_GATE_10_inst : OR2
      port map(A => ENABLE_ADDRA_10_net, B => WEAP, Y => 
        BLKA_EN_10_net);
    MX2_12 : MX2
      port map(A => MX2_255_Y, B => MX2_344_Y, S => BUFF_25_Y, 
        Y => MX2_12_Y);
    MX2_249 : MX2
      port map(A => MX2_134_Y, B => MX2_386_Y, S => BUFF_25_Y, 
        Y => MX2_249_Y);
    AND2_2 : AND2
      port map(A => ADDRA(11), B => ADDRA(10), Y => AND2_2_Y);
    MX2_362 : MX2
      port map(A => MX2_276_Y, B => MX2_90_Y, S => BUFF_27_Y, 
        Y => MX2_362_Y);
    MX2_102 : MX2
      port map(A => MX2_43_Y, B => MX2_89_Y, S => BUFF_7_Y, Y => 
        MX2_102_Y);
    MX2_163 : MX2
      port map(A => MX2_37_Y, B => MX2_86_Y, S => BUFF_27_Y, Y => 
        MX2_163_Y);
    MX2_335 : MX2
      port map(A => MX2_70_Y, B => MX2_345_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_335_Y);
    MX2_210 : MX2
      port map(A => MX2_176_Y, B => MX2_159_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_210_Y);
    NAND2_ENABLE_ADDRB_7_inst : NAND2
      port map(A => AND2_1_Y, B => AND2A_0_Y, Y => 
        ENABLE_ADDRB_7_net);
    dual_port_memory_R0C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_0_net, 
        BLKB => BLKB_EN_0_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR0_7_net, DOUTA2 => 
        QAX_TEMPR0_6_net, DOUTA1 => QAX_TEMPR0_5_net, DOUTA0 => 
        QAX_TEMPR0_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR0_7_net, DOUTB2 => QBX_TEMPR0_6_net, 
        DOUTB1 => QBX_TEMPR0_5_net, DOUTB0 => QBX_TEMPR0_4_net);
    MX2_369 : MX2
      port map(A => QAX_TEMPR0_13_net, B => QAX_TEMPR1_13_net, 
        S => BUFF_37_Y, Y => MX2_369_Y);
    MX2_274 : MX2
      port map(A => QBX_TEMPR2_0_net, B => QBX_TEMPR3_0_net, S => 
        BUFF_23_Y, Y => MX2_274_Y);
    MX2_111 : MX2
      port map(A => MX2_77_Y, B => MX2_372_Y, S => BUFF_1_Y, Y => 
        MX2_111_Y);
    BUFF_15 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_15_Y);
    BUFF_10 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_10_Y);
    MX2_404 : MX2
      port map(A => MX2_359_Y, B => MX2_245_Y, S => BUFF_4_Y, 
        Y => MX2_404_Y);
    dual_port_memory_R5C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_5_net, 
        BLKB => BLKB_EN_5_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR5_3_net, DOUTA2 => 
        QAX_TEMPR5_2_net, DOUTA1 => QAX_TEMPR5_1_net, DOUTA0 => 
        QAX_TEMPR5_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR5_3_net, DOUTB2 => QBX_TEMPR5_2_net, 
        DOUTB1 => QBX_TEMPR5_1_net, DOUTB0 => QBX_TEMPR5_0_net);
    MX2_280 : MX2
      port map(A => QAX_TEMPR2_15_net, B => QAX_TEMPR3_15_net, 
        S => BUFF_9_Y, Y => MX2_280_Y);
    MX2_181 : MX2
      port map(A => MX2_124_Y, B => MX2_231_Y, S => BUFF_35_Y, 
        Y => MX2_181_Y);
    MX2_197 : MX2
      port map(A => QAX_TEMPR8_8_net, B => QAX_TEMPR9_8_net, S => 
        BUFF_11_Y, Y => MX2_197_Y);
    MX2_347 : MX2
      port map(A => MX2_204_Y, B => MX2_393_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_347_Y);
    MX2_215 : MX2
      port map(A => QBX_TEMPR0_8_net, B => QBX_TEMPR1_8_net, S => 
        BUFF_34_Y, Y => MX2_215_Y);
    MX2_311 : MX2
      port map(A => MX2_68_Y, B => MX2_6_Y, S => BUFF_13_Y, Y => 
        MX2_311_Y);
    MX2_DOUTA_8_inst : MX2
      port map(A => MX2_288_Y, B => MX2_106_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(8));
    MX2_243 : MX2
      port map(A => MX2_309_Y, B => QAX_TEMPR14_6_net, S => 
        BUFF_27_Y, Y => MX2_243_Y);
    MX2_DOUTB_5_inst : MX2
      port map(A => MX2_373_Y, B => MX2_313_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(5));
    NAND2_ENABLE_ADDRB_8_inst : NAND2
      port map(A => NOR2_1_Y, B => AND2A_6_Y, Y => 
        ENABLE_ADDRB_8_net);
    dual_port_memory_R11C1 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(7), 
        DINA2 => DINA(6), DINA1 => DINA(5), DINA0 => DINA(4), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(7), DINB2 => DINB(6), DINB1 => DINB(5), 
        DINB0 => DINB(4), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_11_net, 
        BLKB => BLKB_EN_11_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR11_7_net, DOUTA2 => 
        QAX_TEMPR11_6_net, DOUTA1 => QAX_TEMPR11_5_net, DOUTA0 => 
        QAX_TEMPR11_4_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR11_7_net, DOUTB2 => QBX_TEMPR11_6_net, 
        DOUTB1 => QBX_TEMPR11_5_net, DOUTB0 => QBX_TEMPR11_4_net);
    BUFF_25 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_25_Y);
    BUFF_20 : BUFF
      port map(A => ADDRA_FF2_0_net, Y => BUFF_20_Y);
    MX2_34 : MX2
      port map(A => QBX_TEMPR10_12_net, B => QBX_TEMPR11_12_net, 
        S => BUFF_24_Y, Y => MX2_34_Y);
    MX2_285 : MX2
      port map(A => QAX_TEMPR4_3_net, B => QAX_TEMPR5_3_net, S => 
        BUFF_0_Y, Y => MX2_285_Y);
    MX2_381 : MX2
      port map(A => MX2_256_Y, B => MX2_94_Y, S => BUFF_13_Y, 
        Y => MX2_381_Y);
    MX2_409 : MX2
      port map(A => MX2_46_Y, B => MX2_350_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_409_Y);
    MX2_232 : MX2
      port map(A => MX2_336_Y, B => MX2_200_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_232_Y);
    MX2_19 : MX2
      port map(A => MX2_56_Y, B => QBX_TEMPR14_10_net, S => 
        BUFF_19_Y, Y => MX2_19_Y);
    MX2_43 : MX2
      port map(A => QBX_TEMPR8_2_net, B => QBX_TEMPR9_2_net, S => 
        BUFF_33_Y, Y => MX2_43_Y);
    MX2_138 : MX2
      port map(A => MX2_333_Y, B => MX2_337_Y, S => BUFF_31_Y, 
        Y => MX2_138_Y);
    AFF1_1_inst : DFN1
      port map(D => ADDRA(11), CLK => CLKA, Q => ADDRA_FF2_1_net);
    MX2_162 : MX2
      port map(A => QAX_TEMPR0_10_net, B => QAX_TEMPR1_10_net, 
        S => BUFF_20_Y, Y => MX2_162_Y);
    MX2_DOUTA_7_inst : MX2
      port map(A => MX2_351_Y, B => MX2_327_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(7));
    MX2_119 : MX2
      port map(A => QBX_TEMPR2_4_net, B => QBX_TEMPR3_4_net, S => 
        BUFF_12_Y, Y => MX2_119_Y);
    MX2_150 : MX2
      port map(A => MX2_9_Y, B => MX2_387_Y, S => ADDRA_FF2_2_net, 
        Y => MX2_150_Y);
    MX2_248 : MX2
      port map(A => QAX_TEMPR6_8_net, B => QAX_TEMPR7_8_net, S => 
        BUFF_11_Y, Y => MX2_248_Y);
    MX2_376 : MX2
      port map(A => MX2_202_Y, B => MX2_180_Y, S => BUFF_36_Y, 
        Y => MX2_376_Y);
    MX2_189 : MX2
      port map(A => QAX_TEMPR12_14_net, B => QAX_TEMPR13_14_net, 
        S => BUFF_9_Y, Y => MX2_189_Y);
    MX2_20 : MX2
      port map(A => MX2_300_Y, B => QBX_TEMPR14_5_net, S => 
        BUFF_29_Y, Y => MX2_20_Y);
    MX2_146 : MX2
      port map(A => QAX_TEMPR0_6_net, B => QAX_TEMPR1_6_net, S => 
        BUFF_26_Y, Y => MX2_146_Y);
    MX2_315 : MX2
      port map(A => QBX_TEMPR4_5_net, B => QBX_TEMPR5_5_net, S => 
        BUFF_12_Y, Y => MX2_315_Y);
    MX2_145 : MX2
      port map(A => QBX_TEMPR2_3_net, B => QBX_TEMPR3_3_net, S => 
        BUFF_5_Y, Y => MX2_145_Y);
    dual_port_memory_R2C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_2_net, 
        BLKB => BLKB_EN_2_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR2_11_net, DOUTA2 => 
        QAX_TEMPR2_10_net, DOUTA1 => QAX_TEMPR2_9_net, DOUTA0 => 
        QAX_TEMPR2_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR2_11_net, DOUTB2 => QBX_TEMPR2_10_net, 
        DOUTB1 => QBX_TEMPR2_9_net, DOUTB0 => QBX_TEMPR2_8_net);
    MX2_340 : MX2
      port map(A => MX2_201_Y, B => MX2_52_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_340_Y);
    MX2_385 : MX2
      port map(A => MX2_133_Y, B => MX2_12_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_385_Y);
    MX2_72 : MX2
      port map(A => MX2_318_Y, B => QBX_TEMPR14_12_net, S => 
        BUFF_4_Y, Y => MX2_72_Y);
    MX2_234 : MX2
      port map(A => QBX_TEMPR4_10_net, B => QBX_TEMPR5_10_net, 
        S => BUFF_28_Y, Y => MX2_234_Y);
    MX2_372 : MX2
      port map(A => QBX_TEMPR10_9_net, B => QBX_TEMPR11_9_net, 
        S => BUFF_28_Y, Y => MX2_372_Y);
    MX2_173 : MX2
      port map(A => MX2_61_Y, B => MX2_265_Y, S => BUFF_36_Y, 
        Y => MX2_173_Y);
    BUFF_32 : BUFF
      port map(A => ADDRA_FF2_1_net, Y => BUFF_32_Y);
    dual_port_memory_R4C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_4_net, 
        BLKB => BLKB_EN_4_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR4_15_net, DOUTA2 => 
        QAX_TEMPR4_14_net, DOUTA1 => QAX_TEMPR4_13_net, DOUTA0 => 
        QAX_TEMPR4_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR4_15_net, DOUTB2 => QBX_TEMPR4_14_net, 
        DOUTB1 => QBX_TEMPR4_13_net, DOUTB0 => QBX_TEMPR4_12_net);
    MX2_379 : MX2
      port map(A => MX2_290_Y, B => MX2_122_Y, S => BUFF_32_Y, 
        Y => MX2_379_Y);
    MX2_62 : MX2
      port map(A => MX2_160_Y, B => MX2_214_Y, S => BUFF_13_Y, 
        Y => MX2_62_Y);
    MX2_209 : MX2
      port map(A => MX2_294_Y, B => QAX_TEMPR14_15_net, S => 
        BUFF_30_Y, Y => MX2_209_Y);
    dual_port_memory_R5C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_5_net, 
        BLKB => BLKB_EN_5_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR5_11_net, DOUTA2 => 
        QAX_TEMPR5_10_net, DOUTA1 => QAX_TEMPR5_9_net, DOUTA0 => 
        QAX_TEMPR5_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR5_11_net, DOUTB2 => QBX_TEMPR5_10_net, 
        DOUTB1 => QBX_TEMPR5_9_net, DOUTB0 => QBX_TEMPR5_8_net);
    MX2_221 : MX2
      port map(A => MX2_308_Y, B => QAX_TEMPR14_12_net, S => 
        BUFF_8_Y, Y => MX2_221_Y);
    ORB_GATE_9_inst : OR2
      port map(A => ENABLE_ADDRB_9_net, B => WEBP, Y => 
        BLKB_EN_9_net);
    MX2_212 : MX2
      port map(A => QBX_TEMPR12_8_net, B => QBX_TEMPR13_8_net, 
        S => BUFF_34_Y, Y => MX2_212_Y);
    MX2_227 : MX2
      port map(A => MX2_100_Y, B => MX2_360_Y, S => BUFF_19_Y, 
        Y => MX2_227_Y);
    MX2_41 : MX2
      port map(A => QBX_TEMPR8_0_net, B => QBX_TEMPR9_0_net, S => 
        BUFF_23_Y, Y => MX2_41_Y);
    MX2_118 : MX2
      port map(A => MX2_36_Y, B => MX2_218_Y, S => BUFF_27_Y, 
        Y => MX2_118_Y);
    MX2_DOUTA_10_inst : MX2
      port map(A => MX2_186_Y, B => MX2_380_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(10));
    MX2_26 : MX2
      port map(A => MX2_11_Y, B => MX2_108_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_26_Y);
    MX2_282 : MX2
      port map(A => QAX_TEMPR12_8_net, B => QAX_TEMPR13_8_net, 
        S => BUFF_11_Y, Y => MX2_282_Y);
    MX2_48 : MX2
      port map(A => QAX_TEMPR6_9_net, B => QAX_TEMPR7_9_net, S => 
        BUFF_20_Y, Y => MX2_48_Y);
    MX2_55 : MX2
      port map(A => MX2_282_Y, B => QAX_TEMPR14_8_net, S => 
        BUFF_31_Y, Y => MX2_55_Y);
    MX2_188 : MX2
      port map(A => MX2_111_Y, B => MX2_116_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_188_Y);
    AND2A_3 : AND2A
      port map(A => ADDRA(12), B => ADDRA(13), Y => AND2A_3_Y);
    MX2_307 : MX2
      port map(A => MX2_206_Y, B => MX2_72_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_307_Y);
    MX2_95 : MX2
      port map(A => MX2_80_Y, B => MX2_229_Y, S => BUFF_19_Y, 
        Y => MX2_95_Y);
    MX2_203 : MX2
      port map(A => QBX_TEMPR10_1_net, B => QBX_TEMPR11_1_net, 
        S => BUFF_33_Y, Y => MX2_203_Y);
    ORA_GATE_3_inst : OR2
      port map(A => ENABLE_ADDRA_3_net, B => WEAP, Y => 
        BLKA_EN_3_net);
    MX2_79 : MX2
      port map(A => MX2_166_Y, B => MX2_378_Y, S => BUFF_8_Y, 
        Y => MX2_79_Y);
    dual_port_memory_R4C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_4_net, 
        BLKB => BLKB_EN_4_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR4_11_net, DOUTA2 => 
        QAX_TEMPR4_10_net, DOUTA1 => QAX_TEMPR4_9_net, DOUTA0 => 
        QAX_TEMPR4_8_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR4_11_net, DOUTB2 => QBX_TEMPR4_10_net, 
        DOUTB1 => QBX_TEMPR4_9_net, DOUTB0 => QBX_TEMPR4_8_net);
    MX2_30 : MX2
      port map(A => MX2_269_Y, B => QBX_TEMPR14_13_net, S => 
        BUFF_4_Y, Y => MX2_30_Y);
    MX2_172 : MX2
      port map(A => QBX_TEMPR0_13_net, B => QBX_TEMPR1_13_net, 
        S => BUFF_24_Y, Y => MX2_172_Y);
    MX2_344 : MX2
      port map(A => QBX_TEMPR6_6_net, B => QBX_TEMPR7_6_net, S => 
        BUFF_6_Y, Y => MX2_344_Y);
    MX2_69 : MX2
      port map(A => MX2_330_Y, B => MX2_19_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_69_Y);
    MX2_336 : MX2
      port map(A => MX2_103_Y, B => MX2_224_Y, S => BUFF_7_Y, 
        Y => MX2_336_Y);
    NAND2_ENABLE_ADDRB_3_inst : NAND2
      port map(A => AND2_1_Y, B => NOR2_0_Y, Y => 
        ENABLE_ADDRB_3_net);
    MX2_269 : MX2
      port map(A => QBX_TEMPR12_13_net, B => QBX_TEMPR13_13_net, 
        S => BUFF_2_Y, Y => MX2_269_Y);
    MX2_291 : MX2
      port map(A => QAX_TEMPR2_7_net, B => QAX_TEMPR3_7_net, S => 
        BUFF_10_Y, Y => MX2_291_Y);
    MX2_297 : MX2
      port map(A => QBX_TEMPR10_14_net, B => QBX_TEMPR11_14_net, 
        S => BUFF_16_Y, Y => MX2_297_Y);
    MX2_214 : MX2
      port map(A => QBX_TEMPR6_15_net, B => QBX_TEMPR7_15_net, 
        S => BUFF_16_Y, Y => MX2_214_Y);
    NOR2_0 : NOR2
      port map(A => ADDRB(13), B => ADDRB(12), Y => NOR2_0_Y);
    NAND2_ENABLE_ADDRB_9_inst : NAND2
      port map(A => AND2A_1_Y, B => AND2A_6_Y, Y => 
        ENABLE_ADDRB_9_net);
    MX2_208 : MX2
      port map(A => MX2_289_Y, B => MX2_165_Y, S => 
        ADDRB_FF2_2_net, Y => MX2_208_Y);
    dual_port_memory_R9C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_9_net, 
        BLKB => BLKB_EN_9_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR9_15_net, DOUTA2 => 
        QAX_TEMPR9_14_net, DOUTA1 => QAX_TEMPR9_13_net, DOUTA0 => 
        QAX_TEMPR9_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR9_15_net, DOUTB2 => QBX_TEMPR9_14_net, 
        DOUTB1 => QBX_TEMPR9_13_net, DOUTB0 => QBX_TEMPR9_12_net);
    MX2_284 : MX2
      port map(A => MX2_130_Y, B => MX2_195_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_284_Y);
    dual_port_memory_R10C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_10_net, 
        BLKB => BLKB_EN_10_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR10_15_net, DOUTA2 => 
        QAX_TEMPR10_14_net, DOUTA1 => QAX_TEMPR10_13_net, 
        DOUTA0 => QAX_TEMPR10_12_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR10_15_net, DOUTB2 => 
        QBX_TEMPR10_14_net, DOUTB1 => QBX_TEMPR10_13_net, 
        DOUTB0 => QBX_TEMPR10_12_net);
    MX2_106 : MX2
      port map(A => MX2_127_Y, B => MX2_55_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_106_Y);
    dual_port_memory_R14C2 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(11), 
        DINA2 => DINA(10), DINA1 => DINA(9), DINA0 => DINA(8), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(11), DINB2 => DINB(10), DINB1 => DINB(9), 
        DINB0 => DINB(8), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_14_net, 
        BLKB => BLKB_EN_14_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR14_11_net, DOUTA2 => 
        QAX_TEMPR14_10_net, DOUTA1 => QAX_TEMPR14_9_net, 
        DOUTA0 => QAX_TEMPR14_8_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR14_11_net, DOUTB2 => 
        QBX_TEMPR14_10_net, DOUTB1 => QBX_TEMPR14_9_net, 
        DOUTB0 => QBX_TEMPR14_8_net);
    MX2_332 : MX2
      port map(A => QAX_TEMPR2_0_net, B => QAX_TEMPR3_0_net, S => 
        BUFF_18_Y, Y => MX2_332_Y);
    MX2_DOUTB_13_inst : MX2
      port map(A => MX2_83_Y, B => MX2_259_Y, S => 
        ADDRB_FF2_3_net, Y => DOUTB(13));
    MX2_133 : MX2
      port map(A => MX2_114_Y, B => MX2_250_Y, S => BUFF_25_Y, 
        Y => MX2_133_Y);
    MX2_157 : MX2
      port map(A => QBX_TEMPR12_3_net, B => QBX_TEMPR13_3_net, 
        S => BUFF_5_Y, Y => MX2_157_Y);
    MX2_105 : MX2
      port map(A => MX2_399_Y, B => MX2_348_Y, S => 
        ADDRA_FF2_2_net, Y => MX2_105_Y);
    BUFF_36 : BUFF
      port map(A => ADDRB_FF2_1_net, Y => BUFF_36_Y);
    MX2_339 : MX2
      port map(A => MX2_192_Y, B => QBX_TEMPR14_14_net, S => 
        BUFF_13_Y, Y => MX2_339_Y);
    MX2_367 : MX2
      port map(A => MX2_125_Y, B => MX2_287_Y, S => BUFF_30_Y, 
        Y => MX2_367_Y);
    MX2_263 : MX2
      port map(A => QAX_TEMPR12_11_net, B => QAX_TEMPR13_11_net, 
        S => BUFF_14_Y, Y => MX2_263_Y);
    MX2_300 : MX2
      port map(A => QBX_TEMPR12_5_net, B => QBX_TEMPR13_5_net, 
        S => BUFF_6_Y, Y => MX2_300_Y);
    ORB_GATE_1_inst : OR2
      port map(A => ENABLE_ADDRB_1_net, B => WEBP, Y => 
        BLKB_EN_1_net);
    MX2_36 : MX2
      port map(A => QAX_TEMPR8_7_net, B => QAX_TEMPR9_7_net, S => 
        BUFF_10_Y, Y => MX2_36_Y);
    MX2_15 : MX2
      port map(A => MX2_375_Y, B => QAX_TEMPR14_2_net, S => 
        BUFF_17_Y, Y => MX2_15_Y);
    dual_port_memory_R8C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_8_net, 
        BLKB => BLKB_EN_8_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR8_15_net, DOUTA2 => 
        QAX_TEMPR8_14_net, DOUTA1 => QAX_TEMPR8_13_net, DOUTA0 => 
        QAX_TEMPR8_12_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR8_15_net, DOUTB2 => QBX_TEMPR8_14_net, 
        DOUTB1 => QBX_TEMPR8_13_net, DOUTB0 => QBX_TEMPR8_12_net);
    ORB_GATE_0_inst : OR2
      port map(A => ENABLE_ADDRB_0_net, B => WEBP, Y => 
        BLKB_EN_0_net);
    MX2_27 : MX2
      port map(A => QBX_TEMPR0_5_net, B => QBX_TEMPR1_5_net, S => 
        BUFF_12_Y, Y => MX2_27_Y);
    MX2_268 : MX2
      port map(A => MX2_334_Y, B => QAX_TEMPR14_5_net, S => 
        BUFF_35_Y, Y => MX2_268_Y);
    MX2_316 : MX2
      port map(A => QAX_TEMPR2_1_net, B => QAX_TEMPR3_1_net, S => 
        BUFF_18_Y, Y => MX2_316_Y);
    dual_port_memory_R3C0 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(3), 
        DINA2 => DINA(2), DINA1 => DINA(1), DINA0 => DINA(0), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(3), DINB2 => DINB(2), DINB1 => DINB(1), 
        DINB0 => DINB(0), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_3_net, 
        BLKB => BLKB_EN_3_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR3_3_net, DOUTA2 => 
        QAX_TEMPR3_2_net, DOUTA1 => QAX_TEMPR3_1_net, DOUTA0 => 
        QAX_TEMPR3_0_net, DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR3_3_net, DOUTB2 => QBX_TEMPR3_2_net, 
        DOUTB1 => QBX_TEMPR3_1_net, DOUTB0 => QBX_TEMPR3_0_net);
    WEBUBBLEA : INV
      port map(A => BLKA, Y => WEAP);
    ORA_GATE_11_inst : OR2
      port map(A => ENABLE_ADDRA_11_net, B => WEAP, Y => 
        BLKA_EN_11_net);
    MX2_140 : MX2
      port map(A => QAX_TEMPR0_11_net, B => QAX_TEMPR1_11_net, 
        S => BUFF_14_Y, Y => MX2_140_Y);
    MX2_166 : MX2
      port map(A => QAX_TEMPR8_12_net, B => QAX_TEMPR9_12_net, 
        S => BUFF_37_Y, Y => MX2_166_Y);
    MX2_386 : MX2
      port map(A => QBX_TEMPR2_7_net, B => QBX_TEMPR3_7_net, S => 
        BUFF_3_Y, Y => MX2_386_Y);
    MX2_5 : MX2
      port map(A => MX2_398_Y, B => MX2_316_Y, S => BUFF_38_Y, 
        Y => MX2_5_Y);
    MX2_132 : MX2
      port map(A => QAX_TEMPR10_5_net, B => QAX_TEMPR11_5_net, 
        S => BUFF_26_Y, Y => MX2_132_Y);
    AND2A_5 : AND2A
      port map(A => ADDRA(13), B => ADDRA(12), Y => AND2A_5_Y);
    MX2_165 : MX2
      port map(A => MX2_115_Y, B => QBX_TEMPR14_1_net, S => 
        BUFF_36_Y, Y => MX2_165_Y);
    BFF1_2_inst : DFN1
      port map(D => ADDRB(12), CLK => CLKB, Q => ADDRB_FF2_2_net);
    MX2_DOUTA_15_inst : MX2
      port map(A => MX2_335_Y, B => MX2_126_Y, S => 
        ADDRA_FF2_3_net, Y => DOUTA(15));
    MX2_9 : MX2
      port map(A => MX2_402_Y, B => MX2_319_Y, S => BUFF_31_Y, 
        Y => MX2_9_Y);
    MX2_82 : MX2
      port map(A => MX2_117_Y, B => MX2_291_Y, S => BUFF_27_Y, 
        Y => MX2_82_Y);
    MX2_360 : MX2
      port map(A => QBX_TEMPR2_11_net, B => QBX_TEMPR3_11_net, 
        S => BUFF_39_Y, Y => MX2_360_Y);
    dual_port_memory_R14C3 : RAM4K9
      port map(ADDRA11 => GND_1_net, ADDRA10 => GND_1_net, 
        ADDRA9 => ADDRA(9), ADDRA8 => ADDRA(8), ADDRA7 => 
        ADDRA(7), ADDRA6 => ADDRA(6), ADDRA5 => ADDRA(5), 
        ADDRA4 => ADDRA(4), ADDRA3 => ADDRA(3), ADDRA2 => 
        ADDRA(2), ADDRA1 => ADDRA(1), ADDRA0 => ADDRA(0), 
        ADDRB11 => GND_1_net, ADDRB10 => GND_1_net, ADDRB9 => 
        ADDRB(9), ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), 
        ADDRB1 => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => DINA(15), 
        DINA2 => DINA(14), DINA1 => DINA(13), DINA0 => DINA(12), 
        DINB8 => GND_1_net, DINB7 => GND_1_net, DINB6 => 
        GND_1_net, DINB5 => GND_1_net, DINB4 => GND_1_net, 
        DINB3 => DINB(15), DINB2 => DINB(14), DINB1 => DINB(13), 
        DINB0 => DINB(12), WIDTHA0 => GND_1_net, WIDTHA1 => 
        VCC_1_net, WIDTHB0 => GND_1_net, WIDTHB1 => VCC_1_net, 
        PIPEA => GND_1_net, PIPEB => GND_1_net, WMODEA => 
        VCC_1_net, WMODEB => VCC_1_net, BLKA => BLKA_EN_14_net, 
        BLKB => BLKB_EN_14_net, WENA => RWA, WENB => RWB, CLKA => 
        CLKA, CLKB => CLKB, RESET => RESETP, DOUTA8 => OPEN , 
        DOUTA7 => OPEN , DOUTA6 => OPEN , DOUTA5 => OPEN , 
        DOUTA4 => OPEN , DOUTA3 => QAX_TEMPR14_15_net, DOUTA2 => 
        QAX_TEMPR14_14_net, DOUTA1 => QAX_TEMPR14_13_net, 
        DOUTA0 => QAX_TEMPR14_12_net, DOUTB8 => OPEN , DOUTB7 => 
        OPEN , DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => QBX_TEMPR14_15_net, DOUTB2 => 
        QBX_TEMPR14_14_net, DOUTB1 => QBX_TEMPR14_13_net, 
        DOUTB0 => QBX_TEMPR14_12_net);
    MX2_312 : MX2
      port map(A => QAX_TEMPR2_12_net, B => QAX_TEMPR3_12_net, 
        S => BUFF_37_Y, Y => MX2_312_Y);
end DEF_ARCH;
