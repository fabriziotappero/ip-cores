----------------------------------------------------------------------------------
-- Company:   Dossmatik GmbH /Germany
-- Engineer:  Rene Doss
-- Create Date:     10/12/2009 
-- Design Name: 
-- Module Name:    huffman decoder for jpeg application
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
--  use std.textio.all; -- only for testing
--use work.txt_util.all;

--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity huffman_decoder is
port(
clk		:in std_logic;

--interface data input
wr		:in std_logic;  		--write
data_in		: in unsigned (7 downto 0);	--data jpeg stream
wr_en		: out std_logic:='1';		--write enable	

--interface  data out
output_valid	: buffer std_logic;      	--use it as write signal in the follow IDCT
data_out	: out signed (15 downto 0);	--decoded and dequantized coefficient
next_eob	: buffer std_logic:='0';		--the next data is the last coefficient of block
						--all higher zigzag coeficients are zero
sop		: out std_logic:='0';		--start of picture, can be used as reset in the following IDCT
eop		: out std_logic:='0';	        --end of picture
zrl		: out unsigned (3 downto 0);    -- number of consecutive zeros before the next coefficient
decoder_enable	: in std_logic);
end huffman_decoder;



  

architecture Behavioral of huffman_decoder is
-------------------------------------------------
subtype by_te is character;    
type f_byte is file of by_te;

type ubyte_vector16 is array (0 to 15) of unsigned (7 downto 0);
type uword_vector16 is array (0 to 15) of unsigned (15 downto 0);

--prepaired type for post IDCT not implemented yet
-- type word_vector64 is array (0 to 63) of signed (15 downto 0);

type dual_table is array (0 to 1,0 to 63) of unsigned (7 downto 0); --quant Tables


type int_vector64 is array (0 to 63) of integer;
constant  zigzag :int_vector64:=(	 0, 8, 1, 2, 9,16,24,17,
					10, 3, 4,11,18,25,32,40,
					33,26,19,12, 5, 6,13,20,
					27,34,41,48,56,49,42,35,
					28,21,14, 7,15,22,29,36,
					43,50,57,58,51,44,37,30,
					23,31,38,45,52,59,60,53,
					46,39,47,54,61,62,55,63);


--hufftable storage place definition
constant RAM_addrwidth: integer:=9;
-- Entspricht 512 Speicherzellen reicht für 2 DC und 2AC Tabellen
--sollte gegebenfalls erhöht werden!!!!!!!!!

type RAM is array (0 to (2**RAM_addrwidth-1)) of unsigned (7 downto 0);
subtype RAM_int is integer range 0 to (2**RAM_addrwidth-1);


--2*4*16  Für 4 DC-Tabellen und 4AC-Tabelle 
type pointer_array is array (0 to 127) of RAM_int;
type uword_array is array ( 0 to 127) of unsigned (15 downto 0);
type int_vectorRAM is array(0 to 15) of integer range 0 to (2**RAM_addrwidth-1);	
-------------------------------------------------------
--the state machine is divide 
--some states for sub state machine
type sos_type is (decode,decode_post,catch,catch_post,change_comp0,
		change_comp,change_DC_AC0,change_DC_AC);
type sos_header_type is (selector,table);
type SOF0_Header_type is (selector,sampling,table);


--this is for the main state machine
type state_type is (IDLE, 
				SOI,  --0xFFD8 start of image
				APP0,	--0xFFE0 application segment
					
				DQT,  --0xFFDB define quantisation table
				DQT_length,DQT_length0,
				DQT_active,
				SOF0_length,SOF0_length0, --0xFFC0 baseline DCT
				SOF0_precision,
				SOF0_y_high,SOF0_y_low,
				SOF0_x_high,SOF0_x_low,
				SOF0_nr_comp,SOF0_active,
				
				DHT,  --0xFFC4 define Huffman Table
				DHT_length,DHT_length0,
				DHT_destination,
				DHT_Number,

				DHT_active,
				--0xFFDA start of scan
				SOS_length,SOS_length0,SOS_header,
				SOS_init0,SOS_init1,SOS_init2,SOS_init3,
				SOS_scan,  
				EOI); --0xFFD9 end of Image
-----------------------------------------------------------------------------

signal value : signed (15 downto 0);


signal qtable : dual_table;
signal write_active: std_logic;
signal input_reg:unsigned (23 downto 0);
signal Markerlength: unsigned (15 downto 0);
signal next_state,state: state_type:=idle;
signal sos_state,sos_state_old:sos_type:=decode;
signal DHT_counter: integer;


signal SOF0_header_state:SOF0_Header_type;
signal sof0_header_index:integer range 0 to 15 := 15;
signal x_size,y_size:unsigned (15 downto 0);  --picture size
signal sof0_number_comp: unsigned(7 downto 0);
signal sof0_comp_table: uword_vector16; -- hier ist die Info Qtable genommen werden


