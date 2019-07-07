@echo off

:: batch file to create a new Coco floppy disk image and and copy all Coco related files to it.
:: It will also (optionally) run XRoar and mount the disk image (pyDriveWire or normal DECB)

:: this script can take up to 2 command line parameters:
:: Coco driver to use for XRoar (i.e. coco2 coco2b, etc.) and use pyDriveWire (yes or no)

:: syntax example:

:: makeDSK.bat coco2 y

:: this will create a new disk image and copy all Coco compatible files to a disk image
:: using name of the current folder.  In addition, it will launch XRoar using the Coco 2
:: driver for MAME (with HDBDOS) and use pyDriveWire with this disk image mounted as DRIVE 0.
:: If pyDriveWire is not running, the script will start it (net start pyDriveWire if configured as a service).


:: XRoar's location (path only)
SET xroardir=e:\xroar

:: XRoar executable (filename only)
SET xroarexe=xroar.exe

:: Toolshed's DECB utility
SET decb=C:\Program Files (x86)\toolshed-2.2\decb.exe

:: pyDriveWire location (path only)
SET pyDWlocation=e:\pyDriveWire


:: use parameter file for XRoar (if found)
for /f "delims=" %%x in (%xroardir%\.optional_xroar_parameters.txt) do set XROARPARMS=%%x


:: get name of batch file and place it into a variable

SET batchfilename=%~n0%~x0
echo batchfilename %batchfilename%

:: get name of current folder and place it into a variable

for %%a in (.) do set floppy=%%~nxa

:: get name of project folder

SET projectfolder=%cd%
echo projectfolder %projectfolder%

:: if a previous disk image exists, remove it before creating a new one

if exist "%floppy%.DSK" (

	erase "%floppy%.DSK"
	echo.
)

:: create new DSK image based on current folder name

echo Creating new floppy disk image [%floppy%.DSK]
echo.

"%decb%" dskini "%floppy%.DSK"


for %%f in (*.*) do (

rem	echo %%~nf
rem echo %%~nxf
rem echo %%~xf

rem copy all BASIC files (and convert names to UPPERCASE) to DSK image

	IF /I "%%~xf"==".BAS" (

		SETLOCAL ENABLEDELAYEDEXPANSION
		SET String=%%~nxf
		CALL :UpCase String

		echo decb copy -0 -a -t -r %%~nxf "%floppy%.DSK",!String!
		"%decb%" copy -0 -a -t -r %%~nxf "%floppy%.DSK",!String!
		CALL :functionErrorLevel

		ENDLOCAL

	)


rem copy all BIN files (and convert names to UPPERCASE) to DSK image

	IF /I "%%~xf"==".BIN" (

		SETLOCAL ENABLEDELAYEDEXPANSION
		SET String=%%~nxf
		CALL :UpCase String

		echo decb copy -2 -b -r %%~nxf "%floppy%.DSK",!String!
		"%decb%" copy -2 -b -r %%~nxf "%floppy%.DSK",!String!
		CALL :functionErrorLevel

		ENDLOCAL

	)


rem copy all TXT files (and convert names to UPPERCASE) to DSK image

	IF /I "%%~xf"==".TXT" (

		SETLOCAL ENABLEDELAYEDEXPANSION
		SET String=%%~nxf
		CALL :UpCase String

		echo decb copy -3 -a -r %%~nxf "%floppy%.DSK",!String!
		"%decb%" copy -3 -a -r %%~nxf "%floppy%.DSK",!String!
		CALL :functionErrorLevel

		ENDLOCAL

	)


rem copy all DAT files (and convert names to UPPERCASE) to DSK image

	IF /I "%%~xf"==".DAT" (

		SETLOCAL ENABLEDELAYEDEXPANSION
		SET String=%%~nxf
		CALL :UpCase String

		echo decb copy -1 -a -r %%~nxf "%floppy%.DSK",!String!
		"%decb%" copy -1 -a -r %%~nxf "%floppy%.DSK",!String!
		CALL :functionErrorLevel

		ENDLOCAL

	)


rem copy all ROM files (and convert names to UPPERCASE) to DSK image

	IF /I "%%~xf"==".ROM" (

		SETLOCAL ENABLEDELAYEDEXPANSION
		SET String=%%~nxf
		CALL :UpCase String

		echo decb copy -2 -b -r %%~nxf "%floppy%.DSK",!String!
		"%decb%" copy -1 -a -r %%~nxf "%floppy%.DSK",!String!
		CALL :functionErrorLevel

		ENDLOCAL

	)


)


