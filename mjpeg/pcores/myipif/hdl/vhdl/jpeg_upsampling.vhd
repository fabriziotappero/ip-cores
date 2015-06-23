-------------------------------------------------------------------------------------------------
-- Two address ranges (indicated by the address-MSB) are used alternately as input and output buffer.
-- When the input buffer is full and the output buffer is empty, 'do_copy' toggles the address-MSB.
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jpeg_upsampling is
	port(
		Clk			: in  std_logic;
		reset_i		: in  std_logic;
		context_i	: in  std_logic_vector(3 downto 0);
		data_i		: in  std_logic_vector(8 downto 0);
		sampling_i	: in  std_logic_vector(3 downto 0);
		context_o	: out std_logic_vector(3 downto 0);
		Y_o			: out std_logic_vector(8 downto 0);
		Cb_o			: out std_logic_vector(8 downto 0);
		Cr_o			: out std_logic_vector(8 downto 0);
		datavalid_i	: in  std_logic;
		datavalid_o	: out std_logic;
		ready_i		: in  std_logic;
		ready_o		: out std_logic
	);
end entity;

 
architecture IMP of jpeg_upsampling is

	component jpeg_upsampling_buffer
	port (
		clka	: IN  std_logic;
		dina	: IN  std_logic_VECTOR(8 downto 0);
		addra	: IN  std_logic_VECTOR(10 downto 0);
		wea	: IN  std_logic_VECTOR(0 downto 0);
		clkb	: IN  std_logic;
		addrb	: IN  std_logic_VECTOR(10 downto 0);
		doutb	: OUT std_logic_VECTOR(8 downto 0)
	);
	end component;

	signal doutb_Y, doutb_Cb, doutb_Cr : std_logic_vector(8 downto 0) :=(others=>'0');

	signal addra_Y, addra_Cb, addra_Cr : std_logic_vector(10 downto 0) :=(others=>'0');
	signal addrb_Y, addrb_Cb, addrb_Cr : std_logic_vector(10 downto 0) :=(others=>'0');
	signal addrb_Y_short, addrb_Y_short_D : std_logic_vector(7 downto 0) :=(others=>'0');
	signal addrb_Cb_short, addrb_Cr_short, addrb_Cb_short_D, addrb_Cr_short_D : std_logic_vector(5 downto 0) :=(others=>'0');
	signal address_msb, address_msb_D : std_logic :='0';

	signal wea_Y   : std_logic_vector(0 downto 0) :=(others=>'1');
	signal wea_Y_D, wea_Y_rem : std_logic_vector(0 downto 0) :=(others=>'1');
	signal wea_Cb,   wea_Cr   : std_logic_vector(0 downto 0) :=(others=>'0');
	signal wea_Cb_D, wea_Cr_D, wea_Cb_rem, wea_Cr_rem : std_logic_vector(0 downto 0) :=(others=>'0');
	
	signal ce_in  : std_logic :='0';
	signal ce_out : std_logic :='0';
	signal counter_in, counter_in_D,  counter_in_hold  : std_logic_vector(8 downto 0) :=(others=>'0');
	signal counter_out,counter_out_D, counter_out_hold : std_logic_vector(7 downto 0) :=(others=>'1');
	signal counter_in_Y_max,  counter_in_Y_D_max  : std_logic_vector(8 downto 0) :=(others=>'0');
	signal counter_in_Cb_max, counter_in_Cb_D_max : std_logic_vector(8 downto 0) :=(others=>'0');
	signal counter_in_Cr_max, counter_in_Cr_D_max : std_logic_vector(8 downto 0) :=(others=>'0');
	signal do_copy,  do_copy_D, do_copy_delayed  : std_logic :='0';
	signal stop_in,  stop_in_D  : std_logic :='0';
	signal stop_out, stop_out_D : std_logic :='1';
	signal stop_eoi_out, stop_eoi_out_D : std_logic := '1';
	signal context_in, context_in_D, context_out, context_out_D : std_logic_vector(3 downto 0) :=(others=>'0');
	signal eoi, eoi_D	: std_logic :='0'; 
	signal eoi_hold, eoi_hold_D : std_logic :='0'; 
	signal ready, ready_D : std_logic :='1';
	signal datavalid : std_logic :='0';
	
	-- "00"->gray, "01"->4:2:0, "10"->4:2:2, "11"->4:4:4
	signal sampling_in, sampling_in_D, sampling_out, sampling_out_D : std_logic_vector(1 downto 0) :=(others=>'0');


begin


Y_buffer : jpeg_upsampling_buffer
		port map (
			clka => Clk,
			dina => data_i, 
			addra => addra_Y,
			wea => wea_Y,
			clkb => Clk,
			addrb => addrb_Y,
			doutb => doutb_Y 
		);
