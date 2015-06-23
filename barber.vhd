----------------------------------------------------------------------------------
-- http://en.wikipedia.org/wiki/Barber_paradox =>
-- "The barber is a man in town who shaves all those, and only those,
-- men in town who do not shave themselves."

--The point is that the barber is represented by the logical value '1' in the two
--stage shift register. The '1' shows which set he currently belongs to. In a more
--sophisticated case we may assume there are several barbers in different cities,
--and the sets may include more elements at once.

--The reset state is arbitrarily choosen, and in a complex system might effect
--the long term behaviour: like if the model of the sets definition would somwhow
--happen to be an LFSR that does not run through all the combinations...

--If the barbers are not identical, FIFO-s can be used to hold their identifiers.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity barbers is
    Port ( big_bang : in  STD_LOGIC;
	   a_barber_shaves_event : in  STD_LOGIC;
           a_barber_doesnt_shave_event : in  STD_LOGIC; --like for a day...
           number_of_barbers_who_may_shave_themselves : out  STD_LOGIC;
           number_of_barbers_who_may_not_shave_themselves : out  STD_LOGIC);
end barbers;

architecture simulateable of barbers is

begin

   process(big_bang, a_barber_shaves_event, a_barber_doesnt_shave_event)
   begin
      if big_bang = '1' then
         number_of_barbers_who_may_shave_themselves <= x"0";
         number_of_barbers_who_may_not_shave_themselves <= x"f";
      else
         number_of_barbers_who_may_shave_themselves <= number_of_barbers_who_may_shave_themselves + a_barber_doesnt_shave_event - a_barber_shaves_event;
         number_of_barbers_who_may_not_shave_themselves <= number_of_barbers_who_may_not_shave_themselves - a_barber_doesnt_shave_event + a_barber_shaves_event;
      end if;
   end process;

end simulateable;

architecture synthesisable of barbers is

   signal counter1, counter2 : std_logic_vector(3 downto 0);

begin

   process(big_bang, a_barber_shaves_event)
   begin
      if big_bang = '1' then
         counter1 <= x"f";
      elsif rising_edge(a_barber_shaves_event) then
         counter1 <= counter1 + '1';
      end if;
   end process;

   process(big_bang, a_barber_doesnt_shave_event)
   begin
      if big_bang = '1' then
         counter2 <= x"0";
      elsif rising_edge(a_barber_doesnt_shave_event) then
         counter2 <= counter2 + '1';
      end if;
   end process;

number_of_barbers_who_may_shave_themselves <= counter2 - counter1;
number_of_barbers_who_may_not_shave_themselves <= counter1 - counter2;

end synthesisable;
