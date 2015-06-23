LIBRARY ieee  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_arith.all  ; 
USE ieee.std_logic_unsigned.all  ; 
ENTITY decryptor_tb  IS 
END ; 
 
ARCHITECTURE decryptor_tb_arch OF decryptor_tb IS
  SIGNAL clock   :  std_logic :='0' ; 
  SIGNAL ciphertext   :  std_logic_vector (15 downto 0)  ; 
  SIGNAL ready_d   :  std_logic  ; 
  SIGNAL plaintext_d   :  std_logic_vector (15 downto 0)  ; 
  SIGNAL start_d   :  std_logic  ; 
  SIGNAL round_keys_d   :  std_logic_vector (15 downto 0)  ; 
  SIGNAL reset   :  std_logic  ; 
  COMPONENT decryptor  
    PORT ( 
      clock  : in std_logic ; 
      ciphertext  : in std_logic_vector (15 downto 0) ; 
      ready_d  : out std_logic ; 
      plaintext_d  : out std_logic_vector (15 downto 0) ; 
      start_d  : in std_logic ; 
      round_keys_d  : in std_logic_vector (15 downto 0) ; 
      reset  : in std_logic ); 
  END COMPONENT ; 
BEGIN
  DUT  : decryptor  
    PORT MAP ( 
      clock   => clock  ,
      ciphertext   => ciphertext  ,
      ready_d   => ready_d  ,
      plaintext_d   => plaintext_d  ,
      start_d   => start_d  ,
      round_keys_d   => round_keys_d  ,
      reset   => reset   ) ; 

process
begin
reset<='1';
wait for 10 ns;
start_d<='1';
reset<='0'; 

wait for 3000 ns;
end process;
      
 
process(clock) 
begin
clock<= not clock after 10 ns;
end process;

process
begin
  wait for 30 ns;
  ciphertext <="1111101011010000";
  wait for 20 ns;
  ciphertext <="1100011100001101";
  wait for 20 ns;
  ciphertext <="0110000001100010";
  wait for 20 ns; 
  ciphertext <="1001000101010111";
  wait for 3000 ns;
end process;

process
begin
    wait for 10 ns;  
    round_keys_d <="0000000000000000";
    wait for 3000 ns;
end process; 
END ; 

