--------------------------------------------------------------------------------
-- Mycron® DDR2 SDRAM - MT46V32M16 – 8 Meg x 16 x 4 banks                     --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;
--
--library work;
--use work.iwb.all;
--use work.iddr.all;

entity tb_ddr is
end tb_ddr;

architecture tb of tb_ddr is

   component ddr is
     port (
       so_ack : out STD_LOGIC; 
       si_clk : in STD_LOGIC := 'X'; 
       SD_CK_N : out STD_LOGIC; 
       SD_CK_P : out STD_LOGIC; 
       si_rst : in STD_LOGIC := 'X'; 
       si_stb : in STD_LOGIC := 'X'; 
       clk0 : in STD_LOGIC := 'X'; 
       clk180 : in STD_LOGIC := 'X'; 
       SD_CKE : out STD_LOGIC; 
       si_we : in STD_LOGIC := 'X'; 
       clk90 : in STD_LOGIC := 'X'; 
       clk270 : in STD_LOGIC := 'X'; 
       SD_DQ : inout STD_LOGIC_VECTOR ( 15 downto 0 ); 
       SD_DQS : inout STD_LOGIC_VECTOR ( 1 downto 0 ); 
       SD_BA : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
       SD_DM : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
       SD_A : out STD_LOGIC_VECTOR ( 12 downto 0 ); 
       so_dat : out STD_LOGIC_VECTOR ( 31 downto 0 ); 
       SD_CMD : out STD_LOGIC_VECTOR ( 3 downto 0 ); 
       si_dat : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
       si_sel : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
       si_adr : in STD_LOGIC_VECTOR ( 31 downto 0 ) 
     );
   end component;

   component model_ddr
      port(
         Clk   : in    std_logic;
         Clk_n : in    std_logic;
         Cke   : in    std_logic;
         Cs_n  : in    std_logic;
         Ras_n : in    std_logic;
         Cas_n : in    std_logic;
         We_n  : in    std_logic;
         Ba    : in    std_logic_vector(1 downto 0);
         Addr  : in    std_logic_vector(12 downto 0);
         Dm    : in    std_logic_vector(1 downto 0);
         Dq    : inout std_logic_vector(15 downto 0);
         Dqs   : inout std_logic_vector(1 downto 0)
      );
   end component;

   signal so_dat : STD_LOGIC_VECTOR ( 31 downto 0 ); 
   signal so_ack : STD_LOGIC; 
   signal si_clk : STD_LOGIC; 
   signal si_rst : STD_LOGIC; 
   signal si_stb : STD_LOGIC; 
   signal si_we  : STD_LOGIC; 
   signal si_dat : STD_LOGIC_VECTOR ( 31 downto 0 ); 
   signal si_sel : STD_LOGIC_VECTOR ( 3 downto 0 ); 
   signal si_adr : STD_LOGIC_VECTOR ( 31 downto 0 );

   signal SD_CK_N  : std_logic;
   signal SD_CK_P  : std_logic;
   signal SD_CKE   : std_logic;     
   signal SD_BA    : std_logic_vector(1 downto 0);
   signal SD_A     : std_logic_vector(12 downto 0);        
   signal SD_CMD   : std_logic_vector(3 downto 0);      
   signal SD_DM    : std_logic_vector(1 downto 0);
   signal SD_DQS   : std_logic_vector(1 downto 0);
   signal SD_DQ    : std_logic_vector(15 downto 0);

   --constant clk_period : time := 7.5 ns; 
    constant clk_period : time := 25.0 ns;
    
    signal clk0   : std_logic;
    signal clk90  : std_logic;
    signal clk180 : std_logic;
    signal clk270 : std_logic;
begin

   clk000 : process
   begin
      clk0 <= '0';
      clk90 <= '0';
      wait for clk_period / 4;
      clk0 <= '1';
      clk90 <= '0';
      wait for clk_period / 4; 
      clk0 <= '1';
      clk90 <= '1';
      wait for clk_period / 4; 
      clk0 <= '0';
      clk90 <= '1';   
      wait for clk_period / 4;       
   end process;
   
   clk180 <= not clk0;
   clk270 <= not clk90;
   
