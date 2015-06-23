{*******************************************************************************
*                                                                              *
*                            GENERATE VERILOG ROM IMAGE                        *
*                                                                              *
* Generates a rom image from a binary file.  This program is written in        *
* ISO 7185 Compliant Pascal.                                                   *
*                                                                              *
* Usage: run the program as follows:                                           *
*                                                                              *
* genrom test.obj > test.lst                                                   *
*                                                                              *
* Then paste the test.lst file into the rom cell data in testbench.v.          *
*                                                                              *
*******************************************************************************}

program genrom(binfil, output);

type byte = 0..255;

var binfil: file of byte;
    b:      byte;
	addr:   integer;

begin

   reset(binfil); { open file }
   addr := 0; { clear address }
   while not eof(binfil) do begin { dump bytes in file }

      { write preamble }
      write('      ', addr:6, ': datao = 8''h');
      read(binfil, b); { read next byte }
	  { output high digit }
	  if b div 16 > 9 then write(chr(b div 16-10+ord('A')))
	  else write(chr(b div 16+ord('0')));
	  { output low digit }
	  if b mod 16 > 9 then write(chr(b mod 16-10+ord('A')))
	  else write(chr(b mod 16+ord('0')));
	  { write postamble }
	  writeln(';');
	  addr := addr+1

   end

end.
