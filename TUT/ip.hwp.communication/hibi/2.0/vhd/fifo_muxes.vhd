-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- File        : fifo_muxes.vhdl
-- Description : Makes two fifos look like a single fifo.
--               Two components : one for writing and one for reading fifo.
--
--               Write_demux:
--               Input : data, addr valid and command 
--               Out   : data, addr valid and command to two fifos
--
--               Read_mux :
--               Input : data, addr valid and command from two fifos
--               Out   : data, addr valid and command
--
--              NOTE:
--              1) Fifo_mux_read does not fully support One_Data_Left_Out!
--
--              It works when writing to fifo. However, when something
--              is written to empty fifo, One_Data_Left_Out remains 0
--              even if Empty goes from 1 to 0! Be careful out there.
--
--              Case when new addr is written to fifo 0 and there is a gap before
--              corresponding data. At the same time there is some data in fifo
--              #1. It is not wise to wait for data#0, because it blocks the data#1.
--              In such case, transfer from fifo#0 is interrupted (Empty goes high).
--              At the moment, One_Data_Left_Out does not work in such case.
--              (Probably it could be repaired with fifo_bookkeeper component?)
--
--              2) Fifo_demux_write does not fully support One_Place_Left_Out!
--
--              When nothing is written to fifo, demux does not know which one-place
--              to select for output. When writing begins, it is possible that
--              target fifo becomes immediately full. The writer has no warning
--              of this event because one_place_left was zero before writing.
--              Same may happen when target fifo changes, e.g. data to msg
--              without interruption
--              Try-out : OR one-place_left signals together when command is IDLE
--              Caution : May prevent writing to one fifo if the other fifo is
--              is geting full.
--
--              
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : Mikälie
-- Design      : Do not use term design when you mean system
-- Date        : 05.02.2003
-- Modified    : 
-- 18.09.03     ES generic Comb_delayG added to avoid zero delay oscillation in
--                 simulation
--
--              AK When no comm, full-signal is OR-red in write-demux
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.hibiv2_pkg.all; 





-- Write_Mux checks the incoming addr. Same addr is not
-- written to fifo more than once! Written fifo is selected
-- according to incoming command
-- 13.04 Fully asynchronous!
entity fifo_demux_wr is

  generic (
--    comb_delay_g :     time    := 1 ns;  -- 18.09.03
    data_width_g :     integer := 0;
    comm_width_g :     integer := 0
    );
  port (
    data_in      : in  std_logic_vector (data_width_g-1 downto 0);
    av_in        : in  std_logic;
    comm_in      : in  std_logic_vector (comm_width_g-1 downto 0);
    we_in        : in  std_logic;
    full_out     : out std_logic;
    one_p_out    : out std_logic;

    -- Data/Comm/AV conencted to both fifos
    -- Distinction made with WE!
    data_out   : out std_logic_vector ( data_width_g-1 downto 0);
    comm_out   : out std_logic_vector ( comm_width_g-1 downto 0);
    av_out     : out std_logic;
    we_0_out   : out std_logic;
    we_1_out   : out std_logic;
    full_0_in  : in  std_logic;
    full_1_in  : in  std_logic;
    one_p_0_in : in  std_logic;
    one_p_1_in : in  std_logic
    );

end fifo_demux_wr;





architecture rtl of fifo_demux_wr is

  -- Selects if debug prints are used (1-3) or not ('0')
  constant dbg_level : integer range 0 to 3 := 0;  -- 0= no debug, use 0 for synthesis

  -- Registers may be reset to 'Z' to 'X' so that reset state is clearly
  -- distinguished from active state. Using value of rst_value_arr array(dbg_level),
  -- the rst value may be easily set to '0' for synthesis.
  constant rst_value_arr : std_logic_vector ( 6 downto 0) := 'X' & 'Z' & 'X' & 'Z' & 'X' & 'Z' & '0';


