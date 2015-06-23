#######################################################################
# 
# This file is a part of the Rachael SPARC project accessible at
# https://www.rachaelsparc.org. Unless otherwise noted code is released
# under the Lesser GPL (LGPL) available at http://www.gnu.org.
#
# Copyright (c) 2005: 
#   Michael Cowell
#
# Rachael SPARC is based heavily upon the LEON SPARC microprocessor
# released by Gaisler Research, at http://www.gaisler.com, under the
# LGPL. Much of the architectural work on Rachael was done by g2
# Microsystems. Contact michael.cowell@g2microsystems.com for more
# information.
#
#######################################################################
# $Id: File.pm,v 1.1 2008-10-10 21:13:56 julius Exp $
# $URL:  $ 
# $Rev:  $
# $Author: julius $
######################################################################
#
# This file contains the veristruct_file class
#
# This class is for parsing / modifying Verilog files.
#
######################################################################

use Verilog::Veristruct::Structlib;
use Text::Balanced qw (extract_tagged extract_bracketed);
package Verilog::Veristruct::File;

# Global whitespace regex -- also catches comments
$sp = '(?:\s+|\/\/.*?\n|\/\*.*?\*\/)*';
$ssp = '(?:\s+|\/\/.*?$|\/\*.*?\*\/)';
$nsp = '[^(?:\s*|\/\/.*?$|\/\*.*?\*\/)]';
$debug = 0;
$ignore = 0;
$makefile = 0;
@dependencies;

sub new {
    $classobject = {};
    $structlib = new Verilog::Veristruct::Structlib;
    $classobject->{"structlib"} = $structlib;
    $classobject->{"added_lines"} = 0;
    local %variables;
    local %ports;
    $classobject->{"variables"} = \%variables;
    $classobject->{"ports"} = \%ports;
    bless($classobject);
    return $classobject;
}

# Function to load a file
sub load {
    my ($self, $fh) = @_;
    local $buffer;
    while ($line = <$fh>) {
	$buffer .= $line;
    }
    $self->{"buffer"} = \$buffer;
}


# Function to replace structs with verilog for a whole file
sub replace_structs {
    # Call parse - we're not makefiling
    return parse(@_,0);
}

# Function generate a makefile
sub generate_makefile {
    my ($self, $debug_option,$ignore_option,$libpaths, $infile) = @_;
    # Call parse, we *are* generating a makefile
    parse($self, $debug_option, $ignore_option, $libpaths, 1);
    print "Dependencies found: ", join(", ", @dependencies), "\n" if $debug;
    # Trash the output buffer - we don't need it
    my $buffer = $self->{"buffer"};
    $$buffer = "";
    # Construct a makefile that will generate $infile
    print "Checking $infile for .vs extension.\n" if $debug;
    $infile =~ m/(.*?)\.vs$/ or die
	"Makefile mode requires infile to end with extension .vs";
    my $infile_base = $1;
    # outfile is a .v
    my $outfile = $infile_base . ".v";

    # We need to find the dependencies which are themselves veristruct files
    my @normal_deps;
    my @veristruct_deps;

    foreach $dependency (@dependencies) {
	if ($dependency =~ m/(.*?)\.vs$/) {
	    print "Found veristruct dep $1\n" if $debug;
	    push(@veristruct_deps, $1);
	} else {
	    print "Found normal dep $dependency\n" if $debug;
	    push(@normal_deps, $dependency);
	}
    }

    # remove duplicates
    undef %saw;
    @saw{@veristruct_deps} = ();
    @veristruct_deps = keys %saw;
    undef %saw;
    @saw{@normal_deps} = ();
    @normal_deps = keys %saw;
    

    # Start writing the makefile
    $$buffer = "# Automatically generated makefile to create ".
	"$outfile from $infile\n\n";

    my $veristruct_dep_string;

    # Each veristruct dep needs a special bit
    foreach $module (@veristruct_deps) {
        # This rule generates makefiles for veristruct file using veristruct's
        # makefile mode. That makefile will know about dependencies. It
        # needs to be re-run only when the .vs has changed
	$$buffer .= "${module}.make : ${module}.vs\n";
	$$buffer .= "	veristruct -i ${module}.vs -o ${module}.make -m -w -L ".
	    join(",", @$libpaths);
	if ($ignore_option) {
	    $$buffer .= " -f ";
	}
	$$buffer .= "\n";
        # This rule generates a Verilog file from a veristruct file. It must
        # always be run, because only the sub-make knows about the real
        # dependencies
	$$buffer .= "${module}.v : FORCE ${module}.make\n";
	$$buffer .= "	\${MAKE} -f ${module}.make ${module}.v\n\n";
	$veristruct_dep_string .= "${module}.v ";
    }

    # Now for the main bit
    $$buffer .= "$outfile : $infile " . join(" ", @normal_deps) . " " .
	$veristruct_dep_string . "\n";
    
    $$buffer .= "	veristruct -i $infile -o $outfile -w -L ".
	join(",", @$libpaths). "\n\n";

    # End
    $$buffer .= "FORCE:\n\n";
    $$buffer .= ".PRECIOUS: %.v %.make\n";
    $$buffer .= "# End of automatically generated makefile.\n";

}