Cb_buffer : jpeg_upsampling_buffer
		port map (
			clka => Clk,
			dina => data_i, 
			addra => addra_Cb,
			wea => wea_Cb,
			clkb => Clk,
			addrb => addrb_Cb,
			doutb => doutb_Cb
		);
Cr_buffer : jpeg_upsampling_buffer
		port map (
			clka => Clk,
			dina => data_i, 
			addra => addra_Cr,
			wea => wea_Cr,
			clkb => Clk,
			addrb => addrb_Cr,
			doutb => doutb_Cr
		);
addra_Y  <=     address_msb & "00"   & counter_in(7  downto 0);
addra_Cb <=     address_msb & "0000" & counter_in(5  downto 0);
addra_Cr <=     address_msb & "0000" & counter_in(5  downto 0);
addrb_Y  <= not address_msb & "00"   & addrb_Y_short;
addrb_Cb <= not address_msb & "0000" & addrb_Cb_short;
addrb_Cr <= not address_msb & "0000" & addrb_Cr_short;
wea_Y(0)  <= wea_Y_rem(0)  and ce_in;
wea_Cb(0) <= wea_Cb_rem(0) and ce_in;
wea_Cr(0) <= wea_Cr_rem(0) and ce_in;




-- connect signals to the outside
process(Clk)
begin
	if rising_edge(Clk) then
		ready_o		<= ready;
		datavalid	<= ce_out;
		datavalid_o	<= datavalid;
		Y_o 			<= doutb_Y;	
		Cb_o 			<= doutb_Cb;	
		Cr_o 			<= doutb_Cr;		
		context_o	<= context_out;
	end if;
end process;



process(sampling_in, sampling_out)
begin
	case sampling_in is
		when "00" =>								-- gray 1 in (8x8 blocks)
			counter_in_hold   <= "000111111";
			counter_in_Y_max  <= "111111111";
			counter_in_Cb_max <= "111111111";
			counter_in_Cr_max <= "111111111";
		when "01" => 								-- 4:2:0 6 in
			counter_in_hold   <= "101111111";
			counter_in_Y_max  <= "011111111";
			counter_in_Cb_max <= "100111111";
			counter_in_Cr_max <= "101111111";
		when "10" => 								-- 4:2:2 4 in 
			counter_in_hold   <= "011111111";
			counter_in_Y_max  <= "001111111";
			counter_in_Cb_max <= "010111111";
			counter_in_Cr_max <= "011111111";
		when others => 							-- 4:4:4 3 in
			counter_in_hold   <= "010111111";
			counter_in_Y_max  <= "000111111";
			counter_in_Cb_max <= "001111111";
			counter_in_Cr_max <= "010111111";
	end case;
	case sampling_out is
		when "00" =>								-- gray  1 out
			counter_out_hold   <= "00111111";
		when "01" => 								-- 4:2:0  4 out
			counter_out_hold   <= "11111111";
		when "10" =>								-- 4:2:2  2 out
			counter_out_hold   <= "01111111"; 
		when others => 							-- 4:4:4  1 out
			counter_out_hold   <= "00111111";	
	end case;
end process;









----------------------------------------------------------
-- handle the write-enable
process(wea_Y_rem, wea_Cb_rem, wea_Cr_rem, counter_in, counter_in_Y_max, counter_in_Cb_max,
        counter_in_Cr_max, reset_i, do_copy)
begin
	wea_Y_D  <= wea_Y_rem;
	wea_Cb_D <= wea_Cb_rem;
	wea_Cr_D <= wea_Cr_rem;
	if (counter_in=counter_in_Y_max) then
		wea_Y_D  <= "0";
		wea_Cb_D <= "1";
	end if;
	if (counter_in=counter_in_Cb_max) then
		wea_Cb_D <= "0";
		wea_Cr_D <= "1";
	end if;
	if (counter_in=counter_in_Cr_max) then
		wea_Cr_D <= "0";
		wea_Y_D  <= "1";
	end if;
	
	if reset_i='1' or do_copy='1' then
		wea_Y_D  <= "1";
		wea_Cb_D <= "0";
		wea_Cr_D <= "0";
	end if;

end process;

process(Clk)
begin
	if rising_edge(Clk) then
		wea_Y_rem  <= wea_Y_D;
		wea_Cb_rem <= wea_Cb_D;
		wea_Cr_rem <= wea_Cr_D;
	end if;
end process;
----------------------------------------------------------


