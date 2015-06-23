--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2009                                --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : DIVIDER                                                      --
-- Design      : Divider using reciprocal table                               --
-- Author      : Michal Krepa                                                 --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- File        : R_DIVIDER.VHD                                                --
-- Created     : Wed 18-03-2009                                               --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
--------------------------------------------------------------------------------
   
--------------------------------------------------------------------------------
-- MAIN DIVIDER top level
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.All;
  use IEEE.NUMERIC_STD.all;

entity r_divider is
  port 
  (
       rst   : in  STD_LOGIC;
       clk   : in  STD_LOGIC;
       a     : in  STD_LOGIC_VECTOR(11 downto 0);     
       d     : in  STD_LOGIC_VECTOR(7 downto 0);     
       
       q     : out STD_LOGIC_VECTOR(11 downto 0)
  ) ;   
end r_divider ;

architecture rtl of r_divider is
  
  signal romr_datao    : std_logic_vector(15 downto 0);
  signal romr_addr     : std_logic_vector(7 downto 0);
  signal dividend      : signed(11 downto 0);
  signal dividend_d1   : unsigned(11 downto 0);
  signal reciprocal    : unsigned(15 downto 0);
  signal mult_out      : unsigned(27 downto 0);
  signal mult_out_s    : signed(11 downto 0);
  signal signbit       : std_logic;
  signal signbit_d1    : std_logic;
  signal signbit_d2    : std_logic;
  signal signbit_d3    : std_logic;
  signal round         : std_logic;
  
begin

  U_ROMR : entity work.ROMR
    generic map
    (
      ROMADDR_W    => 8,
      ROMDATA_W    => 16
    )
    port map
    (
      addr  => romr_addr,
      clk   => CLK,
      datao => romr_datao
    );
    
  romr_addr <= d;
  reciprocal <= unsigned(romr_datao);
    
 dividend <= signed(a);
 signbit <= dividend(dividend'high);

 rdiv : process(clk,rst)
 begin
   if rst = '1' then
     mult_out    <= (others => '0');
     mult_out_s  <= (others => '0');
     dividend_d1 <= (others => '0');
     q           <= (others => '0');
     signbit_d1  <= '0';
     signbit_d2  <= '0';
     signbit_d3  <= '0';
     round       <= '0';
   elsif clk = '1' and clk'event then
     signbit_d1  <= signbit;
     signbit_d2  <= signbit_d1;
     signbit_d3  <= signbit_d2;
     if signbit = '1' then
       dividend_d1 <= unsigned(0-dividend);
     else
       dividend_d1 <= unsigned(dividend);
     end if;

     mult_out <= dividend_d1 * reciprocal;
     
     if signbit_d2 = '0' then
       mult_out_s <= resize(signed(mult_out(27 downto 16)),mult_out_s'length);
     else
       mult_out_s <= resize(0-signed(mult_out(27 downto 16)),mult_out_s'length);  
     end if;
     round <= mult_out(15);
     
     if signbit_d3 = '0' then
       if round = '1' then
         q <= std_logic_vector(mult_out_s + 1);
       else
         q <= std_logic_vector(mult_out_s);
       end if;
     else
       if round = '1' then
         q <= std_logic_vector(mult_out_s - 1);
       else
         q <= std_logic_vector(mult_out_s);
       end if;
     end if;
   end if;
 end process;
 
end rtl;


