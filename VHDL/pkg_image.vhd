-- $Author: rpaley_yid $
-- $Date: 2003-01-14 21:48:10 $
-- $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/single_port/VHDL/pkg_image.vhd,v 1.1.1.1 2003-01-14 21:48:10 rpaley_yid Exp $
-- $Locker
-- $Revision: 1.1.1.1 $
-- $State: Exp $

-- Copyright (c) 1997 Ben Cohen.   All rights reserved.
-- This model can be used in conjunction with the Kluwer Academic books
-- "VHDL Coding Styles and Methodologies", ISBN: 0-7923-9598-0
-- "VHDL Amswers to Frequently Asked Questions", Kluwer Academic
--    by Ben Cohen.                       email: vhdlcohen@aol.com
--   
-- This source file for the Image Package
-- may be used and distributed without restriction provided
-- that this copyright statement is not removed from the file
-- and that any derivative work contains this copyright notice.
--
--
-- Original Author: Ben Cohen
-- Description: 
-- Convert VHDL types to string for printing. This is especially useful when 
-- compiling with VHDL-87             

---------------------------------------------------------------
LIBRARY IEEE; 
  USE IEEE.STD_LOGIC_1164.ALL;
  USE IEEE.STD_LOGIC_TEXTIO.ALL;  
  USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
  USE STD.TEXTIO.ALL;

package pkg_image is
  function Image(In_Image : Time) return String;
  function Image(In_Image : Bit) return String;
  function Image(In_Image : Bit_Vector) return String;
  function Image(In_Image : Integer) return String;
  function Image(In_Image : Real) return String;
  function Image(In_Image : Std_uLogic) return String;
  function Image(In_Image : Std_uLogic_Vector) return String;
  function Image(In_Image : Std_Logic_Vector) return String;
  function Image(In_Image : Signed) return String;
  function Image(In_Image : UnSigned) return String;

  function HexImage(InStrg  : String) return String;
  function HexImage(In_Image : Bit_Vector) return String;
  function HexImage(In_Image : Std_uLogic_Vector) return String;
  function HexImage(In_Image : Std_Logic_Vector) return String;
  function HexImage(In_Image : Signed) return String;
  function HexImage(In_Image : UnSigned) return String;

  function DecImage(In_Image : Bit_Vector) return String;
  function DecImage(In_Image : Std_uLogic_Vector) return String;
  function DecImage(In_Image : Std_Logic_Vector) return String;
  function DecImage(In_Image : Signed) return String;
  function DecImage(In_Image : UnSigned) return String;
end pkg_image;

