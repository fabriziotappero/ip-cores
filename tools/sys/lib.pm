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
#/*    Copyright (C) <2010-2011>  <Ouabache Design Works>              */
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

package sys::lib;

#/*********************************************************************************************/
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/*********************************************************************************************/

sub trim_sort {
   my @output_files  = @_;
   my %trim = ();
   foreach my $descriptor (@output_files) { $trim{$descriptor}  = 1; }
   my @k = keys %trim;
   @output_files =  sort(sort @k);  
   return(@output_files);
   }


#/*********************************************************************************************/
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/                                                                                            */
#/*********************************************************************************************/

# recursively map directory information 

sub link_dir {
    my $src  = shift;
    my $dest = shift;
    return unless( -e $src );

    if( -d $src ) 
        {

        mkdir $dest,0755;
        my @contents = (  );
        opendir( DIR, $src );
        while( my $item = readdir( DIR )) 
            {
            next if( $item eq '.' or $item eq '..'   or $item eq '.svn'    );
            push( @contents, $item );
            }
        closedir( DIR );
 
        # recurse on items in the directory
        foreach my $item ( @contents )          { &link_dir("$src/$item", "$dest/$item" );}
 

       } 
       else  {symlink( "${src}", "${dest}") unless( -e "${dest}" ); }
}






1;
