# | file: cb_generator.pl
# |
# | This SOPC Builder Generator program is provided by
# | the Component Builder application. It is copied
# | straight across and is data-driven from its command
# | line arguments and the PTF files referenced.
# |
# | Its purpose is to construct an HDL "wrapper" for
# | a particular instance of a particular SOPC Builder
# | peripheral. This wrapper resolves the instance
# | name and any HDL parameterization.
# |
# +-------------------------------------------



# +-------------------------------------------
# |

use strict;
use format_conversion_utils;
use ptf_parse;
use wiz_utils;
use europa_all;
use run_system_command_utils;

# |
# +-------------------------------------------



# +-------------------------------------------
# |
# | first pass: include all of generator_libarary.pm RIGHT HERE.
# | dvb04.08.02
# | then prune down to actual functionality.
# |
# | TODO: Rewrite this whole file into something readable
# | this is much more confusing than I'm comfortable with. dvb04.
# | (though it does seem to work.)
# |

my $DEBUG_DEFAULT_GEN = 1;

#This is the global hash of arguments passed in by the generator program

my $generator_hr = {
		     wrapper_args => {
				      make_wrapper => 0,
				      top_module_name => "",
				      simulate_hdl => 1,
				      ports => "",
				     },
		     class_ptf_hr => "",
		     module_ptf_hr => "",
		     system_ptf_hr => "",
		     language => "",
		     external_args => "",
		     external_args_hr => "",
		     project_path_widget => "__PROJECT_DIRECTORY__",
		     generator_mode => "silent",
		    };


sub generator_print_verbose
{
  my ($info) = (@_);

  if($generator_hr->{generator_mode} eq "verbose"){
    print("cb_generator.pl: ".$info);
  }
}

sub generator_enable_mode
{
  my ($mode) = (@_);
  $generator_hr->{generator_mode} = $mode;
}

sub generator_get_system_ptf_handle
{ 
  return $generator_hr->{system_ptf_hr};
}

sub generator_get_language
{
  return $generator_hr->{language};
}

sub generator_get_class_ptf_handle
{
  return $generator_hr->{class_ptf_hr};
}

sub default_ribbit
{
  my ($arg) = (@_);
  &ribbit("\n\n--Error: default_gen_lib: $arg\n");  
}


sub _copy_files
{
  my ($dest_dir, $source_dir, @files) = (@_);
  my $function_name;
  
  #validate args
  &default_ribbit("No target dir for function copy_files!")
  unless ($dest_dir ne "");
  
  &default_ribbit("No source dir for function copy_files!")
  unless ($source_dir ne "");

  &default_ribbit("No files for function copy_files!")
  unless (@files != 0);

  
  #check for valid directories
  opendir (SDIR, $source_dir) or 
    &default_ribbit("can't open $source_dir !");
  
  opendir (DDIR, $dest_dir) or
    &default_ribbit("can't open $dest_dir !");
  
  
  foreach my $source_file(@files){
    # |
    # | Separate out the source subdir and the source filename
    # |
    my $source_subdir = "";
    my $source_filename = $source_file;

    if($source_filename =~ /^(.*)\/(.*)$/)  # break on last slash
    {
      $source_subdir = "/$1"; # embed its leading slash, for concatty
      $source_filename = $2;
    }

    my $source_fullpath = "$source_dir$source_subdir/$source_filename";
    my $dest_fullpath = "$dest_dir/$source_filename";

    &Perlcopy($source_fullpath, $dest_fullpath);
    &generator_print_verbose("Copying file: \"$source_fullpath\""
            . " to \"$dest_fullpath\".\n");
  }

  closedir (SDIR);
  closedir (DDIR);
}


