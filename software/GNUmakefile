##
# GNUmakefile
#
# Version:
#       $Id: GNUmakefile,v 1.1 2007-05-25 11:20:18 jwdonal Exp $
#
# Author:
#       Jonathon W. Donaldson
##

CXX = g++

CXXFLAGS = -Wall -Werror -O

PATCH = $(shell test `uname` = SunOS && echo gpatch || echo patch)
TAR = $(shell test `uname` = SunOS && echo gtar || echo tar)

apps = $(patsubst %.c,%,$(wildcard *.c))

all: very_small small smiley big all_rows all_cols very_big full_screen jess

jess: $(apps)
	./bmpParse jess.bmp jess_R.coe jess_G.coe jess_B.coe jess.hdr 0 2
	javac *.java
	java Gen_LCD_Image jess_R.coe jess_G.coe jess_B.coe jess.hdr &

full_screen: $(apps)
	./bmpParse full_screen.bmp full_screen_R.coe full_screen_G.coe full_screen_B.coe full_screen.hdr 0 2
	javac *.java
	java Gen_LCD_Image full_screen_R.coe full_screen_G.coe full_screen_B.coe full_screen.hdr &

very_big: $(apps)
	./bmpParse very_big.bmp very_big_R.coe very_big_G.coe very_big_B.coe very_big.hdr 0 2
	javac *.java
	java Gen_LCD_Image very_big_R.coe very_big_G.coe very_big_B.coe very_big.hdr &

all_cols: $(apps)
	./bmpParse all_cols.bmp all_cols_R.coe all_cols_G.coe all_cols_B.coe all_cols.hdr 0 2
	javac *.java
	java Gen_LCD_Image all_cols_R.coe all_cols_G.coe all_cols_B.coe all_cols.hdr &

all_rows: $(apps)
	./bmpParse all_rows.bmp all_rows_R.coe all_rows_G.coe all_rows_B.coe all_rows.hdr 0 2
	javac *.java
	java Gen_LCD_Image all_rows_R.coe all_rows_G.coe all_rows_B.coe all_rows.hdr &

big: $(apps)
	./bmpParse big.bmp big_R.coe big_G.coe big_B.coe big.hdr 0 2
	javac *.java
	java Gen_LCD_Image big_R.coe big_G.coe big_B.coe big.hdr &

smiley: $(apps)
	./bmpParse smiley.bmp smiley_R.coe smiley_G.coe smiley_B.coe smiley.hdr 0 2
	javac *.java
	java Gen_LCD_Image smiley_R.coe smiley_G.coe smiley_B.coe smiley.hdr &

small: $(apps)
	./bmpParse small.bmp small_R.coe small_G.coe small_B.coe small.hdr 0 2
	javac *.java
	java Gen_LCD_Image small_R.coe small_G.coe small_B.coe small.hdr &

very_small: $(apps)
	./bmpParse very_small.bmp very_small_R.coe very_small_G.coe very_small_B.coe very_small.hdr 0 2
	javac *.java
	java Gen_LCD_Image very_small_R.coe very_small_G.coe very_small_B.coe very_small.hdr &

%.o: %.c
	gcc $(CXXFLAGS) -c -o $@ $<
	
clean:
	rm -f *.o *.coe *.hdr

realclean: clean
	rm -f $(apps) *.class
