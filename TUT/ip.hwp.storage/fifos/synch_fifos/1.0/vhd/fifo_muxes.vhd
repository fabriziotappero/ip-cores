-------------------------------------------------------------------------------
-- File        : fifo_muxes.vhdl
-- Description : Makes two fifos look like a single fifo.
--               Two components : one for writing and one for reading fifo.
--               Write_demux:
--               Input : data, addr valid and command 
--               Out   : data, addr valid and command to two fifos
--
--               Read_mux :
--               Input : data, addr valid and command from two fifos
--               Out   : data, addr valid and command
--
--              NOTE:
--              1)
--              Read_mux does not fully support One_Data_Left_Out!
--
--               It works when writing to fifo. However, when something
--              is written to empty fifo, One_Data_Left_Out remains 0
--              even if Empty goes from 1 to 0! Be careful out there.
--
--               Case when new addr is written to fifo 0 and there is a gap before
--              corresponding data. At the same time there is some data in fifo
--              #1. It is not wise to wait for data#0, because it blocks the data#1.
--              In such, case transfer from fifo#0 is interrupted (Empty goes high).
--              At the moment, One_Data_Left_Out does not work in such case.
--              (Probably it could be repaired with fifo_bookkeeper component?)
--              2) 
--              
-- Author      : Erno Salminen
-- Date        : 05.02.2003
-- Modified    : 
--               
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;





-- Write_Mux checks the incoming addr. Same addr is not
-- written to fifo more than once! Written fifo is selected
-- according to incoming command
entity fifo_demux_write is

  generic (
    Data_Width         :     integer := 0;
    Comm_Width         :     integer := 0
    );
  port (
    -- 13.04 Fully asynchronous!
    --Clk                : in  std_logic;
    --Rst_n              : in  std_logic;

    Data_In            : in  std_logic_vector (Data_Width-1 downto 0);
    Addr_Valid_In      : in  std_logic;
    Comm_In            : in  std_logic_vector (Comm_Width-1 downto 0);
    WE_In              : in  std_logic;
    One_Place_Left_Out : out std_logic;
    Full_Out           : out std_logic;

    -- Data/Comm/AV conencted to both fifos
    -- Distinction made with WE!
    Data_Out            : out std_logic_vector (Data_Width-1 downto 0);
    Comm_Out            : out std_logic_vector (Comm_Width-1 downto 0);
    Addr_Valid_Out      : out std_logic;
    WE_0_Out            : out std_logic;
    WE_1_Out            : out std_logic;
    Full_0_In           : in  std_logic;
    Full_1_In           : in  std_logic;
    One_Place_Left_0_In : in  std_logic;
    One_Place_Left_1_In : in  std_logic
    );

end fifo_demux_write;






--   constant Idle              : std_logic_vector ( Comm_Width-1 downto 0) := "000"; -- 0
--   constant Write_Config_Data : std_logic_vector ( Comm_Width-1 downto 0) := "001"; -- 1
--   constant Write_Data        : std_logic_vector ( Comm_Width-1 downto 0) := "010"; -- 2
--   constant Write_Message     : std_logic_vector ( Comm_Width-1 downto 0) := "011"; -- 3

--   constant Read_RQ           : std_logic_vector ( Comm_Width-1 downto 0) := "100"; -- 4
--   constant Read_Config       : std_logic_vector ( Comm_Width-1 downto 0) := "101"; -- 5
--   constant Multicast_Data    : std_logic_vector ( Comm_Width-1 downto 0) := "110"; -- 6
--   constant Multicast_Message : std_logic_vector ( Comm_Width-1 downto 0) := "111"; -- 7

architecture rtl of fifo_demux_write is

