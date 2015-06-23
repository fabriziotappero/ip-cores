####*****************************************************************************************
####**
####**  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are 
####**              provided to you "as is". Xilinx and its licensors make and you 
####**              receive no warranties or conditions, express, implied, statutory 
####**              or otherwise, and Xilinx specifically disclaims any implied 
####**              warranties of merchantability, non-infringement, or fitness for a 
####**              particular purpose. Xilinx does not warrant that the functions 
####**              contained in these designs will meet your requirements, or that the
####**              operation of these designs will be uninterrupted or error free, or 
####**              that defects in the Designs will be corrected. Furthermore, Xilinx 
####**              does not warrant or make any representations regarding use or the 
####**              results of the use of the designs in terms of correctness, accuracy, 
####**              reliability, or otherwise. 
####**
####**              LIMITATION OF LIABILITY. In no event will Xilinx or its licensors be 
####**              liable for any loss of data, lost profits, cost or procurement of 
####**              substitute goods or services, or for any special, incidental, 
####**              consequential, or indirect damages arising from the use or operation 
####**              of the designs or accompanying documentation, however caused and on 
####**              any theory of liability. This limitation will apply even if Xilinx 
####**              has been advised of the possibility of such damage. This limitation 
####**              shall apply not-withstanding the failure of the essential purpose of 
####**              any limited remedies herein. 
####**
####*****************************************************************************************

print "**********************************\n";
print "*\n";
print "*	Preliminary script v1.01\n";
print "*	Author: Stephan Neuhold\n";
print "*\n";
print "**********************************\n\n";
#
#
#
#
################################
################################
#Default commandline switch settings
%default = (	-f		=>	mcs,
				-swap	=>	off,
				-uf		=>	user.txt,
				-pf		=>	prom.mcs);
