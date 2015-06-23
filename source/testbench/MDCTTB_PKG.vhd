--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : MDCTTB_PKG
-- Design      : MDCT Core
-- Author      : Michal Krepa
--
--------------------------------------------------------------------------------
--
-- File        : MDCTTB_PKG.VHD
-- Created     : Sat Mar 5 2006
--
--------------------------------------------------------------------------------
--
--  Description : Package for testbench simulation
--
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.MATH_REAL.all;

library STD;
  use STD.TEXTIO.all;
  
library WORK;
  use WORK.MDCT_PKG.all;

package MDCTTB_PKG is
    
    ----------------------------------------------
    -- constant section 1
    ----------------------------------------------
    constant MAX_IMAGE_SIZE_X : INTEGER := 1024;
    constant MAX_IMAGE_SIZE_Y : INTEGER := 1024;
    ----------------------------------------------
    -- type section
    ----------------------------------------------
    type MATRIX_TYPE   is array (0 to N-1,0 TO N-1) of REAL;
    type I_MATRIX_TYPE is array (0 to N-1,0 TO N-1) of INTEGER;
    type COEM_TYPE     is array (0 to N/2-1, 0 to N/2-1) 
          of SIGNED(ROMDATA_W-1 downto 0);
    type VECTOR4       is array (0 to N/2-1) of REAL;
    type N_LINES_TYPE  is array (0 to N-1)
          of STD_LOGIC_VECTOR(0 to MAX_IMAGE_SIZE_X*IP_W-1);
    type IMAGE_TYPE    is array (0 to MAX_IMAGE_SIZE_Y-1,
                                 0 to MAX_IMAGE_SIZE_X-1) of INTEGER;
                                 
    ----------------------------------------------
    -- function section
    ----------------------------------------------
    procedure CMP_MATRIX(ref_matrix   : in I_MATRIX_TYPE; 
                       dcto_matrix    : in I_MATRIX_TYPE;
                       max_error      : in INTEGER;
                       error_matrix   : out I_MATRIX_TYPE;
                       error_cnt      : inout INTEGER);
    function STR(int: INTEGER; base: INTEGER) return STRING;
    function COMPUTE_REF_DCT1D(input_matrix : I_MATRIX_TYPE; shift : BOOLEAN
                        ) return I_MATRIX_TYPE;
    function COMPUTE_REF_IDCT(X : I_MATRIX_TYPE) return I_MATRIX_TYPE;
    function COMPUTE_PSNR(ref_input : I_MATRIX_TYPE; 
                        reconstr_input : I_MATRIX_TYPE) return REAL;
    function COMPUTE_PSNR(ref_input : IMAGE_TYPE; 
                       reconstr_input : IMAGE_TYPE;
                       ysize : INTEGER;
                       xsize : INTEGER
                       ) return REAL;                   
    ----------------------------------------------
    -- constant section 2
    ----------------------------------------------  
    -- set below to true to enable quantization in testbench
    constant CLK_FREQ_C        : INTEGER := 50;
    constant HOLD_TIME         : TIME := 1 ns;
    constant ENABLE_QUANTIZATION_C : BOOLEAN := FALSE; 
    constant HEX_BASE          : INTEGER := 16;
    constant DEC_BASE          : INTEGER := 10;
    constant RUN_FULL_IMAGE    : BOOLEAN := FALSE;
    constant FILEIN_NAME_C     : STRING := "SOURCE\TESTBENCH\lena512.txt";
    constant FILEERROR_NAME_C  : STRING := "SOURCE\TESTBENCH\imagee.txt";
    constant FILEIMAGEO_NAME_C : STRING := "SOURCE\TESTBENCH\imageo.txt";
    constant MAX_ERROR_1D      : INTEGER := 1;
    constant MAX_ERROR_2D      : INTEGER := 4;
    constant MAX_PIX_VAL       : INTEGER := 2**IP_W-1;
    constant null_data_r       : MATRIX_TYPE := 
                          (
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0),
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0),
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0),
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0),
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0),
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0),
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0),
                          (000.0,000.0,000.0,000.0,000.0,000.0,000.0,000.0)
                          ); 
    
    constant input_data0   : I_MATRIX_TYPE := 
                          (
                          (139,144,149,153,155,155,155,155),
                          (144,151,153,156,159,156,156,156),
                          (150,155,160,163,158,156,156,156),
                          (159,161,162,160,160,159,159,159),
                          (159,160,161,162,162,155,155,155),
                          (161,161,161,161,160,157,157,157),
                          (162,162,161,163,162,157,157,157),
                          (162,162,161,161,163,158,158,158)
                          );
    
    constant input_data1   : I_MATRIX_TYPE := 
                          (
                          (255,255,255,000,000,255,254,255),
                          (255,255,255,000,000,255,254,000),
                          (255,255,255,000,000,255,254,255),
                          (255,255,255,000,000,255,254,000),
                          (254,000,255,255,000,255,254,255),
                          (254,000,255,255,000,255,254,000),
                          (254,000,255,255,000,255,254,255),
                          (254,000,255,255,000,255,254,000)
                          );
                          
    constant input_data2   : I_MATRIX_TYPE := 
                          (
                          (000,000,000,000,000,000,000,000),
                          (000,000,000,000,000,000,000,000),
                          (000,000,000,000,000,000,000,000),
                          (000,000,000,000,000,000,000,000),
                          (000,000,000,000,000,000,000,000),
                          (000,000,000,000,000,000,000,000),
                          (000,000,000,000,000,000,000,000),
                          (000,000,000,000,000,000,000,000)
                          );
    constant input_data3   : I_MATRIX_TYPE := 
                          (
                          (55,89,0,2,35,34,100,255),
                          (144,151,153,151,159,156,156,156),
                          (150,155,165,163,158,126,156,156),
                          (254,000,255,255,000,245,254,255),
                          (159,199,161,162,162,133,155,165),
                          (231,000,255,235,000,255,254,253),
                          (162,162,161,163,162,157,157,157),
                          (11,12,167,165,166,167,101,108)
                          ); 
                          
   constant input_data4   : I_MATRIX_TYPE := 
                          (
                          (135,14,145,15,155,15,155,15),
                          (140,15,151,15,152,15,153,15),
                          (154,15,165,16,156,15,157,15),
                          (158,16,168,16,169,15,150,15),
                          (15,161,16,162,16,153,15,154),
                          (165,16,166,16,167,15,158,15),
                          (16,169,16,160,16,152,15,153),
                          (164,16,165,16,165,15,156,15)
                          );                       
    
    -- from JPEG standard (but not in standard itself!)                      
    constant Q_JPEG_STD : I_MATRIX_TYPE := 
                          (
                          (16,11,10,16,24,40,51,61),
                          (12,12,14,19,26,58,60,55),
                          (14,13,16,24,40,57,69,56),
                          (14,17,22,29,51,87,80,62),
                          (18,22,37,56,68,109,103,77),
                          (24,35,55,64,81,104,113,92),
                          (49,64,78,87,103,121,120,101),
                          (72,92,95,98,112,100,103,99)
                          ); 
    
    -- CANON EOS10D super fine quality                      
    constant Q_CANON10D : I_MATRIX_TYPE := 
                          (                                           
                          (1,  1,  1,  1,  1,  1,  2,  2),
                          (1,  1, 	1, 	1, 	1, 	2, 	4, 	4),
                          (1,  1, 	1, 	1, 	1, 	3, 	3, 	5),
                          (1,  1, 	1, 	2, 	3, 	3, 	5, 	5),
                          (1,  1, 	3, 	3, 	4, 	4, 	5, 	5),
                          (1,  3, 	3, 	3, 	4, 	5, 	6, 	6),
                          (2,  3, 	3, 	5, 	3, 	6, 	5, 	5),
                          (3,  3, 	4, 	3, 	6, 	4, 	5, 	5)         
                          );
                          
    -- quantization matrix used in testbench                      
    constant Q_MATRIX_USED : I_MATRIX_TYPE := Q_CANON10D;
                          
    constant Ce : COEM_TYPE :=
                            (
                            (AP,AP,AP,AP),
                            (BP,CP,CM,BM),
                            (AP,AM,AM,AP),
                            (CP,BM,BP,CM)
                            );
                            
    constant Co : COEM_TYPE :=
                            (
                            (DP,EP,FP,GP),
                            (EP,GM,DM,FM),
                            (FP,DM,GP,EP),
                            (GP,FM,EP,DM)
                            );
