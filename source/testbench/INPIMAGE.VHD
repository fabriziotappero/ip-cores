--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : INPIMAGE
-- Design      : MDCT Core
-- Author      : Michal Krepa
--
--------------------------------------------------------------------------------
-- File        : INPIMAGE.VHD
-- Created     : Sat Mar 12 2006
--
--------------------------------------------------------------------------------
--
--  Description : 1D Discrete Cosine Transform TB stimulator and results compare
--
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all; 
  use IEEE.STD_LOGIC_TEXTIO.all;
  
library STD;
  use STD.TEXTIO.all;

library WORK;
  use WORK.MDCT_PKG.all;
  use WORK.MDCTTB_PKG.all;
  use WORK.RNG.all;
  
entity INPIMAGE is
  port (   
        clk               : in STD_LOGIC;
        odv1              : in STD_LOGIC;
        dcto1             : in STD_LOGIC_VECTOR(OP_W-1 downto 0);
        odv               : in STD_LOGIC;
        dcto              : in STD_LOGIC_VECTOR(COE_W-1 downto 0);
        
        rst               : out STD_LOGIC;
        imageo            : out STD_LOGIC_VECTOR(IP_W-1 downto 0);
        dv                : out STD_LOGIC;
        testend           : out BOOLEAN
       );
end INPIMAGE;

--**************************************************************************--

architecture SIM of INPIMAGE is	 

  constant PERIOD             : TIME := 1 us /(CLK_FREQ_C);
  
  signal rst_s                : STD_LOGIC;
  signal test_inp             : INTEGER;
  signal test_stim            : INTEGER;
  signal test_out             : INTEGER;
  signal xcon_s               : INTEGER;
  signal ycon_s               : INTEGER;
  signal error_dct_matrix_s   : I_MATRIX_TYPE;
  signal error_dcto1_matrix_s : I_MATRIX_TYPE; 
  signal imageo_s             : STD_LOGIC_VECTOR(IP_W-1 downto 0);
  signal dv_s                 : STD_LOGIC; 	 

