--------------------------------------------------------------------------------
-- Organization:      www.opendsp.pl
-- Engineer:          Jerzy Gbur
--
-- Create Date:    2006-05-13
-- Design Name:    aes
-- Module Name:    key_expansion
-- Project Name:   aes
-- Target Device:
-- Tool versions:
-- Description:
--              KEY_SIZE:      0 - 128
--                             1 - 192
--                             2 - 256
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.aes_pkg.ALL;

entity key_expansion is
   generic        (
                  KEY_SIZE             :  in    integer range 0 to 2 := 2
                  );
   port
                  (
                  KEY_I                :  in    std_logic_vector(7 downto 0);
                  VALID_KEY_I          :  in    std_logic;

                  CLK_I                :  in    std_logic;
                  RESET_I              :  in    std_logic;
                  CE_I                 :  in    std_logic;

                  DONE_O               :  out   std_logic;
                  GET_KEY_I            :  in    std_logic;
                  KEY_NUMB_I           :  in    std_logic_vector(5 downto 0);

                  KEY_EXP_O            :  out   std_logic_vector(31 downto 0)
                  );

end key_expansion;

architecture Behavioral of key_expansion is

   type           type_ROUND_TABLE     is array (0 to 63)  of std_logic_vector(31 downto 0);

   signal         KEY_EXPAN0           :  type_ROUND_TABLE;

   signal         t_FORWARD_TABLE      :  type_SBOX;

   signal         v_KEY32_IN           :  std_logic_vector(31 downto 0);

   signal         i_ROUND              :  integer range 0 to 13;
   signal         i_BYTE_CNTR4         :  integer range 0 to 3;

   signal         FF_VALID_KEY         :  std_logic;
   signal         v_KEY_COL_IN0        :  std_logic_vector(31 downto 0);
   signal         v_KEY_COL_OUT0       :  std_logic_vector(31 downto 0);
   signal         v_TEMP_VECTOR        :  std_logic_vector(31 downto 0);
   signal         i_FRW_ADD_RD0        :  integer range 0 to 255;
   signal         v_SUB_WORD           :  std_logic_vector(7 downto 0);

   signal         SRAM_WREN0           :  std_logic;
   signal         i_SRAM_ADDR_WR0      :  integer range 0 to 63;
   signal         i_SRAM_ADDR_RD0      :  integer range 0 to 63;
   signal         i_EXTERN_ADDRESS     :  integer range 0 to 63;
   signal         i_INTERN_ADDR_RD0    :  integer range 0 to 63;

   signal         v_CALCULATION_CNTR   :  std_logic_vector(7 downto 0);
   signal         START_CALCULATION    :  std_logic;
   signal         CALCULATION          :  std_logic;
   signal         FF_GET_KEY           :  std_logic;

begin

t_FORWARD_TABLE <= c_SBOX_FRV;

--****************************************************************************--
--* Packetization for 32bit words from input                                 *--
--****************************************************************************--
P0000:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if CE_I = '1' then
            FF_VALID_KEY <= VALID_KEY_I;

            if VALID_KEY_I = '0' then

               i_BYTE_CNTR4   <=  0;

            elsif VALID_KEY_I = '1' then

               if i_BYTE_CNTR4 = 0 then
                  v_KEY32_IN(7 downto 0) <= KEY_I;
               elsif i_BYTE_CNTR4 = 1 then
                  v_KEY32_IN(15 downto 8) <= KEY_I;
               elsif i_BYTE_CNTR4 = 2 then
                  v_KEY32_IN(23 downto 16) <= KEY_I;
               elsif i_BYTE_CNTR4 = 3 then
                  v_KEY32_IN(31 downto 24) <= KEY_I;
               end if;

               if i_BYTE_CNTR4 = 3 then
                  i_BYTE_CNTR4 <= 0;
               else
                  i_BYTE_CNTR4 <= i_BYTE_CNTR4 + 1;
               end if;

            end if;
         end if;

      end if;
   end process;

--****************************************************************************--
--* RAM for Key Expansion                                                    *--
--****************************************************************************--

