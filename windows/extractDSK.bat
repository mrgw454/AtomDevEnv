:: batch file to extract all files from a Coco floppy disk image

:: syntax example:

:: extractDSK.bat <DSK image>

@echo off

:: if no command line parameters, only make disk image and exit
if "%~1"=="" (
    echo No valid disk image provided.
		echo.
		echo syntax example:
		echo.
		echo "extractDSK.bat <DSK image>"
	  echo.
	  exit /B
)

:: if disk image is not found
if not exist "%1" (
	echo Disk image not found.  Aborting.
	echo.
  exit /B
)


:: set up some environment variables

:: MAME's imgtool utility
SET imgtool=e:\mame\imgtool.exe

:: Toolshed's DECB utility
SET decb=C:\Program Files (x86)\toolshed-2.2\decb.exe


:: get name of batch file and place it into a variable
SET batchfilename=%~n0%~x0

:: use MAME's imgtool to extract all files from DSK image
"%imgtool%" getall coco_jvc_rsdos "%1"

:: use Toolshed's decb command to translate any BASIC files from tokenized to ASCII

:: set up a temp folder for extract

mkdir "extract"

echo Start

for %%f in (*.BAS) do (

	"%decb%" copy -0 -b -t -r "%%~f" ".\extract\%%~f"

	erase "%%~f"

)

echo End

:: move any translated BASIC files back into original folder
move /y ".\extract\*" .\

:: remove temp folder
rmdir ".\extract"

echo.
echo "Done."
echo.

exit /B
