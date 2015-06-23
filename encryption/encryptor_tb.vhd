LIBRARY ieee  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_arith.all  ; 
USE ieee.std_logic_unsigned.all  ; 
ENTITY encryptor_tb  IS 
END ; 
 
ARCHITECTURE encryptor_tb_arch OF encryptor_tb IS
  SIGNAL ciphertext   :  std_logic_vector (15 downto 0)  ; 
  SIGNAL clock   :  std_logic :='0' ; 
  SIGNAL round_keyse   :  std_logic_vector (15 downto 0)  ; 
  SIGNAL ready_e   :  std_logic  ; 
  SIGNAL plaintext_e   :  std_logic_vector (15 downto 0)  ; 
  SIGNAL start_e   :  std_logic  ; 
  SIGNAL reset   :  std_logic  ; 
  COMPONENT encryptor  
    PORT ( 
      ciphertext  : out std_logic_vector (15 downto 0) ; 
      clock  : in std_logic ; 
      round_keyse  : in std_logic_vector (15 downto 0) ; 
      ready_e  : out std_logic ; 
      plaintext_e  : in std_logic_vector (15 downto 0) ; 
      start_e  : in std_logic ; 
      reset  : in std_logic ); 
  END COMPONENT ; 
BEGIN
  DUT  : encryptor  
    PORT MAP ( 
      ciphertext   => ciphertext  ,
      clock   => clock  ,
      round_keyse   => round_keyse  ,
      ready_e   => ready_e  ,
      plaintext_e   => plaintext_e  ,
      start_e   => start_e  ,
      reset   => reset   ) ; 

process
begin
reset<='1';
wait for 10 ns;
start_e<='1';
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
  plaintext_e<="0000000000000001";
  wait for 20 ns;
  plaintext_e<="0000000000000010";
  wait for 20 ns;
  plaintext_e<="0000000000000011";
  wait for 20 ns; 
  plaintext_e<="0000000000000100";
  wait for 3000 ns;
end process;

process
begin
    wait for 10 ns;  
    round_keyse<="0000000000000000";
    wait for 3000 ns;
end process;  

END ; 