begin  -- rtl


  -- Concurrent assignments
  Data_Out       <= Data_In;
  Addr_Valid_Out <= Addr_Valid_In;
  Comm_Out       <= Comm_In;

  
  -- PROCESSES
  -- Fully combinational
  Demultiplex_data : process (Data_In, Addr_Valid_In, Comm_In, WE_In,
                              One_Place_Left_0_In, One_Place_Left_1_In,
                              Full_0_In, Full_1_In)
  begin  -- process Demultiplex_data

    if Comm_In = conv_std_logic_vector (3, Comm_Width)
      or Comm_In = conv_std_logic_vector (7, Comm_Width) then
      -- MESSAGE

      WE_0_Out           <= WE_In;
      WE_1_Out           <= '0';
      Full_Out           <= Full_0_In;
      One_Place_Left_Out <= One_Place_Left_0_In;

      
    elsif Comm_In = conv_std_logic_vector (2, Comm_Width)
      or Comm_In = conv_std_logic_vector (4, Comm_Width)
      or Comm_In = conv_std_logic_vector (6, Comm_Width) then
      -- DATA
      WE_0_Out           <= '0';
      WE_1_Out           <= WE_In;
      Full_Out           <= Full_1_In;
      One_Place_Left_Out <= One_Place_Left_1_In;

      
    elsif Comm_In = conv_std_logic_vector (1, Comm_Width)
      or Comm_In = conv_std_logic_vector (5, Comm_Width) then
      -- CONFIG
      assert false report "Config comm to fifo_demux_write" severity warning;
      WE_0_Out           <= '0';
      WE_1_Out           <= '0';
      Full_Out           <= '0';
      One_Place_Left_Out <= '0';

      
    else
      --IDLE
      WE_0_Out           <= '0';
      WE_1_Out           <= '0';
      Full_Out           <= '0';
      One_Place_Left_Out <= '0';
    end if;                             --Comm_In

      
  end process Demultiplex_data;


      
end rtl;                                --fifo_demux_write






-------------------------------------------------------------------------------
--entity fifo_mux_read kaytetaan lukemaan kahdesta fifosta osoite ja data perakkain
-- fifolla 0 on suurempi prioritetti. Jos ollaan lukemassa fifoa 1, ei ruveta
-- lukemaan fifoa 0 ennekuin on siirretty ainakin yksi data fifosta 1.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;





entity fifo_mux_read is

  generic (
    Data_Width         :     integer := 0;
    Comm_Width         :     integer := 0
    );
  port (
    Clk                : in  std_logic;
    Rst_n              : in  std_logic;

    Data_0_In          : in  std_logic_vector (Data_Width-1 downto 0);
    Comm_0_In          : in  std_logic_vector (Comm_Width-1 downto 0);
    Addr_Valid_0_In    : in  std_logic;
    One_Data_Left_0_In : in  std_logic;
    Empty_0_In         : in  std_logic;
    RE_0_Out           : out std_logic;

    Data_1_In          : in  std_logic_vector (Data_Width-1 downto 0);
    Comm_1_In          : in  std_logic_vector (Comm_Width-1 downto 0);
    Addr_Valid_1_In    : in  std_logic;
    One_Data_Left_1_In : in  std_logic;
    Empty_1_In         : in  std_logic;
    RE_1_Out           : out std_logic;

    Read_Enable_In    : in  std_logic;
    Data_Out          : out std_logic_vector (Data_Width-1 downto 0);
    Comm_Out          : out std_logic_vector (Comm_Width-1 downto 0);      
    Addr_Valid_Out    : out std_logic;
    One_Data_Left_Out : out std_logic;
    Empty_Out         : out std_logic
    );

end fifo_mux_read;


architecture rtl of fifo_mux_read is
  signal Last_Addr_Reg_0   : std_logic_vector ( Comm_Width+Data_Width-1 downto 0);
  signal Last_Addr_Reg_1   : std_logic_vector ( Comm_Width+Data_Width-1 downto 0);

  signal State_Reg : integer range 0 to 5;
  -- Transferred_Reg - siirron tila
  -- 00) Ei ole siirretty viela mitaan
  -- 01) Osoite fifossa 0
  -- 02) Data fifossa 0
  -- 03) Osoite fifosta 1
  -- 04) Data fifosta 1
  -- 05) mol tyhjia
  
  -- Tilasiirtymat
  -- 00 -> 01, 03
  -- 01 -> 02
  -- 02 -> 01, 02, 03
  -- 03 -> 04
  -- 04 -> 01, 04, 05
  -- 05 -> 01, 03
  
