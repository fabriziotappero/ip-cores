#!/usr/bin/gawk -f
BEGIN { loc=0 }

/^@ [0-9a-fA-F]/ {
  l=loc;
  loc=strtonum("0x" $2);
  if (l>loc) printf(stderr,"Warning: origin overlap at 0x%x\n",$2) >"stderr";
  while (l++<loc) printf("%c%c",0,0);
  next;
}
/^[0-9a-fA-F]/ { 
  x=strtonum("0x" $1);
  x1=int(x/256);
  x2=x-(x1*256);
  printf("%c%c",x1,x2);
  loc++;
}
