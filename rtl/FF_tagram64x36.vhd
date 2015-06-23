----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    FF_TagRam64x36 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  16.01.2009
-- 
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.abb64Package.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FF_TagRam64x36 is
  port (
        wea      : in  STD_LOGIC;
        web      : in  STD_LOGIC;
        addra    : in  STD_LOGIC_VECTOR ( C_TAGRAM_AWIDTH-1 downto 0 ); 
        addrb    : in  STD_LOGIC_VECTOR ( C_TAGRAM_AWIDTH-1 downto 0 ); 
        douta    : out STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 ); 
        doutb    : out STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 ); 
        dina     : in  STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 ); 
        dinb     : in  STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 );
        clk      : in  STD_LOGIC
       );
end FF_TagRam64x36;

architecture STRUCTURE of FF_TagRam64x36 is

  TYPE     FF_RAM_Matrix is ARRAY (C_TAG_MAP_WIDTH-1 downto 0) 
                                   of std_logic_vector (C_TAGRAM_DWIDTH-1 downto 0);
  signal   FF_Reg          : FF_RAM_Matrix;

  signal   FF_Muxer_a      : STD_LOGIC_VECTOR ( C_TAG_MAP_WIDTH-1 downto 0 );
  signal   FF_Muxer_b      : STD_LOGIC_VECTOR ( C_TAG_MAP_WIDTH-1 downto 0 );
  -- 
  signal   wea_r1          : STD_LOGIC;
  signal   web_r1          : STD_LOGIC;
  signal   dina_r1         : STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 ); 
  signal   dinb_r1         : STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 );
  signal   douta_i         : STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 ); 
  signal   doutb_i         : STD_LOGIC_VECTOR ( C_TAGRAM_DWIDTH-1 downto 0 ); 



