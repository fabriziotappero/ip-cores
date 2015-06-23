#!/usr/bin/gawk -f

function lineout() {
    cksum=ct+int((loc)/256)+int((loc)%256)+cksum; 
    cksum=(cksum)%256;
    cksum=xor(cksum,0xFF);
    cksum=(cksum+1)%256;
    if (line!="") printf(":%02x%04x00%s%02x\n",ct,loc,line,cksum);
    loc+=ct;
    line="";
    ct=0;
    newline=0;
}

BEGIN { loc=0; newline=0;ct=0; cksum=0; line=""; }

/^@ [0-9a-fA-F]/ {
  lineout();
  loc=strtonum("0x" $2);
  loc=loc*2;  # adjust for byte adjust
  next;
}


/^[0-9a-fA-F]/ {
  x=strtonum("0x" $1);
  x1=int(x/256);
  x2=x-(x1*256);
  line=sprintf("%s%02x%02x",line,x1,x2);
  ct+=2;
  cksum=cksum+x1+x2;

  if (ct==16) {
    lineout();
  }
}

END { lineout(); printf(":00000001FF\n"); }  # need to fix checksum 
