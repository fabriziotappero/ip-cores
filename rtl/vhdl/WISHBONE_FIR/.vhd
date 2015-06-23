library ieee;
use ieee.math_real.all;

package coeff_pkg is
	constant Nb : integer := 16;
	constant Nh : integer := 255;
	constant Q : integer := 15;

--	type coeff is array (Nh-1 downto 0) of integer range -(2**(Nb-1)) to (2**(Nb-1)-1);
--	constant h0 : coeff := (
--		-89,
--		971,
--		860,
--		-8051,
--		-985,
--		14393,
--		-985,
--		-8051,
--		860,
--		971,
--		-89
--	);
end coeff_pkg;
