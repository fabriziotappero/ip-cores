# I expect ARGV[0] to be the test dir
chomp(@ARGV[0]);
@md6files = `ls @ARGV[0]`;
$pass = 1;
foreach(@md6files)
{
    if($_=~m/CVS/) {
	next;
    }
   chomp($_);

  print $_; 
  print "\n";

  &buildBits("./md6_encode","@ARGV[0]/$_");
  $pass = &runTest() && $pass;

  for($i=0; $i < 10; $i = $i +1) {
      &buildBits("./md6_random","@ARGV[0]/$_");
      $pass = &runTest() && $pass;
  } 

}

if($pass) {
    print "PASS\n";
}



sub buildBits {
    my ($exec,$file) = @_;
    print "$exec $file md6Input.hex md6Result.hex inputSize.hex\n";
    `$exec $file md6Input.hex md6Result.hex inputSize.hex`;
}

sub runTest {
    system("./MD6TestBench | grep \"PASS\" > out.hex");
    $out = `cat out.hex`;
    if($out =~ "PASS") {
	print "Test $_ passes.\n";
        return 1;
    } else {
	print "Test $_ fails.\n";
        die "failed a test";
    }
}
