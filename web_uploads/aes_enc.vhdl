--------------------------------------------------------------------------------
-- Organization:      www.opendsp.pl
-- Engineer:          Jerzy Gbur
--
-- Create Date:    2006-05-15 20:05:12
-- Design Name:    AES_128_192_256
-- Module Name:    aes
-- Project Name:
-- Target Device:
-- Tool versions:
-- Description:
--            State Table index
--            ---------------------
--            |  0 |  4 |  8 | 12 |
--            ---------------------
--            |  1 |  5 |  9 | 13 |
--            ---------------------
--            |  2 |  6 | 10 | 14 |
--            ---------------------
--            |  3 |  7 | 11 | 15 |
--            ---------------------
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
-- http://www.csrc.nist.gov/pki/CSOR/algorithms.html

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.aes_pkg.ALL;

entity aes_enc is
   generic
                  (
                  KEY_SIZE             :  in    integer range 0 to 2 := 0            -- 0-128; 1-192; 2-256
                  );
   port
                  (
                  DATA_I               :  in    std_logic_vector(7 downto 0);
                  VALID_DATA_I         :  in    std_logic;
                  KEY_I                :  in    std_logic_vector(7 downto 0);
                  VALID_KEY_I          :  in    std_logic;
                  RESET_I              :  in    std_logic;
                  CLK_I                :  in    std_logic;
                  CE_I                 :  in    std_logic;

                  KEY_READY_O          :  out   std_logic;

                  VALID_O              :  out   std_logic;
                  DATA_O               :  out   std_logic_vector(7 downto 0)
                  );

end aes_enc;

architecture Behavioral of aes_enc is

   signal         rom_FRV_SBOX         :  type_SBOX;

   signal         v_CNT4               :  std_logic_vector(1 downto 0);

   signal         STATE_TABLE1         :  type_STATE_TABLE;

   signal         t_STATE_RAM0         :  type_STATE_RAM;


   signal         v_KEY_COLUMN         :  std_logic_vector(31 downto 0);
   signal         v_DATA_COLUMN        :  std_logic_vector(31 downto 0);


   signal         FF_VALID_DATA        :  std_logic;
   signal         v_KEY_NUMB           :  std_logic_vector(5 downto 0);

   signal         v_C                  :  std_logic_vector(15 downto 0);

   signal         i_MAX_ROUND          :  integer range 0 to 14;
   signal         i_ROUND              :  integer range 0 to 14;

   signal         SRAM_WREN0           :  std_logic;

   signal         GET_KEY              :  std_logic;
   signal         FF_GET_KEY           :  std_logic;

   signal         CALCULATION          :  std_logic;
   signal         LAST_ROUND           :  std_logic;
   signal         i_RAM_ADDR_RD0       :  integer range 0 to 3;
   signal         i_RAM_ADDR_WR0       :  integer range 0 to 3;
   signal         v_RAM_OUT0           :  std_logic_vector(31 downto 0);
   signal         v_RAM_IN0            :  std_logic_vector(31 downto 0);
   signal         v_CALCULATION_CNTR   :  std_logic_vector(7 downto 0);

begin

i_MAX_ROUND <= 8     when  KEY_SIZE = 0 else
               10    when  KEY_SIZE = 1 else
               12    when  KEY_SIZE = 2 else
               8;

--****************************************************************************--
--* Key production                                                           *--
--****************************************************************************--

KEXP0:
   key_expansion
      GENERIC MAP
                  (
                  KEY_SIZE             => KEY_SIZE
                  )
      PORT MAP    (
                  KEY_I                => KEY_I,
                  VALID_KEY_I          => VALID_KEY_I,

                  CLK_I                => CLK_I,
                  RESET_I              => RESET_I,
                  CE_I                 => CE_I,

                  DONE_O               => KEY_READY_O,
                  GET_KEY_I            => GET_KEY,
                  KEY_NUMB_I           => v_KEY_NUMB,
                  KEY_EXP_O            => v_KEY_COLUMN
                  );

