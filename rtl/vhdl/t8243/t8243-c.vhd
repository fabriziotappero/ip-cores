-------------------------------------------------------------------------------
--
-- T8243 Core
--
-- $Id: t8243-c.vhd 295 2009-04-01 19:32:48Z arniml $
--
-------------------------------------------------------------------------------

configuration t8243_struct_c0 of t8243 is

  for struct

    for t8243_async_notri_b: t8243_async_notri
      use configuration work.t8243_async_notri_struct_c0;
    end for;

  end for;

end t8243_struct_c0;
