----------------------------------------------------------------------------------
-- Company: Gerhard Hohner
-- Engineer: Gerhard Hohner
-- 
-- Create Date:    07:41:47 12/14/2010 
-- Design Name:    2Q cache
-- Module Name:    Cache - Rtl 
-- Project Name: 
-- Target Devices: designed for spartan 3A, but no dependecies
-- Tool versions: 
-- Description: implements 2Q cache strategy, write back
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE, work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.global.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Cache is
  generic( constant blocksizeld: integer := 11;                         -- ld of size of one tagram 
			  constant ldways: integer := 1;                               -- ld of number of tagrams
			  constant ldCachedWords: integer := 2);                       -- ld of number of 32-bit words
                                                                        -- in one cacheline
  port( nReset: in std_ulogic;                                          -- System reset active low
        Clock: in std_ulogic;                                           -- System Clock
		  AddressIn: in std_ulogic_vector(RAMrange'high + 1 downto 0);    -- Address of memory fetch
		  DataIn: in std_ulogic_vector( 31 downto 0);                     -- Data to write
	     IOCode: in std_ulogic_vector(2 downto 0);		     		 	   	-- operation
		                                                                  -- Bit
																								--  2    0 read
																								--       1 write
																								-- 1 0   11 word
																								--       10 halfword
																								--       01 single byte
																								--       00 no operation
		  DataOut: out std_ulogic_vector( 31 downto 0);                   -- Data read
		  done: out std_ulogic;
		  -- memory interface
		  AddressOut: out std_ulogic_vector(RAMrange'high downto 0);	   -- memory address
		  DataBlockIn: in std_ulogic_vector( 2 ** ldCachedWords * 32 - 1 downto 0);   -- data from memory
		  reads: out std_ulogic;                                                      -- read memory
		  DataBlockOut: out std_ulogic_vector( 2 ** ldCachedWords * 32 - 1 downto 0); -- data to memory
		  Mask: out std_ulogic_vector( 2 ** ldCachedWords * 4 - 1 downto 0);          -- enables for each byte active low
		  writes: out std_ulogic;                                                     -- write memory
		  led: out std_ulogic_vector(0 to 1);                                         -- control led for tests
		  ack: in std_ulogic                                                          -- acknowledge from memory
		);
end Cache;

architecture Rtl of Cache is
constant ways: integer := 2 ** ldways;                 -- number of tagrams
constant ldqueue: integer := 1;                        -- ld of number of fifos ( 1 for 2Q strategy)
-- next two constants can be modified
constant ldram: integer := blocksizeld + ldways - 1;   -- ld of size of cacheram
constant ldqueuelength: integer := ldram;              -- ld of size of one fifo

type IOType is ( Start, busy);
type tType is ( inittag, startt, startt1, tagtest, tagwait, stateget, stateget1, finish);
type rType is ( raminit, ramstart, ramstart1, ramcheck, ramcheck1, ramcheck2, ramread, ramread1, ramupdate,
                ramupdate1, ramupdate2, ramupdate3, ramflush, ramflush1, ramwait, ramwait1, ramclean, ramclean1);
type fType is ( queuestart, queuewait, queuewaitAm1, queuewaitAm2, queuewaitA11, queuewaitA12, queueelim);
subtype myint is natural range 15 downto 0;
type TagRAMType is record
  cacheAddr: std_ulogic_vector( ldram - 1 downto 0);
  cacheValid: std_ulogic;
  Tag: std_ulogic_vector( RAMrange'high downto 2 + ldCachedWords + blocksizeld);
  TagValid: std_ulogic;
end record;
type WordType is record
  Word: std_ulogic_vector(31 downto 0);
  Modified: std_ulogic_vector( 3 downto 0);
end record;
type WordArray is array ( 2 ** ldCachedWords - 1 downto 0) of WordType;
type CacheType is record
  Words: WordArray;
  FiFoaddr: std_ulogic_vector( ldqueuelength - 1 downto 0);
  counter: std_ulogic_vector( ldqueue - 1 downto 0);
end record;
type FiFoType is record
  Word: std_ulogic_vector( blocksizeld - 1 downto 0);
  way: std_ulogic_vector( ldways downto 0);
  valid: std_ulogic;
end record;

type TagRAMarray is array ( ways - 1 downto 0) of TagRAMType;
type TagBuffer is array ( ways - 1 downto 0) of std_ulogic_vector( RAMrange'high - ldCachedWords - blocksizeld - 2 + ldram + 2 downto 0);
type TagFile is array ( 2 ** blocksizeld - 1 downto 0) of std_ulogic_vector( RAMrange'high - ldCachedWords - blocksizeld - 2 + ldram + 2 downto 0);
type TagFiles is array ( ways - 1 downto 0) of TagFile;

type RAMFile is array ( 2 ** ldram - 1 downto 0) of std_ulogic_vector( 35 downto 0);
type RAMFiles is array ( 2 ** ldCachedWords - 1 downto 0) of RAMFile;
type RAMBuffer is array ( 2 ** ldCachedWords - 1 downto 0) of std_ulogic_vector( 35 downto 0);
type AFile is array ( 2 ** ldram - 1 downto 0) of std_ulogic_vector( ldqueuelength + ldqueue - 1 downto 0);

type myarrayf is array ( 2 ** ldram - 1 downto 0) of std_ulogic_vector( ldram - 1 downto 0);
type myarrayA is array ( 2 ** ldram - 1 downto 0) of std_ulogic_vector( blocksizeld + ldways + 1 downto 0);

signal RAMs: RAMFiles;
signal Ax: AFile;
signal tagRAM: TagFiles;
signal tagdummy, tagBuff, TagRAMIn, TagRAMOut: TagRAMarray;
signal RecBuff, CacheIn, CacheOut: CacheType;
signal blockIn, blockOut: WordArray;
signal DataInh: std_ulogic_vector( 31 downto 0);
signal A1In, A1Out, AmIn, AmOut: FiFoType;
signal putA1, removeA1, getA1, emptyA1, fullA1: std_ulogic;
signal putAm, removeAm, getAm, emptyAm, fullAm: std_ulogic;
signal A1Inaddr, A1Outaddr, AmInaddr, AmOutaddr: std_ulogic_vector( ldqueuelength - 1 downto 0);
signal emptyf, getf, putf: std_ulogic;
signal queueentry: std_ulogic_vector( blocksizeld - 1 downto 0);
signal cindex, FreeOut, FreeIn: std_ulogic_vector( ldram - 1 downto 0);
signal ramf: myarrayf;
signal counterf: unsigned( ldram downto 0);
signal firstf, lastf: unsigned( ldram - 1 downto 0);
signal newFiFoAddr: std_ulogic_vector( ldqueuelength - 1 downto 0);
signal newcounter: std_ulogic_vector( ldqueue - 1 downto 0);
signal initcount: unsigned( blocksizeld - 1 downto 0);
signal initcount1: unsigned( ldram - 1 downto 0);
signal ramA1: myarrayA;
signal counterA1: unsigned( ldqueuelength downto 0);
signal firstA1, lastA1: unsigned( ldqueuelength - 1 downto 0);
signal ramAm: myarrayA;
signal counterAm: unsigned( ldqueuelength downto 0);
signal firstAm, lastAm: unsigned( ldqueuelength - 1 downto 0);

signal AddressInh: std_ulogic_vector( AddressIn'range);
signal IOCodeh: std_ulogic_vector( IOCode'range);
signal AddressInt: std_ulogic_vector( 2 + ldCachedWords + blocksizeld - 1 downto 2 + ldCachedWords);
signal found, free, elim, del: myint;
signal stateIO: IOType;
signal statetag: tType;
signal stateram: rType;
signal statequeue: fType;
signal entered, enableram, enablequeue, queuedone, readsh, writesh, doneh, cleared,
       interrupt, readb, writeb, writec, writet, accdone, accqueue, accinterrupt: std_ulogic;

begin
  
  
  
  blockIO: process( nReset, Clock, readb, writeb) is
  variable s: std_ulogic;
  begin
    if nReset /= '1' then
	   writesh <= '0';
		readsh <= '0';
		stateIO <= start;
    elsif rising_edge(Clock) then
	   case stateIO is
		when start =>
		  if readb = '1' then
			 Mask <= ( others => '1');
			 readsh <= '1';
		    stateIO <= busy;
		  elsif writeb = '1' then
		    s := '0';
			 
		    for i in blockOut'range loop
		      DataBlockOut( ( i + 1) * 32 - 1 downto i * 32) <= blockOut( i).word;
			   Mask( ( i + 1) * 4 - 1 downto i * 4) <= not blockOut( i).Modified;
				s := s or blockOut( i).Modified(0) or blockOut( i).Modified(1) or
				          blockOut( i).Modified(2) or blockOut( i).Modified(3);
			 end loop;
			 
			 writesh <= s;
			 
			 if s = '1' then
		      stateIO <= busy;
			 end if;
		  end if;
		when busy =>
		  if ack = '1' then
		    stateIO <= start;

		    if readsh = '1' then
			   for i in blockIn'range loop
		        blockIn( i).word <= DataBlockIn( ( i + 1) * 32 - 1 downto i * 32);
				  blockIn( i).Modified <= ( others => '0');
				end loop;
		    end if;
		  
		    readsh <= '0';
		    writesh <= '0';
		  end if;
		end case;
	 end if;
  end process blockIO;
  
  writes <= writesh;
  reads <= readsh;
  
  tagrams: process ( nReset, Clock) is
  variable a, b, d: myint;
  variable DataInTag, DataOutTag: TagBuffer;
  begin
  if rising_edge(Clock) then
    if nReset /= '1' then
	   statetag <= inittag;
		writet <= '0';
		enableram <= '0';
		found <= 15;
		free <= 15;
		initcount <= ( others => '0');
		AddressInt <= ( others => '0');
		IOCodeh <= ( others => '0');
		AddressInh <= ( others => '0');
	 else
		
	   case statetag is
		  when inittag =>
		    for i in tagRAMIn'range loop
			   tagRAMIn(i).tagValid <= '0';
			   tagRAMIn(i).tag <= ( others => '0');
			   tagRAMIn(i).cacheValid <= '0';
			   tagRAMIn(i).cacheAddr <= ( others => '0');
			 end loop;
			 AddressInt <= std_ulogic_vector(initcount);
			 initcount <= initcount + 1;
			 if unsigned( not AddressInt) = 0 then
		      statetag <= startt;
			   writet <= '0';
			 else
			   writet <= '1';
			 end if;
		  when startt =>
		    -- valid IOCode and valid address?
		    if IOCode( 1 downto 0) /= "00" and AddressIn( AddressIn'high) = '0' then
		      -- request encountered
				AddressInh <= AddressIn;
				IOCodeh <= IOCode;
		      AddressInt <= AddressIn( AddressInt'range);
				DataInh <= DataIn;
		      statetag <= startt1;
		    end if;
			 
			 writet <= '0';
		  when startt1 =>
		    statetag <= tagtest;
		  when tagtest =>
          a := 15;
		    b := 15;
	 
	       for i in 0 to TagRAMarray'high loop
		      if tagRAMOut( i).tagValid = '1' then
	           if AddressInh(tagRAMout( i).tag'range) = tagRAMout( i).tag then
		          a := i; -- present
				  end if;
		      else
			     b := i; -- free entry
		      end if;
	       end loop;
		  
		    found <= a;
		    free <= b;
		  
		    if stateram = ramstart then
		      enableram <= '1';
		      statetag <= tagwait;
			 end if;
		  when tagwait =>
		    writet <= '0';
			 
		    if interrupt = '1' then
		      enableram <= '0';
			   AddressInt <= queueentry;
				statetag <= stateget;
			 elsif queuedone = '1' then
		      enableram <= '0';
			   statetag <= finish;
			 end if;
		  when stateget =>
			 statetag <= stateget1;
		  when stateget1 =>
		    enableram <= '1';
			 tagDummy <= tagRAMOut;
			 
			 for i in tagRAMIn'range loop
			   if del = i then
		        tagRAMIn( i).tagvalid <= '0';
			     tagRAMIn( i).cacheValid <= '0';
			     tagRAMIn( i).tag <= ( others => '0');
			     tagRAMIn( i).cacheAddr <= ( others => '0');
				  writet <= '1';
			   else
			     tagRAMIn( i) <= tagRAMOut( i);
			   end if;
			 end loop;
			  
			 statetag <= tagwait;
		  when finish =>
		    if doneh = '1' then
			   tagRAMIn <= tagBuff;
				writet <= '1';
		      AddressInt <= AddressInh( AddressInt'range);
		      statetag <= startt;
		    end if;
		end case;
	 
	 for i in tagRAM'range loop
      DataInTag( i) := TagRAMIn( i).TagValid & TagRAMIn( i).Tag & TagRAMIn( i).cacheValid & TagRAMIn( i).cacheAddr;
	 
	   if writet = '1' then
		  tagRAM(i)(to_integer( AddressInt)) <= DataInTag( i);
		  led(0) <= '1';
		  led(1) <= '0';
		else
		  DataOutTag( i) := tagRAM(i)(to_integer( AddressInt));
		  
	     TagRAMOut( i).cacheAddr <= DataOutTag( i)( ldram - 1 downto 0);
	     TagRAMOut( i).cacheValid <= DataOutTag( i)( ldram);
	     TagRAMOut( i).Tag <= DataOutTag( i)( DataOutTag( 0)'high - 1 downto ldram + 1);
	     TagRAMOut( i).TagValid <= DataOutTag( i)( DataOutTag( 0)'high);
		  led(0) <= '0';
		  led(1) <= '1';
		end if;
	 end loop;
	 end if;
  end if;
  end Process tagrams;
  
  dataram: process (nReset, Clock, enableram) is
  variable en, acc, hi: std_ulogic;
  variable f, g: std_ulogic_vector( ldqueuelength + ldqueue - 1 downto 0);
  variable a, b: RAMBuffer;
  variable index, index1: integer;
  
  variable address: std_ulogic_vector( ldram - 1 downto 0);
  variable uaddress: unsigned( ldram - 1 downto 0);
  variable datum:  std_ulogic_vector( FreeIn'range);
  variable w: std_ulogic;
  begin
  if rising_edge(Clock) then
    if nReset /= '1' then
	   enablequeue <= '0';
	   stateram <= raminit;
		writec <= '0';
		writeb <= '0';
		readb <= '0';
		getf <= '0';
		doneh <= '0';
		elim <= 15;
		accinterrupt <= '0';
		accqueue <= '0';
		initcount1 <= ( others => '0');
		FreeIn <= ( others => '0');
		firstf <= ( others => '0');
		lastf <= ( others => '0');
		counterf <= ( others => '0');
		entered <= '0';
	 else
	   hi := accinterrupt or interrupt;
		acc := accqueue or queuedone;
		en := enablequeue and ( hi nor acc);
		
		if ldCachedWords = 0 then
		  index := 0;
		else
		  index := to_integer( AddressInh( ldCachedWords + 1 downto 2));
		end if;
		
	   case stateram is
		  when raminit =>
			 FreeIn <= std_ulogic_vector( initcount1);
          initcount1	<= initcount1 + 1;
			 
			 if unsigned( not FreeIn) = 0 then
			   stateram <= ramstart;
			   putf <= '0';
			 else
			   putf <= '1';
			 end if;
		  when ramstart =>
		    putf <= '0';
			 
		    if enableram = '1' then
			   if entered = '0' then
				  tagBuff <= tagRAMOut;
				  elim <= 15;
				  entered <= '1';
				end if;
				
				stateram <= ramstart1;
			 end if;
		  when ramstart1 =>
		    putf <= '0';
			 
		    if enableram = '1' then
				if found /= 15 then
				  cindex <= tagBuff( found).cacheAddr;
				  writec <= '0';
				  stateram <= ramupdate;
				elsif free /= 15 then
				  en := '1';
				  stateram <= ramwait;
				else
				  elim <= 0;
				  stateram <= ramcheck;
				end if;
			 end if;
		  when ramcheck =>
			 writec <= '0';
			 cindex <= tagBuff( elim).cacheAddr;
		    stateram <= ramcheck1;
		  when ramcheck1 =>
		    stateram <= ramcheck2;
		  when ramcheck2 =>
		    if cacheOut.counter(0) = '0' or elim = ways - 1 then
			   RecBuff <= cacheOut;
				en := '1';
		      stateram <= ramwait;
			 else
			   elim <= elim + 1;
		      stateram <= ramcheck;
			 end if;
		  when ramupdate =>
		    stateram <= ramupdate1;
			 putf <= '0';
		  when ramupdate1 =>
		    cacheIn <= cacheOut;
			 blockOut <= cacheOut.Words;
			 RecBuff <= cacheOut;
			 en := '1';
			 stateram <= ramwait;
		  when ramwait =>
			 doneh <= '0';
			 writec <= '0';
			 
		    if hi = '1' then
				stateram <= ramwait1;
			 elsif acc = '1' then
			   if found /= 15 then
				  cindex <= tagBuff( found).cacheAddr;
				  cacheIn <= RecBuff;
				  blockOut <= RecBuff.Words;
				  stateram <= ramupdate2;
				elsif free /= 15 then
				  cindex <= FreeOut;
				  tagBuff( free).cacheAddr <= FreeOut;
				  tagBuff( free).cacheValid <= '1';
				  tagBuff( free).tag <= AddressInh( tagBuff( free).tag'range);
				  tagBuff( free).tagValid <= '1';
				  getf <= '1';
				  if IOCodeh = "111" and ldCachedWords = 0 then
				    stateram <= ramupdate2;
				  else
				    readb <= '1';
			       AddressOut <= AddressInh( AddressOut'range);
				    stateram <= ramread;
				  end if;
				else
				  cindex <= tagBuff( elim).cacheAddr;
				  cacheIn <= RecBuff;
				  blockOut <= RecBuff.Words;
				  AddressOut <= tagBuff( elim).tag & AddressInh( AddressInt'range) & ( ldCachedWords + 1 downto 0 => '0');
		        writeb <= '1';
				  stateram <= ramflush;
				end if;
			 end if;
		  when ramwait1 =>
			 if del /= 15 and enableram = '1' then
			   cindex <= tagdummy( del).cacheAddr;
				FreeIn <= tagdummy( del).cacheAddr;
				putf <= tagdummy( del).cacheValid;
			   writec <= '0';
			   stateram <= ramclean;
			 end if;
		  when ramread =>
		    readb <= '0';
			 getf <= '0';
		    stateram <= ramread1;
		  when ramread1 =>
		    if readsh = '0' then
			   for i in blockIn'range loop
				  cacheIn.Words( i) <= blockIn( i);
				end loop;
		      stateram <= ramupdate2;
			 end if;
		  when ramupdate2 =>
		    if IOCodeh(2) = '1' then
			   if IOCodeh(1) = '1' then
				  If IOCodeh(0) = '1' then
				    cacheIn.Words( index).Word <= DataInh;
					 cacheIn.Words( index).Modified <= "1111";
				  elsif AddressInh(1) = '1' then
				    cacheIn.Words( index).Word( 31 downto 16) <= DataInh( 15 downto 0);
					 cacheIn.Words( index).Modified( 3 downto 2) <= "11";
				  else
				    cacheIn.Words( index).Word( 15 downto 0) <= DataInh( 15 downto 0);
					 cacheIn.Words( index).Modified( 1 downto 0) <= "11";
				  end if;
				else
				  if AddressInh(1) = '0' then
				    if AddressInh(0) = '0' then
					   cacheIn.Words( index).Word( 7 downto 0) <= DataInh( 7 downto 0);
						cacheIn.Words( index).Modified(0) <= '1';
				    else
					   cacheIn.Words( index).Word( 15 downto 8) <= DataInh( 7 downto 0);
						cacheIn.Words( index).Modified(1) <= '1';
					 end if;
				  else
				    if AddressInh(0) = '0' then
					   cacheIn.Words( index).Word( 23 downto 16) <= DataInh( 7 downto 0);
						cacheIn.Words( index).Modified(2) <= '1';
				    else
					   cacheIn.Words( index).Word( 31 downto 24) <= DataInh( 7 downto 0);
						cacheIn.Words( index).Modified(3) <= '1';
					 end if;
				  end if;
				end if;
			 else
			   DataOut <= cacheIn.Words( index).Word;
			 end if;
			 
			 cacheIn.FiFoAddr <= newFiFoAddr;
			 cacheIn.counter <= newcounter;
			 
			 getf <= '0';
			 writec <= '1';
			 doneh <= '1';
			 entered <= '0';
			 
			 stateram <= ramupdate3;
		  when ramupdate3 =>
		    hi := '0';
			 acc := '0';
			 en := '0';
			 writec <= '0';
			 putf <= '0';
		    doneh <= '0';
			 stateram <= ramstart;
		  when ramclean =>
		    putf <= '0';
		    stateram <= ramclean1;
		  when ramclean1 =>
			 if del /= 15 then
			   blockOut <= cacheOut.words;
				writeb <= tagdummy( del).tagValid;
				AddressOut <= tagdummy( del).tag & queueentry & ( ldCachedWords + 1 downto 0 => '0');
			   stateram <= ramflush;
			 end if;
		  when ramflush =>
		    writeb <= '0';
			 for i in blockIn'range loop
		      cacheIn.Words( i).Word <= ( others => '0');
			   cacheIn.Words( i).Modified <= ( others => '0');
			 end loop;
			 
			 stateram <= ramflush1;
		  when ramflush1 =>
			 if writesh = '0' then
			   if del /= 15 and hi = '1' then
				  doneh <= '1';
				  en := '1';
				  hi := '0';
			     stateram <= ramwait;
				else
				  tagBuff( elim).tag <= AddressInh( tagBuff( elim).tag'range);
				  tagBuff( elim).tagValid <= '1';
				  if IOCodeh = "111" and ldCachedWords = 0 then
				    stateram <= ramupdate2;
				  else
				    readb <= '1';
				    AddressOut <= AddressInh( AddressOut'range);
				    stateram <= ramread;
				  end if;
				end if;
			 end if;
		end case;
		
		accinterrupt <= hi;
		enablequeue <= en;
		accqueue <= acc;
	 
	 f := CacheIn.counter & CacheIn.FiFoAddr;
	 if writec = '1' then
	   Ax( to_integer( cindex)) <= f;
	 else
	   g := Ax( to_integer( cindex));
		CacheOut.FiFoAddr <= g( ldqueuelength - 1 downto 0);
		CacheOut.counter <= g( ldqueuelength + ldqueue - 1 downto ldqueuelength);
	 end if;
	 
	 for i in RAMBuffer'range loop
	   a( i) := CacheIn.Words( i).Modified & CacheIn.Words( i).Word;
		if writec = '1' then
		  RAMs( i)( to_integer( cindex)) <= a( i);
		else
		  b( i) := RAMs( i)( to_integer( cindex));
		  CacheOut.Words( i).Word <= b( i)( 31 downto 0);
		  CacheOut.Words( i).Modified <= b( i)( 35 downto 32);
		end if;
	 end loop;
	 
	 if putf = '1' then
	   address := std_ulogic_vector( firstf);
		datum := FreeIn;
		firstf <= firstf + 1;
		counterf <= counterf + 1;
		w := '1';
	 else
	   uaddress := lastf;
	   if getf = '1' and counterf /= 0 then
	     counterf <= counterf - 1;
		  uaddress := uaddress + 1;
	   end if;
		lastf <= uaddress;
		address := std_ulogic_vector( uaddress);
		w := '0';
	 end if;
		  
	 if w = '1' then
	   ramf( to_integer( address)) <= datum;
	 else
	   FreeOut <= ramf( to_integer( address));
	 end if;
	 
	 end if;
  end if;
  end process dataram;
  
  emptyf <= '1' when counterf = 0 else '0';

  done <= doneh and accqueue;
  
  queues: process( nReset, Clock, enablequeue) is
  variable acc, hi: std_ulogic;
  variable A1OutBuff, AmOutBuff: std_ulogic_vector( blocksizeld + ldways + 1 downto 0);
  variable addressA1: std_ulogic_vector( ldqueuelength - 1 downto 0);
  variable diff, uaddressA1: unsigned( ldqueuelength - 1 downto 0);
  variable datumA1:  std_ulogic_vector( A1OutBuff'range);
  variable wA1: std_ulogic;
  variable addressAm: std_ulogic_vector( ldqueuelength - 1 downto 0);
  variable uaddressAm: unsigned( ldqueuelength - 1 downto 0);
  variable datumAm:  std_ulogic_vector( AmOutBuff'range);
  variable wAm: std_ulogic;
  begin
  if rising_edge(Clock) then
    if nReset /= '1' then
	   statequeue <= queuestart;
	   queuedone <= '0';
		interrupt <= '0';
		accdone <= '0';
		cleared <= '0';
		del <= 15;
		firstA1 <= ( others => '0');
		A1Outaddr <= ( others => '0');
		lastA1 <= ( others => '0');
		counterA1 <= ( others => '0');
		firstAm <= ( others => '0');
		AmOutaddr <= ( others => '0');
		lastAm <= ( others => '0');
		counterAm <= ( others => '0');
	 else
	   hi := '0';
		acc := accdone or doneh;
		
		diff := firstA1 - unsigned( RecBuff.FiFoAddr); -- relative position in A1
		
	   case statequeue is
		  when queuestart =>
			 getA1 <= '0';
			 
		    if enablequeue = '1' then
			   if found /= 15 then
				  if RecBuff.counter(0) = '1' or                                -- in Am
				    ( RecBuff.counter(0) = '0' and diff( diff'high) = '0') then -- in lower half of A1
				    queuedone <= '1';
					 newFiFoAddr <= RecBuff.FiFoAddr;
					 newcounter <= RecBuff.counter;
			       statequeue <= queuewait;
				  elsif fullAm = '1' then
				    -- Am full
					 if AmOut.valid = '1' then
					   del <= to_integer( AmOut.way);
						queueentry <= AmOut.word;
						getAm <= '1';
					   hi := '1';
					   statequeue <= queuewait;
					 end if;
				  else
				    AmIn.word <= AddressInh( 2 + ldCachedWords + blocksizeld - 1 downto 2 + ldCachedWords);
					 AmIn.way <= std_ulogic_vector(to_unsigned( found, ldways + 1));
					 AmIn.valid <= '1';
					 putAm <= '1';
					 A1Inaddr <= RecBuff.FiFoAddr;
					 removeA1 <= '1';
					 statequeue <= queuewaitAm1;
				  end if;
				elsif free /= 15 then
				  if fullA1 = '1' or (emptyf = '1' and emptyA1 = '0') then
				    -- remove last entry from A1
					 if A1Out.valid = '1' then
					   del <= to_integer( A1Out.way);
					   queueentry <= A1Out.word;
					   getA1 <= '1';
					   hi := '1';
					   statequeue <= queuewait;
					 end if;
				  elsif fullAm = '1' and emptyf = '1' then
				    -- remove last entry from Am
					 if AmOut.valid = '1' then
					   del <= to_integer( AmOut.way);
					   queueentry <= AmOut.word;
					   getAm <= '1';
					   hi := '1';
					   statequeue <= queuewait;
					 end if;
				  else
				    A1In.word <= AddressInh( 2 + ldCachedWords + blocksizeld - 1 downto 2 + ldCachedWords);
					 A1In.way <= std_ulogic_vector(to_unsigned( free, ldways + 1));
					 A1In.valid <= '1';
					 putA1 <= '1';
					 statequeue <= queuewaitA11;
				  end if;
				elsif elim /= 15 then
				  if fullA1 = '1' then
				    if A1Out.valid = '1' then 
					   if not ( to_integer( A1Out.way) = elim and
						        A1Out.word = AddressInh( 2 + ldCachedWords + blocksizeld - 1 downto 2 + ldCachedWords)) then
					     del <= to_integer( A1Out.way);
					     queueentry <= A1Out.word;
					     statequeue <= queueelim;
					   end if;
						
					   getA1 <= '1';
					 end if;
				  else
				    A1In.word <= AddressInh( 2 + ldCachedWords + blocksizeld - 1 downto 2 + ldCachedWords);
					 A1In.way <= std_ulogic_vector(to_unsigned( elim, ldways + 1));
					 A1In.valid <= '1';
					 putA1 <= '1';
					 statequeue <= queueelim;
				  end if;
				end if;
			 end if;
		  when queuewait =>
			 removeA1 <= '0';
			 removeAm <= '0';
		    getAm <= '0';
		    getA1 <= '0';
			 queuedone <= '0';
			 
	       if acc = '1' then
			   acc := '0';
			   del <= 15;
			   statequeue <= queuestart;
			 end if;
		  when queuewaitAm1 =>
		    putAm <= '0';
			 removeA1 <= '0';
			 statequeue <= queuewaitAm2;
		  when queuewaitAm2 =>
			 newFiFoAddr <= AmOutAddr;
			 newCounter(0) <= '1';
			 queuedone <= '1';
			 statequeue <= queuewait;
		  when queuewaitA11 =>
		    putA1 <= '0';
			 statequeue <= queuewaitA12;
		  when queuewaitA12 =>
			 newFiFoAddr <= A1OutAddr;
			 newCounter(0) <= '0';
			 removeA1 <= '0';
			 removeAm <= '0';
			 queuedone <= '1';
		    cleared <= '0';
			 statequeue <= queuewait;
		  when queueelim =>
		    putA1 <= '0';
			 getA1 <= '0';
			 
			 if RecBuff.counter(0) = '1' and cleared = '0' then
			   AmInAddr <= RecBuff.FiFoAddr;
			   removeAm <= '1';
			 elsif cleared = '0' then
			   A1InAddr <= RecBuff.FiFoAddr;
			   removeA1 <= '1';
			 end if;
			 
			 if getA1 = '1' then
			   hi := '1';
				cleared <= '1';
			   statequeue <= queuewait;
			 else
			   statequeue <= queuewaitA12;
			 end if;
		end case;
		
		interrupt <= hi;
		accdone <= acc;
	 
	 if putA1 = '1' or removeA1 = '1' then
	   if removeA1 = '0' then
	     addressA1 := std_ulogic_vector( firstA1);
		  datumA1 := A1In.valid & A1In.way & A1In.Word;
		  firstA1 <= firstA1 + 1;
		  counterA1 <= counterA1 + 1;
		  A1Outaddr <= std_ulogic_vector( firstA1);
		else
		  addressA1 := A1Inaddr( addressA1'range);
		  datumA1 := ( others => '0');
		end if;
		wA1 := '1';
	 else
	   uaddressA1 := lastA1;
	   if (getA1 = '1' or A1Out.valid = '0') and counterA1 /= 0 then
	     counterA1 <= counterA1 - 1;
	     uaddressA1 := uaddressA1 + 1;
	   end if;
	   lastA1 <= uaddressA1;
	   addressA1 := std_ulogic_vector( uaddressA1);
	   wA1 := '0';
	 end if;
		  
	 if wA1 = '1' then
	   ramA1( to_integer( addressA1)) <= datumA1;
	 else
	   A1OutBuff := ramA1( to_integer( addressA1));

      A1Out.Word <= A1OutBuff( blocksizeld - 1 downto 0);
      A1Out.way <= A1OutBuff( blocksizeld + ldways downto blocksizeld);
		A1Out.valid <= A1OutBuff( blocksizeld + ldways + 1);
	 end if;
	 
	 if putAm = '1' or removeAm = '1' then
	   if removeAm = '0' then
	     addressAm := std_ulogic_vector( firstAm);
		  datumAm := AmIn.valid & AmIn.way & AmIn.Word;
		  firstAm <= firstAm + 1;
		  counterAm <= counterAm + 1;
		  AmOutaddr <= std_ulogic_vector( firstAm);
		else
		  addressAm := AmInaddr( addressAm'range);
		  datumAm := ( others => '0');
		end if;
		wAm := '1';
	 else
	   uaddressAm := lastAm;
	   if (getAm = '1' or AmOut.valid = '0') and counterAm /= 0 then
	     counterAm <= counterAm - 1;
	     uaddressAm := uaddressAm + 1;
	   end if;
	   lastAm <= uaddressAm;
	   addressAm := std_ulogic_vector( uaddressAm);
	   wAm := '0';
	 end if;
  
	 if wAm = '1' then
	   ramAm( to_integer( addressAm)) <= datumAm;
	 else
	   AmOutBuff := ramAm( to_integer( addressAm));
		
      AmOut.Word <= AmOutBuff( blocksizeld - 1 downto 0);
      AmOut.way <= AmOutBuff( blocksizeld + ldways downto blocksizeld);
		AmOut.valid <= AmOutBuff( blocksizeld + ldways + 1);
	 end if;
	 end if;
  end if;
  end process queues;

  fullA1 <= counterA1( counterA1'high);
  emptyA1 <= '1' when counterA1 = 0 else '0';

  fullAm <= counterAm( counterAm'high);
  emptyAm <= '1' when counterAm = 0 else '0';

end Rtl;

