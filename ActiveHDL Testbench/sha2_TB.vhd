library sha2;
use sha2.shaPkg.all;
library ieee;			   
use ieee.std_logic_1164.all;		   
use ieee.numeric_std.all;					 
use work.std_logic_1164_additions.all; 

  -- Add your library and packages declaration here ...

entity sha2_tb is
end sha2_tb;

architecture TB_ARCHITECTURE of sha2_tb is
  -- Component declaration of the tested unit   
  component sha2
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;								 
      chunk       : in  std_logic_vector(0 to CW-1);
      len         : in  std_logic_vector(0 to CLENBIT-1);
      load        : in  std_logic;                 
      hash        : out std_logic_vector(0 to WW-1);
      valid       : out std_logic
    );                
  end component;

  -- Stimulus signals - signals mapped to the input and inout ports of tested entity
  signal clk         : std_logic := '0';
  signal rst         : std_logic;					 			   
  signal chunk       : std_logic_vector(0 to CW-1);
  signal len         : std_logic_vector(0 to CLENBIT-1);
  signal load        : std_logic;

  -- Observed signals - signals mapped to the output ports of tested entity
  signal hash        : std_logic_vector(0 to WW-1);
  signal valid       : std_logic;
  signal stop        : std_logic;
  signal finish      : std_logic;
  signal output_hash : std_logic_vector(0 to OS-1);
  signal hash_read   : integer;

  -- Add your code here ...
     
  constant clk_period : time := 50 ns;
