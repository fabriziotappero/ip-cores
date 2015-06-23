------------------------------------------------------------------------------
-- Two shift registers are used, when nr1 is full and nr2  is empty
-- they are nr1 is mapped on nr2 in a reverse-zigzag order. Additionally
-- the "matrix" is transposed to compensate transponation of successional
-- the idct-core.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity jpeg_dezigzag is
	port(	
		Clk 		: in std_logic; 
		context_i: in std_logic_vector(3 downto 0);
		data_i	: in std_logic_vector(11 downto 0);
		reset_i	: in std_logic;
		
		context_o: out std_logic_vector(3 downto 0);
		data_o 	: out std_logic_vector(11 downto 0);

		-- flow control
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
	);
end entity jpeg_dezigzag;





architecture IMP of jpeg_dezigzag is
	
	type sr is array (0 to 63) of std_logic_vector(11 downto 0);
	signal sr_in, sr_out : sr := (others=>X"000");
	signal ce_in, ce_out : std_logic :='0';
	signal counter_in  : std_logic_vector(5 downto 0) :=(others=>'0');
	signal counter_out : std_logic_vector(5 downto 0) :=(others=>'0');
	signal do_copy, do_copy_D : std_logic :='0';
	signal stop_in,  stop_in_D  : std_logic :='0';
	signal stop_out, stop_out_D : std_logic :='1';
	signal stop_eoi_out, stop_eoi_out_D : std_logic := '1';
	signal context, context_D : std_logic_vector(3 downto 0) :=(others=>'0');
	signal eoi, eoi_D : std_logic :='0'; 
	signal eoi_hold, eoi_hold_D : std_logic :='0'; 
	signal ready, ready_D : std_logic :='1';







begin



ready_o		<= ready;
datavalid_o	<= (ce_out and not do_copy);
data_o 		<= sr_out(0);	
context_o	<= context;

process(ready, counter_in, do_copy)
begin
	ready_D <= ready;
	if (counter_in=63) then
		ready_D <='0';
	elsif(do_copy='1') then 
		ready_D<='1';
	end if;
end process;
process(Clk)
begin
	if rising_edge(Clk) then
		if(reset_i='1') then
			ready <='1';
		elsif ce_in='1' then
			ready <= ready_D;
		end if;
	end if;
end process;


process(stop_eoi_out, counter_in, do_copy)
begin
	stop_eoi_out_D <= stop_eoi_out;
	if (counter_in=1) then
		stop_eoi_out_D <='1';
	elsif(do_copy='1') then 
		stop_eoi_out_D<='0';
	end if;
end process;
process(Clk)
begin
	if rising_edge(Clk) then
		if(reset_i='1') then
			stop_eoi_out <='1';
		elsif ce_in='1' then
			stop_eoi_out <= stop_eoi_out_D;
		end if;
	end if;
end process;



-- handle the context
process(eoi, eoi_hold, context_i, counter_out, do_copy, stop_eoi_out)
begin
	eoi_D <= eoi;
	eoi_hold_D <= eoi_hold;
	if (context_i(3)='1' and do_copy='0' and stop_eoi_out='1') then
		eoi_hold_D <= '1';
	elsif(context_i(3)='1' and (do_copy='1' and stop_eoi_out='1')) then
		eoi_D <= '1';
		eoi_hold_D <= '0';
	elsif(context_i(3)='1' and stop_eoi_out='0') then
		eoi_D <= '1';
		eoi_hold_D <= '0';
	elsif(eoi_hold='1' and do_copy='1') then
		eoi_D <= '1';
		eoi_hold_D <= '0';
	end if;
	if (counter_out=63 and eoi='1') then
		eoi_D <= '0';
		eoi_hold_D <= '0';
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		eoi		<= eoi_D;
		eoi_hold <= eoi_hold_D;
		context	<= '0' & '0' & context(1 downto 0);		
		if counter_in=60 then
			context_D <= context_i;
		end if;
		if do_copy='1' then
			context <= context_D;
		end if;

		if reset_i='1' then
			context <= (others=>'0');
			eoi <='0';
			eoi_hold <='0';
		elsif counter_out=63 and ce_out='1' then  
			context(3)	<= eoi;
		end if;

	end if;
end process;





-- SHIFT_IN
process(Clk)
begin
	if rising_edge(Clk) then
	if reset_i='1' then
		sr_in <= (others=>X"000");
		counter_in <= (others=>'0');
	elsif ce_in='1' and do_copy='0' then
		sr_in <= sr_in(1 to 63) & data_i;	
		counter_in <= counter_in+1;
	end if;
	end if;