--****************************************************************************--
--* Incomming data                                                           *--
--****************************************************************************--

P0001:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if VALID_DATA_I = '1' then
            if v_CNT4 = "00" then
               v_DATA_COLUMN(7 downto 0) <= DATA_I;
            elsif v_CNT4 = "01" then
               v_DATA_COLUMN(15 downto 8) <= DATA_I;
            elsif v_CNT4 = "10" then
               v_DATA_COLUMN(23 downto 16) <= DATA_I;
            elsif v_CNT4 = "11" then
               v_DATA_COLUMN(31 downto 24) <= DATA_I;
            end if;
         end if;
      end if;
   end process;

P0002:
   process (CLK_I)
   begin
      if rising_edge(CLK_I) then
         if CE_I = '1' then
            if VALID_DATA_I = '1' then
               v_CNT4 <= v_CNT4 + 1;
            else
               v_CNT4 <= "00";
            end if;
         end if;
      end if;
   end process;

--****************************************************************************--
--* Get Key                                                                  *--
--****************************************************************************--

P0003:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if VALID_DATA_I = '1' and v_CNT4 = "10" then
            GET_KEY <= '1';
         elsif v_CALCULATION_CNTR = x"04" or v_CALCULATION_CNTR = x"05" or v_CALCULATION_CNTR = x"06" or v_CALCULATION_CNTR = x"07" then
            GET_KEY <= '1';
         else
            GET_KEY <= '0';
         end if;
      end if;
   end process;

--****************************************************************************--
--* Address for 32bit words of KEY                                           *--
--****************************************************************************--

P0004:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if RESET_I = '1' then
            v_KEY_NUMB <= (others => '0');
         elsif CE_I = '1' then
            if VALID_DATA_I = '1' and FF_VALID_DATA = '0' then
               v_KEY_NUMB <= (others => '0');
            elsif GET_KEY = '1' then
               v_KEY_NUMB <= v_KEY_NUMB + 1;
            end if;
         end if;
      end if;
   end process;


--****************************************************************************--
--* Rom - forward TABLE                                                      *--
--****************************************************************************--

rom_FRV_SBOX <= c_SBOX_FRV;

--****************************************************************************--
--* State RAM                                                                *--
--****************************************************************************--
ST_RAM0:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         -- WRITTING ADDERSS
         if RESET_I = '1' then
            i_RAM_ADDR_WR0 <= 0;
            i_RAM_ADDR_RD0 <= 0;
         elsif CE_I = '1' then
            if VALID_DATA_I = '1' and FF_VALID_DATA = '0' then
               i_RAM_ADDR_WR0 <= 0;
            elsif SRAM_WREN0 = '1' then
               if i_RAM_ADDR_WR0 = 3 then
                  i_RAM_ADDR_WR0 <= 0;
               else
                  i_RAM_ADDR_WR0 <=  i_RAM_ADDR_WR0 + 1;
               end if;
            end if;
         end if;
         -- RAM
         if CE_I = '1' then
            if SRAM_WREN0 = '1' then
               t_STATE_RAM0(i_RAM_ADDR_WR0) <= v_RAM_IN0;
            end if;
            v_RAM_OUT0 <=  t_STATE_RAM0(i_RAM_ADDR_RD0);
         end if;

         if CE_I = '1' then
            FF_GET_KEY     <= GET_KEY;
            SRAM_WREN0     <= FF_GET_KEY;
         end if;
         -- READING ADDRESS
         if CE_I = '1' then
            if v_CALCULATION_CNTR = x"01" or v_CALCULATION_CNTR = x"02" or v_CALCULATION_CNTR = x"03" then
               i_RAM_ADDR_RD0 <= i_RAM_ADDR_RD0 + 1;
            elsif v_CALCULATION_CNTR = x"00" then
               i_RAM_ADDR_RD0 <= 0;
            end if;
         end if;

      end if;
   end process;