SRAM0:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then

         if RESET_I = '1' then
            SRAM_WREN0 <= '0';
         elsif CE_I = '1' then
            if VALID_KEY_I = '1' and i_BYTE_CNTR4 = 3 then
               SRAM_WREN0 <= '1';
            elsif v_CALCULATION_CNTR = x"08" then
               SRAM_WREN0 <= '1';
            elsif v_CALCULATION_CNTR = x"09" then
               SRAM_WREN0 <= '1';
            elsif v_CALCULATION_CNTR = x"0A" then
               SRAM_WREN0 <= '1';
            elsif v_CALCULATION_CNTR = x"0B" then
               SRAM_WREN0 <= '1';
            elsif KEY_SIZE = 1 then
               if v_CALCULATION_CNTR = x"0C" then
                  SRAM_WREN0 <= '1';
               elsif v_CALCULATION_CNTR = x"0D" then
                  SRAM_WREN0 <= '1';
               else
                  SRAM_WREN0 <= '0';
               end if;
            elsif KEY_SIZE = 2 then
               if v_CALCULATION_CNTR = x"11" then
                  SRAM_WREN0 <= '1';
               elsif v_CALCULATION_CNTR = x"12" then
                  SRAM_WREN0 <= '1';
               elsif v_CALCULATION_CNTR = x"13" then
                  SRAM_WREN0 <= '1';
               elsif v_CALCULATION_CNTR = x"14" then
                  SRAM_WREN0 <= '1';
               else
                  SRAM_WREN0 <= '0';
               end if;
            else
               SRAM_WREN0 <= '0';
            end if;
         end if;

         -- RAM
         if CE_I = '1' then
            if SRAM_WREN0 = '1' then
               KEY_EXPAN0(i_SRAM_ADDR_WR0) <= v_KEY_COL_IN0;
            end if;
            v_KEY_COL_OUT0  <= KEY_EXPAN0(i_SRAM_ADDR_RD0);
         end if;

         -- Write address
         if RESET_I = '1' then
            i_SRAM_ADDR_WR0 <= 0;
         elsif CE_I = '1' then
            if FF_VALID_KEY = '0' and VALID_KEY_I = '1' then
               i_SRAM_ADDR_WR0 <= 0;
            elsif SRAM_WREN0 = '1' then
               i_SRAM_ADDR_WR0 <= i_SRAM_ADDR_WR0 + 1;
            end if;
         end if;

         -- Read address
         if RESET_I = '1' then
            i_INTERN_ADDR_RD0 <= 0;
         elsif CE_I = '1' then
            if FF_VALID_KEY = '0' and VALID_KEY_I = '1' then
               i_INTERN_ADDR_RD0 <= 0;
            elsif v_CALCULATION_CNTR = x"07" then
               i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
            elsif v_CALCULATION_CNTR = x"08" then
               i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
            elsif v_CALCULATION_CNTR = x"09" then
               i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
            elsif v_CALCULATION_CNTR = x"0A" then
               i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
            elsif KEY_SIZE = 1 then
               if v_CALCULATION_CNTR = x"0B" then
                  i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
               elsif v_CALCULATION_CNTR = x"0C" then
                  i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
               end if;
            elsif KEY_SIZE = 2 then
               if v_CALCULATION_CNTR = x"10" then
                  i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
               elsif v_CALCULATION_CNTR = x"11" then
                  i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
               elsif v_CALCULATION_CNTR = x"12" then
                  i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
               elsif v_CALCULATION_CNTR = x"13" then
                  i_INTERN_ADDR_RD0 <= i_INTERN_ADDR_RD0 + 1;
               end if;
            end if;
         end if;

         FF_GET_KEY <= GET_KEY_I;
      end if;
   end process;

i_EXTERN_ADDRESS <= conv_integer(KEY_NUMB_I);

i_SRAM_ADDR_RD0   <= i_INTERN_ADDR_RD0 when GET_KEY_I = '0' else i_EXTERN_ADDRESS;

KEY_EXP_O         <= v_KEY_COL_OUT0 when  FF_GET_KEY  = '1' else (others => '0');

--****************************************************************************--
--* ROM for Sub Word                                                         *--
--****************************************************************************--
i_FRW_ADD_RD0 <= conv_integer(v_TEMP_VECTOR(7 downto 0)) when v_CALCULATION_CNTR = x"02"   else
                 conv_integer(v_TEMP_VECTOR(15 downto 8)) when v_CALCULATION_CNTR = x"03"  else
                 conv_integer(v_TEMP_VECTOR(23 downto 16)) when v_CALCULATION_CNTR = x"04" else
                 conv_integer(v_TEMP_VECTOR(31 downto 24)) when v_CALCULATION_CNTR = x"05" else
                 conv_integer(v_TEMP_VECTOR(7 downto 0)) when v_CALCULATION_CNTR = x"0C" and KEY_SIZE = 2  else
                 conv_integer(v_TEMP_VECTOR(15 downto 8)) when v_CALCULATION_CNTR = x"0D" and KEY_SIZE = 2  else
                 conv_integer(v_TEMP_VECTOR(23 downto 16)) when v_CALCULATION_CNTR = x"0E" and KEY_SIZE = 2 else
                 conv_integer(v_TEMP_VECTOR(31 downto 24)) when v_CALCULATION_CNTR = x"0F" and KEY_SIZE = 2 else
                 0;



ROM0:
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         if CE_I = '1' then
            v_SUB_WORD  <= t_FORWARD_TABLE(i_FRW_ADD_RD0);
         end if;
      end if;
   end process;


--****************************************************************************--
--* v_KEY_COL_IN0                                                            *--
--****************************************************************************--


v_KEY_COL_IN0 <=  v_KEY32_IN     when FF_VALID_KEY = '1' and i_BYTE_CNTR4 = 0 else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"09" else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"0A" else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"0B" else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"0C" else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"0D" and KEY_SIZE = 1 else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"0E" and KEY_SIZE = 1 else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"12" and KEY_SIZE = 2 else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"13" and KEY_SIZE = 2 else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"14" and KEY_SIZE = 2 else
                  v_TEMP_VECTOR  when v_CALCULATION_CNTR = x"15" and KEY_SIZE = 2 else
                  (others => '0');

