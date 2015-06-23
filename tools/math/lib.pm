#/**********************************************************************/
#/*                                                                    */
#/*             -------                                                */
#/*            /   SOC  \                                              */
#/*           /    GEN   \                                             */
#/*          /    TOOL    \                                            */
#/*          ==============                                            */
#/*          |            |                                            */
#/*          |____________|                                            */
#/*                                                                    */
#/*                                                                    */
#/*                                                                    */
#/*  Author(s):                                                        */
#/*      - John Eaton, jt_eaton@opencores.org                          */
#/*                                                                    */
#/**********************************************************************/
#/*                                                                    */
#/*    Copyright (C) <2010-2015>  <Ouabache Design Works>              */
#/*                                                                    */
#/*  This source file may be used and distributed without              */
#/*  restriction provided that this copyright statement is not         */
#/*  removed from the file and that any derivative work contains       */
#/*  the original copyright notice and the associated disclaimer.      */
#/*                                                                    */
#/*  This source file is free software; you can redistribute it        */
#/*  and/or modify it under the terms of the GNU Lesser General        */
#/*  Public License as published by the Free Software Foundation;      */
#/*  either version 2.1 of the License, or (at your option) any        */
#/*  later version.                                                    */
#/*                                                                    */
#/*  This source is distributed in the hope that it will be            */
#/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
#/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
#/*  PURPOSE.  See the GNU Lesser General Public License for more      */
#/*  details.                                                          */
#/*                                                                    */
#/*  You should have received a copy of the GNU Lesser General         */
#/*  Public License along with this source; if not, download it        */
#/*  from http://www.opencores.org/lgpl.shtml                          */
#/*                                                                    */
#/**********************************************************************/

use strict;
use warnings;

package math::lib;

#/*********************************************************************************************/
#/                                                                                            */
#/  Arithmetic parser                                                                         */
#/                                                                                            */
#/  parse a line and replace all occurrences of symbol with its value                         */
#/                                                                                            */
#/  my $line = math::lib::parse($line,$symbol,$value);                                        */
#/                                                                                            */
#/                                                                                            */
#/*********************************************************************************************/


sub parse {
    my $line  = shift;
    my $symbol  = shift;
    my $value  = shift;

    my $len = length $line;
    my $state         = "math";
    my $start_sym     = -1;
    my $stop_sym      = -1;
    my $match         = "___";
    my $math_only     = 0;




#    print "PARSE   $line $symbol $value $len  \n";
    if($symbol eq $value ) 
       {
       print "DANGER WILL ROBINSON      $line $symbol $value $len             \n";
       return();
       }

    for (my $i=0; $i < $len; $i++) 
        {
        my $char = substr($line,$i,1);
        $_ = $char;


        unless ($state eq "constant")
               {
               if(/[a-zA-Z_]/)
                 {
                 $state = "symbol";
                 $math_only = $math_only +1;
                 if($start_sym eq "-1") {$start_sym = $i;}
                 }
               }
        if(/[0-9+-\/]/)
          {
          if($state eq "symbol") {$stop_sym = $i;}
          $state = "math";
          }

        if(/[\*]/)
          {
          if($state eq "symbol")            {    $stop_sym = $i;}
          $state = "math";
          }


        if(/['`]/)
          {    
          $state = "constant";
          $math_only = $math_only +1;
          }

        if(($state ne "symbol") && (($stop_sym ne "-1")  ) )
          {
          my $str_len  = $stop_sym-$start_sym;
          my $substring = substr($line,$start_sym,$str_len);
          if($substring eq $symbol)
            {
            $match = "MATCH";
            $math_only = $math_only - $str_len;
            my $new_line = "";
            my $end_line = "";

            if($start_sym  eq "0") { $new_line  =$value; }
            else
               {
               $new_line  = substr($line,0,$start_sym);
               $new_line  ="${new_line}${value}";
               }
            my $line_len = $len - $stop_sym;
            $end_line = substr($line,$stop_sym,$line_len);
            $new_line  ="${new_line}${end_line}";
#            print "$substring $stop_sym  $start_sym  $str_len $match ==  $new_line  \n";
            $new_line = parse($new_line,$symbol,$value) ;
            return($new_line);
	    }
          else
            {
            $match = "NO_MATCH";
#            print "$substring $stop_sym  $start_sym  $str_len $match \n";
            }
          $start_sym  = -1;
          $stop_sym = -1;
          }

#        print "$i   $char  $state  $start_sym $stop_sym       \n";

        if(($state eq "symbol") && ($i eq $len -1) )
           {
           my $str_len  = $len-$start_sym;
           my $substring = substr($line,$start_sym,$str_len );

           if($substring eq $symbol)
              {
              $match = "MATCH";
              $math_only = $math_only - $str_len;
#              print "MATCH $substring $start_sym $str_len  \n";
              my $new_line = "";
              my $end_line = "";
              if($start_sym  eq "0") { $new_line  =$value;}
              else
                {
                $new_line  = substr($line,0,$start_sym);
                $new_line  ="${new_line}${value}";
                }
 
#              print "Recursion  $math_only  $new_line  \n";
              return(parse($new_line,$symbol,$value));

	      }
           else
              {
              $match = "NO_MATCH";
#              print "$substring $stop_sym  $start_sym  $str_len $match \n";
              }
	   }

         }
#     print "$math_only  $line  \n";
     if($math_only eq 0)     { return (  solve($line));}
     else                    { return ($line);}

}




sub solve {

my $line  = shift;
#   print "SOLVE $line  \n";

$line = "0${line}";
#my $result = `./tools/math/perl_arith $line `;
#chomp($result);
#print   "MMMMMMMMM  $line  || $result  ||";


my $result = `./tools/math/c_arith $line `;
chomp($result);

#if($result ne  $result2)
#   {
#   print " $result2    MISMATCH \n";
#   }
#else
#   {
#   print " $result2 \n";
#   }

return ($result);
}
1




