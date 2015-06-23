
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Copyright(c) 2009 by Unicore Systems. All rights reserved
#
# DESIGN    	   :	FFT128_core
# FILENAME 		:	 sinerom64_gen.pl
# CREATED		:	 10.1:2008
# MODIFIED		:	
# VERSION			:	1.0
#
# AUTHORS:	Anatolij Sergiyenko.
# HISTORY	:	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
# DESCRIPTION	:	Test generating PERL file1
# FUNCTION:	 	Generating sine wave ROM 
#    					 with $n samples  which consists of 4 sine wave sum
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		

$aw=7;   ##   - address bit width
$n = 128; ### - period length
$n0 = 0; ### - init address  
$f1 = 1;  ## - first frequency
$f2 = 3;  ## -second frequency
$f3 = 5;  ## - 3-d frequency
$f4 = 7;  ## -4-th frequency
$Pi = 3.14159265358	;
$ph =$Pi/4; ## initial phase	=> 45 degree
    open OutFile, ">Wave_ROM128.v" || die "Cannot open file .V";    # file is open to write
                           
  	 
	print OutFile 	"//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
    print OutFile 	"//   ROM with ".$n." samples of the sine waves at the frequencies = ".$f1.", ".  $f2.",". $f3." and ".$f4 ."\n";
    print OutFile 	"//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n"; 
	print OutFile	"   `timescale 1 ns / 1 ps  \n";
	print OutFile	"module Wave_ROM128 ( ADDR ,DATA_RE,DATA_IM,DATA_REF ); \n";  
    print OutFile	"    	output [15:0] DATA_RE,DATA_IM,DATA_REF ;     \n";	
    print OutFile	"    	input [".($aw-1).":0]    ADDR ;     \n";		


# # Cosine table generation
    print OutFile	"    	reg [15:0] cosi[0:".($n-1)."];    \n";	
    print OutFile	"    	initial	  begin    \n";	
	for $j(0..$n/16-1){ 
	  $cos_row=0;
	 for $i(0..15){ 
$CosArr=(32767*cos(2*$Pi*$f1*(($n0+$i+16*$j)/$n)));	#23170
#	$CosArr=(16384*cos(2*$Pi*$f1*(($n0+$i+$j*16)/$n)));
#	                 +16383*cos(2*$Pi*$f2*(($n0+$i+$j*16)/$n))); 
#	$CosArr=(8191*cos($ph+2*$Pi*$f1*(($n0+$i+$j*16)/$n))
   #              +8191*cos($ph+2*$Pi*$f2*(($n0+$i+$j*16)/$n))
	#			 +8191*cos($ph+2*$Pi*$f3*(($n0+$i+$j*16)/$n))
	   #              +8191*cos($ph+2*$Pi*$f4*(($n0+$i+$j*16)/$n))); 
	    $sinv= To_Hex4(int ($CosArr));

	print OutFile	" cosi[".($n0+$i+$j*16)."]=16'h".$sinv.";";
}				
print OutFile "\n";    
}	
print OutFile "     end \n\n";	
   	 print "\n";			
# # Sine table generation
    print OutFile	"    	reg [15:0] sine[0:".($n-1)."];    \n";	
    print OutFile	"    	initial	  begin    \n";	
	 	for $j(0..$n/16-1){ 
	  $sin_row=0;
	 for $i(0..15){ 
	$SinArr=(32767*sin(2*$Pi*$f1*(($n0+$i+16*$j)/$n)));	   #16384	   23170
# 	$SinArr=(16384*sin(2*$Pi*$f1*(($n0+$i+$j*16)/$n)));	   #
#	                 +16383*sin(2*$Pi*$f2*(($n0+$i+$j*16)/$n))); 	
# 	$SinArr=(8191*sin($ph+2*$Pi*$f1*(($n0+$i+$j*16)/$n))
	#                 +8191*sin($ph+2*$Pi*$f2*(($n0+$i+$j*16)/$n))
		#			 +8191*sin($ph+2*$Pi*$f3*(($n0+$i+$j*16)/$n))
	       #          +8191*sin($ph+2*$Pi*$f4*(($n0+$i+$j*16)/$n))); 


	    $sinv= To_Hex4(int ($SinArr));

	print OutFile	" sine[".($n0+$i+$j*16)."]=16'h".$sinv.";";
}				
print OutFile "\n"; 
}	 
   	 print "\n";				   
print OutFile "      end \n\n";			 

##Reference table generation
    print OutFile	"    	reg [15:0] deltas[0:".($n-1)."];    \n";	
    print OutFile	"    	initial	  begin    \n";	
 	for $j(0..$n/4-1){ 													   
	 for $i(0..3){ 
	print OutFile	" deltas[".($n0+$i+$j*4)."]=16'h0000;";
}				
print OutFile "\n"; 
}	 					  
##print OutFile	" deltas[".$f1."]=16'h3fff;  deltas[".$f2."]=16'h3fff;\n";
$SinMag=To_Hex4(int (8191*4*sin($ph)));

print OutFile	" deltas[".$f1."]=16'h".$SinMag."; deltas[".$f2."]=16'h".$SinMag."; deltas[".$f3."]=16'h".$SinMag."; deltas[".$f4."]=16'h".$SinMag.";\n";
print OutFile "     end \n\n";			 

print OutFile "	assign DATA_RE=cosi[ADDR];	\n";
print OutFile "	assign DATA_IM=sine[ADDR];	\n";
print OutFile "	assign DATA_REF=deltas[ADDR];	\n";
print OutFile "endmodule   \n";
			
   close(OutFile);	  
   
   	
   sub To_Hex2{ 
 	my(%Hexnumbers)= (0,0,1,1,2,2,3,3,
   			4,4,5,5,6,6,7,7,
			8,8,9,9,10,'A',11,'B',
			12,'C',13,'D',14,'E',15,'F'); 		  
   
	$_[0]=($_[0]>=0) ? $_[0] : 256+$_[0];
	my($h21)=$_[0] % 16; 
	my($h22)=int($_[0] / 16);
	return $Hexnumbers{$h22}.$Hexnumbers{$h21};
   }; 
   
    sub To_Hex4{ 
 	my(%Hexnumbers)= (0,0,1,1,2,2,3,3,
   			4,4,5,5,6,6,7,7,
			8,8,9,9,10,'A',11,'B',
			12,'C',13,'D',14,'E',15,'F'); 		  
   
   $_[0]=($_[0]>=0) ? $_[0] : 65536+$_[0];
	my($h21)=$_[0] % 16; 
	my($r21)=int($_[0] / 16); 
	my($h22)=$r21 % 16;
	my($r22)=int($r21 / 16);
	my($h23)=$r22 % 16;
	my($h24)=int($r22 / 16); 
   return $Hexnumbers{$h24}.$Hexnumbers{$h23}.$Hexnumbers{$h22}.$Hexnumbers{$h21};
  ##return $_[0];
  };
  
	  open (File, "Wave_ROM128.v") || die  "Cannot open r";
	  while ($line = <File>)
       {
           print $line;         # Ready file output to the screen
		   }
   
	  
	  close(File);