--****************************************************************************--
--* CALCULATION                                                              *--
--****************************************************************************--

P0002:
	process(CLK_I)
	begin
		if rising_edge(CLK_I) then
         if RESET_I = '1' then
            START_CALCULATION <= '0';
            CALCULATION <= '0';
            DONE_O <= '0';
         elsif CE_I = '1' then
            if FF_VALID_KEY = '1' and VALID_KEY_I = '0' then
               START_CALCULATION <= '1';
               CALCULATION <= '1';
               DONE_O <= '0';
            elsif i_ROUND = 10 and KEY_SIZE = 0 then
               DONE_O <= '1';
               CALCULATION <= '0';
            elsif i_ROUND = 8 and KEY_SIZE = 1 then
               DONE_O <= '1';
               CALCULATION <= '0';
            elsif i_ROUND = 7 and KEY_SIZE = 2 then
               DONE_O <= '1';
               CALCULATION <= '0';
            else
               START_CALCULATION <= '0';
            end if;
         end if;
		end if;
	end process;

P0003:
	process(CLK_I)
	begin
		if rising_edge(CLK_I) then
         if RESET_I = '1' then
            v_CALCULATION_CNTR <= (others => '0');
            i_ROUND <= 0;
         elsif CE_I = '1' then
            if START_CALCULATION = '1' then
               v_CALCULATION_CNTR <= (others => '0');
               i_ROUND <= 0;
            elsif v_CALCULATION_CNTR = x"0C" and KEY_SIZE = 0 then
               v_CALCULATION_CNTR <= (others => '0');
               i_ROUND <= i_ROUND + 1;
            elsif v_CALCULATION_CNTR = x"0E" and KEY_SIZE = 1 then
               v_CALCULATION_CNTR <= (others => '0');
               i_ROUND <= i_ROUND + 1;
            elsif v_CALCULATION_CNTR = x"15" and KEY_SIZE = 2 then
               v_CALCULATION_CNTR <= (others => '0');
               i_ROUND <= i_ROUND + 1;
            elsif CALCULATION = '1' then
               v_CALCULATION_CNTR <= v_CALCULATION_CNTR + 1;
            else
               v_CALCULATION_CNTR <= (others => '0');
            end if;
         end if;
		end if;
	end process;
--****************************************************************************--
--* v_TEMP_VECTOR                                                            *--
--****************************************************************************--
P0:
	process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if RESET_I = '1' then
            v_TEMP_VECTOR <= (others => '0');
         elsif CE_I = '1' then
            if START_CALCULATION = '1' then
               v_TEMP_VECTOR <= v_KEY32_IN;
            elsif v_CALCULATION_CNTR = x"03" then
               v_TEMP_VECTOR(7 downto 0)     <= v_SUB_WORD;
            elsif v_CALCULATION_CNTR = x"04" then
               v_TEMP_VECTOR(15 downto 8)    <= v_SUB_WORD;
            elsif v_CALCULATION_CNTR = x"05" then
               v_TEMP_VECTOR(23 downto 16)   <= v_SUB_WORD;
            elsif v_CALCULATION_CNTR = x"06" then
               v_TEMP_VECTOR(31 downto 24)   <= v_SUB_WORD;

            elsif v_CALCULATION_CNTR = x"07" then
               v_TEMP_VECTOR   <= (v_TEMP_VECTOR(7 downto 0) & v_TEMP_VECTOR(31 downto 8)) xor (x"000000" & c_RCON(i_ROUND));
            elsif v_CALCULATION_CNTR = x"08" then
               v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
            elsif v_CALCULATION_CNTR = x"09" then
               v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
            elsif v_CALCULATION_CNTR = x"0A" then
               v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
            elsif v_CALCULATION_CNTR = x"0B" then
               v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
            elsif KEY_SIZE = 1 then
               if v_CALCULATION_CNTR = x"0C" then
                  v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
               elsif v_CALCULATION_CNTR = x"0D" then
                  v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
               end if;
            elsif KEY_SIZE = 2 then

               if v_CALCULATION_CNTR = x"0D" then
                  v_TEMP_VECTOR(7 downto 0)     <= v_SUB_WORD;
               elsif v_CALCULATION_CNTR = x"0E" then
                  v_TEMP_VECTOR(15 downto 8)    <= v_SUB_WORD;
               elsif v_CALCULATION_CNTR = x"0F" then
                  v_TEMP_VECTOR(23 downto 16)   <= v_SUB_WORD;
               elsif v_CALCULATION_CNTR = x"10" then
                  v_TEMP_VECTOR(31 downto 24)   <= v_SUB_WORD;

               elsif v_CALCULATION_CNTR = x"11" then
                  v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
               elsif v_CALCULATION_CNTR = x"12" then
                  v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
               elsif v_CALCULATION_CNTR = x"13" then
                  v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
               elsif v_CALCULATION_CNTR = x"14" then
                  v_TEMP_VECTOR   <= v_TEMP_VECTOR xor v_KEY_COL_OUT0;
               end if;

            end if;
         end if;
		end if;
	end process;

end Behavioral;
