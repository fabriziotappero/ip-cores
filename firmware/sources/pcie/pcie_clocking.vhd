--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_clocking
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! Instantiates an MMCM for the PCIe Gen3 hard block and the user design. 
--! Depending on some generic values, the frequencies of the MMCM and 
--! buffers are generated.
--!
--! @detail
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Virtex7 PCIe Gen3 DMA Core
--! 
--! \copyright GNU LGPL License
--! Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3.0 of the License, or (at your option) any later version.
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--! Lesser General Public License for more details.<br>
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library.
--! 

--! @brief ieee

library work, ieee, UNISIM;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;



entity pcie_clocking is
generic
(
    PCIE_ASYNC_EN      : string  := "FALSE";                 -- PCIe async enable
    PCIE_TXBUF_EN      : string  := "FALSE";                 -- PCIe TX buffer enable for Gen1/Gen2 only
    PCIE_CLK_SHARING_EN: string  := "FALSE";                 -- Enable Clock Sharing
    PCIE_LANE          : integer := 8;                       -- PCIe number of lanes
    PCIE_LINK_SPEED    : integer := 3;                       -- PCIe link speed 
    PCIE_REFCLK_FREQ   : integer := 0;                       -- PCIe reference clock frequency
    PCIE_USERCLK1_FREQ : integer := 5;                       -- PCIe user clock 1 frequency
    PCIE_USERCLK2_FREQ : integer := 4;                       -- PCIe user clock 2 frequency
    PCIE_OOBCLK_MODE   : integer := 1;                       -- PCIe oob clock mode
    PCIE_DEBUG_MODE    : integer := 0                        -- PCIe Debug mode
);
port
(
    CLK_CLK            : in std_logic;
    CLK_TXOUTCLK       : in std_logic;
    CLK_RXOUTCLK_IN    : in std_logic_vector(PCIE_LANE-1 downto 0);
    CLK_RST_N          : in std_logic;
    CLK_PCLK_SEL       : in std_logic_vector(PCIE_LANE-1 downto 0);
    CLK_PCLK_SEL_SLAVE : in std_logic_vector(PCIE_LANE-1 downto 0);
    CLK_GEN3           : in std_logic;
    
    CLK_PCLK           : out std_logic;
    CLK_PCLK_SLAVE     : out std_logic;
    CLK_RXUSRCLK       : out std_logic;
    CLK_RXOUTCLK_OUT   : out std_logic_vector(PCIE_LANE-1 downto 0);
    CLK_DCLK           : out std_logic;
    CLK_OOBCLK         : out std_logic;
    CLK_USERCLK1       : out std_logic;
    CLK_USERCLK2       : out std_logic;
    CLK_MMCM_LOCK      : out std_logic
);
end entity pcie_clocking;

