#!/usr/bin/php
<?php

/**
Prints an error message and quits.
*/
function error(string $msg)
{
  exit($msg);
}


function parsecsv(array $csv)
{
  $res = array();
  foreach ($csv as $item)
    {
      $exp = explode("=",$item);
      $res[$exp[0]] = $exp[1];
    }

  return $res;
}


function decopc($opword)
{
  // convert HEX opword

  $opword = hexdec($opword);

  // split parts
  $opc = ($opword >> 26) & 63;
  $rd = ($opword >> 21) & 31;
  $ra = ($opword >> 16) & 31;
  $rb = ($opword >> 11) & 31;
  $imm = $opword & 65535;  

  switch ($opc)
    {
    case 000: $str = "ADD\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 001: $str = "RSUB\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 002: $str = "ADDC\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 003: $str = "RSUBC\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 004: $str = "ADDK\t r" . $rd . ", r" . $ra . ", r" . $rb; break;

    case 005:
      switch ($imm & 3)
	{
	case 0:	$str = "RSUBK\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
	case 3: $str = "CMPU\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
	case 1: $str = "CMP\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
	default: $str = "XXX"; break;
	}
      break;

    case 006: $str = "ADDKC\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 007: $str = "RSUBKC\t r" . $rd . ", r" . $ra . ", r" . $rb; break;

    case 010: $str = "ADDI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 011: $str = "RSUBI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 012: $str = "ADDIC\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 013: $str = "RSUBIC\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 014: $str = "ADDIK\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 015: $str = "RSUBIK\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 016: $str = "ADDIKC\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 017: $str = "RSUBIKC\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;

      
    case 020: $str = "MUL\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 021: 
      switch ( ($imm >> 9) & 3)
	{
	case 0: $str = "BSRL\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
	case 1: $str = "BSRA\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
	case 3: $str = "BSLL\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
	default: $str = "XXX"; break;
	}
      break;
    case 022: $str = "IDIV\t r" . $rd . ", r" . $ra . ", r" . $rb; break;

    case 030: $str = "MULI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 031: 
      switch ( ($imm >> 9) & 3)
	{
	case 00: $str = "BSRLI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
	case 01: $str = "BSRAI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
	case 02: $str = "BSLLI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;	
	default: $str = "XXX"; break;
	}
      break;
    case 033:
      switch ( ($rb >> 2) )
	{
	case 00: $str = "GET\t r" . $rd . ", rfsl0x".dechex($imm); break;
	case 01: $str = "PUT\t rfsl0x".dechex($imm) . ", r" . $ra; break;
	case 02: $str = "NGET\t r" . $rd . ", rfsl0x".dechex($imm); break;
	case 03: $str = "NPUT\t rfsl0x".dechex($imm) . ", r" . $ra; break;
	case 04: $str = "CGET\t r" . $rd . ", rfsl0x".dechex($imm); break;
	case 05: $str = "CPUT\t rfsl0x".dechex($imm) . ", r" . $ra; break;
	case 06: $str = "NCGET\t r" . $rd . ", rfsl0x".dechex($imm); break;
	case 07: $str = "NCPUT\t rfsl0x".dechex($imm) . ", r" . $ra; break;
	}
      break;
    case 040: $str = "OR\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 041: $str = "AND\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 042: $str = "XOR\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 043: $str = "ANDN\t r" . $rd . ", r" . $ra . ", r" . $rb; break;

    case 044:
      switch ( ($imm >> 5) & 3)
	{
	case 00: $str = "SRA\t r" . $rd . ", r" . $ra; break;
	case 01: $str = "SRC\t r" . $rd . ", r" . $ra; break;
	case 02: $str = "SRL\t r" . $rd . ", r" . $ra; break;
	case 03:
	  switch ( $imm & 1 )
	    {
	    case 00: $str = "SEXT8\t r" . $rd . ", r" . $ra; break;
	    case 01: $str = "SEXT16\t r" . $rd . ", r" . $ra; break;
	    }
	  break;
	}
      break;
    case 045:
      switch ( ($imm >> 14) & 3)
	{
	case 03: $str = "MTS\t rmsr, r" . $ra; break;
	case 02: $str = "MFS\t r" . $rd . ", rmsr"; break;
	case 00: 
	  switch ( $ra & 1)
	    {
	    case 1: $str = "MSRCLR\t r" . $rd . ", 0x".dechex($imm); break;
	    case 0: $str = "MSRSET\t r" . $rd . ", 0x".dechex($imm); break;
	    }
	  break;
	default : $str = "XXX"; break;
	}
      break;
    case 046:
      switch ( ($ra >> 2) & 7)
	{
	case 00: $str = "BR\t r".$rb; break;
	case 01: $str = "BRL\t r".$rd.", r".$rb;break;      
	case 02: $str = "BRA\t r".$rb;break;
	case 03: $str = "BRAL\t r".$rd.", r".$rb;break;
	case 04: $str = "BRD\t r".$rb; break;
	case 05: $str = "BRLD\t r".$rd.", r".$rb;break;      
	case 06: $str = "BRAD\t r".$rb;break;
	case 07: $str = "BRALD\t r".$rd.", r".$rb;break;
	}
      break;

    case 047:
      switch ( $rd & 31 )
	{
	case 00: $str = "BEQ\t r".$ra.", r".$rb;break;
	case 01: $str = "BNE\t r".$ra.", r".$rb;break;
	case 02: $str = "BLT\t r".$ra.", r".$rb;break;
	case 03: $str = "BLE\t r".$ra.", r".$rb;break;
	case 04: $str = "BGT\t r".$ra.", r".$rb;break;
	case 05: $str = "BGE\t r".$ra.", r".$rb;break;
	case 020: $str = "BEQD\t r".$ra.", r".$rb;break;
	case 021: $str = "BNED\t r".$ra.", r".$rb;break;
	case 022: $str = "BLTD\t r".$ra.", r".$rb;break;
	case 023: $str = "BLED\t r".$ra.", r".$rb;break;
	case 024: $str = "BGTD\t r".$ra.", r".$rb;break;
	case 025: $str = "BGED\t r".$ra.", r".$rb;break;
	default: $str = "XXX"; break;
	}
      break;


    case 050: $str = "ORI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 051: $str = "ANDI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 052: $str = "XORI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 053: $str = "ANDNI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 054: $str = "IMMI\t 0x".dechex($imm);break;

    case 055:
      switch ( ($rd & 3))
	{
	case 0: $str = "RTSD\t r". $ra . ", 0x".dechex($imm);break;
	case 1: $str = "RTID\t r". $ra . ", 0x".dechex($imm);break;
	case 2: $str = "RTBD\t r". $ra . ", 0x".dechex($imm);break;
	default: $str = "XXX";break;
	}
      break;

    case 056:
      switch ( ($ra >> 2) & 7)
	{
	case 00: $str = "BRI\t 0x".dechex($imm); break;
	case 01: $str = "BRLI\t r".$rd.", 0x".dechex($imm);break;      
	case 02: $str = "BRAI\t 0x".dechex($imm);break;
	case 03: $str = "BRALI\t r".$rd.", 0x".dechex($imm);break;
	case 04: $str = "BRID\t 0x".dechex($imm); break;
	case 05: $str = "BRLID\t r".$rd.", 0x".dechex($imm);break;      
	case 06: $str = "BRAID\t 0x".dechex($imm);break;
	case 07: $str = "BRALID\t r".$rd.", 0x".dechex($imm);break;
	}
      break;

    case 057:
      switch ( $rd & 31 )
	{
	case 00: $str = "BEQI\t r".$ra.", 0x".dechex($imm);break;
	case 01: $str = "BNEI\t r".$ra.", 0x".dechex($imm);break;
	case 02: $str = "BLTI\t r".$ra.", 0x".dechex($imm);break;
	case 03: $str = "BLEI\t r".$ra.", 0x".dechex($imm);break;
	case 04: $str = "BGTI\t r".$ra.", 0x".dechex($imm);break;
	case 05: $str = "BGEI\t r".$ra.", 0x".dechex($imm);break;
	case 020: $str = "BEQID\t r".$ra.", 0x".dechex($imm);break;
	case 021: $str = "BNEID\t r".$ra.", 0x".dechex($imm);break;
	case 022: $str = "BLTID\t r".$ra.", 0x".dechex($imm);break;
	case 023: $str = "BLEID\t r".$ra.", 0x".dechex($imm);break;
	case 024: $str = "BGTID\t r".$ra.", 0x".dechex($imm);break;
	case 025: $str = "BGEID\t r".$ra.", 0x".dechex($imm);break;
	default: $str = "XXX"; break;
	}
      break;

    case 060: $str = "LB\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 061: $str = "LH\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 062: $str = "LW\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 064: $str = "SB\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 065: $str = "SH\t r" . $rd . ", r" . $ra . ", r" . $rb; break;
    case 066: $str = "SW\t r" . $rd . ", r" . $ra . ", r" . $rb; break;

    case 070: $str = "LBI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 071: $str = "LHI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 072: $str = "LWI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 074: $str = "SBI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 075: $str = "SHI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
    case 076: $str = "SWI\t r" . $rd . ", r" . $ra . ", 0x".dechex($imm); break;
      
    default: $str = "XXX " . decoct($opc); break;      
    }
  
  return $str;
}