begin
    
  rst  <= rst_s after HOLD_TIME;
  
  imageo <= imageo_s after HOLD_TIME;
  dv     <= dv_s after HOLD_TIME;
    
 --------------------------
 -- input image stimuli  
 --------------------------
 INPIMAGE_PROC: process
   variable i : INTEGER   := 0;
   variable j : INTEGER   := 0;
   variable INSERT_DELAYS : BOOLEAN := FALSE;
   variable unf:	Uniform  := InitUniform(7, 0.0, 2.0);
  	variable rnd:	real     := 0.0;
  	variable xi            : INTEGER := 0;
   
  -------------------------------------
  -- wait for defined number of clock cycles
  -------------------------------------
  procedure waitposedge(clocks : in INTEGER) is
  begin
    for i in 1 to clocks loop
      wait until clk='1' and clk'event; 
    end loop;
  end waitposedge;
  
  -------------------------------------
  -- wait on clock rising edge
  -------------------------------------
  procedure waitposedge is
  begin
    wait until clk='1' and clk'event;
  end waitposedge;

  --------------------------------------
  -- read text image data
  --------------------------------------
  procedure read_image is
    file infile          : TEXT open read_mode is FILEIN_NAME_C;
    variable inline      : LINE;
    variable tmp_int     : INTEGER := 0;
    variable y_size      : INTEGER := 0;
    variable x_size      : INTEGER := 0;
    variable x_blocks8   : INTEGER := 0;
    variable y_blocks8   : INTEGER := 0;
    variable matrix      : I_MATRIX_TYPE;
    variable x_blk_cnt   : INTEGER := 0;
    variable y_blk_cnt   : INTEGER := 0;
    variable n_lines_arr : N_LINES_TYPE;
    variable line_n      : INTEGER := 0;
    variable pix_n       : INTEGER := 0;
    variable x_n         : INTEGER := 0;
    variable y_n         : INTEGER := 0;
  begin
    READLINE(infile,inline);
    READ(inline,y_size);
    READLINE(infile,inline);
    READ(inline,x_size);
    
    y_blocks8 := y_size / N;
    x_blocks8 := x_size / N;
    
    assert MAX_IMAGE_SIZE_X > x_size
      report "E02: Input image x size exceeds maximum value!"
      severity Failure;
      
    if y_size rem N > 0 then
      assert false
        report "E03: Image height dimension is not multiply of N!"
        severity Failure;
    end if;
    if x_size rem N > 0 then
      assert false
        report "E03: Image width dimension is not multiply of N!"
        severity Failure;
    end if;  
    
    for y_blk_cnt in 0 to y_blocks8-1 loop
      
      -- read N input lines and store them to buffer
      for y_n in 0 to N-1 loop
        READLINE(infile,inline);
        HREAD(inline,n_lines_arr(y_n)(0 to x_size*IP_W-1));
      end loop;
      y_n := 0;
      
      for x_blk_cnt in 0 to x_blocks8-1 loop
        for y_n in 0 to N-1 loop
          for x_n in 0 to N-1 loop
            matrix(y_n,x_n) := TO_INTEGER(UNSIGNED(
                n_lines_arr(y_n)
                    ((x_blk_cnt*N+x_n)*IP_W to (x_blk_cnt*N+(x_n+1))*IP_W-1)));
          end loop;
        end loop;
        
        for i in 0 to N-1 loop
          for j in 0 to N-1 loop
            dv_s      <= '1';
            imageo_s  <= STD_LOGIC_VECTOR(
                         TO_UNSIGNED(INTEGER(matrix(i,j)),IP_W));
            xcon_s <= x_blk_cnt*N+j;
            ycon_s <= y_blk_cnt*N+i;
            waitposedge;
            if INSERT_DELAYS = TRUE then
              dv_s    <= '0';
              waitposedge(40);
            end if;
          end loop;
        end loop;
             
      end loop;
      
    end loop;

  end read_image;
  
   ---------------------------
   -- process begin
   ---------------------------
   begin
     test_stim <= 0;
     dv_s      <= '0';
     imageo_s  <= (others => '0'); 
     rst_s <= '1';
     waitposedge(20);
     rst_s <= '0'; 
     
     -------------------------
     -- test 1
     -------------------------
     test_stim <= 1;
     for i in 0 to 7 loop
       for j in 0 to 7 loop
         dv_s      <= '1';
         imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data0(i,j)),IP_W));
         waitposedge;
       end loop;
     
     end loop;
     
     dv_s <= '0';
     waitposedge;
     -------------------------
     
     -------------------------
     -- test 2
     -------------------------
     test_stim <= 2;
     for i in 0 to 7 loop
       for j in 0 to 7 loop
         dv_s      <= '1';
         imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data1(i,j)),IP_W));
         waitposedge;
       end loop;
     
     end loop;
     
     dv_s <= '0';
     waitposedge;
     ------------------------
     
     -------------------------
     -- test 3
     -------------------------
     test_stim <= 3;
     for i in 0 to 7 loop
       for j in 0 to 7 loop
         dv_s      <= '1';
         imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data2(i,j)),IP_W));
         waitposedge;
       end loop;
     
     end loop;
     
     dv_s <= '0';
     waitposedge;
     ------------------------
     
     -------------------------
     -- test 4
     -------------------------
     test_stim <= 4;
     for i in 0 to 7 loop
       for j in 0 to 7 loop
         dv_s      <= '1';
         imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data0(i,j)),IP_W));
         waitposedge;
         dv_s      <= '0';
         waitposedge;
       end loop;
     
     end loop;
     
     dv_s <= '0';
     waitposedge;
     ------------------------
     
     -------------------------
     -- test 5
     -------------------------
     test_stim <= 5;
     for i in 0 to 7 loop
       for j in 0 to 7 loop
         dv_s      <= '1';
         imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data1(i,j)),IP_W));
         waitposedge;
         dv_s      <= '0';
         waitposedge(25);
       end loop;
     
     end loop;
     
     dv_s <= '0';
     waitposedge;
     ------------------------
     
     -------------------------
     -- test 6-16
     -------------------------
     
     for x in 0 to 10 loop
       test_stim <= test_stim+1;
       for i in 0 to 7 loop
         for j in 0 to 7 loop
           dv_s      <= '1';
           if x rem 2 = 0 then
             imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data0(i,j)),IP_W));
           else
             imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data3(i,j)),IP_W));
           end if;
           waitposedge;
         end loop;
       end loop;
     end loop;

     dv_s <= '0';
     waitposedge;
     ------------------------
     
     -------------------------
     -- test 17-33
     -------------------------
     
     for x in 0 to 16 loop
       test_stim <= test_stim+1;
       if xi < 4 then
         xi := xi + 1;
       else
         xi := 0;
       end if; 
       for i in 0 to 7 loop
         for j in 0 to 7 loop
           dv_s      <= '1';
 
           case xi is
             when 0 =>
               imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data1(i,j)),IP_W)); 
             when 1 =>
               imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data0(i,j)),IP_W)); 
             when 2 =>
               imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data3(i,j)),IP_W));
             when 3 =>
               imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data4(i,j)),IP_W)); 
             when others =>
               imageo_s  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INTEGER(input_data0(i,j)),IP_W));    
           end case;
           waitposedge;
           dv_s      <= '0';
           GenRnd(unf);
          	rnd := unf.rnd;
          	waitposedge(INTEGER(rnd));
         end loop;
       end loop;
     end loop;

     dv_s <= '0';
     waitposedge;
     ------------------------
     
     -------------------------
     -- test 6
     -------------------------
     if RUN_FULL_IMAGE = TRUE then
       read_image;
     end if;
     
     -------------------------
     -- test 7
     -------------------------
     --INSERT_DELAYS := TRUE;
     --read_image;
     
     dv_s <= '0';
     waitposedge;
     ------------------------ 
     
     wait;
 end process;

 --------------------------
 -- output coeffs comparison (after 1st stage) 
 --------------------------
 OUTIMAGE_PROC: process
   variable i : INTEGER  := 0;
   variable j : INTEGER  := 0;
   variable error_matrix : I_MATRIX_TYPE;
   variable error_cnt    : INTEGER := 0;
   variable raport_str   : STRING(1 to 255);
   variable ref_matrix   : I_MATRIX_TYPE;
   variable dcto_matrix  : I_MATRIX_TYPE;
   variable xi           : INTEGER := 0;
  -------------------------------------
  -- wait for defined number of clock cycles
  -------------------------------------
  procedure waitposedge(clocks : in INTEGER) is
  begin
    for i in 1 to clocks loop
      wait until clk='1' and clk'event; 
    end loop;
  end waitposedge;
  
  -------------------------------------
  -- wait on clock rising edge
  -------------------------------------
  procedure waitposedge is
  begin
    wait until clk='1' and clk'event;
  end waitposedge;

  --------------------------------------
  -- read text image data 1D DCT
  --------------------------------------
  procedure read_image_for1dct(error_cnt_i : inout INTEGER) is
    file infile          : TEXT open read_mode is FILEIN_NAME_C;
    variable inline      : LINE;
    variable tmp_int     : INTEGER := 0;
    variable y_size      : INTEGER := 0;
    variable x_size      : INTEGER := 0;
    variable x_blocks8   : INTEGER := 0;
    variable y_blocks8   : INTEGER := 0;
    variable matrix      : I_MATRIX_TYPE;
    variable x_blk_cnt   : INTEGER := 0;
    variable y_blk_cnt   : INTEGER := 0;
    variable n_lines_arr : N_LINES_TYPE;
    variable line_n      : INTEGER := 0;
    variable pix_n       : INTEGER := 0;
    variable x_n         : INTEGER := 0;
    variable y_n         : INTEGER := 0;
    variable i           : INTEGER := 0;
    variable j           : INTEGER := 0;
    variable dcto_matrix_v : I_MATRIX_TYPE;
    variable ref_matrix_v  : I_MATRIX_TYPE;
    variable error_dcto1_matrix_v : I_MATRIX_TYPE;
  begin
    READLINE(infile,inline);
    READ(inline,y_size);
    READLINE(infile,inline);
    READ(inline,x_size);
    
    y_blocks8 := y_size / N;
    x_blocks8 := x_size / N;
    
    assert MAX_IMAGE_SIZE_X > x_size
      report "E02: Input image x size exceeds maximum value!"
      severity Failure;
    
    if y_size rem N > 0 then
      assert false
        report "E03: Image height dimension is not multiply of N!"
        severity Failure;
    end if;
    if x_size rem N > 0 then
      assert false
        report "E03: Image width dimension is not multiply of N!"
        severity Failure;
    end if;
    
    for y_blk_cnt in 0 to y_blocks8-1 loop
      
      -- read N input lines and store them to buffer
      for y_n in 0 to N-1 loop
        READLINE(infile,inline);
        HREAD(inline,n_lines_arr(y_n)(0 to x_size*IP_W-1));
      end loop;
      y_n := 0;
      
      for x_blk_cnt in 0 to x_blocks8-1 loop
        for y_n in 0 to N-1 loop
          for x_n in 0 to N-1 loop
            matrix(y_n,x_n) := TO_INTEGER(UNSIGNED(
                n_lines_arr(y_n)
                    ((x_blk_cnt*N+x_n)*IP_W to (x_blk_cnt*N+(x_n+1))*IP_W-1)));
          end loop;
        end loop;
        
        for i in 0 to N-1 loop
          j := 0;
          while(true) loop
            waitposedge;
            if odv1 = '1' then
              dcto_matrix_v(j,i) := TO_INTEGER(SIGNED( dcto1 ));
              j := j + 1;
            end if;

            if j = N then
              exit;
            end if;
          end loop;
        end loop;
        
        -- compute reference coefficients
        ref_matrix_v := COMPUTE_REF_DCT1D(matrix,TRUE); 
        CMP_MATRIX(ref_matrix_v,dcto_matrix_v,
                                    MAX_ERROR_1D,error_dcto1_matrix_v,error_cnt_i);             
        error_dcto1_matrix_s <= error_dcto1_matrix_v;
      end loop;
    end loop;
  end read_image_for1dct;

  begin
     test_inp <= 0;
       
     -------------------------
     -- test 1
     -------------------------  
     test_inp <= 1;
     -- compute reference coefficients
     ref_matrix := COMPUTE_REF_DCT1D(input_data0,TRUE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv1 = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto1 ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     CMP_MATRIX(ref_matrix,dcto_matrix,MAX_ERROR_1D,error_matrix,error_cnt);
     -------------------------
     
     -------------------------
     -- test 2
     -------------------------
     test_inp <= 2;  
     -- compute reference coefficients
     ref_matrix := COMPUTE_REF_DCT1D(input_data1,TRUE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv1 = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto1 ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     CMP_MATRIX(ref_matrix,dcto_matrix,MAX_ERROR_1D,error_matrix,error_cnt);
     -------------------------
     
     -------------------------
     -- test 3
     -------------------------
     test_inp <= 3;  
     -- compute reference coefficients
     ref_matrix := COMPUTE_REF_DCT1D(input_data2,TRUE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv1 = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto1 ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     CMP_MATRIX(ref_matrix,dcto_matrix,MAX_ERROR_1D,error_matrix,error_cnt);
     -------------------------
     
     -------------------------
     -- test 4
     -------------------------
     test_inp <= 4;  
     -- compute reference coefficients
     ref_matrix := COMPUTE_REF_DCT1D(input_data0,TRUE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv1 = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto1 ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     CMP_MATRIX(ref_matrix,dcto_matrix,MAX_ERROR_1D,error_matrix,error_cnt);
     -------------------------
     
     -------------------------
     -- test 5
     -------------------------
     test_inp <= 5;  
     -- compute reference coefficients
     ref_matrix := COMPUTE_REF_DCT1D(input_data1,TRUE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv1 = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto1 ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     CMP_MATRIX(ref_matrix,dcto_matrix,MAX_ERROR_1D,error_matrix,error_cnt);
     -------------------------
     
     -------------------------
     -- test 6-16
     -------------------------
     for x in 0 to 10 loop
       test_inp <= test_inp + 1;  
       -- compute reference coefficients
       if x rem 2 = 0 then
         ref_matrix := COMPUTE_REF_DCT1D(input_data0,TRUE); 
       else
         ref_matrix := COMPUTE_REF_DCT1D(input_data3,TRUE);
       end if;
       for i in 0 to N-1 loop
         j := 0;
         while(true) loop
  
           waitposedge;
           if odv1 = '1' then
             dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto1 ));
             j := j + 1;
           end if;
  
           if j = N then
             exit;
           end if;
   
         end loop;
       end loop;
       CMP_MATRIX(ref_matrix,dcto_matrix,MAX_ERROR_1D,error_matrix,error_cnt);
     end loop;
     -------------------------
     
     -------------------------
     -- test 17-33
     -------------------------
     for x in 0 to 16 loop
       test_inp <= test_inp + 1;  
       -- compute reference coefficients
       if xi < 4 then
         xi := xi + 1;
       else
         xi := 0;
       end if;
       case xi is
         when 0 =>
           ref_matrix := COMPUTE_REF_DCT1D(input_data1,TRUE); 
         when 1 =>
           ref_matrix := COMPUTE_REF_DCT1D(input_data0,TRUE); 
         when 2 =>
           ref_matrix := COMPUTE_REF_DCT1D(input_data3,TRUE); 
         when 3 =>
           ref_matrix := COMPUTE_REF_DCT1D(input_data4,TRUE); 
         when others =>
           ref_matrix := COMPUTE_REF_DCT1D(input_data0,TRUE);     
       end case;

       for i in 0 to N-1 loop
         j := 0;
         while(true) loop
  
           waitposedge;
           if odv1 = '1' then
             dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto1 ));
             j := j + 1;
           end if;
  
           if j = N then
             exit;
           end if;
   
         end loop;
       end loop;
       CMP_MATRIX(ref_matrix,dcto_matrix,MAX_ERROR_1D,error_matrix,error_cnt);
     end loop;
     -------------------------
     
     -------------------------
     -- test 6
     -------------------------
     test_inp <= 6;  
     
     if RUN_FULL_IMAGE = TRUE then
       read_image_for1dct(error_cnt);
     end if;
     -------------------------
     
     -------------------------
     -- test 7
     -------------------------
     test_inp <= 7;  
     
     --read_image_for1dct(error_cnt);
     -------------------------
     
     if error_cnt = 0 then
       assert false
         report "No errors found in first stage of DCT"
         severity Note;
     else
       assert false
         report "Found " & STR(error_cnt,10) & " errors in first stage of DCT!"
         severity Error;
     end if;
     assert false
       report "1D Test finished"
       severity Note;
     
     wait;
 end process;  
 
 --------------------------
 -- final output coeffs comparison (after 2nd stage) 
 --------------------------
 FINAL_OUTIMAGE_PROC: process
   variable i : INTEGER := 0;
   variable j : INTEGER := 0;
   variable error_matrix    : I_MATRIX_TYPE;
   variable error_idct_matrix : I_MATRIX_TYPE;
   variable error_cnt       : INTEGER := 0;
   variable raport_str      : STRING(1 to 255);
   variable ref_matrix_1d   : I_MATRIX_TYPE;
   variable ref_matrix_2d   : I_MATRIX_TYPE;
   variable ref_idct_matrix : I_MATRIX_TYPE;
   variable idcto_matrix    : I_MATRIX_TYPE;
   variable dcto_matrix     : I_MATRIX_TYPE;
   variable tmp_matrix      : I_MATRIX_TYPE;
   variable psnr            : REAL;
   variable xi              : INTEGER := 0;
  -------------------------------------
  -- wait for defined number of clock cycles
  -------------------------------------
  procedure waitposedge(clocks : in INTEGER) is
  begin
    for i in 1 to clocks loop
      wait until clk='1' and clk'event; 
    end loop;
  end waitposedge;
  
  -------------------------------------
  -- wait on clock rising edge
  -------------------------------------
  procedure waitposedge is
  begin
    wait until clk='1' and clk'event;
  end waitposedge;

  --------------------------------------
  -- read text image data 2D DCT
  --------------------------------------
  procedure read_image_for2dct(error_cnt_i : inout INTEGER) is
    file infile          : TEXT open read_mode is FILEIN_NAME_C;
    file outfile_imagee  : TEXT open write_mode is FILEERROR_NAME_C;
    file outfile_imageo  : TEXT open write_mode is FILEIMAGEO_NAME_C;
    variable inline      : LINE;
    variable outline     : LINE;
    variable outline2    : LINE;
    variable tmp_int     : INTEGER := 0;
    variable y_size      : INTEGER := 0;
    variable x_size      : INTEGER := 0;
    variable x_blocks8   : INTEGER := 0;
    variable y_blocks8   : INTEGER := 0;
    variable matrix      : I_MATRIX_TYPE;
    variable x_blk_cnt   : INTEGER := 0;
    variable y_blk_cnt   : INTEGER := 0;
    variable n_lines_arr : N_LINES_TYPE;
    variable line_n      : INTEGER := 0;
    variable pix_n       : INTEGER := 0;
    variable x_n         : INTEGER := 0;
    variable y_n         : INTEGER := 0;
    variable i           : INTEGER := 0;
    variable j           : INTEGER := 0;
    variable dcto_matrix_v    : I_MATRIX_TYPE;
    variable ref_matrix_v     : I_MATRIX_TYPE;
    variable error_matrix_v   : I_MATRIX_TYPE;
    variable idcto_matrix_v   : I_MATRIX_TYPE;
    variable ref_matrix_1d_v  : I_MATRIX_TYPE;
    variable ref_matrix_2d_v  : I_MATRIX_TYPE;
    variable error_idct_matrix_v : I_MATRIX_TYPE;
    variable error_dct_matrix_v  : I_MATRIX_TYPE;
    variable psnr_v           : REAL := 0.0;
    variable linebuf          : LINE;
    variable input_image      : IMAGE_TYPE;
    variable output_image     : IMAGE_TYPE;
    variable dcto_image       : IMAGE_TYPE;
    variable str2_v           : STRING(1 to 2);
    variable dec_v            : INTEGER := 0;
    variable dec2_v           : INTEGER := 0;
    variable clip_cnt_v       : INTEGER := 0;
    variable tmp_q            : INTEGER := 0;
  begin
    READLINE(infile,inline);
    READ(inline,y_size);
    READLINE(infile,inline);
    READ(inline,x_size);
    
    y_blocks8 := y_size / N;
    x_blocks8 := x_size / N;
    
    assert MAX_IMAGE_SIZE_X > x_size
      report "E02: Input image x size exceeds maximum value!"
      severity Failure;
    
    if y_size rem N > 0 then
      assert false
        report "E03: Image height dimension is not multiply of N!"
        severity Failure;
    end if;
    if x_size rem N > 0 then
      assert false
        report "E03: Image width dimension is not multiply of N!"
        severity Failure;
    end if;
    
    for y_blk_cnt in 0 to y_blocks8-1 loop
      
      -- read N input lines and store them to buffer
      for y_n in 0 to N-1 loop
        READLINE(infile,inline);
        HREAD(inline,n_lines_arr(y_n)(0 to x_size*IP_W-1));
      end loop;
      y_n := 0;
      
      for x_blk_cnt in 0 to x_blocks8-1 loop
        for y_n in 0 to N-1 loop
          for x_n in 0 to N-1 loop
            matrix(y_n,x_n) := TO_INTEGER(UNSIGNED(
                n_lines_arr(y_n)
                    ((x_blk_cnt*N+x_n)*IP_W to 
                    (x_blk_cnt*N+(x_n+1))*IP_W-1)));
            input_image(y_blk_cnt*N+y_n,x_blk_cnt*N+x_n) := 
                                                    matrix(y_n,x_n);
          end loop;
        end loop;
        
        for i in 0 to N-1 loop
          j := 0;
          while(true) loop
            waitposedge;
            if odv = '1' then
              tmp_q := TO_INTEGER(SIGNED( dcto ));
              if ENABLE_QUANTIZATION_C = TRUE then
                tmp_q := tmp_q / Q_MATRIX_USED(j,i);
                tmp_q := tmp_q * Q_MATRIX_USED(j,i);
              end if;
              dcto_matrix_v(j,i) := tmp_q;
              j := j + 1;
            end if;

            if j = N then
              exit;
            end if;
          end loop;
        end loop;
        idcto_matrix_v := COMPUTE_REF_IDCT(dcto_matrix_v);
        for i in 0 to N-1 loop
          for j in 0 to N-1 loop
            output_image(y_blk_cnt*N+j,x_blk_cnt*N+i) := 
                                                    idcto_matrix_v(j,i);
            dcto_image(y_blk_cnt*N+j,x_blk_cnt*N+i) := 
                                                    dcto_matrix_v(j,i);
          end loop;
        end loop;
        -- compute reference coefficients
        ref_matrix_1d_v := COMPUTE_REF_DCT1D(matrix,TRUE);
        ref_matrix_2d_v := COMPUTE_REF_DCT1D(ref_matrix_1d_v,FALSE);
        CMP_MATRIX(ref_matrix_2d_v,dcto_matrix_v,MAX_ERROR_2D,
                                error_dct_matrix_v,error_cnt_i);
        error_dct_matrix_s <= error_dct_matrix_v;
                   
      end loop;
    end loop;
    
    -- PSNR
    psnr_v := COMPUTE_PSNR(input_image,output_image,y_size,x_size);
    WRITE(linebuf,STRING'("PSNR computed for image " 
                          & FILEIN_NAME_C & " is "));
    WRITE(linebuf,psnr_v);
    WRITE(linebuf,STRING'(" dB")); 
    assert false
      report linebuf.all
      severity Note;
      
    -- Save images
    WRITE(outline,y_size);
    WRITELINE(outfile_imageo,outline);
    WRITE(outline,x_size);
    WRITELINE(outfile_imageo,outline);
    
    WRITE(outline,y_size);
    WRITELINE(outfile_imagee,outline);
    WRITE(outline,x_size);
    WRITELINE(outfile_imagee,outline);
    
    for i in 0 to y_size-1 loop
      for j in 0 to x_size-1 loop
        
        -- output image
        dec_v := output_image(i,j);
        -- if DCT transform error created minus value, set it to zero
        if dec_v < 0 then
          dec_v := 0;
          clip_cnt_v := clip_cnt_v + 1;
        elsif dec_v > 255 then
          dec_v := 255;
          clip_cnt_v := clip_cnt_v + 1;
        end if;
        
        if dec_v <= HEX_BASE-1 then
          str2_v := "0" & STR( dec_v, HEX_BASE);
        else
          str2_v := STR( dec_v, HEX_BASE);
        end if;
        WRITE(outline,str2_v);     
        
        -- dcto image
        dec_v := abs(output_image(i,j)-input_image(i,j));
        -- if DCT transform error created minus value, set it to zero
        if dec_v > 255 then
          dec_v := 255;
        end if;
        
        if dec_v <= HEX_BASE-1 then
          str2_v := "0" & STR( dec_v, HEX_BASE);
        else
          str2_v := STR( dec_v, HEX_BASE);
        end if;
        WRITE(outline2,str2_v);
      end loop;
      WRITELINE(outfile_imageo,outline);
      WRITELINE(outfile_imagee,outline2); 
    end loop;
    
    
  end read_image_for2dct;

  begin
     test_out <= 0;
     testend <= false;
       
     -------------------------
     -- test 1
     -------------------------  
     test_out <= 1;
     tmp_matrix := input_data0;
     -- compute reference coefficients
     ref_matrix_1d := COMPUTE_REF_DCT1D(tmp_matrix,TRUE);
     ref_matrix_2d := COMPUTE_REF_DCT1D(ref_matrix_1d,FALSE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     waitposedge;
     
     CMP_MATRIX(ref_matrix_2d,dcto_matrix,MAX_ERROR_2D,error_matrix,error_cnt);
     idcto_matrix := COMPUTE_REF_IDCT(dcto_matrix);
     --error_idct_matrix := CMP_MATRIX(tmp_matrix,idcto_matrix,MAX_ERROR_2D);
     psnr := psnr + COMPUTE_PSNR(tmp_matrix,idcto_matrix);
     -------------------------
     
     -------------------------
     -- test 2
     -------------------------
     test_out <= 2;  
     tmp_matrix := input_data1;
     -- compute reference coefficients
     ref_matrix_1d := COMPUTE_REF_DCT1D(tmp_matrix,TRUE);
     ref_matrix_2d := COMPUTE_REF_DCT1D(ref_matrix_1d,FALSE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     waitposedge;
     
     CMP_MATRIX(ref_matrix_2d,dcto_matrix,MAX_ERROR_2D,error_matrix,error_cnt);
     idcto_matrix := COMPUTE_REF_IDCT(dcto_matrix);
     --error_idct_matrix := CMP_MATRIX(tmp_matrix,idcto_matrix,MAX_ERROR_2D);
     psnr := COMPUTE_PSNR(tmp_matrix,idcto_matrix);
     -------------------------
     
     -------------------------
     -- test 3
     -------------------------
     test_out <= 3;  
     tmp_matrix := input_data2;
     -- compute reference coefficients
     ref_matrix_1d := COMPUTE_REF_DCT1D(tmp_matrix,TRUE);
     ref_matrix_2d := COMPUTE_REF_DCT1D(ref_matrix_1d,FALSE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     waitposedge;
     
     CMP_MATRIX(ref_matrix_2d,dcto_matrix,MAX_ERROR_2D,error_matrix,error_cnt);
     idcto_matrix := COMPUTE_REF_IDCT(dcto_matrix);
     --error_idct_matrix := CMP_MATRIX(tmp_matrix,idcto_matrix,MAX_ERROR_2D);
     --psnr := COMPUTE_PSNR(tmp_matrix,idcto_matrix);
     -------------------------
     
     -------------------------
     -- test 4
     -------------------------
     test_out <= 4;  
     tmp_matrix := input_data0;
     -- compute reference coefficients
     ref_matrix_1d := COMPUTE_REF_DCT1D(tmp_matrix,TRUE);
     ref_matrix_2d := COMPUTE_REF_DCT1D(ref_matrix_1d,FALSE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     waitposedge;
     
     CMP_MATRIX(ref_matrix_2d,dcto_matrix,MAX_ERROR_2D,error_matrix,error_cnt);
     idcto_matrix := COMPUTE_REF_IDCT(dcto_matrix);
     --error_idct_matrix := CMP_MATRIX(tmp_matrix,idcto_matrix,MAX_ERROR_2D);
     psnr := COMPUTE_PSNR(tmp_matrix,idcto_matrix);
     -------------------------
     
     -------------------------
     -- test 5
     -------------------------
     test_out <= 5;  
     tmp_matrix := input_data1;
     -- compute reference coefficients
     ref_matrix_1d := COMPUTE_REF_DCT1D(tmp_matrix,TRUE);
     ref_matrix_2d := COMPUTE_REF_DCT1D(ref_matrix_1d,FALSE); 
       
     for i in 0 to N-1 loop
       j := 0;
       while(true) loop

         waitposedge;
         if odv = '1' then
           dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto ));
           j := j + 1;
         end if;

         if j = N then
           exit;
         end if;
 
       end loop;
     end loop;
     
     waitposedge;
     
     CMP_MATRIX(ref_matrix_2d,dcto_matrix,MAX_ERROR_2D,error_matrix,error_cnt);
     idcto_matrix := COMPUTE_REF_IDCT(dcto_matrix);
     psnr := COMPUTE_PSNR(tmp_matrix,idcto_matrix);
     -------------------------
     
     -------------------------
     -- test 6-16
     -------------------------
     for x in 0 to 10 loop
       test_out <= test_out+1; 
       
       if x rem 2 = 0 then 
         tmp_matrix := input_data0;
       else
         tmp_matrix := input_data3;
       end if;
       -- compute reference coefficients
       ref_matrix_1d := COMPUTE_REF_DCT1D(tmp_matrix,TRUE);
       ref_matrix_2d := COMPUTE_REF_DCT1D(ref_matrix_1d,FALSE); 
         
       for i in 0 to N-1 loop
         j := 0;
         while(true) loop
  
           waitposedge;
           if odv = '1' then
             dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto ));
             j := j + 1;
           end if;
  
           if j = N then
             exit;
           end if;
   
         end loop;
       end loop;
       
       CMP_MATRIX(ref_matrix_2d,dcto_matrix,MAX_ERROR_2D,error_matrix,error_cnt);
       idcto_matrix := COMPUTE_REF_IDCT(dcto_matrix);
       psnr := COMPUTE_PSNR(tmp_matrix,idcto_matrix);
     end loop;
     -------------------------
     
     -------------------------
     -- test 17-33
     -------------------------
     for x in 0 to 16 loop
       test_out <= test_out+1; 
       if xi < 4 then
         xi := xi + 1;
       else
         xi := 0;
       end if;
       case xi is
         when 0 =>
           tmp_matrix := input_data1;
         when 1 =>
           tmp_matrix := input_data0;
         when 2 =>
           tmp_matrix := input_data3;
         when 3 =>
           tmp_matrix := input_data4;
         when others =>
           tmp_matrix := input_data0;    
       end case;
       -- compute reference coefficients
       ref_matrix_1d := COMPUTE_REF_DCT1D(tmp_matrix,TRUE);
       ref_matrix_2d := COMPUTE_REF_DCT1D(ref_matrix_1d,FALSE); 
         
       for i in 0 to N-1 loop
         j := 0;
         while(true) loop
  
           waitposedge;
           if odv = '1' then
             dcto_matrix(j,i) := TO_INTEGER(SIGNED( dcto ));
             j := j + 1;
           end if;

           if j = N then
             exit;
           end if;
   
         end loop;
       end loop;
       
       CMP_MATRIX(ref_matrix_2d,dcto_matrix,MAX_ERROR_2D,error_matrix,error_cnt);
       idcto_matrix := COMPUTE_REF_IDCT(dcto_matrix);
       psnr := COMPUTE_PSNR(tmp_matrix,idcto_matrix);
     end loop;
     -------------------------
     
     -------------------------
     -- test 6
     -------------------------
     test_out <= 6; 
     if RUN_FULL_IMAGE = TRUE then
       read_image_for2dct(error_cnt);
     end if;
     -------------------------
     
     -------------------------
     -- test 7
     -------------------------
     test_out <= 7; 
     --read_image_for2dct(error_cnt);
     -------------------------
     
     waitposedge;
     testend <= TRUE;
     if error_cnt = 0 then
       assert false
         report "No errors found in second stage of DCT"
         severity Note;
     else
       assert false
         report "Found " & STR(error_cnt,10) & " errors in second stage of DCT!"
         severity Error;
     end if;
     assert false
       report "2D Test finished"
       severity Note;
     
     wait;
 end process;  

end SIM;
--**************************************************************************--