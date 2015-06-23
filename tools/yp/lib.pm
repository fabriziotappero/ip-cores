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

package yp::lib;


############################################################################
# General PERL config
############################################################################
use Getopt::Long;
use English;
use File::Basename;
use Cwd;
use XML::LibXML;
use lib './tools';
use sys::lib;
use BerkeleyDB;


$OUTPUT_AUTOFLUSH = 1; # set autoflush of stdout to TRUE.






my $home         = cwd();


my $parser = XML::LibXML->new();



my    $workspace_xml    = $parser->parse_file("${home}/workspace.xml"); 
my @repos =();
my $repo;


foreach my $repo ($workspace_xml->findnodes('//socgen:workspace/socgen:repos/socgen:repo')) 
                  {
                  my $repo_name  = $repo->findnodes('./socgen:name/text()')->to_literal ;
                  push  @repos,$repo_name;                   
                  }







my $number_of_cpus;
my $workspace;
my $yellow_pages;
my $io_ports;
my $doc_dir;


foreach my $repo ($workspace_xml->findnodes('//socgen:workspace')) 
                  {
                  $number_of_cpus  = $repo->findnodes('./socgen:number_of_cpus/text()')->to_literal ;
                  $workspace       = $repo->findnodes('./socgen:build_dir/text()')->to_literal ;
                  $yellow_pages    = $repo->findnodes('./socgen:yp_dir/text()')->to_literal ;
                  $io_ports        = $repo->findnodes('./socgen:ports_dir/text()')->to_literal ;
                  $doc_dir         = $repo->findnodes('./socgen:doc_dir/text()')->to_literal ;

                  }

unless(defined $number_of_cpus)  {    $number_of_cpus = 1;         }
unless(defined $workspace     )  {    $workspace      = "work";    }
unless(defined $yellow_pages  )  {    $yellow_pages   = "yp";      }
unless(defined $io_ports      )  {    $io_ports       = "io_ports";}
unless(defined $doc_dir       )  {    $doc_dir        = "doc_dir"; }

#print "number_of_cpus  $number_of_cpus  \n";
#print "workspace       $workspace  \n";
#print "yellow_pages    $yellow_pages  \n";
#print "io_ports        $io_ports  \n";

my $path  = "${home}/${yellow_pages}";

unless( -e $path )
{
print "$path does not exist \n";
my $cmd = "./tools/yp/create_yp $path \n";
if(system($cmd)){};
}

my $repo_db                     = new BerkeleyDB::Hash( -Filename => "${yellow_pages}/repo.dbm", -Flags => DB_CREATE ) or die "Cannot open file: $!";
my $component_db                = new BerkeleyDB::Hash( -Filename => "${yellow_pages}/component.dbm", -Flags => DB_CREATE ) or die "Cannot open file: $!";
my $design_db                   = new BerkeleyDB::Hash( -Filename => "${yellow_pages}/design.dbm", -Flags => DB_CREATE ) or die "Cannot open file: $!";
my $abstractionDefinition_db    = new BerkeleyDB::Hash( -Filename => "${yellow_pages}/abstractionDefinition.dbm", -Flags => DB_CREATE ) or die "Cannot open file: $!";
my $busDefinition_db            = new BerkeleyDB::Hash( -Filename => "${yellow_pages}/busDefinition.dbm", -Flags => DB_CREATE ) or die "Cannot open file: $!";
my $libraryConfiguration_db     = new BerkeleyDB::Hash( -Filename => "${yellow_pages}/libraryConfiguration.dbm", -Flags => DB_CREATE ) or die "Cannot open file: $!";
my $componentConfiguration_db   = new BerkeleyDB::Hash( -Filename => "${yellow_pages}/componentConfiguration.dbm", -Flags => DB_CREATE ) or die "Cannot open file: $!";


#/***********************************************************************************************/
#/  get_workspace                                                                               */
#/                                                                                              */
#/  returns name for the workspace subdirectory under ${home}                                   */
#/                                                                                              */
#/  my $workspace = yp::lib::get_workspace();                                                   */
#/                                                                                              */
#/***********************************************************************************************/

sub get_workspace
   {
   return("${workspace}");
   }



#/***********************************************************************************************/
#/  get_yp                                                                                      */
#/                                                                                              */
#/  returns name for the yellow_pages subdirectory under ${home}                                */
#/                                                                                              */
#/  my $workspace = yp::lib::get_yp();                                                          */
#/                                                                                              */
#/***********************************************************************************************/

sub get_yp
   {
   return("${yellow_pages}");
   }





#/***********************************************************************************************/
#/  get_io_ports                                                                                */
#/                                                                                              */
#/  returns name for the io_ports subdirectory under ${home}                                    */
#/                                                                                              */
#/  my $workspace = yp::lib::get_io_ports();                                                    */
#/                                                                                              */
#/***********************************************************************************************/

sub get_io_ports
   {
   return("${io_ports}");
   }

#/***********************************************************************************************/
#/  get_doc_dir                                                                                 */
#/                                                                                              */
#/  returns name for the documentation  subdirectory under ${home}                              */
#/                                                                                              */
#/  my $workspace = yp::lib::get_doc_dir ();                                                    */
#/                                                                                              */
#/***********************************************************************************************/

sub get_doc_dir
   {
   return("${doc_dir}");
   }



#/***********************************************************************************************/
#/  get_number_of_cpus                                                                          */
#/                                                                                              */
#/  returns number of cpus available for tool usage                                             */
#/                                                                                              */
#/  my $number_of_cpus = yp::lib::get_number_of_cpus ();                                        */
#/                                                                                              */
#/***********************************************************************************************/

sub get_number_of_cpus
   {
   return("${number_of_cpus}");
   }




#/***************************************************************************************************/
#/  get_io_ports_db_filename                                                                        */
#/                                                                                                  */
#/  returns full path name to io_ports database filename                                            */
#/                                                                                                  */
#/  my $io_ports_filename = yp::lib::get_io_ports_db_filename($vendor,$library,$component,$version);*/
#/                                                                                                  */
#/***************************************************************************************************/

sub get_io_ports_db_filename
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $main_module_name = yp::lib::get_module_name($vendor,$library,$component,$version) ;
   my $io_ports_db_filename = "${home}/${io_ports}/${vendor}__${library}/${component}/${main_module_name}/PORTS.dbm";

   if(-e ${io_ports_db_filename } ) 
     { 
     return("${io_ports_db_filename}");
     }
   my $cmd = "./tools/verilog/gen_ports    -vendor $vendor -library  $library  -component $component  -version $version   ";
   if (system($cmd)) {}
   return("${io_ports_db_filename}");
   }





#/*************************************************************************************************************/
#/  get_io_busses_db_filename                                                                                 */
#/                                                                                                            */
#/  returns full path name to io_busses database filename                                                     */
#/                                                                                                            */
#/  my $io_busses_filename = yp::lib::get_io_busses_db_filename($vendor,$library,$component,$version,config); */
#/                                                                                                            */
#/*************************************************************************************************************/

