#!/usr/bin/php -q
<?php

  // Open the stdin
  $fp = fopen("php://stdin", "r");

  // Start writing to stdout
  echo("/* THIS FILE IS GENERATED AUTOMATICALLY BY THE compile_test SCRIPT */\n");

  // Discard first lines
  for($i=0; $i<6; $i++) fgets($fp);

  // Print only the opcodes to stdout
  $address = 0;
  while (!feof($fp)) {
    $line = fgets($fp);
    $opcode = substr($line, 6, 8);
    if(is_numeric("0x".$opcode)) {
      echo("MEM[$address] <= 32'h$opcode;\n");
      $address++;
    }
  }

  // Fill in the remaining empty locations
  while($address<256) {
    echo("MEM[$address] <= 32'h00000000;\n");
    $address++;
  }

  // Close the input file
  fclose($fp);

?>