sub get_module_wrapper_arg_hash_from_system_ptf_file
{
  my $module_ptf_hr = $generator_hr->{module_ptf_hr};
  
  my @list_of_sections = ("MASTER","SLAVE","PORT_WIRING");
  my @port_list;
  foreach my $section(@list_of_sections){
    my $number = get_child_count($module_ptf_hr, $section);

    for(my $initial=0; $initial < $number; $initial++){
      
      my $interface_section = get_child($module_ptf_hr, $initial, $section);	
      my $interface_section_name = get_data($interface_section);

      my $port_wiring_section;
      if($section ne "PORT_WIRING"){
	$port_wiring_section = 
	  get_child_by_path($module_ptf_hr, $section." ".$interface_section_name."/PORT_WIRING");	
      }else{
	$port_wiring_section =
	  get_child_by_path($module_ptf_hr, $section);
      }
      my $num_ports = get_child_count($port_wiring_section, "PORT");
      foreach(my $port_count = 0; $port_count < $num_ports; $port_count++){
	my $port = get_child($port_wiring_section, $port_count, "PORT");
	
	my %port_info_struct;
	$port_info_struct{name} = get_data($port);
	$port_info_struct{direction} = get_data_by_path($port, "direction");
	$port_info_struct{width} = get_data_by_path($port, "width");
	$port_info_struct{vhdl_record_name} = get_data_by_path($port, "vhdl_record_name");
	$port_info_struct{vhdl_record_type} = get_data_by_path($port, "vhdl_record_type");
	
	push(@port_list, \%port_info_struct);
	
      }
    }	
  }
  $generator_hr->{wrapper_args}{ports} = \@port_list;
}


sub generator_make_module_wrapper
{
  my ($simulate_hdl, $top_module_name, $module_language) = (@_);

  &default_ribbit("generator_make_module_wrapper: no arg0 passed in for simulate_hdl\n")
    if($simulate_hdl eq '');

  &default_ribbit("generator_make_module_wrapper: no arg1 passed in for top_module_name\n")
    unless($top_module_name);

  $generator_hr->{wrapper_args}{simulate_hdl} = $simulate_hdl;
  $generator_hr->{wrapper_args}{top_module_name} = $top_module_name;
  $generator_hr->{wrapper_args}{make_wrapper} = 1;
  $generator_hr->{wrapper_args}{module_language} = $module_language;

}