--****************************************************************************--
--* v_RAM_IN0                                                                *--
--****************************************************************************--

P0005:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if RESET_I = '1' then
            v_RAM_IN0 <= (others => '0');
         elsif CE_I = '1' then
            FF_VALID_DATA <= VALID_DATA_I;
            if FF_VALID_DATA = '1' and v_CNT4 = "00" then
               v_RAM_IN0 <= v_KEY_COLUMN xor v_DATA_COLUMN;
            elsif LAST_ROUND = '0' then

               if v_CALCULATION_CNTR = x"06" then
                  v_RAM_IN0(7 downto 0)   <= v_KEY_COLUMN(7 downto 0)   xor (STATE_TABLE1(0)(6 downto 0) & "0")                         xor ((STATE_TABLE1(1)(6 downto 0) & "0") xor STATE_TABLE1(1))  xor STATE_TABLE1(2)                                               xor STATE_TABLE1(3)                                               xor ("000" & v_C(0) & v_C(0) & "0" & v_C(0) & v_C(0));
                  v_RAM_IN0(15 downto 8)  <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(0)                                             xor (STATE_TABLE1(1)(6 downto 0) & "0")                        xor ((STATE_TABLE1(2)(6 downto 0) & "0") xor STATE_TABLE1(2))     xor STATE_TABLE1(3)                                               xor ("000" & v_C(1) & v_C(1) & "0" & v_C(1) & v_C(1));
                  v_RAM_IN0(23 downto 16) <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(0)                                             xor STATE_TABLE1(1)                                            xor (STATE_TABLE1(2)(6 downto 0) & "0")                           xor ((STATE_TABLE1(3)(6 downto 0) & "0") xor STATE_TABLE1(3))     xor ("000" & v_C(2) & v_C(2) & "0" & v_C(2) & v_C(2));
                  v_RAM_IN0(31 downto 24) <= v_KEY_COLUMN(31 downto 24) xor ((STATE_TABLE1(0)(6 downto 0) & "0") xor STATE_TABLE1(0))   xor STATE_TABLE1(1)                                            xor STATE_TABLE1(2)                                               xor (STATE_TABLE1(3)(6 downto 0) & "0")                           xor ("000" & v_C(3) & v_C(3) & "0" & v_C(3) & v_C(3));
               elsif v_CALCULATION_CNTR = x"07" then
                  v_RAM_IN0(7 downto 0)   <= v_KEY_COLUMN(7 downto 0)   xor (STATE_TABLE1(4)(6 downto 0) & "0")                         xor ((STATE_TABLE1(5)(6 downto 0) & "0") xor STATE_TABLE1(5))  xor STATE_TABLE1(6)                                               xor STATE_TABLE1(7)                                               xor ("000" & v_C(4) & v_C(4) & "0" & v_C(4) & v_C(4));
                  v_RAM_IN0(15 downto 8)  <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(4)                                             xor (STATE_TABLE1(5)(6 downto 0) & "0")                        xor ((STATE_TABLE1(6)(6 downto 0) & "0") xor STATE_TABLE1(6))     xor STATE_TABLE1(7)                                               xor ("000" & v_C(5) & v_C(5) & "0" & v_C(5) & v_C(5));
                  v_RAM_IN0(23 downto 16) <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(4)                                             xor STATE_TABLE1(5)                                            xor (STATE_TABLE1(6)(6 downto 0) & "0")                           xor ((STATE_TABLE1(7)(6 downto 0) & "0") xor STATE_TABLE1(7))     xor ("000" & v_C(6) & v_C(6) & "0" & v_C(6) & v_C(6));
                  v_RAM_IN0(31 downto 24) <= v_KEY_COLUMN(31 downto 24) xor ((STATE_TABLE1(4)(6 downto 0) & "0") xor STATE_TABLE1(4))   xor STATE_TABLE1(5)                                            xor STATE_TABLE1(6)                                               xor (STATE_TABLE1(7)(6 downto 0) & "0")                           xor ("000" & v_C(7) & v_C(7) & "0" & v_C(7) & v_C(7));
               elsif v_CALCULATION_CNTR = x"08" then
                  v_RAM_IN0(7 downto 0)   <= v_KEY_COLUMN(7 downto 0)   xor (STATE_TABLE1(8)(6 downto 0) & "0")                         xor ((STATE_TABLE1(9)(6 downto 0) & "0") xor STATE_TABLE1(9))  xor STATE_TABLE1(10)                                              xor STATE_TABLE1(11)                                              xor ("000" & v_C(8) & v_C(8) & "0" & v_C(8) & v_C(8));
                  v_RAM_IN0(15 downto 8)  <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(8)                                             xor (STATE_TABLE1(9)(6 downto 0) & "0")                        xor ((STATE_TABLE1(10)(6 downto 0) & "0") xor STATE_TABLE1(10))   xor STATE_TABLE1(11)                                              xor ("000" & v_C(9) & v_C(9) & "0" & v_C(9) & v_C(9));
                  v_RAM_IN0(23 downto 16) <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(8)                                             xor STATE_TABLE1(9)                                            xor (STATE_TABLE1(10)(6 downto 0) & "0")                          xor ((STATE_TABLE1(11)(6 downto 0) & "0") xor STATE_TABLE1(11))   xor ("000" & v_C(10) & v_C(10) & "0" & v_C(10) & v_C(10));
                  v_RAM_IN0(31 downto 24) <= v_KEY_COLUMN(31 downto 24) xor ((STATE_TABLE1(8)(6 downto 0) & "0") xor STATE_TABLE1(8))   xor STATE_TABLE1(9)                                            xor STATE_TABLE1(10)                                              xor (STATE_TABLE1(11)(6 downto 0) & "0")                          xor ("000" & v_C(11) & v_C(11) & "0" & v_C(11) & v_C(11));
               elsif v_CALCULATION_CNTR = x"09" then
                  v_RAM_IN0(7 downto 0)   <= v_KEY_COLUMN(7 downto 0)   xor (STATE_TABLE1(12)(6 downto 0) & "0")                        xor ((STATE_TABLE1(13)(6 downto 0) & "0") xor STATE_TABLE1(13))xor STATE_TABLE1(14)                                              xor STATE_TABLE1(15)                                              xor ("000" & v_C(12) & v_C(12) & "0" & v_C(12) & v_C(12));
                  v_RAM_IN0(15 downto 8)  <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(12)                                            xor (STATE_TABLE1(13)(6 downto 0) & "0")                       xor ((STATE_TABLE1(14)(6 downto 0) & "0") xor STATE_TABLE1(14))   xor STATE_TABLE1(15)                                              xor ("000" & v_C(13) & v_C(13) & "0" & v_C(13) & v_C(13));
                  v_RAM_IN0(23 downto 16) <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(12)                                            xor STATE_TABLE1(13)                                           xor (STATE_TABLE1(14)(6 downto 0) & "0")                          xor ((STATE_TABLE1(15)(6 downto 0) & "0") xor STATE_TABLE1(15))   xor ("000" & v_C(14) & v_C(14) & "0" & v_C(14) & v_C(14));
                  v_RAM_IN0(31 downto 24) <= v_KEY_COLUMN(31 downto 24) xor ((STATE_TABLE1(12)(6 downto 0) & "0") xor STATE_TABLE1(12)) xor STATE_TABLE1(13)                                           xor STATE_TABLE1(14)                                              xor (STATE_TABLE1(15)(6 downto 0) & "0")                          xor ("000" & v_C(15) & v_C(15) & "0" & v_C(15) & v_C(15));
               end if;

            end if;
         end if;
      end if;
   end process;