package body pkg_image is
  function Image(In_Image : Time) return String is
    variable L : Line;  -- access type
    variable W : String(1 to 14) := (others => ' '); 
       -- Long enough to hold a time string
  begin
    -- the WRITE procedure creates an object with "NEW".
    -- L is passed as an output of the procedure.
    Std.TextIO.WRITE(L, in_image);
    -- Copy L.all onto W
    W(L.all'range) := L.all;
    Deallocate(L);
    return W;
  end Image;

  function Image(In_Image : Bit) return String is
    variable L : Line;  -- access type
    variable W : String(1 to 3) := (others => ' ');  
  begin
    Std.TextIO.WRITE(L, in_image);
    W(L.all'range) := L.all;
    Deallocate(L);
    return W;
  end Image;

  function Image(In_Image : Bit_Vector) return String is
    variable L : Line;  -- access type
    variable W : String(1 to In_Image'length) := (others => ' ');  
  begin
    Std.TextIO.WRITE(L, in_image);
    W(L.all'range) := L.all;
    Deallocate(L);
    return W;
  end Image;

  function Image(In_Image : Integer) return String is
    variable L : Line;  -- access type
    variable W : String(1 to 32) := (others => ' ');  
     -- Long enough to hold a time string
  begin
    Std.TextIO.WRITE(L, in_image);
    W(L.all'range) := L.all;
    Deallocate(L);
    return W;
  end Image;

  function Image(In_Image : Real) return String is
    variable L : Line;  -- access type
    variable W : String(1 to 32) := (others => ' ');  
      -- Long enough to hold a time string
  begin
    Std.TextIO.WRITE(L, in_image);
    W(L.all'range) := L.all;
    Deallocate(L);
    return W;
  end Image;

  function Image(In_Image : Std_uLogic) return String is
    variable L : Line;  -- access type
    variable W : String(1 to 3) := (others => ' ');  
  begin
    IEEE.Std_Logic_Textio.WRITE(L, in_image);
    W(L.all'range) := L.all;
    Deallocate(L);
    return W;
  end Image;

  function Image(In_Image : Std_uLogic_Vector) return String is
    variable L : Line;  -- access type
    variable W : String(1 to In_Image'length) := (others => ' ');  
  begin
    IEEE.Std_Logic_Textio.WRITE(L, in_image);
    W(L.all'range) := L.all;
    Deallocate(L);
    return W;
  end Image;

  function Image(In_Image : Std_Logic_Vector) return String is
    variable L : Line;  -- access type
    variable W : String(1 to In_Image'length) := (others => ' ');  
  begin
     IEEE.Std_Logic_TextIO.WRITE(L, In_Image);
     W(L.all'range) := L.all;
     Deallocate(L);
     return W;
  end Image;

  function Image(In_Image : Signed) return String is 
  begin 
    return Image(Std_Logic_Vector(In_Image));
  end Image;

  function Image(In_Image : UnSigned) return String is
  begin 
    return Image(Std_Logic_Vector(In_Image));
  end Image;

  function HexImage(InStrg  : String) return String is
    subtype Int03_Typ is Integer range 0 to 3;
    variable Result : string(1 to ((InStrg'length - 1)/4)+1) :=
        (others => '0');
    variable StrTo4 : string(1 to Result'length * 4) := 
        (others => '0');
    variable MTspace : Int03_Typ;  --  Empty space to fill in
    variable Str4    : String(1 to 4);
    variable Group_v   : Natural := 0; 
  begin
    MTspace := Result'length * 4  - InStrg'length; 
    StrTo4(MTspace + 1 to StrTo4'length) := InStrg; -- padded with '0'
    Cnvrt_Lbl : for I in Result'range loop
      Group_v := Group_v + 4;  -- identifies end of bit # in a group of 4 
      Str4 := StrTo4(Group_v - 3 to Group_v); -- get next 4 characters 
      case Str4 is
        when "0000"  => Result(I) := '0'; 
        when "0001"  => Result(I) := '1'; 
        when "0010"  => Result(I) := '2'; 
        when "0011"  => Result(I) := '3'; 
        when "0100"  => Result(I) := '4'; 
        when "0101"  => Result(I) := '5'; 
        when "0110"  => Result(I) := '6'; 
        when "0111"  => Result(I) := '7'; 
        when "1000"  => Result(I) := '8'; 
        when "1001"  => Result(I) := '9'; 
        when "1010"  => Result(I) := 'A'; 
        when "1011"  => Result(I) := 'B'; 
        when "1100"  => Result(I) := 'C'; 
        when "1101"  => Result(I) := 'D'; 
        when "1110"  => Result(I) := 'E'; 
        when "1111"  => Result(I) := 'F';
        when others  => Result(I) := 'X'; 
      end case;                          --  Str4
    end loop Cnvrt_Lbl;

    return Result; 
  end HexImage;


  function HexImage(In_Image : Bit_Vector) return String is
  begin
    return HexImage(Image(In_Image));
  end HexImage;

  function HexImage(In_Image : Std_uLogic_Vector) return String is
  begin
    return HexImage(Image(In_Image));
  end HexImage;
    
  function HexImage(In_Image : Std_Logic_Vector) return String is
  begin
    return HexImage(Image(In_Image));
  end HexImage;
    
  function HexImage(In_Image : Signed) return String is
  begin
    return HexImage(Image(In_Image));
  end HexImage;
    
  function HexImage(In_Image : UnSigned) return String is
  begin
    return HexImage(Image(In_Image));
  end HexImage;

  function DecImage(In_Image : Bit_Vector) return String is
    variable In_Image_v : Bit_Vector(In_Image'length downto 1) := In_Image;
  begin
    if In_Image'length > 31 then
      assert False
        report "Number too large for Integer, clipping to 31 bits"
        severity Warning;
      return Image(To_Integer
                    (Unsigned(To_StdLogicVector
                        (In_Image_v(31 downto 1)))));
    else             
      return Image(To_Integer(Unsigned(To_StdLogicVector(In_Image))));
    end if; 
  end DecImage;
  
  function DecImage(In_Image : Std_uLogic_Vector) return String is
    variable In_Image_v : Std_uLogic_Vector(In_Image'length downto 1)
                              := In_Image;
  begin
    if In_Image'length > 31 then
      assert False
        report "Number too large for Integer, clipping to 31 bits"
        severity Warning;
       return Image(To_Integer(Unsigned(In_Image_v(31 downto 1))));
    else
        return Image(To_Integer(Unsigned(In_Image)));
    end if; 
  end DecImage;
  
  function DecImage(In_Image : Std_Logic_Vector) return String is
    variable In_Image_v : Std_Logic_Vector(In_Image'length downto 1)
                              := In_Image;
  begin
    if In_Image'length > 31 then
      assert False
        report "Number too large for Integer, clipping to 31 bits"
        severity Warning;
       return Image(To_Integer(Unsigned(In_Image_v(31 downto 1))));
    else
        return Image(To_Integer(Unsigned(In_Image)));
    end if; 
  end DecImage;
    
  function DecImage(In_Image : Signed) return String is
    variable In_Image_v : Signed(In_Image'length downto 1) := In_Image;
  begin
    if In_Image'length > 31 then
      assert False
        report "Number too large for Integer, clipping to 31 bits"
        severity Warning;
       return Image(To_Integer(In_Image_v(31 downto 1)));
    else
        return Image(To_Integer(In_Image));
    end if; 
  end DecImage;
    
  function DecImage(In_Image : UnSigned) return String is
    variable In_Image_v : UnSigned(In_Image'length downto 1) := In_Image;
  begin
    if In_Image'length > 31 then
      assert False
        report "Number too large for Integer, clipping to 31 bits"
        severity Warning;
       return Image(To_Integer(In_Image_v(31 downto 1)));
    else
        return Image(To_Integer(In_Image));
    end if; 
  end DecImage;
    
end pkg_image;

-- $Log: not supported by cvs2svn $
-- Revision 1.1  2003/01/14 17:48:44  Default
-- Initial revision
--
-- Revision 1.1  2002/12/24 18:07:50  Default
-- Initial revision
--








