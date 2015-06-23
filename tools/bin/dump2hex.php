#!/usr/bin/php -q
<?php

  // Open the stdin
  $fp = fopen("php://stdin", "r");

  // Discard first lines
  for($i=0; $i<6; $i++) fgets($fp);

  // Print only the opcodes to stdout
  while (!feof($fp)) {
    $line = fgets($fp);
    $opcode = substr($line, 6, 8);
    $caratteri = strlen($opcode);
    if($caratteri != 0){
        echo $opcode."\n";
    }
    else{
        for($i=0; $i<1; $i++) fgets($fp);
     } 
    }

  // Close the input file
  fclose($fp);

?>
     