sub get_io_busses_db_filename
   {
   my @params     = @_;
   my $config     = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $main_module_name = yp::lib::get_module_name($vendor,$library,$component,$version) ;
   my $io_busses_db_filename;

   if(defined $config && length $config > 0)   
   {
   $io_busses_db_filename = "${home}/${io_ports}/${vendor}__${library}/${component}/${main_module_name}/BUSSES.dbm";
   }
   else
   {
   $io_busses_db_filename = "${home}/${io_ports}/${vendor}__${library}/${component}/${main_module_name}/${config}/BUSSES.dbm";
   }


   if(-e ${io_busses_db_filename } ) 
     { 
     return("${io_busses_db_filename}");
     }
   my $cmd = "./tools/verilog/gen_ports    -vendor $vendor -library  $library  -component $component  -version $version   ";
   if (system($cmd)) {}
   return("${io_busses_db_filename}");
   }



#/******************************************************************************************************/
#/  get_io_busses_name_db_filename                                                                     */
#/                                                                                                     */
#/  returns full path name to io_busses database named filename                                        */
#/                                                                                                     */
#/  my $io_busses_filename = yp::lib::get_io_busses_name_db_filename($vendor,$library,$component,$version); */
#/                                                                                                     */
#/******************************************************************************************************/

sub get_io_busses_named_db_filename
   {
   my @params     = @_;
   my $name       = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $main_module_name = yp::lib::get_module_name($vendor,$library,$component,$version) ;
   my $io_busses_db_filename = "${home}/${io_ports}/${vendor}__${library}/${component}/${main_module_name}_${name}/BUSSES.dbm";

   if(-e ${io_busses_db_filename } ) 
     { 
     return("${io_busses_db_filename}");
     }
   my $cmd = "./tools/verilog/gen_ports    -vendor $vendor -library  $library  -component $component  -version $version   ";
   if (system($cmd)) {}
   return("${io_busses_db_filename}");
   }





#/***********************************************************************************************************/
#/  get_elab_db_filename                                                                                    */
#/                                                                                                          */
#/  returns full path name to elab database filename                                                        */
#/                                                                                                          */
#/  my $elab_filename = yp::lib::get_elab_db_filename($vendor,$library,$component,$version,$configuration); */
#/                                                                                                          */
#/***********************************************************************************************************/

sub get_elab_db_filename
   {
   my @params     = @_;
   my $configuration    = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   
   my $elab_db_filename;

   mkdir "${home}/dbs",0755  unless (-e "${home}/dbs" );

   if($configuration eq "xxxxxx")
   {
    $elab_db_filename = "${home}/dbs/${vendor}_${library}_${component}_${version}.db";
   }
   else
   {
    $elab_db_filename = "${home}/dbs/${vendor}_${library}_${component}_${version}_${configuration}.db";
   }

   return("${elab_db_filename}");
   }




#/***********************************************************************************************************/
#/  get_design_db_file                                                                                      */
#/                                                                                                          */
#/  returns full path name to design database filename                                                      */
#/                                                                                                          */
#/  my $design_db_file = yp::lib::get_design_db_file;  */
#/                                                                                                          */
#/***********************************************************************************************************/

sub get_design_db_file
   {

   mkdir "${home}/dbs",0755  unless (-e "${home}/dbs" );
   return("${home}/dbs/design.dbm");
   }






#/***************************************************************************************************/
#/  get_component configs                                                                           */
#/                                                                                                  */
#/  returns array of config_n's for component                                                       */
#/                                                                                                  */
#/  my @configs  = yp::lib::get_component_configs($vendor,$library,$component,$version);            */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_component_configs
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $main_module_name = yp::lib::get_module_name($vendor,$library,$component,$version) ;
   my $Config_db_file = "${io_ports}/${vendor}__${library}/${component}/${main_module_name}/Config.db";

   unless(-e $Config_db_file  ){return();}

   my  $config_db   = new BerkeleyDB::Hash( -Filename => $Config_db_file, -Flags => DB_CREATE ) or die "Cannot open ${Config_db_file}: $!";
   my  @configs  = (); 
   my  $key;
   my  $value;
   my  $port_cursor = $config_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {
          push (@configs, $key);       
          }
   my  $status = $port_cursor->c_close() ;
       $config_db   -> db_close();
   return(@configs);

   }








#/***************************************************************************************************/
#/  get_signals                                                                                     */
#/                                                                                                  */
#/  returns array of all signals in a component                                                     */
#/                                                                                                  */
#/  my @signals  = yp::lib::get_signals($vendor,$library,$component,$version);                      */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_signals
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $io_ports_db_filename = yp::lib::get_io_ports_db_filename($vendor,$library,$component,$version);
   unless (-e ${io_ports_db_filename } ) 
      { 

      my $cmd = "./tools/verilog/gen_ports    -vendor $vendor -library  $library  -component $component  -version $version   ";
      if (system($cmd)) {}
         $cmd = "./tools/verilog/gen_signals  -vendor $vendor -library  $library  -component $component  -version $version   ";
      if (system($cmd)) {}
      }



   my  $ports_db   = new BerkeleyDB::Hash( -Filename => $io_ports_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${io_ports_db_filename}: $!";
   my  @signals  = (); 
   my  $key;
   my  $value;
   my  $port_cursor = $ports_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {

          push (@signals, $value);       
          }
   my  $status = $port_cursor->c_close() ;

       @signals      = sys::lib::trim_sort(@signals);

       $ports_db   -> db_close();
   return(@signals);
   }







