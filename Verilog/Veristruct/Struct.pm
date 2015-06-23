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
# $Id: Struct.pm,v 1.1 2008-10-10 21:13:56 julius Exp $
# $URL: $ 
# $Rev: $
# $Author: julius $
######################################################################
#
# This file is the struct module of the Veristruct Perl program.
#
# This class supports structs. It can parse struct definitons, and
# print out various struct representations.
#
######################################################################

use Verilog::Veristruct::Structlib;

package Verilog::Veristruct::Struct;

our $debug = 1;

sub new {
    $classobject = {};
    bless($classobject);
    local %struct_hash;
    $classobject->{"struct_hash"} = \%struct_hash;
    return $classobject;
} 

# Parses a string (that should be a valid struct definition)
sub parse {
    my ($self, $struct_string, $string_position) = @_;

    # Set search to begin at the relevant point in the buffer
    pos($$struct_string) = $string_position;

    # Find struct name
    if ($$struct_string !~ m/\G\s*struct\s+(\w+)\s*{/gis) {
	print "Couldn't find pattern: 'struct name {' in struct block.\n";
	return;
    }

    $self->{"name"} = $1;

    # Find all elements  
    while ($$struct_string =~ m/\G\s*(\w+)\s+(\w+)/gcs) {

	# Pull out the back-references
	my $elem_type = $1; my $elem_name = $2;

	if ($elem_type eq "wire") {
	    if ($$struct_string =~ m/\G\s*(\S+)\s*;/gcs) {
		# Ranged wire
		my $range = $1;
		$self->{"struct_hash"}->{$elem_name} = {};
		$self->{"struct_hash"}->{$elem_name}->{"type"} = "vector";
		$self->{"struct_hash"}->{$elem_name}->{"range"} = $range;
	    } elsif ($$struct_string =~ m/\G\s*;/gcs) {
		$self->{"struct_hash"}->{$elem_name} = {};
		$self->{"struct_hash"}->{$elem_name}->{"type"} = "wire";
	    } else {
		print "Invalid syntax in struct file - semicolon not",
		" found after element definition.";
		return;
	    }
	} elsif ($elem_type eq "signed") {
	    if ($$struct_string =~ m/\G\s*(\S+)\s*;/gcs) {
		# Ranged wire
		my $range = $1;
		$self->{"struct_hash"}->{$elem_name} = {};
		$self->{"struct_hash"}->{$elem_name}->{"type"} = "svector";
		$self->{"struct_hash"}->{$elem_name}->{"range"} = $range;
	    } elsif ($$struct_string =~ m/\G\s*;/gcs) {
		$self->{"struct_hash"}->{$elem_name} = {};
		$self->{"struct_hash"}->{$elem_name}->{"type"} = "signed";
	    } else {
		print "Invalid syntax in struct file - semicolon not",
		" found after element definition.";
		return;
	    }
	}  else {
	    $self->{"struct_hash"}->{$elem_name} = {};
	    $self->{"struct_hash"}->{$elem_name}->{"type"} = "struct";
	    $self->{"struct_hash"}->{$elem_name}->{"struct"} = $elem_type;

            # Check for closing brace
	    if ($$struct_string !~ m/\G\s*;/gcs) {
		print "Invalid syntax in struct file - semicolon not",
		" found after element definition.\n";
		print "Rest of buffer is: ",
		substr($$struct_string, pos($$struct_string)), "\n";
		return;
	    }
	}
        
    }

    # Find closing brace
    if ($$struct_string !~ m/\G\s*};/gcs) {
	print "Couldn't find closing brace in struct defn.\n";
	return;
    }

    # Push position back to method that called us
    return pos($$struct_string);
}

# For debugging:
sub print_elem_info {
    my ($self) = @_;
    foreach $elem_name (keys (%{$self->{"struct_hash"}})) {
	print "  $elem_name: ";
	my $type = $self->{"struct_hash"}->{$elem_name}->{"type"};
	if (($type eq "wire") or ($type eq "signed")) {
	    print "wire\n";
	} elsif (($type eq "vector") or ($type eq "svector")) {
	    my $range = $self->{"struct_hash"}->{$elem_name}->{"range"};
	    print "vector, range is $range\n";
	} elsif ($type eq "struct") {
	    my $struct = $self->{"struct_hash"}->{$elem_name}->{"struct"};
	    print "nested struct of type $struct\n";
	}
    }
}

