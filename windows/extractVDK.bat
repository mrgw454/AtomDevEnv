rem @echo off

:: batch file to extact all files from a Dragon floppy disk image

:: syntax examplc:

:: extractVDK.bat <VDK image>

:: use DragonTool's DragonDos to extract all files from VDK image

echo Start

for /f "tokens=* delims=" %%a in ('dir "*.VDK" /s /b') do (

	"c:\Program Files (x86)\DragonTools\DragonDos.exe" dir "%%a" > "%%a.dir"

)

exit /b





for %%f in (*.VDK) do (

	"c:\Program Files (x86)\DragonTools\DragonDos.exe" dir "%1" > "%1.txt"

)

echo End

exit /B