begin  -- rtl



  -- PROC
  Assign_Outputs : process (State_Reg, Data_1_In, Data_0_In, Addr_Valid_1_In, Addr_Valid_0_In,
                            Comm_0_In, Comm_1_In, Empty_0_In, Empty_1_In,
                            One_Data_Left_0_In, One_Data_Left_1_In,
                            Last_Addr_Reg_0, Last_Addr_Reg_1, Read_Enable_In)
  begin  -- process Assign_Outputs

      case State_Reg is

        when 0                         =>
          -- Ei ole tehty mitaan
          Data_Out          <= (others => '0'); --  'Z'); -- '0');
          Comm_Out          <= (others => '0'); -- 'Z'); -- '0');
          Addr_Valid_Out    <= '0';
          Empty_Out         <= '1';
          RE_0_Out          <= '0';
          RE_1_Out          <= '0';


          
        when 1 =>
          -- Siirretaan osoite 0
          
          -- joko rekisterista (sama osoite kuin viimeksikin)
          -- tai suoraan fifosta (uusi osoite, otetaan se myos talteen)
          if Addr_Valid_0_In = '1' then
            -- Uusi osoite
            Data_Out        <= Data_0_In;
            Comm_Out        <= Comm_0_In;
            RE_0_Out        <= Read_Enable_In;
          else
            Data_Out        <= Last_Addr_Reg_0 (Data_Width-1 downto 0);
            Comm_Out        <= Last_Addr_Reg_0 ( Comm_Width+Data_Width-1 downto Data_Width);
            RE_0_Out        <= '0';

          end if;
          Addr_Valid_Out    <= '1';
          Empty_Out         <= '0';
          RE_1_Out          <= '0';



        when 2 =>
          -- Siirretaan data fifosta 0

          if Addr_Valid_0_In = '1' and One_Data_Left_0_In = '1' then
            -- Fifossa 0 pelkka osoite

            if Empty_1_In = '1'
              or (Addr_Valid_1_In = '1' and One_Data_Left_1_In = '1') then
              -- Fifo 1 tyhja tai siella pelkka osoite
              RE_0_Out          <= '0';
              RE_1_Out          <= '0';              
              Data_Out          <= (others => '0'); -- 'X');
              Comm_Out          <= (others => '0'); -- 'X');
              Addr_Valid_Out    <= '0';
              Empty_Out         <= '1';
            else
              -- Fifossa 1 olisi jotain, otetaan varman paalle
              RE_0_Out          <= '0';
              RE_1_Out          <= '0';              
              Data_Out          <= (others => '0'); -- '-');
              Comm_Out          <= (others => '0'); -- '-');
              Addr_Valid_Out    <= '0';
              Empty_Out         <= '1';
            end if;                     --e_1 || (av1&1left1)            
          else
            -- Fifossa 0 osoite+jotain tai dataa
            RE_0_Out          <= Read_Enable_In;
            RE_1_Out          <= '0';
          
            Data_Out          <= Data_0_In;
            Comm_Out          <= Comm_0_In;
            Addr_Valid_Out    <= Addr_Valid_0_In;
            Empty_Out         <= Empty_0_In;            
          end if;                       --av_1


          

        when 3                      =>
          -- Siirretaan osoite 1

          if Addr_Valid_1_In = '1' then
            -- Uusi osoite
            Data_Out        <= Data_1_In;
            Comm_Out        <= Comm_1_In;
            RE_1_Out        <= Read_Enable_In;
          else
            Data_Out        <= Last_Addr_Reg_1 (Data_Width-1 downto 0);
            Comm_Out        <= Last_Addr_Reg_1 ( Comm_Width+Data_Width-1 downto Data_Width);
            RE_1_Out        <= '0';
          end if;
          RE_0_Out          <= '0';
          Addr_Valid_Out    <= '1';
          Empty_Out         <= '0';




        when 4 =>
          -- Siirretaan fifosta 1


          if Addr_Valid_1_In = '1' and One_Data_Left_1_In = '1' then
            -- Fifossa 1 pelkka osoite

            if Empty_0_In = '1'
              or (Addr_Valid_0_In = '1' and One_Data_Left_0_In = '1') then
              -- Fifo 0 tyhja tai siella pelkka osoite
              RE_0_Out          <= '0';
              RE_1_Out          <= '0';              
              Data_Out          <= (others => '0'); -- 'X');
              Comm_Out          <= (others => '0'); -- 'X');
              Addr_Valid_Out    <= '0';
              Empty_Out         <= '1';
            else
              -- Fifossa 0 olisi jotain, otetaan varman paalle
              RE_0_Out          <= '0';
              RE_1_Out          <= '0';              
              Data_Out          <= (others => '0'); -- '-');
              Comm_Out          <= (others => '0'); -- '-');
              Addr_Valid_Out    <= '0';
              Empty_Out         <= '1';
            end if;                     --e_0 || (av0&1left0)            
          else
            -- Fifossa 1 osoite+jotain tai dataa
            RE_0_Out          <= '0';
            RE_1_Out          <= Read_Enable_In;
          
            Data_Out          <= Data_1_In;
            Comm_Out          <= Comm_1_In;
            Addr_Valid_Out    <= Addr_Valid_1_In;
            Empty_Out         <= Empty_1_In;            
          end if;                       --av_1
          
          
          
        when 5                         =>
          -- Molemmat fifot tyhjia
          RE_0_Out          <= '0';
          RE_1_Out          <= '0';
          Data_Out          <= (others => '0'); -- 'Z');  -- '0');
          Comm_Out          <= (others => '0'); -- 'Z');  -- '0');
          Addr_Valid_Out    <= '0';
          Empty_Out         <= '1';

        when others                    =>
          RE_0_Out          <= '0';
          RE_1_Out          <= '0';
          Data_Out          <= (others => '0'); -- 'Z');  -- '0');
          Comm_Out          <= (others => '0'); -- 'Z');  -- '0');
          Addr_Valid_Out    <= '0';
          Empty_Out         <= '1';
          assert false report "Illegal state in fifo_mux_read" severity warning;
      end case;

  end process Assign_Outputs;




  -- PROC
  Reg_proc : process (Clk, Rst_n)
  begin  -- process Reg_proc
    if Rst_n = '0' then                 -- asynchronous reset (active low)
      State_Reg       <= 5;      
      Last_Addr_Reg_0 <= (others => '0'); -- '0');
      Last_Addr_Reg_1 <= (others => '0'); -- 'Z'); -- '0');
      
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      case State_Reg is

        when 0 =>
