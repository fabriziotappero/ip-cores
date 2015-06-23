#!/bin/sh

# $Id: analyze.sh,v 1.1.1.1 2005-11-15 01:51:28 arif_endro Exp $
# -----------------------------------------------------------------------------
#  Title       : Analyze Output File
#  Project     :  
# -----------------------------------------------------------------------------
#  File        :  analyze.sh
#  Author      : "Arif E. Nugroho" <arif_endro@yahoo.com>
#  Created     : 2005/11/01
#  Last update : 
#  Simulators  :
#  Synthesizers: 
#  Target      : 
# -----------------------------------------------------------------------------
#  Description : Bourne Shell script to analyze output of simulations
# -----------------------------------------------------------------------------
#  Copyright (C) 2005 Arif E. Nugroho
###############################################################################
## 
## 	THIS SOURCE FILE MAY BE USED AND DISTRIBUTED WITHOUT RESTRICTION
## PROVIDED THAT THIS COPYRIGHT STATEMENT IS NOT REMOVED FROM THE FILE AND THAT
## ANY DERIVATIVE WORK CONTAINS THE ORIGINAL COPYRIGHT NOTICE AND THE
## ASSOCIATED DISCLAIMER.
## 
###############################################################################
## 
## 	THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
## IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
## EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
## OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
## OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
## ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
###############################################################################

SOURCE=../data/senddata.txt
TARGET=send_out.txt
echo "Changing to UNIX text file format..."
dos2unix ${TARGET}

BIT=`wc -l ${TARGET} | awk '{print $1}'`

if [ $BIT  -gt 10000 ]; then
   echo "Removing 12 first line..."
   ex -s -n -c "1,12d" -c "wq" ${TARGET}
else
   echo "File ${TARGET} already ${BIT} lines."
fi;

BIT=`wc -l ${TARGET} | awk '{print $1}'`

if [ $BIT -eq 10000 ]; then
   echo "line difference:"
   cmp -l ${SOURCE} ${TARGET} | wc -l
else
   echo "WARNING: File ${TARGET} has ${BIT} lines only."
fi