# |
# | recognize varous number forms,
# | return 'h0123abcd-ish.
# |
sub turn_anything_into_appropriate_string($$$$)
	{
	my ($value,$type,$editable,$module_language) = (@_);

    return $value if($value =~ /^\"/);   # quoted string: unscathed
    return $value if($type eq "string"); # string: anything is ok
    
    return $value if(!$editable);        # and you know, if you can't change it, keep it!
    
    
	# |
	# | first, convert to a number
	# |
	my $base = 10;
	my $n = $value;
	my $width = 32;
	my $number = 0;
	
	$value = lc($value); # lower case
	
	if($value =~ /^([0-9]*)\'([hbo])(.*)$/)
		{
		# | tick notation: AOK for verilog
		if($module_language eq "verilog")
			{
			$number = $value;
			}
		# |
		# | note: at this point, we could notice if the
		# | result should be vhdl binary, and convert
		# | to that, avoiding the precision-losing
		# | integer intermediary
		# |
		# | (alternatively, we could use a binary string
		# | always as the intermediate form, rather than
		# | a precision-losing int.)
		# |
		else
			{
			$width = $1;
			my $baseletter = $2;
			my $digits = $3;
			
			if($baseletter eq "h")
				{
				$base = 16;
				}
			elsif($baseletter eq "b")
				{
				$base = 2;
				}
			elsif($baseletter eq "o") # must be
				{
				$base = 8;
				}
			
			$digits =~ s/[ _-]//g; # crush out dividing value
			
			while(length($digits) > 0)
				{
				my $digit = substr($digits,0,1);
				$digits = substr($digits,1);
				my $digitvalue = hex($digit); # how handy
				$number = $number * $base + $digitvalue;
				}
			}
		}
	elsif($value =~ /^0x(.*)$/)
		{
		$number = hex($1);
		}
	else  # try for decimal
		{
		$number = int(1 * $value);
		}
	
	# |
	# | ok, we have a number. If our target type
	# | is "std_logic_vector(this downto that)"
	# | for tricky VHDL, we
	# | must quote a binary string out of it.
	# |
	
	if(($module_language eq "vhdl") and ($type =~ /^.*\((\d+) downto (\d+)\).*$/))
		{
		my ($high_bit,$low_bit) = ($1,$2);
		my $binary = "";
		for(my $bit = $low_bit; $bit <= $high_bit; $bit++)
			{
			$binary = ($number % 2) . $binary;
			$number = int($number >> 1);
			}
		
		$number = '"' . $binary . '"';
		}
	
	return $number;
	}

#
# return @array of vhdl libraries, if any, from the class.ptf
sub get_libraries()
{
    my $class_ptf = generator_get_class_ptf_handle();
    my @libraries;
    my $libraries_ptf = get_child_by_path($class_ptf,"CLASS/CB_GENERATOR/LIBRARIES");

    if($libraries_ptf)
        {
        my $library_count = get_child_count($libraries_ptf,"library");
        for(my $i = 0; $i < $library_count; $i++)
        {
            my $library_ptf = get_child($libraries_ptf,$i,"library");
            my $library_name = get_data($library_ptf);
            push(@libraries,$library_name);
        }
    }

    return @libraries;
}



sub _generator_make_module_wrapper	
{
  
  my $wrapper_args = $generator_hr->{wrapper_args};
  my $no_black_box = $wrapper_args->{simulate_hdl};
  my $top_module_name = $wrapper_args->{top_module_name};
  my $language = $generator_hr->{language};
  my @external_args = @{$generator_hr->{external_args}};
  my $module_ptf_hr = $generator_hr->{module_ptf_hr};

  ### Build Module
  my $project = e_project->new(@external_args);
  my $top = $project->top();
  
  # add the ports to the system module
  my @ports;
  
  foreach my $port_hash(@{$wrapper_args->{ports}}){
    my $porto = e_port->new({
			     name => $port_hash->{name},
			     width => $port_hash->{width},
			     direction => $port_hash->{direction},
			     vhdl_record_name => $port_hash->{vhdl_record_name},
			     vhdl_record_type => $port_hash->{vhdl_record_type}
			    });
    push(@ports, $porto);
  }
  $top->add_contents(@ports);
  




    # +----------------------------------------
    # | Get parameters from class.ptf
    # | create @array of parameters, eacho
    # | one like name=>, default=>, type=>,
    # |  
    # | These are the definitions of parameters for
    # | ANY instance of this module; we need to 
    # | have them in the "wrapee" module so that
    # | when the system bus is knitted together
    # | the parameter types can be properly used.
    # |
    # | (as it turns out, verilog doesnt need
    # | them, but vhld does)
    # |
    # | dvb2004


    my @e_hdl_parameters; # list of e_parameters

    my $class_ptf = generator_get_class_ptf_handle();
    my $hdl_parameter_definitions_ptf = get_child_by_path($class_ptf,"CLASS/COMPONENT_BUILDER/HDL_PARAMETERS");

    my @libraries = get_libraries();

    my $hdl_parameter_count = get_child_count($hdl_parameter_definitions_ptf,"HDL_PARAMETER");

    my $module_language = $generator_hr->{wrapper_args}{module_language};

    for(my $i = 0; $i < $hdl_parameter_count; $i++)
        {
        my $a_parameter = get_child($hdl_parameter_definitions_ptf,$i,"HDL_PARAMETER");
        my $parameter_editable = get_data_by_path($a_parameter,"editable");
        if($parameter_editable)
                {
                my $boring_name = get_data($a_parameter); # legal guinevere-ized
                my $name = get_data_by_path($a_parameter,"parameter_name"); # original HDL name
                my $default = get_data_by_path($a_parameter,"default_value");
                my $type = get_data_by_path($a_parameter,"type");
                
                $default = turn_anything_into_appropriate_string($default,$type,1,$module_language);

                my $a_parameter = e_parameter->new
                    ({
                    name => $name,
                    default => $default,
                    type => $type
                    });

                push (@e_hdl_parameters,$a_parameter);
                }
        }
        


    # | and @e_hdl_parameters is used below in the wrapee module
    # +--------------------------------------------

    # +--------------------------------------------
    # | Now, we build a "hdl_parameter_map", which is just
    # | your basic hash table with keys (parameters)
    # | and values (parameter values).
    # |
    # | these are the particular values for this instance.
    # |

    my %hdl_parameter_map;
    my $module_ptf = $generator_hr->{module_ptf_hr};
    my $hdl_parameters_ptf =
            get_child_by_path($module_ptf,"WIZARD_SCRIPT_ARGUMENTS/hdl_parameters");

    my $child_count = get_child_count($hdl_parameters_ptf);

    for(my $i = 0; $i < $child_count; $i++)
        {
        my $a_parameter = get_child($hdl_parameters_ptf,$i);

        my $boring_name = get_name($a_parameter);
        my $value = get_data($a_parameter);

		# refer back to the original HDL name...
        my $parameter_definition_ptf = get_child_by_path($hdl_parameter_definitions_ptf,"HDL_PARAMETER $boring_name");
        my $parameter_name = get_data_by_path($parameter_definition_ptf,"parameter_name");
        my $parameter_type = get_data_by_path($parameter_definition_ptf,"type");
        my $parameter_editable = get_data_by_path($parameter_definition_ptf,"editable");
        
        $value = turn_anything_into_appropriate_string($value,$parameter_type,$parameter_editable,$module_language);

        # |
        # | our internal _dummy assignment shows up here
        # | without a corresponding hdl entry. we
        # | ignore it.
        # |

        if(($parameter_name ne "") and $parameter_editable)
            {
            $hdl_parameter_map{$parameter_name} = $value;
            }
        }

  my $wrapee_module;
  $wrapee_module = e_module->new({
				 name => $top_module_name,
				 contents =>  [@ports,@e_hdl_parameters],
				 do_black_box => 0,
				 do_ptf => 0,
				 _hdl_generated => 1,
				 _explicitly_empty_module => 1,
				});

  # VHDL Libraries, from PTF file...
  $wrapee_module->add_vhdl_libraries(@libraries);
  $top->add_vhdl_libraries(@libraries);


  $top->add_contents (
		      e_instance->new({
				       module => $wrapee_module,
                       parameter_map => \%hdl_parameter_map
				      }),
		     );
  
  $project->top()->do_ptf(0);
  $project->do_write_ptf(0);
  
  
  my $module_file = $project->_target_module_name().".v";
  $module_file = $project->_target_module_name().".vhd"
    if($language eq "vhdl");

  $module_file = $generator_hr->{project_path_widget}."/".$module_file;
  &generator_set_files_in_system_ptf("Synthesis_HDL_Files", ($module_file));
  $project->output();


  # if you don't want a simulation model, you don't get a simulation model
  if($no_black_box eq "0")
  {
    my $black_project = e_project->new(@external_args);
    $black_project->_target_module_name($top_module_name);
    my $black_top = $black_project->top();



    $black_top->add_contents(@ports);
    my $black_top_instance;
    $black_top_instance = e_module->new({
				   name => $wrapper_args->{top_module_name}."_bb",
				   contents =>  [@ports],
				   do_black_box => 1,
				   do_ptf => 0,
				   _hdl_generated => 0,
				   _explicitly_empty_module => 1,
				  });
    
    $black_top->add_contents (
			e_instance->new({
					 module => $black_top_instance,
					}),
		       );




    $black_project->top()->do_ptf(0);
    $black_project->do_write_ptf(0);

    my $black_module_file = $black_project->_target_module_name().".v";
    $black_module_file = $black_project->_target_module_name().".vhd"
      if($language eq "vhdl");


    $black_module_file = $generator_hr->{project_path_widget}."/".$black_module_file;
    &generator_set_files_in_system_ptf("Simulation_HDL_Files", ($black_module_file));

#    &set_data_by_path($module_ptf_hr, "HDL_INFO/Simulation_HDL_Files", $black_module_file);


    $black_project->output();
  }

}

####
# Args: $file_type : "synthesis", "synthesis_only", "simulation"
#       @file_list   :  an array of files.  This list of files is assumed to be relative to the
#                       component's directory


my $decoder_ring_hr = {
			quartus_only => {
					 copy => 1,
					 copy_to => "project",
					 ptf_set => 0,
					},
			simulation_only => {
					    copy => 1,
					    copy_to => "simulation",
					    ptf_set => 1,
					    ptf_section => "Simulation_HDL_Files",
					   },
			simulation_and_quartus => {
						   copy => 1,
						   copy_to => "project",
						   ptf_set => 1,
						   ptf_section => "Synthesis_HDL_Files",
						  }, 
		       precompiled_simulation_files => {
							copy => 0,
							ptf_set => 1,
							ptf_section => "Precompiled_Simulation_Library_Files",
						       },
		      };




sub generator_copy_files_and_set_system_ptf
{
  my ($hdl_section, @file_list) = (@_);

  my $ptf_path_prefix = "";  
  my $external_args_hr = $generator_hr->{external_args_hr};
  my @new_file_array;

  #validate first
  my $decoder_hash = $decoder_ring_hr->{$hdl_section};
  &default_ribbit("generator_copy_files_and_set_system_ptf: No understood HDL section passed in for first arg\n")
    unless($decoder_ring_hr->{$hdl_section} ne "");

  &generator_print_verbose("generator_copy_files_and_set_system_ptf: copying files for section ".$hdl_section."\n");

  #copy second
  my @new_file_array;

  # If we need to copy over some files, then we need to make sure we are 
  # keeping track of what files we copy over.
  # Otherwise, we just need to keep track of the files that the user has asked to copy over
  # and use these instead.
  if($decoder_hash->{copy}){
    my $copy_to_location;
    my $copy_from_location;

    if($decoder_hash->{copy_to} eq "project"){
      $copy_to_location = $external_args_hr->{system_directory};
    }elsif($decoder_hash->{copy_to} eq "simulation"){
      $copy_to_location = $external_args_hr->{system_sim_dir};
    }else{
      &default_ribbit("generator_copy_files_and_set_system_ptf: No understood copy files to location\n");
    }

    $copy_from_location = $external_args_hr->{class_directory};
    @new_file_array = &generator_copy_files($copy_to_location, $copy_from_location, @file_list);
  }else{
    @new_file_array = @file_list;
  }	

  #scribble on PTF hash last
  if($decoder_hash->{ptf_set}){

    if($decoder_hash->{copy_to} eq "project"){
      foreach my $file(@new_file_array){
         $file =~ s/^.*\/(.*?)$/$1/;
         $file = $generator_hr->{project_path_widget}."/".$file;
      }
    }
    &generator_print_verbose("generator_copy_files_and_set_system_ptf: setting system PTF file in section ".$hdl_section."\n");
    if($decoder_hash->{ptf_section} eq "Precompiled_Simulation_Library_Files"){
      @new_file_array = map{$external_args_hr->{class_directory}."/".$_} @new_file_array;
    }
    &generator_set_files_in_system_ptf($decoder_hash->{ptf_section}, @new_file_array);
  }
}



####
# Name: generator_set_files_in_system_ptf
# Args: $hdl_section
#       @list_of_files
# Returns: 1 or 0
# Purpose: This is an internal function used to set files in the module's section in the system PTF file
#
sub generator_set_files_in_system_ptf
{
  my ($hdl_section, @list_of_files) = (@_);

  my $file_list = join(",", @list_of_files);
  my $previous_data;  

  &generator_print_verbose("setting HDL_INFO/".$hdl_section." in system PTF file with ".$file_list."\n");
  my $previous_data = &get_data_by_path($generator_hr->{module_ptf_hr}, "HDL_INFO/".$hdl_section);  
  if($previous_data){
    $file_list = $previous_data . ", $file_list"; # spr 132177
                                                  # swapping order, dvb 2003
  }
  &set_data_by_path($generator_hr->{module_ptf_hr}, "HDL_INFO/".$hdl_section, $file_list);
}

####
# Name: generator_copy_files
# Args: $target_directory
#       $source_directory
#       @list_of_files
# Returns: The list of files which has been copied (suitable for framing!)
# Purpose: This is an internal function used to copy files around in the generator program.
#
sub generator_copy_files
{
  my ($target_directory, $source_directory, @list_of_files) = (@_);

  my @new_file_array;

  foreach my $file_name(@list_of_files){
     $file_name =~ s|\\|\/|g;
    if($file_name =~ /\*\.*/){
      $file_name =~ s/\*/$1/;
      my @found_list = &_find_all_dir_files_with_ext($source_directory, $file_name);
      push(@new_file_array, @found_list);
    }else{
      &generator_print_verbose("Copying: ".$file_name."\n");
      push(@new_file_array, $file_name);
    }
  }

  &_copy_files($target_directory, $source_directory, @new_file_array);
  return @new_file_array;
}



sub _find_all_dir_files_with_ext
{
  my ($dir,
      $ext) = (@_);

  opendir (DIR, $dir) or
    &default_ribbit("can't open $dir !");
  
  my @all_files = readdir(DIR);
  my @new_file_list; 
 
  
  foreach my $file (@all_files){
    if($file =~ /^.*($ext)$/){
      push(@new_file_list, $file);
    }
  }

  return @new_file_list;
}

####
# Name: generator_begin
# Args: Array of generator program launcher args
# Returns: A hash reference to the module's section in the system PTF file
# Purpose: This is the first subroutine a user should call before running the rest of their
#          generator program.
#

sub generator_begin
{
  my @external_args = (@_);

  my  ($external_args_hr, 
       $temp_user_defined, 
       $temp_db_Module, 
       $temp_db_PTF_File) = Process_Wizard_Script_Arguments("", @external_args);

  &generator_print_verbose("generator_begin: initializing\n");

  $generator_hr->{external_args_hr} = $external_args_hr;
  $generator_hr->{external_args} = \@external_args;

  # open up class.ptf and 
  $generator_hr->{class_ptf_hr} = new_ptf_from_file($external_args_hr->{class_directory}."/class.ptf");

  # get the system.ptf 
  $generator_hr->{system_ptf_hr} = new_ptf_from_file($external_args_hr->{system_directory}."/".$external_args_hr->{system_name}.".ptf");
  $generator_hr->{module_ptf_hr} = &get_child_by_path($generator_hr->{system_ptf_hr}, "SYSTEM $external_args_hr->{system_name}/MODULE $external_args_hr->{target_module_name}");
  my $class_name = get_data_by_path($generator_hr->{module_ptf_hr}, "class");

  # find the default generator section
  $generator_hr->{language} = get_data_by_path($generator_hr->{system_ptf_hr}, "SYSTEM $external_args_hr->{system_name}/WIZARD_SCRIPT_ARGUMENTS/hdl_language");

  # get some wrapper settings
  &get_module_wrapper_arg_hash_from_system_ptf_file();

  # clear system ptf's HDL section
  &delete_child($generator_hr->{module_ptf_hr}, "HDL_INFO");

  return $generator_hr->{module_ptf_hr};
}	

####
# Name: generator_end
# Args: none
# Returns: nothing
# Purpose: This is the last subroutine a user should call from their generator program.
#          Not calling this subroutine will make you very sad... =<
#

sub generator_end
{
  # o.k., time to make the wrapper and output it.
  if($generator_hr->{wrapper_args}{make_wrapper}){
    &_generator_make_module_wrapper();
  }

  
  my $external_args_hr = $generator_hr->{external_args_hr};
  my $ptf_file_name = $external_args_hr->{system_directory}."/".$external_args_hr->{system_name}.".ptf";
  &generator_print_verbose("generator_end: writing PTF file ".$external_args_hr->{system_name}.".ptf to ".$external_args_hr->{system_directory}."\n");

  default_ribbit("Cannot write PTF file ".$ptf_file_name."!\n")
    unless(&write_ptf_file($generator_hr->{system_ptf_hr}, $external_args_hr->{system_directory}."/".$external_args_hr->{system_name}.".ptf"));  
}

sub generator_end_read_module_wrapper_string
{
   my $language = &generator_get_language();
   my $ls;

   if($language =~ /vhdl/){
     $ls = ".vhd";
   }elsif($language =~ /verilog/){
     $ls = ".v";
   }else{
     &ribbit("generator_end_read_module_wrapper_string invoked with unkown language");
   }
   my $system_dir = $generator_hr->{external_args_hr}->{system_directory};
   my $module_name = $generator_hr->{external_args_hr}->{target_module_name};

   my $file = $system_dir."/".$module_name.$ls;
   &generator_print_verbose("generator library reading file into string: $file\n");

   open (FILE,"<$file") or ribbit "cannot open file ($file) ($!)\n";
   my $return_string;
   while (<FILE>)
   {
      $return_string .= $_;
   }
   close (FILE);
   return($return_string);
}

sub generator_end_write_module_wrapper_string
{
   my $string = shift or ribbit "no string specified\n";

   my $language = &generator_get_language();
   my $ls;

   print $language;

   if($language =~ /vhdl/){
     $ls = ".vhd";
   }elsif($language =~ /verilog/){
     $ls = ".v";
   }else{
     &ribbit("generator_end_read_module_wrapper_string invoked with unkown language");
   }
   my $system_dir = $generator_hr->{external_args_hr}->{system_directory};
   my $module_name = $generator_hr->{external_args_hr}->{target_module_name};

   my $file = $system_dir."/".$module_name.$ls;
   &generator_print_verbose("generator library writing string into file: $file\n");

   open (FILE,">$file") or ribbit "cannot open file ($file) ($!)\n";
   print FILE $string;
   close (FILE);
}
# end of generator_library.pm





#
#
#
#
# ---------------------------------------------------------------------

# +----------------------------------------------------
# | emit_system_h
# |
# | if "is_cpu", attempt to emit a system.h
# | memory map.
# |

sub emit_system_h($$$)
    {
    my ($sopc_directory,$master,$system_ptf) = (@_);

    # |
    # | Build a system.h file for masters.
    # |


# as of quartus 5.0, we prefer gtf-generate in sopc_builder directly

    my $gtf_generate = "$sopc_directory/bin/gtf-generate";
    my $gtf_filename = "$sopc_directory/bin/gtf/system.h.gtf";
    
    if(! -f $gtf_generate)
    	{
    	# but if sopc_builder is missing it for whatever reason,
    	# try the one in sopc_kit_nios2
    	
	    my $sopc_kit_nios2 = $ENV{SOPC_KIT_NIOS2};
	    if($sopc_kit_nios2 ne "")
	    	{
	    	$gtf_generate = "$sopc_kit_nios2/bin/gtf-generate";
    		$gtf_filename = "$sopc_kit_nios2/bin/gtf/system.h.gtf";
    		}
    	}

    # |
    # | xml template
    # |

    my $stf_template = <<EOP;
<?xml version="1.0" encoding="UTF-8"?>
<stf>
<!-- This file generated on --date-- by --whoami-- -->
    <project name="--project_name--"
             ptf="--system_ptf--"
             dir="--output_directory--"
    />
    <cpu name="--master--" />
</stf>

EOP

    # |
    # | THINK
    # |

    my $output_directory = "./${master}_map";
    my $project_name = "ignored";
    my $stf_filename = "./${master}_project.stf";

    # |
    # | build up template variables
    # |

    my %template_vars;
    $template_vars{date} = fcu_date_time();
    $template_vars{whoami} = $0;
    $template_vars{project_name} = $project_name;
    $template_vars{system_ptf} = $system_ptf;
    $template_vars{output_directory} = $output_directory;
    $template_vars{master} = $master;

    # |
    # | poke in the values to the template
    # |

    foreach my $key (sort(keys(%template_vars)))
        {
        $stf_template =~ s/--$key--/$template_vars{$key}/gs;
        }

    ## debug print $stf_template;

    # |
    # | write out the stf file, so we can soon use it
    # |

    fcu_write_file($stf_filename,$stf_template);

    # |
    # | and use it
    # |

    if(-e $gtf_generate && -e $gtf_filename)
        {

        my $generate_cmd = $gtf_generate;

        $generate_cmd .= " --output-directory=$output_directory";
        $generate_cmd .= " --gtf=$gtf_filename";
        $generate_cmd .= " --stf=$stf_filename";

        r_system($sopc_directory,$generate_cmd);
    
        # |
        # | done with it
        # |

        r_system($sopc_directory,"rm $stf_filename");

        fcu_print_command("Generated memory map \"$output_directory/system.h\"");
        }
    else
        {
        fcu_print_command("Warning: did NOT emit system.h for $master");
        }




    }


sub r_system($$)
    {
    my ($sopc_directory,$cmd) = (@_);
    fcu_print_command($cmd);
    return Run_Command_In_Unix_Like_Shell($sopc_directory,$cmd);
    }







# +------------------------------------------
# | synthesis and simulation files are are
# | listed in CLASS/CB_GENERATOR/HDL_FILES.
# |

sub get_synthesis_files($)
    {
    my ($class_ptf) = (@_);
    my $synthesis_files = "";
    my $simulation_files = "";

    my $hdl_files = get_child_by_path($class_ptf,"CLASS/CB_GENERATOR/HDL_FILES");
    my $child_count = get_child_count($hdl_files);
    for(my $i = 0; $i < $child_count; $i++)
        {
        my $hdl_file = get_child($hdl_files,$i);
        if(get_name($hdl_file) eq "FILE")
            {
            my $filename = get_data_by_path($hdl_file,"filepath");
            my $use_in_synthesis = get_data_by_path($hdl_file,"use_in_synthesis");
            my $use_in_simulation = get_data_by_path($hdl_file,"use_in_simulation");

            if($use_in_synthesis)
                {
                $synthesis_files .= ", " if $synthesis_files;
                $synthesis_files .= $filename;
                }

            if($use_in_simulation)
                {
                $simulation_files .= ", " if $simulation_files;
                $simulation_files .= $filename;
                }
            }
        }

    return $synthesis_files;
    }








sub main
    {

    push(@ARGV,"--verbose=1") if 0;
    my %args = fcu_parse_args(@ARGV);
    
    if(0)
    	{
    	foreach my $key (sort(keys(%args)))
    		{
    		print("--$key = $args{$key} \n");
    		}
    	}

    # |
    # | get the arguments we care about
    # |

    my $class_dir = fcu_get_switch(\%args,"module_lib_dir");


    my $target_module_name = fcu_get_switch(\%args,"target_module_name");
    my $system_name = fcu_get_switch(\%args,"system_name");
    my $sopc_directory = fcu_get_switch(\%args,"sopc_directory");

    # |
    # | preflight the arguments a little
    # |

    my $error_count = 0;

    my $class_ptf_path = "$class_dir/class.ptf";
    if(!-f $class_ptf_path)
        {
        print "error: no class.ptf at \"$class_dir\"\n";
        $error_count++;
        }

    die "$error_count errors" if($error_count > 0);

    # +-------------------------------------------
    # | ok, let us get to work
    # |


    my $class_ptf = new_ptf_from_file($class_ptf_path);

    # |
    # | emit system.h for this module
    # | TODO iff Is_CPU i guess.
    # |

    my $do_emit_system_h = get_data_by_path($class_ptf,
            "CLASS/CB_GENERATOR/emit_system_h");
    if($do_emit_system_h)
        {
        emit_system_h($sopc_directory,
                $target_module_name,
                "./$system_name.ptf");
        }
    
    my $top_module_name = get_data_by_path($class_ptf,
            "CLASS/CB_GENERATOR/top_module_name");
    my $file_name = "";
    
    # | stored as file_name.v:module_name, so we break it open
    if($top_module_name =~ /^(.*):(.*)$/)
        {
        $file_name = $1;
        my $module_name = $2;
        $top_module_name = $module_name;
        }
    
    # | language of this particular module...

    my $module_language = "verilog";
    if($file_name =~ /^.*\.vhd$/)
    	{
    	$module_language = "vhdl";
    	}
    
    # |
    # | consult the CB_GENERATOR/HDL_FILES section regarding
    # | where our HDL files for synthesis are.
    # |
     

    my $synthesis_files = get_synthesis_files($class_ptf);

    
    my $instantiate_in_system_module = get_data_by_path($class_ptf,
    	"CLASS/MODULE_DEFAULTS/SYSTEM_BUILDER_INFO/Instantiate_In_System_Module");



	if($instantiate_in_system_module)
		{
	    generator_enable_mode ("terse");


	    generator_begin (@ARGV);


	    generator_make_module_wrapper(1,$top_module_name,$module_language);

	    generator_copy_files_and_set_system_ptf
    	        (
        	    "simulation_and_quartus", 
                split(/ *, */,$synthesis_files)
#            	"$synthesis_files"
          	  );

		generator_end ();
		}

    exit (0);
    }

$| = 1;  # always polite to flush.
main()

# end of file
