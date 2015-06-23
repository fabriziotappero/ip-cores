-------------------------------------------------------------------------------
-- Title      : PS/2 interface Testbench
-- Project    :
-------------------------------------------------------------------------------
-- File       : ps2.vhd
-- Author     : Daniel Quintero <danielqg@infonegocio.com>
-- Company    : Itoo Software
-- Created    : 2003-04-14
-- Last update: 2003-10-30
-- Platform   : VHDL'87
-------------------------------------------------------------------------------
-- Description: PS/2 mice model
-------------------------------------------------------------------------------
--  This code is distributed under the terms and conditions of the
--  GNU General Public License
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-04-14  1.0      daniel  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;

entity ps2mouse is
        port (
                PS2_clk  : inout std_logic;
                PS2_data : inout std_logic);
end ps2mouse;

architecture sim of ps2mouse is

        procedure PS2SendByte(byte             : in    std_logic_vector(7 downto 0);
                               signal PS2_clk  : inout std_logic;
                               signal PS2_data : inout std_logic) is
        begin
                --wait until (PS2_clk = 'H');
                for i in 0 to 10 loop
                        if i = 0 then
                                PS2_Data <= '0';
                        elsif i = 9 then
                                PS2_Data <= not (Byte(0) xor
                                                 Byte(1) xor
                                                 Byte(2) xor
                                                 Byte(3) xor
                                                 Byte(4) xor
                                                 Byte(5) xor
                                                 Byte(6) xor
                                                 Byte(7));
                        elsif i = 10 then
                                PS2_Data <= 'H';
                        else
                                if Byte(i - 1) = '1' then
                                        PS2_Data <= '1';
                                else

                                end if;
                        end if;
                        wait for 20 us;
                        PS2_Clk <= '0';
                        wait for 20 us;
                        PS2_Clk <= '1';
                end loop;
                PS2_Clk <= 'H';
        end;

        procedure PS2RecvByte(byte             : out   std_logic_vector(7 downto 0);
                               signal PS2_clk  : inout std_logic;
                               signal PS2_data : inout std_logic) is
                variable parity : std_logic;
                variable buf    : std_logic_vector(7 downto 0);
        begin
                PS2_Data <= 'H';
                for i in 0 to 10 loop
                        wait for 20 us;
                        PS2_Clk <= '0';
                        if i = 0 then
                                if PS2_data /= '0' then
                                        write(output, string'("Warning, not start bit from Host"));
                                end if;
                        elsif i = 9 then
                                parity := To_X01(PS2_data);
                        elsif i = 10 then
                                PS2_Data <= '0';  -- Ack
                        else
                                buf(i - 1) := To_X01(PS2_data);
                        end if;
                        wait for 20 us;
                        PS2_Clk <= '1';
                end loop;

                if parity /= not (buf(0) xor buf(1) xor buf(2) xor buf(3) xor
                                  buf(4) xor buf(5) xor buf(6) xor buf(7)) then
                        write(output, string'("Waring, parity check error in host data"));
                end if;
                Byte     := buf;
                PS2_Clk  <= 'H';
                PS2_Data <= 'H';
        end;

        procedure PS2Write(signal req, rw : out std_logic;
                            signal ack    : in  std_logic) is
        begin
                wait for 20 us;
                req <= '1';
                rw  <= '0';
                wait until ack = '1';
                req <= '0' after 10 ns;
                rw  <= '1' after 10 ns;
        end;


        function stdvec_to_str(inp : std_logic_vector) return string is
                variable temp : string(inp'left+1 downto 1) := (others => 'X');
        begin
                for i in inp'reverse_range loop
                        if (inp(i) = '1') then
                                temp(i+1) := '1';
                        elsif (inp(i) = '0') then
                                temp(i+1) := '0';
                        end if;
                end loop;
                return temp;
        end function stdvec_to_str;


        signal stop               : boolean                      := false;
        signal listen, read, send : boolean                      := false;
        signal clk                : std_logic                    := '0';
        signal rst                : std_logic;
        signal cmd_in             : std_logic_vector(7 downto 0) := (others => '0');

begin
        process
                variable data_in : std_logic_vector(7 downto 0) := (others => '0');
                variable cmd     : integer;
        begin
                --wait for 100 us;
                 -- Send BAT cycle successful, 0xAA
                --PS2SendByte("10101010", PS2_clk, PS2_data);
                -- Send PS/2 device ID, 0x00
                --PS2SendByte("00000000", PS2_clk, PS2_data);
                wait for 10 us;
		   listen <= true;
                wait;
        end process;

	process
                variable data_in : std_logic_vector(7 downto 0) := (others => '0');
                variable cmd     : integer;
	begin
                PS2_clk <= 'H';
                PS2_data <= 'H';
		wait on PS2_clk;
  		if PS2_clk = '0' then --and listen and not send then
			wait on PS2_clk;
                    PS2RecvByte(data_in, PS2_clk, PS2_data);
                    write(output, string'("PS2MOUSE - Received data from host : "));
                    write(output, stdvec_to_str(data_in));
			send <= true;
		elsif PS2_clk /= '0' and send then
			wait for 1 ms;
			PS2SendByte("00001000", PS2_clk, PS2_data);
			PS2SendByte("00000100", PS2_clk, PS2_data);
			PS2SendByte("00000101", PS2_clk, PS2_data);
                        wait;
		end if;
	end process;


end sim;