begin  -- rtl


  -- Concurrent assignments
  av_out   <= av_in;
  data_out <= data_in;
  comm_out <= comm_in;

  
  -- COMB PROC
  -- Fully combinational
  Demultiplex_data : process (-- data_in,
                              -- av_in,
                              comm_in, we_in,
                              one_p_0_in, one_p_1_in,
                              full_0_in, full_1_in)
  begin  -- process Demultiplex_data

   

    if comm_in = conv_std_logic_vector (3, comm_width_g)
      or comm_in = conv_std_logic_vector (7, comm_width_g) then
      -- MESSAGE
      we_0_out  <= we_in;--     after comb_delay_g;
      we_1_out  <= '0';
      full_out  <= full_0_in;-- after comb_delay_g;
      one_p_out <= one_p_0_in;

    elsif comm_in = conv_std_logic_vector (2, comm_width_g)
      or comm_in = conv_std_logic_vector (4, comm_width_g)
      or comm_in = conv_std_logic_vector (6, comm_width_g) then
      -- DATA
      we_0_out  <= '0';
      we_1_out  <= we_in;--     after comb_delay_g;
      full_out  <= full_1_in;-- after comb_delay_g;
      one_p_out <= one_p_1_in;

    elsif comm_in = conv_std_logic_vector (1, comm_width_g)
      or comm_in = conv_std_logic_vector (5, comm_width_g) then
      -- CONFIG
      assert false report "Config comm to fifo_demux_wr" severity warning;
      we_0_out  <= '0';
      we_1_out  <= '0';
      full_out  <= '0';
      one_p_out <= '0';

    else
      --IDLE
      we_0_out  <= '0';
      we_1_out  <= '0';
      full_out  <= full_1_in or full_0_in; -- 18.03.05 0'
      one_p_out <= one_p_0_in or one_p_1_in;  -- 24.07 '0';
    end if;
  end process Demultiplex_data;


      
end rtl;                                --fifo_demux_wr






-------------------------------------------------------------------------------
--entity fifo_mux_read kaytetaan lukemaan kahdesta fifosta osoite ja data perakkain
-- fifolla 0 on suurempi prioritetti. Jos ollaan lukemassa fifoa 1, ei ruveta
-- lukemaan fifoa 0 ennekuin on siirretty ainakin yksi data fifosta 1.
-- File        : fifo_muxes.vhdl
-- Description : Makes two fifos look like a single fifo for the reader
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : Mikälie
-- Project     : Mikälie
-- Date        : 05.02.2003
-- Modified    : 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;





entity fifo_mux_rd is

  generic (
    data_width_g :     integer := 0;
    comm_width_g :     integer := 0
    );
  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    
    data_0_in    : in  std_logic_vector ( data_width_g-1 downto 0);
    comm_0_in    : in  std_logic_vector ( comm_width_g-1 downto 0);
    av_0_in      : in  std_logic;
    one_d_0_in   : in  std_logic;
    empty_0_in   : in  std_logic;
    re_0_Out     : out std_logic;

    data_1_in    : in  std_logic_vector ( data_width_g-1 downto 0);
    comm_1_in    : in  std_logic_vector ( comm_width_g-1 downto 0);
    av_1_in      : in  std_logic;
    one_d_1_in   : in  std_logic;
    empty_1_in   : in  std_logic;
    re_1_Out     : out std_logic;

    re_in        : in  std_logic;
    data_out     : out std_logic_vector ( data_width_g-1 downto 0);
    comm_out     : out std_logic_vector ( comm_width_g-1 downto 0);
    av_out       : out std_logic;
    one_d_Out    : out std_logic;
    empty_Out    : out std_logic
    );

end fifo_mux_rd;


architecture rtl of fifo_mux_rd is


  -- Selects if debug prints are used (1-3) or not ('0')
  constant dbg_level : integer range 0 to 3 := 0;  -- 0= no debug, use 0 for synthesis

  -- Registers may be reset to 'Z' to 'X' so that reset state is clearly
  -- distinguished from active state. Using dbg_level+rst_value_arr array, the rst value may
  -- be easily set to '0' for synthesis.
  constant rst_value_arr : std_logic_vector ( 6 downto 0) := 'X' & 'Z' & 'X' & 'Z' & 'X' & 'Z' & '0';

  type addr_comm_type is record
                           addr : std_logic_vector ( data_width_g -1 downto 0);
                           comm : std_logic_vector ( comm_width_g -1 downto 0);
                         end record;

  signal last_addr_0_r : addr_comm_type;
  signal last_addr_1_r : addr_comm_type;
  

  signal curr_state_r : integer range 0 to 5;
  -- Transferred_Reg - siirron tila
  -- 00) Ei ole siirretty viela mitaan, saman tien pois. Alkutila ilman resettia.
  -- 01) Osoite fifossa 0
  -- 02) data   fifossa 0
  -- 03) Osoite fifosta 1
  -- 04) data   fifosta 1
  -- 05) molemmat fifot tyhjia. Alkutila resetissa.
  
  -- Tilasiirtymat
  -- 00 -> 05
  -- 01 -> 02
  -- 02 -> 01, 02, 03
  -- 03 -> 04
  -- 04 -> 01, 04, 05
  -- 05 -> 01, 03
  