# Top level parsing function
sub parse {
    my ($self, $debug_option, $ignore_option, $libpaths, $makefile_option) = @_;
    
    $buffer = $self->{"buffer"};
    $buffer or die "You need to call load before parse.";
    pos($$buffer) = 0; # Reset search position

    # Set the debug and makefileglobal variable
    $debug = $debug_option;
    $ignore = $ignore_option;
    $makefile = $makefile_option;
    $pos = pos($$buffer);

    # Find top level tokens
    while ($$buffer =~ m/\G${sp}(${nsp}+)/gmsc) {
	$token = $1;
	print "Top level token: $token\n" if $debug;
	if ($token eq '`sinclude') {
	    # grab filename
	    if ($$buffer !~ m/\G\s+\"([^\"]+)\"/gmsc) {
		$self->report_error(pos($$buffer),
				    "File name not supplied for \`sinclude.");
		return;
	    }
	    # open a filehandle
	    $filepath = find_in_libs($1, $libpaths) or die
		"Couldn't find $1";
	    # This is a dependency
	    push(@dependencies, $filepath);
	    open($fh, "<$filepath");
	    $self->{"structlib"}->load($fh) or die "Couldn't load $1.";
	    # should be a blank line now
	    if ($$buffer !~ m/\G${sp}$/gmsc) {
		$self->report_error(pos($$buffer),
				    "Incorrect syntax after \`sinclude.");
		return;
	    }
	    # This should be commented out now
	    my $savepos = pos($$buffer);
	    pos($$buffer) = $pos;
	    $$buffer =~ m/${sp}/gsmc; #search past whitespace
	    substr($$buffer, pos($$buffer), 0, "//");
	    # Return to save (plus two for the two quotes)
	    pos($$buffer) = $savepos + 2;
	} elsif (($token eq '`include') and $makefile) {
	    # grab filename
	    if ($$buffer !~ m/\G\s+\"([^\"]+)\"/gmsc) {
		$self->report_error(pos($$buffer),
				    "File name not supplied for \`include.");
		return;
	    }
	    # open a filehandle
	    $filepath = find_in_libs($1, $libpaths) or die
		"Couldn't find $1";
	    # This is a dependency
	    push(@dependencies, $filepath);
	} elsif ($token =~ m/\`.*/) {
	    print "Found other processor directive.\n" if $debug;
	    # some other pre-processor directive
	    # seek to the end of the line and ignore
	    $$buffer =~ m/\G.*?\n/gmsc or die "huh?";
	} elsif ($token =~ m/module/ || $token =~ m/macromodule/) {
	    $pos = $self->parse_module(pos($$buffer), $libpaths);
	    (pos($$buffer) = $pos) or die "Module parse failed.";
	    print "We have this left: ", substr($$buffer, pos($$buffer)) if $debug;
	} else {
	    $self->report_error(pos($$buffer),
				"Invalid syntax at top level.");
	    return;
	}
	$pos = pos($$buffer);
    }
    print "Done parsing.\n";
}

# Function to parse modules
sub parse_module {
    my ($self, $pos, $libpaths) = @_;
    
    $buffer = $self->{"buffer"};
    $buffer or die "You need to call load before parse.";

    # Save portlist position to go back and parse later.
    # We need to know if any of the ports are structs first :)
    $portlist_pos = pos($$buffer);
    $$buffer =~ m/\G.*?;/gsmc or
	$self->report_error(pos($$buffer),
			    "Couldn't find end of portlist.");

    $pos = pos($$buffer);

    # Now we are inside the module. See p134 ieee1364.1995 for ebnf
    # loop looking for tokens
    TOKEN: while ($$buffer =~ m/\G(${sp})(${nsp}+)/gmsc) {
	$token = $2;
	$pos += length($1);
	print "Found token: $token\n" if $debug;
	if (($token eq "input") or ($token eq "output") or
	    ($token eq "inout") or ($token eq "reg") or
	    ($token eq "wire")) {

	    $pos=$self->parse_decl($pos, pos($$buffer), $token, $buffer);
	    $pos or $self->report_error(pos($$buffer), 
					"Failed to parse declaration.");
	    pos($$buffer) = $pos;
	    #print "New buffer:\n$$buffer";
	} elsif ($token eq "assign") {
	    #Continuous assignment - parse!
	    # Extract assignment into a buffer and a backup
	    ($$buffer =~ m/\G(.*?;)/gsmc) or
	      $self->report_error($pos, "Failed to parse assign - no semicolon?");
	    # Get parse assign to get us a new assignment statement and some
	    # wire declarations
	    my ($new_assign, $decls) =
		$self->parse_assign(substr($$buffer,$pos,pos($$buffer)-$pos),
				    "wire","=",",");
	   
	    # Shove in the new string
	    $$buffer = substr($$buffer, 0, $pos).$decls.$new_assign.
		substr($$buffer, pos($$buffer));

	    # Set the position pointer
	    #print "New assign:\n$new_assign\n";
	    pos($$buffer) = $pos + length($decls) + length($new_assign);
	    
	} elsif (($token eq "integer") or ($token eq "real") or
		 ($token eq "time") or ($token eq "realtime") or
		 ($token eq "event") or ($token eq "parameter") or
	         ($token eq "defparam") or ($token eq "supply1") or
	         ($token eq "supply0")) {
	    # These aren't handled (because I can't think of any way
	    # in which they could benefit from having struct support)
	    $$buffer =~ m/\G.*?;/gsmc;
	} elsif (($token eq "initial") or ($token eq "always")) {
	    # Save position
	    $before_process = pos($$buffer);
	    # Grab anything before a semicolon or begin statement
	    if ($$buffer !~ m/\G(.*?)(begin|;)/gsmc) {
		report_error($self, pos($$buffer),
			     "Invalid initial / always statement");
	    }
	    # Push that into a block
	    my $block = $1;
	    # If we found begin then do a recursive parse
	    if ($2 eq "begin") {
		$recursive_string = " ".$2.substr($$buffer, pos($$buffer))." ";
		print "Recursive string is: $recursive_string\n" if $debug;
		my ($extract, $remainder, $prefix) =
		    Text::Balanced::extract_tagged($recursive_string,
						   '(?<!\\\w)begin(?!\\\w)',
						   '(?<!\\\w)end(?!\\\w)',
						   undef);
		if (!($extract)) {
		    report_error($self, pos($$buffer),
				 "Invalid initial / always statement. Couldn't".
			         " find a begin/end block.");
		}
		$block .= $extract;
	    }
	    # Now parse the process...
	    my $prefix_length = $before_process - $pos;
	    my $block_length = length($block);
	    my $new_block = $self->parse_block(substr($$buffer, $pos, 
						      $prefix_length) . $block);
	    
	    # Now replace the original block
	    $$buffer = substr($$buffer, 0, $pos) . $new_block .
		substr($$buffer, $pos+$prefix_length+$block_length);

	    # Set position properly
	    pos($$buffer) = $pos + length($new_block);
	} elsif ($token eq "function") {
	    # No support for now
	    $$buffer =~ m/\G.*?endfunction/gsmc;
	} elsif ($token eq "task") {
	    # No support for now
	    $$buffer =~ m/\G.*?endtask/gsmc;
	} elsif ($token eq "specify") {
	    # No support for now
	    $$buffer =~ m/\G.*?endspecify/gsmc;
	} elsif ($token eq "endmodule") {
	    # Now we can go back and parse the portlist
	    $saved_pos = pos($$buffer);
	    pos($$buffer) = $portlist_pos;
	    my $oldlength = length $$buffer;
	    $pos = $self->parse_portlist(pos($$buffer), "main", $buffer);
	    my $newlength = length $$buffer;
	    $pos or $self->
		report_error(pos($$buffer), 
			     "Couldn't parse portlist.");
	    # Return pos to where we were
	    pos($$buffer) = $saved_pos + ($newlength - $oldlength);
	    # Yay we're done
	    print "Finished processing!\n" if $debug;
	    return pos($$buffer);
	} elsif ($token =~ m/\`.*/) {
	    print "Found other processor directive.\n" if $debug;
	    # some other pre-processor directive
	    # seek to the end of the line and ignore
	    $$buffer =~ m/\G.*?\n/gmsc or die "huh?";
	} else {
	    # The only uncaught keywords allowed are module or gate
	    # instantiations. Gate instantations are most probably *not*
	    # going to work with structs. But if you used a struct name
	    # in there I guess you get what you asked for!
	    
	    # $token is the name of a module, which is a dependency
	    # Find it in the library paths and add it to the list (if
	    # we're doing makefile processing)
	    if ($makefile) {
		#my $filepath = find_in_libs("$token.vs", $libpaths) or
		#    $filepath = find_in_libs("$token.v", $libpaths);
		my $filepath;
		#$filepath = find_in_libs("$token.vs", $libpaths);
		#if ($filepath == 0) {
		#    $filepath = find_in_libs("$token.v", $libpaths)
		#    }
		
		#if (filepath == 0) {
		    # This is to double check in the case that find_in_libs returns 0 even though
		    # it has found a correct file
		    foreach $path (@$libpaths) {
			if (-e "$path/$token.vs") {
			    $filepath = "$path/$token.vs";
			}
			if (-e "$path/$token.v") {
			    $filepath = "$path/$token.v";
			}
		    }
		#}
		
		    
		#print "Filepath is $filepath\n"; 
		if ($filepath) {
		    push(@dependencies, $filepath);
		} elsif (!$ignore) {
		    $self->report_error(pos($$buffer),
					"Couldn't find module $token in".
					" library path.");
		    
		}
	    }
	    
	    # First find the openings bracket
	    if ($$buffer !~ m/\G.*?(?=\()/gsmc) {
		$self->report_error(pos($$buffer),
         	 "Parse failed at apparent module instantiation");
	    }

	    print "What sort of module?: ", substr($$buffer, pos($$buffer)), "\n"
		if $debug;
	    
	    # Check if there's a . coming up -- it means named style
	    if ($$buffer =~ /\G${sp}\(${sp}\./sm) {
		print "Named style.\n" if $debug;
		print "We're at :", substr($$buffer, $pos), "\n" if $debug;
		$pos = $self->parse_module_inst($pos);
		$pos or $self->
		    report_error(pos($$buffer), 
				 "Couldn't parse portlist.");
		pos($$buffer) = $pos;
	    } else {
		print "Portlist style\n" if $debug;
		# Can re-use the module portlist method
		$pos = $self->parse_portlist(pos($$buffer), "inst", $buffer);
		$pos or $self->
		    report_error(pos($$buffer), 
				 "Couldn't parse portlist.");
		pos($$buffer) = $pos;
	    }

	}
	# Update saved position at end of while loop
	$pos = pos($$buffer);
    }
    # Shouldn't end here - should end at endmodule
    return;
}

# Check if a struct is defined
sub have_struct {
    my ($self, $struct) = @_;
    if ($self->{"structlib"}->{"structs"}->{$struct}) {
	return 1;
    } else {
	return 0;
    }
}

# Function to parse module port lists
sub parse_portlist {
    my ($self, $pos, $type, $buffer) = @_;
    
    # We should see a module name, then some braces, then
    # some ports seperated by commas. If one of those ports
    # is a struct that we know (i.e. "struct inst") then we have
    # to break it out.

    print "Trying to parse: ", substr($$buffer, pos($$buffer)), "\n" if $debug;

    # Seek past the brace
    ($$buffer =~ m/\G.*?\(/gsmc) or
	$self->report_error(pos($$buffer), 
		  "Failed to find opening brace in portlist.");

    print "After brace: ", substr($$buffer, pos($$buffer)), "\n" if $debug;

    my @port_list;
    # Also use a hash to store positions of ports
    my %port_position;

    if ($type eq "sense") {
	while ($$buffer =~ m/\G${sp}([\w\[\]\:\.\s]+?)(${sp}?\sor)/gsmc) {
	    push(@port_list, $1);
	    # Save the location of this port
	    $port_position{$1} = pos($$buffer) - length($1) - length($2);
	    print "Found element $1\n" if $debug;
	}
    } else { 
	while ($$buffer =~ m/\G${sp}([`\(\)\+\-\*\w\[\]\:\.]+)(${sp},)/gsmc) {
	    push(@port_list, $1); 
            # Save the location of this port
	    $port_position{$1} = pos($$buffer) - length($1) - length($2);
	    print "Found element $1\n" if $debug;
	}
    }

    print "After first elems: ", substr($$buffer, pos($$buffer)), "\n" if $debug;

    # Grab the last one (special case)
    if ($type eq "sense") {
	($$buffer =~ m/\G${sp}([\w\d\[\]\:\.\s]+)(${sp}\)${sp})/gsmc) or
	    $self->report_error(pos($$buffer), 
		  "Failed to find closing brace in port list.");
	# Save the location of this port
	$port_position{$1} = pos($$buffer) - length($1) - length($2);
	# Save the name
	push(@port_list, $1);
	print "Found element $1\n" if $debug;
    } else {
	($$buffer =~ m/\G${sp}([`\(\)\+\-\*\w\[\]\:\. ]*)(${sp}\)${sp};)/gsmc) or
	    $self->report_error(pos($$buffer), 
		  "Failed to find closing brace in port list.");
	# Save the location of this port
	$port_position{$1} = pos($$buffer) - length($1) - length($2);
	# Save the name
	push(@port_list, $1);
	print "Found element $1\n" if $debug;
    }
	
    # Only some ports are structs
    foreach $port (@port_list) {
	$match = $port;
        # Check if this is an element
	if ($port =~ m/(posedge|negedge)*\s*(\w+)\.[\w\.]+
                        ((?:`\w+)|(?:[\[:\w\s]+\])){0,1}$/sx) {
	    if (($self->{"variables"}->{$2}) or ($self->{"ports"}->{$2})) {
		print "Attemping simple scalar expansion replacement\n" if $debug;

		$replacement = $port;
		$temp_port = $port;

		# Replace dots with underscores
		$replacement =~ s/\./__/g;

		# Escape quotes in local name
		$temp_port =~ s/\[/\\\[/;
		$temp_port =~ s/\]/\\\]/;
		
		# Save this
		$match = $temp_port;
		
		# save pos
		$saved_pos = pos($$buffer);
		# seek to start of temp_port
		pos($$buffer) = $pos;	 
		
		print "Buffer before replacement: $$buffer\n" if $debug;
		print "Match is: $match, Replacement is $replacement.\n" if $debug;

		# replace old port string with new port string
		$$buffer =~ s/\G(.*?${sp}?[\(,\s]${sp}?)${match}(${sp}?[\s,\)]${sp}?)/${1}${replacement}${2}/sm;

		print "Buffer after replacement: $$buffer\n" if $debug;
		
		# restore pos
		pos($$buffer) = $saved_pos;
		
		# unset local_name to stop struct matching
		undef($port);
	    }

	} elsif ($port =~ m/(posedge|negedge)*\s*(\w+)
                           ((?:`\w+)|(?:[\[:\w\s]+\])){1}([\w\.]+)$/sx) {
	    if (($self->{"variables"}->{$2}) or ($self->{"ports"}->{$2})) {
		print "Attemping simple scalar expansion replacement\n" if $debug;
		    
		# Need to do some fancy pants extraction here.
		$replacement = $4;
		$temp_port = $port;
		$inst = $2;
		$range = $3;
		
		# Replace dots with underscores
		$replacement =~ s/\./__/g;
		$replacement = $inst.$replacement.$range;
		
		# Escape quotes in local name
		$temp_port =~ s/\[/\\\[/;
		$temp_port =~ s/\]/\\\]/;
		
		# Save this
		$match = $temp_port;
		
		
		# save pos
		$saved_pos = pos($$buffer);
		# seek to start of port
		pos($$buffer) = $pos;	 
		
		# replace old port string with new port string
		$$buffer =~ s/\G(.*?${sp}?[\(,\s]${sp}?)${match}(${sp}?[\s,\)]${sp}?)/${1}${replacement}${2}/sm;
		
		# restore pos
		pos($$buffer) = $saved_pos;
		
		# unset local_name to stop struct matching
		undef($port);
	    }
	} # Now, for structs, check for ranges
 
	elsif ($port =~ m/(\w+)(\[\d+\])/) {
	    $port = $1;
	    $range = $2;
	} else {
	    $range = "";
	}

	print "Trying to match: $port and type is $type\n" if $debug;
	print "Variables known to us are: ", 
	join(", ", keys %{$self->{"variables"}}), ", ", 
	join(", ", keys %{$self->{"ports"}}), "\n" if $debug;

	if (($self->{"ports"}->{$port}) or
	    ($self->{"variables"}->{$port} and !($type eq "main"))) {
	    print "Doing whole struct replacement for $port\n" if $debug;
	    if ($type eq "main") { 
		$struct_name = $self->{"ports"}->{$port};
		if (!($range eq "")) {
		    $self->report_error(pos($$buffer),
					"Range not allowed on ports".
					" in module declaration.");
		}
	    } else {
		if (($self->{"variables"}->{$port}->{"type"} eq "vector") or
		    ($self->{"ports"}->{$port}->{"type"} eq "vector")){
		    if ($range eq "") {
			$self->report_error(pos($$buffer),
					    "Vector struct hooked up to ".
					    "port and not ranged");
		    }
		} 
		$struct_name = $self->{"variables"}->{$port}->{"struct"} or
		    $struct_name = $self->{"ports"}->{$port};
	    }
	    $inst_name = $port;

	    # Set the seperator based on the type of portlist (sensitivty ones
	    # use the seperator or because verilog is weird)
	    my $sep;
	    if ($type eq "sense") {
		$sep = " or";
	    } else {
		$sep = ",";
	    }

	    $port_string =  $self->{"structlib"}->{"structs"}->
	    {$struct_name}->get_portlist_string($inst_name, $range, $sep,
						$self->{"structlib"});
	    
	    print "Before substr...\n" if $debug;
	    # Replace the old string for the new string
	    substr($$buffer, $port_position{$match}, length($match),
		   $port_string);
	    print "After substr...\n" if $debug;
	    
	    # Pos needs to be fixed
	    pos($$buffer) += length($port_string) - length($match);

	    # Finally, need to update the port_position hash
	    foreach $portname (keys %port_position) {
		if ($port_position{$portname} > $port_position{$match}) {
		    # This came after, so needs to be pushed
		    $port_position{$portname} += length($port_string)
			- length($match);
		}
	    }
		
	}
    }

    print "Modified buffer: ", $$buffer, "\n" if $debug;

    pos($$buffer) = $pos;
    # Buffer has changed so we have to seek forward to end again:
    if ($type eq "sense") {
	($$buffer =~ m/\)${sp};?/gsmc) or
	    $self->report_error(pos($$buffer), 
				"Failed to find end of new port list in: ".
				substr($$buffer, pos($$buffer))."\n");
    } else {
	($$buffer =~ m/\)${sp};/gsmc) or
	    $self->report_error(pos($$buffer), 
				"Failed to find end of new port list in: ".
				substr($$buffer, pos($$buffer))."\n");
    }


    return pos($$buffer);
}

# Function to parse declarations
sub parse_decl {
    my ($self, $oldpos, $newpos, $context, $buffer) = @_;

    # Load position
    pos($$buffer) = $newpos;

    # This could be a struct. First we need to check the next
    # token to see if it indicates that this will be an array
    if ($$buffer !~ m/\G${sp}((?:`\w+)|(?:\[.+?\])|(?:\w+))/gmsc) {
	$self->report_error(pos($$buffer), 
			    "Module parsing failed after decl.");
    }
    $token2 = $1;
    
    #So no ` and no [ means scalar
    if ($token2 !~ m/^[`\[].*/) {
	$struct = $token2;
	print "Found parameter: $struct\n" if $debug;
	# Check if this is a struct
	if (!($self->have_struct($struct))) {
	    # We don't have this - advance to nearest ";"
	    # an loop
	    $$buffer =~ m/.*?;/gmsc;
	    return pos($$buffer);
	}
	# Now get the instance name
	if ($$buffer !~ m/\G${sp}(\w+)/gmsc) {
	    $self->report_error(pos($$buffer), 
				"Module parsing failed after decl.");
	}
	$inst = $1;

	# Add this declaration to the variable or port list
	my %decl_info;
	$decl_info{"type"} = "scalar";
	$decl_info{"struct"} = $struct;
	if (($context eq "wire") or ($context eq "reg")) {
	    $self->{"variables"}->{$inst} = \%decl_info;
	} else {
	    # Ports cannot have vectors so don't need data structure
	    $self->{"ports"}->{$inst} = $struct;
	}

	$new_string = $self->{"structlib"}->{"structs"}->
	{$struct}->get_scalar_decl_string($inst, $context,
					  $self->{"structlib"});
	$old_string = $context.$sp.$struct.$sp.$inst;

	# Also we need to check if there's an assignment happening (if this
	# is a wire declaration).
	if ($$buffer !~ m/\G${sp}=${sp}(\w+)/gsmc) {
	    # No equals modifier so just add semicolon
	    $old_string .= $sp.";";
	} else {
	    if (!($context eq "wire")) {
		$self->report_error(pos($$buffer), "Assign in non-wire decl.");
	    }
	    $destination = $1;
	    ($self->{"variables"}->{$destination}->{"struct"} eq $struct) or
		$self->report_error(pos($$buffer),
				    "rvalue must be same sort of struct.");
	    if ($$buffer =~ m/\G${sp}((?:`\w+)|(?:\[[\w:]+\]))${sp};/gsmc) {
		$self->{"variables"}->{$destination} or
		    $self->report_error(pos($$buffer), "rvalue unknown var.");
		($self->{"variables"}->{$destination}->{"type"} eq "vector") or
		    $self->report_error(pos($$buffer),
					"rvalue indexed but not a vector.");
		$range = $1;
		$old_string .= $sp."=".$sp.$destination.$sp.'[\w`\[\]:]+'
		    .$sp.";";
	    } else {
		$old_string .= $sp."=".$sp.$destination.$sp.";";
		$range = "";
	    }
	    $new_string .= $self->{"structlib"}->{"structs"}->
	    {$struct}->get_decl_struct_assign(0,$inst,"",$destination,$range,"=",
					 $self->{"structlib"});
	}
	    
    } else {
	# This is a vector declaration
	$range = $token2;
	# Now get type
	#print "rest buffer: ", substr($$buffer, pos($$buffer));
	if ($$buffer !~ m/\G${sp}(\w+)/gmsc) {
	    $self->report_error(pos($$buffer), 
				"Module typeparsing failed after vector decl.");
	}
	$struct = $1;
	print "Found parameter: $struct\n" if $debug;
	# Check if this is a struct
	if (!($self->have_struct($struct))) {
	    # We don't have this - advance to nearest ";"
	    # an loop
	    $$buffer =~ m/.*?;/gsmc;
	    return pos($$buffer);
	}
	# Now get instance name
	if ($$buffer !~ m/\G${sp}(\w+)/gmsc) {
	    $self->report_error(pos($$buffer), 
				"Module instparsing failed after vector decl.");
	}
	$inst = $1;

	# Add this declaration to the variable or port list
	my %decl_info;
	$decl_info{"type"} = "vector";
	$decl_info{"struct"} = $struct;
	$decl_info{"range"} = $range;
	if (($context eq "wire") or ($context eq "reg")) {
	    $self->{"variables"}->{$inst} = \%decl_info;
	} else {
	    # Ports cannot have vectors so error
	    $self->report_error(pos($$buffer), 
				"Ports can't have arrays of structs");
	}

	$new_string = $self->{"structlib"}->{"structs"}->
	{$struct}->get_vector_decl_string($inst, $context, $range,
					  $self->{"structlib"});
	$old_string = $context.$sp.'[\w`\[\]:]+'.$sp.$struct.$sp.$inst;

        # Also we need to check if there's an assignment happening (if this
	# is a wire declaration).
	if ($$buffer !~ m/\G${sp}=${sp}(\w+)/gsmc) {
	    # No equals modifier so just add semicolon
	    $old_string .= $sp.";";
	} else {
	    $self->report_error(pos($$buffer), "Assignment to an array of".
		" structs is not allowed.");
	}
    }
    
    # Find where the old string ended
    pos($$buffer) = $oldpos;
    $$buffer =~ m/\G($sp)\w.*?;/gsmc;
    
    print "old_string: $old_string" if $debug;
    print "new_string: $new_string" if $debug;
    #print "rest of buffer: ", substr($$buffer, pos($$buffer));
    
    # replace old port string with new port string
    $$buffer = substr($$buffer, 0, $oldpos).$1.$new_string.
	substr($$buffer, pos($$buffer));
    
    print "Modified buffer:\n", $$buffer if $debug;
    
    # restore pos
    pos($$buffer) = $oldpos + length($1) + length($new_string);

    return pos($$buffer);
}