v_C(0)   <=  STATE_TABLE1(0)(7) xor STATE_TABLE1(1)(7);
v_C(1)   <=  STATE_TABLE1(1)(7) xor STATE_TABLE1(2)(7);
v_C(2)   <=  STATE_TABLE1(2)(7) xor STATE_TABLE1(3)(7);
v_C(3)   <=  STATE_TABLE1(3)(7) xor STATE_TABLE1(0)(7);
v_C(4)   <=  STATE_TABLE1(4)(7) xor STATE_TABLE1(5)(7);
v_C(5)   <=  STATE_TABLE1(5)(7) xor STATE_TABLE1(6)(7);
v_C(6)   <=  STATE_TABLE1(6)(7) xor STATE_TABLE1(7)(7);
v_C(7)   <=  STATE_TABLE1(7)(7) xor STATE_TABLE1(4)(7);
v_C(8)   <=  STATE_TABLE1(8)(7) xor STATE_TABLE1(9)(7);
v_C(9)   <=  STATE_TABLE1(9)(7) xor STATE_TABLE1(10)(7);
v_C(10)  <=  STATE_TABLE1(10)(7) xor STATE_TABLE1(11)(7);
v_C(11)  <=  STATE_TABLE1(11)(7) xor STATE_TABLE1(8)(7);
v_C(12)  <=  STATE_TABLE1(12)(7) xor STATE_TABLE1(13)(7);
v_C(13)  <=  STATE_TABLE1(13)(7) xor STATE_TABLE1(14)(7);
v_C(14)  <=  STATE_TABLE1(14)(7) xor STATE_TABLE1(15)(7);
v_C(15)  <=  STATE_TABLE1(15)(7) xor STATE_TABLE1(12)(7);