architecture rtl of pcie_clocking is

    function clksel(S: integer) return integer is
    begin
        case (S) is
            when 5      => return 2;
            when 4      => return 4;
            when 3      => return 8;
            when 1      => return 32;
            when others => return 16;
        end case;
    end function clksel; 
    
    function refclksel(S: integer) return integer is
    begin
        case (S) is
            when 2      => return 4;
            when 1      => return 8;
            when others => return 10;
        end case;
    end function refclksel;

    ---------- Select Clock Divider ----------------------
    constant            DIVCLK_DIVIDE    : integer :=  1;
                                               
                                              
    constant            CLKOUT0_DIVIDE_F : real := 8.0;
    
    constant            CLKOUT1_DIVIDE   : integer := 4;
    constant            CLKOUT2_DIVIDE   : integer := clksel(PCIE_USERCLK1_FREQ);
    constant            CLKOUT3_DIVIDE   : integer := clksel(PCIE_USERCLK2_FREQ);
    constant            CLKFBOUT_MULT_F  : real := real(refclksel(PCIE_REFCLK_FREQ));
    constant            CLKIN1_PERIOD    : real := real(refclksel(PCIE_REFCLK_FREQ));


                                           
    constant            CLKOUT4_DIVIDE   : integer := 20;

    constant            PCIE_GEN1_MODE   : integer := 0;             -- PCIe link speed is GEN1 only
    ---------- Input Registers ---------------------------
    signal           pclk_sel_reg1       : std_logic_vector(PCIE_LANE-1 downto 0) := (others => '0');
    signal           pclk_sel_slave_reg1 : std_logic_vector(PCIE_LANE-1 downto 0) := (others => '0');
    signal           gen3_reg1           : std_logic := '0';

    signal           pclk_sel_reg2       : std_logic_vector(PCIE_LANE-1 downto 0) := (others => '0');
    signal           pclk_sel_slave_reg2 : std_logic_vector(PCIE_LANE-1 downto 0) := (others => '0');
    signal           gen3_reg2           : std_logic := '0';
    
    attribute ASYNC_REG : string;
    attribute SHIFT_EXTRACT : string;
    attribute ASYNC_REG of pclk_sel_reg1: signal is "TRUE";
    attribute ASYNC_REG of pclk_sel_slave_reg1: signal is "TRUE";
    attribute ASYNC_REG of gen3_reg1: signal is "TRUE";
    attribute ASYNC_REG of pclk_sel_reg2: signal is "TRUE";
    attribute ASYNC_REG of pclk_sel_slave_reg2: signal is "TRUE";
    attribute ASYNC_REG of gen3_reg2: signal is "TRUE";
    attribute SHIFT_EXTRACT of pclk_sel_reg1: signal is "NO";
    attribute SHIFT_EXTRACT of pclk_sel_slave_reg1: signal is "NO";
    attribute SHIFT_EXTRACT of gen3_reg1: signal is "NO";
    attribute SHIFT_EXTRACT of pclk_sel_reg2: signal is "NO";
    attribute SHIFT_EXTRACT of pclk_sel_slave_reg2: signal is "NO";
    attribute SHIFT_EXTRACT of gen3_reg2: signal is "NO";
    
    
       
    ---------- Internal Signals -------------------------- 
    signal    refclk         : std_logic;
    signal    mmcm_fb        : std_logic;
    signal    clk_125mhz     : std_logic;
    signal    clk_125mhz_buf : std_logic;
    signal    clk_250mhz     : std_logic;
    signal    userclk1       : std_logic;
    signal    userclk2       : std_logic;
    signal    oobclk         : std_logic;
    signal    pclk_sel       : std_logic := '0';
    signal    pclk_sel_slave : std_logic := '0';
    signal    CLK_RST        : std_logic;
    signal    pclk_sel_n     : std_logic;
    signal    pclk_sel_slave_n: std_logic;
    ---------- Output Registers --------------------------
    signal    pclk_1         : std_logic;
    signal    pclk           : std_logic;
    signal    userclk1_1     : std_logic;
    signal    userclk2_1     : std_logic;
    signal    mmcm_lock      : std_logic;
    
    
begin

---------- Input FF ----------------------------------------------------------
process(pclk, CLK_RST_N)
begin
    if(CLK_RST_N = '0') then
        ---------- 1st Stage FF --------------------------
        pclk_sel_reg1       <= (others => '0');
        pclk_sel_slave_reg1 <= (others => '0');
        gen3_reg1           <= '0';
        ---------- 2nd Stage FF --------------------------
        pclk_sel_reg2       <= (others => '0');
        pclk_sel_slave_reg2 <= (others => '0');
        gen3_reg2           <= '0';
    elsif(rising_edge(pclk)) then
        ---------- 1st Stage FF --------------------------
        pclk_sel_reg1 <= CLK_PCLK_SEL;
        pclk_sel_slave_reg1 <= CLK_PCLK_SEL_SLAVE;
        gen3_reg1     <= CLK_GEN3;
        ---------- 2nd Stage FF --------------------------
        pclk_sel_reg2 <= pclk_sel_reg1;
        pclk_sel_slave_reg2 <= pclk_sel_slave_reg1;
        gen3_reg2     <= gen3_reg1;
    end if;
end process;

CLK_RST <= not CLK_RST_N;