begin  -- rtl



  -- COMB PROC
  Assign_Outputs : process (curr_state_r,
                            av_1_in, av_0_in,
                            data_1_in, data_0_in,
                            comm_1_in, comm_0_in, 
                            empty_1_in, empty_0_in, 
                            one_d_1_in, one_d_0_in, 
                            Last_Addr_0_r, Last_Addr_1_r,
                            re_in
                            )
  begin  -- process Assign_Outputs

      case curr_state_r is

        when 0                 =>
          -- Ei ole tehty mitaan
          data_out  <= (others => rst_value_arr (dbg_level *1));
          comm_out  <= (others => rst_value_arr (dbg_level *1));
          av_out    <= '0';
          empty_Out <= '1';
          re_0_Out  <= '0';
          re_1_Out  <= '0';


          
        when 1 =>
          -- Osoite fifossa 0
          -- Siirretaan osoite 0

          -- joko rekisterista (sama osoite kuin viimeksikin)
          -- tai suoraan fifosta (uusi osoite, otetaan se myos talteen)
          if av_0_in = '1' then
            -- Uusi osoite
            data_out <= data_0_in;
            comm_out <= comm_0_in;
            re_0_Out <= re_in;
          else
            data_out <= Last_Addr_0_r.addr;
            comm_out <= Last_Addr_0_r.comm;
            re_0_Out <= '0';

          end if;
          av_out    <= '1';
          empty_Out         <= '0';
          re_1_Out          <= '0';



        when 2 =>
          -- data fifossa 0
          -- Siirretaan data fifosta 0

          if av_0_in = '1' and one_d_0_in = '1' then
            -- Fifossa 0 pelkka osoite

            if empty_1_in = '1'
              or (av_1_in = '1' and one_d_1_in = '1') then
              -- Fifo 1 tyhja tai siella pelkka osoite
              re_0_Out  <= '0';
              re_1_Out  <= '0';
              data_out  <= (others => rst_value_arr (dbg_level *2));
              comm_out  <= (others => rst_value_arr (dbg_level *2));
              av_out    <= '0';
              empty_Out <= '1';
            else
              -- Fifossa 1 olisi jotain, otetaan varman paalle
              re_0_Out  <= '0';
              re_1_Out  <= '0';
              data_out  <= (others => rst_value_arr (dbg_level *2));
              comm_out  <= (others => rst_value_arr (dbg_level *2));
              av_out    <= '0';
              empty_Out <= '1';
            end if;  --e_1 || (av1&1left1)            
          else
            -- Fifossa 0 osoite+jotain tai dataa
            re_0_Out    <= re_in;
            re_1_Out    <= '0';

            data_out  <= data_0_in;
            comm_out  <= comm_0_in;
            av_out    <= av_0_in;
            empty_Out <= empty_0_in;
          end if;  --av_1


          

        when 3                      =>
          -- Osoite fifossa 1
          -- Siirretaan osoite 1

          if av_1_in = '1' then
            -- Uusi osoite
            data_out <= data_1_in;
            comm_out <= comm_1_in;
            re_1_Out <= re_in;
          else
            data_out <= Last_Addr_1_r.addr;
            comm_out <= Last_Addr_1_r.comm;
            re_1_Out <= '0';
          end if;
          re_0_Out   <= '0';
          av_out     <= '1';
          empty_Out  <= '0';




        when 4 =>
          -- data fifossa 1
          -- Siirretaan fifosta 1


          if av_1_in = '1' and one_d_1_in = '1' then
            -- Fifossa 1 pelkka osoite

            if empty_0_in = '1'
              or (av_0_in = '1' and one_d_0_in = '1') then
              -- Fifo 0 tyhja tai siella pelkka osoite
              re_0_Out  <= '0';
              re_1_Out  <= '0';
              data_out  <= (others => rst_value_arr (dbg_level *2));
              comm_out  <= (others => rst_value_arr (dbg_level *2));
              av_out    <= '0';
              empty_Out <= '1';
            else
              -- Fifossa 0 olisi jotain, otetaan varman paalle
              re_0_Out  <= '0';
              re_1_Out  <= '0';
              data_out  <= (others => rst_value_arr (dbg_level *2));
              comm_out  <= (others => rst_value_arr (dbg_level *2));
              av_out    <= '0';
              empty_Out <= '1';
            end if;  --e_0 || (av0&1left0)            
          else
            -- Fifossa 1 osoite+jotain tai dataa
            re_0_Out    <= '0';
            re_1_Out    <= re_in;

            data_out  <= data_1_in;
            comm_out  <= comm_1_in;
            av_out    <= av_1_in;
            empty_Out <= empty_1_in;
          end if;  --av_1

          

        when 5                 =>
          -- Molemmat fifot tyhjia
          re_0_Out  <= '0';
          re_1_Out  <= '0';
          data_out  <= (others => rst_value_arr (dbg_level *1));
          comm_out  <= (others => rst_value_arr (dbg_level *1));
          av_out    <= '0';
          empty_Out <= '1';

        when others            =>
          re_0_Out  <= '0';
          re_1_Out  <= '0';
          data_out  <= (others => rst_value_arr (dbg_level));
          comm_out  <= (others => rst_value_arr (dbg_level));
          av_out    <= '0';
          empty_Out <= '1';
          assert false report "Illegal state in fifo_mux_rd" severity warning;
      end case;

  end process Assign_Outputs;




  -- SEQ PROC
  Reg_proc : process (clk, rst_n)
  begin  -- process Reg_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      curr_state_r       <= 5;
      Last_Addr_0_r.addr <= (others => rst_value_arr (dbg_level));
      Last_Addr_0_r.comm <= (others => rst_value_arr (dbg_level));
      Last_Addr_1_r.addr <= (others => rst_value_arr (dbg_level));
      Last_Addr_1_r.comm <= (others => rst_value_arr (dbg_level));

    elsif clk'event and clk = '1' then  -- rising clock edge
      case curr_state_r is

        when 0 =>
          --           -- Ei ole tehty mitaan
          -- Tassa tilassa ei kauaa viihdy.
          curr_state_r <= 5;


          
        when 1 =>
          -- Siirretaan osoite 0
          -- joko rekisterista (sama osoite kuin viimeksikin)
          -- tai suoraan fifosta (uusi osoite, otetaan se myos talteen)
          if re_in = '1' then
            curr_state_r <= 2;
          else
            curr_state_r <= 1;
          end if;

          if av_0_in = '1' then
            -- Uusi osoite
            Last_Addr_0_r.addr <= data_0_in;
            Last_Addr_0_r.comm <= comm_0_in;
          else
            Last_Addr_0_r      <= Last_Addr_0_r;
          end if;

          

        when 2 =>
          -- Siirretaan fifosta 0
          
          if re_in = '1' then
            -- Luetaan fifosta 0
            
            if one_d_0_in = '1' then             
              -- Oli viim data fifossa 0
              if empty_1_in = '1'
              or (av_1_in = '1' and one_d_1_in = '1') then
                -- Myos fifo 1 tyhja tai siella pelkka osoite
                curr_state_r <= 5;
              else
                -- Siirretaan osoite 1 (fifosta tai rekisterista)
                curr_state_r <= 3;
              end if;                   --empty_1_in
              Last_Addr_0_r <= Last_Addr_0_r;
              Last_Addr_1_r <= Last_Addr_1_r;
              
            else
              -- Fifossa 0 lukemisen jalkeenkin viela jotain
              curr_state_r       <= 2;
              Last_Addr_1_r <= Last_Addr_1_r;

              if av_0_in = '1' then
                -- fifosta 0 luettiin osoite
                Last_Addr_0_r.addr <= data_0_in;
                Last_Addr_0_r.comm <= comm_0_in;
              else
                -- Fifosta 0 luettiin dataa
                Last_Addr_0_r      <= Last_Addr_0_r;
              end if;  --av_0_in
            end if;  --empty_0_in




          else
            -- Odotellaan etta data luetaan
            curr_state_r       <= 2;
            Last_Addr_0_r <= Last_Addr_0_r;
            Last_Addr_1_r <= Last_Addr_1_r;
          end if;  --re_in





          

        when 3 =>
          -- Siirretaan osoite 1
          if re_in = '1' then
              curr_state_r <= 4;              
          else
            -- Odotellaan lukua
            curr_state_r <= 3;
          end if;

          if av_1_in = '1' then
            -- Uusi osoite
            Last_Addr_1_r.addr <= data_1_in;
            Last_Addr_1_r.comm <= comm_1_in;
          else
            Last_Addr_1_r <= Last_Addr_1_r;
          end if;
          

          
        when 4 =>
          -- Siirretaan fifosta 1

          if re_in = '1' then
            -- Luetaan fifoa 1

            if av_1_in = '1' then
              -- Luetaan osoite fifosta 1
              Last_Addr_0_r      <= Last_Addr_0_r;
              Last_Addr_1_r.addr <= data_1_in;
              Last_Addr_1_r.comm <= comm_1_in;

              if one_d_1_in = '1' then
                -- fifossa oli pelkka osoite
                -- puolittainen VIRHE?
                --assert false report "Was? 1" severity note;
                curr_state_r <= 5;
              else
                -- Fifossa 1 on myos dataa, luetaan se 
                -- ennen (mahdollista) siirtymista
                -- fifon 1 lukemiseen
                curr_state_r <= 4;
              end if;  --one_d_1_in

            else
              -- Luetaan data fifosta 1
              
              if empty_0_in = '1'
                or (av_0_in = '1' and one_d_0_in = '1') then
                -- Fifo 0 tyhja tai siella pelkka osoite

                if one_d_1_in = '0' then
                  -- Onneksi fifossa 1 on viela jotain
                  curr_state_r <= 4;
                else
                  -- Ei ole siis kummassakaan fifossa mit'n
                  curr_state_r <= 5;
                end if;  -- one_d_1_in


              else
                -- fifossa 0 luettavaa
                -- siirretann siis osoite 1 seuraavaksi (fifosta/rekisterista)
                curr_state_r       <= 1;
                Last_Addr_0_r <= Last_Addr_0_r;
                Last_Addr_1_r <= Last_Addr_1_r;
              end if;  --empty_0_in or (av0 & 1left_0)
            end if;  --av_0_in


          else
            -- Odotetaan etta luetaan fifoa 1
            --curr_state_r       <= 4;
            Last_Addr_0_r <= Last_Addr_0_r;
            Last_Addr_1_r <= Last_Addr_1_r;

            if av_1_in = '1' and one_d_1_in ='1' then
              -- Ei olekaan kuin pelkka osoite fifossa #1!
              if empty_0_in = '1'
                or (av_0_in = '1' and one_d_0_in ='1') then
                -- Ei ole fifossa 0 :kaan mitaan jarkevaa
                curr_state_r <= 5;
              else
                -- Voidaan siirtaa osoite 0 seuraavaksi
                curr_state_r <= 1;
              end if;
            else
              -- fifossa 1 on myos dataa, odotellaan lukemista
              curr_state_r <= 4;
            end if;


            
          end if;  --re_in


          

        when 5 =>
          -- Ei voitu lukea kummastakaan fifosta
          
          Last_Addr_0_r <= Last_Addr_0_r;
          Last_Addr_1_r <= Last_Addr_1_r;


          if empty_0_in = '1' or ( av_0_in = '1' and one_d_0_in ='1') then
            -- Fifo 0 tyhja tai siella pelkka osoite
            if empty_1_in = '1' or ( av_1_in = '1' and one_d_1_in ='1') then
              -- Fifo 1 tyhja tai siella pelkka osoite
              -- => KUmmastakaan ei voi lukea
              curr_state_r       <= 5;
            else
              -- Fifossa 1 jotain
              -- siirretann siis osoite 1 seuraavaksi (fifosta/rekisterista)
              curr_state_r <= 3;
            end if;--empty_0_in or (av0 & 1left_0)
            
          else
            -- Fifossa 0 jotain
            -- siirretann siis osoite 0 seuraavaksi (fifosta/rekisterista)
            curr_state_r <= 1;
          end if; --empty_0_in or (av0 & 1left_0)





          
          
        when others =>
          assert false report "Illegal state in fifo_mux_rd" severity warning;
      end case;

      
    end if;
  end process Reg_proc;


  -- one_d_Out on sen verta vaikea, etta tehdaan se omassa prosessissaan
  Assign_1_D_Left_Out : process (curr_state_r,
                                 -- data_0_in,     data_1_in,
                                 -- comm_0_in,     comm_1_in,
                                 empty_0_in,    empty_1_in,
                                 av_0_in,       av_1_in,
                                 one_d_0_in,    one_d_1_in--,
                                 -- Last_Addr_0_r, Last_Addr_1_r,
                                 -- re_in
                                 )
  begin  -- process Assign_1_D_Left_Out
      case curr_state_r is

        when 0                         =>
          -- Ei ole tehty mitaan
          one_d_Out <= '0';
          
        when 1 =>
          -- Siirretaan osoite 0
          -- ellei ihmeita tapahdu, one_d_Out pitaisi olla 0!

          if av_0_in = '1' then
            --Olisi syyta olla dataakin fifossa 0, toivotaan
            one_d_Out <= '0';
          else
            -- Sama osoite kuin viimeksi (rekisterista)
            if empty_0_in = '1' then
              -- Fifossa 0 tyhja
              assert false report
                "Retrsnferring addr#0, but fifo#0 is empty. ERROR?" severity warning;

              
              if empty_1_in = '1'
              or (av_1_in = '1' and one_d_1_in = '1') then
                -- ja fifo 1:kin on tyhja, tai siina on pelkka osoite
                one_d_Out <= '1';
              else
                -- Voidaan siirtya lukemaan fifoa 1
                one_d_Out <= '0';
              end if;  -- empty_1_in || (av1 &1d_Left1)
            else
              one_d_Out <= '0';
            end if;  -- empty_0_in

          end if;  -- av_0 




        when 2 =>
          -- Siirretaan data fifosta 0

          if one_d_0_in = '1' then
            -- Fifo 0 tyhjenee

            if empty_1_in = '1' then
              -- ja fifo 1:kin on tyhja
              one_d_Out   <= '1';
            else
              if av_1_in = '1' and one_d_1_in = '1' then
                -- Fifossa 1 pelkka osoite
                one_d_Out <= '1';
              else
                -- Voidaan siirtya lukemaan fifoa 1
                one_d_Out <= '0';
              end if;  --AV1 & 1D_Left1
            end if;  -- empty_1_in            
          else
            -- Fifoon 0 jaa jotain
            one_d_Out     <= '0';
          end if;  --one_d_0_in

          

        when 3                      =>
          -- Siirretaan osoite 1
          -- ellei ihmeita tapahdu, one_d_Out pitaisi olla 0!

          if av_1_in = '1' then
            --Olisi syyta olla dataakin fifossa 1, toivotaan
            one_d_Out <= '0';
          else
            -- Sama osoite kuin viimeksi (rekisterista)

            if empty_1_in = '1' then
              -- Fifo 1 on tyhja
              assert false report
                "Retrsnferring addr#1, but fifo#1 is empty. ERROR?" severity warning;

              if empty_0_in = '1'
                or (av_0_in = '1' and one_d_0_in = '1' )then
                -- ja fifo 0:kin on tyhja
                one_d_Out <= '1';
              else
                -- Voidaan siirtya lukemaan fifoa 0
                one_d_Out <= '0';
              end if;  -- empty_1_in & (AV1 & 1D_Left1)
                       -- 
            else
              one_d_Out   <= '0';
            end if;  --empty_Left_1_in
          end if;  -- av_1






        when 4 =>
          -- Siirretaan data 1
          
          if one_d_1_in = '1' then
            -- fifo 1 tyhjenee

            if empty_0_in = '1'
              or (av_0_in = '1' and one_d_0_in = '1') then
              -- Fifo 0:kin on tyhja tai siella pelkka osoite
              one_d_Out <= '1';
            else
              -- Voidaan siirtya lukemaan fifoa 0
              one_d_Out <= '0';
            end if;  --empty_0_in & (av0 & 1_D_Left0)

          else
            -- Fifoon 1 jaa jotain
            one_d_Out <= '0';
          end if;                       --one_d_1_in


          
        when 5                         =>
          -- Molemmat fifot tyhjia
          one_d_Out <= '0';


        when others                    =>
          one_d_Out <= '0';
          assert false report "Illegal state in fifo_mux_rd" severity warning;
      end case;
  end process Assign_1_D_Left_Out;

end rtl;








