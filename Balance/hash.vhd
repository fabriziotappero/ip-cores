-------------------------------------------------
----Hash Function---
	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	USE IEEE.STD_LOGIC_ARITH.ALL;
	USE IEEE.STD_LOGIC_UNSIGNED.ALL;
	USE IEEE.NUMERIC_STD.ALL;
	USE IEEE.STD_LOGIC_MISC.ALL;
----------------
	ENTITY hash IS
		GENERIC(
			KEY_WIDTH 	: 	NATURAL := 48;--Hash key width
			ADD_WIDTH 	: 	NATURAL := 12; --address width
			HASH_NO 	: 	NATURAL := 4 --Hash number
		);
		PORT (
			key 		: 	STD_LOGIC_VECTOR(47 DOWNTO 0);	--Hash key 
			address 	: 	OUT STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0)		--address 
		);
	END ENTITY hash;
---------------------------------
	ARCHITECTURE behavioral OF hash IS
		TYPE matrix_generator_type IS ARRAY (0 TO ADD_WIDTH-1) OF STD_LOGIC_VECTOR(KEY_WIDTH-1 DOWNTO 0);
		TYPE  matrix_type IS ARRAY (0 TO 3) OF matrix_generator_type ;
		CONSTANT matrix : matrix_type:=(
					(X"1066cb9fe7bc", X"d56494892645", X"492cf1e56e26", X"fbd5ee7df102",
					 X"da6ff1b5421b", X"2186ffc8bdb6", X"9089eb857902", X"4315d53c7df8",
					 X"c13cbcb713d7", X"9c1b26e99383", X"1ff39e15912a", X"b4008e58a8c9"), -- H1 					
					(X"02a6200f47d5", X"812bbc47a2a4", X"1bcc1d1cb32a", X"5158420941ea",
					 X"c13cbcb713d7", X"9c1b26e99383", X"1ff39e15912a", X"b4008e58a8c9",
					 X"c13cbcb713d7", X"9c1b26e99383", X"1ff39e15912a", X"b4008e58a8c9"), -- H2					
					(X"2ce30e05be00", X"e8e3eefc2b70", X"5b3a5cdff1d3", X"087f63fb3838",
					 X"f43c6ceb8b24", X"b3e80a27240e", X"88a21edc44d7", X"9a0320707b17",
					 X"c13cbcb713d7", X"9c1b26e99383", X"1ff39e15912a", X"b4008e58a8c9"), -- H3					
					(X"27d0a50ed2db", X"7f09c83e8ce3", X"73af4e487d3f", X"6f02e7293763",
					 X"87ebcfd7adfe", X"ed4fe1631a21", X"88c79139eee0", X"e4dde0201768",
					 X"c13cbcb713d7", X"9c1b26e99383", X"1ff39e15912a", X"b4008e58a8c9")  -- H4
					
							);
		
		SIGNAL matrix_wires : matrix_generator_type;
		BEGIN
		PROCESS(key ,matrix_wires)
		BEGIN
			FOR row IN 0 TO ADD_WIDTH-1 LOOP
				FOR col IN 0 TO KEY_WIDTH-1 LOOP
					matrix_wires(row)(col)<= matrix(HASH_NO-1)(row)(col) AND key(col) ;
				END LOOP;
				
					address(row) <=  XOR_REDUCE(matrix_wires(row)) ;--XOR address(row);
				
			END LOOP; 
		END PROCESS;
	END ARCHITECTURE behavioral;