end process;

process(datavalid_i, stop_in, do_copy)
begin
	if datavalid_i='1' and stop_in='0' then
		ce_in <='1';
	elsif(do_copy='1') then
		ce_in <= '1';
	else
		ce_in <='0';
	end if;
end process;

process(counter_in, do_copy, ce_in)
begin
	stop_in_D <= stop_in;
	if(do_copy='1') then
		stop_in_D <= '0';
	elsif counter_in="111111" and ce_in='1' then
		stop_in_D <= '1';
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
	if reset_i='1' then
		stop_in <= '0'; 
	else
		stop_in <= stop_in_D;
	end if;
	end if;
end process;





-- DO_COPY
process(stop_in, stop_out)
begin
	if stop_in ='1' and stop_out='1' then 
		do_copy_D <= '1';
	else
		do_copy_D <= '0';
	end if;
end process;
process(Clk)
begin
	if rising_edge(Clk) then
		if(reset_i='1') then
			do_copy <='0';
		else
		do_copy <= do_copy_D;	
		end if;
	end if;
end process;




-- SHIFT_OUT
process(Clk)
begin
	if rising_edge(Clk) then
	
		if reset_i='1' then
			sr_out <= (others=>X"000");
			counter_out <= (others=>'0');
		elsif do_copy='1' then
	
