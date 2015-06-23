-- Testbech for Camellia Algorithm Implementation
-- purpose : testbench file
-- file: camellia_core_tb.vhd
-- Ahmad Rifqi H (13200013)
-- 2004/Sept/20


LIBRARY work  ; 
LIBRARY ieee  ; 
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.camellia_package.all  ; 
USE ieee.std_logic_arith.all  ; 
USE ieee.std_logic_1164.all  ; 
ENTITY camellia_core_tb  IS 
END ; 
 
ARCHITECTURE camellia_core_tb_arch OF camellia_core_tb IS
  CONSTANT	CLK_PER		: time := 45 ns;
  FILE key_file  : text IS in
       "KAT_vectors/key.txt"; -- plaintext
  FILE plain_file  : text IS in
       "KAT_vectors/plaintext.txt"; -- plaintext
  FILE cipher_file : text IS in
       "KAT_vectors/ciphertext.txt"; -- input ciphertext
  FILE cipher_o_file : text IS out
       "KAT_vectors/out.txt"; -- output ciphertext
 
  SIGNAL out_ready   :  std_logic  ; 
  SIGNAL proc   :  std_logic  ; 
  SIGNAL input_ready   :  std_logic  ; 
  SIGNAL clock   :  std_logic  := '0'; 
  SIGNAL input   :  std_logic_vector (0 to 127)  ; 
  SIGNAL key_ready   :  std_logic  ; 
  SIGNAL inv   :  std_logic  ; 
  SIGNAL data_output   :  std_logic_vector (0 to 127)  ; 
  SIGNAL reset   :  std_logic  ; 
  COMPONENT camellia_core  
    PORT ( 
      out_ready  : out std_logic ; 
      proc  : in std_logic ; 
      input_ready  : in std_logic ; 
      clock  : in std_logic ; 
      input  : in std_logic_vector (0 to 127) ; 
      key_ready  : in std_logic ; 
      inv  : in std_logic ; 
      data_output  : out std_logic_vector (0 to 127) ; 
      reset  : in std_logic ); 
  END COMPONENT ; 
BEGIN
  DUT  : camellia_core  
    PORT MAP ( 
      out_ready   => out_ready  ,
      proc   => proc  ,
      input_ready   => input_ready  ,
      clock   => clock  ,
      input   => input  ,
      key_ready   => key_ready  ,
      inv   => inv  ,
      data_output   => data_output  ,
      reset   => reset   ) ; 
      
      PROCESS
	   BEGIN
  	      WAIT for CLK_PER / 2;
		  	        clock <= NOT clock;
	   END PROCESS;
 PROCESS
		VARIABLE tmp_data_in			: std_logic_vector (0 to 127);
		VARIABLE tmp_key, tmp_cipher			: std_logic_vector (0 to 127);
		VARIABLE L1,L3,L4   					  : line;
		--VARIABLE counter					: integer := 0;
		BEGIN

		reset <= '1';
		inv <= '0';		
		key_ready <= '0';
		input_ready <= '0';
		proc <= '0';
		wait for 2*CLK_PER;
		reset <= '0';
		WAIT FOR CLK_PER;
		
		FOR i IN 0 TO 41 LOOP	 	
				IF NOT (ENDFILE(key_file)) THEN
					READLINE(key_file, L3);
					HREAD(L3, tmp_key);
				ELSE
					tmp_key := (OTHERS => 'X');
				END if;
				
				IF NOT (ENDFILE(plain_file)) THEN
					READLINE(plain_file, L1);
					HREAD(L1, tmp_data_in);
				ELSE
					tmp_data_in := (OTHERS => 'X');
				END if;
				
				IF NOT (ENDFILE(cipher_file)) THEN
					READLINE(cipher_file, L4);
					HREAD(L4, tmp_cipher);
				ELSE
					tmp_cipher := (OTHERS => 'X');
				END if;
				
			reset <= '1';---------ENCRYPTION-------
			inv <= '0';
			WAIT FOR CLK_PER;
			reset <= '0';	
			WAIT FOR CLK_PER;
			input <= tmp_key;
			key_ready <= '1';
			WAIT FOR CLK_PER;
			key_ready <= '0';
			proc <= '1';
			WAIT FOR 1*CLK_PER;
			proc <= '0';
			input <= tmp_data_in;
			WAIT FOR 1*CLK_PER;
			input_ready <= '1';
			WAIT FOR 1*CLK_PER;
			input_ready <= '0';
			proc <= '1';
			WAIT FOR CLK_PER;
			proc <= '0';
			wait for 5*CLK_PER;
			
			reset <= '1';---------DECRYPTION-------
			inv <= '1';
			WAIT FOR CLK_PER;
			reset <= '0';	
			WAIT FOR CLK_PER;
			input <= tmp_key;
			key_ready <= '1';
			WAIT FOR CLK_PER;
			key_ready <= '0';
			proc <= '1';
			WAIT FOR 1*CLK_PER;
			proc <= '0';
			input <= tmp_cipher;
			WAIT FOR 1*CLK_PER;
			input_ready <= '1';
			WAIT FOR 1*CLK_PER;
			input_ready <= '0';
			proc <= '1';
			WAIT FOR CLK_PER;
			proc <= '0';
			wait for 5*CLK_PER;
			
	   END loop;
		
		reset <= '1';
		input <= (others => '0');
			
		WAIT;
	END PROCESS;



		PROCESS(clock)
		VARIABLE L2	: line;
		BEGIN
			IF clock'EVENT AND clock = '1' THEN
				IF out_ready = '1' THEN
					HWRITE(L2, data_output);
					WRITELINE(cipher_o_file, L2);
				END if;
			END if;
		END PROCESS;
      
END ;

