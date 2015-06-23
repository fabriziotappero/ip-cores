-- lem1_9min.vhd	9-bit instruction block memory, 64x1 distributed data memory
--	targets Spartan-2/3 on Digilent board
--	uses distributed RAM for data RAM, block RAM for instruction ROM & LUT tables
--	single clock cycle instruction execution, 9-bit fixed instruction format
--	Processing cycle: sync instruction read, async data RAM read, ALU, sync data RAM write  15-20ns
--	one clock per instruction

------		64x1 single port RAM with async read (distributed RAM)
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity async_ram64x1 is port(
    clk: in std_logic;
--    en: in std_logic;
    we: in std_logic;
    a: in std_logic_vector(5 downto 0);
    di: in std_logic;
    do: out std_logic);
end async_ram64x1;
architecture arch3 of async_ram64x1 is
    type ram_type is array(63 downto 0) of std_logic;
    signal RAM: ram_type;
begin
    process(clk)
    begin
        if clk'event and clk='1' then
--            if en = '1' then 
                if we='1' then RAM(conv_integer(a))<=di; end if;
--            end if;
        end if;
    end process;
    do <= RAM(conv_integer(a));
end arch3;


------		2048x9 single port RAM with sync read (block RAM)
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity sync_ram2048x9 is port(
    clk: in std_logic;
--    en: in std_logic;
    we: in std_logic;
    a: in std_logic_vector(10 downto 0);
    di: in std_logic_vector(8 downto 0);
    do: out std_logic_vector(8 downto 0));
end sync_ram2048x9;
architecture arch4 of sync_ram2048x9 is
    type ram_type is array(2047 downto 0) of std_logic_vector(8 downto 0);
    signal RAM: ram_type;
    signal read_a: std_logic_vector(10 downto 0);
begin
    process(clk)
    begin
        if clk'event and clk='1' then
--            if en = '1' then 
                if we='1' then RAM(conv_integer(a))<=di; end if;
--            end if;
        read_a <= a;
        end if;
    end process;
    do <= RAM(conv_integer(read_a));
end arch4;


------			processor definition
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_signed.all;
use work.definitions.all;

entity lem1_9 is port(
    clk:		in std_logic;
    reset:	in std_logic;
    start:	in std_logic;
    pc_reg:	out std_logic_vector(10 downto 0);
    mem_rd:	out std_logic_vector(8 downto 0);
    nxdata:	out std_logic;
    data_we:	out std_logic;
    acc_cpy:	out std_logic;
    cry_cpy:	out std_logic
	);
end entity lem1_9;
 
architecture arch of lem1_9 is
-- signal naming: nx prefix: new value, x prefix: new value enable
type dly_type is (run, hlt);		-- states: run, halt
signal dly, nxdly: dly_type;		-- processing state variable & next dly

--	instruction register & renamings
signal ir: std_logic_vector(8 downto 0);		-- instruction register
signal inst: std_logic_vector(2 downto 0);		-- ir(8..6), op-code field
signal pc, nxpc: std_logic_vector(10 downto 0);	-- program counter & next pc
signal xpc: std_logic;						-- pc update enable
signal acc, nxacc: std_logic;					-- accumulator & next acc
signal xacc: std_logic;						-- acc update enable
signal cry, nxcry: std_logic;					-- carry & next carry
signal xcry: std_logic;						-- carry update enable
signal nxadr: std_logic_vector(5 downto 0);		-- ir(5..0), data read/write address
signal nxmem: std_logic;						-- write data
signal memrd: std_logic;						-- read data
signal nxwe: std_logic;						-- data write enable

--		Block RAM with parity bits
component RAMB16_S9 is
  generic (
       WRITE_MODE : string := "WRITE_FIRST";
       INIT  : bit_vector  := X"000";
       SRVAL : bit_vector  := X"000";
	  -- use hexidecimal encoding
	  --	little endian: right most bit of INIT_00 is bit 0 of location 0
       INIT_00 : bit_vector(255 downto 0) := X"000000000000000000000000000000000000000000000000000000000000000F";
       INIT_01 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_02 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_03 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_04 : bit_vector(255 downto 0) := X"000000000000000000000000000000000000000000000000000000000000000F";
       INIT_05 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_06 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_07 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
	  -- little endian: right most bit of INITP_00 is bit9 of location 0
       INITP_00 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000001";
       INITP_01 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_02 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_03 : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000"
  );
  port (DI    : in STD_LOGIC_VECTOR (7 downto 0);
        DIP   : in STD_LOGIC_VECTOR (0 downto 0);
        EN    : in STD_logic;
        WE    : in STD_logic;
        SSR   : in STD_logic;
        CLK   : in STD_logic;
        ADDR  : in STD_LOGIC_VECTOR (10 downto 0);
        DO    : out STD_LOGIC_VECTOR (7 downto 0);
        DOP   : out STD_LOGIC_VECTOR (0 downto 0));
end component;

begin
--	renamings
inst  <= ir(8 downto 6);
nxadr <= ir(5 downto 0);

