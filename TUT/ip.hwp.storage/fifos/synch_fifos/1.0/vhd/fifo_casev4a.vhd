-- Fifo with case version 4:
-- different from v3:
-- - using variable data_amount in order to update it right away,
--   rather than wait util the process ends.
--
-- Designer : Ari Kulmala
--
-- Variable Data_amount will infer register synthesis! Scary stuff, es 07.11.2003



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity fifo is

  generic (
    width : integer := 0;
    depth : integer := 0
    );
  port (
    Clk            : in  std_logic;
    Rst_n          : in  std_logic;     -- Active low
    Data_In        : in  std_logic_vector (width-1 downto 0);
    Write_Enable   : in  std_logic;
    One_Place_Left : out std_logic;
    Full           : out std_logic;
    Data_Out       : out std_logic_vector (width-1 downto 0);
    Read_Enable    : in  std_logic;
    Empty          : out std_logic;
    One_Data_Left  : out std_logic
    );

end fifo;

architecture behavioral of fifo is

  type reg is array (depth downto 2) of std_logic_vector
    (width-1 downto 0);
  signal input_buffer : reg;

  signal WR : std_logic_vector ( 1 downto 0);
  
begin  -- behavioral

  -- Concurrent assignment
  WR <= Write_Enable & Read_Enable;
  

  
  process (Clk, rst_n)
    variable Data_amount : integer range 0 to depth;
  begin  -- process
    if rst_n = '0' then                   -- asynchronous reset (active low)
      --     for i in depth downto 2 loop
      --       input_buffer(i) <= (others => '0');
      --     end loop;  -- i
      --     Data_out          <= (others => '0');

      Data_Amount       := 0;
      Empty             <= '1';
      One_Data_Left     <= '0';
      One_Place_Left    <= '0';
      Full              <= '0';

    elsif Clk'event and Clk = '1' then    -- rising clock edge

      case WR is
        when "01" =>
          -- Read data
          if Data_amount = 0 then
            Data_amount := Data_amount;
          elsif Data_amount = 1 then
            -- Data_out <= (others => '0');
            Data_amount := Data_amount-1;
          else
            Data_out <= input_buffer(Data_amount);
            Data_amount := Data_amount-1;
          end if;


        when "10" =>
          -- Write Data
          if Data_amount = 0 then
            Data_out            <= Data_In;
            Data_amount := Data_amount+1;
          elsif Data_amount = depth then
            input_buffer        <= input_buffer;
          else
            for i in depth-1 downto 2 loop
              input_buffer(i+1) <= input_buffer(i);
            end loop;  -- i
            input_buffer(2)     <= Data_In;
            Data_amount := Data_amount+1;
          end if;

        when "11" =>
          -- Read and Write concurrently
          if Data_amount = 0 then
            -- cannot read if empty
            Data_out            <= Data_in;
            Data_Amount := Data_Amount +1;
          elsif Data_amount = 1 then
            Data_out            <= Data_In;
          elsif Data_amount = depth then
            -- cannot write if full
            Data_out            <= input_buffer (Data_amount);
            Data_amount := Data_amount-1;
          else
            Data_out            <= input_buffer (Data_amount);
            for i in depth-1 downto 2 loop
              input_buffer(i+1) <= input_buffer(i);
            end loop;  -- i
            input_buffer(2)      <= Data_In;
          end if;

        when others =>                            -- Do nothing
          input_buffer <= input_buffer;
          Data_amount := Data_amount;
          
      end case;

      if Data_amount = 0 then
        Empty          <= '1';
        One_Place_Left <= '0';
        One_Data_Left  <= '0';
        Full           <= '0';

      elsif Data_amount = 1 then

        Empty          <= '0';
        One_Data_Left  <= '1';
        One_Place_Left <= '0';
        Full           <= '0';
      elsif Data_amount = depth-1 then    --one place left
        Empty          <= '0';

        One_Place_Left <= '1';
        One_Data_Left  <= '0';
        Full           <= '0';
      elsif Data_amount = depth then      --full
        Empty          <= '0';
        One_Place_Left <= '0';
        One_Data_Left  <= '0';
        Full           <= '1';


      else
        Empty          <= '0';
        One_Place_Left <= '0';
        One_Data_Left  <= '0';
        Full           <= '0';
      end if;

    end if; --synchronous

  end process;
  
end behavioral;