--		-- do the Zig-Zag Mapping
--			sr_out(00) <= sr_in(00);	
--			sr_out(01) <= sr_in(01);	
--			sr_out(02) <= sr_in(05);	
--			sr_out(03) <= sr_in(06);	
--			sr_out(04) <= sr_in(14);	
--			sr_out(05) <= sr_in(15);	
--			sr_out(06) <= sr_in(27);	
--			sr_out(07) <= sr_in(28);	
--			sr_out(08) <= sr_in(02);	
--			sr_out(09) <= sr_in(04);	
--			sr_out(10) <= sr_in(07);	
--			sr_out(11) <= sr_in(13);	
--			sr_out(12) <= sr_in(16);	
--			sr_out(13) <= sr_in(26);	
--			sr_out(14) <= sr_in(29);	
--			sr_out(15) <= sr_in(42);	
--			sr_out(16) <= sr_in(03);	
--			sr_out(17) <= sr_in(08);	
--			sr_out(18) <= sr_in(12);	
--			sr_out(19) <= sr_in(17);	
--			sr_out(20) <= sr_in(25);	
--			sr_out(21) <= sr_in(30);	
--			sr_out(22) <= sr_in(41);	
--			sr_out(23) <= sr_in(43);	
--			sr_out(24) <= sr_in(09);	
--			sr_out(25) <= sr_in(11);	
--			sr_out(26) <= sr_in(18);	
--			sr_out(27) <= sr_in(24);	
--			sr_out(28) <= sr_in(31);	
--			sr_out(29) <= sr_in(40);	
--			sr_out(30) <= sr_in(44);	
--			sr_out(31) <= sr_in(53);	
--			sr_out(32) <= sr_in(10);	
--			sr_out(33) <= sr_in(19);	
--			sr_out(34) <= sr_in(23);	
--			sr_out(35) <= sr_in(32);	
--			sr_out(36) <= sr_in(39);	
--			sr_out(37) <= sr_in(45);	
--			sr_out(38) <= sr_in(52);	
--			sr_out(39) <= sr_in(54);	
--			sr_out(40) <= sr_in(20);	
--			sr_out(41) <= sr_in(22);	
--			sr_out(42) <= sr_in(33);	
--			sr_out(43) <= sr_in(38);	
--			sr_out(44) <= sr_in(46);	
--			sr_out(45) <= sr_in(51);	
--			sr_out(46) <= sr_in(55);	
--			sr_out(47) <= sr_in(60);	
--			sr_out(48) <= sr_in(21);	
--			sr_out(49) <= sr_in(34);	
--			sr_out(50) <= sr_in(37);	
--			sr_out(51) <= sr_in(47);	
--			sr_out(52) <= sr_in(50);	
--			sr_out(53) <= sr_in(56);	
--			sr_out(54) <= sr_in(59);	
--			sr_out(55) <= sr_in(61);	
--			sr_out(56) <= sr_in(35);	
--			sr_out(57) <= sr_in(36);	
--			sr_out(58) <= sr_in(48);	
--			sr_out(59) <= sr_in(49);	
--			sr_out(60) <= sr_in(57);	
--			sr_out(61) <= sr_in(58);	
--			sr_out(62) <= sr_in(62);	
--			sr_out(63) <= sr_in(63);	
		-- additionally transpose the inputx matrix
		-- to compensate the column-wise output of the successional idct-entity
			sr_out(00) <= sr_in(00);	
			sr_out(08) <= sr_in(01);	
			sr_out(16) <= sr_in(05);	
			sr_out(24) <= sr_in(06);	
			sr_out(32) <= sr_in(14);	
			sr_out(40) <= sr_in(15);	
			sr_out(48) <= sr_in(27);	
			sr_out(56) <= sr_in(28);	
			sr_out(01) <= sr_in(02);	
			sr_out(09) <= sr_in(04);	
			sr_out(17) <= sr_in(07);	
			sr_out(25) <= sr_in(13);	
			sr_out(33) <= sr_in(16);	
			sr_out(41) <= sr_in(26);	
			sr_out(49) <= sr_in(29);	
			sr_out(57) <= sr_in(42);	
			sr_out(02) <= sr_in(03);	
			sr_out(10) <= sr_in(08);	
			sr_out(18) <= sr_in(12);	
			sr_out(26) <= sr_in(17);	
			sr_out(34) <= sr_in(25);	
			sr_out(42) <= sr_in(30);	
			sr_out(50) <= sr_in(41);	
			sr_out(58) <= sr_in(43);	
			sr_out(03) <= sr_in(09);	
			sr_out(11) <= sr_in(11);	
			sr_out(19) <= sr_in(18);	
			sr_out(27) <= sr_in(24);	
			sr_out(35) <= sr_in(31);	
			sr_out(43) <= sr_in(40);	
			sr_out(51) <= sr_in(44);	
			sr_out(59) <= sr_in(53);	
			sr_out(04) <= sr_in(10);	
			sr_out(12) <= sr_in(19);	
			sr_out(20) <= sr_in(23);	
			sr_out(28) <= sr_in(32);	
			sr_out(36) <= sr_in(39);	
			sr_out(44) <= sr_in(45);	
			sr_out(51) <= sr_in(52);	
			sr_out(60) <= sr_in(54);	
			sr_out(05) <= sr_in(20);	
			sr_out(13) <= sr_in(22);	
			sr_out(21) <= sr_in(33);	
			sr_out(29) <= sr_in(38);	
			sr_out(37) <= sr_in(46);	
			sr_out(45) <= sr_in(51);	
			sr_out(53) <= sr_in(55);	
			sr_out(61) <= sr_in(60);	
			sr_out(06) <= sr_in(21);	
			sr_out(14) <= sr_in(34);	
			sr_out(22) <= sr_in(37);	
			sr_out(30) <= sr_in(47);	
			sr_out(38) <= sr_in(50);	
			sr_out(46) <= sr_in(56);	
			sr_out(54) <= sr_in(59);	
			sr_out(62) <= sr_in(61);	
			sr_out(07) <= sr_in(35);	
			sr_out(15) <= sr_in(36);	
			sr_out(23) <= sr_in(48);	
			sr_out(31) <= sr_in(49);	
			sr_out(39) <= sr_in(57);	
			sr_out(47) <= sr_in(58);	
			sr_out(55) <= sr_in(62);	
			sr_out(63) <= sr_in(63);
		elsif ce_out='1' and do_copy='0' then
			sr_out <= sr_out(1 to 63) & X"000";
			counter_out <= counter_out+1;
		end if;
		
	end if;
end process;


process(ready_i, stop_out, do_copy)
begin
	if ready_i='1' and stop_out='0' then
		ce_out <='1';
	elsif(do_copy='1') then
		ce_out <= '1';
	else
		ce_out <='0';
	end if;
end process;


process(counter_out, do_copy, ce_out)
begin
	stop_out_D <= stop_out;
	if(do_copy='1') then
		stop_out_D <= '0';
	elsif counter_out="111111" and ce_out='1' then
		stop_out_D <= '1';
	end if;
end process;


process(Clk)
begin
	if rising_edge(Clk) then
	if reset_i='1' then
		stop_out <= '1'; 
	else
		stop_out <= stop_out_D;
	end if;
	end if;
end process;


end IMP;
