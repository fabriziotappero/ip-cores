use strict;
use warnings;

print "Enter the Number of Rungs :\n";
my $rung_num = <>;
chomp($rung_num);

my (@inp_array, @out_array, @inst_array);
@inp_array = ('I0', 'I1', 'I2', 'I3', 'I4', 'I5', 'I6');
@out_array = ('O0', 'O1', 'O2', 'O3', 'O4', 'O5', 'O6');
@inst_array = ('LD', 'ST', 'AND', 'OR', 'N');

#Loop for Creating Instructions in a rung
open my $file_out, ">", "PLC_instruction.txt";

for (my $i = 1; $i <= $rung_num ; $i++)
{
my $instr_num = int(rand(10)) + 1;
  
  for (my $j = 1; $j <= $instr_num; $j++)
  {
  #print {$file_out} $i,".",$j, " ";
    if ($j == 1)
    {
    print {$file_out} $inst_array[0], " ";
    print {$file_out} $inp_array[int(rand(6))], "\n";
    }
	elsif ($j == $rung_num)
	{
	print {$file_out} $inst_array[1], " ";
    print {$file_out} $out_array[int(rand(6))], "\n";
	}
	else
	{
	print {$file_out} $inst_array[int(rand(3))+1], " ";
    print {$file_out} $inp_array[int(rand(6))], "\n";
	}
  }	
print {$file_out} "ENDOFRUNG", "\n";
#print {$file_out} "\n";
}
close($file_out);