signal output_active: std_logic:='0';

signal huff_wr_en: std_logic:='1'; 




--Hufftable
signal ram_pointer:   pointer_array;
signal huff_ram:	RAM;
signal huff_code_offset: uword_array;
signal ram_offset:RAM_int;

signal dest: integer:=0;
signal DC_AC_decode: unsigned (2 downto 0):="000";
signal DC_AC_old: unsigned (0 downto 0);
signal index: integer range 0 to 15; 
signal huff_table_end :std_logic:='1';
signal addr: integer  range 0 to (2**RAM_addrwidth-1);
signal huff_a: unsigned (7 downto 0):="00000011";
signal huff_code_number: ubyte_vector16;
signal h_code: unsigned (15 downto 0);
signal h_delta: uword_vector16;
signal code_word: unsigned (7 downto 0);



signal comp_table:ubyte_vector16;
--data
signal read_offset,read_offset_a: integer range 0 to 15;
signal shift : integer range 1 to 16;
--signal ablock :word_vector64;
signal RLD_wr:std_logic;
signal stuffing :std_logic;
signal scan_data: unsigned (7 downto 0);
signal Barrel,ba: unsigned (15 downto 0);
signal ba_1: unsigned (0 downto 0);
signal rot_buffer: unsigned(31 downto 0):=X"00000000"; --Das ist der Ringspeicher vom Decoder
signal barrel_pointer: unsigned (4 downto 0):="00000";
signal write_rot_pointer: unsigned (1 downto 0):="11";
signal sos_number_comp: unsigned(7 downto 0);
signal sos_comp_table: ubyte_vector16; -- hier ist die Info welche Huff-table und Qtable genommen werden
signal sos_wr_en:std_logic:='1';
signal sos_teiler2: std_logic:='0';

signal sos_header_state:sos_header_type;
signal sos_header_index:integer range 0 to 15 := 15;
signal sos_matrix_counter:unsigned (5 downto 0):=(others=>'0');
Signal sos_scan_index: integer;
signal sos_hi :unsigned (3 downto 0);
signal sos_vi :unsigned (3 downto 0);
signal sos_component: integer range 0 to 15;
signal eoi_detect:std_logic_vector (1 downto 0):="00";   --bit 0 eoi  detect, bit 1 last eob detect
--------------------------------------------
signal addr_table: integer range 0 to 63;


-- 
 begin

data_out<=value;

process(clk)
begin
if  clk'event and clk='1' then
  if sos_state=catch_post then
      output_active<='1';
  end if;
  if state=eoi then
      output_active<='0';
  end if;
end if;
end process;

process(clk)
begin
if  clk'event and clk='1' then
  if output_active='1' and sos_state=catch then
	output_valid<='1';
	zrl<=code_word(7 downto 4);
      else
	output_valid<='0';
  end if;
end if;
end process;