begin
  clk <= not clk after clk_period / 2;

  -- Unit Under Test port map
  UUT : sha2
  port map (
      clk        => clk,
      rst        => rst,
      chunk   	 => chunk,
      len        => len,
      load       => load,
      hash       => hash,
      valid      => valid
  );

  -- Add your stimulus here ...  
  test : process (clk) 
  
  -- Choose a Benchmark !!!	
  -- for test http://www.fileformat.info/tool/hash.htm	SHA-256 from ASCII and HEX
  -- http://www.miniwebtool.com/sha224-hash-generator SHA-224 only ASCII
  
  -- TEST VECTOR SHA-224 (includere sha224Pkg ed escludere sha256Pkg)
  -- EMPTY STRING
  --variable text_len : integer := 0; variable text : std_logic_vector(0 to 3) := x"0"; variable expected_hash : std_logic_vector(0 to OS-1) := x"d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f";
  -- abc
  --variable text_len : integer := 24; variable text : std_logic_vector(0 to text_len-1) := x"616263"; variable expected_hash : std_logic_vector(0 to OS-1) := x"23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7";
  -- The quick brown fox jumps over the lazy dog
  --variable text_len : integer := 344; variable text : std_logic_vector(0 to text_len-1) := x"54686520717569636b2062726f776e20666f78206a756d7073206f76657220746865206c617a7920646f67"; variable expected_hash : std_logic_vector(0 to OS-1) := x"730e109bd7a8a32b1cb9d9a09aa2325d2430587ddbc0c38bad911525";
  -- The quick brown fox jumps over the lazy dog.
  --variable text_len : integer := 352; variable text : std_logic_vector(0 to text_len-1) := x"54686520717569636b2062726f776e20666f78206a756d7073206f76657220746865206c617a7920646f672e"; variable expected_hash : std_logic_vector(0 to OS-1) := x"619cba8e8e05826e9b8c519c0a5c68f4fb653e8a3d8aa04bb2c8cd4c";
  -- 60 caratteri 'a' (60*8+1 % 512 > 448, richiede blocco extra)
  --variable text_len : integer := 480; variable text : std_logic_vector(0 to text_len-1) := x"616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161"; variable expected_hash : std_logic_vector(0 to OS-1) := x"efda4316fe2d457d622cf1fc42993d41566f77449b7494b38e250c41";
  -- 115 caratteri 'a' (125*8 % 512 < 448, NON richiede blocco extra)
  --variable text_len : integer := 920; variable text : std_logic_vector(0 to text_len-1) := x"61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161"; variable expected_hash : std_logic_vector(0 to OS-1) := x"3705538e8bcc6a326824e0aa1cb57a5eea41bd332f39eb296b78a06c";
  -- 125 caratteri 'a' (125*8 % 512 > 448, richiede blocco extra)
  --variable text_len : integer := 1000; variable text : std_logic_vector(0 to text_len-1) := x"6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161"; variable expected_hash : std_logic_vector(0 to OS-1) := x"0087b823c4dfaefcca81f8ff6c5d1a3ca0104d466e51fc6b450b1494";
  -- 126 caratteri 'abc' (126*8+1 % 512 > 448, richiede blocco extra)
  --variable text_len : integer := 1008; variable text : std_logic_vector(0 to text_len-1) := x"616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263"; variable expected_hash : std_logic_vector(0 to OS-1) := x"c50b5fd769d58c627b773ec065ced52eb5b461fe90a444c2ea498661";
  
  -- TEST VECTOR SHA-256 (includere sha256Pkg ed escludere sha224Pkg)
  -- EMPTY STRING
  --variable text_len : integer := 0; variable text : std_logic_vector(0 to 3) := x"0"; variable expected_hash : std_logic_vector(0 to OS-1) := x"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
  -- abc
  --variable text_len : integer := 24; variable text : std_logic_vector(0 to text_len-1) := x"616263"; variable expected_hash : std_logic_vector(0 to OS-1) := x"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
  -- The quick brown fox jumps over the lazy dog
  --variable text_len : integer := 344; variable text : std_logic_vector(0 to text_len-1) := x"54686520717569636b2062726f776e20666f78206a756d7073206f76657220746865206c617a7920646f67"; variable expected_hash : std_logic_vector(0 to OS-1) := x"d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592";
  -- The quick brown fox jumps over the lazy dog.
  --variable text_len : integer := 352; variable text : std_logic_vector(0 to text_len-1) := x"54686520717569636b2062726f776e20666f78206a756d7073206f76657220746865206c617a7920646f672e"; variable expected_hash : std_logic_vector(0 to OS-1) := x"ef537f25c895bfa782526529a9b63d97aa631564d5d789c2b765448c8635fb6c";
  -- 60 caratteri 'a' (60*8+1 % 512 > 448, richiede blocco extra)
  --variable text_len : integer := 480; variable text : std_logic_vector(0 to text_len-1) := x"616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161"; variable expected_hash : std_logic_vector(0 to OS-1) := x"11ee391211c6256460b6ed375957fadd8061cafbb31daf967db875aebd5aaad4";
  -- 115 caratteri 'a' (125*8+1 % 512 < 448, NON richiede blocco extra)
  --variable text_len : integer := 920; variable text : std_logic_vector(0 to text_len-1) := x"61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161"; variable expected_hash : std_logic_vector(0 to OS-1) := x"64410e651b346524cfe56e68c237ea76c0377921697027eb794a067501fb2910";
  -- 125 caratteri 'a' (125*8+1 % 512 > 448, richiede blocco extra)
  --variable text_len : integer := 1000; variable text : std_logic_vector(0 to text_len-1) := x"6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161"; variable expected_hash : std_logic_vector(0 to OS-1) := x"a8e1a0f35c15c01a458bcb345528b751556c14850f6f9bdcc9933b8003d29b43";
  -- 126 caratteri 'abc' (126*8+1 % 512 > 448, richiede blocco extra)
  variable text_len : integer := 1008; variable text : std_logic_vector(0 to text_len-1) := x"616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263616263"; variable expected_hash : std_logic_vector(0 to OS-1) := x"bfd187c5d9f06e35d0794555203b0d043cb6e6b4a5176c763a7892891bd3a9e2";

  -- CUSTOM
  --variable text_len : integer := ;
  --variable text : std_logic_vector(0 to text_len-1) := x"";
  --variable expected_hash : std_logic_vector(0 to OS-1) := x"";
  
  variable doloop : bit := '1';	 -- conversioni cicliche
  variable num_a : integer := 0; -- numero di caratteri 'a' == "aaa...aa" 
  
  variable counter : integer := -2;
  variable last_blk : std_logic_vector(0 to WW-1);
  variable c : unsigned(0 to CW-1) := "00000001";
  variable index : integer := 0;
  begin
	   
    if (clk'event and clk = '0') then		
	  c := c rol 1;
	  
      if counter < 0 then				
		stop <= '0';				
		finish <= '0';
        rst  <= '1';
        load <= '0';
        chunk <= (others => '0');
		len <= (others => '0');
		output_hash <= (others => '0');
		hash_read <= 0;
      else
		  if valid = '1' then
			output_hash(hash_read * WW to (hash_read + 1) * WW - 1) <= hash;
			hash_read <= hash_read + 1;
		  elsif hash_read = WOUT then
			hash_read <= 0;
		    if output_hash = expected_hash then							   
			  report "--------- COMPUTE HASH OK --------" severity NOTE;
			  report to_hstring(output_hash) severity NOTE;
		    else														   
			  report "--------- COMPUTED: --------" severity NOTE;
			  report to_hstring(output_hash) severity NOTE;   
			  report "--------- EXPECTED: --------" severity NOTE; 	   
			  report to_hstring(expected_hash) severity NOTE; 
			  report "--------- COMPUTE HASH FAILED --------" severity FAILURE;
		    end if;
		    finish <= '1';
		  end if;
	  
		  if doloop = '1' and finish = '1' and index = 30 then
			counter := 0;
			index := 0;				
			stop <= '0'; 				
			finish <= '0';
			output_hash <= (others => '0'); 	   	 
	      elsif doloop = '1' and finish = '1' then
			index := index + 1;
	      elsif stop = '1' then
	        load  <= '0';	
	        chunk <= (others => '0');
	      elsif counter = 0 then
	        rst  <= '0';
		  elsif text_len > 0 then
			load <= '1';
			if (index+1) * CW < text_len then
			  chunk <= text(index * CW to (index+1) * CW - 1);
			  len <= "1000";
			else
			  chunk <= text(index * CW to text_len - 1);
			  len <= std_logic_vector(to_unsigned(integer(integer(text_len - integer(index) * integer(CW))), 4));
			  counter := 1000000;
			  index := 0;
			  stop <= '1';
			end if;
			index := index + 1;
	      elsif num_a = 0 and counter = 1 then  -- caso empty chunk e len sono a 0
	        load <= '1';
	        chunk <= (others => '0');
			len <= (others => '0');
	      elsif counter <= num_a then
	        load <= '1';																				 
			chunk <= x"61"; -- a   
			len <= "1000";
	      else
	        load  <= '0';	
	        chunk <= (others => '0');
	      end if;
	  end if;
	  counter := counter + 1;
	end if;
  end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_sha2 of sha2_tb is
  for TB_ARCHITECTURE
    for UUT : sha2
      use entity work.sha2(hash);
    end for;
  end for;
end TESTBENCH_FOR_sha2; 