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
# $Id: Structlib.pm,v 1.1 2008-10-10 21:13:56 julius Exp $
# $URL: $ 
# $Rev: $
# $Author: julius $
######################################################################
#
# Class for a collection of structs
#
######################################################################

use Verilog::Veristruct::Struct;

package Verilog::Veristruct::Structlib;

sub new {
    $classobject = {};
    local %structs;
    $classobject->{"structs"} = \%structs;
    bless($classobject);
    return $classobject;
} 

# Parses a string (that should contain multiple struct defns)
sub parse {
    my ($self, $struct_string, $string_position) = @_;

    # Set search to begin at the relevant point in the buffer
    pos($$struct_string) = $string_position;

    # Replace comments with nothing
    # Line comments:
    $$struct_string =~ s/\s*\/\/.*?$//mg;
    # Block comments:
    $$struct_string =~ s/\s*\/\*.*?\*\///gs;

    while ($$struct_string =~ m/\G\s*struct/is) {
	$local_struct = new Verilog::Veristruct::Struct;
	$pos = $local_struct->parse($struct_string, 
				    pos($$struct_string));
	if (!$pos) {
	    print "Struct failed to parse.\n";
	    return;
	}
	$self->{"structs"}->{$local_struct->get_name()} 
	  = $local_struct;
	pos($$struct_string) = $pos;
    }

    # This should be the end of the buffer - check
    if ($$struct_string !~ m/\G\s*$/mc) {
	print "EOF expected - not found: ", 
	substr($$struct_string, pos($$struct_string)), "\n";
	return;
    }

    return pos($$struct_string);
}

# Load structs from a file (should already be opened)
sub load {
    my ($self, $handle) = @_;
    # Read in the whole file
    while ($line = <$handle>) {
	$buffer .= $line;
    }
    $self->parse(\$buffer, 0);
}

# For debugging:
sub print_info {
    my ($self) = @_;
    foreach $name (keys (%{$self->{"structs"}})) {
	print "Info for struct named: ", $name, "\n";
	$self->{"structs"}->{$name}->print_elem_info();
    }
}

# Returns the names of the structs that we know
sub get_struct_names {
    my ($self) = @_;
    return keys (%{$self->{"structs"}});
}

1;