function draw(array $sample)
{
  fputs(STDOUT, "Time\t:" . hexdec($sample["TME"]) . "\t");
  switch ($sample["PHA"])
    {
    case 1: fputs(STDOUT,"".$sample["IWB"]."@".decopc($sample["ASM"])); break;
    case 0: fputs(STDOUT,"\t\t\t\t\t".$sample["IWB"]."@".decopc($sample["ASM"])); break;
    }

  fputs(STDOUT, "\n");
  //fputs(STDOUT,$sample["PHA"].":".$sample["IWB"]."@".decopc($sample["ASM"]) . "\n");
}


function main()
{
  // read simulator output one line at a time
  while ( ($line = fgets(STDIN)) )
    {
      $line = parsecsv(explode(",",$line));
      if (array_key_exists("TME",$line))
	draw($line);
    }   
}


function gui()
{
  
  // we begin by initializing ncurses 
  $ncurse = ncurses_init();  
  // let ncurses know we wish to use the whole screen 
  $fullscreen = ncurses_newwin(0, 0, 0, 0); 
  // draw a border around the whole thing. 
  ncurses_border(0,0, 0,0, 0,0, 0,0); 

  ncurses_attron(NCURSES_A_REVERSE); 
  ncurses_mvaddstr(0,1,"AEMB2 SIMULATOR OUTPUT TRANSLATOR"); 
  ncurses_attroff(NCURSES_A_REVERSE);

  // now lets create a small window 
  $small = ncurses_newwin(10, 30, 2, 2);  
  // border our small window. 
  ncurses_wborder($small,0,0, 0,0, 0,0, 0,0); 
  ncurses_refresh();// paint both windows 
 
  // move into the small window and write a string 
  ncurses_mvwaddstr($small, 5, 5, "   Test  String   "); 
 
  // show our handiwork and refresh our small window 
  ncurses_wrefresh($small);
 
  $pressed = ncurses_getch();// wait for a user keypress 
 
  ncurses_end();// clean up our screen

}

main();
//gui();

?>