#
#
#
#
################################
################################
#Define USAGE of script
sub usage
{
	if ($argument eq "-f")
	{
		print "You have not specified a PROM file format!\n"
	}
	elsif ($argument eq "-swap")
	{
		print "You have not specified if bits should be swapped or not!\n"
	}
	elsif ($argument eq "-uf")
	{
		print "You have not specified a file containing user data!\n"
	}
	elsif ($argument eq "-pf")
	{
		print "You have not specifed a PROM file!\n"
	}
	print "usage:\n
		pc.pl [-f : PROM file format {mcs|hex}] [-swap : bits should be swapped {on|off}] [-uf : user data file {<filename.ext>}] [-pf : PROM file {filename.ext}]\n
		-f = PROM file format used
			mcs => Intel file format
			hex => Simple hex file format\n
		
		-swap = Specify if bits are to be swapped
			on => swaps bits in every byte
			off => bits are not swapped\n
		
		-uf = File containing user data to be added to PROM file\n
		
		-pf = PROM file to which user data is to be added\n\n";
}
#
#
#
#
################################
################################
#Place command line arguments into hash				
%commandline_arguments = @ARGV;
#
#
#
#
################################
################################
#Check if all necessary arguments have been given and store them seperately
foreach $argument(keys (%default))
{
	if (exists($commandline_arguments{$argument}))
	{
		if ($argument eq "-f")
		{
			$format = $commandline_arguments{$argument};
		}
		elsif ($argument eq "-swap")
		{
			$do_swap = $commandline_arguments{$argument};
		}
		elsif ($argument eq "-uf")
		{
			$user_file = $commandline_arguments{$argument};
		}
		elsif ($argument eq "-pf")
		{
			$prom_file = $commandline_arguments{$argument};
		}
	}
	else
	{
		print usage($argument);
		exit;
	}
}
#
#
#
#
################################
################################
#Initialise all variables
$prom_line_number = 0;
$user_line_number = 0;
#
#
#
#
################################
################################
#Print settings used
print "\n\n";
print "Running script with following settings:\n";
print "	PROM file format	==>	$format\n";
print "	Bit swapping		==>	$do_swap\n";
print "	User data file		==>	$user_file\n";
print "	Original PROM file	==>	$prom_file\n\n\n";
print "New PROM file is		==>	new_$prom_file\n\n";
#
#
#
#
################################
################################
#Open files and begin processing
open (PROM_FILE, "<$prom_file") || die "Cannot open file $prom_file: $!";
open (NEW_PROM_FILE, ">new_$prom_file") || die "Cannot open file new_$prom_file: $!";
open (USER_DATA, "<$user_file") || die "Cannot open file $user_file: $!";
while (<PROM_FILE>)
{
	$current_prom_line = $_;
	
	#Process "mcs" file format
	if ($format eq "mcs")
	{
		print "Copying original PROM line number $prom_line_number...		\r";
		$prom_line_number = $prom_line_number + 1;
		
		#Get the last information for record type "04"
		get_current_mcs_prom_line_data();
		
		#If the current PROM line is not the last line in the PROM
    	#file then just print it into the new PROM file. If the line
    	#is the last line in the PROM file then we take the previous
    	#line and find its address, so we can add a new line, with
    	#new data at the next address. Also, we calculate a checksum
    	#for the new line in the PROM file and append that to the new
    	#PROM line.
		if ($current_prom_line =~ /\:00000001FF$/)
		{
			print "\n";
			#New address offset starts at 0
			$new_address_offset = 0;
			#Add user data to PROM file
			while (<USER_DATA>)
			{
				chomp;
				if ($_ =~ /^\#/)
				{
					#Ignoring comments
					print "Ignoring comment\r";
				}
				elsif ($_ =~ /\#/g)
				{
					@split_user_line = split(/\#/, $_);
					$current_user_line = @split_user_line[0];
					print "Processing USER line $user_line_number...		\r";
					$user_line_number = $user_line_number + 1;
					#Calculate the new address
					get_mcs_address();
				}
				else
				{
					$current_user_line = $_;
					print "Processing USER line $user_line_number...		\r";
					$user_line_number = $user_line_number + 1;
					#Calculate the new address
					get_mcs_address();
				}
			}
			print NEW_PROM_FILE $current_prom_line;
		}
		else
		{
			#Print the line to the new PROM file unchanged
			print NEW_PROM_FILE $current_prom_line;
			#Store the current line for use in next iteration
			$previous_prom_line = $current_prom_line;
		}
	}
	elsif ($format eq "hex")
	{
	    #Print the original PROM file contents to the new PROM file.
	    if ($do_swap eq "on")
	    {
    		$current_prom_line = $_;
	    	print "Copying original PROM line number $prom_line_number...\r";
			$prom_line_number = $prom_line_number + 1;
	    	print NEW_PROM_FILE $current_prom_line;
	    	print "\n";
    		while (<USER_DATA>)
    		{
	    		if ($_ =~ /^\#/)
	    		{
		    		print "Ignoring comment\r";
	    		}
	    		elsif ($_ =~ /\#/g)
	    		{
		    		chomp;
		    		@split_user_line = split(/\#/, $_);
		    		$current_user_line = @split_user_line[0];
	    			print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
		   			#Extract bytes from user data
    				(@bytes_hex) = unpack("A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2", $current_user_line);
    				foreach $byte_hex(@bytes_hex)
    				{
		    			#Convert hex to decimal
    					$byte_dec = hex($byte_hex);
    					#Convert decimal to binary
    					$byte_binary = decimal2binary($byte_dec);
    					#Get the last eight bits
    					$last_eight_bits = substr($byte_binary, -8);
    					#Extract each bit
    					(@last_eight_bits_not_swapped) = unpack("A1 A1 A1 A1 A1 A1 A1 A1", $last_eight_bits);
    					#Bit swap each bit
    					@last_eight_bits_swapped = reverse(@last_eight_bits_not_swapped);
    					$byte_swapped_bin = 0;
    					#Concatenate the bits to form a byte
    					foreach $bit(@last_eight_bits_swapped)
    					{
		    				$byte_swapped_bin = $byte_swapped_bin.$bit;
    					}
    					#Convert binary to decimal
    					$byte_swapped_dec = binary2decimal($byte_swapped_bin);
    					#Convert decimal to hex
    					$byte_swapped_hex = sprintf "%lx", $byte_swapped_dec;
    					#Get the last byte
    					$byte_hex = substr($byte_swapped_hex, -2);
    					#If the value is less than 0x0F then concatenate a "0" to the front
    					if ($byte_swapped_dec <= 15)
    					{
		    				$byte_hex = "0$byte_hex";
    					}
    					print NEW_PROM_FILE uc("$byte_hex");
    				}
				}
				else
				{
					chomp;
					$current_user_line = $_;
					print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
		   			#Extract bytes from user data
    				(@bytes_hex) = unpack("A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2", $current_user_line);
    				foreach $byte_hex(@bytes_hex)
    				{
		    			#Convert hex to decimal
    					$byte_dec = hex($byte_hex);
    					#Convert decimal to binary
    					$byte_binary = decimal2binary($byte_dec);
    					#Get the last eight bits
    					$last_eight_bits = substr($byte_binary, -8);
    					#Extract each bit
    					(@last_eight_bits_not_swapped) = unpack("A1 A1 A1 A1 A1 A1 A1 A1", $last_eight_bits);
    					#Bit swap each bit
    					@last_eight_bits_swapped = reverse(@last_eight_bits_not_swapped);
    					$byte_swapped_bin = 0;
    					#Concatenate the bits to form a byte
    					foreach $bit(@last_eight_bits_swapped)
    					{
		    				$byte_swapped_bin = $byte_swapped_bin.$bit;
    					}
    					#Convert binary to decimal
    					$byte_swapped_dec = binary2decimal($byte_swapped_bin);
    					#Convert decimal to hex
    					$byte_swapped_hex = sprintf "%lx", $byte_swapped_dec;
    					#Get the last byte
    					$byte_hex = substr($byte_swapped_hex, -2);
    					#If the value is less than 0x0F then concatenate a "0" to the front
    					if ($byte_swapped_dec <= 15)
    					{
		    				$byte_hex = "0$byte_hex";
    					}
    					print NEW_PROM_FILE uc("$byte_hex");
    				}
				}
    		}
    	}
    	#Simply print the original file and then the user data
    	#into the new PROM file.
    	elsif ($do_swap eq "off")
    	{
    		$current_prom_line = $_;
	    	print "Copying original PROM line number $prom_line_number...\r";
			$prom_line_number = $prom_line_number + 1;
	    	print NEW_PROM_FILE $current_prom_line;
	    	print "\n";
    		while (<USER_DATA>)
    		{
	    		if ($_ =~ /^\#/)
	    		{
		    		print "Ignoring comment\r";
	    		}
	    		elsif ($_ =~ /\#/g)
	    		{
		    		chomp;
		    		@split_user_line = split(/\#/, $_);
		    		$current_user_line = @split_user_line[0];
	    			print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
    				print NEW_PROM_FILE uc("$current_user_line");
				}
				else
				{
					chomp;
					print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
    				$current_user_line = $_;
    				print NEW_PROM_FILE uc("$current_user_line");
				}
    		}
    	}
	}
}
close (USER_DATA) || die "Cannot close file $user_file: $!";
close (PROM_FILE) || die "Cannot close file $prom_file: $!";
close (NEW_PROM_FILE) || die "Cannot close file new_$prom_file: $!";
print "\nDONE...\n";
#
#
#
#
################################
################################
#Get the data from the current prom line
sub get_current_mcs_prom_line_data
{
	($start_character, $byte_count_hex) = unpack("A1 A2", $current_prom_line);
	#Convert byte count from hex to decimal
	$byte_count_dec = hex($byte_count_hex);
	$byte_count_dec = $byte_count_dec * 2;	
	#Based on byte count get other fields from the PROM line
	(	$start_character,
		$byte_count_hex,
		$address_hex[0],
		$address_hex[1],
		$record_type_hex,
		$all_data_hex,
		$checksum_hex
	) = unpack("A1 A2 A2 A2 A2 A$byte_count_dec A2", $current_prom_line);
	#If this is a "04" record type then store its information
	if ($record_type eq "04")
	{
		$last_04_record_data_hex = $all_data_hex;
	}
}
#
#
#
#
################################
################################
#Calculate the new address to be used
sub get_mcs_address
{
	#Get the address from the PROM file
	($address_hex) = unpack("x3 A4", $previous_prom_line);
	#Convert the hex address to decimal
	$address_dec = hex($address_hex);
	#Calculate new address value based on existing address value
	if ($address_dec eq "65520")
	{
		#Store current user data temporarily
		$temporary_current_user_line = $current_user_line;
		#New address starts at zero
		$new_address_dec = 0;
		$new_address_hex = "0000";
		($address_hex[0], $address_hex[1]) = unpack("A2 A2", $new_address_hex);
	    $address_dec[0] = hex($address_hex[0]);
    	$address_dec[1] = hex($address_hex[1]);
		$new_address_offset = 0;
		#Convert hex record data to decimal
		$new_04_record_data_dec = hex($last_04_record_data_hex);
		#Calculate new record "04" data
		$new_04_record_data_dec = $new_04_record_data_dec + 1;
		#Convert to hex
		$new_04_record_data_hex = sprintf "%lx", $new_04_record_data_dec;
		#Store for next use
		$last_04_record_data_hex = $new_04_record_data_hex;
		#Make data at least 4 characters long (i.e. 2 data bytes)
		$length = length($new_04_record_data_hex);
		if ($length > 4)
		{
			die "Record data is too large....Quitting: $!";
		}
		else
		{
			for ($i = 0; $i < 4 - $length; $i++)
			{
				$new_04_record_data_hex = "0$new_04_record_data_hex";
			}
		}
		#Define new record data
		$byte_count_hex = "02";
		$byte_count_dec = hex($byte_count_hex);
		$record_type_hex = "04";
		$record_type_dec = hex($record_type_hex);
		$current_user_line = $new_04_record_data_hex;
		#Calculate checksum for new "04" record
		calculate_mcs_checksum();
		#Print new "04" record to new PROM file
		print NEW_PROM_FILE uc(":$byte_count_hex$new_address_hex$record_type_hex$new_04_record_data_hex$checksum_hex\n");
		$previous_prom_line = uc(":$byte_count_hex$new_address_hex$record_type_hex$new_04_record_data_hex$checksum_hex\n");
		#Restore current user data from temporary storage
		$current_user_line = $temporary_current_user_line;
	}
	else
	{
		#Calculate the offset for the next address to be used in the PROM file
		$new_address_offset = 16;#$new_address_offset + 16;
		#Calculate the new address
		$new_address_dec = $address_dec + $new_address_offset;
	}
	#Convert new address to hex
	$new_address_hex = sprintf "%lx", $new_address_dec;
	#Make address at least 4 characters long (i.e. 2 address bytes)
	$length = length($new_address_hex);
	if ($length > 4)
	{
		die "Address is too large....Quitting: $!";
	}
	else
	{
		for ($i = 0; $i < 4 - $length; $i++)
		{
			$new_address_hex = "0$new_address_hex";
		}
	}
	($address_hex[0], $address_hex[1]) = unpack("A2 A2", $new_address_hex);
    $address_dec[0] = hex($address_hex[0]);
    $address_dec[1] = hex($address_hex[1]);
	$byte_count_dec = "16";
	$byte_count_hex = "10";
	$record_type_dec = "00";
	$record_type_hex = "00";
	#Calculate checksum for current user data
	calculate_mcs_checksum();
	#Print new data to new PROM file
	print NEW_PROM_FILE uc(":$byte_count_hex$new_address_hex$record_type_hex$current_user_line$checksum_hex\n");
	$previous_prom_line = uc(":$byte_count_hex$new_address_hex$record_type_hex$current_user_line$checksum_hex\n");
}
#
#
#
#
################################
################################
#Calculate the checksum for the new line
sub calculate_mcs_checksum
{
	$skip = 0;
	$data_sum_hex = 0;
	$data_sum_dec = 0;
	#Based on byte count get individual data bytes and their sum
	for ($d = 0; $d < $byte_count_dec; $d++)
	{
		($data_hex[$d]) = unpack("x$skip A2", $current_user_line);
		$skip = $skip + 2;
		#Convert data byte to decimal format
		$data_dec[$d] = hex($data_hex[$d]);
		#Add all data bytes together
		$data_sum_dec = $data_sum_dec + $data_dec[$d];
		#convert decimal to hex format
		$data_sum_hex = sprintf "%lx", $data_sum_dec;
	}
	#Add all fields together
	$all_sum_dec = $data_sum_dec + $byte_count_dec + $address_dec[0] + $address_dec[1] + $record_type_dec;
    #Convert the decimal sum to hex format
    $all_sum_hex = sprintf "%lx", $all_sum_dec;
    #Get the last two bytes of the hex sum
    $last_two_bytes_of_sum_hex = substr($all_sum_hex, -2);
    #Convert the last two bytes of the hex sum to decimal format
    $last_two_bytes_of_sum_dec = hex($last_two_bytes_of_sum_hex);
    #Invert the bits - 1's complement
    $inverted_dec = $last_two_bytes_of_sum_dec ^ 255;
    #Convert the 1's complement to hex format
    $inverted_hex = sprintf "%lx", $inverted_dec;
    #Get the last two bytes of 1's complement in hex format
    $last_two_bytes_of_inverted_dec = hex($inverted_hex);
    #Add 1 to last two bytes - 2's complement
    $checksum_dec = $last_two_bytes_of_inverted_dec + 1;
    #Convert 2's complement to hex format
    $last_two_bytes_2s_hex = uc(sprintf "%lx", $checksum_dec);
    #Get the last two bytes of hex 2's compliment
    ($checksum_he) = substr($last_two_bytes_2s_hex, -2);
    #If value is less than two characters then add a '0'
    if ($checksum_dec <= 15)
    {
    	$checksum_hex = "0$checksum_he";
    }
    else
    {
    	$checksum_hex = $checksum_he;
    }
}
#
#
#
#
################################
################################
#Decimal to binary representation conversion
sub decimal2binary
{
    my $bin_value = unpack("B32", pack("N", shift));
    $bin_value =~ s/^0+(?=d)//;
    return $bin_value;
}
#
#
#
#
################################
################################
#Binary to decimal representation conversion
sub binary2decimal
{
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}