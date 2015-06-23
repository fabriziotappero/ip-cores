library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;  

entity eDither  is
   generic
   (
      img_width       : integer := 512;
      img_height      : integer := 512;
      color_width     : integer := 8;
      reduced_width   : integer := 4
   );
   port 
   (
      clk       : in  std_logic;
      enable    : in  std_logic;
      
      x         : in  integer range 0 to img_width-1;
      
      din_r     : in  std_logic_vector(color_width-1 downto 0);
      din_g     : in  std_logic_vector(color_width-1 downto 0);
      din_b     : in  std_logic_vector(color_width-1 downto 0);
      
      dout_r    : out std_logic_vector(color_width-1 downto 0) := (others => '0');
      dout_g    : out std_logic_vector(color_width-1 downto 0) := (others => '0');
      dout_b    : out std_logic_vector(color_width-1 downto 0) := (others => '0')
   );
end entity;

architecture arch of eDither is
  
   constant dither_bits : integer := color_width - reduced_width;

   -- intermediate signals for caclulation
   type t_dither_rgb is array(1 to 3) of unsigned(dither_bits-1 downto 0);
   signal dither_buffer_next : t_dither_rgb := (others => (others =>'0'));
   signal dither_buffer_newline : t_dither_rgb := (others => (others =>'0'));
   signal dither_buffer_toRam : t_dither_rgb := (others => (others =>'0'));
   signal dither_buffer_fromRam : t_dither_rgb := (others => (others =>'0'));
    
   -- infered ram for holding old pixel information
   type t_dither_buffer is array(0 to img_width-1) of unsigned((dither_bits * 3)-1 downto 0);
   signal dither_buffer : t_dither_buffer := (others => (others => '0')); 
   signal index : integer range 0 to img_width-1 := 0;
   signal AddrA : integer range 0 to img_width-1 := 0;
   signal AddrB : integer range 0 to img_width-1 := 0;
   signal WEA   : std_logic := '0';

         
begin

   process (clk)
      type t_intermediate is array(1 to 3) of unsigned(color_width downto 0);
      variable intermediate_color : t_intermediate;
   begin
      if rising_edge(clk) then
         
         -- calculate dithered colors
         if (enable = '1') then
        
            intermediate_color(1) := ("0" & unsigned(din_r)) + dither_buffer_next(1) + unsigned(dither_buffer_fromRam(1));
            intermediate_color(2) := ("0" & unsigned(din_g)) + dither_buffer_next(2) + unsigned(dither_buffer_fromRam(2));
            intermediate_color(3) := ("0" & unsigned(din_b)) + dither_buffer_next(3) + unsigned(dither_buffer_fromRam(3));
            
            for c in 1 to 3 loop

               if (intermediate_color(c)(8) = '1') then intermediate_color(c) := '0' & to_unsigned((2**color_width) - 1, color_width); end if;
            
               dither_buffer_next(c) <= "0" & intermediate_color(c)(dither_bits-1 downto 1); 
               dither_buffer_newline(c) <= "00" & intermediate_color(c)(dither_bits-1 downto 2);
               dither_buffer_toRam(c) <= ("00" & intermediate_color(c)(dither_bits-1 downto 2)) + dither_buffer_newline(c);
            end loop; 
            
         else
            intermediate_color(1) := "0" & unsigned(din_r);
            intermediate_color(2) := "0" & unsigned(din_g);
            intermediate_color(3) := "0" & unsigned(din_b);
         end if;
         
         
         -- calculate address for line buffer + enable
         if (x<img_width-2) then
            AddrB <= x+2;
         elsif (x=img_width-2) then
            AddrB <= 0;
         else
            AddrB <= 1;
         end if;
         
         index <= x;
         AddrA <= index;
         
         if (enable = '1') then
            WEA <= '1';
         else
            WEA <= '0';
         end if;
            
         -- line buffer memory
         if (WEA = '1') then
            dither_buffer(AddrA) <= dither_buffer_toRam(1) & dither_buffer_toRam(2) & dither_buffer_toRam(3);
         end if;
         
         dither_buffer_fromRam(1) <= dither_buffer(AddrB)((dither_bits * 3)-1 downto (dither_bits * 2));
         dither_buffer_fromRam(2) <= dither_buffer(AddrB)((dither_bits * 2)-1 downto dither_bits);
         dither_buffer_fromRam(3) <= dither_buffer(AddrB)(dither_bits-1 downto 0);
            
         -- map outputs
         dout_r <= std_logic_vector(intermediate_color(1)(color_width-1 downto 0));
         dout_g <= std_logic_vector(intermediate_color(2)(color_width-1 downto 0));
         dout_b <= std_logic_vector(intermediate_color(3)(color_width-1 downto 0));
 
      end if;
   end process;

   
end architecture;