process(counter_out, addrb_Y_short, addrb_Cb_short, addrb_Cr_short, sampling_out)
begin

	case sampling_out is
	when "01" =>					-- 4:2:0
		addrb_Y_short 	<= counter_out(7) & counter_out(3) & counter_out(6 downto 4) & counter_out(2 downto 0);
		addrb_Cb_short	<= counter_out(7 downto 5) & counter_out(3 downto 1);
		addrb_Cr_short	<= counter_out(7 downto 5) & counter_out(3 downto 1);
	when "10" =>					-- 4:2:2
		addrb_Y_short 	<= '0' & counter_out(3) & counter_out(6 downto 4) & counter_out(2 downto 0);
		addrb_Cb_short	<= counter_out(6 downto 1);
		addrb_Cr_short	<= counter_out(6 downto 1);
	when others =>					-- gray and 4:4:4
		addrb_Y_short 	<= "00" & counter_out(5 downto 0);
		addrb_Cb_short	<= counter_out(5 downto 0);
		addrb_Cr_short	<= counter_out(5 downto 0);
	end case;

end process;
----------------------------------------------------------




----------------------------------------------------------
-- switch read and write memory

do_copy_D <= stop_in and stop_out;

process(do_copy, do_copy_delayed, address_msb)
begin
	address_msb_D <= address_msb;
	if do_copy='1' and do_copy_delayed='0' then
		address_msb_D <= not address_msb;
	end if;
end process;


process(ready, counter_in, counter_in_hold, do_copy)
begin
	ready_D <= ready;	

	if counter_in=(counter_in_hold-62) then
		ready_D <='0';
	end if;
	if do_copy='1' then
		ready_D <='1';
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		if reset_i='1' then
			ready <= '1';
			do_copy <= '0';
			do_copy_delayed <= '0';
			address_msb <= '0';
		else
			ready <= ready_D;
			do_copy <= do_copy_D;
			do_copy_delayed <= do_copy;
			address_msb <= address_msb_D;
		end if;
	end if;
end process;
----------------------------------------------------------







process(stop_eoi_out, counter_in, do_copy)
begin
	stop_eoi_out_D <= stop_eoi_out;
	if (counter_in=1) then
		stop_eoi_out_D <='1';
	elsif(do_copy='1') then 
		stop_eoi_out_D<='0';
	end if;
end process;
process(Clk, reset_i)
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
	if (counter_out=counter_out_hold and eoi='1') then
		eoi_D <= '0';
	end if;
end process;

process(context_i, sampling_i)
begin
	context_in_D <= '0' & context_i(2 downto 0);
	if context_i(1)='0' then
		sampling_in_D <= sampling_i(1 downto 0);
	else
		sampling_in_D <= sampling_i(3 downto 2);
	end if;
end process;


process(Clk)
begin
	if rising_edge(Clk) then
		eoi		<= eoi_D;
		eoi_hold <= eoi_hold_D;
		context_out	<= '0' & '0' & context_out(1 downto 0);		
		if counter_out=counter_out_hold and ce_out='1' then  
			context_out(3)	<= eoi;
		end if;

		if(ce_in='1') then
			sampling_in <= sampling_in_D;
			context_in  <= context_in_D;
		end if;
		if do_copy='1' then
			sampling_out <= sampling_in;
			context_out(2 downto 0)  <= context_in(2 downto 0);
		end if;

		if reset_i='1' then
			context_out <= (others=>'0');
			context_in  <= (others=>'0');
			eoi <='0';
			eoi_hold <='0';
			sampling_out <= "00";
			sampling_in  <= "00";
		end if;

	end if;
end process;





-------------------------------------------------------------------------
-- shift in

ce_in <= datavalid_i and not stop_in;

process(counter_in_hold, stop_in, counter_in)
begin
		if counter_in = counter_in_hold then
			stop_in_D <= '1';
		elsif do_copy ='1' then
			stop_in_D <= '0';
		else
			stop_in_D <= stop_in;
		end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
	if reset_i='1' or do_copy ='1' then
		counter_in <= (others=>'0');
		stop_in <= '0';
	elsif ce_in='1' then
		counter_in <= counter_in+1;
		stop_in <= stop_in_D;
	end if;
	end if;
end process;
-------------------------------------------------------------------------


-------------------------------------------------------------------------
-- shift out 
ce_out <= ready_i and not stop_out and not do_copy;

process(counter_out_hold, do_copy, stop_out, counter_out)
begin
	if counter_out = counter_out_hold then
		stop_out_D <= '1';
	elsif do_copy ='1' then
		stop_out_D <= '0';
	else
		stop_out_D <= stop_out;
	end if;
end process;

process(counter_out, do_copy, ready_i, stop_out)
begin
	counter_out_D	<= counter_out;
	if ready_i='1' and stop_out='0' then
		counter_out_D	<= counter_out+1;
	end if;

	if (do_copy='1') then
		counter_out_D	<=(others=>'0');
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		stop_out <= stop_out_D;
		if reset_i='1' then
			counter_out	<= (others=>'1');
			stop_out		<= '1';
		elsif ce_out='1' or do_copy='1' then
			counter_out	<= counter_out_D;
		end if;
	end if;
end process;

-------------------------------------------------------------------------

end IMP;
