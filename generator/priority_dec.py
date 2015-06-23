#!/sbin/python

# Marius TIVADAR (c) Apr, 2009

for i in range(64):
    print """if ( M_q[%(i)d] ) begin
   X_d = %(x)d;
   Y_d = %(y)d;
end
else""" % {"i":i , "x":i%8, "y":i/8}
