Library ieee;
use ieee.std_logic_1164.all;


ENTITY IC6821 IS
--	GENERIC	();
	PORT
	(
		r_w: in std_logic;
		e: in std_logic;
--		dbg: out std_logic_vector(7 downto 0);
				
		cs0: in std_logic;
		cs1: in std_logic;
		cs2: in std_logic;  -- active low
		reset: in std_logic;  -- active low
		RS0: in std_logic;
		RS1: in std_logic;
		CA1: in std_logic;
		CA2: inout std_logic;
		CB1: in std_logic;
		CB2: inout std_logic;
		DB: inout std_logic_vector(7 downto 0);
		PA: inout std_logic_vector(7 downto 0);		
		PB: inout std_logic_vector(7 downto 0);		
		irqa: out std_logic;  -- active low
		irqb: out std_logic   -- active low
	);
END IC6821;

-------------------------------------------------
-------------------------------------------------

ARCHITECTURE bhv1 OF IC6821 IS
------------------------
COMPONENT DFF
   PORT (d   : IN STD_LOGIC;
        clk  : IN STD_LOGIC;
        clrn : IN STD_LOGIC;
        prn  : IN STD_LOGIC;
        q    : OUT STD_LOGIC );
END COMPONENT;
COMPONENT LATCH
   PORT (d  : IN STD_LOGIC;
      ena: IN STD_LOGIC;
      q  : OUT STD_LOGIC);
END COMPONENT;
COMPONENT TFF
   PORT (t   : IN STD_LOGIC;
      clk : IN STD_LOGIC;
      clrn: IN STD_LOGIC;
      prn : IN STD_LOGIC;
      q   : OUT STD_LOGIC);
END COMPONENT;


-----------------------
	SIGNAL bufPA,DDRAbits,CRA : STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL bufPB,DDRBbits,CRB : STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL CRA2, CRB2, iCS: STD_LOGIC;
	SIGNAL irqaf1_1, irqaf1_2, irqaf2_1, irqaf2_2,
		   irqbf1_1, irqbf1_2, irqbf2_1, irqbf2_2,
		   prev_readA, mpu_readA,
		   prev_writeB, mpu_readB: STD_LOGIC;
	SIGNAL disbla1, disbla2: std_logic;
	SIGNAL disblb1, disblb2: std_logic;
	
	SIGNAL edly: std_logic_vector(7 downto 0);
	
	SIGNAL DB_PA,DB_DDRA,DB_CRA, DB_PB,DB_DDRB,DB_CRB: std_logic_vector(7 downto 0);
BEGIN
  iCS<= CS0 and CS1 and (not CS2);
---------  peripheral register A
bufPAprcs:
PROCESS (E, RS0, RS1, CRA2, CRB2, DDRAbits,reset,iCS, DB, PA,r_w)
BEGIN
	if reset='0' then bufPA<=(others=>'0');
	elsif RS0='0' and RS1='0' and CRA2='1' and r_w='0' and iCS='1' then
	FOR i IN 0 to 7 LOOP
     if DDRAbits(i)='1' then   --- the pin acts like an output
		if e'event and	e='0' then	bufPA(i)<=DB(i); end if;
     elsif DDRAbits(i)='0' then   --- the pin acts like an input
		if e'event and	e='0' then	bufPA(i)<=bufPA(i); end if;
	 end if;
	END LOOP;
	
	elsif RS0='0' and RS1='0' and CRA2='1' and r_w='1' and iCS='1' then
	FOR i IN 0 to 7 LOOP
     if DDRAbits(i)='1' then   --- the pin acts like an output
		if e'event and	e='1' then	DB_PA(i)<=bufPA(i);  end if;
     elsif DDRAbits(i)='0' then   --- the pin acts like an input
		if e'event and	e='1' then	bufPA(i)<=PA(i); DB_PA(i)<=PA(i); end if;
	 end if;
	END LOOP;
	end if;
END PROCESS;