#/***************************************************************************************************/
#/  get_Parameters                                                                                  */
#/                                                                                                  */
#/  returns array of all instance parameters in a component                                         */
#/                                                                                                  */
#/  my @parameters  = yp::lib::get_Parameters($vendor,$library,$component,$version,$instance,$configuration);      */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_Parameters
   {
   my @params     = @_;
   my $configuration = pop(@params);
   my $instance   = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $elab_db_filename = yp::lib::get_elab_db_filename($vendor,$library,$component,$version,$configuration);
   my  $ports_db   = new BerkeleyDB::Hash( -Filename => $elab_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${elab_db_filename}: $!";
   my  @parameters  = (); 
   my  $key;
   my  $value;
   my  $port_cursor = $ports_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {
	  my $parameter_root;
	  my $parameter;
          ( $parameter_root,$parameter) = split( /\__/ , $key);
          if($parameter_root eq "Parameter_${instance}")
            {
            push (@parameters, "${parameter}::${value}");       
            }
          }

   my  $status = $port_cursor->c_close() ;
       $ports_db   -> db_close();
       @parameters      = sys::lib::trim_sort(@parameters);
   return(@parameters);
   }




#/***************************************************************************************************/
#/  get_parameters                                                                                  */
#/                                                                                                  */
#/  returns array of all parameters in a component                                                  */
#/                                                                                                  */
#/  my @parameters  = yp::lib::get_parameters($vendor,$library,$component,$version,$configuration);                */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_parameters
   {
   my @params     = @_;
   my $configuration    = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $elab_db_filename = yp::lib::get_elab_db_filename($vendor,$library,$component,$version,$configuration);
   my  $ports_db   = new BerkeleyDB::Hash( -Filename => $elab_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${elab_db_filename}: $!";
   my  @parameters  = (); 
   my  $key;
   my  $value;
   my  $port_cursor = $ports_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {
	  my $parameter_root;
	  my $parameter;
          ( $parameter_root,$parameter) = split( /\__/ , $key);
          if($parameter_root eq "parameter_root")
            {
            push (@parameters, "${parameter}::${value}");       
            }
          }

   my  $status = $port_cursor->c_close() ;
       $ports_db   -> db_close();
       @parameters      = sys::lib::trim_sort(@parameters);
   return(@parameters);
   }






#/***************************************************************************************************/
#/  get_instance_names                                                                              */
#/                                                                                                  */
#/  returns array of all instance_names in a component                                              */
#/                                                                                                  */
#/  my @instance_names  = yp::lib::get_instance_names($vendor,$library,$component,$version,$configuration);        */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_instance_names
   {
   my @params     = @_;
   my $configuration    = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $elab_db_filename = yp::lib::get_elab_db_filename($vendor,$library,$component,$version,$configuration);
   my  $ports_db   = new BerkeleyDB::Hash( -Filename => $elab_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${elab_db_filename}: $!";
   my  @instance_names  = ();
   my  $field1;
   my  $field2;
   my  $key;
   my  $value;


   my  $port_cursor = $ports_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {
          ( $field1,$field2) = split( /\./ , $key);


          if(($field1 eq "component___root")&& ($key eq "${field1}.${field2}"   )  )
            {

            push (@instance_names, "${field2}");       
            }
          }

   my  $status = $port_cursor->c_close() ;
       $ports_db   -> db_close();
       @instance_names      = sys::lib::trim_sort(@instance_names);
   return(@instance_names);
   }



#/***********************************************************************************************************/
#/  get_instance_module_name                                                                                */
#/                                                                                                          */
#/  returns the module name of an instance                                                                  */
#/                                                                                                          */
#/  my $module_name  = yp::lib::get_instance_module_name($vendor,$library,$component,$version,$instance,$configuration );  */
#/                                                                                                          */
#/***********************************************************************************************************/

sub get_instance_module_name
   {
   my @params     = @_;
   my $configuration   = pop(@params);
   my $instance   = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $elab_db_filename = yp::lib::get_elab_db_filename($vendor,$library,$component,$version,$configuration);
   my $elab_db   = new BerkeleyDB::Hash( -Filename => $elab_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${elab_db_filename}: $!";
   my $module_name;
   my $module_vlnv;
   my $module_vendor;
   my $module_library;
   my $module_component;
   my $module_version;
   $elab_db->db_get("component___root.${instance}", $module_vlnv );
   ( $module_vendor,$module_library,$module_component,$module_version) = split( /\:/ , $module_vlnv);
     $module_name = yp::lib::get_module_name($module_vendor,$module_library,$module_component,$module_version) ;
       $elab_db   -> db_close();
   return($module_name);
   }




#/*************************************************************************************************************/
#/  get_instance_vlnvc                                                                                        */
#/                                                                                                            */
#/  returns the ven,lib,cmp,ver,cfg  name for a components instance                                           */
#/                                                                                                            */
#/  my $vlnvc  = yp::lib::get_instance_vlnvc($vendor,$library,$component,$version,$instance,$configuration ); */
#/                                                                                                            */
#/*************************************************************************************************************/

sub get_instance_vlnvc
   {
   my @params     = @_;
   my $configuration     = pop(@params);
   my $instance          = pop(@params);
   my $version           = pop(@params);
   my $component         = pop(@params);
   my $library           = pop(@params);
   my $vendor            = pop(@params);
   my $elab_db_filename  = yp::lib::get_elab_db_filename($vendor,$library,$component,$version,$configuration);
   my $elab_db           = new BerkeleyDB::Hash( -Filename => $elab_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${elab_db_filename}: $!";

   my $module_vlnv;

   $elab_db->db_get("component___root.${instance}", $module_vlnv );
       $elab_db   -> db_close();
   return($module_vlnv);
   }






#/*********************************************************************************************************/
#/  get_instance_conns                                                                                    */
#/                                                                                                        */
#/  returns array of all connections to an instance                                                       */
#/                                                                                                        */
#/  my @inst_conns  = yp::lib::get_instance_conns($vendor,$library,$component,$version,$instance);        */
#/                                                                                                        */
#/*********************************************************************************************************/

sub get_instance_conns
   {
   my @params     = @_;
   my $instance   = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $io_busses_db_filename = yp::lib::get_io_busses_db_filename($vendor,$library,$component,$version,"default");




   unless (-e ${io_busses_db_filename } ) 
      { 

      my $cmd = "./tools/verilog/gen_ports    -vendor $vendor -library  $library  -component $component  -version $version   ";
      if (system($cmd)) {}
         $cmd = "./tools/verilog/gen_signals  -vendor $vendor -library  $library  -component $component  -version $version   ";
      if (system($cmd)) {}
      }



   my  $ports_db   = new BerkeleyDB::Hash( -Filename => $io_busses_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${io_busses_db_filename}: $!";
   my  @inst_conns  = (); 
   my  $key;
   my  $value;
   my  $port_cursor = $ports_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {
	  my $Instance;
          my $instance_name;
          my $instance_busref;
          ( $Instance,$instance_name,$instance_busref) = split( /\./ , $key);
          if(($Instance eq "Instance")&& ($instance eq $instance_name))
      	    {
            my $new_key;
	    my $new_value;
            my  $bus_cursor = $ports_db->db_cursor() ;
          while ($bus_cursor->c_get($new_key, $new_value, DB_NEXT) == 0) 
          {
	  my $IXstance;
          my $IX_inst;
          my $IX_busref;
          my $IX_port;
          ( $IXstance,$IX_inst,$IX_busref,$IX_port) = split( /\./ , $new_key);
          if(($IXstance eq "IXstance") && ($IX_inst eq $instance_name) &&($IX_busref eq $instance_busref) )
      	    {
	    my $logname;
            my $direction;
            my $wire;
            my $vector;
            my $left;
            my $right;
            my $port;
            ($logname,$direction,$wire,$vector,$left,$right,$port ) = split( /\:/ , $new_value);
            my $type;
            my $signal;

            $ports_db->db_get("BusRef.${value}.${IX_port}", $new_value );


            ($logname,$type,$wire,$vector,$left,$right,$signal ) = split( /\:/ , $new_value);


               if($vector eq "vector")
                {               
                push (@inst_conns, ".${port}      ( ${signal}[${left}:${right}]  )");       
                }
               else
                {               
                push (@inst_conns, ".${port}      ( ${signal}  )");       
                }
            }
	  }
          my  $status = $bus_cursor->c_close() ;






            }
          }
   my  $status = $port_cursor->c_close() ;
       $ports_db   -> db_close();
       @inst_conns      = sys::lib::trim_sort(@inst_conns);
   return(@inst_conns);
   }




#/*********************************************************************************************************/
#/  get_instance_adhoc_conns                                                                                    */
#/                                                                                                        */
#/  returns array of all connections to an instance                                                       */
#/                                                                                                        */
#/  my @inst_conns  = yp::lib::get_instance_adhoc_conns($vendor,$library,$component,$version,$instance);  */
#/                                                                                                        */
#/*********************************************************************************************************/

sub get_instance_adhoc_conns
   {
   my @params     = @_;
   my $instance   = pop(@params);
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $io_busses_db_filename = yp::lib::get_io_busses_db_filename($vendor,$library,$component,$version,"default");

   unless (-e ${io_busses_db_filename } ) 
      { 

      my $cmd = "./tools/verilog/gen_ports    -vendor $vendor -library  $library  -component $component  -version $version   ";
      if (system($cmd)) {}
         $cmd = "./tools/verilog/gen_signals  -vendor $vendor -library  $library  -component $component  -version $version   ";
      if (system($cmd)) {}
      }



   my  $ports_db   = new BerkeleyDB::Hash( -Filename => $io_busses_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${io_busses_db_filename}: $!";
   my  @inst_conns  = (); 
   my  $key;
   my  $value;
   my  $port_cursor = $ports_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {

	  my $adhoc_inst;
          my $port;
          ( $adhoc_inst,$port) = split( /\__/ , $key);
          if($adhoc_inst eq "AdHoc_${instance}")
             {
		 my $sig1;
                 my $sig2;
		 my $wire;
                 my $vector;
		 my $left;
                 my $right;
	    


          ( $sig1,$sig2,$wire,$vector,$left,$right) = split( /\:/ , $value);

		 if($sig1 eq "***") {$sig1 = "   ";}
              if($vector eq "vector")
              {
               push (@inst_conns, " .${port}      ( ${sig1}[${left}:${right}] )");       
              }
              else
              {
               push (@inst_conns, " .${port}      ( ${sig1}  )");       
              }

             }

          }
   my  $status = $port_cursor->c_close() ;
       $ports_db   -> db_close();
       @inst_conns      = sys::lib::trim_sort(@inst_conns);
   return(@inst_conns);
   }








#/***************************************************************************************************/
#/  get_busses                                                                                     */
#/                                                                                                  */
#/  returns array of all busses in a component                                                     */
#/                                                                                                  */
#/  my @signals  = yp::lib::get_busses($vendor,$library,$component,$version);                      */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_busses
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);


   my $io_busses_db_filename = yp::lib::get_io_busses_db_filename($vendor,$library,$component,$version,"default");

   unless (-e ${io_busses_db_filename } ) 
      { 

      my $cmd = "./tools/verilog/gen_ports    -vendor $vendor -library  $library  -component $component  -version $version   ";
      if (system($cmd)) {}
      }

   my  $ports_db   = new BerkeleyDB::Hash( -Filename => $io_busses_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${io_busses_db_filename}: $!";
   my  @busses  = (); 
   my  $key;
   my  $value;
   my  ${key_type};
   my  ${busref};
   my  ${conn};
   my  ${log_name};
   my  ${direction};
   my  ${type};
   my  ${vector};
   my  ${left};
   my  ${right};
   my  ${phy_name};
   my  $port_cursor = $ports_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {
          ( ${key_type},${busref},${conn}) = split( /\./ , $key);
          ( ${log_name},${direction},${type},${vector},${left},${right},${phy_name}) = split ':', $value;

           if(($key_type eq "BusRef"))
              {
              push (@busses,  "${busref}:::${conn}:::${phy_name}:::${log_name}:::${direction}:::${type}:::${vector}:::${left}:::${right}");
              }
          }
   my  $status = $port_cursor->c_close() ;
       $ports_db   -> db_close();
   @busses      = sys::lib::trim_sort(@busses);
   return(@busses);
   }



#/***************************************************************************************************/
#/  get_files                                                                                       */
#/                                                                                                  */
#/  returns array of all verilog usertypes in a component                                           */
#/                                                                                                  */
#/  my @fragments  = yp::lib::get_fragments($vendor,$library,$component,$version,$fileSet_name);    */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_files
   {
   my @params     = @_;
   my $userType       = pop(@params);
   my $fileSet_name   = pop(@params);
   my $version        = pop(@params);
   my $component      = pop(@params);
   my $library        = pop(@params);
   my $vendor         = pop(@params);
   my $elab_db_filename = yp::lib::get_elab_db_filename($vendor,$library,$component,$version,"default");
   my  $elab_db   = new BerkeleyDB::Hash( -Filename => $elab_db_filename, -Flags => DB_CREATE ) or die "Cannot open ${elab_db_filename}: $!";
   my  @files  = (); 
   my  $key;
   my  $value;
   my  $port_cursor = $elab_db->db_cursor() ;
       while ($port_cursor->c_get($key, $value, DB_NEXT) == 0) 
          {
	  my $FILE_root;
	  my $fragment;
          ( $FILE_root,$fragment) = split( /\__/ , $key);
          if($FILE_root eq "FILE_verilogSource_${fileSet_name}_${userType}")
            {
            push (@files, "${value}");       
            }
          }

   my  $status = $port_cursor->c_close() ;
       $elab_db   -> db_close();
       @files      = sys::lib::trim_sort(@files);
   return(@files);
   }







#/***************************************************************************************************/
#/  get_absDef_db_filename                                                                          */
#/                                                                                                  */
#/  returns full path name to abstractionDefinition database filename                               */
#/                                                                                                  */
#/  my $absDef_filename = yp::lib::get_absDef_db_filename($vendor,$library,$component,$version);    */
#/                                                                                                  */
#/***************************************************************************************************/

sub get_absDef_db_filename
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $absDef_db_filename = "${io_ports}/${vendor}__${library}/${component}/${component}_${version}_ABSDEF.dbm";

   if(-e ${absDef_db_filename } ) 
     { 
     return("${absDef_db_filename}");
     }
   my $cmd = "./tools/busdefs/gen_busdef    -vendor $vendor -library $library  -component $component  -version $version   ";
   if (system($cmd)) {}

   return("${absDef_db_filename}");
   }









#/***********************************************************************************************/
#/  find_ipxact_component                                                                       */
#/                                                                                              */
#/  returns full path name to ip-xact component file                                            */
#/                                                                                              */
#/  my $spirit_type_file = yp::lib::find_ipxact_component($vendor,$library,$component,$version);*/
#/                                                                                              */
#/***********************************************************************************************/

sub find_ipxact_component
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $comp_data;
   my $component_version;
   my $component_xml;
   my $comp_xml_sep;
      $component_db->db_get("${vendor}__${library}_${component}_${version}", $comp_data );
      ( $component_xml, $comp_xml_sep,$component_version ) = split ':', $comp_data;

      return("$component_xml");
   }



#/***********************************************************************************************/
#/  find_ipxact_design                                                                          */
#/                                                                                              */
#/  returns full path name to ip-xact design file                                               */
#/                                                                                              */
#/  my $spirit_type_file = yp::lib::find_ipxact_design($vendor,$library,$component,$version);   */
#/                                                                                              */
#/***********************************************************************************************/

sub find_ipxact_design
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $data;
   my $design_xml_sep ;
   my $design_xml_file ;
   my $design_version;

      $design_db->db_get("${vendor}__${library}_${component}_${version}", $data );
      ( $design_xml_file, $design_xml_sep,$design_version ) = split ':', $data;

      return("$design_xml_file");
   }


#/**************************************************************************************************************/
#/  find_ipxact_abstractionDefinition                                                                          */
#/                                                                                                             */
#/  returns full path name to ip-xact abstractionDefinition file                                               */
#/                                                                                                             */
#/  my $spirit_type_file = yp::lib::find_ipxact_abstractionDefinition($vendor,$library,$component,$version);   */
#/                                                                                                             */
#/**************************************************************************************************************/

sub find_ipxact_abstractionDefinition
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $data;
   my $design_xml_sep ;
   my $design_xml_file ;
   my $design_version;
   my $design_name;
   my $design_library;
   my $design_vendor;


      $abstractionDefinition_db->db_get("${vendor}__${library}_${component}_${version}", $data );
      ( $design_xml_file, $design_xml_sep,$design_version,$design_name,$design_library,$design_vendor ) = split ':', $data;

      return("$design_xml_file");

   }



#/**************************************************************************************************************/
#/  find_ipxact_busDefinition                                                                                  */
#/                                                                                                             */
#/  returns full path name to ip-xact busDefinition file                                                       */
#/                                                                                                             */
#/  my $spirit_type_file = yp::lib::find_ipxact_busDefinition($vendor,$library,$component,$version);           */
#/                                                                                                             */
#/**************************************************************************************************************/

sub find_ipxact_busDefinition
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $data;
   my $design_xml_sep ;
   my $design_xml_file ;
   my $design_version;


      $busDefinition_db->db_get("${vendor}__${library}_${component}_${version}", $data );
      ( $design_xml_file, $design_xml_sep,$design_version ) = split ':', $data;

      return("$design_xml_file");
   }



#/**************************************************************************************************************/
#/  find_libraryConfiguration                                                                                  */
#/                                                                                                             */
#/  returns full path name to socgen  libraryConfiguration xml file                                            */
#/                                                                                                             */
#/  my $socgen_file = yp::lib::find_libraryConfiguration($vendor,$library);                                    */
#/                                                                                                             */
#/**************************************************************************************************************/

sub find_libraryConfiguration
   {
   my @params     = @_;
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $libraryConfiguration_xml;
      $libraryConfiguration_db->db_get("${vendor}__${library}", $libraryConfiguration_xml );
   return("$libraryConfiguration_xml");
   }


#/**************************************************************************************************************/
#/  find_componentConfiguration                                                                                */
#/                                                                                                             */
#/  returns full path name to socgen  componentConfiguration xml file                                          */
#/                                                                                                             */
#/  my $socgen_file = yp::lib::find_componentConfiguration($vendor,$library,$component);                       */
#/                                                                                                             */
#/**************************************************************************************************************/

sub find_componentConfiguration
   {
   my @params     = @_;
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $componentConfiguration_xml;
      $componentConfiguration_db->db_get("${vendor}__${library}_${component}", $componentConfiguration_xml );
   return("$componentConfiguration_xml");
   }




#/**************************************************************************************************************/
#/  find_component_repo                                                                                        */
#/                                                                                                             */
#/  returns repository that containing component                                                               */
#/                                                                                                             */
#/  my $repo_name = yp::lib::find_component_repo($vendor,$library,$component);                                 */
#/                                                                                                             */
#/**************************************************************************************************************/

sub find_component_repo   {
   my @params     = @_;
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $type;
   my $name;
   my $lib_comp_sep;
   my $repo_dir;
   my $repo_data;

      $repo_db->db_get("${vendor}__${library}_${component}", $repo_data );
   ( $type,$name, $lib_comp_sep, $repo_dir ) = split ':', $repo_data;
   return("${repo_dir}");
   }




#/**************************************************************************************************************/
#/  find_library_repo                                                                                          */
#/                                                                                                             */
#/  returns repository containing library                                                                      */
#/                                                                                                             */
#/  my $repo_name = yp::lib::find_library_repo($vendor,$library);                                              */
#/                                                                                                             */
#/**************************************************************************************************************/

sub find_library_repo   {
   my @params     = @_;
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $type;
   my $name;
   my $status;
   my $library_path;
   my $repo_dir;
   my $repo_data;

      $repo_db->db_get("${vendor}__${library}", $repo_data );
   ( $type,$name, $library_path,$status, $repo_dir ) = split ':', $repo_data;
   return("${repo_dir}");
   }




#/**************************************************************************************************************/
#/  find_lib_comp_sep                                                                                          */
#/                                                                                                             */
#/  returns libraries path to components                                                                       */
#/                                                                                                             */
#/  my $lib_comp_sep = yp::lib::find_lib_comp_sep($vendor,$library,$component);                                */
#/                                                                                                             */
#/**************************************************************************************************************/

sub find_lib_comp_sep
   {
   my @params     = @_;
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $type;
   my $name;
   my $lib_comp_sep;
   my $repo_dir;
   my $repo_data;

      $repo_db->db_get("${vendor}__${library}_${component}", $repo_data );
   ( $type,$name, $lib_comp_sep, $repo_dir ) = split ':', $repo_data;
   return("${lib_comp_sep}");
   }


 
#/***********************************************************************************************/
#/  find_ipxact_comp_xml_sep                                                                    */
#/                                                                                              */
#/                                                                                              */
#/                                                                                              */
#/  my $comp_xml_sep = yp::lib::find_ipxact_component($vendor,$library,$component,$version);    */
#/                                                                                              */
#/***********************************************************************************************/

sub find_comp_xml_sep
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $comp_data;
   my $comp_version;
   my $comp_xml_sep;
   my $component_xml;
      $component_db->db_get("${vendor}__${library}_${component}_${version}", $comp_data );
      ( $component_xml, $comp_xml_sep, $comp_version) = split ':', $comp_data;
      return("$comp_xml_sep");
   }