--           -- Ei ole tehty mitaan



          
        when 1 =>
          -- Siirretaan osoite 0
          -- joko rekisterista (sama osoite kuin viimeksikin)
          -- tai suoraan fifosta (uusi osoite, otetaan se myos talteen)
          if Read_Enable_In = '1' then
            State_Reg <= 2;
          else
            State_Reg <= 1;
          end if;

          if Addr_Valid_0_In = '1' then
            -- Uusi osoite
            Last_Addr_Reg_0 <= Comm_0_In & Data_0_In;
          else
            Last_Addr_Reg_0 <= Last_Addr_Reg_0;
          end if;
          
          

        when 2 =>
          -- Siirretaan fifosta 0
          
          if Read_Enable_In = '1' then
            -- Luetaan fifosta 0
            
            if One_Data_Left_0_In = '1' then             
              -- Oli viim data fifossa 0
              if Empty_1_In = '1'
              or (Addr_Valid_1_In = '1' and One_Data_Left_1_In = '1') then
                -- Myos fifo 1 tyhja tai siella pelkka osoite
                State_Reg <= 5;
              else
                -- Siirretaan osoite 1 (fifosta tai rekisterista)
                State_Reg <= 3;
              end if;                   --Empty_1_In
              Last_Addr_Reg_0 <= Last_Addr_Reg_0;
              Last_Addr_Reg_1 <= Last_Addr_Reg_1;
              
            else
              -- Fifossa 0 lukemisen jalkeenkin viela jotain
              State_Reg       <= 2;
              Last_Addr_Reg_1 <= Last_Addr_Reg_1;

              if Addr_Valid_0_In = '1' then
                -- fifosta 0 luettiin osoite
                Last_Addr_Reg_0 <= Comm_0_In & Data_0_In;
              else
                -- Fifosta 0 luettiin dataa
                Last_Addr_Reg_0 <= Last_Addr_Reg_0;
              end if;  --Addr_Valid_0_In
            end if;  --Empty_0_In




          else
            -- Odotellaan etta data luetaan
            State_Reg       <= 2;
            Last_Addr_Reg_0 <= Last_Addr_Reg_0;
            Last_Addr_Reg_1 <= Last_Addr_Reg_1;
          end if;  --Read_Enable_In





          

        when 3 =>
          -- Siirretaan osoite 1
          if Read_Enable_In = '1' then
              State_Reg <= 4;              
          else
            -- Odotellaan lukua
            State_Reg <= 3;
          end if;

          if Addr_Valid_1_In = '1' then
            -- Uusi osoite
            Last_Addr_Reg_1 <= Comm_1_In & Data_1_In;
          else
            Last_Addr_Reg_1 <= Last_Addr_Reg_1;
          end if;
          

          
        when 4 =>
          -- Siirretaan fifosta 1

          if Read_Enable_In = '1' then
            -- Luetaan fifoa 1

            if Addr_Valid_1_In = '1' then
              -- Luetaan osoite fifosta 1
              Last_Addr_Reg_0 <= Last_Addr_Reg_0;              
              Last_Addr_Reg_1 <= Comm_1_In & Data_1_In;

              if One_Data_Left_1_In = '1' then
                -- fifossa oli pelkka osoite
                -- puolittainen VIRHE?
                assert false report "Was? 1" severity note;
                State_Reg <= 5;
              else
                -- Fifossa 1 on myos dataa, luetaan se 
                -- ennen (mahdollista) siirtymista
                -- fifon 1 lukemiseen
                State_Reg <= 4;
              end if;  --One_Data_Left_1_In

            else
              -- Luetaan data fifosta 1
              
              if Empty_0_In = '1'
                or (Addr_Valid_0_In = '1' and One_Data_Left_0_In = '1') then
                -- Fifo 0 tyhja tai siella pelkka osoite

                if One_Data_Left_1_In = '0' then
                  -- Onneksi fifossa 1 on viela jotain
                  State_Reg <= 4;
                else
                  -- Ei ole siis kummassakaan fifossa mit'n
                  State_Reg <= 5;
                end if;  -- One_Data_Left_1_In


              else
                -- fifossa 0 luettavaa
                -- siirretann siis osoite 1 seuraavaksi (fifosta/rekisterista)
                State_Reg       <= 1;
                Last_Addr_Reg_0 <= Last_Addr_Reg_0;
                Last_Addr_Reg_1 <= Last_Addr_Reg_1;
              end if;  --Empty_0_In or (av0 & 1left_0)
            end if;  --Addr_Valid_0_In


          else
            -- Odotetaan etta luetaan fifoa 1
            --State_Reg       <= 4;
            Last_Addr_Reg_0 <= Last_Addr_Reg_0;
            Last_Addr_Reg_1 <= Last_Addr_Reg_1;

            if Addr_Valid_1_In = '1' and One_Data_Left_1_In ='1' then
              -- Ei olekaan kuin pelkka osoite fifossa #1!
              if Empty_0_In = '1'
                or (Addr_Valid_0_In = '1' and One_Data_Left_0_In ='1') then
                -- Ei ole fifossa 0 :kaan mitaan jarkevaa
                State_Reg <= 5;
              else
                -- Voidaan siirtaa osoite 0 seuraavaksi
                State_Reg <= 1;
              end if;
            else
              -- fifossa 1 on myos dataa, odotellaan lukemista
              State_Reg <= 4;
            end if;


            
          end if;  --Read_Enable_In


          

        when 5 =>
          -- Ei voitu lukea kummastakaan fifosta
          
          Last_Addr_Reg_0 <= Last_Addr_Reg_0;
          Last_Addr_Reg_1 <= Last_Addr_Reg_1;


          if Empty_0_In = '1' or ( Addr_Valid_0_In = '1' and One_Data_Left_0_In ='1') then
            -- Fifo 0 tyhja tai siella pelkka osoite
            if Empty_1_In = '1' or ( Addr_Valid_1_In = '1' and One_Data_Left_1_In ='1') then
              -- Fifo 1 tyhja tai siella pelkka osoite
              -- => KUmmastakaan ei voi lukea
              State_Reg       <= 5;
            else
              -- Fifossa 1 jotain
              -- siirretann siis osoite 1 seuraavaksi (fifosta/rekisterista)
              State_Reg <= 3;
            end if;--Empty_0_In or (av0 & 1left_0)
            
          else
            -- Fifossa 0 jotain
            -- siirretann siis osoite 0 seuraavaksi (fifosta/rekisterista)
            State_Reg <= 1;
          end if; --Empty_0_In or (av0 & 1left_0)





          
          
        when others =>
          assert false report "Illegal state in fifo_mux_read" severity warning;
      end case;

      
    end if;
  end process Reg_proc;


  -- One_Data_Left_Out on sen verta vaikea, etta tehdaan se omassa prosessissaan
  Assign_1_D_Left_Out : process (State_Reg,
                                 Data_0_In,         Data_1_In,
                                 Comm_0_In,         Comm_1_In,
                                 Empty_0_In,        Empty_1_In,
                                 Addr_Valid_0_In,   Addr_Valid_1_In,
                                 One_Data_Left_0_In,One_Data_Left_1_In,
                                 Last_Addr_Reg_0,   Last_Addr_Reg_1,
                                 Read_Enable_In)
  begin  -- process Assign_1_D_Left_Out
      case State_Reg is

        when 0                         =>
          -- Ei ole tehty mitaan
          One_Data_Left_Out <= '0';
          
        when 1 =>
          -- Siirretaan osoite 0
          -- ellei ihmeita tapahdu, One_Data_Left_Out pitaisi olla 0!

          if Addr_Valid_0_In = '1' then
            --Olisi syyta olla dataakin fifossa 0, toivotaan
            One_Data_Left_Out <= '0';
          else
            -- Sama osoite kuin viimeksi (rekisterista)
            if Empty_0_In = '1' then
              -- Fifossa 0 tyhja
              assert false report
                "Retrsnferring addr#0, but fifo#0 is empty. ERROR?" severity warning;

              
              if Empty_1_In = '1'
              or (Addr_Valid_1_In = '1' and One_Data_Left_1_In = '1') then
                -- ja fifo 1:kin on tyhja, tai siina on pelkka osoite
                One_Data_Left_Out <= '1';
              else
                -- Voidaan siirtya lukemaan fifoa 1
                One_Data_Left_Out <= '0';
              end if;  -- Empty_1_In || (av1 &1d_Left1)
            else
              One_Data_Left_Out <= '0';
            end if;  -- Empty_0_In

          end if;  -- Addr_Valid_0 




        when 2 =>
          -- Siirretaan data fifosta 0

          if One_Data_Left_0_In = '1' then
            -- Fifo 0 tyhjenee

            if Empty_1_In = '1' then
              -- ja fifo 1:kin on tyhja
              One_Data_Left_Out <= '1';
            else
              if Addr_Valid_1_In = '1' and One_Data_Left_1_In = '1' then
                -- Fifossa 1 pelkka osoite
                One_Data_Left_Out <= '1';
              else
                -- Voidaan siirtya lukemaan fifoa 1
                One_Data_Left_Out <= '0';
              end if;  --AV1 & 1D_Left1
            end if;  -- Empty_1_In            
          else
            -- Fifoon 0 jaa jotain
            One_Data_Left_Out <= '0';            
          end if;                       --One_Data_Left_0_In

          

        when 3                      =>
          -- Siirretaan osoite 1
          -- ellei ihmeita tapahdu, One_Data_Left_Out pitaisi olla 0!
          
          if Addr_Valid_1_In = '1' then
            --Olisi syyta olla dataakin fifossa 1, toivotaan
            One_Data_Left_Out <= '0';
          else
            -- Sama osoite kuin viimeksi (rekisterista)

            if Empty_1_In = '1' then
              -- Fifo 1 on tyhja
              assert false report
                "Retrsnferring addr#1, but fifo#1 is empty. ERROR?" severity warning;

              if Empty_0_In = '1'
                or (Addr_Valid_0_In = '1' and One_Data_Left_0_In = '1' )then
                -- ja fifo 0:kin on tyhja
                One_Data_Left_Out <= '1';
              else
                -- Voidaan siirtya lukemaan fifoa 0
                One_Data_Left_Out <= '0';
              end if;  -- Empty_1_In & (AV1 & 1D_Left1)
                       -- 
            else
              One_Data_Left_Out <= '0';
            end if;  --Empty_Left_1_In
          end if;  -- Addr_Valid_1






        when 4 =>
          -- Siirretaan data 1
          
          if One_Data_Left_1_In = '1' then
            -- fifo 1 tyhjenee
            
            if Empty_0_In = '1'
              or (Addr_Valid_0_In = '1' and One_Data_Left_0_In = '1') then
              -- Fifo 0:kin on tyhja tai siella pelkka osoite
              One_Data_Left_Out <= '1';
            else
              -- Voidaan siirtya lukemaan fifoa 0
              One_Data_Left_Out <= '0';
            end if;                     --Empty_0_In & (av0 & 1_D_Left0)

          else
            -- Fifoon 1 jaa jotain
            One_Data_Left_Out <= '0';
          end if;                       --One_Data_Left_1_In


          
        when 5                         =>
          -- Molemmat fifot tyhjia
          One_Data_Left_Out <= '0';


        when others                    =>
          One_Data_Left_Out <= '0';
          assert false report "Illegal state in fifo_mux_read" severity warning;
      end case;
  end process Assign_1_D_Left_Out;






end rtl;