---------- MMCM --------------------------------------------------------------
mmcm0: MMCME2_ADV 
generic map
(

    BANDWIDTH                  => ("OPTIMIZED"),
    CLKOUT4_CASCADE            => FALSE,
    COMPENSATION               => ("ZHOLD"),
    STARTUP_WAIT               => FALSE,
    DIVCLK_DIVIDE              => (DIVCLK_DIVIDE),
    CLKFBOUT_MULT_F            => (CLKFBOUT_MULT_F),  
    CLKFBOUT_PHASE             => (0.000),
    CLKFBOUT_USE_FINE_PS       => FALSE,
    CLKOUT0_DIVIDE_F           => (CLKOUT0_DIVIDE_F),                    
    CLKOUT0_PHASE              => (0.000),
    CLKOUT0_DUTY_CYCLE         => (0.500),
    CLKOUT0_USE_FINE_PS        => FALSE,
    CLKOUT1_DIVIDE             => (CLKOUT1_DIVIDE),                    
    CLKOUT1_PHASE              => (0.000),
    CLKOUT1_DUTY_CYCLE         => (0.500),
    CLKOUT1_USE_FINE_PS        => FALSE,
    CLKOUT2_DIVIDE             => (CLKOUT2_DIVIDE),                  
    CLKOUT2_PHASE              => (0.000),
    CLKOUT2_DUTY_CYCLE         => (0.500),
    CLKOUT2_USE_FINE_PS        => FALSE,
    CLKOUT3_DIVIDE             => (CLKOUT3_DIVIDE),                  
    CLKOUT3_PHASE              => (0.000),
    CLKOUT3_DUTY_CYCLE         => (0.500),
    CLKOUT3_USE_FINE_PS        => FALSE,
    CLKOUT4_DIVIDE             => (CLKOUT4_DIVIDE),                  
    CLKOUT4_PHASE              => (0.000),
    CLKOUT4_DUTY_CYCLE         => (0.500),
    CLKOUT4_USE_FINE_PS        => FALSE,
    CLKIN1_PERIOD              => (CLKIN1_PERIOD),                   
    REF_JITTER1                => (0.010)
    
)
port map
(

     ---------- Input ------------------------------------
    CLKIN1                     => CLK_TXOUTCLK,
    CLKIN2                     => '0',                     -- not used, comment out CLKIN2 if it cause implementation issues
    CLKINSEL                   => '1',
    CLKFBIN                    => mmcm_fb,
    RST                        => CLK_RST,
    PWRDWN                     => '0', 
    
    ---------- Output ------------------------------------
    CLKFBOUT                   => mmcm_fb,
    CLKFBOUTB                  => open,
    CLKOUT0                    => clk_125mhz,
    CLKOUT0B                   => open,
    CLKOUT1                    => clk_250mhz,
    CLKOUT1B                   => open,
    CLKOUT2                    => userclk1,
    CLKOUT2B                   => open,
    CLKOUT3                    => userclk2,
    CLKOUT3B                   => open,
    CLKOUT4                    => oobclk,
    CLKOUT5                    => open,
    CLKOUT6                    => open,
    LOCKED                     => mmcm_lock,
    
    ---------- Dynamic Reconfiguration -------------------
    DCLK                       => '0',
    DADDR                      => (others => '0'),
    DEN                        => '0',
    DWE                        => '0',
    DI                         => (others => '0'),
    DO                         => open,
    DRDY                       => open,
    
    ---------- Dynamic Phase Shift -----------------------
    PSCLK                      => '0',
    PSEN                       => '0',
    PSINCDEC                   => '0',
    PSDONE                     => open,
    
    ---------- Status ------------------------------------
    CLKINSTOPPED               => open,
    CLKFBSTOPPED               => open  

); 
  

pclk_sel_n <= not pclk_sel;
---------- Select PCLK MUX ---------------------------------------------------
g0: if (PCIE_LINK_SPEED /= 1) generate
    pclk_i1: BUFGCTRL 
    port map
    (
        ---------- Input ---------------------------------
        CE0                      => '1',
        CE1                      => '1',
        I0                       => clk_125mhz,
        I1                       => clk_250mhz,
        IGNORE0                  => '0',
        IGNORE1                  => '0',
        S0                       => pclk_sel_n,
        S1                       => pclk_sel,
        ---------- Output --------------------------------
        O                        => pclk_1
    );
    
end generate;

g1: if (PCIE_LINK_SPEED = 1) generate
    ---------- Select PCLK Buffer ------------------------
    pclk_i1: BUFG 
    port map
    (
        I                       =>   clk_125mhz,
        O                       =>   clk_125mhz_buf
    );
    pclk_1 <= clk_125mhz_buf;
end generate;

---------- Select PCLK MUX for Slave---------------------------------------------------
g2: if(PCIE_CLK_SHARING_EN = "FALSE") generate
   ---------- PCLK MUX for Slave------------------
    CLK_PCLK_SLAVE <= '0';
end generate;

pclk_sel_slave_n <= not pclk_sel_slave;

g3: if(PCIE_CLK_SHARING_EN /= "FALSE") generate
  g3a: if (PCIE_LINK_SPEED /= 1) generate
    ---------- PCLK Mux ----------------------------------
    pclk_slave: BUFGCTRL 
    port map
    (
        ---------- Input ---------------------------------
        CE0                       =>  '1',         
        CE1                       =>  '1',        
        I0                        =>  clk_125mhz,   
        I1                        =>  clk_250mhz,   
        IGNORE0                   =>  '0',        
        IGNORE1                   =>  '0',        
        S0                        =>   pclk_sel_slave_n,    
        S1                        =>   pclk_sel_slave,    
        ---------- Output --------------------------------
        O                         =>  CLK_PCLK_SLAVE
    );
  end generate;
  g3b: if (PCIE_LINK_SPEED = 1 ) generate

    ---------- Select PCLK Buffer ------------------------
    ---------- PCLK Buffer -------------------------------
    pclk_slave: BUFG 
    port map
    (
        I                        =>  clk_125mhz, 
        O                        =>  CLK_PCLK_SLAVE
    );
  end generate;
