library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity Bresenhamer is
    Port ( WriteEnable : out  STD_LOGIC;
           X : out  STD_LOGIC_VECTOR (9 downto 0);
           Y : out  STD_LOGIC_VECTOR (8 downto 0);
           X1 : in  STD_LOGIC_VECTOR (9 downto 0);
           Y1 : in  STD_LOGIC_VECTOR (8 downto 0);
           X2 : in  STD_LOGIC_VECTOR (9 downto 0);
           Y2 : in  STD_LOGIC_VECTOR (8 downto 0);
			  SS : out  STD_LOGIC_VECTOR (3 downto 0);
			  Clk : in STD_LOGIC;
           StartDraw : in  STD_LOGIC;
			  dbg : out  STD_LOGIC_VECTOR (11 downto 0);
			  Reset : in  STD_LOGIC);
end Bresenhamer;
architecture Behavioral of Bresenhamer is
signal myX1,myX2 : STD_LOGIC_VECTOR (11 downto 0);
signal myY1,myY2 : STD_LOGIC_VECTOR (11 downto 0);
signal p,p0_1,p0_2,p0_3,p0_4,p0_5,p0_6,p0_7,p0_8 : STD_LOGIC_VECTOR (11 downto 0);
signal p_1,p_2,p_3,p_4,p_5,p_6,p_7,p_8 : STD_LOGIC_VECTOR (11 downto 0);
signal ndx,ndy : STD_LOGIC_VECTOR (11 downto 0);
signal dx,dy,t_2dx,t_2dy,neg_dx,neg_dy,t_2neg_dx,t_2neg_dy : STD_LOGIC_VECTOR (11 downto 0);
signal dx_minus_dy : STD_LOGIC_VECTOR (11 downto 0);
signal minus_dx_minus_dy : STD_LOGIC_VECTOR (11 downto 0);
signal minus_dx_plus_dy : STD_LOGIC_VECTOR (11 downto 0);
signal dx_plus_dy : STD_LOGIC_VECTOR (11 downto 0);
signal State : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal condX1X2,condY1Y2 : STD_LOGIC;
constant IDLE : STD_LOGIC_VECTOR(3 downto 0) := "0000";
constant INIT : STD_LOGIC_VECTOR(3 downto 0) := "0001";
constant CASE1 : STD_LOGIC_VECTOR(3 downto 0) := "0010";
constant CASE2 : STD_LOGIC_VECTOR(3 downto 0) := "0011";
constant CASE3 : STD_LOGIC_VECTOR(3 downto 0) := "0100";
constant CASE4 : STD_LOGIC_VECTOR(3 downto 0) := "0101";
constant CASE5 : STD_LOGIC_VECTOR(3 downto 0) := "0110";
constant CASE6 : STD_LOGIC_VECTOR(3 downto 0) := "0111";
constant CASE7 : STD_LOGIC_VECTOR(3 downto 0) := "1000";
constant CASE8 : STD_LOGIC_VECTOR(3 downto 0) := "1001";
constant CLEAR : STD_LOGIC_VECTOR(3 downto 0) := "1010";
signal ccounter : STD_LOGIC_VECTOR (18 downto 0) := "0000000000000000000";
begin
ndx <= ("00" & X2)-("00" & X1);
ndy <= ("000" & Y2)-("000" & Y1);
neg_dx <= 0-dx;
neg_dy <= 0-dy;
dbg <= p;
dx_minus_dy <= dx+neg_dy;
minus_dx_minus_dy <= neg_dx+neg_dy;
minus_dx_plus_dy <= neg_dx+dy;
dx_plus_dy <= dx+dy;
t_2dy <= dy(10 downto 0) & '0';
t_2dx <= dx(10 downto 0) & '0';
t_2neg_dy <= neg_dy(10 downto 0) & '0';
t_2neg_dx <= neg_dx(10 downto 0) & '0';
p0_1 <= t_2dy+neg_dx;
p0_2 <= t_2dx+neg_dy;
p0_3 <= t_2neg_dx+dy;
p0_4 <= t_2dy+neg_dx;
p0_5 <= t_2neg_dy+dx;
p0_6 <= t_2neg_dx+dy;
p0_7 <= t_2dx+neg_dy;
p0_8 <= t_2neg_dy+dx;
p_1 <= p+t_2dy when p(11)='1' else p+t_2dy+t_2neg_dx;
p_2 <= p+t_2dx when p(11)='1' else p+t_2dx+t_2neg_dy;
p_3 <= p+t_2neg_dx when p(11)='1' else p+t_2neg_dx+t_2neg_dy;
p_4 <= p+t_2dy when p(11)='1' else p+t_2dy+t_2dx;
p_5 <= p+t_2neg_dy when p(11)='1' else p+t_2neg_dy+t_2dx;
p_6 <= p+t_2neg_dx when p(11)='1' else p+t_2neg_dx+t_2dy;
p_7 <= p+t_2dx when p(11)='1' else p+t_2dx+t_2dy;
p_8 <= p+t_2neg_dy when p(11)='1' else p+t_2neg_dy+t_2neg_dx;
X <= ccounter(9 downto 0) when State = CLEAR else myX1(9 downto 0);
Y <= ccounter(18 downto 10) when State = CLEAR else myY1(8 downto 0);
SS <= State;
WriteEnable <= '0' when State = IDLE or State = INIT else '1';
process (Clk) begin
	if (rising_edge(Clk)) then
		if (State = IDLE) then
			if (Reset = '1') then
				State <= CLEAR;
				ccounter <= (others=>'0');
			elsif (StartDraw = '1') then
				myX1(9 downto 0) <= X1;
				myX1(11 downto 10) <= "00";
				myY1(8 downto 0) <= Y1;
				myY1(11 downto 9) <= "000";
				myX2(9 downto 0) <= X2;
				myX2(11 downto 10) <= "00";
				myY2(8 downto 0) <= Y2;
				myY2(11 downto 9) <= "000";
				dx <= ndx;
				dy <= ndy;
				State <= INIT;
			end if;
		elsif (State = INIT) then
			if (dx(11) = '0' and dy(11) = '0' and dx_minus_dy(11) = '0') then
				State <= CASE1;
				p <= p0_1;
			elsif (dx(11) = '0' and dy(11) = '0' and dx_minus_dy(11) = '1') then
				State <= CASE2;
				p <= p0_2;
			elsif (dx(11) = '1' and dy(11) = '0' and minus_dx_minus_dy(11) = '1') then
				State <= CASE3;
				p <= p0_3;
			elsif (dx(11) = '1' and dy(11) = '0' and minus_dx_minus_dy(11) = '0') then
				State <= CASE4;
				p <= p0_4;
			elsif (dx(11) = '1' and dy(11) = '1' and minus_dx_plus_dy(11) = '0') then
				State <= CASE5;
				p <= p0_5;
			elsif (dx(11) = '1' and dy(11) = '1' and minus_dx_plus_dy(11) = '1') then
				State <= CASE6;
				p <= p0_6;
			elsif (dx(11) = '0' and dy(11) = '1' and dx_plus_dy(11) = '1') then
				State <= CASE7;
				p <= p0_7;
			else
				State <= CASE8;
				p <= p0_8;
			end if;
		elsif (State = CASE1) then
			if (myX1 = myX2) then
				State <= IDLE;
			else
				myX1 <= myX1 + 1;
				p <= p_1;
				if (P(11) = '0') then
					myY1 <= myY1 + 1;
				end if;
			end if;
		elsif (State = CASE2) then
			if (myY1 = myY2) then
				State <= IDLE;
			else
				myY1 <= myY1 + 1;
				p <= p_2;
				if (P(11) = '0') then
					myX1 <= myX1 + 1;
				end if;
			end if;
		elsif (State = CASE3) then
			if (myY1 = myY2) then
				State <= IDLE;
			else
				myY1 <= myY1 + 1;
				p <= p_3;
				if (P(11) = '0') then
					myX1 <= myX1 - 1;
				end if;
			end if;
		elsif (State = CASE4) then
			if (myX1 = myX2) then
				State <= IDLE;
			else
				myX1 <= myX1 - 1;
				p <= p_4;
				if (P(11) = '0') then
					myY1 <= myY1 + 1;
				end if;
			end if;
		elsif (State = CASE5) then
			if (myX1 = myX2) then
				State <= IDLE;
			else
				myX1 <= myX1 - 1;
				p <= p_5;
				if (P(11) = '0') then
					myY1 <= myY1 - 1;
				end if;
			end if;
		elsif (State = CASE6) then
			if (myY1 = myY2) then
				State <= IDLE;
			else
				myY1 <= myY1 - 1;
				p <= p_6;
				if (P(11) = '0') then
					myX1 <= myX1 - 1;
				end if;
			end if;
		elsif (State = CASE7) then
			if (myY1 = myY2) then
				State <= IDLE;
			else
				myY1 <= myY1 - 1;
				p <= p_7;
				if (P(11) = '0') then
					myX1 <= myX1 + 1;
				end if;
			end if;
		elsif (State = CASE8) then
			if (myX1 = myX2) then
				State <= IDLE;
			else
				myX1 <= myX1 + 1;
				p <= p_8;
				if (P(11) = '0') then
					myY1 <= myY1 - 1;
				end if;
			end if;
		elsif (State = CLEAR) then
			ccounter <= ccounter + 1;
			if (ccounter = "1111111111111111111") then
				State <= IDLE;
			end if;
		end if;
	end if;
end process;
end Behavioral;