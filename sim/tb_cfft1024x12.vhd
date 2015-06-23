---------------------------------------------------------------------------------------------------
--
-- Title       : test bench
-- Design      : cfft
-- Author      : henning larsen
-- email	   : 
--
---------------------------------------------------------------------------------------------------
--
-- File        : tb_cfft1024x12.vhd
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--
-- Simple "testbench" for cfft1024x12. It is realy just an excitation of inputs
-- The output has to be evaluated manually. run for 125 us with current settings.
-- Input is a dual sinsoid with constant amplitudes, and a DC value. 
-- Input is real valued only. A calculation of the power spectrum, and a frequency bin
-- counter is included, but no reordering of output sequence is performed.
-- Frequencies are easy to select such that a minimum of spill into side bins is obtained.
-- Beware of the posibilty of saturation in the output. For single sinsoide,the saturation limit
-- is 2^14/29.4=557 units of input amplitude. 
--	
-- henning larsen															 
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	1
-- Version         :	1.1.0
-- Date            :	Nov 21 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    init release 
-- 						compare output position
--
---------------------------------------------------------------------------------------------------



LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.math_real.all;
USE ieee.std_logic_signed.all;

ENTITY cfft1024x12_tester1 IS
END cfft1024x12_tester1 ;
ARCHITECTURE tester OF cfft1024x12_tester1 IS
   -- Component Declarations
   COMPONENT cfft1024X12
   PORT (
      clk       : IN     STD_LOGIC ;
      rst       : IN     STD_LOGIC ;
      start     : IN     STD_LOGIC ;
      invert       : IN     std_logic ;
      Iin       : IN     STD_LOGIC_VECTOR (11 DOWNTO 0);
      Qin       : IN     STD_LOGIC_VECTOR (11 DOWNTO 0);
      inputbusy : OUT    STD_LOGIC ;
      outdataen : OUT    STD_LOGIC ;
      Iout      : OUT    STD_LOGIC_VECTOR (13 DOWNTO 0);
      Qout      : OUT    STD_LOGIC_VECTOR (13 DOWNTO 0);
	  OutPosition : out STD_LOGIC_VECTOR( 9 downto 0 )
   );
   END COMPONENT;

	constant Tck_half : time:=10 ns;
	constant Tckhalf : real:=10.0e-9;-- real value eqv of time, there is some conversion function
					-- for this but could not find/remember.
	constant ampl1 : real:=100.0;-- max amplitude is roughly 550=2^14/29.4 to avoid sturation in output
	constant ampl2 : real:=200.0; -- .. but see intro comments
	constant f1 : real := 100.0/TckHalf/2.0/1024.0;-- bin number =100
	constant f2 : real := 33.0/TckHalf/2.0/1024.0;-- bin number =33
	constant dc : real:=100.0;--bin number=0

	signal   c1,c2,cout: real; 	
	signal 	clock : std_logic:='0';
	signal 	reset : std_logic:='0';
	signal 	start : std_logic:='0';
    signal	invert       : 	std_logic ;
    signal	Iin       :   STD_LOGIC_VECTOR (11 DOWNTO 0);
    signal	Qin       :   STD_LOGIC_VECTOR (11 DOWNTO 0);
    signal	inputbusy :   STD_LOGIC:='0' ;
    signal	outdataen :   STD_LOGIC:='0' ;
    signal 	Iout      :   STD_LOGIC_VECTOR (13 DOWNTO 0);
    signal	Qout      :   STD_LOGIC_VECTOR (13 DOWNTO 0);
 	signal  amp : real; -- power spectrum	
    signal	bitRev    :   STD_LOGIC_VECTOR (9 DOWNTO 0);-- bin counter
	signal  OutPosition : STD_LOGIC_VECTOR( 9 downto 0 );

BEGIN
   -- Instance port mappings.
   I0 : cfft1024X12
      PORT MAP (
         clk       => clock,
         rst       => reset,
         start     => start,
         invert       => invert,
         Iin       => Iin,
         Qin       => Qin,
         inputbusy => inputbusy,
         outdataen => outdataen,
         Iout      => Iout,
         Qout      => Qout,
		 OutPosition => OutPosition
      );

----------------------------------------------------------------------------
--
-- control signals ,setup
clock <= not clock after Tck_half;
reset <= '1', '0' after 2*Tck_half;
start <= '0', '1' after 3*Tck_half, '0' after 5*Tck_half;-- only one FFT is done
invert <= '0';-- FFT

----------------------------------------------------------------------------
--
sin_gen: process(clock, reset)	      
	variable tid : real;
	variable TM : real :=0.0 ;
	begin
		if Reset = '1' then
			c1 <= 0.0;
			c2 <= 0.0;
			Iin<="000000000000" ;
			Qin<="000000000000" ;
			TM := 0.0;
			tid := TM;
		else
			if clock'event and clock = '1' then
				TM := TM + Tckhalf*2.0;
				tid := TM;
				c1 <= (ampl1 * sin(2.0*math_pi*f1*tid));
				c2 <= (ampl2 * sin(2.0*math_pi*f2*tid));
				cout <= c1+c2+dc;
				Iin <= conv_std_logic_vector(integer(cout),Iin'length);
				Qin <="000000000000" ;
			end if;
		end if;
	end process sin_gen;
----------------------------------------------------------------------------
--
--Output power spectrum, normalized with the gain of 29.4
amp <= sqrt(real(CONV_integer(Iout)) * real(CONV_integer(Iout)) 
		+ real(CONV_integer(Qout)) * real(CONV_integer(Qout)))/29.4;
----------------------------------------------------------------------------
--
-- radix 4 bit reversed counter
radix4cnt: process (clock)
variable cntr: std_logic_vector ( 9 downto 0);
begin
	if rising_edge(clock) then
		if outdataen='1' then
			cntr:=unsigned(cntr)+1;
		else
			cntr:=(others => '0');
		end if;
		for k in 1 to ((10) / 2) loop  
			bitRev(2*k-2)<= cntr(10-2*k);
			bitRev(2*k-1)<= cntr(10-(-1+2*k));
		end loop;
	end if;
end process radix4cnt;

END tester;