--****************************************************************************--
--* CALCULATION                                                              *--
--****************************************************************************--

P0006:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if RESET_I = '1' then
            CALCULATION <= '0';
         elsif CE_I = '1' then

            if FF_VALID_DATA = '1' and VALID_DATA_I = '0' then
               CALCULATION <= '1';
            elsif LAST_ROUND = '1' and v_CALCULATION_CNTR = x"16" then
               CALCULATION <= '0';
            end if;

         end if;
      end if;
   end process;

P0007:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if RESET_I = '1' then
            v_CALCULATION_CNTR <= (others => '0');
            LAST_ROUND <= '0';
            i_ROUND <= 0;
         elsif CE_I = '1' then
            if CALCULATION = '1' then
               if v_CALCULATION_CNTR = x"09" and LAST_ROUND = '0' then
                  v_CALCULATION_CNTR <= (others => '0');
                  i_ROUND <= i_ROUND + 1;

                  if i_ROUND = i_MAX_ROUND then
                     LAST_ROUND <= '1';
                  end if;
               elsif v_CALCULATION_CNTR = x"16" and LAST_ROUND = '1' then
                  v_CALCULATION_CNTR <= (others => '0');
                  i_ROUND <= i_ROUND + 1;

               else
                  v_CALCULATION_CNTR <= v_CALCULATION_CNTR + 1;
               end if;
            else
               v_CALCULATION_CNTR <= (others => '0');
               i_ROUND <= 0;
               LAST_ROUND <= '0';
            end if;
         end if;
      end if;
   end process;

--****************************************************************************--
--* STATE_TABLE1                                                             *--
--****************************************************************************--

