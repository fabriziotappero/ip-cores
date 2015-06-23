library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;     
use IEEE.std_logic_textio.all;
use STD.textio.all;


entity tb is
end entity;

architecture arch of tb is
   
   constant img_width      : integer := 256;
   constant img_height     : integer := 512;
   constant reduced_width  : integer := 4;

   type   bit_vector_file is file of bit_vector;
   file   read_file       : bit_vector_file open read_mode is "input.bmp";

   type   std_file is file of character;
   file   write_file      : std_file open write_mode is "output.bmp";
   
   signal clk        : std_logic := '1';
   
   type t_color is array(1 to 3) of std_logic_vector(7 downto 0);
   type t_bmp is array(0 to img_width, 0 to img_height) of t_color;
   signal bmp_read   : t_bmp;
   signal bmp_out    : t_bmp := (others => (others => (others => (others => '0'))));
      
   signal enable     : std_logic := '0';
      
   signal din_r      : std_logic_vector(7 downto 0) := (others => '0');
   signal din_g      : std_logic_vector(7 downto 0) := (others => '0');
   signal din_b      : std_logic_vector(7 downto 0) := (others => '0');
   signal dout_r     : std_logic_vector(7 downto 0);
   signal dout_g     : std_logic_vector(7 downto 0);
   signal dout_b     : std_logic_vector(7 downto 0);
   
   signal x_count    : integer := 0;
   signal y_count    : integer := 0;
   signal x_in       : integer := 0;
   signal y_in       : integer := 1;
   signal x_out      : integer := 0;
   signal y_out      : integer := 1;
      
   signal running    : std_logic := '0';
   signal done       : std_logic := '0';
   
begin 
   
   
   clk <= not clk after 5 ns;
   
   
   pcreate_pixelpositions : process (clk)
   begin
      if rising_edge(clk) then
         
         if (running = '1' and done = '0') then
      
            if (x_count < img_width-1) then
               x_count <= x_count + 1;
            else
               x_count <= 0;
               if (y_count< img_height-1) then
                  y_count <= y_count + 1;
               else
                  done <= '1';
               end if;
            end if;
            
            -- for test only one half of image is dithered
            if (y_count < img_height / 2) then
               enable <= '1';
            else
               enable <= '0';
            end if;
            
            x_in <= x_count;
            y_in <= y_count;
            
            x_out <= x_in;
            y_out <= y_in;
            
            din_r <= bmp_read(x_count,y_count)(1);
            din_g <= bmp_read(x_count,y_count)(2);
            din_b <= bmp_read(x_count,y_count)(3);
            
            bmp_out(x_out,y_out)(1) <= dout_r(7 downto 7 - reduced_width + 1) & (7 - reduced_width downto 0 => '0');
            bmp_out(x_out,y_out)(2) <= dout_g(7 downto 7 - reduced_width + 1) & (7 - reduced_width downto 0 => '0');
            bmp_out(x_out,y_out)(3) <= dout_b(7 downto 7 - reduced_width + 1) & (7 - reduced_width downto 0 => '0');
         
         end if;
        
      end if;
   end process;
   
   
   
   idither : entity work.eDither
   generic map
   (
      img_width      => img_width,
      img_height     => img_height,
      color_width    => 8,  
      reduced_width  => reduced_width
   )
   port map 
   (
      clk       => clk,  
      enable    => enable,
      x         => x_in,
      din_r     => din_r, 
      din_g     => din_g, 
      din_b     => din_b, 
      dout_r    => dout_r,
      dout_g    => dout_g,
      dout_b    => dout_b
   );
   

   
   pfile_actions : process
       
      variable next_vector : bit_vector (0 downto 0);
      variable actual_len  : natural;
      variable addr        : unsigned(17 downto 0) := (others => '0');
      variable to_write    : signed(15 downto 0); 
      variable read_byte   : std_logic_vector(7 downto 0);
      
      -- copy from std_logic_arith, not used here because numeric std is also included
      function CONV_STD_LOGIC_VECTOR(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR is
        variable result: STD_LOGIC_VECTOR (SIZE-1 downto 0);
        variable temp: integer;
      begin
      
         temp := ARG;
         for i in 0 to SIZE-1 loop
        
         if (temp mod 2) = 1 then
            result(i) := '1';
         else 
            result(i) := '0';
         end if;
         
         if temp > 0 then
            temp := temp / 2;
         elsif (temp > integer'low) then
            temp := (temp - 1) / 2; -- simulate ASR
         else
            temp := temp / 2; -- simulate ASR
         end if;
        end loop;
      
        return result;  
      end;
        
      variable std_buffer : character;
        
   begin
   
      -- copy bmp header
      for i in 1 to 51 loop
         read(read_file, next_vector, actual_len);
         std_buffer := character'val(to_integer(unsigned(CONV_STD_LOGIC_VECTOR(bit'pos(next_vector(0)), 8))));
         write(write_file, std_buffer);
      end loop;

      -- read in bmp color data
      for y in 0 to img_height-1 loop
         for x in 0 to img_width-1 loop
            for c in 1 to 3 loop
      
               read(read_file, next_vector, actual_len);  
               read_byte := CONV_STD_LOGIC_VECTOR(bit'pos(next_vector(0)), 8);
               bmp_read(x,y)(c) <= read_byte;
               wait for 5 ns;
               
            end loop;
         end loop;
      end loop;
      
      running <= '1';
      
      wait until done = '1';
      
      -- write result to bmp
      for y in 0 to img_height-1 loop
         for x in 0 to img_width-1 loop
            for c in 1 to 3 loop
               
               std_buffer := character'val(to_integer(unsigned(bmp_out(x,y)(c))));
               write(write_file, std_buffer);

            end loop;
         end loop;
      end loop;
      
      running <= '0';
      
      ASSERT false REPORT "End of Test" SEVERITY FAILURE;
      
      wait;
           
   end process; 
   
   
   
end architecture;