PAprcs:
PROCESS (DDRAbits, bufPA)
BEGIN
	 FOR i IN 0 to 7 LOOP
      if DDRAbits(i)='1' then   --- the pin acts like an output
		PA(i)<=bufPA(i);
	  else	PA(i)<='Z';  end if;
	END LOOP;
END PROCESS;

DDRAprcs:
PROCESS (E, RS0, RS1, CRA2, reset,iCS,r_w)
BEGIN
	if reset='0' then DDRAbits<=(others=>'0');
	elsif RS0='0' and RS1='0' and CRA2='0' and r_w ='0' and iCS='1' then
		if e'event and	e='0' then	DDRAbits<=DB; end if;
	elsif RS0='0' and RS1='0' and CRA2='0' and r_w ='1' and iCS='1' then
		if e'event and	e='1' then	DB_DDRA<=DDRAbits; end if;
	end if;
END PROCESS;

CRAprcs:
PROCESS (E, RS0, RS1, reset,iCS,CRA,r_w)
BEGIN
	if reset='0' then CRA(5 downto 0)<=(others=>'0');
	elsif RS0='1' and RS1='0' and r_w='0' and iCS='1' then
		if e'event and	e='0' then	CRA(5 downto 0)<=DB(5 downto 0);	end if;
	elsif RS0='1' and RS1='0' and r_w='1' and iCS='1' then
		if e'event and	e='1' then	DB_CRA(5 downto 0)<=CRA(5 downto 0);	end if;
	end if;	
	CRA2<=CRA(2);
END PROCESS;
---------  peripheral register B
bufPBprcs:
PROCESS (E, RS0, RS1, CRA2, CRB2, DDRBbits,reset,iCS, DB, PB,r_w)
BEGIN
	if reset='0' then bufPB<=(others=>'0');
	elsif RS0='0' and RS1='1' and CRB2='1' and r_w='0' and iCS='1' then
	FOR i IN 0 to 7 LOOP
     if DDRBbits(i)='1' then   --- the pin acts like an output
		if e'event and	e='0' then	bufPB(i)<=DB(i); end if;
     elsif DDRBbits(i)='0' then   --- the pin acts like an input
		if e'event and	e='0' then	bufPB(i)<=bufPB(i); end if;
	 end if;
	END LOOP;
	
	elsif RS0='0' and RS1='1' and CRB2='1' and r_w='1' and iCS='1' then
	FOR i IN 0 to 7 LOOP
     if DDRBbits(i)='1' then   --- the pin acts like an output
		if e'event and	e='1' then	DB_PB(i)<=bufPB(i); end if;
     elsif DDRBbits(i)='0' then   --- the pin acts like an input
		if e'event and	e='1' then	bufPB(i)<=PB(i); DB_PB(i)<=PB(i); end if;
	 end if;
	END LOOP;
	end if;
END PROCESS;

PBprcs:
PROCESS (DDRBbits, bufPB)
BEGIN
	 FOR i IN 0 to 7 LOOP
      if DDRBbits(i)='1' then   --- the pin acts like an output
		PB(i)<=bufPB(i);
	  else	PB(i)<='Z';  end if;
	END LOOP;
END PROCESS;

DDRBprcs:
PROCESS (E, RS0, RS1, CRA2, CRB2,reset,iCS,r_w)
BEGIN
	if reset='0' then DDRBbits<=(others=>'0');
	elsif RS0='0' and RS1='1' and CRB2='0' and r_w ='0' and iCS='1' then
		if e'event and	e='0' then	DDRBbits<=DB; end if;
	elsif RS0='0' and RS1='1' and CRB2='0' and r_w ='1' and iCS='1' then
		if e'event and	e='1' then	DB_DDRB<=DDRBbits; end if;
	end if;
	
END PROCESS;

