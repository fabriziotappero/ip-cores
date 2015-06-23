# Procedure for printing text.
proc Print {txt} {
}

# Procedure for cleaning up the devel structure.
# Dive into devel subdirectories and execute any file named `clean.bat'.
proc CleanDevelStructure {crtDir} {
   if {[catch {set cleanFilesList [glob -directory $crtDir clean.bat]} tmpMsg]} {
   } else {
      foreach {cleanFile} $cleanFilesList {
         Print "Cleaning $crtDir ...\n"
         set initialDir "[pwd]"
         cd "$crtDir"
         catch {exec clean.bat} tmpMsg
         cd "$initialDir"
         if [string equal $tmpMsg ""] {
            Print "$tmpMsg \n"
         }
      }
   }
   if {[catch {set dirsList [glob -directory $crtDir -type d *]} tmpMsg]} {
   } else {
      foreach {dirToSearchIn} $dirsList {
         CleanDevelStructure "$dirToSearchIn"
      }
   }
}

# -------------------------------------
# Set source and destination paths.
set src             ../..
set dst             pavr
set archiveFileName pavr-devel

# Delete existent devel directory structure.
Print "Deleting existing devel directory structure ...\n"
file delete -force $dst

# Copy existent structure to devel structure.
Print "Creating devel directory structure ...\n"
file mkdir $dst

file copy  $src/doc $dst
file copy  $src/src $dst
file copy  $src/test $dst

file mkdir $dst/tools/

file copy  $src/tools/build_vhdl_hdr  $dst/tools
file copy  $src/tools/build_vhdl_test $dst/tools
file copy  $src/tools/common          $dst/tools

file mkdir $dst/tools/backup
file copy $src/tools/backup/build_devel.tcl        $dst/tools/backup
file copy $src/tools/backup/build_release_chm.tcl  $dst/tools/backup
file copy $src/tools/backup/build_release_html.tcl $dst/tools/backup

CleanDevelStructure "$dst"

Print "Archiving...\n"
catch {exec wzzip -rP -ybc $archiveFileName $dst} tmpMsg

Print "Deleting temporary devel directory structure...\n"
file delete -force $dst

exit
