
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
-- use work.jpeg_pack.all;
 
ENTITY jpeg_tb IS
END jpeg_tb;
 
ARCHITECTURE behavior OF jpeg_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
  	
signal	output_valid	:  std_logic:='0';
signal data_out	:  signed (15 downto 0);
signal sop,eop: std_logic;
signal next_eob: std_logic;
   --Inputs
   signal clk : std_logic := '0';
  signal zrl: unsigned (3 downto 0);
   signal data_in : unsigned (7 downto 0);
   signal wr : std_logic := '0';
 	--Outputs
   --signal data_out : matrix_word;
   signal wr_en : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
subtype by_te is character;

type f_byte is file of by_te;
BEGIN

process (wr_en,clk)
--constant file_name: string:="test3.jpg";
constant file_name: string:="test.jpg";
file in_file: f_byte open read_mode is file_name;

--variable in_line,out_line: line;
variable good:boolean;
variable a:character;

begin 
--read(in_file,a);
--data_in<=a;
--wait until wr_en='1';
--wait for 6 ns;
--wr<='1';

--when not endfile(in_file) loop
if  wr_en='0' then 
	--wr<='0';
	elsif clk'event and clk='1' then
		if not endfile (in_file) then
			read(in_file,a);
		end if;
		data_in<=to_unsigned(character'pos(a),8);--very tricky the conversation
	--	wr<='1';
 	
end if;
end process;
wr<='1' when wr_en='1' else'0';

  clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.huffman_decoder PORT MAP (
         
	clk => clk,
	next_eob=> next_eob,
	zrl => zrl,
	sop =>sop,
	eop => eop,
	output_valid=>output_valid,
	data_out=>data_out,
        wr => wr,
	decoder_enable =>'1',
          data_in => data_in,
	wr_en=>wr_en
        );

 

END;
