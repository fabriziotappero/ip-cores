library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity img_testbench is
  port (
    pclk_i		: in  std_logic;
	 reset_i		: in  std_logic;
	 fsync_i		: in  std_logic;
	 rsync_i		: in  std_logic;
    pdata_i		: in std_logic_vector(7 downto 0);
    cols_o		: out std_logic_vector(15 downto 0);
	 rows_o		: out std_logic_vector(15 downto 0);
	 col_o		: out std_logic_vector(15 downto 0);
	 row_o		: out std_logic_vector(15 downto 0);
	 rsync_o		: out std_logic;
	 fsync_o		: out std_logic;
    pdata_o		: out std_logic_vector(7 downto 0) );		 
end img_testbench;

architecture main of img_testbench is	
  
  type ByteT is (c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,
						c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,
						c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,
						c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,
						c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,c82,
						c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,c97,c98,
						c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,
						c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,
						c125,c126,c127,c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,
						c138,c139,c140,c141,c142,c143,c144,c145,c146,c147,c148,c149,c150,
						c151,c152,c153,c154,c155,c156,c157,c158,c159,c160,c161,c162,c163,
						c164,c165,c166,c167,c168,c169,c170,c171,c172,c173,c174,c175,c176,
						c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,c188,c189,
						c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,
						c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,
						c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,
						c229,c230,c231,c232,c233,c234,c235,c236,c237,c238,c239,c240,c241,
				c242,c243,c244,c245,c246,c247,c248,c249,c250,c251,c252,c253,c254,c255);
  subtype Byte is ByteT;
  type ByteFileType is file of Byte;
  file infile	: ByteFileType open read_mode is "test1.bmp";
  file outfile	: ByteFileType open write_mode is "result_08bits.bmp";
    
  -- integer to bit_vector conversion
  function int2bit_vec(A: integer; SIZE: integer) return BIT_VECTOR is
		variable RESULT	: BIT_VECTOR(SIZE-1 DOWNTO 0);
		variable TMP		: integer;
	begin
		TMP := A;
		for i in 0 to SIZE - 1 loop
			if TMP mod 2 = 1 then RESULT(i) := '1';
			else RESULT(i) := '0';
			end if;
			TMP := TMP / 2;
		end loop;
		return RESULT;
	end;

begin  -- main

	img_read : process (pclk_i)
		variable pixelB : Byte;
		variable pixelG : Byte;
		variable pixelR : Byte;
		variable pixel : Byte;
		variable pixel1 : REAL;
		variable cols	: std_logic_vector(15 downto 0);
		variable rows	: std_logic_vector(15 downto 0);
		variable col	: std_logic_vector(15 downto 0);
		variable row	: std_logic_vector(15 downto 0);
		variable cnt	: integer;
		variable rsync	: std_logic := '0';
		variable stop	: std_logic;
		variable pixptr : std_logic_vector(19 downto 0) := (others => '0');
		type videomemtype is array (1048575 downto 0) of std_logic_vector(7 downto 0);
		variable videomem : videomemtype := (others=> (others=>'0'));
  
	begin  -- process img_read
		if (reset_i = '1') then
			pdata_o	<= (others => '0');
			col		:= (others => '0');
			row		:=	(others => '0');
		for i in 0 to 53 loop -- read header infos
			read(infile, pixel);
			write(outfile, pixel);
			case i is
				when 18 =>		-- 1st byte of cols
					cols(7 downto 0 ) := To_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
				when 19 =>		-- 2nd byte of cols
					cols(15 downto 8) := To_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
				when 22 =>		-- 1st byte of rows
					rows(7 downto 0 ) := To_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
				when 23 =>		-- 2nd byte of  rows
					rows(15 downto 8) := to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
				when 24 =>		-- do important things
					cols_o	<= cols;
					rows_o	<= rows;
					cols		:= cols - 1;
					rows		:= rows - 1;
				when others =>
					null;
			end case;
		end loop; -- i
		rsync := '1';
		cnt	:= 10;
		stop	:= '0';
		
		elsif (pclk_i'event and pclk_i = '1') then		
			rsync_o <= rsync;
			if rsync = '1' then	
			
				if row = "0000000000000000" and col = "0000000000000000" then
					fsync_o <= '1';
					pixptr := (others => '0');
				else
					fsync_o <= '0';
				end if;
				
				if stop = '0' then
					read(infile, pixelB); -- B
					read(infile, pixelG); -- G
					read(infile, pixelR); -- R
					pixel1	:= (ByteT'pos(pixelB)*0.11) + (ByteT'pos(pixelR)*0.3) + (ByteT'pos(pixelG)*0.59);
					pdata_o	<= CONV_STD_LOGIC_VECTOR(INTEGER(pixel1), 8);
					videomem(conv_integer(pixptr)) := CONV_STD_LOGIC_VECTOR(INTEGER(pixel1), 8);
					pixptr := pixptr + 1;
					col_o		<= col;
					row_o		<= row;
				else
					pdata_o <= videomem(conv_integer(pixptr));
					pixptr := pixptr + 1;
				end if;
				
				if col = cols then
					col	:= (others => '0');
					rsync	:= '0';
					if row = rows then
						File_Close(infile);
						stop := '1';
						row := (others=>'0'); -- This line was added by Benny
					else
						row := row + 1;
					end if;		-- row
				else
					col := col + 1;
				end if;			-- col
				
			else					-- rsync
				if cnt > 0 then
					cnt	:= cnt -1;
				else
					cnt	:= 10;  -- Can be changed from 10 to 300 to get correct frame speed timing
					rsync := '1';
				end if;
				pdata_o <= (others => 'X');
			end if;	-- rsync
		
			if rsync_i = '1' then
				write(outfile, ByteT'val(ieee.numeric_std.To_Integer(ieee.numeric_std.unsigned(pdata_i)))); --, pixel);
				write(outfile, ByteT'val(ieee.numeric_std.To_Integer(ieee.numeric_std.unsigned(pdata_i)))); --, pixel);
				write(outfile, ByteT'val(ieee.numeric_std.To_Integer(ieee.numeric_std.unsigned(pdata_i)))); --, pixel);
			end if; -- rsync_i
		
		end if;	  -- clk
	end process img_read;
end main;