#/*********************************************************************************************/
#/  find_lib_sw_dir                                                                           */
#/                                                                                            */
#/  returns  library sw directory                                                             */
#/                                                                                            */
#/   my $file_lib_sw_dir = yp::lib::find_file_lib_sw_dir($vendor,$library);                   */
#/                                                                                            */
#/*********************************************************************************************/

sub find_lib_sw_dir
   {
   my @params     = @_;
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $parser     = XML::LibXML->new();

   my $lib_sw_dir ;
  if(yp::lib::find_libraryConfiguration($vendor,$library))
   {
   my $socgen_libraryConfiguration= $parser->parse_file(yp::lib::find_libraryConfiguration($vendor,$library)); 
      $lib_sw_dir  = $socgen_libraryConfiguration->findnodes('//socgen:libraryConfiguration/socgen:lib_sw_dir/text()')->to_literal ;
   }

      return("/${lib_sw_dir}");

   }






#/**************************************************************************************************************/
#/  get_vendor_status                                                                                          */
#/                                                                                                             */
#/  returns vendor status                                                                                      */
#/                                                                                                             */
#/  my $vendor_status = yp::lib::get_vendor_status($vendor);                                                   */
#/                                                                                                             */
#/**************************************************************************************************************/

sub get_vendor_status   {
   my @params     = @_;
   my $vendor     = pop(@params);

   my $type;
   my $name;
   my $status;
   my $repo_dir;
   my $repo_data;

      $repo_db->db_get("${vendor}", $repo_data );
   ( $type,$name, $status, $repo_dir ) = split ':', $repo_data;
   return("${status}");
   }




