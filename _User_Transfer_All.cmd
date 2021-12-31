REM Batch file for copying ALL user data.
REM September 16, 2021 - Version 4.0
REM Mike Patterson - mepatterson@ncdot.gov
@ECHO OFF
@setlocal enableextensions
@SET LOCAL EnableDelayedExpansion
@cd /d "%~dp0"
COLOR 9F
REM First, some error checking.
REM These three text files tell robocopy what *not* to copy
REM This would be stuff like C:\Windows, C:\Program Files, etc.
REM The script will not run unless all three are present.
CLS
IF NOT EXIST ExcludeFiles.txt (
	color 04
	cls
	ECHO Error: You're missing [ ExcludeFiles.txt ]
	ECHO ---------------------------------------------------------
	ECHO Without this, a *LOT* of unnecessary data will be copied.
	ECHO Please put ExcludeFiles.txt in the same folder as 
	ECHO this script: [ %cd% ]
	ECHO Press Enter to exit.
	set /p > Null01=""
	del Null01
	GOTO EOF
)
IF NOT EXIST ExcludeDirs.txt (
	color 04
	cls
	ECHO Error: You're missing [ ExcludeDirs.txt ]
	ECHO ---------------------------------------------------------
	ECHO Without this, a *LOT* of unnecessary data will be copied.
	ECHO Please put ExcludeDirs.txt in the same folder as
	ECHO this script: [ %cd% ]
	ECHO Press Enter to exit.
	set /p > Null01=""
	del Null01
	GOTO EOF
)
ECHO IMPORTANT: Run this from the target folder where you want
ECHO to copy the data into. The script will generate a folder
ECHO specific to the user.
ECHO ---------------------------------------------------------
ECHO IMPORTANT: This script also copies the entire C drive, but
ECHO will skip common folders that do not need to be copied, 
ECHO such as C:\Windows, C:\ProgramData, etc
ECHO ----------------------------------------------------------------
ECHO Please enter the user name for the primary user of this machine:
ECHO ----------------------------------------------------------------
set "pwd=%cd%"
set drvletter=%pwd:~0,2%

IF %drvletter%==C: (
  goto BADLOCATION
)
goto TRANSFERDATA
:BADLOCATION
color 4f
cls
@ECHO Oops! Attempted to run from C:
@ECHO ------------------------------------------------------
@ECHO We can't run a backup to the C: drive. 
@ECHO This script is meant to be ran from an external drive.
@ECHO ------------------------------------------------------
@ECHO Aborting...
PAUSE
EXIT
:SHUTDOWN
ECHO Press Enter to shut down...
set /p "NUL0L1="
shutdown /s /t 0
:NOSHUTDOWN
ECHO 
exit
:END
color 2f
cls
ECHO ----------------------------------------------------------------
ECHO Transfer Complete!
ECHO Log can be found at: "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log"
ECHO ----------------------------------------------------------------
ECHO Would you like to shut down? (Y/N)
set /P "Shutdown="
IF %Shutdown%==Y (
  goto SHUTDOWN
)
IF %Shutdown%==y (
  goto SHUTDOWN
)
goto NOSHUTDOWN
PAUSE
EXIT
:SHUTDOWN
ECHO Press Enter to shut down...
set /p "NUL0L1="
shutdown /s /t 0
:NOSHUTDOWN
exit
:TRANSFERDATA
set /P "PrimaryUserName="
set PrimaryUserName=%PrimaryUserName: =%
mkdir C:\source
ECHO ----------------------------------------------------------------
ECHO Backup will be stored in "%drvletter%\_Users\%PrimaryUserName%.%computername%"
ECHO Printer names and port/IP's will be stored in "%drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_PRINTERS.txt"
ECHO ----------------------------------------------------------------
mkdir "%drvletter%\_Users" > null
del null
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\C.Root"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\StickyNotes"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\StickyNotes.Win10"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Wallpaper"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Chrome"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Other"
SET /P XFiles=<ExcludeFiles.txt
SET /P XDirs=<ExcludeDirs.txt
echo ********************************************  >> "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log "
echo Begin Log for %date% %time% >> "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log"
echo ********************************************  >> "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log"
robocopy "C:\Users" "%drvletter%\_Users\%PrimaryUserName%.%computername%\Users" /XD %XDirs% /XF %XFiles% /XJ /E /COPY:DAT /W:2 /R:2 /MT:32 /ETA /tee /log+:"%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log"
robocopy C:\ "%drvletter%\_Users\%PrimaryUserName%.%computername%\C.Root" /XD %XDirs% /XF %XFiles% /XJ /E /COPY:DAT /W:2 /R:2 /MT:32 /ETA /tee /log+:"%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log"
wmic printer get portname,name >> "%drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_PRINTERS.txt"
ECHO ----------------------------------------------------------------
ECHO Gathering software list ...
wmic /output:C:\source\SOFTWARE.html product get name /format:hform
copy /y C:\source\SOFTWARE.html "%drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_SOFTWARE.html"
ECHO ----------------------------------------------------------------
ECHO Please review the printer list. Double-check any connected USB printers:
type "%drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_PRINTERS.txt"
ECHO ----------------------------------------------------------------
PAUSE
ECHO ----------------------------------------------------------------
findstr /C:"0x00000005" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
findstr /C:"0x00000002" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
findstr /C:"0x00000003" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
findstr /C:"0x00000006" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
findstr /C:"0x00000020" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
findstr /C:"0x00000035" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
findstr /C:"0x00000040" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
findstr /C:"0x00000070" "%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log" >> C:\source\MissedFiles.txt
cls
copy /y C:\source\MissedFiles.txt "%drvletter%\_Users\%PrimaryUserName%.%computername%"
color 2f
ECHO Gathering user list, wallpapers, and sticky notes ...
attrib -s -h "%drvletter%\_Users\%PrimaryUserName%.%computername%\C.Root"
for /f "usebackq" %%m in (`dir /b c:\users`) do (
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\StickyNotes\%%m"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\StickyNotes.Win10\%%m\"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Wallpaper\%%m"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Chrome\%%m"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\EdgeBookmarks\%%m"

copy /y "C:\Users\%%m\AppData\Roaming\Microsoft\Sticky Notes\*.*" "%drvletter%\_Users\%PrimaryUserName%.%computername%\Stickey Notes\%%m"
copy /y "C:\Users\%%m\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper" "%drvletter%\_Users\%PrimaryUserName%.%computername%\Wallpaper\%%m\TranscodedWallpaper.bmp"
copy /y "C:\Users\%%m\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "%drvletter%\_Users\%PrimaryUserName%.%computername%\Chrome\%%m\"
copy /y "C:\Users\%%m\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks" "%drvletter%\_Users\%PrimaryUserName%.%computername%\EdgeBookmarks\%%m\Bookmarks"
robocopy /e /w:1 /r:1 C:\Users\%%m\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\ %drvletter%\_Users\%PrimaryUserName%.%computername%\StickyNotes.Win10\%%m\ /log+:%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log

)
GOTO END
PAUSE
:EOF
exit




