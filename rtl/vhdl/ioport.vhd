--===========================================================================--
--
--  S Y N T H E Z I A B L E    ioport  Quad 8 Bit I/O port
--
--  This core adheres to the GNU public license  
--
-- File name      : ioport.vhd
--
-- Purpose        : Implements 4 x 8 bit bi-directional I/O ports
--                  
-- Dependencies   : ieee.Std_Logic_1164
--                  ieee.std_logic_unsigned
--
-- Uses           : None
--
-- Author         : John E. Kent      
--
--===========================================================================----
--
-- Revision History:
--===========================================================================--
--
-- Initial version John Kent - 6 Sept 2002
--	Cleaned up 30th May 2004
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ioport is
	port (	
	 clk       : in  std_logic;
    rst       : in  std_logic;
    cs        : in  std_logic;
    rw        : in  std_logic;
    addr      : in  std_logic_vector(2 downto 0);
    data_in   : in  std_logic_vector(7 downto 0);
	 data_out  : out std_logic_vector(7 downto 0);
	 porta_io  : inout std_logic_vector(7 downto 0);
	 portb_io  : inout std_logic_vector(7 downto 0);
	 portc_io  : inout std_logic_vector(7 downto 0);
    portd_io  : inout std_logic_vector(7 downto 0) );
end;

architecture ioport_arch of ioport is
signal porta_ddr : std_logic_vector(7 downto 0);
signal portb_ddr : std_logic_vector(7 downto 0);
signal portc_ddr : std_logic_vector(7 downto 0);
signal portd_ddr : std_logic_vector(7 downto 0);
signal porta_data : std_logic_vector(7 downto 0);
signal portb_data : std_logic_vector(7 downto 0);
signal portc_data : std_logic_vector(7 downto 0);
signal portd_data : std_logic_vector(7 downto 0);

begin


--------------------------------
--
-- read I/O port
--
--------------------------------

ioport_read : process( addr,
                     porta_ddr, portb_ddr, portc_ddr, portd_ddr,
							porta_data, portb_data, portc_data, portd_data,
						   porta_io, portb_io, portc_io, portd_io )
variable count : integer;
begin
      case addr is

	     when "000" =>
		    for count in 0 to 7 loop
            if porta_ddr(count) = '1' then
              data_out(count) <= porta_data(count);
            else
              data_out(count) <= porta_io(count);
            end if;
			 end loop;

		  when "001" =>
		    for count in 0 to 7 loop
            if portb_ddr(count) = '1' then
              data_out(count) <= portb_data(count);
            else
              data_out(count) <= portb_io(count);
            end if;
			 end loop;

		  when "010" =>
		    for count in 0 to 7 loop
            if portc_ddr(count) = '1' then
              data_out(count) <= portc_data(count);
            else
              data_out(count) <= portc_io(count);
            end if;
			 end loop;

		  when "011" =>
		    for count in 0 to 7 loop
            if portd_ddr(count) = '1' then
              data_out(count) <= portd_data(count);
            else
              data_out(count) <= portd_io(count);
            end if;
			 end loop;

	     when "100" =>
		    data_out <= porta_ddr;

		  when "101" =>
		    data_out <= portb_ddr;

		  when "110" =>
		    data_out <= portc_ddr;

		  when "111" =>
		    data_out <= portd_ddr;

		  when others =>
		    data_out <= "00000000";
		end case;
end process;

---------------------------------
--
-- Write I/O ports
--
---------------------------------

ioport_write : process( clk, rst, addr, cs, rw, data_in,
                        porta_data, portb_data, portc_data, portd_data,
								porta_ddr, portb_ddr, portc_ddr, portd_ddr )
begin
  if clk'event and clk = '0' then
    if rst = '1' then
      porta_data <= "00000000";
      portb_data <= "00000000";
      portc_data <= "00000000";
      portd_data <= "00000000";
      porta_ddr <= "00000000";
      portb_ddr <= "00000000";
      portc_ddr <= "00000000";
      portd_ddr <= "00000000";
    elsif cs = '1' and rw = '0' then
      case addr is
	     when "000" =>
		    porta_data <= data_in;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
		  when "001" =>
		    porta_data <= porta_data;
		    portb_data <= data_in;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
		  when "010" =>
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= data_in;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
		  when "011" =>
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= data_in;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
	     when "100" =>
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= data_in;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
		  when "101" =>
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= data_in;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
		  when "110" =>
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= data_in;
		    portd_ddr  <= portd_ddr;
		  when "111" =>
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= data_in;
		  when others =>
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
		end case;
	 else
		    porta_data <= porta_data;
		    portb_data <= portb_data;
		    portc_data <= portc_data;
		    portd_data <= portd_data;
		    porta_ddr  <= porta_ddr;
		    portb_ddr  <= portb_ddr;
		    portc_ddr  <= portc_ddr;
		    portd_ddr  <= portd_ddr;
	 end if;
  end if;
end process;

---------------------------------
--
-- direction control port a
--
---------------------------------
porta_direction : process ( porta_data, porta_ddr )
variable count : integer;
begin
  for count in 0 to 7 loop
    if porta_ddr(count) = '1' then
      porta_io(count) <= porta_data(count);
    else
      porta_io(count) <= 'Z';
    end if;
  end loop;
end process;

---------------------------------
--
-- direction control port b
--
---------------------------------
portb_direction : process ( portb_data, portb_ddr )
variable count : integer;
begin
  for count in 0 to 7 loop
    if portb_ddr(count) = '1' then
      portb_io(count) <= portb_data(count);
    else
      portb_io(count) <= 'Z';
    end if;
  end loop;
end process;

---------------------------------
--
-- direction control port c
--
---------------------------------
portc_direction : process ( portc_data, portc_ddr )
variable count : integer;
begin
  for count in 0 to 7 loop
    if portc_ddr(count) = '1' then
      portc_io(count) <= portc_data(count);
    else
      portc_io(count) <= 'Z';
    end if;
  end loop;
end process;

---------------------------------
--
-- direction control port d
--
---------------------------------
portd_direction : process ( portd_data, portd_ddr )
variable count : integer;
begin
  for count in 0 to 7 loop
    if portd_ddr(count) = '1' then
      portd_io(count) <= portd_data(count);
    else
      portd_io(count) <= 'Z';
    end if;
  end loop;
end process;

end ioport_arch;
	
