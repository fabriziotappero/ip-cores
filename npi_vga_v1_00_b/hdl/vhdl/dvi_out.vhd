library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity dvi_out is
Generic (
   C_FAMILY : string := "spartan3adsp");
    Port ( clk        : in  STD_LOGIC;
           ce         : in  STD_LOGIC;
           de_i       : in  STD_LOGIC;
           vsync_i    : in  STD_LOGIC;
           hsync_i    : in  STD_LOGIC;
           red_i      : in  STD_LOGIC_VECTOR (7 downto 0);
           green_i    : in  STD_LOGIC_VECTOR (7 downto 0);
           blue_i     : in  STD_LOGIC_VECTOR (7 downto 0);
           de         : out STD_LOGIC;
           vsync      : out STD_LOGIC;
           hsync      : out STD_LOGIC;
           dvi_data   : out STD_LOGIC_VECTOR (11 downto 0);
           dvi_clk_p  : out STD_LOGIC;
           dvi_clk_n  : out STD_LOGIC;
           reset_n    : out STD_LOGIC);
end dvi_out;

architecture Behavioral of dvi_out is
   
   signal d1        : STD_LOGIC_VECTOR (11 downto 0);
   signal d2        : STD_LOGIC_VECTOR (11 downto 0);
   signal d2_r      : STD_LOGIC_VECTOR (11 downto 0);

begin

   reset_n <= '1';
   
   d1    <= green_i(3 downto 0) & blue_i;
   d2    <= red_i & green_i(7 downto 4);
   
   OUT_Reg : process (clk)
   begin
      if clk'event and clk = '1' then
         de    <= de_i;
         vsync <= vsync_i;
         hsync <= hsync_i;
      end if;
   end process;

   V5_GEN : if (C_FAMILY /= "spartan3adsp") generate
      R1: for I in 0 to 11 generate
         ODDR_inst : ODDR
         generic map(
            DDR_CLK_EDGE => "SAME_EDGE")
         port map(
            Q  => dvi_data(I),
            C  => clk,
            CE => '1', 
            D1 => d1(I),
            D2 => d2(I),
            R  => '0',
            S  => '0');
      end generate R1;
  
      ODDR_dvi_clk_p : ODDR
      generic map(
         DDR_CLK_EDGE => "OPPOSITE_EDGE")
      port map (
         Q  => dvi_clk_p,
         C  => clk,
         CE => '1',
         D1 => '0',
         D2 => '1',
         R  => '0',
         S  => '0');
        
      ODDR_dvi_clk_n : ODDR
      generic map(
         DDR_CLK_EDGE => "OPPOSITE_EDGE")
      port map (
         Q  => dvi_clk_n,
         C  => clk,
         CE => '1',
         D1 => '1',
         D2 => '0',
         R  => '0',
         S  => '0');
   
   end generate V5_GEN;
   
   S3ADSP_GEN : if (C_FAMILY = "spartan3adsp") generate

      Delay_Reg : process (clk)
      begin
         if (clk'event and (clk = '1')) then
            d2_r <= d2;
         end if;
      end process;

      R1: for I in 0 to 11 generate
         ODDR_inst : ODDR2 
           generic map (
              DDR_ALIGNMENT => "NONE", -- "NONE", "C0" or "C1" 
              INIT => '1',             -- Sets initial state of Q  
              SRTYPE => "ASYNC")       -- Reset type
            port map (
               Q  => dvi_data(I),
               C0 => clk,
               C1 => not clk,
               CE => '1',
               D0 => d1(I), 
               D1 => d2_r(I), 
               R  => '0', 
               S  => '0');
      end generate R1;

      ODDR_dvi_clk_p : ODDR2 
         generic map (
            DDR_ALIGNMENT => "NONE", -- "NONE", "C0" or "C1" 
            INIT => '1',             -- Sets initial state of Q  
            SRTYPE => "ASYNC")       -- Reset type     
         port map (
            Q  => dvi_clk_p,
            C0 => clk,
            C1 => not clk,
            CE => '1',
            D0 => '0', 
            D1 => '1', 
            R  => '0', 
            S  => '0');

      ODDR_dvi_clk_n : ODDR2 
         generic map (
            DDR_ALIGNMENT => "NONE", -- "NONE", "C0" or "C1" 
            INIT => '1',             -- Sets initial state of Q  
            SRTYPE => "ASYNC")       -- Reset type
         port map (
            Q  => dvi_clk_n,
            C0 => clk,
            C1 => not clk,
            CE => '1',
            D0 => '1', 
            D1 => '0', 
            R  => '0', 
            S  => '0');
            
    end generate S3ADSP_GEN;
        
end Behavioral;