#/**************************************************************************************************************/
#/  set_vendor_status                                                                                          */
#/                                                                                                             */
#/  sets vendor status                                                                                         */
#/                                                                                                             */
#/  my $vendor_status = yp::lib::set_vendor_status($vendor,$status);                                           */
#/                                                                                                             */
#/**************************************************************************************************************/

sub set_vendor_status   {
   my @params     = @_;
   my $status     = pop(@params);
   my $vendor     = pop(@params);

   my $type;
   my $name;
   my $old_status;
   my $repo_dir;
   my $repo_data;
   my @repo_info;

      $repo_db->db_get("${vendor}", $repo_data );
   ( $type,$name, $old_status, $repo_dir ) = split ':', $repo_data;

   my @repo_info  = ("vendor","$vendor","$status","$repo_dir" );
   $repo_db->db_put( $vendor, join(':', @repo_info) );

   return("${status}");
   }




#/**************************************************************************************************************/
#/  get_library_status                                                                                         */
#/                                                                                                             */
#/  returns library status                                                                                     */
#/                                                                                                             */
#/  my $library_status = yp::lib::get_library_status($vendor);                                                 */
#/                                                                                                             */
#/**************************************************************************************************************/

sub get_library_status   {
   my @params     = @_;
   my $library     = pop(@params);
   my $vendor     = pop(@params);

   my $type;
   my $name;
   my $library_path;
   my $status;
   my $repo_dir;
   my $repo_data;

      $repo_db->db_get("${vendor}_${library}", $repo_data );
   ( $type,$name,$library_path, $status, $repo_dir ) = split ':', $repo_data;
   return("${status}");
   }