end generate;



---------- Generate RXOUTCLK Buffer for Debug --------------------------------
g4: if ((PCIE_DEBUG_MODE = 1) or (PCIE_ASYNC_EN = "TRUE")) generate
   g4a: for i in 0 to PCIE_LANE-1 generate
        bufg0: BUFG 
        port map
        (
            I                       =>  CLK_RXOUTCLK_IN(i), 
            O                       =>  CLK_RXOUTCLK_OUT(i)
        );
    end generate;
end generate;

g5: if (not((PCIE_DEBUG_MODE = 1) or (PCIE_ASYNC_EN = "TRUE"))) generate
    ---------- Disable RXOUTCLK Buffer for Normal Operation 
    CLK_RXOUTCLK_OUT <= (others => '0');
end generate;


---------- Generate DCLK Buffer ----------------------------------------------
g6: if (PCIE_USERCLK2_FREQ <= 3) generate 
    ---------- Disable DCLK Buffer -----------------------
    CLK_DCLK <= userclk2_1;                       -- always less than 125Mhz
end generate;

g7: if (PCIE_USERCLK2_FREQ > 3) generate
    ---------- DCLK Buffer -------------------------------
    dclk_i: BUFG 
    port map
    (
        I                    =>    clk_125mhz, 
        O                    =>    CLK_DCLK
    );

end generate;



---------- Generate USERCLK1 Buffer ------------------------------------------
g8: if ((PCIE_GEN1_MODE = 1) and (PCIE_USERCLK1_FREQ = 3)) generate
    ---------- USERCLK1 same as PCLK -------------------
    userclk1_1 <= pclk_1;
end generate;
    
g9: if (not((PCIE_GEN1_MODE = 1) and (PCIE_USERCLK1_FREQ = 3))) generate
    ---------- USERCLK1 Buffer ---------------------------
    usrclk1_i1: BUFG 
    port map
    (
        I                    =>     (userclk1),
        O                    =>     (userclk1_1)
    );
end generate;



---------- Generate USERCLK2 Buffer ------------------------------------------

g10: if ((PCIE_GEN1_MODE = 1) and (PCIE_USERCLK2_FREQ = 3 )) generate
---------- USERCLK2 same as PCLK -------------------
    userclk2_1 <= pclk_1;
end generate;

g11: if (not ((PCIE_GEN1_MODE = 1) and (PCIE_USERCLK2_FREQ = 3 ))) and (PCIE_USERCLK2_FREQ = PCIE_USERCLK1_FREQ ) generate
---------- USERCLK2 same as USERCLK1 -------------------
    userclk2_1 <= userclk1_1;
end generate;

g12: if not ((not ((PCIE_GEN1_MODE = 1) and (PCIE_USERCLK2_FREQ = 3 ))) and (PCIE_USERCLK2_FREQ = PCIE_USERCLK1_FREQ )) generate
    usrclk2_i1: BUFG 
    port map
    (
        I                       =>   userclk2,
        O                       =>   userclk2_1
    );
end generate;



---------- Generate OOBCLK Buffer --------------------------------------------
g13: if (PCIE_OOBCLK_MODE = 2) generate 
    oobclk_i1: BUFG
    port map
    (
        I                   =>      oobclk,
        O                   =>      CLK_OOBCLK
    );
end generate;

g14: if (PCIE_OOBCLK_MODE /= 2) generate 
    CLK_OOBCLK <= pclk;
end generate;


--Disabled Second Stage Buffers
pclk         <= pclk_1;
CLK_RXUSRCLK <= pclk_1;
CLK_USERCLK1 <= userclk1_1;
CLK_USERCLK2 <= userclk2_1;
 
---------- Select PCLK -------------------------------------------------------
process (pclk, CLK_RST_N)
begin
    if(CLK_RST_N = '0') then
        pclk_sel <= '0';
        pclk_sel_slave <= '0';
    
    elsif(rising_edge(pclk)) then
        if (pclk_sel_reg2 = x"FF") then
            pclk_sel <= '1';
        elsif (pclk_sel_reg2 = x"00") then
            pclk_sel <= '0';
        else
            pclk_sel <= pclk_sel;
        end if;
        
        if (pclk_sel_slave_reg2 = x"FF") then
            pclk_sel_slave <= '1';
        elsif (pclk_sel_slave_reg2 = x"00") then
            pclk_sel_slave <= '0';
        else
            pclk_sel_slave <= pclk_sel_slave;
        end if;
    end if;
end process;

---------- PIPE Clock Output -------------------------------------------------
CLK_PCLK      <= pclk;
CLK_MMCM_LOCK <= mmcm_lock;


end architecture;




