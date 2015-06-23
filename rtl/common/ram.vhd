----------------------------------------------------------------------------------
-------------------------- Componente memoria ------------------------------------
----------------------------------------------------------------------------------
-- Entrada de configuracao:														--
--  dim - dimensao da memoria (numero de palavra de 16 bits)					--
--																				--
-- Portos de entrada de controlo de leitura e escrita nos ficheiros:			--
--	read_file  - carrega a memoria com os dados presentes no ficheiro "rom.out"	--
--  write_file - carrega no ficheiro "data.out" os dados presentes na memoria	--
--																				--
-- Portos de acesso a memoria:													--
--   we 	- enable de escrita													--
--   clk    - sinal de relogio													--
--   address - endereo de acesso a memoria										--
--	 data   - entrada de daos para escrita										--
--   q      - saida de dados para leitura									    --
----------------------------------------------------------------------------------
--           Componente memoria desenvolvida para a disciplina de 			    --
--                 Arquitecturas Avanadas de Computadores						--
----------------------------------------------------------------------------------
-- Non synthetizable															--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use std.textio;
use ieee.stc_logic_textio.all;	

entity ram is
	generic (dim : integer := 1024)	;
	port (
		-- control bits for file manipulation ---------
		read_file : in std_logic;
		write_file : in std_logic;
		-----------------------------------------------	
		we : in std_logic;
		clk: in std_logic;
		address : in std_logic_vector(15 downto 0);	 
		data : in std_logic_vector (15 downto 0);
		q : out std_logic_vector (15 downto 0)
	);

end ram;

architecture behavioral of ram is
	type ram_mem_type is array (dim-1 downto 0) of std_logic_vector (15 downto 0);
	signal ram_mem, ram_mem2 : ram_mem_type;
begin

	------------------------------------------------------------------------------
	-- memory access -------------------------------------------------------------
	------------------------------------------------------------------------------
	process (clk)
		variable addr_wr_temp: integer;
	begin
		if((clk'event) and (clk='1')) then 
			if (read_file = '1') then
				ram_mem <= ram_mem2;
			elsif ((we = '1') and (not (read_file = '1'))) then 
				addr_wr_temp := conv_integer(address); 
				assert(dim > addr_wr_temp)
				report " Tentou aceder a uma posicao de memoria nao defenida!"
		     	severity ERROR; --FAILURE; --WARNING;
		  		ram_mem(addr_wr_temp) <= data;
			end if;
		end if;	
	end process;								

	q <= ram_mem(conv_integer(address));

	------------------------------------------------------------------------------
	-- when read_file is '1' the file rom.out is writen in memory ----------------
	------------------------------------------------------------------------------
	read : process(read_file)
		file in_file : TEXT  is in "/home/joaocarlos/workspace/xilinx-ise/uRISC/MEM/rom.out";
		variable data_temp : std_logic_vector(15 downto 0);	
		variable in_line: LINE;  		
		variable index :integer;
	begin			 
		if((read_file'event) and (read_file='1')) then
			index := 0;
		  	while NOT(endfile(in_file)) loop
				readline(in_file,in_line);	
				hread(in_line, data_temp)
				ram_mem2(index) <= data_tem
				index := index + 1
		  	end loop;
		end if;		

	end process read;	

	--------------------------------------------------------------------------------
	-- when write_file is '1' the memory is writen in file data.out ----------------
	--------------------------------------------------------------------------------
	write : process( write_file)	
		file out_file : TEXT is out "/home/joaocarlos/workspace/xilinx-ise/uRISC/MEM/data.out";
		variable out_line : LINE;
		variable index :integer;
	begin
		if((write_file'event) and (write_file='1')) then
			index := 0;
			while (index < dim) loop	
		--		write(out_line,index);
		--		write(out_line,":");
				hwrite(out_line,ram_mem(index));
				writeline(out_file,out_line);	
				index := index + 1;
		  	end loop;
		end if;	
	end process write;	

end behavioral;

