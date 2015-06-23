###################################################
# General purpose Makefile for LaTeX-Documents    #
#                                                 #
# Based on the makefile written by Daniel Ciaglia #
# http://www.sigterm.de/misc/src/Makefile-latex   #
#                                                 #
# Modified by Tero Kangas 2005/09/05              #
###################################################


##### Variables #############
#############################

# Basename for the document (without postfix '.tex')
TARGET=hibi_datasheet

# Title & Author for pdf
#TITLE=PhD Thesis, TUT 2006
#AUTHOR=Erno Salminen

# .tex Source files
SRC= hibi_datasheet.tex \
 hibi_datasheet_ref.bib

# ATTENTION!
# File-extensions to delete recursive from here
#EXTENSION=aux toc idx ind ilg log out lof lot lol bbl blg
EXTENSION=aux toc log lof lot lol bbl blg

#############################
#############################

##### Targets ###############
#############################

all: ${TARGET}.dvi

ps: ${TARGET}.ps

pdf: ${TARGET}.pdf

ps_2on1: $(TARGET)_2on1.ps

pdf_2on1: $(TARGET)_2on1.pdf


##################################################
##################################################
# HTML (latex2html is not cygwin currently so this does not work)
html: ${SRC}
	latex ${TARGET}.tex
	bibtex ${TARGET}
	latex ${TARGET}.tex
	latex2html \
	-short_index -split 3 \
	-dir www -numbered_footnotes -no_footnode \
	-antialias -html_version 4.0 \
	-white ${TARGET}.tex

# PS
${TARGET}.ps: ${TARGET}.dvi
	dvips -o ${TARGET}.ps ${TARGET}.dvi

# PDF
#${TARGET}.pdf: ${SRC} 
#	tex2pdf --title="${TITLE}" --author="${AUTHOR}" ${TARGET}.tex
${TARGET}.pdf: ${TARGET}.ps 
#	ps2pdf -dMaxSubsetPct=100 -dCompatibilityLevel=1.3 -dSubsetFonts=true -dEmbedAllFonts=true $(TARGET).ps $(TARGET).pdf
	ps2pdf -dPDFSETTINGS=/printer $(TARGET).ps $(TARGET).pdf

# DVI
${TARGET}.dvi: ${SRC}
	echo "Running latex..."
	latex ${TARGET}.tex
	echo "Running bibtex..."
	bibtex ${TARGET}
	echo "Rerunning latex...."
	latex ${TARGET}.tex
	latex_count=5 ; \
	while egrep -s 'Rerun (LaTeX|to get cross-references right)' ${TARGET}.log && [ $$latex_count -gt 0 ] ;\
	    do \
	      echo "Rerunning latex...." ;\
	      latex ${TARGET}.tex ;\
	      latex_count=`expr $$latex_count - 1` ;\
	    done

# 2on1 PS
$(TARGET)_2on1.ps: ${TARGET}.ps
	psnup -2 ${TARGET}.ps > ${TARGET}_2on1.ps

# 2on1 PDF
$(TARGET)_2on1.pdf: $(TARGET)_2on1.ps
	ps2pdf -dMaxSubsetPct=100 -dCompatibilityLevel=1.3 -dSubsetFonts=true -dEmbedAllFonts=true ${TARGET}_2on1.ps ${TARGET}_2on1.pdf

# TAR
dist:	pdf
	tar -zcf thesis.tar.gz $(SRC) *.bib *.bst *.cls Fig/Eps/*.eps makefile $(TARGET).pdf

# Clean
clean:
	@for EXT in ${EXTENSION}; \
	do \
	find `pwd` -name \*\.$${EXT} -exec rm -v \{\} \; ;\
	done
	@rm -fv ${TARGET}.dvi
	@rm -fv ${TARGET}.pdf
	@rm -fv ${TARGET}.ps
	@rm -fv ${TARGET}_2on1.ps
	@rm -fv ${TARGET}_2on1.pdf
	@rm -rfv auto
	@rm -fv *~ 
	@rm -fv www/*\.*