--   uut : ddr
--      port map(
--         si       => si,
--         so       => so,
--         clk0     => clk0,
--         clk90    => clk90,
--         clk180   => clk180,
--         clk270   => clk270,
--      -- Non Wishbone Signals
--         SD_CK_N  => SD_CK_N,
--         SD_CK_P  => SD_CK_P,
--         SD_CKE   => SD_CKE,
--         SD_BA    => SD_BA,
--         SD_A     => SD_A,      
--         SD_CMD   => SD_CMD,
--         SD_DM    => SD_DM,
--         SD_DQS   => SD_DQS,
--         SD_DQ    => SD_DQ
--      );


      
uut : ddr
   port map(
      so_ack  => so_ack,
      si_clk  => si_clk,
      SD_CK_N => SD_CK_N,
      SD_CK_P => SD_CK_P, 
      si_rst  => si_rst,
      si_stb  => si_stb,
      clk0    => clk0,
      clk180  => clk180,
      SD_CKE  => SD_CKE, 
      si_we   => si_we,
      clk90   => clk90, 
      clk270  => clk270,
      SD_DQ   => SD_DQ, 
      SD_DQS  => SD_DQS, 
      SD_BA   => SD_BA,
      SD_DM   => SD_DM,
      SD_A    => SD_A,
      so_dat  => so_dat, 
      SD_CMD  => SD_CMD,
      si_dat  => si_dat,
      si_sel  => si_sel,
      si_adr  => si_adr
   );


   model : model_ddr
      port map(
         Clk   => SD_CK_P,
         Clk_n => SD_CK_N,
         Cke   => SD_CKE,
         Cs_n  => SD_CMD(3),
         Ras_n => SD_CMD(2),
         Cas_n => SD_CMD(1),
         We_n  => SD_CMD(0),
         Ba    => SD_BA,
         Addr  => SD_A,
         Dm    => SD_DM,
         Dq    => SD_DQ,
         Dqs   => SD_DQS
      );  
  
   sti : process
   begin   
         si_rst <= '1';
      wait for 3*clk_period;
         si_rst <= '0'; 

   -----------------------------------------------------------------------------
   -- Same Bank, Same Rows                                                    --
   -----------------------------------------------------------------------------         
      -- Write 0x12xx5678 to 0x00000000  
      -- Row 0, Col 0,1      
         si_adr <= x"00000000";
         si_dat <= x"12345678";
         si_sel <= "1011";
         si_stb <= '1';
         si_we  <= '1';
      wait until so_ack = '1';
         si_stb <= '0';
         si_we  <= '0';
      wait until so_ack = '0';
      
      -- Write 0x8765xx21 to 0x00000004
      -- Row 0, Col 2,3 
         si_adr <= x"00000004";
         si_dat <= x"87654321";
         si_sel <= "1101";
         si_stb <= '1';
         si_we  <= '1';
      wait until so_ack = '1';
         si_stb <= '0';
         si_we  <= '0';
      wait until so_ack = '0';
      
      -- Read 0x8765xx21 from 0x00000004
         si_adr <= x"00000004";
         si_sel <= "1111";
         si_stb <= '1';
         si_we  <= '0';
      wait until so_ack = '1';
         si_stb <= '0';
         si_we  <= '0';
      wait until so_ack = '0';

      -- Read 0x12xx5678 from 0x00000000
         si_adr <= x"00000000";
         si_sel <= "1111";
         si_stb <= '1';
         si_we  <= '0';
      wait until so_ack = '1';
         si_stb <= '0';
         si_we  <= '0';
      wait until so_ack = '0';

  
   -----------------------------------------------------------------------------
   -- Same Bank, different Rows                                               --
   -----------------------------------------------------------------------------  
      -- Write 0x12xxxx78 to 0x00001000 
      -- Row 2, Col 0,1
          si_adr <= x"00001000";
          si_dat <= x"12345678";
          si_sel <= "1001";
          si_stb <= '1';
          si_we  <= '1';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
       wait until so_ack = '0';
      
      -- Write 0xxx6543xx to 0x00002004
      -- Row 4, Col 2,3
          si_adr <= x"00002004";
          si_dat <= x"87654321";
          si_sel <= "0110";
          si_stb <= '1';
          si_we  <= '1';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
       wait until so_ack = '0';

      -- Read 0x12xx5678 from 0x00001000
      -- Row 2, Col 0,1
          si_adr <= x"00001000";
          si_sel <= "1111";
          si_stb <= '1';
          si_we  <= '0';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
      
      -- Read 0x8765xx21 from 0x00002004
      -- Row 4, Col 2,3
          si_adr <= x"00002004";
          si_sel <= "1111";
          si_stb <= '1';
          si_we  <= '0';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
       wait until so_ack = '0';


   -----------------------------------------------------------------------------
   -- Different Banks, different Rows                                         --
   -----------------------------------------------------------------------------  
      -- Write 0x12xxxx78 to 0x00001000 
      -- Bank 1, Row 2, Col 0,1
          si_adr <= x"01001000";
          si_dat <= x"12345678";
          si_sel <= "1001";
          si_stb <= '1';
          si_we  <= '1';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
       wait until so_ack = '0';
      
      -- Write 0xxx6543xx to 0x00002004
      -- Bank 2, Row 4, Col 2,3
          si_adr <= x"02002004";
          si_dat <= x"87654321";
          si_sel <= "0110";
          si_stb <= '1';
          si_we  <= '1';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
       wait until so_ack = '0';

      -- Read 0x12xx5678 from 0x00001000
      -- Bank 1, Row 2, Col 0,1
          si_adr <= x"01001000";
          si_sel <= "1111";
          si_stb <= '1';
          si_we  <= '0';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
       wait until so_ack = '0';
      
      -- Read 0x8765xx21 from 0x00002004
      -- Bank 2, Row 4, Col 2,3
          si_adr <= x"02002004";
          si_sel <= "1111";
          si_stb <= '1';
          si_we  <= '0';
       wait until so_ack = '1';
          si_stb <= '0';
          si_we  <= '0';
       wait until so_ack = '0';
      
      wait;                            -- Important: no wait, no simulation.
   end process;   
end tb;