CRBprcs:
PROCESS (E, RS0, RS1, reset,iCS,CRB,r_w)
BEGIN
	if reset='0' then CRB(5 downto 0)<=(others=>'0');
	elsif RS0='1' and RS1='1' and r_w='0' and iCS='1' then
		if e'event and	e='0' then	CRB(5 downto 0)<=DB(5 downto 0);	end if;
	elsif RS0='1' and RS1='1' and r_w='1' and iCS='1' then
		if e'event and	e='1' then	DB_CRB(5 downto 0)<=CRB(5 downto 0);	end if;
	end if;	
	CRB2<=CRB(2);
END PROCESS;

-------------------------------------------------------
-------------  spooling with the data bus
dbspoller:
PROCESS (RS0, RS1, CRA2, CRB2, r_w, iCS, 
		 DB_PA, DB_DDRA, DB_CRA,
		 DB_PB, DB_DDRB, DB_CRB)
BEGIN
	if RS0='0' and RS1='0' and CRA2='1' and r_w='1' and iCS='1' then
		DB<=DB_PA;
	elsif RS0='0' and RS1='0' and CRA2='0' and r_w ='1' and iCS='1' then
		DB<=DB_DDRA;
	elsif RS0='1' and RS1='0' and r_w='1' and iCS='1' then
		DB<=DB_CRA;		
	elsif RS0='0' and RS1='1' and CRB2='1' and r_w='1' and iCS='1' then
		DB<=DB_PB;	
	elsif RS0='0' and RS1='1' and CRB2='0' and r_w ='1' and iCS='1' then
		DB<=DB_DDRB;
	elsif RS0='1' and RS1='1' and r_w='1' and iCS='1' then
		DB<=DB_CRB;
	ELSE
		DB<=(OTHERS=>'Z');
	END IF;
END PROCESS;

----------------------------------------------------
----------  captures interrupts
	  mpu_readA<=(not RS0) and (not RS1) and CRA2 and r_w and iCS;
	  mpu_readB<=(not RS0) and RS1 and CRB2 and r_w and iCS;
	
prvsread:  -- this is the last read
PROCESS (E, RS0, RS1, reset, r_w, iCS,CRA,CRB)
BEGIN
	if reset='0' then prev_readA<='0';
	elsif e'event and e='1' then
		if RS0='0' and RS1='0' and CRA2='1' and r_w='1' and iCS='1' then
			prev_readA<='1';
		else prev_readA<='0';
		end if;
	end if;
	
	if reset='0' then prev_writeB<='0';
	elsif e'event and e='0' then
		if RS0='0' and RS1='1' and CRB2='1' and r_w='0' and iCS='1' then
			prev_writeB<='1';
		else prev_writeB<='0';
		end if;
	end if;
END PROCESS;

	
intrptsA:
PROCESS (E, RS0, RS1, reset, r_w, CRA,CRB,mpu_readA,mpu_readB,
		 prev_readA, prev_writeB,CA1,CB1,CA2,CB2,
		 irqaf1_1,irqaf1_2,irqaf2_1,irqaf2_2,
		 irqbf1_1, irqbf1_2,irqbf2_1,irqbf2_2,
		 iCS,disbla1,disbla2,
		 disblb1,disblb2)
