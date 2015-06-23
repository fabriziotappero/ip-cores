--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_Usefull_Pkg.vhd
--
-- Description:
--	projet copyBlaze
--	Package utilisé pour le projet
--
-- File history:
-- v1.0: 31/08/11: Creation
-- v1.1: 20/11/11: Ajout de la fréquence low (10Mhz)
-- v1.2: 27/11/11: Ajout des fonctions OR_Func, AND_Func
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- Package: Usefull_Pkg
--------------------------------------------------------------------------------
package Usefull_Pkg is
	--- frequence of the fpga core
	constant FREQ				: real		:= 40.0e6;
	constant FREQ_LOW			: real		:= 10.0e6;

	--- find minimum number of bits required to
	--- represent N as an unsigned binary number
	function log2_ceil(N: natural) return positive;
	
	function log2(A: integer) return integer;

	-- OR sur tout les bits d'un vecteur
	function OR_Func (x : std_ulogic_vector) return std_ulogic;
	-- AND sur tout les bits d'un vecteur
	function AND_Func (x : std_ulogic_vector) return std_ulogic;

	function ODD_Func (x : std_ulogic_vector) return std_ulogic;
end;

--------------------------------------------------------------------------------
-- Body: Usefull_Pkg
--------------------------------------------------------------------------------
package body Usefull_Pkg is

	--- find minimum number of bits required to
	--- represent N as an unsigned binary number
	function log2_ceil(N: natural) return positive is
	begin
		if N < 2 then
			return 1;
		else
			return 1 + log2_ceil(N/2);
		end if;
	end;

--	function log2_ceil(N : integer) return integer is
--	begin
--		if (N <= 2) then
--			return 1;
--		else
--			if (N mod 2 = 0) then
--				return 1 + log2_ceil(N/2);
--			else
--				return 1 + log2_ceil((N+1)/2);
--			end if;
--		end if;
--	end function log2_ceil;

--	function log2_ceil (constant x : natural) return positive is
--	
--		variable v_tmp : natural := x;
--		variable v_ret : natural := 0;
--		variable v_line : integer;
--	
--	begin -- function log2
--	
--		while (v_tmp > 0) loop
--			v_tmp := v_tmp / 2;
--			v_ret := v_ret + 1;
--		end loop;
--
--		v_line := v_ret;
--		report "value: " & integer'image(v_line);
--		return v_ret;
--	end function log2_ceil;

	function log2(A: integer) return integer is
	begin
		for I in 1 to 30 loop  -- Works for up to 32 bit integers
			if(2**I > A) then return(I-1);  end if;
		end loop;
		return(30);
	end;
	-- OR sur tout les bits d'un vecteur
	function OR_Func (x : std_ulogic_vector) return std_ulogic is
		variable tmp : std_ulogic := '0';
	begin
		for j in x'range loop
			tmp := tmp or x(j);
		end loop;
        return tmp;
	end OR_Func;

	-- AND sur tout les bits d'un vecteur
	function AND_Func (x : std_ulogic_vector) return std_ulogic is
		variable tmp : std_ulogic := '1';
	begin
		for j in x'range loop
			tmp := tmp and x(j);
		end loop;
        return tmp;
	end AND_Func;

	function ODD_Func (x : std_ulogic_vector) return std_ulogic is
		variable tmp : std_ulogic := '0';
	begin
		for j in x'range loop
			tmp := tmp xor x(j);
		end loop;
        return tmp;
	end ODD_Func;

end package body;
