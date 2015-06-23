--********************************************************************
--********************************************************************
--** This model is the property of Cypress Semiconductor Corp. and  **
--** is protected by the US copyright laws, any unauthorized copying** 
--** and distribution is prohibited. Cypress reserves the right to  **
--** change any of the functional specifications without any prior  **
--** notice. Cypress is not liable for any damages which may result **
--** from the use of this functional model.                         ** 
--**                                                                **
--** File Name: 8KX8.vhd                                            **
--**                                                                **
--** Revision : 1.0                                                 **
--**                                                                **
--** All the timings to be assigned by the user depending on the    **
--** frequency of operation.                                        **
--**                                                                ** 
--** Model    : 8K x 8 Asynchronous SRAM                            **   
--**                                                                **
--** Queries ?: MPD Applications                                    **
--**            Ph#: (408)-943-2821                                 **
--**            e-mail: mpd_apps@cypress.com                        **
--********************************************************************
--******************************************************************** 

Library IEEE;
Use IEEE.Std_Logic_1164.All;
use IEEE.Std_Logic_Signed.All; 

-- Entity Description for 8K x 8

Entity A8Kx8 Is
 Generic (Trc  :   TIME    :=   0 ns;
          Taa  :   TIME    :=   0 ns;
          Toha :   TIME    :=   0 ns;
          Tace :   TIME    :=   0 ns;
          Tdoe :   TIME    :=   0 ns;
          Thzoe:   TIME    :=   0 ns;
          Thzce:   TIME    :=   0 ns;
          Twc  :   TIME    :=   0 ns;
          Tsce :   TIME    :=   0 ns;
          Taw  :   TIME    :=   0 ns;
          Tha  :   TIME    :=   0 ns;
          Tsa  :   TIME    :=   0 ns;
          Tpwe :   TIME    :=   0 ns;
          Tsd  :   TIME    :=   0 ns;
          Thd  :   TIME    :=   0 ns);

Port ( CE_b, WE_b, OE_n : IN Std_Logic;
         A : IN Std_Logic_Vector(12 downto 0);
        IO : INOUT Std_Logic_Vector(7 downto 0):=(others=>'Z'));

End A8Kx8;

-- End Entity Description

-- Architecture Description of entity A8Kx8

Architecture Behavioral Of A8Kx8 Is

   Type array1 Is array (8191 downto 0) of std_logic_vector(7 downto 0);
   Signal rd, wr, oe, ce, we, ce_pipe, we_pipe, r_chk : Std_logic;
   Signal we_chk, ce_chk, wr_sa, wr_sa1 : Std_logic;
   Signal address, A_adr, prev_addr, addr : Std_Logic_Vector(12 downto 0);
   Signal io_reg, io_val : Std_Logic_Vector(7 downto 0);

Begin

  ce <=  CE_b;
  oe <=  OE_n;
  we <=  WE_b;
  wr <= (NOT CE_b) and (NOT WE_b);
  rd <= (NOT CE_b) and (NOT OE_n) and WE_b;
  io_reg <= IO;
  address(12 downto 0) <= A(12 downto 0);

-- Process Description for the write and read cycle 

  PROCESS (ce, wr, A, we, oe, io_reg, IO)

   VARIABLE mem_array1: array1;
   VARIABLE Troe, Trce, Tro, Trc, Thdrd, Tprev, Tiopr, Tsa1 : Time;
   VARIABLE z : Time := 0 ns;
   VARIABLE wrt, ce_end, wr_end, oe_end, io_end, add_end, A_event_rd : Std_logic ;

   begin