--    --this is my testing process at simulation 
--process(clk)
--constant file_name: string:="output.txt";
--file log: text open write_mode is file_name;
--variable myline:line;
--begin
--if  clk'event and clk='1' then
--	if sos_state=catch then
--	write(myline,now);
--	write(myline,string'("   "));
--	write(myline,str(to_integer(DC_AC_decode)));
--	write(myline,string'("   "));
--	write(myline,str(to_integer(value)));
--	writeline(log,myline);
--	end if;
--end if;
--end process;


--sm Huffdecoder


--state decode  huffman decode
--state catch  mantissa bits 
--state catch post an additional delay

-- decode -> catch -> catch_post ->decode...........this is the cycle in work
--some waits needed when the table is changed that all values are valid


process (clk,state,decoder_enable)
begin
if state=sos_init1 then
		barrel_pointer<="11111";
	
elsif clk'event and clk='1' and decoder_enable='1' then
	if state=sos_init0 then
	      sos_state<=decode;
	end if;

	if state=sos_scan then
		if sos_state=catch then
			sos_state<=catch_post;
			
		end if;
		--normaler Ablauf
		if (sos_state=catch_post and  (DC_AC_decode(0 downto 0)/="0" and code_word/=to_unsigned(0,8)))then
				barrel_pointer<=barrel_pointer - ('0'& code_word(3 downto 0));
				sos_state<=decode;
		end if;
		--letzte Zeichen
		if(sos_state=catch_post and  (DC_AC_decode(0 downto 0)/="0" and code_word=to_unsigned(0,8))) then
				sos_state<=change_comp0;
		end if;
		if sos_state=change_comp0 then
				sos_state<=change_comp;
		end if;

		--DC zu AC Uebergang
		if (sos_state=catch_post and  (DC_AC_decode(0 downto 0)="0")) then
				sos_state<=change_DC_AC0;
		end if;
		if sos_state=change_DC_AC0 then
				sos_state<=change_DC_AC;
		end if;
		--
		if  sos_state=change_DC_AC or sos_state=change_comp then
				barrel_pointer<=barrel_pointer - ('0'& code_word(3 downto 0));
				sos_state<=decode;
		end if;	
		 
		
		if ((write_rot_pointer=barrel_pointer(4 downto 3)) or
		   (write_rot_pointer="00" and barrel_pointer(4 downto 3)="11") or	
		   (write_rot_pointer="01" and barrel_pointer(4 downto 3)="00") or	
		   (write_rot_pointer="10" and barrel_pointer(4 downto 3)="01") or	
		   (write_rot_pointer="11" and barrel_pointer(4 downto 3)="10")) then

			if sos_state= decode then
				barrel_pointer<=barrel_pointer-to_unsigned(shift,5);
				sos_state<=catch;
				
			end if;
			
			
		end if;
	end if;

		
end if;
end process;




--chose the correct table
--xx0 DC Tables
--xx1 AC Table
process (clk)
begin
if clk'event and clk='1' then
sos_state_old<=sos_state;
	
	if state=sos_init0 then
		DC_AC_decode<=SOS_comp_table(0)(1 downto 0)&"0";
		sos_matrix_counter<=(others=>'0');
		sos_scan_index<=0;
		sos_component<=0;
		sos_vi<=to_unsigned(1,4);
		sos_hi<=to_unsigned(1,4);
	end if;

	if state=sos_scan then
	if sos_state=change_comp0 then
		DC_AC_decode<=SOS_comp_table(sos_component)(1 downto 0)&"0";
		
	end if;
	if sos_state_old=catch  then
		if (((code_word=0) and (sos_matrix_counter>0)) or sos_matrix_counter=63) then 
		--darf erst ab Position 2 zurückgesetzt werden
		--mindestens ein DC und ein AC Wert
			sos_matrix_counter<=(others=>'0');
		
		else
			sos_matrix_counter<=sos_matrix_counter+1;
		end if;
		
		
		if sos_matrix_counter=0 then 
			DC_AC_decode<=SOS_comp_table(sos_component)(1 downto 0)&"1";
			
		end if;
		if sos_matrix_counter/=0 then
			
--  		
 			if code_word=0 or sos_matrix_counter=63 then 
				
				if sos_vi<sof0_comp_table(sos_component)(15 downto 12) then
					sos_vi<=sos_vi+1;
					
				else
					sos_vi<=to_unsigned(1,4);
					if sos_hi<sof0_comp_table(sos_component)(11 downto 8) then
						sos_hi<=sos_hi+1;
					else
						sos_hi<=to_unsigned(1,4);
					end if;
					if sos_hi=sof0_comp_table(sos_component)(11 downto 8) then
						if sos_component=to_integer(sos_number_comp-1) then
							sos_component<=0;
						else
							sos_component<=sos_component+1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;
	end if;
end if;
end process;





wr_en<=huff_wr_en and sos_wr_en and not eoi_detect(0) after 2 ns;


---decoder

write_active<=wr; --notwendig für die Simulation


-- waiting for the last block

process(clk)
begin
if clk'event and clk='1' then
if next_state=eoi then
      eoi_detect<="00";
end if;
    if input_reg(15 downto 0)=x"FFD9"then 
	  eoi_detect(0)<='1';
    end if;
    if eoi_detect(0)='1' and next_eob='1' then
	  eoi_detect(1)<='1';
    end if;
end if;
end process;


--destuffing
process(clk,write_active)
begin
if write_active='1' then
	if clk'event and clk='1' then
		if input_reg(7 downto 0)=X"FF"  then
			stuffing<='1';
		else
			stuffing<='0';
		end  if;
	end if;
end if;
end process;


	
sos_wr_en<='0' when state=sos_scan and barrel_pointer(4 downto 3) = write_rot_pointer else '1';

---load fifo 
--it is a cirular memory 32bit long
-- this is the importent part in ths design
process(clk,write_active,sos_wr_en,eoi_detect(0))

begin
--wr_en<=huff_wr_en and sos_wr_en and not eoi_detect after 2 ns;
if clk'event and clk='1' then
	
if (write_active='1' and stuffing='0')or (sos_wr_en='1' and eoi_detect(0)='1' ) then

	
	if  state=SOS_init0 then
		write_rot_pointer<="11";
		rot_buffer(31 downto 24) <=input_reg(15 downto 8);		
	end if;
	if  state=SOS_init1 then
		rot_buffer(23 downto 16) <=input_reg(15 downto 8);			
		end if;
	if  state=SOS_init2 then
		rot_buffer(15 downto 8) <=input_reg (15 downto 8);		
		end if;
	if  state=SOS_init3 then
			rot_buffer(7 downto 0)<= input_reg(15 downto 8);
			
		end if;


	if  state=sos_scan then
		if barrel_pointer(4 downto 3) /= write_rot_pointer then
		
			--sos_wr_en<='0';
		
		write_rot_pointer<=write_rot_pointer-1;
		--sos_wr_en<='1';
		case write_rot_pointer is
		when "00"=>  rot_buffer(7 downto 0)<= input_reg(15 downto 8);
		when "01"=>  rot_buffer(15 downto 8) <=input_reg (15 downto 8);
		when "10"=> rot_buffer(23 downto 16) <=input_reg(15 downto 8);	
		when "11"=>   rot_buffer(31 downto 24) <=input_reg(15 downto 8);
		when others=> null;
		end case;
		end if;
	end if;
end if;
end if;
end process;

process (barrel_pointer,rot_buffer)
   begin
      case to_integer(barrel_pointer) is
         when 0 => barrel<= rot_buffer (0 downto 0) &  rot_buffer (31 downto 17);
         when 1 => barrel<= rot_buffer (1 downto 0) &  rot_buffer (31 downto 18); 
         when 2 => barrel<= rot_buffer (2 downto 0) &  rot_buffer (31 downto 19);
         when 3 => barrel<= rot_buffer (3 downto 0) &  rot_buffer (31 downto 20);
         when 4 => barrel<= rot_buffer (4 downto 0) &  rot_buffer (31 downto 21);
         when 5 => barrel<= rot_buffer (5 downto 0) &  rot_buffer (31 downto 22);
         when 6 => barrel<= rot_buffer (6 downto 0)  &  rot_buffer (31 downto 23);
         when 7 => barrel<= rot_buffer (7 downto 0)  &  rot_buffer (31 downto 24);
         when 8 => barrel<= rot_buffer (8 downto 0)  &  rot_buffer (31 downto 25);
         when 9 => barrel<= rot_buffer (9 downto 0)  &  rot_buffer (31 downto 26);
         when 10 => barrel<= rot_buffer (10 downto 0) &  rot_buffer (31 downto 27);
         when 11 => barrel<= rot_buffer (11 downto 0) &  rot_buffer (31 downto 28);
         when 12 => barrel<= rot_buffer (12 downto 0) &  rot_buffer (31 downto 29);
         when 13 => barrel<= rot_buffer (13 downto 0) &  rot_buffer (31 downto 30);
         when 14 => barrel<= rot_buffer (14 downto 0) &  rot_buffer (31 downto 31);
         when 15 => barrel<= rot_buffer (15 downto 0);
         when 16 => barrel<= rot_buffer (16 downto 1);
         when 17 => barrel<= rot_buffer (17 downto 2);
         when 18 => barrel<= rot_buffer (18 downto 3);
         when 19 => barrel<= rot_buffer (19 downto 4);
         when 20 => barrel<= rot_buffer (20 downto 5);
         when 21 => barrel<= rot_buffer (21 downto 6);
         when 22 => barrel<= rot_buffer (22 downto 7);
         when 23 => barrel<= rot_buffer (23 downto 8);
         when 24 => barrel<= rot_buffer (24 downto 9);
         when 25 => barrel<= rot_buffer (25 downto 10);
         when 26 => barrel<= rot_buffer (26 downto 11);
         when 27 => barrel<= rot_buffer (27 downto 12);
         when 28 => barrel<= rot_buffer (28 downto 13);
         when 29 => barrel<= rot_buffer (29 downto 14);
         when 30 => barrel<= rot_buffer (30 downto 15);
         when 31 => barrel<= rot_buffer (31 downto 16);
         when others => null;		
      end case;
end process;

--preprocessing calculate the distance of different codelengths
--this is parallel at the same periode detect codelength
process(clk)
begin
	if clk'event and clk='1' then
			h_delta(0)<="000000000000000"&(Barrel(15 downto 15));
			h_delta(1)<=(Barrel(15 downto 14)- ("00000000000000"& huff_code_offset(to_integer(DC_AC_decode &"0001")) (0 downto 0)&'0')); 
  			h_delta(2)<=(Barrel(15 downto 13)- ("0000000000000"&huff_code_offset(to_integer(DC_AC_decode&"0010")) (1 downto 0) &'0')); 
  			h_delta(3)<=(Barrel(15 downto 12)- ("000000000000"&huff_code_offset(to_integer(DC_AC_decode &"0011")) (2 downto 0) &'0')); 
  			h_delta(4)<=(Barrel(15 downto 11)- ("00000000000"&huff_code_offset(to_integer(DC_AC_decode &"0100")) (3 downto 0) &'0')); 
  			h_delta(5)<=(Barrel(15 downto 10)- ("0000000000"&huff_code_offset(to_integer(DC_AC_decode &"0101")) (4 downto 0) &'0')); 
  			h_delta(6)<=(Barrel(15 downto 9)- ("000000000"&huff_code_offset(to_integer(DC_AC_decode &"0110")) (5 downto 0) &'0')); 
 			h_delta(7)<=(Barrel(15 downto 8) - ("00000000"&huff_code_offset(to_integer(DC_AC_decode &"0111")) (6 downto 0) &'0'));   
 			h_delta(8)<=(Barrel(15 downto 7) - ("0000000"&huff_code_offset(to_integer(DC_AC_decode &"1000")) (7 downto 0) &'0'));   
 			h_delta(9)<=(Barrel(15 downto 6) - ("000000"&huff_code_offset(to_integer(DC_AC_decode &"1001")) (8 downto 0) &'0'));   
 			h_delta(10)<=(Barrel(15 downto 5)- ("00000"&huff_code_offset(to_integer(DC_AC_decode &"1010")) (9 downto 0) &'0'));   
 			h_delta(11)<=(Barrel(15 downto 4)- ("0000"&huff_code_offset(to_integer(DC_AC_decode &"1011")) (10 downto 0) &'0'));   
 			h_delta(12)<=(Barrel(15 downto 3)- ("000"&huff_code_offset(to_integer(DC_AC_decode &"1100")) (11 downto 0) &'0'));   
 			h_delta(13)<=(Barrel(15 downto 2)- ("00"&huff_code_offset(to_integer(DC_AC_decode &"1101")) (12 downto 0) &'0'));   
 			h_delta(14)<=(Barrel(15 downto 1)- ("0"&huff_code_offset(to_integer(DC_AC_decode &"1110")) (13 downto 0) &'0'));   
 			h_delta(15)<=(Barrel(15 downto 0)- (huff_code_offset(to_integer(DC_AC_decode &"1111")) (14 downto 0) &'0'));  
end if;
end process;

process(clk)
begin
if clk'event and clk='1' then
      DC_AC_old(0)<=DC_AC_decode(0);
      if state=sos_scan then
	  if DC_AC_decode(0)='0' and DC_AC_old(0)='1' then
	      next_eob<='1';
	  else
	      next_eob<='0';
	  end if;
      end if;
end if;
end process;
-------------------------------------------------------------------------------------------------------------------------
--code_word<=HUFF_RAM(to_integer(ram_pointer(DC_AC_decode,0,read_offset)+h_delta(read_offset)(8 downto 0)));

ram_offset<=ram_pointer(to_integer(DC_AC_decode & to_unsigned(read_offset,4))); --begin the actual codeword table

--recognise code word

process(clk,write_active)
begin
	if clk'event and clk='1' then
		read_offset<=read_offset_a;

	if state=sos_header then
		code_word<=to_unsigned(1,code_word'length);
	end if;

	if sos_state=catch then
		code_word<=HUFF_RAM(to_integer(ram_offset+h_delta(read_offset)(8 downto 0)));
	end if;
	end if;

end process;

read_offset_a<= 	
	 0 when  Barrel(15 downto 15)< huff_code_offset(to_integer(DC_AC_decode &"0001")) (0 downto 0)  else 
 	1 when  Barrel(15 downto 14)< huff_code_offset(to_integer(DC_AC_decode &"0010")) (1 downto 0)  else
 	2 when  Barrel(15 downto 13)< huff_code_offset(to_integer(DC_AC_decode &"0011")) (2 downto 0)  else
 	3 when  Barrel(15 downto 12)< huff_code_offset(to_integer(DC_AC_decode &"0100")) (3 downto 0)  else
 	4 when  Barrel(15 downto 11)< huff_code_offset(to_integer(DC_AC_decode &"0101")) (4 downto 0)  else
 	5 when  Barrel(15 downto 10)< huff_code_offset(to_integer(DC_AC_decode &"0110")) (5 downto 0)  else
 	6 when  Barrel(15 downto 9)< huff_code_offset(to_integer(DC_AC_decode &"0111")) (6 downto 0)  else
 	7 when  Barrel(15 downto 8)< huff_code_offset(to_integer(DC_AC_decode &"1000")) (7 downto 0)  else
 	8 when  Barrel(15 downto 7)< huff_code_offset(to_integer(DC_AC_decode &"1001")) (8 downto 0)  else
 	9 when  Barrel(15 downto 6)< huff_code_offset(to_integer(DC_AC_decode &"1010")) (9 downto 0)  else
 	10 when  Barrel(15 downto 5)< huff_code_offset(to_integer(DC_AC_decode &"1011")) (10 downto 0)  else
 	11 when  Barrel(15 downto 4)< huff_code_offset(to_integer(DC_AC_decode &"1100")) (11 downto 0)  else
 	12 when  Barrel(15 downto 3)< huff_code_offset(to_integer(DC_AC_decode &"1101")) (12 downto 0)  else
 	13 when  Barrel(15 downto 2)< huff_code_offset(to_integer(DC_AC_decode &"1110")) (13 downto 0)  else
 	14 when  Barrel(15 downto 1) < huff_code_offset(to_integer(DC_AC_decode &"1111")) (14 downto 0)  else
 	15;

shift<= 	
	 1 when  Barrel(15 downto 15)< huff_code_offset(to_integer(DC_AC_decode &"0001")) (0 downto 0)  else 
 	2 when  Barrel(15 downto 14)< huff_code_offset(to_integer(DC_AC_decode &"0010")) (1 downto 0)  else
 	3 when  Barrel(15 downto 13)< huff_code_offset(to_integer(DC_AC_decode &"0011")) (2 downto 0)  else
 	4 when  Barrel(15 downto 12)< huff_code_offset(to_integer(DC_AC_decode &"0100")) (3 downto 0)  else
 	5 when  Barrel(15 downto 11)< huff_code_offset(to_integer(DC_AC_decode &"0101")) (4 downto 0)  else
 	6 when  Barrel(15 downto 10)< huff_code_offset(to_integer(DC_AC_decode &"0110")) (5 downto 0)  else
 	7 when  Barrel(15 downto 9)< huff_code_offset(to_integer(DC_AC_decode &"0111")) (6 downto 0)  else
 	8 when  Barrel(15 downto 8)< huff_code_offset(to_integer(DC_AC_decode &"1000")) (7 downto 0)  else
 	9 when  Barrel(15 downto 7)< huff_code_offset(to_integer(DC_AC_decode &"1001")) (8 downto 0)  else
 	10 when  Barrel(15 downto 6)< huff_code_offset(to_integer(DC_AC_decode &"1010")) (9 downto 0)  else
 	11 when  Barrel(15 downto 5)< huff_code_offset(to_integer(DC_AC_decode &"1011")) (10 downto 0)  else
 	12 when  Barrel(15 downto 4)< huff_code_offset(to_integer(DC_AC_decode &"1100")) (11 downto 0)  else
 	13 when  Barrel(15 downto 3)< huff_code_offset(to_integer(DC_AC_decode &"1101")) (12 downto 0)  else
 	14 when  Barrel(15 downto 2)< huff_code_offset(to_integer(DC_AC_decode &"1110")) (13 downto 0)  else
 	15 when  Barrel(15 downto 1) < huff_code_offset(to_integer(DC_AC_decode &"1111")) (14 downto 0)  else
 	16;	
   

---------------------------------------
process(clk,write_active)
begin
	if clk'event and clk='1' then
		if sos_state=catch then
			ba<=barrel;
		end if;
	end if;
end process;

process(clk)
begin

	if clk'event and clk='1' then
		if sos_state=decode then
			-- ba_1<=ba(15); --entscheide positiver Wert oder negativ 1 posiver Wert!!!!!
			
		if ba(15)='1' then
			case code_word(3 downto 0) is
			when X"0" => value<=X"0000";
			when X"1" => value<=(0=>'1',others=>'0');
			when X"2" => value<=(1=>'1',0=>ba(14),others=>'0');
			when X"3" => value<=(2=>'1',1=>ba(14),0=>ba(13),others=>'0');
			when X"4" => value<=(3=>'1',2=>ba(14),1=>ba(13),0=>ba(12),others=>'0');
			when X"5" => value<=(4=>'1',3=>ba(14),2=>ba(13),1=>ba(12),0=>ba(11),others=>'0');
			when X"6" => value<=(5=>'1',4=>ba(14),3=>ba(13),2=>ba(12),1=>ba(11),0=>ba(10),others=>'0');
			when X"7" => value<=(6=>'1',5=>ba(14),4=>ba(13),3=>ba(12),2=>ba(11),1=>ba(10),0=>ba(9),others=>'0');
			when others=>null;
			end case;
		else
			case code_word(3 downto 0) is
			when X"0" => value<=X"0000";
			when X"1" => value<=to_signed(-1,16);
			when X"2" => value<="000000000000000"&ba(14)-3;
			when X"3" => value<="00000000000000"&ba(14)&ba(13)-7;
			when X"4" => value<="0000000000000"&ba(14)&ba(13)&ba(12)-15;
			when X"5" => value<="000000000000"&ba(14)&ba(13)&ba(12)&ba(11)-31;
			when X"6" => value<="00000000000"&ba(14)&ba(13)&ba(12)&ba(11)&ba(10)-63;
			when X"7" => value<="0000000000"&ba(14)&ba(13)&ba(12)&ba(11)&ba(10)&ba(9)-127;
			when others=>null;
			end case;


		end if;
		end if;
	end if;

end process;

--------------------------------------------------------------------------------------------
--Anzahl der Componenten lesen und welche Hufftabe genommen wird
process (clk,write_active)
begin
if write_active='1' then
	if clk'event and clk='1' then
		if next_state=SOS_Header and state/=SOS_Header then
			SOS_number_comp<=input_reg(7 downto 0);
			SOS_Header_state<=selector;
			SOS_Header_index<=0;
		end if;
	
		if SOS_Header_Index < SOS_number_comp then
			if SOS_Header_state=selector  then
				--SOS_selector<=input_reg(15 downto 7);
				SOS_header_state<=table; 	
			 end if;
			if SOS_Header_state=table then	
				SOS_comp_table(SOS_Header_index)<= input_reg(7 downto 0);
				
				SOS_header_state<=selector;
				SOS_Header_index<=SOS_Header_index+1;
			end if;
		end if;
		
	end if;
end if;
end process;
--------------------------------------------------------------------------------------------
process(clk,write_active)
begin
if write_active='1' then
	if clk'event and clk='1' then
		if ((next_state=SOF0_length) or (next_state=DQT_length) or (next_state=DHT_length)or (next_state=SOS_length)) then	
			Markerlength<=unsigned(input_reg(15 downto 0));
		else
			Markerlength<=Markerlength-1;
		end if;
	end if;
end if;
end process;


process(clk,write_active) --DQT  read

variable element: integer range 0 to 64:=0;
variable destination: integer range 0 to 1;
variable multible : integer range 0 to 1;
begin
if write_active='1' then
	if clk'event and clk='1' then
		if state=DQT_length0 then
			multible:=1;
			
		end if;
		if state=DQT_length then			
				element:=64;   --paralle wird Markerlength gesetzt
					
		end if;
		if state=DQT_active then
			if element=62 then				
				if Markerlength<10 then  -- Wenn mehrere Tabellen hintereinander hängen
			--der wert muss ausreichend gross sein 10 nur gewaehlt
				multible:=0;
				end if;
			end if;
            		if (element=64 and multible=1) then

				destination:=to_integer(unsigned(input_reg (8 downto 8)));
				element:=0;
				
			end if;
			if element <64 then
				qtable(destination,zigzag(element))<=unsigned(input_reg(7 downto 0));
				element:=element +1;
			end if;			
		end if;
	end if;
end if;	
end process;	


process(clk,write_active)
begin

if clk'event and clk='1' then
	  if write_active='1' then
		input_reg (7 downto 0)<= data_in;
		input_reg (15 downto 8)<= input_reg(7 downto 0);
		input_reg (23 downto 16)<= input_reg (15 downto 8);
	  end if;
	  if eoi_detect(0)='1' then     --else bit stuffing at 0xFFD9 !!
		 input_reg (7 downto 0)<= X"00";
 		input_reg (15 downto 8)<= input_reg(7 downto 0);
 		input_reg (23 downto 16)<= input_reg (15 downto 8); 
	  end if;
end if;
end process;


state_machine: process(clk,write_active)
begin


	
	if clk'event and clk='1' then
	if  eoi_detect="11" and output_valid='1' then next_state<=EOI; 
		end if;
	if (state=DHT_active and huff_table_end='1') then 
		state<=DHT_destination;
		next_state<=DHT_number;
		dht_counter<=0;
	end if;
	    if next_state=EOI then 
		state<=EOI;
	    end if;
	    if write_active='1' then
			state<=next_state;
			case input_reg(15 downto 0) is
			when  X"FFD8"=> 	next_state<=SOI;
			when  x"FFE0"=>		next_state<=APP0;
			when  x"FFDB"=>		next_state<=DQT_length0;
			when  x"FFC0"=>		next_state<=SOF0_length0;
			when  x"FFC4"=>		next_state<=DHT_length0;
			when  x"FFDA"=>		next_state<=SOS_length0;
			--when  x"FFD9"=>		eoi_detect(0)<='1';
			when others => 
			
			if next_state=DQT_length0 then next_state<=DQT_length; end if;
			if next_state=DQT_length then next_state<=DQT_active; end if;

			if next_state=SOF0_length0 then next_state<=SOF0_length; end if;
			if next_state=SOF0_length then next_state<=SOF0_precision; end if;
			if next_state=SOF0_precision then next_state<=SOF0_y_high; end if;
			if next_state=SOF0_y_high then next_state<=SOF0_y_low; end if;
			if next_state=SOF0_y_low then next_state<=SOF0_x_high; end if;
			if next_state=SOF0_x_high then next_state<=SOF0_x_low; end if;
			if next_state=SOF0_x_low then next_state<=SOF0_nr_comp; end if;
			if next_state=SOF0_nr_comp then next_state<=SOF0_active; end if;
	
			--SOS
			if next_state=SOS_length0 then next_state<=SOS_length; end if;
			if next_state=SOS_length then next_state<=SOS_header; end if;
			if next_state=SOS_header and markerlength=3 then --der scan hat keine Laengenmarke
			next_state<=SOS_init0; end if;
			if next_state=SOS_init0 then next_state<=SOS_init1; end if;
			if next_state=SOS_init1 then next_state<=SOS_init2; end if;
			if next_state=SOS_init2 then next_state<=SOS_init3; end if;
			if next_state=SOS_init3 then next_state<=SOS_scan; end if;
			
			--Hufftable
			if next_state=DHT_length0 then next_state<=DHT_length; end if;
			if next_state=DHT_length then next_state<=DHT_destination; end if;
			if next_state=DHT_destination then 
				next_state<=DHT_Number;
				dht_counter<=0;
			 end if;
			if next_state=DHT_Number then 
				dht_counter<=dht_counter+1;
			end if;
			if next_state=DHT_Number and dht_counter=15 then 
			next_state<=DHT_active; end if;
			--multible tables
			
			if next_state=DHT_active and Markerlength=2 then next_state<=idle; end if;
					end case;
	
end if;
end if;
end process state_machine;

--------------------------------------------------
 --x_size,y_size:unsigned (15 downto 0);  --picture size
--------------------------------------------------

process(clk,write_active) --SOF0 einlesen

begin
if write_active='1' then
	if clk'event and clk='1' then
		if state=SOF0_y_high then
			y_size(15 downto 8) <= input_reg(15 downto 8);
		end if;
		if state=SOF0_y_low  then
			y_size(7 downto 0) <= input_reg(15 downto 8);
		end if;
		if state=SOF0_x_high then
			x_size(15 downto 8) <= input_reg(15 downto 8);
		end if;
		if state=SOF0_x_low  then
			x_size(7 downto 0) <= input_reg(15 downto 8);
		end if;	
		if state=SOF0_nr_comp  then
			SOF0_number_comp <= input_reg(15 downto 8);
			SOF0_Header_index<= 0;
			SOF0_header_state<=selector;
		end if;	
		if SOF0_Header_Index < SOF0_number_comp then
 
			if SOF0_Header_state=selector then
				SOF0_Header_state<=Sampling;					
			end if;
			if SOF0_Header_state=sampling then
				SOF0_comp_table(SOF0_Header_index)(15 downto 8)<=input_reg(15 downto 8);
				SOF0_Header_state<=table;
			end if;
			if SOF0_Header_state=table then	
				SOF0_comp_table(SOF0_Header_index)(7 downto 0)<=input_reg(15 downto 8);
				SOF0_Header_state<=selector;
				SOF0_Header_index<=SOF0_Header_index+1;
			end if;
		end if;	

	end if;
end if;
end process;
----------------------------------------------------
process(clk,write_active) --Hufftable read
variable dest:unsigned(1 downto 0); --destination
variable DC_AC:unsigned(0 downto 0); --AC oder DC Table
					--'0' entspricht DC
begin


if clk'event and clk='1' then
	if wr='1' then
		if state=SOI then
			ADDR<=0;
		end if;
		if state=DHT_destination then
			index<=0;
			dest:=input_reg(9 downto 8);--0-1 Baseline 
			DC_AC:=input_reg(12 downto 12);  --0 DC / 1 AC
			
		end if;

		if state=DHT_Number then
			huff_table_end<='0';
			huff_a<=to_unsigned(0,8);
			huff_code_number(index)<=input_reg(15 downto 8);
			h_code<=X"0000";
			if index< 15 then
				index<=index+1;
			end if;
			if index=15 then
				index<=0;
			end if;
		end if;
		
		if state=DHT_active and huff_a>0 then
				huff_a<=huff_a-1;
				Huff_RAM(addr)<=input_reg(15 downto 8);
				addr<=addr+1;
				h_code<=h_code+1;
		end if;
	end if;
	--if next_state=DHT_active
	if state=DHT_active and huff_a=0 then
			huff_a<=huff_code_number(index);
			ram_pointer(to_integer(dest&DC_AC&to_unsigned(index,4)))<= addr;
			if index<15 then
				index<=index+1;	
				h_code<=h_code (14 downto 0) &'0' ; --shift left
			
				huff_code_offset(to_integer(dest& DC_AC & to_unsigned(index,4)))<=h_code;
			end if;
			if index=15 then
				huff_table_end<='1';
			end if;
			 
	end if;	
end if;

end process;
huff_wr_en<='0' when ((huff_a=0 or huff_table_end='1')and  (state=dht_active) and not (next_state=idle)) else '1';


--- syncronisation information
-- sop.......... start of picture 
-- eop.......... end of picture
process(clk)
begin
if  clk'event and clk='1' then
    if state=sos_length then
	sop<='1';
    else
	sop<='0';
    end if;

    if state=EOI then
	eop<='1';
    else
	eop<='0';
    end if;
end if;
end process;

end Behavioral;