# Function to parse module port lists
sub parse_module_inst {
    my ($self, $pos) = @_;
    
    $buffer = $self->{"buffer"};
    $buffer or die "You need to call load before parse.";

    # Initialize buffer position
    pos($$buffer) = $pos;

    # Similar to above but we have dots and commas now

    # Seek past the brace
    ($$buffer =~ m/\G.*?\(/gsmc) or
	$self->report_error(pos($$buffer), 
		  "Failed to parse module instantiation port list.");

    my @port_list;
    my @local_list;

    while ($$buffer =~ m/\G(${sp})\.${sp}(\w+)${sp}\(${sp}([\w\~\'\[\]\:\.]+)${sp}\)${sp},/gsmc) {
	print "Prefix part $1\n" if $debug;
	print "Port part $2\n" if $debug;
	print "Local part $3\n" if $debug;
	push(@port_list, $2);
	push(@local_list, $3);
    }

    print "Last couple: ", substr($$buffer, pos($$buffer)), "\n" if $debug;

    # Just have to grab the last couple, they're special cases:
    if ($$buffer !~ m/\G${sp}\.${sp}(\w+)${sp}
                        \(${sp}([\w\~\'\[\]\:\.]+)${sp}\)${sp}\)/gsmcx) {
	# Didn't get it?!?
	$self->report_error(pos($$buffer),
			    "Couldn't parse module instantiation.");
    }

    push(@port_list, $1);
    push(@local_list, $2);

    # Similar to last time, loop for each port
    foreach (my $i=0; $i < @port_list; $i++) {

	# Check if this is an element
	if ($local_list[$i] =~ m/(\w+)\.[\w\.]+((?:`\w+)|(?:[\[:\w\s]+\])){0,1}$/sx) {
	    if (($self->{"variables"}->{$1}) or ($self->{"ports"}->{$1})) {
		#print "Attemping simple scalar expansion replacement\n";

		$replacement = $local_list[$i];

		# Replace dots with underscores
		$replacement =~ s/\./__/g;

		# Escape quotes in local name
		$local_list[$i] =~ s/\[/\\\[/;
		$local_list[$i] =~ s/\]/\\\]/;
		
		# Save this
		$match = $local_list[$i];
		
		
		# save pos
		$saved_pos = pos($$buffer);
		# seek to start of port
		pos($$buffer) = $pos;	 
		
		# replace old port string with new port string
		$$buffer =~ s/\G(.*?)${match}/${1}${replacement}/xsm;
		
		# restore pos
		pos($$buffer) = $saved_pos;
		
		# unset local_name to stop struct matching
		undef($local_name);
	    }

	} elsif ($local_list[$i] =~ m/(\w+)((?:`\w+)|(?:[\[:\w\s]+\])){1}
                                     ([\w\.]+)$/sx) {
	    #print "Attemping simple vector expansion replacement\n";
	    if (($self->{"variables"}->{$1}) or ($self->{"ports"}->{$1})) {
		#print "Attemping simple scalar expansion replacement\n";
		    
		# Need to do some fancy pants extraction here.
		$replacement = $3;
		$inst = $1;
		$range = $2;
		
		# Replace dots with underscores
		$replacement =~ s/\./__/g;
		$replacement = $inst.$replacement.$range;
		
		# Escape quotes in local name
		$local_list[$i] =~ s/\[/\\\[/;
		$local_list[$i] =~ s/\]/\\\]/;
		
		# Save this
		$match = $local_list[$i];
		
		
		# save pos
		$saved_pos = pos($$buffer);
		# seek to start of port
		pos($$buffer) = $pos;	 
		
		# replace old port string with new port string
		$$buffer =~ s/\G(.*?)${match}/${1}${replacement}/xsm;
		
		# restore pos
		pos($$buffer) = $saved_pos;
		
		# unset local_name to stop struct matching
		undef($local_name);
	    }
	} # Now, for structs, check for ranges
 
	elsif ($local_list[$i] =~ m/(\w+)(\[\d+\])/) {
	    $local_name = $1;
	    $local_range = $2;
	} else {
	    $local_range = "";
	    $local_name = $local_list[$i];
	}
	
	if ($self->{"variables"}->{$local_name} or
	    $self->{"ports"}->{$local_name}) {
	    
	    if (!defined($self->{"ports"}->{$localname}) and
		$self->{"variables"}->
		{$local_name}->{"type"} eq "vector") {
		if ($local_range eq "") {
		    $self->report_error(pos($$buffer),
					"Vector struct hooked up to ".
					"port and not ranged");
		}
	    }
	    print "Expanding named portlist for $local_name\n" if $debug;
	    
	    # Lookup struct name, and find port string
	    $struct_name = $self->{"variables"}->{$local_name}->{"struct"} or
		$struct_name = $self->{"ports"}->{$local_name} ;
	    $port_string =  $self->{"structlib"}->{"structs"}->
	    {$struct_name}->
	    get_named_portlist_string($local_name,$port_list[$i],
				      $local_range,$self->{"structlib"});
	    # save pos
	    $saved_pos = pos($$buffer);
	    
	    # seek to start of module
	    pos($$buffer) = $pos;	 
	    
            # change names so that square brackets are escaped
	    $local_list[$i] =~ s/\[/\\\[/;
	    $local_list[$i] =~ s/\]/\\\]/;
	    $port_list[$i] =~ s/\[/\\\[/;
	    $port_list[$i] =~ s/\]/\\\]/;

            # This is what we're looking for:
	    $match = "\\.".${sp}.$port_list[$i].${sp}."\\(".
		${sp}.$local_list[$i].${sp}."\\)";

	    # record buffer size
	    my $oldlength = length($$buffer);

	    # replace old port string with new port string
	    $$buffer =~ s/\G(.*?)${match}/${1}${port_string}/xsm;

	    # find length difference
	    my $length_difference = length($$buffer) - $oldlength;

	    print "Length difference is ", $length_difference, "\n"
		if $debug;

	    # restore pos
	    pos($$buffer) = $saved_pos + $length_difference;
	}
    }
    # Buffer has changed so we have to seek forward to end again:
    print "We are at", substr($$buffer, pos($$buffer)), "\n" if $debug;
    ($$buffer =~ m/\G.*?;/gsmc) or
	$self->report_error(pos($$buffer), 
		 "Failed to parse module instantiation port list. End");
    
    return pos($$buffer);
}

# Function to parse continuous assignments
sub parse_assign {
    my ($self, $assign_buffer, $temp_type, $operator, $seperator) = @_;
    
    my $decl_buffer = "";

    print "assign_buffer: $assign_buffer\n" if $debug;
    
    foreach $inst (keys(%{$self->{"variables"}}), 
		   keys(%{$self->{"ports"}})) {
	#restore position for search
	pos($assign_buffer) = 0;
	print "looking for: $inst\nin: $assign_buffer\n" if $debug;
	while ($assign_buffer =~ m/\G(?:^|(?:.*?[^\w\.]))${inst}(?![_\w])/gsmc) {
	    print "found this: ", substr($assign_buffer, pos($assign_buffer)), "\n"
		if $debug;
	    my $start_of_match = pos($assign_buffer);
	    # See if this elem is of the form inst.elem.elem*
	    if ($assign_buffer =~ m/\G(\.[\w\.]+)((?:`\w+)|(?:\[.+?\])){0,1}
                                   ([^\w\[].*)/msgxc) {
		print "Attemping simple scalar expansion replacement\n" if $debug;
		if (!(defined $self->{"ports"}->{$inst}) and
		    $self->{"variables"}->{$inst}->{"type"} eq "vector") {
		    $self->report_error(pos($$buffer),
					"Array of structs treated like element.");
		}
		print "I got $1, $2, $3\n" if $debug;
		my $dotted_string = $1; my $range = $2; my $rest = $3;
		$dotted_string =~ s/\./__/g;
		# Check to make sure this isn't a struct
		my ($dot_struct, $dot_type) = $self->
		    determine_struct($inst.$dotted_string);
		if (!($dot_struct)) {
		    # shove this back in
		    $assign_buffer = substr($assign_buffer,0,$start_of_match)
			.$dotted_string.$range.$rest;
		    pos($assign_buffer) = $start_of_match +
			length($dotted_string) + length($range);
		    print "assign now: $assign_buffer\n" if $debug;
		    next;
		} else {
		    #Need to do whole struct replacement so:
		    pos($assign_buffer) = $start_of_match;
		}
	    } 
	    if ($assign_buffer =~ m/\G((?:`\w+)|(?:\[.+?\])){1}
                                   ([\w\.]+)([^\w\[\.].*)/msgxc) {
		print "Attemping simple vector expansion replacement\n" if $debug;
		if ((defined $self->{"ports"}->{$inst}) or
		    $self->{"variables"}->{$inst}->{"type"} eq "scalar") {
		    $self->report_error(pos($$buffer),
					"Scalar struct treated like array.");
		}
		my $dotted_string = $2; my $range = $1; my $rest = $3;
		$dotted_string =~ s/\./__/g;
		# Check to make sure this isn't a struct
		my ($dot_struct, $dot_type) = $self->
		    determine_struct($inst.$dotted_string);
		if (!($dot_struct)) {
		    # shove this back in
		    $assign_buffer = substr($assign_buffer,0,$start_of_match)
			.$dotted_string.$range.$rest;
		    pos($assign_buffer) = $start_of_match +
			length($dotted_string) + length($range);
		    print "assign now: $assign_buffer\n" if $debug;
		    next;
		} else {
		    #Need to do whole struct replacement so:
		    pos($assign_buffer) = $start_of_match;
		}
		    
	    }
	    if ($assign_buffer =~ m/\G((?:`\w+)|(?:\[.+?\])){1}
                                   (\.([\w\.]+))((?:`\w+)|(?:\[.+?\])){1}
                                   ([^\w\[].*)/msgxc) {
		print "Attempting temporary variable expansion.\n" if $debug;
		my $dotted_string = $2; my $strut_range = $1; my $rest = $5;
		my $elem_range = $4; my $full_elem_range = $3;
		if ($rest !~ m/\G[^=]*[,;]/gsmc) {
		    $self->report_error(pos($$buffer),
					"Arrayed struct element slice not".
					" allowed as an lvalue in continuous".
					" assignment.");
		}
		# find the struct we're using
		my $struct_type = $self->{"variables"}->{$inst}->{"struct"};
		# get this element's full range
		print "Trying to get: $full_elem_range\n" if $debug;
		$full_elem_range = $self->{"structlib"}->{"structs"}->
		    {$struct_type}->get_elem_range_string($full_elem_range,
							$self->{"structlib"});
		print "Got: $full_elem_range\n" if $debug;
		# generate the dotted string
		$dotted_string =~ s/\./__/g;
                # Check to make sure this isn't a struct
		my ($dot_struct, $dot_type) = $self->
		    determine_struct($inst.$dotted_string);
		if (!($dot_struct)) {
		    # create a register declaration
		    $decl_buffer .= $temp_type." ".$full_elem_range." temp__".$inst.
			$dotted_string."=".$inst.$dotted_string.$strut_range."; ";
		    my $rvalue = "temp__".$inst.$dotted_string.$elem_range;
		    
		    # shove this back in
		    $assign_buffer =
			substr($assign_buffer,0,($start_of_match-length($inst))).
			$rvalue.$rest;
		    pos($assign_buffer) = $start_of_match + length($rvalue);
		    print "assign now: $assign_buffer\n" if $debug;
		    next;
		} else {
		    #Need to do whole struct replacement so:
		    pos($assign_buffer) = $start_of_match;
		}

	    } 
	    if ($assign_buffer =~ m/\G(\.[\w\.]+)?((?:`\w+)|(?:[\[:\w\s`\-\+]+\])){0,1}
                                        ([^\w\[].*)/msgxc) {
		my $range = $2; my $rest = $3; my $rrange; my $lrange;
		my $rinst; my $linst; my $sep; 

		# Might add some more stuff to inst
		my $old_inst  =$inst;
		$inst .= $1; my $length_of_suffix = length($1);
		
		print "Whole struct used in assignment $inst -- checking if it's an",
		" l or an r value - \"", $rest, "\"\n" if $debug;
		if ($rest =~ m/\G${sp}([^=]*)${sp}([,;])(.*)/gsmc) {
		    # This must be our rvalue
		    print "This appears to be the rvalue.\n" if $debug;
		    if ($1) { # Expression not empty - bad!
			$self->report_error(pos($$buffer),
					"Struct assignment expressions may only".
			                " contain a scalar struct or single".
			                " struct array slice.");
		    }
		    $rinst = $inst;
		    $rrange = $range;
		    $sep = $2;
		    $rest = $3;
		    pos($assign_buffer) = $start_of_match + $length_of_suffix;
		    # Find the lvalue
		    print "Search for lvalue - \"", substr($assign_buffer, 0,
		    pos($assign_buffer)),
		    "\"\n" if $debug;
		    if ($assign_buffer !~ m/(?:assign|;|,|^)${sp}(([\w\.]+)
                                           ((?:`\w+)|(?:[\[:\w\s`\-\+]+\]))?
                                           ([\w\.]*)${sp}<?=${sp}${inst})\G/xsgmc) {
			# Couldn't find the lvalue
			$self->report_error(pos($$buffer),
					    "Couldn't find lvalue in struct".
					    " assignment. Make sure lvalue is".
					    " a scalar struct or an array struct".
					    " element, and rvalue expression is the".
					    " same.");
		    }
		    # We should have found our lvalue
		    $linst = $2 . $4; $lrange = $3;
		    # Change the start of match to the new one
		    $start_of_match = pos($assign_buffer) - length($1);
		} else {
		    # This must be the lvalue
		    print "This appears to be the lvalue.\n" if $debug;
                    # Find the rvalue
		    print "Search for rvalue - \"", $rest, "\"\n" if $debug;
		    if ($rest !~ m/${sp}<?=${sp}([\w\.]+)((?:`\w+)|(?:[\[:\w\s`\-\+]+\])){0,1}
                                  ([\w\.]*)(.*?)([,;])(.*)/gsmcx) {
			# Couldn't find the rvalue
			$self->report_error(pos($$buffer),
					    "Couldn't find rvalue in struct".
					    " assignment. Make sure lvalue is".
					    " a scalar struct or an array struct".
					    " element, and rvalue expression is the".
					    " same.");
		    }

		    # Pull out our bits of info
		    $rinst = $1 . $3;
		    $rrange = $2;
		    $sep = $5;
		    $rest = $6;
		    if ($4 and ($4 !~ m/\s*/)) { 
                        # There's stuff after the rvalue - bad!
			$self->report_error(pos($$buffer),
					"Struct assignment expressions may only".
			                " contain a scalar struct or single".
			                " struct array slice. This bad: \'$3\'");
		    }
		    $linst = $inst;
		    $lrange = $range;
		    # Set start of match to the right place
		    $start_of_match = $start_of_match - length($old_inst);
		};
                                  
		print "linst: $linst, lrange: $lrange, rinst: $rinst, rrange: $rrange\n" if $debug;
		print "before is: ", substr($assign_buffer,0,$start_of_match), "\n" if $debug;
		$rest and print "rest is: $rest\n" if $debug;
		
		# Linst and rinst maybe be sub instances and some of the dots
		# may already have been changed to __s. So we change them ALL
		# and call the struct and type determination routine
		$linst =~ s/\./__/g;
		my ($lstruct, $ltype) = $self->determine_struct($linst);
		$rinst =~ s/\./__/g;
		my ($rstruct, $rtype) = $self->determine_struct($rinst);

		# Check if these seem right
		if ($rrange and $rrange =~ m/\[\s*\d\s*:\s*\d\s*\]/) {
		    # Range of form [max:min] -- array slice not allowed in assign
		    $self->report_error(pos($$buffer),
					"Struct array slice used in continuous".
					" assign. This is not supported.");
		}
		if (!($rrange)
		    and ($rtype eq "vector")) {
		    # Non ranged array struct type used
		    $self->report_error(pos($$buffer),
					"Struct array $rinst used without range in".
			                " continous assign. This is not supported.");
		}
		if ($lrange and $lrange =~ m/\[\s*\d\s*:\s*\d\s*\]/) {
		    # Range of form [max:min] -- array slice not allowed in assign
		    $self->report_error(pos($$buffer),
					"Struct array slice used in continuous".
					" assign. This is not supported.");
		}
		if (!($lrange)
		    and ($ltype eq "vector")) {
		    # Non ranged array struct type used
		    $self->report_error(pos($$buffer),
					"Struct array $linst used without range in".
			                " continous assign. This is not supported.");
		}

		print "You survived!\n" if $debug;

		print "lstruct: $lstruct, lrstruct: $rstruct\n" if $debug;

		if (!($lstruct eq $rstruct)) {
		    # Different types of struct!
		    $self->report_error(pos($$buffer),
					"Assignment between incompatible structs.");
		}

		# Construct an assignment to replace the struct one
		$new_assign = 
		    $self->{"structlib"}->{"structs"}->{$lstruct}->
		    get_struct_assign($linst, $lrange, $rinst, $rrange,$operator,
		                       $seperator,$self->{"structlib"}, 0);
		
		print "Candidate assign: $new_assign\n" if $debug;

		# Finally, can modify assign buffer
		$assign_buffer = substr($assign_buffer,0,$start_of_match).
		    $new_assign.$sep.$rest;
		pos($assign_buffer) = $start_of_match+length($new_assign)+
		    length($sep);

	    } else {
		$self->report_error(pos($$buffer),
				    "Unsupported continuous assignment involving".
				    " a struct. Please remove.");
	    }
	}
    }

    return ($assign_buffer, $decl_buffer);
}

sub parse_block {
    my ($self, $block) = @_;
    
    # We should get passed a complete always block
    #print "Received process for parsing:\n$block\n";

    my $buffer = $self->{"buffer"};
    my $pos = 0;

    # Seek past the always or initial
    if ($block !~ /(?:initial|always)/gsmc) {
	$self->report_error(pos($$buffer) + pos($block),
			    "Couldn't parse initial / always block.");
    }
    
    while ($block =~ m/\G(${sp})(\S+)/gmsc) {
	$token = $2;
	# Update pos to not include comments / space
	$pos += length($1);
	print "Found token in process: $token\n" if $debug;

	if ($token =~ m/^@/sm) {
	    # Sensitivity list - like port list.
	    # Might have had a bit bushed into the token so reset pos
	    pos($block) = $pos;
	    $pos = $self->parse_portlist(pos($block),"sense",\$block);
	    if (!($pos)) {
		$self->report_error(pos($$buffer)+pos($block),
				    "Port list parse failed.");
	    }
	} elsif (($token eq "begin") or ($token eq "fork")) {
	    # These guys effect scope / simulation only
	    # We should skip past any block identifier
	    $block =~ m/\G${sp}\:${sp}\w+/gsmc;
	    # Declarations can show up after this, but we'll handle them
	    # in the outer loop
	} elsif (($token eq "end") or ($token eq "join")) {
	} elsif (($token eq "reg")) {
	    # Declaration, call declaration parser
	    $self->parse_decl($pos, pos($block), "reg", \$block);
	} elsif (($token eq "integer") or ($token eq "real") or
		 ($token eq "time") or ($token eq "realtime") or
		 ($token eq "event")) {
	    # These are non struct declarations, just find semicolon
	    $block =~ m/\G.*?;/gsmc;
	} elsif (($token eq "assign") or ($token eq "force")) {
	    #Continuous assignment - parse!
	    # Extract assignment into a buffer and a backup
	    ($block =~ m/\G(.*?;)/gsmc) or
	      $self->report_error($pos, "Failed to parse assign - no semicolon?");
	    # Get parse assign to get us a new assignment statement and some
	    # wire declarations
	    my ($new_assign, $decls) =
		$self->parse_assign(substr($block,$pos,pos($block)-$pos),
				    "wire","=",",");
	   
	    # Shove in the new string, put declaration *in front* because
	    # this is a process.
	    $block = $decls.substr($block, 0, $pos).$new_assign.
		substr($block, pos($block));

	    # Set the position pointer
	    #print "New assign:\n$new_assign\n";
	    pos($block) = $pos + length($decls) + length($new_assign);
	} elsif (($token eq "deassign") or ($token eq "release")) {
	    # These should be followed by lvalues, just call the lvalue
	    # replacer.
	    if ($block !~ m/${sp}(\S+)${sp}(?=;)/gsmc) {
		$self->report_error(pos($$buffer)+pos($block),
				    "Can't find end of deassign or release.");
	    }
	    # Get expanded lvalue
	    $new_string = $self->expand_lvalue($token, $1);
	    # Push this back in
	    $block = substr($block, 0, $pos).$new_string.
		substr($block, pos($block));
	    pos($block) = $pos + length($new_string);
	} elsif (($token =~ m/#.*/sm) or ($token eq ";")) {
	    # These can just be ignored =) (they are either timing statements
	    # or junk semicolons, which might legitimately come after timing
	    # statements).
	} elsif (($token eq "repeat") or ($token eq "if") or
		 ($token eq "while") or ($token eq "wait") or
	         ($token eq "for") or ($token =~ m/^(?:$).*/sm)) {
	    # save this position
	    my $after_token = pos($block);
	    # These statements are followed by expressions in brackets. We
	    # can use the expression expander to expand them
	    # Note: although for also can include assignments, whole
	    # struct assignments would be p weird - so i'm just putting this
	    # here.
	    $recursive_string = substr($block, pos($block));
	    print "Recursive string is: $recursive_string\n" if $debug;
	    my ($extract, $remainder, $prefix) =
		Text::Balanced::extract_bracketed($recursive_string, '()');
	    if (!($extract)) {
		report_error($self, pos($$buffer),
			     "Invalid token, couldn't find parens");
	    }
	    print "Extracted: $extract\n" if $debug;  
	    # Update the pos thingo too
	    $after_token += length($prefix);
	    pos($block) = $after_token + length($extract);
	    # Get expanded expression and declaration list
	    ($expanded_expr, $decls) = $self->expand_expression($extract);
	    # Push this into process
	    print "Pushing $expanded_expr into buffer.\n" if $debug;
	    $block = $decls.substr($block, 0, $after_token).$expanded_expr.
		substr($block, pos($block));
	    #print "Buffer is now $block\n";
	    pos($block) = length($decls)+$after_token+length($expanded_expr);
	    print "We're up to: ", substr($block, pos($block)), "\n" if $debug;
	} elsif (($token eq "else") or ($token eq "forever")) {
	    # These can just be skipped because they have no impact on semantic
	    # content of next token
	} elsif ($token eq "case") {
	    # save this position
	    my $after_token = pos($block);
	    # This statements is followed by an expression in brackets. We
	    # can use the expression expander to expand it
	    if ($block !~ m/\G(${sp}\()([^\)]+)(?=\))/gsmc) {
		$self->report_error(0,
				    "Can't find brackets after token that".
		                    " requires them.");
	    }
	    # Update the pos thingo too
	    $after_token += length($1);
	    # Get expanded expression and declaration list
	    ($expanded_expr, $decls) = $self->expand_expression($2);
	    # Push this into process
	    $block = $decls.substr($block, 0, $after_token).$expanded_expr.
		substr($block, pos($block));
	    pos($block) = length($decls)+$after_token+length($expanded_expr)+(1);
	} elsif ($token eq "endcase") {
	} elsif (($token eq '`define') or ($token eq '`undef') or
		 ($token eq '`ifdef') or ($token eq '`else') or
		 ($token eq '`timescale') or ($token eq '`endif')){
	    # Some pre-processor directive, skip to end of line
	    $block =~ m/\G.*?\n/gsmc;
	} elsif ($token eq "default") {
	    # Seek to colon
	    $block =~ m/\G.*?:/gsmc;
	} else {
	    # Need to roll back to before token
	    pos($block) = $pos;
	    # This is one of four things
	    # 1: a blocking assign (token followed by '=' before ';')
	    # 2: a non-blocking assign (token followed by '<=' before ';')
	    # 3: a task enable ("task call") (token followed by '(' before ';')
	    # 4: a case statement (token followed by ',' or ':' beore ';')
	    my $test_buffer = substr($block, pos($block));
	    $test_buffer =~ s/\[.*?\]//g;
	    #print "Looking at: ", $test_buffer, "\n";
	    #print "Trying to work out what this is... ";
	    pos($test_buffer) = 0;
	    if ($test_buffer =~ m/\G[^;:,]+<=/sm) {
		#print "non blocking assign!\n";
		# non blocking assign
		# Extract assignment into a buffer and a backup
		($block =~ m/\G(.*?;)/gsmc) or
		    $self->report_error($pos, "Failed to parse assign - no semicolon?");
		# Get parse assign to get us a new assignment statement and some
		# wire declarations
		my ($new_assign, $decls) =
		    $self->parse_assign(substr($block,$pos,pos($block)-$pos),
					"wire","<=",";");
		
		# Shove in the new string, put declaration *in front* because
		# this is a process.
		$block = $decls.substr($block, 0, $pos).$new_assign.
		    substr($block, pos($block));
		
		# Set the position pointer
		#print "New assign:\n$new_assign\n";
		pos($block) = $pos + length($decls) + length($new_assign);
	    } elsif ($test_buffer =~ m/\G[^;:,]+=/sm) {
		#print "blocking assign!\n";
		# blocking assign
		# Extract assignment into a buffer and a backup
		($block =~ m/\G(.*?;)/gsmc) or
		    $self->report_error($pos, "Failed to parse assign - no semicolon?");
		# Get parse assign to get us a new assignment statement and some
		# wire declarations
		my ($new_assign, $decls) =
		    $self->parse_assign(substr($block,$pos,pos($block)-$pos),
					"wire","=",";");
		
		# Shove in the new string, put declaration *in front* because
		# this is a process.
		$block = $decls.substr($block, 0, $pos).$new_assign.
		    substr($block, pos($block));
		
		# Set the position pointer
		#print "New assign:\n$new_assign\n";
		pos($block) = $pos + length($decls) + length($new_assign);
	    } elsif ($test_buffer =~ m/\G[^;:,]+\(/sm) {
		#print "task enable!\n";
		# task enable
		# These statements are followed by expressions in brackets. We
		# can use the expression expander to expand them
		# Find the first paren
		$block =~ m/\G.*?(?=\()/gsmc;
		print "Found task enable: ",
		substr($test_buffer, pos($test_buffer)), "\n" if $debug;
		# save this position
		my $after_token = pos($block);
		# These statements are followed by expressions in brackets. We
		# can use the expression expander to expand them
		# Note: although for also can include assignments, whole
		# struct assignments would be p weird - so i'm just putting this
		# here.
		$recursive_string = substr($block, pos($block));
		print "Recursive string is: $recursive_string\n" if $debug;
		my ($extract, $remainder, $prefix) =
		    Text::Balanced::extract_bracketed($recursive_string, '()');
		if (!($extract)) {
		    report_error($self, pos($$buffer),
				 "Invalid token, couldn't find parens");
		}
		print "Extracted: $extract\n" if $debug;  
		# Update the pos thingo too
		$after_token += length($prefix);
		pos($block) = $after_token + length($extract);
		# Get expanded expression and declaration list
		($expanded_expr, $decls) = $self->expand_expression($extract);
		# Push this into process
		print "Pushing $expanded_expr into buffer.\n" if $debug;
		$block = $decls.substr($block, 0, $after_token).$expanded_expr.
		substr($block, pos($block));
		#print "Buffer is now $block\n";
		pos($block) = length($decls)+$after_token+length($expanded_expr);
	    } elsif ($test_buffer =~ m/\G[^;]+[,:]/sm) {
		#print "case expression!\n";
		# case expression
                #print "I'm looking in:", substr($block, pos($block)), "\n";
		# Actually we expect a series of comma delimited expressions
		# save this position
		my $after_token = pos($block);
		# This statements is followed by an expression
		while ($block =~ m/\G(${sp})([^,:]+)([,:])/gsmc) {
		    #print "Found an expression: $2\n";
		    # Update the pos thingo too
		    $after_token += length($1);
		    $final_token = $3;
		    # Get expanded expression and declaration list
		    ($expanded_expr, $decls) = $self->expand_expression($2);
		    # Push this into process
		    #print "Expanded case expression is : $expanded_expr\n";
		    $block = $decls.substr($block, 0, $after_token).$expanded_expr.
			$final_token.substr($block, pos($block));
		    pos($block) = length($decls)+$after_token+length($final_token)+
			length($expanded_expr);
		    # break out of this loop if we saw a ":"
		    if ($final_token eq ":") { last; }
		    $after_token = pos($block);
		}
	    } else {
		#Task enable without argument - just skip to semicolon
		$block =~ m/\G.*?;/gsmc;
	    }
	}

        # Update saved position at end of while loop
	$pos = pos($block);
    }

    # Return the new block
    return $block;
}

# Function to parse a bare lvalue (from say, a release command)
# Takes the token before the lvalue and the lvalue itself
sub expand_lvalue {
    my ($self, $token, $lvalue) = @_;
    my $output = "";

    #print "Expand lvalue called with token: $token, lvalue: $lvalue\n";

    if ($lvalue =~ m/(\w+)\.[\w\.]+((?:`\w+)|(?:[\[:\w\s]+\])){0,1}$/sx) {
	if ($self->{"variables"}->{$1}) {
	    #print "Attemping simple scalar expansion replacement\n";
	    
	    $replacement = $lvalue;
	    
	    # Replace dots with underscores
	    $replacement =~ s/\./__/g;
	    
	    $output = $token." ".$replacement;
	} 
    } elsif ($lvalue =~ m/(\w+)((?:`\w+)|(?:[\[:\w\s]+\])){1}([\w\.]+)$/sx) {
	if ($self->{"variables"}->{$1}) {
	    #print "Attemping simple scalar expansion replacement\n";
	    
	    # Need to do some fancy pants extraction here.
	    $replacement = $3;
	    $inst = $1;
	    $range = $2;
		
	    # Replace dots with underscores
	    $replacement =~ s/\./__/g;
	    $replacement = $inst.$replacement.$range;
		
	    $output = $token." ".$replacement;
	    }
    } # Now, for structs, check for ranges
 
    else {
	if ($lvalue =~ m/(\w+)(\[\d+\])/) {
	    $lvalue = $1;
	    $range = $2;
	} else {
	    $range = "";
	}
	if ($self->{"variables"}->{$lvalue}) {
	    #print "Doing whole struct replacement\n";
	    if ($self->{"variables"}->{$lvalue}->{"type"} eq "vector") {
		if ($range eq "") {
		    $self->report_error(pos($$buffer),
					"Vector struct hooked up to ".
					"port and not ranged");
		}
	    } else {
		$struct_name = $self->{"variables"}->{$lvalue}->{"struct"};
	    }
	    $inst_name = $lvalue;

	    # Seperator is semicolon and token because will generate multiple
	    # instructions.
	    my $sep = "; $token ";

	    $port_string =  $self->{"structlib"}->{"structs"}->
	    {$struct_name}->get_portlist_string($inst_name, $range, $sep,
						$self->{"structlib"});
	    
	    $output = $token." ".$port_string;
	}
    }
    return $output;
}

# Function to expand an expression - expressions *can't* currently contain
# whole structs. Only struct element are allowed (but lots of them are ok).
# Takes a string, which will get expanded and returned. Also returned is a list
# of net declarations that should be added to make the expression work.
sub expand_expression {
    my ($self, $expression) = @_;

    # Some local vars
    my $decl_buffer = "";

    foreach $inst (keys(%{$self->{"variables"}}),
		   keys(%{$self->{"ports"}})) {
	#restore position for search
	pos($expression) = 0;
	print "looking for: $inst\nin: $expression\n" if $debug;
	while ($expression =~ m/\G(?:^|(?:.*?[^\w\.]))${inst}(?![_\w])/gsmc) {
	    print "found this: ", substr($expression, pos($expression)), "\n" if $debug;
	    my $start_of_match = pos($expression);
	    # See if this elem is of the form inst.elem.elem*
	    if ($expression =~ m/\G(\.[\w\.]+)((?:`\w+)|(?:[\[:\w\s]+\])){0,1}
                                   ((?:[^\w\[\.])|(?:$))(.*)/msgxc) {
		#print "Attemping simple scalar expansion replacement\n";
		if (!(defined $self->{"ports"}->{$inst}) and
		    $self->{"variables"}->{$inst}->{"type"} eq "vector") {
		    $self->report_error(pos($$buffer),
					"Array of structs treated like element $inst.");
		}
		my $dotted_string = $1; my $range = $2; my $rest = $3.$4;
		$dotted_string =~ s/\./__/g;
		# shove this back in
		$expression = substr($expression,0,$start_of_match)
		    .$dotted_string.$range.$rest;
		pos($expression) = $start_of_match +
		    length($dotted_string) + length($range);
		#print "assign now: $expression\n";
	    } elsif ($expression =~ m/\G((?:`\w+)|(?:[\[:\w\s]+\])){1}
                                   ([\w\.]+)((?:[^\w\[\.])|(?:$))(.*)/msgxc) {
		#print "Attemping simple vector expansion replacement\n";	
		if ((defined $self->{"ports"}->{$inst}) or
		    $self->{"variables"}->{$inst}->{"type"} eq "scalar") {
		    $self->report_error(pos($$buffer),
					"Scalar struct treated like array. $inst");
		}
		my $dotted_string = $2; my $range = $1; my $rest = $3.$4;
		#print "Rest is: $rest\n";
		$dotted_string =~ s/\./__/g;
		# shove this back in
		$expression = substr($expression,0,$start_of_match)
		    .$dotted_string.$range.$rest;
		pos($expression) = $start_of_match +
		    length($dotted_string) + length($range);
		#print "assign now: $expression\n";
	    } elsif ($expression =~ m/\G((?:`\w+)|(?:[\[:\w\s]+\])){1}
                                   (\.([\w\.]+))((?:`\w+)|(?:[\[:\w\s]+\])){1}
                                   ((?:[^\w\[\.])|(?:$))(.*)/msgxc) {
		#print "Attempting temporary variable expansion.\n";
		my $dotted_string = $2; my $strut_range = $1; my $rest = $5.$6;
		my $elem_range = $4; my $full_elem_range = $3;
		# find the struct we're using
		my $struct_type = $self->{"variables"}->{$inst}->{"struct"};
		# get this element's full range
		#print "Trying to get: $full_elem_range\n";
		$full_elem_range = $self->{"structlib"}->{"structs"}->
		    {$struct_type}->get_elem_range_string($full_elem_range,
							$self->{"structlib"});
		#print "Got: $full_elem_range\n";
		# generate the dotted string
		$dotted_string =~ s/\./__/g;
		# create a register declaration
		$decl_buffer .= "wire ".$full_elem_range." temp__".$inst.
		    $dotted_string."=".$inst.$dotted_string.$strut_range."; ";
		my $rvalue = "temp__".$inst.$dotted_string.$elem_range;

		# shove this back in
		$expression =
		    substr($expression,0,($start_of_match-length($inst))).
		    $rvalue.$rest;
		pos($expression) = $start_of_match + length($rvalue);
		#print "assign now: $expression\n";
	    }
	}
    }

    return ($expression, $decl_buffer);
}

sub report_error {
    my ($self, $pos, $error) = @_;
    
    #Find the line that the pos refers to, its alright to blow away things
    $buffer = $self->{"buffer"};
    pos($$buffer) = 0;
    my $line = 0;
    while (pos($$buffer) < $pos) {
	$line++;
	$$buffer =~ m/\n/g;
    }
    $line -= $self->{"added_lines"};
    #Now report error
    print "Error near line $line:\n  $error\n";

    #Exit from program (dud pass makes useless)
    exit(1);
}

sub find_in_libs {
    my ($file, $libpaths) = @_;
    foreach $path (@$libpaths) {
	#print "Looking for $path/$file\n";
	if (-e "$path/$file") {
	    #print "Returning $path/$file\n";
	    return "$path/$file";
	}
    }
    #print "Not returning anything!\n";
    return 0;
}

sub determine_struct {
    my ($self, $inst) = @_;
    my $struct, $type;
    #If there's no __s then we just lookup
    if ($inst !~ m/__/) {
	$struct = $self->{"variables"}->{$inst}->{"struct"} or  
	    $struct = $self->{"ports"}->{$inst};
	$type = $self->{"variables"}->{$inst}->{"type"};
	print "Simple struct: $inst: $struct, $type\n" if $debug;
	return ($struct, $type);
    }
    # Grab the bit before the first __s
    pos($inst) = 0;
    $inst =~ m/(.*?)__/gc;
    $struct = $self->{"variables"}->{$1}->{"struct"} or
	$struct = $self->{"ports"}->{$1};
    $type = $self->{"variables"}->{$1}->{"type"} or $type = "scalar";
    print "Complex struct, base of $inst is: $struct, $type\n" if $debug;
    # Follow the tree
    while ($inst =~ m/(.*?)__/gc) {
	if (!(defined ($self->{"structlib"}->{"structs"}->{$struct}->{"struct_hash"}->
	    {$1}))) {
	    $struct = 0;
	} else {
	    $struct = $self->{"structlib"}->{"structs"}->{$struct}->{"struct_hash"}->
	    {$1}->{"struct"};
	}
	print "Element $1 is of type $struct\n" if $debug;
    }
    

    # Lookup the last element
    if (!(defined ($self->{"structlib"}->{"structs"}->{$struct}->{"struct_hash"}->
	    {substr($inst, pos($inst))}))) {
	$struct = 0;
	print "This was undefined!\n" if $debug;
    } else {
	print "Struct is $struct...",substr($inst, pos($inst)),"\n" if $debug;
	$struct = $self->{"structlib"}->{"structs"}->{$struct}->{"struct_hash"}->
	{substr($inst, pos($inst))}->{"struct"};
	print "Struct is $struct\n" if $debug;
	print "This wasn't undefined!\n" if $debug;
    }
    print "Final element ", substr($inst, pos($inst)), " is of type $struct\n"
	if $debug;
    return ($struct, $type);
}
1;