--- Assign signals and variables for time checks before reading or writing.

   ce_pipe <= ce;
   wr_sa <= wr;

   if (ce'event and ce'last_value = '0') then
    ce_end := '1';
   else 
    ce_end := '0';
   end if;

   if (wr'event and wr'last_value = '1') then
    wr_end := '1';
   else 
    wr_end := '0';
   end if;

   if (io_reg(7 downto 0)'event) then
    io_end := '1';
   else 
    io_end := '0';
   end if;

   if (oe'event and oe'last_value = '0') then
    oe_end := '1';
   else 
    oe_end := '0';
   end if;

------ Storing the last event and previous address when address transitions 
------ along with write end.

   if (A'event) then
   prev_addr(12 downto 0)  <= address(12 downto 0);

   end if;
    
   if (address'event) then
   Add_end := '1';
   else 
   Add_end := '0';
   end if;

   if (A'event) then
   Tprev := address'last_event;
   end if;


------ Storing the address setup to write start time for performing the check 
------ before the write.

   if (wr_end = '1' and Add_end = '1') then
   Tsa1 := Tprev - wr_sa'last_event;
   elsif (wr_end = '1' and Add_end = '0') then
   Tsa1 := A'last_event -  wr_sa'last_event;
   end if;

----- Reading or writing occurs only when CE low or CE has transitioned 
----- from low to high.

   if ((CE_b = '0') or (ce_end = '1' and wr_end = '1') or (ce_end = '1')) then
 
      we_pipe <= we;

      wrt := '0';
      if  (wr'event and wr'last_value = '1') then 
      wrt := '1';
      else 
      wrt:= '0';
      end if;

------------------------------------------------------------------------------------------------
----- WRITE CYCLE

----- Storing the previous value of higher order data bits and storing last event
----- of data for data setup time check if data changes along with the write end transition.

      if (io_reg'event) then
      io_val <= io_reg;
      end if;

      if (IO'event) then
      Tiopr := io_reg'last_event;
      end if;

----- Write the higher order byte after checking for the necessary
----- timings - Tsa, Tpwe, Tsce, Tbw, Taw, Tsd. 
    
       if (wrt = '1') then
         if (we_pipe'last_event >= Tpwe) and (ce_pipe'last_event >= Tsce) and (Tsa1 >= Tsa) then
           if (Add_end = '1') then
             if (Tprev >= Taw) then
               if (io_end = '1') then
                 if (Tiopr > Tsd) then
                  mem_array1(conv_integer(prev_addr)) := io_val;
                 end if;
               else
                 if (IO'last_event >= Tsd) then
                 mem_array1(conv_integer(prev_addr)) := IO(7 downto 0);
                 end if;
               end if;
             end if;
           else
              if (A'last_event >= Taw) then
                if (io_end = '1') then
                  if (Tiopr >= Tsd) then
                   mem_array1(conv_integer(A)) := io_val;
                  end if;
                else
                  if (IO'last_event >= Tsd) then
                   mem_array1(conv_integer(A)) := IO(7 downto 0);
                  end if;
                end if;
              end if;
           end if;
              IO(7 downto 0) <= "ZZZZZZZZ" AFTER Thd;
        end if;
      end if;                               ----- End of write.



----------------------------------------------------------------------------------------------------
----- READ CYCLE.

    if (A'event) then
     A_event_rd := '1';
    else
     A_event_rd := '0';
    end if;


    if (rd'event and rd = '1') then

------ Determine the read initiation to data valid time.

      Tro := OE_n'last_event;
      Troe := Tdoe-Tro;
      if (Troe < 0 ns) then
        Troe := 0 ns;
      end if;

      Trc := 0 ns;
      Trc := CE_b'last_event;
      Trce := Tace-Trc;
      If (Trce < 0 ns) then
        Trce := 0 ns;
      end if;

      if (Troe > Trce) then
       if (rd = '1') then
       z := Troe;
       end if;
      else
       if (rd = '1') then
       z := Trce;
       end if;
      end if;

       if (address'last_event+z) < Taa then
       z := Taa;
       end if;
      end if;

  end if;


      if (A_event_rd = '0') then
         if (rd'event and rd = '1') then
          IO(7 downto 0) <= mem_array1(conv_integer(A)) after z;
         end if;
      elsif (A_event_rd = '1') then
         if (rd'event and rd = '1') then
          IO(7 downto 0) <= mem_array1(conv_integer(A)) after z;
         elsif (rd = '1') then
          IO(7 downto 0) <= mem_array1(conv_integer(A)) after Taa;
         end if;
      end if;                                                   ------- End of Read


------ Determine read end to High Z time.

------ Higher order bits read. The time is calculated as per which signal(s) terrminates
------ the read.

       if (rd'event and rd = '0') then

          if (oe_end = '1' and ce_end = '1') then
             Thdrd := Thzoe;
             if (Thdrd < Thzce) then
              Thdrd := Thzce;
             end if; 
          else
             if (ce_end = '1') then
              Thdrd := Thzce;
             end if;

             if (oe_end = '1') then
              Thdrd := Thzoe;
             end if;
          end if;

          if (Thdrd < 0 ns) then
           Thdrd := 0 ns;
          end if;

         IO(7 downto 0) <= (others=>'Z') after Thdrd; 

  end if;

 END PROCESS;


------ Read Cycle (Trc) and Write Cycle (Twc) time checks.

Process (A, address, wr, rd)

variable A_evnt, A_wr, A_rd, r1 : Std_logic;
variable Trd, Tadr : Time;

 Begin

   r_chk <= rd;

   if (A'event) then
   A_adr(12 downto 0)  <= address(12 downto 0);
   end if;

   if (A'event) then
   Tadr := A_adr(12 downto 0)'last_event;
   end if;

   if (wr'event and wr'last_value = '1') then
     A_wr := '1';
   end if;

   if (rd'event and rd'last_value = '1') then
     A_rd := '1';
     Trd := r_chk'last_event;
   end if;

   if address'event then
     A_evnt := '1';
   else
     A_evnt := '0';
   end if;


      if (rd'event and rd'last_value = '1') then
        if (A_evnt = '1') then
        r1 := '1';
        ASSERT (Trd >= Trc) or (A_adr'LAST_EVENT >= Trc) 
        REPORT "READ CYCLE TIME VIOLATION"
        SEVERITY Error;   
        elsif (A_evnt = '0') then
        r1 := '0';
        ASSERT (Trd >= Trc) or (A'LAST_EVENT >= Trc) 
        REPORT "READ CYCLE TIME VIOLATION"
        SEVERITY Error;   
        end if;
      end if;

      if (A_evnt = '1') then
       if (rd'event and rd'last_value = '1') then
        r1 := '0';
       elsif rd = '1' then
        ASSERT (A_adr'LAST_EVENT >= Trc) or (Trd >= Trc)
        REPORT "READ CYCLE TIME VIOLATION"
        SEVERITY Error;   
      end if;

      if (wr'event and wr'last_value = '1') then
        ASSERT (Tadr >= Twc)
        REPORT "WRITE CYCLE TIME VIOLATION"
        SEVERITY Error;   
      elsif A_wr = '1' then
        ASSERT (Tadr >= Twc)
        REPORT "WRITE CYCLE TIME VIOLATION"
        SEVERITY Error;   
      end if;

   A_wr := '0';
   A_rd := '0';
   end if;

 End Process;


------ Checks for Tsce, Taw, Tsa, Tpwe, Tsd and Tbw.     

 Process (ce, wr, WE_b, A, IO)

 VARIABLE wr_end_chk, A_end : Std_logic := '0';
 VARIABLE Taw_chk, Tsd_chk, Tsa_chk : Time;

 begin

   ce_chk <= ce;
   we_chk <= we;
   addr(12 downto 0) <= address(12 downto 0);
   wr_sa1 <= wr;

   wr_end_chk := '0';
   if (wr'event and wr'last_value = '1') then
    wr_end_chk := '1';
   else 
    wr_end_chk := '0';
   end if;

   A_end := '0';
   if (address'event) and (wr_end_chk = '1') then
    A_end := '1';
   else 
    A_end := '0';
   end if;

   if (A'event) then
    Taw_chk := address'last_event;
   end if; 

   if (IO'event) then
    Tsd_chk := io_reg'last_event;
   end if; 

   if (wr_end_chk = '1' and A_end = '1') then
   Tsa_chk := Taw_chk - wr_sa1'last_event;
   elsif (wr_end_chk = '1' and A_end = '0') then
   Tsa_chk := A'last_event -  wr_sa1'last_event;
   end if;

      if wr_end_chk = '1' then

          ASSERT (ce_chk'LAST_EVENT >= Tsce)
          REPORT "CE LOW TO WRITE END TIME VIOLATION"
          SEVERITY Error;

          if (we'event) then
          ASSERT (we_chk'LAST_EVENT >= Tpwe)
          REPORT "WE PULSE WIDTH TIME VIOLATION"
          SEVERITY Error;
          else
          ASSERT (WE_b'LAST_EVENT >= Tpwe)
          REPORT "WE PULSE WIDTH TIME VIOLATION"
          SEVERITY Error;
          end if;

          if (A_end = '1') then
          ASSERT (Taw_chk >= Taw)
          REPORT "ADDRESS SETUP TO WRITE END TIME VIOLATION"
          SEVERITY Error;
          else
          ASSERT (A'LAST_EVENT >= Taw)
          REPORT "ADDRESS SETUP TO WRITE END TIME VIOLATION"
          SEVERITY Error;
          end if;

          if (io_reg'event) then
           ASSERT (Tsd_chk >= Tsd)
           REPORT "DATA SETUP TO WRITE END TIME VIOLATION"
           SEVERITY Error;
          else 
           ASSERT (IO'LAST_EVENT >= Tsd)
           REPORT "DATA SETUP TO WRITE END TIME VIOLATION"
           SEVERITY Error;
          end if;

          ASSERT (Tsa_chk >= Tsa) or (Tsa_chk < 0 ns)
          REPORT "ADDRESS SETUP TO WRITE START TIME VIOLATION"
          SEVERITY Error; 
      end if;

   end Process;

----- Address Hold (Tha) and Data Hold (Thd) time checks on write.

   Process (wr'delayed(Thd), wr'delayed(Tha), A, IO)

    begin

     if (wr'delayed(Thd) = '0' and wr'delayed(Thd)'last_value = '1') and (wr'delayed(Thd)'event) then
 
         ASSERT (IO'LAST_EVENT = 0 ns) or (IO'LAST_EVENT > Thd)
         REPORT "DATA HOLD FROM WRITE END TIME VIOLATION"
         SEVERITY Error;
 
     end if;

     if (wr'delayed(Tha) = '0' and wr'delayed(Tha)'last_value = '1') and (wr'delayed(Tha)'event) then

         ASSERT (A'LAST_EVENT = 0 ns) or (A'LAST_EVENT > Tha)
         REPORT "ADDRESS HOLD FROM WRITE END TIME VIOLATION"
         SEVERITY Error;

     end if;

   End Process;

---- Tdoe, Tdbe, Tace, Taa and Toha time checks on read.

Process (IO, A'delayed(Toha))
    begin

      if ((IO'event) and (rd = '1')) then
        
          if (rd'last_event <= A'last_event) then
           ASSERT (OE_n'LAST_EVENT >= Tdoe)
           REPORT "OE LOW TO DATA VALID TIME VIOLATION"
           SEVERITY Error;

           ASSERT (CE_b'LAST_EVENT >= Tace)
           REPORT "CE LOW TO DATA VALID TIME VIOLATION"
           SEVERITY Error;
          end if;

          if (rd'last_event > A'last_event) then
           ASSERT (A'LAST_EVENT >= Taa)
           REPORT "ADDRESS TO DATA VALID TIME VIOLATION"
           SEVERITY Error;
          end if;

      end if;

     if (A'delayed(Toha)'event and (rd = '1')) then

      if (rd'last_event > Toha) then
         ASSERT (IO'LAST_EVENT = 0 ns) or (IO'LAST_EVENT > Toha)
         REPORT "DATA HOLD FROM ADDRESS CHANGE TIME VIOLATION"
         SEVERITY Error;
      end if;

    end if;

End Process;

------ Thzbe, Thzoe and Thzce time checks.

Process (OE_n'delayed(Thzoe), CE_b'delayed(Thzce))
   begin

   if (OE_n'delayed(Thzoe)'event and OE_n'delayed'last_value = '0' and OE_n'delayed(Thzoe) = '1') then

       ASSERT (IO'LAST_EVENT = 0 ns) or (IO'LAST_EVENT > Thzoe)
       REPORT "OE DISABLE TO HIGH Z TIME VIOLATION"
       SEVERITY Error;

   end if;

   if (CE_b'delayed(Thzce)'event and CE_b'delayed'last_value = '0' and CE_b'delayed(Thzce) = '1') then

       ASSERT (IO'LAST_EVENT = 0 ns) or (IO'LAST_EVENT > Thzce)
       REPORT "CE DISABLE TO HIGH Z TIME VIOLATION"
       SEVERITY Error;

   end if;

End Process;               
End Behavioral;