echo.
echo.

:: list disk image contents

"%decb%" dir "%floppy%.DSK"

echo.


:: copy to /media/share1/DW4 so the disk image can be sync'd to other DriveWire servers

echo Copying file to [e:\media\share1\DW4\%floppy%\%floppy%.DSK] so it can be sync'd to other DriveWire servers...
echo.

mkdir "e:\media\share1\DW4\%floppy%"
copy "%floppy%.DSK" "e:\media\share1\DW4\%floppy%"

echo.
echo.

:: if no command line parameters, only make disk image and exit

if "%~1"=="" (

    echo Only made disk image as no command line parameters supplied.

	echo.
	echo Done.
	echo.

	exit /B

)

:: (optional) load XRoar and mount disk image in pyDrivewire INSTANCE 0 as DRIVE 0

if /I "%2" == "Y" (

	rem make sure HDBDOS is used for pyDriveWire access

	rem Coco 2 section

	if %1 == coco2 (

		cd "%pyDWlocation%"

			:: eject disk from pyDriveWire
		pypy ./pyDwCli.py http://localhost:6800 dw disk eject 0
		echo -e

		:: insert disk for pyDriveWire
		pypy ./pyDwCli.py http://localhost:6800 dw disk insert 0 %cd%\%floppy%.DSK
		echo -e

		:: show (confirm) disk mounted in pyDriveWire
		pypy ./pyDwCli.py http://localhost:6800 dw disk show 0
		echo -e

		rem change to XRoar folder
		cd "%xroardir%"

		"%xroardir%\%xroarexe%" -c xroar.conf -default-machine coco2bus -machine-cart hdbdos %XROARPARMS%

    cd "%pyDWlocation%"

		:: eject disk from pyDriveWire
		pypy ./pyDwCli.py http://localhost:6800 dw disk eject 0

		rem change back to project folder
		cd "%projectfolder%"

		echo.
		rem set /p=Press [ENTER] to continue...

		exit /B

	)


	echo.
	echo Not a valid Coco based driver for pyDriveWire.  Exiting.
	echo.

	exit /B

) else (


	rem (optional) load XRoar and mount the disk image as DRIVE 0

	rem change to XRoar folder
	cd "%xroardir%"

	"%xroardir%\xroarexe%" -c xroar.conf -default-machine coco2bus -load "%cd%\%floppy%.DSK" %XROARPARMS%
	
	rem change back to project folder
	cd "%projectfolder%"

	echo.
	echo Done.
	echo.

	exit /B

)

	echo.
	echo Done.
	echo.

exit /B


:UpCase
:: Subroutine to convert a variable VALUE to all upper case.
:: The argument for this subroutine is the variable NAME.
SET %~1=!%1:a=A!
SET %~1=!%1:b=B!
SET %~1=!%1:c=C!
SET %~1=!%1:d=D!
SET %~1=!%1:e=E!
SET %~1=!%1:f=F!
SET %~1=!%1:g=G!
SET %~1=!%1:h=H!
SET %~1=!%1:i=I!
SET %~1=!%1:j=J!
SET %~1=!%1:k=K!
SET %~1=!%1:l=L!
SET %~1=!%1:m=M!
SET %~1=!%1:n=N!
SET %~1=!%1:o=O!
SET %~1=!%1:p=P!
SET %~1=!%1:q=Q!
SET %~1=!%1:r=R!
SET %~1=!%1:s=S!
SET %~1=!%1:t=T!
SET %~1=!%1:u=U!
SET %~1=!%1:v=V!
SET %~1=!%1:w=W!
SET %~1=!%1:x=X!
SET %~1=!%1:y=Y!
SET %~1=!%1:z=Z!
GOTO:EOF


rem Define function for displaying error codes from Toolshed's 'decb' command
:functionErrorLevel

if %errorlevel%==0 (

	echo Successfully copied file to DSK image.
	echo.

) else (

	echo Error during copy process to DSK image.
	echo.
	set /p=Press [ENTER] to continue...
	echo.
	echo.

)
