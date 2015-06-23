% illustrations for mmix.w

beginfig(1)
numeric r; r=.5in; % radius of circle
numeric rr; rr=.9in; % radius of arc

pickup pencircle scaled .6pt;
draw (r,0){up}...(0,r){left}...(-r,0){down}...(0,-r){right}...cycle;
pickup pencircle scaled .3pt;
for a=-45, 30, 180:
  z[a]=(r+10pt,0) rotated (a+10);
  draw ((r-4pt,0)--(r+20pt,0)) rotated a;
endfor
label.rt(btex $\alpha$ etex,z[-45]-(2pt,6pt));
label.rt(btex $\beta$ etex,z[30]+(0,2pt));
label.lft(btex $\gamma$ etex,z[180]);

drawdblarrow ((rr,0) rotated-45){dir 45}...((rr,0) rotated 30){dir 120};
label.rt(btex $L$ etex,(rr+8pt,0) rotated -10);
endfig;

bye.