--	monitoring signals
--pc_reg	<= pc; 
--acc_cpy	<= acc; 
--cry_cpy	<= cry;
--nxdata	<= nxmem;
--data_we	<= nxwe;
--mem_rd	<= inst & nxadr;

-- port maps
data_bit:	entity work.async_ram64x1 port map(
	clk  => clk,
--   en   => sig1,
	we   => nxwe,
	a    => nxadr(5 downto 0),
	di   => nxmem,
	do   => memrd);

memory: RAMB16_S9 generic map(
--	toggle ACC & CRY (clear ACC & CRY; set ACC & CRY; HALT)
--	INIT_00  => X"00000000000000000000000000000000000000000000000000000000007F1A1F",
--	INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000")
--	increment 24-bit counter at memory locations 23..0
--	INIT_00  => X"CD164ECE164FCF1650D01651D11652D21653D31654D41655D51656D61657D711",
--	INIT_01  => X"1643C31644C41645C51646C61647C71648C81649C9164ACA164BCB164CCC164D",
--	INIT_02  => X"00000000000000000000000000000000000000000000000040C01641C11642C2",
--	INITP_00 => X"0000000000000000000000000000000000000000000000492492492492492492")
--	four-bit adder at memory locations 59..56 (mem loc 7..4 + "00" & loc 15..14)
--	mem loc 63..60: active low decode of loc 15..14
--	mem loc 55..48: active low drive of 7-seg display
--	HELLO UJOrLd
	INIT_00  => X"CD164ECE164FCF1650D01651D11652D21653D31654D41655D51656D61657D711",
	INIT_01  => X"1643C31644C41645C51646C61647C71648C81649C9164ACA164BCB164CCC164D",
	INIT_02  => X"177E8F7C8E7D4FCE7F4F8E7BC2167AC31679C48E78C58F1040C01641C11642C2",
	INIT_03  => X"6C38AA776F6E6D792AF86939F86A197ABB6B3A6C38F96D38BA6E38BB6F3ABB70",
	INIT_04  => X"39FB726F6EAD736FAB746F6B682CBB682A1978B9756F6C6829FA6839AA766F69",
	INIT_05  => X"000000000000000000000000000000000000000000000000000071687A3BF868",
	INITP_00 => X"00000000000000000000001C993CA793CF9129242A4924492492492492492492")

--	HEllo UJorld
--	INIT_00  => X"CD164ECE164FCF1650D01651D11652D21653D31654D41655D51656D61657D711",
--	INIT_01  => X"1643C31644C41645C51646C61647C71648C81649C9164ACA164BCB164CCC164D",
--	INIT_02  => X"177E8F7C8E7D4FCE7F4F8E7BC2167AC31679C48E78C58F1040C01641C11642C2",
--	INIT_03  => X"79BA6E7B1939BA762F7A193839BB6F2F7B193839BA6F78797ABB77797A7BF870",
--	INIT_04  => X"BB6D2D78797AFB6D2D7B1939BA6D787BFA752E7879BB6E2E7A193839BB6E2E78",
--	INIT_05  => X"BB6A79BA722B787AF96B2B787BF96B7ABB733A2C7BF96C78BB74372D7A193839",
--	INIT_06  => X"00000000000000000000000000000000000000000000712A7A1938BB6A2A7879",
--	INITP_00 => X"00000000000001A72739393B3CD339B394D9B39C2A4924492492492492492492")
--	
		port map(  
	DI	=> (others => '0'),
	DIP	=> (others => '0'),
	EN	=> '1',
	WE	=> '0',
	SSR	=> '0',
	CLK	=> clk,
	ADDR	=> nxpc(10 downto 0),
	DO	=> ir(7 downto 0),
	DOP	=> ir(8 downto 8));

--memory: entity work.sync_ram2048x9 port map(
--	clk => clk,
----	en  => vcc,
--	we  => gnd,
--	a   => nxpc(10 downto 0),
--	di  => (others => '0'),
--	do  => ir);
				
-- instruction processing       
decode: process(dly,start,memrd,acc,cry,inst,pc,ir) begin
--	default values for update enables & "nx" signals
nxdly	<= hlt;
xpc		<= '-';
nxpc		<= (others => '-');
nxwe		<= '-';
nxmem 	<= '-';
xacc		<= '-';
nxacc	<= '-';
xcry		<= '-';
nxcry	<= '-';

--	state dispatch
	case dly is
	when hlt	=>
		if start = '1' then nxdly <= run; else nxdly <= hlt; end if;
		xacc	<= '1';	nxacc	<= '0'; 
		xpc	<= '1';	nxpc		<= (others => '0');	-- keep PC reset 
		xcry	<= '1';	nxcry	<= '0';
		nxwe	<= '0';
	
	when run	=>
--	op-code dispatch 
case inst is