#/**************************************************************************************************************/
#/  set_library_status                                                                                         */
#/                                                                                                             */
#/  sets library status                                                                                        */
#/                                                                                                             */
#/  my $library_status = yp::lib::set_library_status($vendor,$library,$status);                                */
#/                                                                                                             */
#/**************************************************************************************************************/

sub set_library_status   {
   my @params     = @_;
   my $status     = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $type;
   my $name;
   my $old_status;
   my $library_path;
   my $repo_dir;
   my $repo_data;
   my @repo_info;

      $repo_db->db_get("${vendor}_${library}", $repo_data );
   ( $type,$name,$library_path, $old_status, $repo_dir ) = split ':', $repo_data;

   my @repo_info  = ("library","$library","$library_path","$status","$repo_dir" );
   $repo_db->db_put( "${vendor}_${library}", join(':', @repo_info) );

   return("${status}");
   }













#/*********************************************************************************************/
#/  find_vendors                                                                              */
#/                                                                                            */
#/  returns  array of all vendors                                                             */
#/                                                                                            */
#/   my @vendors = yp::lib::find_vendors();                                                   */
#/                                                                                            */
#/*********************************************************************************************/

sub find_vendors
   {
   my $key;
   my $value;
   my $type;
   my $name;
   my $path;
   my $repo_dir;
   my @vendors = ();

   my $cursor = $repo_db->db_cursor() ;
   while ($cursor->c_get($key, $value, DB_NEXT) == 0) 
   {
   ( $type,$name, $path,$repo_dir ) = split ':', $value;
   if($type  eq "vendor")
     {
      push (@vendors,$name );
      }
   }
     @vendors = trim_sort(@vendors);
     return (@vendors);
   }



#/*********************************************************************************************/
#/  find_libraries                                                                            */
#/                                                                                            */
#/  returns  array of all libraries from a vendor                                             */
#/                                                                                            */
#/   my @libraries = yp::lib::find_libraries($vendor);                                        */
#/                                                                                            */
#/*********************************************************************************************/

sub find_libraries
   {
   my @params     = @_;
   my $vendor    = pop(@params);
   my $type;
   my $key;
   my $value;
   my $name;
   my $status;
   my $path;
   my $repo_dir;
   my @libraries = ();

   my $cursor = $repo_db->db_cursor() ;
   while ($cursor->c_get($key, $value, DB_NEXT) == 0) 
   {
   ( $type,$name, $path,$status, $repo_dir) = split ':', $value;


   if(($type  eq "library")&& ($key eq "${vendor}__${name}")          )
     {
      push (@libraries,$name );
      }
   }
   @libraries = trim_sort(@libraries);
   return (@libraries);
   }


#/*********************************************************************************************/
#/  find_components                                                                           */
#/                                                                                            */
#/  returns  array of all components from a vendors library                                   */
#/                                                                                            */
#/   my @components = yp::lib::find_components($vendor,$library);                                      */
#/                                                                                            */
#/*********************************************************************************************/

sub find_components
   {
   my @params     = @_;
   my $library    = pop(@params);
   my $vendor     = pop(@params);
   my $type;
   my $key;
   my $value;
   my $name;
   my $path;
   my $repo_dir;
   my @components = ();
   my $cursor = $repo_db->db_cursor() ;
   while ($cursor->c_get($key, $value, DB_NEXT) == 0) 
      {
      ( $type,$name, $path,$repo_dir ) = split ':', $value;
      if(($type  eq "component")&& ($key eq "${vendor}__${library}_${name}"))
         { push (@components,$name );}
      }
   @components = trim_sort(@components);
   return (@components);
   }




#/*********************************************************************************************/
#/  find_component_versions                                                                   */
#/                                                                                            */
#/  returns  array of all versions os a component                                             */
#/                                                                                            */
#/   my @components = yp::lib::find_component_versions($vendor,$library,$component);          */
#/                                                                                            */
#/*********************************************************************************************/

sub find_component_versions
   {
   my @params     = @_;
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $xml_file;
   my $key;
   my $value;
   my $comp_xml_sep;
   my $version;

   my @versions = ();
   my $cursor = $component_db->db_cursor() ;
   while ($cursor->c_get($key, $value, DB_NEXT) == 0) 
      {
      ( $xml_file,$comp_xml_sep, $version ) = split ':', $value;
      if(($key eq "${vendor}__${library}_${component}_${version}"))
         { 
         push (@versions,$version );
         }
      }
   @versions = trim_sort(@versions);
   return (@versions);
   }





#/************************************************************************************************************************/
#/  find_abstractionDefinition_versions                                                                                  */
#/                                                                                                                       */
#/  returns  array of all versions os a abstractionDefinition                                                            */
#/                                                                                                                       */
#/   my @abstractionDefinitions = yp::lib::find_abstractionDefinition_versions($vendor,$library,$abstractionDefinition); */
#/                                                                                                                       */
#/************************************************************************************************************************/

sub find_abstractionDefinition_versions
   {
   my @params     = @_;
   my $abstractionDefinition  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $xml_file;
   my $key;
   my $value;
   my $comp_xml_sep;
   my $design_vendor;
   my $design_library;
   my $design_name;
   my $design_version;

   my @versions = ();
   my $cursor = $abstractionDefinition_db->db_cursor() ;
   while ($cursor->c_get($key, $value, DB_NEXT) == 0) 
      {
      ( $xml_file,$comp_xml_sep, $design_version,$design_name,$design_library,$design_vendor ) = split ':', $value;
      if(($key eq "${vendor}__${library}_${abstractionDefinition}_${design_version}"))
         { 
         push (@versions,$design_version );
         }
      }
   @versions = trim_sort(@versions);
   return (@versions);
   }


