@echo off

:: batch file to extact all files from a Coco floppy disk image

:: syntax example:

:: extractDSK.bat <DSK image>


:: get name of batch file and place it into a variable
SET batchfilename=%~n0%~x0

:: get name of current folder and place it into a variable
pushd %1 & for %%i in (.) do SET floppy=%%~ni

:: use MAME's imgtool to extract all files from DSK image
e:\mame\imgtool.exe getall coco_jvc_rsdos "%1"

:: use Toolshed's decb command to translate any BASIC files from tokenized to ASCII

:: set up a temp folder for extract

mkdir "extract"

echo Start

for %%f in (*.BAS) do (

	"C:\Program Files (x86)\toolshed-2.2\decb.exe" copy -0 -b -t -r "%%~f" ".\extract\%%~f"
	erase "%%~f"

)

echo End

:: move any translated BASIC files back into original folder
move ".\extract\*" .\

:: remove temp folder
rmdir ".\extract"

echo.
echo "Done."
echo.

exit /B
