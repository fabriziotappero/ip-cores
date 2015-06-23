# Procedure for printing text.
proc Print {txt} {
}

# -------------------------------------
# Set source and destination paths.
set src             ../..
set dst             pavr
set archiveFileName pavr-release-html.zip

Print "Deleting existing release directory structure...\n"
file delete -force $dst

Print "Creating temporary release directory structure...\n"
file mkdir $dst
file copy $src/doc $dst
file copy $src/src $dst

cd $dst/doc
Print "Cleaning documentation...\n"
catch {exec clean.bat} tmpMsg
Print "Compiling documentation...\n"
catch {exec compile.bat} tmpMsg

Print "Deleting temporary sources of the documentation...\n"
catch {
   set fNames [glob ./*.*]
   foreach {fName} "$fNames" {
      file delete -force $fName
   }
}
cd ../

Print "Building release package...\n"
catch {
   set fNames [glob ./doc/html/*.*]
   foreach {fName} "$fNames" {
      file copy $fName ./
   }
}

file delete -force ./doc
file delete -force ./src

Print "Archiving...\n"
cd ../
catch {exec wzzip $archiveFileName $dst} tmpMsg

file delete -force $dst

exit