#/*********************************************************************************************/
#/  find_abstractionDefinitions                                                                */
#/                                                                                            */
#/  returns  array of all         abstractionDefinitions   vendor__library_abstractionDefinition_version      */
#/                                                                                            */
#/   my @abstractionDefinitions = yp::lib::find_abstractionDefinitions();                     */
#/                                                                                            */
#/*********************************************************************************************/










sub find_abstractionDefinitions
   {
   my $key;
   my $value;
   my $type;
   my $name;
   my $path;

   my $design_xml_file;
   my $design_xml_sep;

   my $design_version;
   my $design_name;
   my $design_library;
   my $design_vendor;


   my @abstractionDefinitions = ();

   my $cursor = $abstractionDefinition_db->db_cursor() ;
   while ($cursor->c_get($key, $value, DB_NEXT) == 0) 
         {

         ( $design_xml_file, $design_xml_sep,$design_version,$design_name,$design_library,$design_vendor ) = split ':', $value;
         push (@abstractionDefinitions,"${design_vendor}:${design_library}:${design_name}:${design_version}" );
         @abstractionDefinitions = trim_sort(@abstractionDefinitions);
         }
         return (@abstractionDefinitions);
   }


#/************************************************************************************************************************/
#/  find_busDefinition_versions                                                                                  */
#/                                                                                                                       */
#/  returns  array of all versions os a busDefinition                                                            */
#/                                                                                                                       */
#/   my @busDefinitions = yp::lib::find_busDefinition_versions($vendor,$library,$busDefinition); */
#/                                                                                                                       */
#/************************************************************************************************************************/

sub find_busDefinition_versions
   {
   my @params     = @_;
   my $busDefinition  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $xml_file;
   my $key;
   my $value;
   my $comp_xml_sep;
   my $version;

   my @versions = ();
   my $cursor = $busDefinition_db->db_cursor() ;
   while ($cursor->c_get($key, $value, DB_NEXT) == 0) 
      {
      ( $xml_file,$comp_xml_sep, $version ) = split ':', $value;
      if(($key eq "${vendor}__${library}_${busDefinition}_${version}"))
         { 
         push (@versions,$version );
         }
      }
   @versions = trim_sort(@versions);
   return (@versions);
   }

#/*********************************************************************************************/
#/  get_module_name                                                                           */
#/                                                                                            */
#/  returns module name for component                                                         */
#/                                                                                            */
#/   my $module_name = yp::lib::get_module_name($vendor,$library,$component,$version);        */
#/                                                                                            */
#/*********************************************************************************************/

sub get_module_name
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $name_depth =2;

   my $parser     = XML::LibXML->new();

   my $socgen_component_filename  = yp::lib::find_componentConfiguration($vendor,$library,$component);  
   unless($socgen_component_filename)
      {
	  return("");
      }
   my $socgen_component_file  = $parser->parse_file($socgen_component_filename);  

   foreach my $new_comp ($socgen_component_file->findnodes("//socgen:componentConfiguration")) 
     {
     $name_depth        = $new_comp->findnodes('./socgen:ip_name_depth/text()')->to_literal ;
     }
  if($name_depth eq "0"){   return("${library}");}  
  if($name_depth eq "1"){   return("${component}");}  
  if($name_depth eq "2"){   return("${component}_${version}");}  
  if($name_depth eq "3"){   return("${library}_${component}_${version}");}  
  if($name_depth eq "4"){   return("${vendor}_${library}_${component}_${version}");}  
     
   }


#/*********************************************************************************************/
#/  parse_component_file                                                                      */
#/                                                                                            */
#/  returns design names for component                                                        */
#/                                                                                            */
#/   my @filelist = yp::lib::parse_component_file($vendor,$library,$component,$version);      */
#/                                                                                            */
#/*********************************************************************************************/



sub parse_component_file
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $parser     = XML::LibXML->new();


   my $spirit_cmp_filename =yp::lib::find_ipxact_component($vendor,$library,$component,$version ); 

   unless($spirit_cmp_filename)
      {
      print("spirit:component MISSING   $vendor,$library,$component,$version \n"); 
      }


   my $spirit_component_file  = $parser->parse_file(yp::lib::find_ipxact_component($vendor,$library,$component,$version )); 


   my $line;

   my      @filelist_acc = (  );
   push(@filelist_acc,"::${vendor}::${library}::${component}::${version}::");
   
   foreach my $new_comp ($spirit_component_file->findnodes("//spirit:component/spirit:model/spirit:views/spirit:view/spirit:vendorExtensions/spirit:componentRef")) 
     {
     my($new_vendor)        = $new_comp->findnodes('./@spirit:vendor')->to_literal ;
     my($new_library)       = $new_comp->findnodes('./@spirit:library')->to_literal ;
     my($new_name)          = $new_comp->findnodes('./@spirit:name')->to_literal ;
     my($new_version)       = $new_comp->findnodes('./@spirit:version')->to_literal ;
     my @filelist_sub       = parse_component_fileX($new_vendor,$new_library,$new_name,$new_version);
                              foreach $line (@filelist_sub) { push(@filelist_acc,"$line"); }
     }

   foreach my $new_comp ($spirit_component_file->findnodes("//spirit:component/spirit:model/spirit:views/spirit:view/spirit:hierarchyRef")) 
     {
     my($new_vendor)        = $new_comp->findnodes('./@spirit:vendor')->to_literal ;
     my($new_library)       = $new_comp->findnodes('./@spirit:library')->to_literal ;
     my($new_name)          = $new_comp->findnodes('./@spirit:name')->to_literal ;
     my($new_version)       = $new_comp->findnodes('./@spirit:version')->to_literal ;

     if(yp::lib::find_ipxact_design($new_vendor,$new_library,$new_name,$new_version ))
             {
             my $spirit_design_file = $parser->parse_file(yp::lib::find_ipxact_design($new_vendor,$new_library,$new_name,$new_version )); 
             foreach  my   $i_name ($spirit_design_file->findnodes("//spirit:design/spirit:componentInstances/spirit:componentInstance/spirit:componentRef/\@spirit:vendor"))
                {
                my($vendor_name)         = $i_name  ->to_literal ;
                my($library_name)        = $i_name  ->findnodes('../@spirit:library')->to_literal ;
                my($component_name)      = $i_name  ->findnodes('../@spirit:name')->to_literal ;
                my($version_name)        = $i_name  ->findnodes('../@spirit:version')->to_literal ;

                push(@filelist_acc,"::${vendor_name}::${library_name}::${component_name}::${version_name}::");
                my  @filelist_sub = parse_component_fileX($vendor_name,$library_name,$component_name,$version_name);
                  foreach $line (@filelist_sub) { push(@filelist_acc,"$line"); }
                }            
             }
     }

   @filelist_acc     =       sys::lib::trim_sort(@filelist_acc);
   return(@filelist_acc);
}