end MDCTTB_PKG;

--------------------------------------------------
-- PACKAGE BODY
--------------------------------------------------                        
package body MDCTTB_PKG is  
  --------------------------------------------------------------------------
  -- converts an INTEGER into a CHARACTER
  -- for 0 to 9 the obvious mapping is used, higher
  -- values are mapped to the CHARACTERs A-Z
  -- (this is usefull for systems with base > 10)
  -- (adapted from Steve Vogwell's posting in comp.lang.vhdl) 
  --------------------------------------------------------------------------
  function CHR(int: INTEGER) return CHARACTER is
   variable c: CHARACTER;
  begin
    case int is
      when  0 => c := '0';
      when  1 => c := '1';
      when  2 => c := '2';
      when  3 => c := '3';
      when  4 => c := '4';
      when  5 => c := '5';
      when  6 => c := '6';
      when  7 => c := '7';
      when  8 => c := '8';
      when  9 => c := '9';
      when 10 => c := 'A';
      when 11 => c := 'B';
      when 12 => c := 'C';
      when 13 => c := 'D';
      when 14 => c := 'E';
      when 15 => c := 'F';
      when 16 => c := 'G';
      when 17 => c := 'H';
      when 18 => c := 'I';
      when 19 => c := 'J';
      when 20 => c := 'K';
      when 21 => c := 'L';
      when 22 => c := 'M';
      when 23 => c := 'N';
      when 24 => c := 'O';
      when 25 => c := 'P';
      when 26 => c := 'Q';
      when 27 => c := 'R';
      when 28 => c := 'S';
      when 29 => c := 'T';
      when 30 => c := 'U';
      when 31 => c := 'V';
      when 32 => c := 'W';
      when 33 => c := 'X';
      when 34 => c := 'Y';
      when 35 => c := 'Z';
      when others => c := '?';
    end case;
    return c;
  end CHR;


                          
  --------------------------------------------------------------------------
  -- convert INTEGER to STRING using specified base 
  --------------------------------------------------------------------------
  function STR(int: INTEGER; base: INTEGER) return STRING is
   variable temp:      STRING(1 to 10);
   variable num:       INTEGER;
   variable abs_int:   INTEGER;
   variable len:       INTEGER := 1;
   variable power:     INTEGER := 1;
  begin
   -- bug fix for negative numbers
   abs_int := abs(int);
   num     := abs_int;
   while num >= base loop                     
     len := len + 1;                          
     num := num / base;                       
   end loop ;                                 
   for i in len downto 1 loop                 
     temp(i) := chr(abs_int/power mod base);  
     power := power * base;                   
   end loop ;                                 
   -- return result and add sign if required
   if int < 0 then
      return '-'& temp(1 to len);
    else
      return temp(1 to len);
   end if;
  end STR; 
  
  ------------------------------------------------
  -- computes DCT1D
  ------------------------------------------------
  function COMPUTE_REF_DCT1D(input_matrix : I_MATRIX_TYPE; shift : BOOLEAN) 
  return I_MATRIX_TYPE is
   variable fXm : VECTOR4 := (0.0,0.0,0.0,0.0);
   variable fXs : VECTOR4 := (0.0,0.0,0.0,0.0);
   variable fYe : VECTOR4 := (0.0,0.0,0.0,0.0);
   variable fYo : VECTOR4 := (0.0,0.0,0.0,0.0);
   variable ref_dct_matrix : I_MATRIX_TYPE;
   variable norma_input : MATRIX_TYPE;
  begin
     -- compute reference coefficients
     for x in 0 to N-1 loop
     
       for s in 0 to 7 loop
         if shift = TRUE then
           norma_input(x,s) := (REAL(input_matrix(x,s))- REAL(LEVEL_SHIFT))/2.0;
         else
           norma_input(x,s) := REAL(input_matrix(x,s))/2.0;
         end if;
       end loop;
       fXs(0) := norma_input(x,0)+norma_input(x,7);
       fXs(1) := norma_input(x,1)+norma_input(x,6);
       fXs(2) := norma_input(x,2)+norma_input(x,5);
       fXs(3) := norma_input(x,3)+norma_input(x,4);
       
       fXm(0) := norma_input(x,0)-norma_input(x,7);
       fXm(1) := norma_input(x,1)-norma_input(x,6);
       fXm(2) := norma_input(x,2)-norma_input(x,5);
       fXm(3) := norma_input(x,3)-norma_input(x,4);
       
       for k in 0 to N/2-1 loop
         fYe(k) := REAL(TO_INTEGER(Ce(k,0)))*fXs(0) + 
                   REAL(TO_INTEGER(Ce(k,1)))*fXs(1) + 
                   REAL(TO_INTEGER(Ce(k,2)))*fXs(2) + 
                   REAL(TO_INTEGER(Ce(k,3)))*fXs(3);
         fYo(k) := REAL(TO_INTEGER(Co(k,0)))*fXm(0) + 
                   REAL(TO_INTEGER(Co(k,1)))*fXm(1) + 
                   REAL(TO_INTEGER(Co(k,2)))*fXm(2) + 
                   REAL(TO_INTEGER(Co(k,3)))*fXm(3);
       end loop;       
       
       -- transpose matrix by writing in row order
       ref_dct_matrix(0,x) := INTEGER(fYe(0)/REAL((2**(COE_W-1))));
       ref_dct_matrix(1,x) := INTEGER(fYo(0)/REAL((2**(COE_W-1))));
       ref_dct_matrix(2,x) := INTEGER(fYe(1)/REAL((2**(COE_W-1))));
       ref_dct_matrix(3,x) := INTEGER(fYo(1)/REAL((2**(COE_W-1))));
       ref_dct_matrix(4,x) := INTEGER(fYe(2)/REAL((2**(COE_W-1))));
       ref_dct_matrix(5,x) := INTEGER(fYo(2)/REAL((2**(COE_W-1))));
       ref_dct_matrix(6,x) := INTEGER(fYe(3)/REAL((2**(COE_W-1))));
       ref_dct_matrix(7,x) := INTEGER(fYo(3)/REAL((2**(COE_W-1))));
       
     end loop;  
     
     return ref_dct_matrix;
   end COMPUTE_REF_DCT1D; 
   
   -----------------------------------------------
   -- compares NxN matrices, logs failure if difference
   -- greater than maximum error specified
   -----------------------------------------------
   procedure CMP_MATRIX(ref_matrix    : in I_MATRIX_TYPE; 
                       dcto_matrix    : in I_MATRIX_TYPE;
                       max_error      : in INTEGER;
                       error_matrix   : out I_MATRIX_TYPE;
                       error_cnt      : inout INTEGER
                       ) is
     variable error_matrix_v : I_MATRIX_TYPE;
   begin 
     for a in 0 to N - 1 loop
       for b in 0 to N - 1 loop
         error_matrix_v(a,b) := ref_matrix(a,b) - dcto_matrix(a,b);
         if abs(error_matrix_v(a,b)) > max_error then
           error_cnt := error_cnt + 1;
           assert false
             report "E01: DCT max error violated!"
             severity Error;
         end if;
       end loop;
     end loop;
     error_matrix := error_matrix_v;
  end CMP_MATRIX;
  
  ------------------------------------------------
  -- computes IDCT on NxN matrix
  ------------------------------------------------
  function COMPUTE_REF_IDCT(X : I_MATRIX_TYPE) 
  return I_MATRIX_TYPE is
    variable i  : INTEGER := 0;
    variable j  : INTEGER := 0;
    variable u  : INTEGER := 0;
    variable v  : INTEGER := 0;
    variable Cu : REAL;
    variable Cv : REAL;
    variable xi : MATRIX_TYPE := null_data_r;
    variable xr : I_MATRIX_TYPE;
  begin
    -- idct
    for i in 0 to N-1 loop
      for j in 0 to N-1 loop  
        for u in 0 to N-1 loop
          if u = 0 then
            Cu := 1.0/sqrt(2.0);
          else
            Cu := 1.0;
          end if;         
          for v in 0 to N-1 loop
            if v = 0 then
              Cv := 1.0/sqrt(2.0);
            else
              Cv := 1.0;
            end if;
            xi(i,j) := xi(i,j) + 
                     2.0/REAL(N)*Cu*Cv*REAL(X(u,v))*
                     cos( ( (2.0*REAL(i)+1.0)*REAL(u)*MATH_PI ) / (2.0*REAL(N)) )*
                     cos( ( (2.0*REAL(j)+1.0)*REAL(v)*MATH_PI ) / (2.0*REAL(N)) );
            xr(i,j) := INTEGER(ROUND(xi(i,j)))+LEVEL_SHIFT;
          end loop;     
        end loop;
      end loop;
    end loop;
    return xr;
  end COMPUTE_REF_IDCT;
  
  ------------------------------------------------
  -- computes peak signal to noise ratio
  -- for reconstruced and input image data
  ------------------------------------------------
  function COMPUTE_PSNR(ref_input : I_MATRIX_TYPE; 
                       reconstr_input : I_MATRIX_TYPE) return REAL is
    variable psnr_tmp : REAL := 0.0;
  begin
    for i in 0 to N-1 loop
      for j in 0 to N-1 loop
        psnr_tmp := psnr_tmp + (REAL(ref_input(i,j))-REAL(reconstr_input(i,j)))**2;
      end loop;
    end loop;
    psnr_tmp := psnr_tmp / (REAL(N)*REAL(N));
    psnr_tmp := 10.0*LOG10( (REAL(MAX_PIX_VAL)**2) / psnr_tmp );
    return psnr_tmp;
  
  end COMPUTE_PSNR;
  
  ------------------------------------------------
  -- computes peak signal to noise ratio
  -- for reconstruced and input image data
  ------------------------------------------------
  function COMPUTE_PSNR(ref_input : IMAGE_TYPE; 
                       reconstr_input : IMAGE_TYPE;
                       ysize : INTEGER;
                       xsize : INTEGER
                       ) return REAL is
    variable psnr_tmp : REAL := 0.0;
    variable lineb    : LINE;
  begin
    for i in 0 to ysize-1 loop
      for j in 0 to xsize-1 loop
        psnr_tmp := psnr_tmp + 
                    (REAL(ref_input(i,j))-REAL(reconstr_input(i,j)))**2;
      end loop;
    end loop;
    psnr_tmp := psnr_tmp / (REAL(ysize)*REAL(xsize));
    --WRITE(lineb,STRING'("MSE Mean Squared Error is "));
    --WRITE(lineb,psnr_tmp); 
    --assert false
    --  report lineb.all
    --  severity Note;
    psnr_tmp := 10.0*LOG10( (REAL(MAX_PIX_VAL)**2) / psnr_tmp );
    return psnr_tmp;
  
  end COMPUTE_PSNR;
                      
   
end MDCTTB_PKG;