sub get_name {
    my ($self) = @_;
    return $self->{"name"};
}

# Function to return a valid portlist string
sub get_portlist_string {
    my ($self, $inst_name, $range, $sep, $structlib) = @_;
    my $buffer; my $seperator = "";
    
    foreach $elem (keys (%{$self->{"struct_hash"}})) {
	my $type = $self->{"struct_hash"}->{$elem}->{"type"};
	if (($type eq "wire") or ($type eq "vector") or
	    ($type eq "signed") or ($type eq "svector")) {
	    $buffer .= $seperator . $inst_name . "__" . $elem . $range;
	    $seperator = $sep." ";
	} else {
	    # nested struct
	    my $struct = $self->{"struct_hash"}->{$elem}->{"struct"};
	    if (!($structlib->{"structs"}->{$struct})) {
		print "Nested struct named $struct_name in module port list",
		" undefined. Failure.\n";
		return;
	    }
	    $buffer .= $seperator .
		$structlib->{"structs"}->{$struct}->get_portlist_string(
		($inst_name . "__" . $elem), $range, $sep, $structlib);
	    $seperator = $sep." ";
	}
    }

    return $buffer;
}

# Function to return a named portlist string
sub get_named_portlist_string {
    my ($self, $local_name, $port_name, $local_range, $structlib) = @_;
    my $buffer; my $seperator = "";
    
    foreach $elem (keys (%{$self->{"struct_hash"}})) {
	my $type = $self->{"struct_hash"}->{$elem}->{"type"};
	if (($type eq "wire") or ($type eq "vector") or
	    ($type eq "signed") or ($type eq "svector")) {
	    $buffer .= $seperator . "." . $port_name . "__" . $elem . 
		" (" . $local_name . "__" . $elem . $local_range. ")";
	    $seperator = ", ";
	} else {
	    # nested struct
	    my $struct = $self->{"struct_hash"}->{$elem}->{"struct"};
	    if (!($structlib->{"structs"}->{$struct})) {
		print "Nested struct named $struct_name in module port list",
		" undefined. Failure.\n";
		return;
	    }
	    $buffer .= $seperator .
		$structlib->{"structs"}->{$struct}->
		get_named_portlist_string(($local_name . "__" . $elem), 
		  ($port_name . "__" . $elem), $local_range, $structlib);
	    $seperator = ", ";
	}
    }

    return $buffer;
}

# Function to get a whole struct assignment
sub get_decl_struct_assign {
    my ($self, $procedural, $left, $lrange, 
	$right, $rrange, $operator, $structlib) = @_;
    my $buffer;

    if ($procedural) {$assign = "";} else {$assign = "assign ";}

    foreach $elem (keys (%{$self->{"struct_hash"}})) {
	my $type = $self->{"struct_hash"}->{$elem}->{"type"};
	if (($type eq "wire") or ($type eq "vector") or
	    ($type eq "signed") or ($type eq "svector")) {
	    $buffer.="${assign}${left}__$elem$lrange $operator ".
	    "${right}__$elem$rrange; ";
	} else {
	    # nested struct
	    my $struct = $self->{"struct_hash"}->{$elem}->{"struct"};
	    if (!($structlib->{"structs"}->{$struct})) {
		print "Nested struct named $struct in assignment",
		" undefined. Failure.\n";
		return;
	    }
	    $buffer .= 
		$structlib->{"structs"}->{$struct}->get_decl_struct_assign(
		$procedural, ($left."__".$elem), $lrange, ($right."__".$elem), 
		    $rrange, $operator, $structlib);
	    $seperator = ", ";
	}
    }

    return $buffer;
}