when opMSC =>
	case ir(5 downto 4) is
	when opHLT =>
		nxdly <= hlt;

	when opAnC => 
		nxdly <= run;
  		case ir(3 downto 0) is
		when "0000" => xacc <= '1';	nxacc <= '0';		xcry <= '1';	nxcry <= '0';	-- A,C = 0,0
		when "0001" => xacc <= '1';	nxacc <= '0';		xcry <= '1';	nxcry <= '1';	-- A,C = 0,1
		when "0010" => xacc <= '1';	nxacc <= '1';		xcry <= '1';	nxcry <= '0';	-- A,C = 1,0
		when "0011" => xacc <= '1';	nxacc <= '1';		xcry <= '1';	nxcry <= '1';	-- A,C = 1,1
		when "0100" => xacc <= '0';					xcry <= '1';	nxcry <= '0';	-- C = 0
		when "0101" => xacc <= '0';					xcry <= '1';	nxcry <= '1';	-- C = 1
		when "0110" => xacc <= '1';	nxacc <= '0';		xcry <= '0';	-- A = 0
		when "0111" => xacc <= '1';	nxacc <= '1';		xcry <= '0';	-- A = 1
		when "1000" => xacc <= '0';					xcry <= '1';	nxcry <= acc OR cry;	-- C = A | C
		when "1001" => xacc <= '1';	nxacc <= not acc;	xcry <= '0';	-- A = not A
		when "1010" => xacc <= '0';					xcry <= '1';	nxcry <= not cry;	-- C = not C
		when "1011" => xacc <= '1';	nxacc <= not acc;	xcry <= '1';	nxcry <= not cry;	-- A,C = not A, not C
		when "1100" => xacc <= '0';					xcry <= '1';	nxcry <= acc AND cry;	-- C = A & C
		when "1101" => xacc <= '1';	nxacc <= cry;		xcry <= '0';	-- A = C
		when "1110" => xacc <= '0';					xcry <= '1';	nxcry <= acc;	-- C = A
		when "1111" => xacc <= '1';	nxacc <= cry;		xcry <= '1';	nxcry <= acc;	-- A,C = C,A
		when others => xacc <= '0';					xcry <= '0';
		end case;
		xpc	<= '1';	nxpc	<= pc + 1; 
		nxwe	<= '0';
	when others =>	null;
	end case;
			
when opST  =>
	nxdly<= run;
	xacc	<= '0';
	xpc	<= '1';	nxpc		<= pc + 1; 
	xcry	<= '0';	
	nxwe	<= '1';	nxmem	<= acc;

when opLD  =>
	nxdly<= run;
	xacc	<= '1';	nxacc	<= memrd; 
	xpc	<= '1';	nxpc		<= pc + 1; 
	xcry	<= '0';
	nxwe	<= '0';

when opLDC =>
	nxdly<= run;
	xacc	<= '1';	nxacc	<= not memrd; 
	xpc	<= '1';	nxpc		<= pc + 1; 
	xcry	<= '0';
	nxwe	<= '0';

when opAND => 
	nxdly<= run;
	xacc	<= '1';	nxacc	<= acc and memrd; 
	xpc	<= '1';	nxpc		<= pc + 1; 
	xcry	<= '0';
	nxwe	<= '0';
	
when opOR  => 
	nxdly<= run;
	xacc	<= '1';	nxacc	<= acc or memrd; 
	xpc	<= '1';	nxpc		<= pc + 1; 
	xcry	<= '0';	
	nxwe	<= '0';

when opXOR => 
	nxdly<= run;
	xacc	<= '1';	nxacc	<= acc xor memrd; 
	xpc	<= '1';	nxpc		<= pc + 1; 
	xcry	<= '0';	
	nxwe	<= '0';

when opADC => 
	nxdly<= run;
	xacc	<= '1';	nxacc	<= acc xor memrd xor cry; 
	xpc	<= '1';	nxpc		<= pc + 1; 
	xcry	<= '1';	nxcry	<= (acc and cry) or (acc and memrd) or (cry and memrd);
	nxwe	<= '0';

when others => null;
end case;
	when others => null;
	end case;
    
end process decode;
 
--		all processor register updates 
update: process(clk,reset) begin
if reset='1'		-- master reset
then	dly		<= hlt;
	acc		<= '0';
	cry		<= '0';
	pc		<= (others => '0');
--		monitoring signals
	acc_cpy	<= '0'; 
	cry_cpy	<= '0';
	nxdata	<= '0';
	data_we	<= '0';
	pc_reg	<= (others => '0'); 
	mem_rd	<= (others => '0');
elsif (clk'event and clk='1')
then 
--		state variable update
	dly		<= nxdly;
--		accumulator update
	if xacc = '1'	then acc	<= nxacc; end if;
--		update carry bit
	if xcry = '1'	then cry	<= nxcry; end if;
--		Program counter update
	if xpc = '1'	then pc	<= nxpc; end if;
----	monitoring signals
	acc_cpy	<= acc; 
	cry_cpy	<= cry;
	nxdata	<= nxmem;
	data_we	<= nxwe;
	pc_reg	<= pc; 
	mem_rd	<= inst & nxadr;
end if;
end process update;
 
end arch;