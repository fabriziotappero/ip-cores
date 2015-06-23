#!/bin/sh
#

################################################################################
####                                                                        ####
#### This file is part of the yaVGA project                                 ####
#### http://www.opencores.org/?do=project&who=yavga                         ####
####                                                                        ####
#### Description                                                            ####
#### Implementation of yaVGA IP core                                        ####
####                                                                        ####
#### To Do:                                                                 ####
####                                                                        ####
####                                                                        ####
#### Author(s):                                                             ####
#### Sandro Amato, sdroamt@netscape.net                                     ####
####                                                                        ####
################################################################################
####                                                                        ####
#### Copyright (c) 2009, Sandro Amato                                       ####
#### All rights reserved.                                                   ####
####                                                                        ####
#### Redistribution  and  use in  source  and binary forms, with or without ####
#### modification,  are  permitted  provided that  the following conditions ####
#### are met:                                                               ####
####                                                                        ####
####     * Redistributions  of  source  code  must  retain the above        ####
####       copyright   notice,  this  list  of  conditions  and  the        ####
####       following disclaimer.                                            ####
####     * Redistributions  in  binary form must reproduce the above        ####
####       copyright   notice,  this  list  of  conditions  and  the        ####
####       following  disclaimer in  the documentation and/or  other        ####
####       materials provided with the distribution.                        ####
####     * Neither  the  name  of  SANDRO AMATO nor the names of its        ####
####       contributors may be used to  endorse or  promote products        ####
####       derived from this software without specific prior written        ####
####       permission.                                                      ####
####                                                                        ####
#### THIS SOFTWARE IS PROVIDED  BY THE COPYRIGHT  HOLDERS AND  CONTRIBUTORS ####
#### "AS IS"  AND  ANY EXPRESS OR  IMPLIED  WARRANTIES, INCLUDING,  BUT NOT ####
#### LIMITED  TO, THE  IMPLIED  WARRANTIES  OF MERCHANTABILITY  AND FITNESS ####
#### FOR  A PARTICULAR  PURPOSE  ARE  DISCLAIMED. IN  NO  EVENT  SHALL  THE ####
#### COPYRIGHT  OWNER  OR CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, ####
#### INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, ####
#### BUT  NOT LIMITED  TO,  PROCUREMENT OF  SUBSTITUTE  GOODS  OR SERVICES; ####
#### LOSS  OF  USE,  DATA,  OR PROFITS;  OR  BUSINESS INTERRUPTION) HOWEVER ####
#### CAUSED  AND  ON  ANY THEORY  OF LIABILITY, WHETHER IN CONTRACT, STRICT ####
#### LIABILITY,  OR  TORT  (INCLUDING  NEGLIGENCE  OR OTHERWISE) ARISING IN ####
#### ANY  WAY OUT  OF THE  USE  OF  THIS  SOFTWARE,  EVEN IF ADVISED OF THE ####
#### POSSIBILITY OF SUCH DAMAGE.                                            ####
################################################################################

cat charmaps_ROM.vhd_head

ROW_SIZE=4
COL_NUM=0

CURR_NUM=0
INIT_NUM=0
while read LINE ; do
  case "${LINE}" in
    \#*) # skip
         ;;

      *) HEX=`echo "obase=16; ibase=2; ${LINE}" | sed -e ' s/-/0/g ' | sed -e ' s/@/1/g ' | bc`

         
#         echo ${CURR_ELEM}

         if [ ${#HEX} = 1 ] ; then
           HEX="0${HEX}"
         else
           HEX="${HEX}"
         fi

         if [ ${COL_NUM} = 0 ] ; then
           echo -en "\n    "
           COL_NUM=${ROW_SIZE}
         fi

         echo -n "${CURR_NUM} => X\"${HEX}\", "

         CURR_NUM=$((${CURR_NUM} + 1))
         COL_NUM=$((${COL_NUM} - 1))

         ;;
  esac
done < chars.map
echo -e "\n    others => X\"00\""

cat charmaps_ROM.vhd_tail
