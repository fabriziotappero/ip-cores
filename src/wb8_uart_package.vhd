--
-- Package for UART testing
--
-- Author:  Federico Aglietti, www.ipdesign.eu
-- Version: 2.0
-- Date:    30.08.2009
-- WishBone 8-bit bus compliant
--
-- Author:  Sebastian Witt
-- Version: 1.0
-- Date:    31.01.2008
--
-- This code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the
-- Free Software  Foundation, Inc., 59 Temple Place, Suite 330,
-- Boston, MA  02111-1307  USA
--

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE std.textio.all;
USE work.txt_util.all;


package uart_package is
    constant CYCLE  : time := 30 ns;

    -- UART register addresses
    constant A_RBR  : std_logic_vector(2 downto 0) := "000";
    constant A_DLL  : std_logic_vector(2 downto 0) := "000";
    constant A_THR  : std_logic_vector(2 downto 0) := "000";
    constant A_DLM  : std_logic_vector(2 downto 0) := "001";
    constant A_IER  : std_logic_vector(2 downto 0) := "001";
    constant A_IIR  : std_logic_vector(2 downto 0) := "010";
    constant A_FCR  : std_logic_vector(2 downto 0) := "010";
    constant A_LCR  : std_logic_vector(2 downto 0) := "011";
    constant A_MCR  : std_logic_vector(2 downto 0) := "100";
    constant A_LSR  : std_logic_vector(2 downto 0) := "101";
    constant A_MSR  : std_logic_vector(2 downto 0) := "110";
    constant A_SCR  : std_logic_vector(2 downto 0) := "111";

    -- UART input interface
    type uart_in_t is record
        WB_CYC      : std_logic;
        WB_STB      : std_logic;
        WB_WE       : std_logic;
        WB_ADR      : std_logic_vector(31 downto 0);
        WB_DIN      : std_logic_vector(7 downto 0);
    end record;

    type uart_out_t is record
        WB_ACK      : std_logic;
        WB_DOUT     : std_logic_vector(7 downto 0);
    end record;

    -- Write to UART
    procedure uart_write (signal clk: in std_logic;
                          signal ui : out uart_in_t;
                          signal uo : in  uart_out_t;
                          addr      : in std_logic_vector (2 downto 0);
                          data      : in std_logic_vector (7 downto 0);
                          file log  : TEXT
                         );

    -- Read from UART
    procedure uart_read  (signal clk: in std_logic;
                          signal ui : out uart_in_t;
                          signal uo : in  uart_out_t;
                          addr      : in std_logic_vector(2 downto 0);
                          ret       : out std_logic_vector(7 downto 0);
                          file log  : TEXT
                         );

    -- Compare two std_logig_vectors (handles don't-care)
    function compare (d1 : std_logic_vector; d2 : std_logic_vector) return boolean;

end uart_package;

package body uart_package is
    -- Write to UART
    procedure uart_write (signal clk: in std_logic;signal ui: out uart_in_t;signal uo: in  uart_out_t;addr: in std_logic_vector (2 downto 0);data: in std_logic_vector (7 downto 0);file log: TEXT) is	  
    begin
        wait until CLK'event and CLK='1';
        print (log, "UART write: 0x" & hstr(addr) & " : 0x" & hstr(data));
--        wait for cycle;
        ui.WB_ADR  <= "00000000000000000000000000000"&addr;
        ui.WB_DIN  <= data;
        ui.WB_CYC  <= '1';
        ui.WB_STB  <= '1';
        ui.WB_WE   <= '1';
        wait until uo.WB_ACK'event and uo.WB_ACK='1';
        wait until CLK'event and CLK='1';
--        wait for cycle/2;
        ui.WB_WE   <= '0';
        ui.WB_CYC  <= '0';
        ui.WB_STB  <= '0';
        ui.WB_DIN <= (others => '0');
    end uart_write;

    -- Read from UART
    procedure uart_read(signal clk: in std_logic;signal ui : out uart_in_t;signal uo: in  uart_out_t;addr: in std_logic_vector(2 downto 0);ret: out std_logic_vector(7 downto 0);file log: TEXT) is
      variable data : std_logic_vector(7 downto 0);
    begin
        wait until CLK'event and CLK='1';
--        wait for cycle;
        ui.WB_ADR    <= "00000000000000000000000000000"&addr;
        ui.WB_CYC    <= '1';
        ui.WB_STB    <= '1';
        --wait until uo.WB_ACK'event and uo.WB_ACK='1';
        wait until CLK'event and CLK='1' and uo.WB_ACK='1';
	    data:= uo.WB_DOUT;
        print (log, "UART read:  0x" & hstr(addr) & " : 0x" & hstr(data));
        --wait for cycle/2;
        ui.WB_WE  <= '0';
        ui.WB_CYC <= '0';
        ui.WB_STB <= '0';
        ui.WB_DIN <= (others => '0');
        ret:= data;
    end uart_read;

    -- Compare two std_logig_vectors (handles don't-care)
    function compare (d1 : std_logic_vector; d2 : std_logic_vector) return boolean is
        variable i : natural;
    begin
        for i in d1'range loop
            if (not (d1(i)='-' or d2(i)='-')) then
                if (d1(i)/=d2(i)) then
                    return false;
                end if;
            end if;
        end loop;
        return true;
    end compare;

end uart_package;

