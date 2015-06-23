-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: altera_ethmodels_pack.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/package/altera_ethmodels_pack.vhd,v $
--
-- $Revision: #1 $
-- $Date: 2008/08/09 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : (Simulation only)
--
-- Package defining components and features of Ethernet Models
--
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------





library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all ;
use std.textio.all ;

package altera_ethmodels_pack is


    constant GENCNTMODULO  : integer := 256;    -- modulo used for the start counter
                                                -- (informative, not for change)
    


    -- --------------------------------------
    -- Procedures to help generation Messages
    -- --------------------------------------

    -- convert vector to HEX digits (assumes multiples of nibbles (4-bit) )
    --
    procedure WRITE_HEX(L : inout LINE; val : in std_logic_vector );
    
    -- write timestamp and message
    --
    procedure WRITETM(L: inout LINE; theMessage : in string );


    -- write to logfile and to stdout
    --
    procedure WRITELINE_LOG( file theLog: TEXT; L: inout LINE );
    



    
end altera_ethmodels_pack;


package body altera_ethmodels_pack is

    --
    -- Convert vector to hex digit (assumes 4-bit nibbles)
    --

    procedure WRITE_HEX(L: inout LINE; val: in std_logic_vector ) is
    
        variable i, ix : integer;
        variable nib   : integer;
        
        begin
        
            for i in ((val'left)+1)/4 downto 1 loop  -- start with MSNibble
            
                ix := i*4;
                
                nib := conv_integer( '0' & val( ix-1 downto ix-4 ) ); -- convert to unsigned always
                
                if( nib < 10 ) then
                
                    write( L, character'val(character'pos('0') + nib));
                    
                else
                
                    write( L, character'val(character'pos('a') + nib-10 ));
                
                end if;
                
            end loop;
        
        end;
            
            
    --
    -- Write line in logfile and stdout with time stamp
    --

    procedure WRITETM( L: inout LINE; theMessage: in string  ) is
    
        variable ln: line;
    
        begin
    
            write(L, string'("Time: "));
            write(L, NOW, RIGHT, 10 );
            write(L, string'(" - "));
            write(L, theMessage );
            
        end;
               
    -- write line in logfile and to output
    --
    procedure WRITELINE_LOG( file theLog: TEXT; L: inout LINE ) is
    
        variable ln1 : line;
        variable ln2 : line;
        variable tmp : string(1 to L'length);
        
        begin
                -- copy the string in two destinations as writeline deallocates them
                
               read(L, tmp);
               write( ln1, tmp);
               write( ln2, tmp);
               
               writeline( theLog, ln1);
               writeline( OUTPUT, ln2);
    
        end;    

end; -- body        
        