sub parse_component_fileX
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $parser     = XML::LibXML->new();


   my $spirit_cmp_filename =yp::lib::find_ipxact_component($vendor,$library,$component,$version ); 

   unless($spirit_cmp_filename)
      {
      print("spirit:component MISSING   $vendor,$library,$component,$version \n"); 
      }


   my $spirit_component_file  = $parser->parse_file(yp::lib::find_ipxact_component($vendor,$library,$component,$version )); 


   my $line;

   my      @filelist_acc = (  );

   
   foreach my $new_comp ($spirit_component_file->findnodes("//spirit:component/spirit:model/spirit:views/spirit:view/spirit:vendorExtensions/spirit:componentRef")) 
     {
     my($new_vendor)        = $new_comp->findnodes('./@spirit:vendor')->to_literal ;
     my($new_library)       = $new_comp->findnodes('./@spirit:library')->to_literal ;
     my($new_name)          = $new_comp->findnodes('./@spirit:name')->to_literal ;
     my($new_version)       = $new_comp->findnodes('./@spirit:version')->to_literal ;
     my @filelist_sub       = parse_component_fileX($new_vendor,$new_library,$new_name,$new_version);
                              foreach $line (@filelist_sub) { push(@filelist_acc,"$line"); }
     }

   foreach my $new_comp ($spirit_component_file->findnodes("//spirit:component/spirit:model/spirit:views/spirit:view/spirit:hierarchyRef")) 
     {
     my($new_vendor)        = $new_comp->findnodes('./@spirit:vendor')->to_literal ;
     my($new_library)       = $new_comp->findnodes('./@spirit:library')->to_literal ;
     my($new_name)          = $new_comp->findnodes('./@spirit:name')->to_literal ;
     my($new_version)       = $new_comp->findnodes('./@spirit:version')->to_literal ;

     if(yp::lib::find_ipxact_design($new_vendor,$new_library,$new_name,$new_version ))
          {
          my $spirit_design_file = $parser->parse_file(yp::lib::find_ipxact_design($new_vendor,$new_library,$new_name,$new_version )); 
          foreach  my   $i_name ($spirit_design_file->findnodes("//spirit:design/spirit:componentInstances/spirit:componentInstance/spirit:componentRef/\@spirit:vendor"))
                {
                my($vendor_name)         = $i_name  ->to_literal ;
                my($library_name)        = $i_name  ->findnodes('../@spirit:library')->to_literal ;
                my($component_name)      = $i_name  ->findnodes('../@spirit:name')->to_literal ;
                my($version_name)        = $i_name  ->findnodes('../@spirit:version')->to_literal ;

                push(@filelist_acc,"::${vendor_name}::${library_name}::${component_name}::${version_name}::");
                my  @filelist_sub = parse_component_fileX($vendor_name,$library_name,$component_name,$version_name);
                  foreach $line (@filelist_sub) { push(@filelist_acc,"$line"); }
                }       
           
           }
     }

   @filelist_acc     =       sys::lib::trim_sort(@filelist_acc);
   return(@filelist_acc);
}






#/*********************************************************************************************/
#/  parse_component_brothers                                                                  */
#/                                                                                            */
#/  returns names for component brothers                                                      */
#/                                                                                            */
#/   my @filelist = yp::lib::parse_component_brothers($vendor,$library,$component,$version);   */
#/                                                                                            */
#/*********************************************************************************************/

sub parse_component_brothers
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);

   my $parser     = XML::LibXML->new();
   unless (yp::lib::find_ipxact_component($vendor,$library,$component,$version)){print "Missing Component  $vendor, $library, $component, $version \n";  }
   my $spirit_component_file  = $parser->parse_file(yp::lib::find_ipxact_component($vendor,$library,$component,$version )); 

   my $line;
   my      @filelist_acc = (  );
   push(@filelist_acc,"::${vendor}::${library}::${component}::${version}::");
   
   foreach my $new_comp ($spirit_component_file->findnodes("//spirit:component/spirit:model/spirit:views/spirit:view/spirit:vendorExtensions/spirit:componentRef")) 
     {
     my($new_vendor)        = $new_comp->findnodes('./@spirit:vendor')->to_literal ;
     my($new_library)       = $new_comp->findnodes('./@spirit:library')->to_literal ;
     my($new_component)     = $new_comp->findnodes('./@spirit:name')->to_literal ;
     my($new_version)       = $new_comp->findnodes('./@spirit:version')->to_literal ;
     push(@filelist_acc,"::${new_vendor}::${new_library}::${new_component}::${new_version}::");
     }

   return(@filelist_acc);
}

#/*****************************************************************************************************/
#/  find_ipxact_design_files                                                                          */
#/                                                                                                    */
#/  returns parser tokens  to ip-xact design files referred to by component file vlnv                 */
#/                                                                                                    */
#/  my @spirit_design_files = yp::lib::find_ipxact_design_file($vendor,$library,$component,$version);  */
#/                                                                                                    */
#/*****************************************************************************************************/

sub find_ipxact_design_files 
   {
   my @params     = @_;
   my $version    = pop(@params);
   my $component  = pop(@params);
   my $library    = pop(@params);
   my $vendor     = pop(@params);


   my @design_files = ();
   my $parser           = XML::LibXML->new();
   unless (yp::lib::find_ipxact_component($vendor,$library,$component,$version)){print "Missing Component  $vendor, $library, $component, $version \n";  }
   my $spirit_component_file    = $parser->parse_file(yp::lib::find_ipxact_component($vendor,$library,$component,$version));

   foreach my $new_comp ($spirit_component_file->findnodes("//spirit:component/spirit:model/spirit:views/spirit:view/spirit:vendorExtensions/spirit:componentRef")) 
     {
     my($new_vendor)        = $new_comp->findnodes('./@spirit:vendor')->to_literal ;
     my($new_library)       = $new_comp->findnodes('./@spirit:library')->to_literal ;
     my($new_name)          = $new_comp->findnodes('./@spirit:name')->to_literal ;
     my($new_version)       = $new_comp->findnodes('./@spirit:version')->to_literal ;
     my @filelist_sub       = yp::lib::find_ipxact_design_files($new_vendor,$new_library,$new_name,$new_version);
                              foreach my $line (@filelist_sub) { push(@design_files,"$line"); }     }

   foreach my $comp_view ($spirit_component_file->findnodes('//spirit:component/spirit:model/spirit:views/spirit:view')) 
      {
      my($hier_ref_vendor)         = $comp_view->findnodes('./spirit:hierarchyRef/@spirit:vendor')->to_literal ;
      my($hier_ref_library)        = $comp_view->findnodes('./spirit:hierarchyRef/@spirit:library')->to_literal ;
      my($hier_ref_design)         = $comp_view->findnodes('./spirit:hierarchyRef/@spirit:name')->to_literal ;
      my($hier_ref_version)        = $comp_view->findnodes('./spirit:hierarchyRef/@spirit:version')->to_literal ;
      if(find_ipxact_design($hier_ref_vendor,$hier_ref_library,$hier_ref_design,$hier_ref_version))
        {
        push(@design_files,":::${hier_ref_vendor}:::${hier_ref_library}:::${hier_ref_design}:::${hier_ref_version}:::");           
        }
      }
     return(@design_files);
   }

sub trim_sort {
   my @output_files  = @_;
   my %trim = ();
   foreach my $descriptor (@output_files) { $trim{$descriptor}  = 1; }
   my @k = keys %trim;
   @output_files =  sort(sort @k);  
   return(@output_files);
   }


1;
