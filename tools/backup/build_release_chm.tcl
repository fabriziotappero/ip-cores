# Procedure for printing text.
proc Print {txt} {
}

# -------------------------------------
# Set source and destination paths.
set src             ../..
set dst             pavr
set archiveFileName pavr-release-chm.zip

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

file copy -force ./chm/pavr.chm ../../pavr.chm
cd ../../

Print "Archiving...\n"
catch {exec wzzip $archiveFileName pavr.chm} tmpMsg

file delete -force $dst
file delete -force pavr.chm

exit