P0008:
   process (CLK_I)
   begin
      if rising_edge(CLK_I) then
         if v_CALCULATION_CNTR = x"02" then
            STATE_TABLE1(0)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(7 downto 0)));
            STATE_TABLE1(13) <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(15 downto 8)));
            STATE_TABLE1(10) <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(23 downto 16)));
            STATE_TABLE1(7)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(31 downto 24)));
         elsif v_CALCULATION_CNTR = x"03" then
            STATE_TABLE1(4)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(7 downto 0)));
            STATE_TABLE1(1)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(15 downto 8)));
            STATE_TABLE1(14) <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(23 downto 16)));
            STATE_TABLE1(11) <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(31 downto 24)));
         elsif v_CALCULATION_CNTR = x"04" then
            STATE_TABLE1(8)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(7 downto 0)));
            STATE_TABLE1(5)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(15 downto 8)));
            STATE_TABLE1(2)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(23 downto 16)));
            STATE_TABLE1(15) <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(31 downto 24)));
         elsif v_CALCULATION_CNTR = x"05" then
            STATE_TABLE1(12) <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(7 downto 0)));
            STATE_TABLE1(9)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(15 downto 8)));
            STATE_TABLE1(6)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(23 downto 16)));
            STATE_TABLE1(3)  <= rom_FRV_SBOX(conv_integer(v_RAM_OUT0(31 downto 24)));
         end if;

         if LAST_ROUND = '1' then

            if v_CALCULATION_CNTR = x"06" then

               STATE_TABLE1(0)   <= v_KEY_COLUMN(7 downto 0)   xor STATE_TABLE1(0);
               STATE_TABLE1(1)   <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(1);
               STATE_TABLE1(2)   <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(2);
               STATE_TABLE1(3)   <= v_KEY_COLUMN(31 downto 24) xor STATE_TABLE1(3);
            elsif v_CALCULATION_CNTR = x"07" then
               DATA_O   <= STATE_TABLE1(0);
               VALID_O  <= '1';

               STATE_TABLE1(4)   <= v_KEY_COLUMN(7 downto 0)   xor STATE_TABLE1(4);
               STATE_TABLE1(5)   <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(5);
               STATE_TABLE1(6)   <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(6);
               STATE_TABLE1(7)   <= v_KEY_COLUMN(31 downto 24) xor STATE_TABLE1(7);
            elsif v_CALCULATION_CNTR = x"08" then
               DATA_O   <= STATE_TABLE1(1);
               VALID_O  <= '1';

               STATE_TABLE1(8)   <= v_KEY_COLUMN(7 downto 0)   xor STATE_TABLE1(8);
               STATE_TABLE1(9)   <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(9);
               STATE_TABLE1(10)  <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(10);
               STATE_TABLE1(11)  <= v_KEY_COLUMN(31 downto 24) xor STATE_TABLE1(11);
            elsif v_CALCULATION_CNTR = x"09" then
               DATA_O   <= STATE_TABLE1(2);
               VALID_O  <= '1';

               STATE_TABLE1(12)  <= v_KEY_COLUMN(7 downto 0)   xor STATE_TABLE1(12);
               STATE_TABLE1(13)  <= v_KEY_COLUMN(15 downto 8)  xor STATE_TABLE1(13);
               STATE_TABLE1(14)  <= v_KEY_COLUMN(23 downto 16) xor STATE_TABLE1(14);
               STATE_TABLE1(15)  <= v_KEY_COLUMN(31 downto 24) xor STATE_TABLE1(15);
            elsif v_CALCULATION_CNTR = x"0A" then
               DATA_O   <= STATE_TABLE1(3);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"0B" then
               DATA_O   <= STATE_TABLE1(4);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"0C" then
               DATA_O   <= STATE_TABLE1(5);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"0D" then
               DATA_O   <= STATE_TABLE1(6);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"0E" then
               DATA_O   <= STATE_TABLE1(7);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"0F" then
               DATA_O   <= STATE_TABLE1(8);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"10" then
               DATA_O   <= STATE_TABLE1(9);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"11" then
               DATA_O   <= STATE_TABLE1(10);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"12" then
               DATA_O   <= STATE_TABLE1(11);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"13" then
               DATA_O   <= STATE_TABLE1(12);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"14" then
               DATA_O   <= STATE_TABLE1(13);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"15" then
               DATA_O   <= STATE_TABLE1(14);
               VALID_O  <= '1';
            elsif v_CALCULATION_CNTR = x"16" then
               DATA_O   <= STATE_TABLE1(15);
               VALID_O  <= '1';
            else
               DATA_O   <= x"00";
               VALID_O  <= '0';
            end if;
         else
            VALID_O  <= '0';
         end if;

      end if;
   end process;





end Behavioral;

