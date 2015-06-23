# Procedure for printing text.
# It's null for now.
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
set prjPath ../../

CleanDevelStructure "$prjPath"

exit
