/*	Tauhop resolution package
	
	Description
	Defines common resolution functions.
	
	To Do: 
	
	Author(s): 
	- Daniel C.K. Kho, daniel.kho@tauhop.com
	
	Copyright (C) 2012-2014 Authors and Tauhop Solutions.
	
	This source file may be used and distributed without 
	restriction provided that this copyright statement is not 
	removed from the file and that any derivative work contains 
	the original copyright notice and the associated disclaimer.
	
	This source file is free software; you can redistribute it 
	and/or modify it under the terms of the GNU Lesser General 
	Public License as published by the Free Software Foundation; 
	either version 2.1 of the License, or (at your option) any 
	later version.
	
	This source is distributed in the hope that it will be 
	useful, but WITHOUT ANY WARRANTY; without even the implied 
	warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
	PURPOSE. See the GNU Lesser General Public License for more 
	details.
	
	You should have received a copy of the GNU Lesser General 
	Public License along with this source; if not, download it 
	from http://www.opencores.org/lgpl.shtml.
*/
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
package resolved is
	generic(type t);
	
	/* unresolved vector of generic type. */
	type t_vector is array(natural range <>) of t;
	
	type unsigned32_vector is array (natural range <>) of unsigned(31 downto 0);
	type signed32_vector is array (natural range <>) of signed(31 downto 0);
	type integer_vector is array(natural range <>) of integer;
	
	function resolve(s:t_vector) return t;
	function resolve(s:unsigned32_vector) return unsigned;
	function resolve(s:integer_vector) return integer;
	function to_int(u_unsigned: unresolved_unsigned) return integer;
end package resolved;

package body resolved is
	function resolve(s: t_vector) return t is
		variable result: t;
	begin
		for i in s'range loop
			for j in s(i)'range loop
				if is_LH01(s(i)(j)) then
					if is_LH01(result(j)) then
						report "Multiple driving signals detected." severity warning;
					end if;
					result(j) := s(i)(j);
				end if;
			end loop;
		end loop;
	end function resolve;
	
	function resolve(s: unsigned32_vector) return unsigned is
		variable result: unsigned(31 downto 0);
	begin
		for i in s'range loop
			if s(i) /= 0 then
				if result /= 0 then
					report "Multiple driving signals on unsigned32" severity warning;
				end if;
				result := s(i);
			end if;
		end loop;
		return result;
	end function resolve;
	
	function resolve(s:integer_vector) return integer is
		variable result:integer:=0;
	begin
		for i in s'range loop
			if s(i) /= 0 then
				if result /= 0 then
					report "Multiple driving signals on integer" severity warning;
				end if;
				result := s(i);
			end if;
		end loop;
		return result;
	end function resolve;
	
	function to_int(u_unsigned: unresolved_unsigned) return integer is
		variable result: natural:=0;
	begin
		for i in u_unsigned'range loop
			result := result+result;
			if u_unsigned(i) = '1' then
				result := result + 1;
			end if;
		end loop;
		return result;
	end function to_int;
end package body resolved;
