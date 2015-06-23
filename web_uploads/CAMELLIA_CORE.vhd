-- Camellia Algorithm Implementation
-- file: camellia_core.vhd (top level)
-- Ahmad Rifqi H (13200013)
-- 2004/April/28
-- Created	for under graduate  final project     	

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE work.CAMELLIA_package.all;
 
ENTITY CAMELLIA_core IS
PORT(  INPUT    	: IN   type_128bit;
       INV		: in	 STD_LOGIC;
       clock	 : IN	 std_logic;
       reset	 : IN	 std_logic;
       key_ready	 : IN	 std_logic;
       input_ready : IN	 std_logic;
       proc	 : IN	 std_logic;

       DATA_OUTPUT : OUT  type_128bit;
       out_ready	 : OUT	 std_logic
       );

-- Declarations

END CAMELLIA_core ;
ARCHITECTURE struct OF CAMELLIA_core IS
SIGNAL  OUTPUT_BUFF,OUTPUT_BUFF1: type_128bit;
SIGNAL  DATA_INPUT_buff,KEY_INPUT_buff: type_128bit;
SIGNAL  out_readybuff,out_readybuff1	: std_logic ;
  COMPONENT encrypt_decrypt
     PORT(  data_in	: IN   type_128bit;
            key_in	: IN   type_128bit;
            data_out 	: OUT  type_128bit;
            clock		: IN	 std_logic;
            reset		: IN	 std_logic;
            key_ready	: IN	 std_logic;
            input_ready	: IN	 std_logic;
            out_ready	: OUT	 std_logic;
            INV		: IN	 std_logic		
          );
    END COMPONENT;
	
begin

C1:  encrypt_decrypt
     port map(
       data_in 	=> DATA_INPUT_buff,
       key_in	=> KEY_INPUT_buff,
       data_out 	=> OUTPUT_BUFF,
       clock	=> clock,
       reset	=> reset,
       key_ready	=> proc,
       input_ready => proc,
       out_ready	=> out_readybuff,
       INV		=> INV
     	);
  
  out_ready 	<= out_readybuff1;
  DATA_OUTPUT  	<= OUTPUT_BUFF1;

PROCESS (reset,CLOCK)
     BEGIN
     IF (cLock'event and cLock='1' ) THEN     
          if (reset='1') then
            OUTPUT_BUFF1 <= sigma(6)&sigma(6);
            out_readybuff1 <='0';
            KEY_INPUT_buff <= sigma(6)&sigma(6);
            DATA_INPUT_buff <= sigma(6)&sigma(6);
	
          else
		     
            IF key_ready='1' THEN	 -- Read key input
               KEY_INPUT_buff <= INPUT;
               
            ELSE  
                 KEY_INPUT_buff <= KEY_INPUT_buff;	
            END IF ;

            IF input_ready='1' THEN	 --Read data input
               DATA_INPUT_buff <= INPUT;
            ELSE  DATA_INPUT_buff <= DATA_INPUT_buff;
            END IF ;

            IF out_readybuff ='1' THEN	  -- output
              OUTPUT_BUFF1 <= OUTPUT_BUFF;
            ELSE  OUTPUT_BUFF1 <= OUTPUT_BUFF1;
            END IF ;
	
            out_readybuff1 <= out_readybuff;			
           	end if;
     END IF ;

			
END PROCESS;
END struct;







