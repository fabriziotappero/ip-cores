#!/usr/bin/perl -w

use strict;
my $fsm = pop @ARGV;

if (defined $fsm)
{
  my $contents = `cat $fsm`;
  
  my ($others) = $contents =~ /(\w+.+?\=\>)/;
  
  while ($others !~ /others.+\=\>/ and defined $others)
  {
    $contents =~ s/\=\>(.*\n(?:.*?\n)*?)(.+=\>)/\:\n\t\t\t\t\t\tbegin\n$1\n\t\t\t      end\n$2/;
    ($others) = $contents =~ /(\w+.+?\=\>)/;
  }
  
  $contents =~ s/others.+\=\>\n((?:.+\n)*.+)end.*?case/default :\n\t\t\t\t\t\tbegin\n$1\tend\n\t\t\t\t\t\tendcase/;
  
  $contents   =~ s/\'(\d)\'/1\'b$1/g;
  print $contents;
}
else
{
  print "Please supply a VHDL fsm to parse\n";
}


