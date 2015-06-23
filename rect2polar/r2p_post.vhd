--
--	post.vhd
--
--	Cordic post-processing block
--
-- Compensate cordic algorithm K-factor; divide Radius by 1.6467, or multiply by 0.60725. 
-- Approximation:  Ra = Ri/2 + Ri/8 - Ri/64 - Ri/512
--                 Radius = Ra - Ra/4096 = Ri * 0.60727. This is a 0.0034% error.
-- Implementation: Ra = (Ri/2 + Ri/8) - (Ri/64 + Ri/512)
--                 Radius = Ra - Ra/4096
--	Position calculated angle in correct quadrant.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity r2p_post is
	port(
		clk	: in std_logic;
		ena	: in std_logic;

		Ai	: in signed(19 downto 0);
		Ri	: in unsigned(19 downto 0);
		Q	: in std_logic_vector(2 downto 0);

		Ao	: out signed(19 downto 0);
		Ro	: out unsigned(19 downto 0));
end entity r2p_post;

architecture dataflow of r2p_post is
begin
	radius: block
		signal RadA, RadB, RadC : unsigned(19 downto 0);
	begin
		process(clk)
		begin
			if (clk'event and clk = '1') then
				if (ena = '1') then
					RadA <= ('0' & Ri(19 downto 1)) + ("000" & Ri(19 downto 3));
					RadB <= ("000000" & Ri(19 downto 6)) + ("000000000" & Ri(19 downto 9));
					RadC <= RadA - RadB;

					Ro <= RadC - RadC(19 downto 12);
				end if;
			end if;
		end process;
	end block radius;

	angle: block
		constant const_PI2 : signed(19 downto 0) := conv_signed(16#40000#, 20); -- PI / 2
		constant const_PI : signed(19 downto 0) := conv_signed(16#80000#, 20);  -- PI
		constant const_2PI : signed(19 downto 0) := (others => '0');            -- 2PI

		signal dQ : std_logic_vector(2 downto 1);
		signal ddQ : std_logic;
		signal AngStep1 : signed(19 downto 0);
		signal AngStep2 : signed(19 downto 0);
	begin
		angle_step1: process(clk, Ai, Q)
			variable overflow : std_logic;
			variable AngA, AngB, Ang : signed(19 downto 0);
		begin
			-- check if angle is negative, if so set it to zero
			overflow := Ai(19); --and Ai(18);

			if (overflow = '1') then
				AngA := (others => '0');
			else
				AngA := Ai;
			end if;

			-- step 1: Xabs and Yabs are swapped
			-- Calculated angle is the angle between vector and Y-axis.
			-- ActualAngle = PI/2 - CalculatedAngle
		 	AngB := const_PI2 - AngA;

			if (Q(0) = '1') then
				Ang := AngB;
			else
				Ang := AngA;
			end if;

			if (clk'event and clk = '1') then
				if (ena = '1') then
					AngStep1 <= Ang;
					dQ <= q(2 downto 1);
				end if;
			end if;
		end process angle_step1;


		angle_step2: process(clk, AngStep1, dQ)
			variable AngA, AngB, Ang : signed(19 downto 0);
		begin
			AngA := AngStep1;

			-- step 2: Xvalue is negative
			-- Actual angle is in the second or third quadrant
			-- ActualAngle = PI - CalculatedAngle
			AngB := const_PI - AngA;

			if (dQ(1) = '1') then
				Ang := AngB;
			else
				Ang := AngA;
			end if;

			if (clk'event and clk = '1') then
				if (ena = '1') then
					AngStep2 <= Ang;
					ddQ <= dQ(2);
				end if;
			end if;
		end process angle_step2;


		angle_step3: process(clk, AngStep2, ddQ)
			variable AngA, AngB, Ang : signed(19 downto 0);
		begin
			AngA := AngStep2;

			-- step 3: Yvalue is negative
			-- Actual angle is in the third or fourth quadrant
			-- ActualAngle = 2PI - CalculatedAngle
			AngB := const_2PI - AngA;

			if (ddQ = '1') then
				Ang := AngB;
			else
				Ang := AngA;
			end if;
			
			if (clk'event and clk = '1') then
				if (ena = '1') then
					Ao <= Ang;
				end if;
			end if;
		end process angle_step3;
	end block angle;
end;









