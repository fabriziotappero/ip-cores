% A peculiar example of MMIXAL
     LOC   Data_Segment  % location #2000000000000000
     OCTA  1F            % a future reference
a    GREG  @             % $254 is base register for ABCD
ABCD BYTE  "ab"          % two bytes of data
     LOC   #123456789    % switch to the instruction segment
Main JMP   1F            % another future reference
     LOC   @+#4000       % skip past 16384 bytes
2H   LDB   $3,ABCD+1     % use the base register
     BZ    $3,1F; TRAP   % and refer to the future again
# 3 "foo.mms"            % this comment is a line directive
     LOC   2B-4*10       % move 10 tetras before prev loc
1H   JMP   2B            % resolve previous references to 1F
     BSPEC 5             % begin special data of type 5
     TETRA &a<<8         % four bytes of special data
     WYDE  a-$0          % two more bytes of special data
     ESPEC               % end a special data packet
     LOC   ABCD+2        % resume the data segment
     BYTE  "cd",#98      % assemble three more bytes of data