begin

   douta     <=  douta_i;
   doutb     <=  (OTHERS=>'0');   -- doutb_i;

   -- ---------------------------------------
   -- 
   Syn_Delay_Writes:
   process ( clk )
   begin
      if clk'event and clk = '1' then
         wea_r1  <= wea;
         web_r1  <= web;
         dina_r1 <= dina;
         dinb_r1 <= dinb;
      end if;
   end process;


   -- ---------------------------------------
   -- 
   FF_Address:
   process ( clk )
   begin
      if clk'event and clk = '1' then

         FOR k IN 0 TO C_TAG_MAP_WIDTH-1 LOOP

            if addra=CONV_STD_LOGIC_VECTOR(k, C_TAGRAM_AWIDTH)
               then
               FF_Muxer_a(k)   <= '1';
            else
               FF_Muxer_a(k)   <= '0';
            end if;

         END LOOP;

         FOR k IN 0 TO C_TAG_MAP_WIDTH-1 LOOP

            if addrb=CONV_STD_LOGIC_VECTOR(k, C_TAGRAM_AWIDTH)
               then
               FF_Muxer_b(k)   <= '1';
            else
               FF_Muxer_b(k)   <= '0';
            end if;

         END LOOP;

      end if;
   end process;


   -- ---------------------------------------
   -- 
   FF_Matrix_Write:
   process ( clk )
   begin
     if clk'event and clk = '1' then

       FOR k IN 0 TO C_TAG_MAP_WIDTH-1 LOOP

         if wea_r1='1' and web_r1='1' and FF_Muxer_a(k)='1' and FF_Muxer_b(k)='1' then
            FF_Reg(k)   <= dina_r1;
         elsif wea_r1='1' and FF_Muxer_a(k)='1' then
            FF_Reg(k)   <= dina_r1;
         elsif web_r1='1' and FF_Muxer_b(k)='1' then
            FF_Reg(k)   <= dinb_r1;
         else
            FF_Reg(k)   <= FF_Reg(k);
         end if;

       END LOOP;

     end if;
   end process;


   -- ---------------------------------------
   -- 
   FF_Matrix_Read:
   process ( clk )
   begin
     if clk'event and clk = '1' then

         case FF_Muxer_a is

            when X"0000000000000001" =>
              douta_i     <= FF_Reg(0);
            when X"0000000000000002" =>
              douta_i     <= FF_Reg(1);
            when X"0000000000000004" =>
              douta_i     <= FF_Reg(2);
            when X"0000000000000008" =>
              douta_i     <= FF_Reg(3);
            when X"0000000000000010" =>
              douta_i     <= FF_Reg(4);
            when X"0000000000000020" =>
              douta_i     <= FF_Reg(5);
            when X"0000000000000040" =>
              douta_i     <= FF_Reg(6);
            when X"0000000000000080" =>
              douta_i     <= FF_Reg(7);
            when X"0000000000000100" =>
              douta_i     <= FF_Reg(8);
            when X"0000000000000200" =>
              douta_i     <= FF_Reg(9);
            when X"0000000000000400" =>
              douta_i     <= FF_Reg(10);
            when X"0000000000000800" =>
              douta_i     <= FF_Reg(11);
            when X"0000000000001000" =>
              douta_i     <= FF_Reg(12);
            when X"0000000000002000" =>
              douta_i     <= FF_Reg(13);
            when X"0000000000004000" =>
              douta_i     <= FF_Reg(14);
            when X"0000000000008000" =>
              douta_i     <= FF_Reg(15);

            when X"0000000000010000" =>
              douta_i     <= FF_Reg(16);
            when X"0000000000020000" =>
              douta_i     <= FF_Reg(17);
            when X"0000000000040000" =>
              douta_i     <= FF_Reg(18);
            when X"0000000000080000" =>
              douta_i     <= FF_Reg(19);
            when X"0000000000100000" =>
              douta_i     <= FF_Reg(20);
            when X"0000000000200000" =>
              douta_i     <= FF_Reg(21);
            when X"0000000000400000" =>
              douta_i     <= FF_Reg(22);
            when X"0000000000800000" =>
              douta_i     <= FF_Reg(23);
            when X"0000000001000000" =>
              douta_i     <= FF_Reg(24);
            when X"0000000002000000" =>
              douta_i     <= FF_Reg(25);
            when X"0000000004000000" =>
              douta_i     <= FF_Reg(26);
            when X"0000000008000000" =>
              douta_i     <= FF_Reg(27);
            when X"0000000010000000" =>
              douta_i     <= FF_Reg(28);
            when X"0000000020000000" =>
              douta_i     <= FF_Reg(29);
            when X"0000000040000000" =>
              douta_i     <= FF_Reg(30);
            when X"0000000080000000" =>
              douta_i     <= FF_Reg(31);

            when X"0000000100000000" =>
              douta_i     <= FF_Reg(32);
            when X"0000000200000000" =>
              douta_i     <= FF_Reg(33);
            when X"0000000400000000" =>
              douta_i     <= FF_Reg(34);
            when X"0000000800000000" =>
              douta_i     <= FF_Reg(35);
            when X"0000001000000000" =>
              douta_i     <= FF_Reg(36);
            when X"0000002000000000" =>
              douta_i     <= FF_Reg(37);
            when X"0000004000000000" =>
              douta_i     <= FF_Reg(38);
            when X"0000008000000000" =>
              douta_i     <= FF_Reg(39);
            when X"0000010000000000" =>
              douta_i     <= FF_Reg(40);
            when X"0000020000000000" =>
              douta_i     <= FF_Reg(41);
            when X"0000040000000000" =>
              douta_i     <= FF_Reg(42);
            when X"0000080000000000" =>
              douta_i     <= FF_Reg(43);
            when X"0000100000000000" =>
              douta_i     <= FF_Reg(44);
            when X"0000200000000000" =>
              douta_i     <= FF_Reg(45);
            when X"0000400000000000" =>
              douta_i     <= FF_Reg(46);
            when X"0000800000000000" =>
              douta_i     <= FF_Reg(47);

            when X"0001000000000000" =>
              douta_i     <= FF_Reg(48);
            when X"0002000000000000" =>
              douta_i     <= FF_Reg(49);
            when X"0004000000000000" =>
              douta_i     <= FF_Reg(50);
            when X"0008000000000000" =>
              douta_i     <= FF_Reg(51);
            when X"0010000000000000" =>
              douta_i     <= FF_Reg(52);
            when X"0020000000000000" =>
              douta_i     <= FF_Reg(53);
            when X"0040000000000000" =>
              douta_i     <= FF_Reg(54);
            when X"0080000000000000" =>
              douta_i     <= FF_Reg(55);
            when X"0100000000000000" =>
              douta_i     <= FF_Reg(56);
            when X"0200000000000000" =>
              douta_i     <= FF_Reg(57);
            when X"0400000000000000" =>
              douta_i     <= FF_Reg(58);
            when X"0800000000000000" =>
              douta_i     <= FF_Reg(59);
            when X"1000000000000000" =>
              douta_i     <= FF_Reg(60);
            when X"2000000000000000" =>
              douta_i     <= FF_Reg(61);
            when X"4000000000000000" =>
              douta_i     <= FF_Reg(62);
--            when X"8000000000000000" =>
--              douta_i     <= FF_Reg(63);
            when OTHERS =>
              douta_i     <= FF_Reg(63);

         end case;

     end if;
   end process;


end architecture STRUCTURE;