BEGIN
	disbla1<= (not CRA(0));
	disbla2<= (not CRA(5)) and (not CRA(3));
	------------------------------------------
	---- CA1 line
	if (reset='0') or (mpu_readA='1') then irqaf1_1<='0'; irqaf1_2<='0';
	elsif CRA(1)='0' then   -- the latch for the CA1 is from high to low
		if CA1'event and CA1='0' then irqaf1_1<='1'; end if;
	elsif CRA(1)='1' then   -- the latch for the CA1 is from low to high
		if CA1'event and CA1='1' then irqaf1_2<='1'; end if;
	end if;
	CRA(7)<=irqaf1_1 or irqaf1_2; -- flag bit
	if (disbla1='1') and CRA(7)='1' then irqa<='0';
	elsif (disbla2='1') and CRA(6)='1' then irqa<='0';
	else irqa<='Z'; end if;
	---- CA2 line
	if (reset='0') then 
	
	elsif CRA(5)='1' and CRA(4)='0' and CRA(3)='0' then  -- the CA2 is output
													-- read Strobe with CA1 restore
		if (irqaf1_1='1') or (irqaf1_2='1') then CA2<='1';
		elsif prev_readA='1' then 
			if e'event and e='0' then	CA2<='0';	end if;
		end if;
	elsif CRA(5)='1' and CRA(4)='0' and CRA(3)='1' then  -- the CA2 is output
													-- read Strobe with E restore
		if e'event and e='0' then	
			if prev_readA='1' then  CA2<='0';
			elsif  ics='0' then  CA2<='1'; end if;
		end if;
	elsif CRA(5)='1' and CRA(4)='1' then  -- the CA2 is output
		CA2<=CRA(3);
	else 
		CA2<='Z';	
	end if;
--------------------		
	if (reset='0') or (mpu_readA='1') then irqaf1_1<='0'; irqaf1_2<='0';
	elsif CRA(5)='0' and CRA(4)='0' then   -- the latch for the CA2 is from high to low
		if CA2'event and CA2='0' then irqaf2_1<='1'; end if;
	elsif CRA(5)='0' and CRA(4)='1' then   -- the latch for the CA2 is from low to high
		if CA2'event and CA2='1' then irqaf2_2<='1'; end if;
	end if;
	CRA(6)<=irqaf2_1 or irqaf2_2; -- flag bit
---------------------------------------
---------------------------------------
	disblb1<= (not CRB(0));
	disblb2<= (not CRB(5)) and (not CRB(3));
	---- CB1 line
	if (reset='0') or (mpu_readB='1') then irqbf1_1<='0'; irqbf1_2<='0';
	elsif CRB(1)='0' then   -- the latch for the CB1 is from high to low
		if CB1'event and CB1='0' then irqbf1_1<='1'; end if;
	elsif CRB(1)='1' then   -- the latch for the CB1 is from low to high
		if CB1'event and CB1='1' then irqbf1_2<='1'; end if;
	end if;
	CRB(7)<=irqbf1_1 or irqbf1_2; -- flag bit
	if (disblb1='1') and CRB(7)='1' then irqb<='0';
	elsif (disblb2='1') and CRB(6)='1' then irqb<='0';
	else irqb<='Z'; end if;
	---- CB2 line
	if (reset='0') then 
	
	elsif CRB(5)='1' and CRB(4)='0' and CRB(3)='0' then  -- the CB2 is output
													-- read Strobe with CA1 restore
		if (irqbf1_1='1') or (irqbf1_2='1') then CB2<='1';
		elsif prev_writeB='1' then 
			if e'event and e='1' then CB2<='0';	end if;
		end if;
	elsif CRB(5)='1' and CRB(4)='0' and CRB(3)='1' then  -- the CB2 is output
													-- read Strobe with E restore
		if e'event and e='1' then	
			if prev_writeB='1' then  CB2<='0';
			elsif  ics='0' then  CB2<='1'; end if;
		end if;
	elsif CRB(5)='1' and CRB(4)='1' then  -- the CB2 is output
		CB2<=CRB(3);
	else 
		CB2<='Z';	
	end if;
--------------------		
	if (reset='0') or (mpu_readB='1') then irqbf1_1<='0'; irqbf1_2<='0';
	elsif CRB(5)='0' and CRB(4)='0' then   -- the latch for the CB2 is from high to low
		if CB2'event and CB2='0' then irqbf2_1<='1'; end if;
	elsif CRB(5)='0' and CRB(4)='1' then   -- the latch for the CB2 is from low to high
		if CB2'event and CB2='1' then irqbf2_2<='1'; end if;
	end if;
	CRB(6)<=irqbf2_1 or irqbf2_2; -- flag bit
-------------------		
END PROCESS;

END bhv1;