# Function to return a struct declaration:
sub get_scalar_decl_string {
    my ($self, $inst, $context, $structlib) = @_;
    my $buffer;
    foreach $elem (keys (%{$self->{"struct_hash"}})) {
	my $type = $self->{"struct_hash"}->{$elem}->{"type"};
	if ($type eq "wire") {
	    $buffer .= "$context ${inst}__${elem}; ";
	} elsif ($type eq "vector") {
	    my $range = $self->{"struct_hash"}->{$elem}->{"range"};
	    $buffer .= "$context $range ${inst}__${elem}; ";
	} elsif ($type eq "signed") {
	    $buffer .= "$context signed ${inst}__${elem}; ";
	} elsif ($type eq "svector") {
	    my $range = $self->{"struct_hash"}->{$elem}->{"range"};
	    $buffer .= "$context signed $range ${inst}__${elem}; ";
	} elsif ($type eq "struct") {
	    my $struct = $self->{"struct_hash"}->{$elem}->{"struct"};
	    $buffer .= $structlib->{"structs"}->{$struct}->
		get_scalar_decl_string(($inst."__".$elem), $context, 
				       $structlib);
	}
    }
    return $buffer;
}

# Function to return a struct declaration:
sub get_vector_decl_string {
    my ($self, $inst, $context, $range, $structlib) = @_;
    my $buffer;
    foreach $elem (keys (%{$self->{"struct_hash"}})) {
	my $type = $self->{"struct_hash"}->{$elem}->{"type"};
	if ($type eq "wire") {
	    $buffer .= "$context ${range}${inst}__${elem}; ";
	} elsif ($type eq "vector") {
	    my $elem_range = $self->{"struct_hash"}->{$elem}->{"range"};
	    $buffer .= "$context $elem_range${inst}__${elem}$range; ";
	} elsif ($type eq "signed") {
	    $buffer .= "$context signed ${range}${inst}__${elem}; ";
	} elsif ($type eq "svector") {
	    my $elem_range = $self->{"struct_hash"}->{$elem}->{"range"};
	    $buffer .= "$context signed $elem_range${inst}__${elem}$erange; ";
	} elsif ($type eq "struct") {
	    my $struct = $self->{"struct_hash"}->{$elem}->{"struct"};
	    $buffer .= $structlib->{"structs"}->{$struct}->
		get_scalar_decl_string(($inst."__".$elem), $context, 
				       $structlib);
	}
    }
    return $buffer;
}

# Get elem range string
sub get_elem_range_string {
    my ($self, $elem_string, $structlib) = @_;
    if ($elem_string =~ m/(\w+)\.(.*)/) {
	$struct = $self->{"struct_hash"}->{${1}}->{"struct"};
	$struct or die
	    "${1} not a valid struct.";
	return $structlib->{"structs"}->{$struct}->get_elem_range_string($2,$structlib);
    }
    return $self->{"struct_hash"}->{$elem_string}->{"range"};
}

# Retuns a series of assignments (that copies one struct to another)
sub get_struct_assign {
    my ($self, $linst, $lrange, $rinst, $rrange, $op, $seperator, $structlib, $recurs) = @_;
    my $buffer;
    foreach $elem (keys (%{$self->{"struct_hash"}})) {
	my $type = $self->{"struct_hash"}->{$elem}->{"type"};
	if ($type eq "wire"  or $type eq "vector") {
	    $buffer .= "${linst}__${elem}${lrange}${op}${rinst}__${elem}".
		"${rrange}${seperator}";
	    #print "Buffer now $buffer\n";
	} elsif ($type eq "struct") {
	    my $struct = $self->{"struct_hash"}->{$elem}->{"struct"};
	    $buffer .= $structlib->{"structs"}->{$struct}->
		get_struct_assign(($linst."__".$elem), $lrange, ($rinst."__".$elem),
				  $rrange, $op, $seperator, $structlib, 1);
	    #print "Buffer now $buffer\n";
	}
    }
    # Have to remove the last seperator if we're not recursive
    if (!($recurs)) {
	#print "Recurs is $recurs\n";
	$buffer =~ s/(.*)${seperator}/$1/;
    }
    return $buffer;
}

1;
