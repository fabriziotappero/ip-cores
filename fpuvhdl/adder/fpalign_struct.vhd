-- VHDL Entity HAVOC.FPalign.symbol
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FPalign IS
   PORT( 
      A_in  : IN     std_logic_vector (28 DOWNTO 0);
      B_in  : IN     std_logic_vector (28 DOWNTO 0);
      cin   : IN     std_logic;
      diff  : IN     std_logic_vector (8 DOWNTO 0);
      A_out : OUT    std_logic_vector (28 DOWNTO 0);
      B_out : OUT    std_logic_vector (28 DOWNTO 0)
   );

-- Declarations

END FPalign ;

--
-- VHDL Architecture HAVOC.FPalign.struct
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- Copyright 2003-2004. V1.0
--


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


ARCHITECTURE struct OF FPalign IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL B_shift  : std_logic_vector(28 DOWNTO 0);
   SIGNAL diff_int : std_logic_vector(8 DOWNTO 0);
   SIGNAL shift_B  : std_logic_vector(5 DOWNTO 0);



BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1
   PROCESS(diff_int, B_shift)
   BEGIN
      IF (diff_int(8)='1') THEN
         IF (((NOT diff_int) + 1) > 28) THEN
             B_out <= (OTHERS => '0');
          ELSE
              B_out <= B_shift;
          END IF; 
      ELSE      
          IF (diff_int > 28) THEN
             B_out <= (OTHERS => '0');
          ELSE
              B_out <= B_shift;
          END IF;
       END IF;
   END PROCESS;

   -- HDL Embedded Text Block 2 eb2
   -- eb2 2   
   PROCESS(diff_int)
   BEGIN
      IF (diff_int(8)='1') THEN
            shift_B <= (NOT diff_int(5 DOWNTO 0)) + 1;
      ELSE
            shift_B <= diff_int(5 DOWNTO 0) ;
      END IF;
   END PROCESS;

   -- HDL Embedded Text Block 3 eb3
   -- eb3 3
   PROCESS(cin,diff)
   BEGIN
      IF ((cin='1') AND (diff(8)='1')) THEN
         diff_int <= diff + 2;
      ELSE
         diff_int <= diff;
      END IF;
   END PROCESS;


   -- ModuleWare code(v1.1) for instance 'I0' of 'assignment'
   A_out <= A_in;

   -- ModuleWare code(v1.1) for instance 'I1' of 'rshift'
   I1combo : PROCESS (B_in, shift_B)
   VARIABLE stemp : std_logic_vector (5 DOWNTO 0);
   VARIABLE dtemp : std_logic_vector (28 DOWNTO 0);
   VARIABLE temp : std_logic_vector (28 DOWNTO 0);
   BEGIN
      temp := (OTHERS=> 'X');
      stemp := shift_B;
      temp := B_in;
      FOR i IN 5 DOWNTO 0 LOOP
         IF (i < 5) THEN
            IF (stemp(i) = '1' OR stemp(i) = 'H') THEN
               dtemp := (OTHERS => '0');
               dtemp(28 - 2**i DOWNTO 0) := temp(28 DOWNTO 2**i);
            ELSIF (stemp(i) = '0' OR stemp(i) = 'L') THEN
               dtemp := temp;
            ELSE
               dtemp := (OTHERS => 'X');
            END IF;
         ELSE
            IF (stemp(i) = '1' OR stemp(i) = 'H') THEN
               dtemp := (OTHERS => '0');
            ELSIF (stemp(i) = '0' OR stemp(i) = 'L') THEN
               dtemp := temp;
            ELSE
               dtemp := (OTHERS => 'X');
            END IF;
         END IF;
         temp := dtemp;
      END LOOP;
      B_shift <= dtemp;
   END PROCESS I1combo;

   -- Instance port mappings.

END struct;
