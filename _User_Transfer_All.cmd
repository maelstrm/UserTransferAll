@ECHO OFF
REM Batch file for copying ALL user data.
REM January 28, 2019 - Version 3.5
REM Mike Patterson
REM Basically, put this script on an external with the two Exclude*.txt files
REM and run it as an admin. The only input is the name of the user you want to back up.
REM However, the script backs up data for *ALL* users on the machine. 
REM So realistitically, you can enter any name you want in the input.
REM All data will be stored as D:\_Users\<THENAMEYOUINPUT>.%computername
REM Where D: is your external drive letter.
REM This script can not be ran from C:
REM ----------------------------------------------------------------------------------
COLOR 9F
REM First, some error checking.
REM These text files tell robocopy what *not* to copy
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
ECHO Attempted to run from C:
ECHO We can't run a backup to the
ECHO same hard drive.
ECHO   
ECHO Continuing may over-write data
ECHO on the C: drive. 
ECHO Aborting...
PAUSE
EXIT
:SHUTDOWN
ECHO Press Enter to shut down...
set /p "NUL0L1="
shutdown /s /t 0
:NOSHUTDOWN
ECHO Waiting...
set /p "NULL2="
exit
:END
color 2f
cls
ECHO ----------------------------------------------------------------
ECHO Transfer Complete!
ECHO Log file is stored at: %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log 
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
ECHO Waiting...
set /p "NULL2="
exit
:TRANSFERDATA
set /P "PrimaryUserName="
mkdir C:\source
ECHO ----------------------------------------------------------------
ECHO Backup will be stored in %drvletter%\_Users\%PrimaryUserName%.%computername%
ECHO Printer names and port/IP's will be stored in %drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_PRINTERS.txt
ECHO ----------------------------------------------------------------
mkdir %drvletter%\_Users
mkdir %drvletter%\_Users\%PrimaryUserName%.%computername%
mkdir %drvletter%\_Users\%PrimaryUserName%.%computername%\C.Root
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\sticky Notes"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Wallpaper"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Chrome"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Other"
SET /P XFiles=<ExcludeFiles.txt
SET /P XDirs=<ExcludeDirs.txt
echo ********************************************  >> %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log 
echo Begin Log for %date% %time% >> %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log 
echo ********************************************  >> %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log 
robocopy "C:\Users" %drvletter%\_Users\%PrimaryUserName%.%computername%\Users /XD %XDirs% /XF %XFiles% /XJ /E /COPY:DAT /W:2 /R:2 /MT:32 /ETA /tee /log+:%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log 
robocopy C:\ %drvletter%\_Users\%PrimaryUserName%.%computername%\C.Root /XD %XDirs% /XF %XFiles% /XJ /E /COPY:DAT /W:2 /R:2 /MT:32 /ETA /tee /log+:%drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log 
wmic printer get portname,name >> %drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_PRINTERS.txt
ECHO ----------------------------------------------------------------
REM Un-REM to gather a software list using wmic, and copy this software list to your external drive
REM ECHO Gathering software list ...
REM wmic /output:C:\source\SOFTWARE.html product get name /format:hform
REM copy /y C:\source\SOFTWARE.html %drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_SOFTWARE.html
ECHO ----------------------------------------------------------------
ECHO Please review the printer list. Double-check any connected USB printers:
type %drvletter%\_Users\%PrimaryUserName%.%computername%\%PrimaryUserName%-%computername%_PRINTERS.txt
ECHO ----------------------------------------------------------------
PAUSE
ECHO ----------------------------------------------------------------
REM "grep" for robocopy error codes in the log file. Generally, these errors mean robocopy can't access a file to back up
REM becasue of permissions issues or the file/folder simply does not exist. 
findstr /C:"0x00000005" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
findstr /C:"0x00000002" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
findstr /C:"0x00000003" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
findstr /C:"0x00000006" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
findstr /C:"0x00000020" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
findstr /C:"0x00000035" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
findstr /C:"0x00000040" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
findstr /C:"0x00000070" %drvletter%\_Users\%PrimaryUserName%.%computername%\RoboCopyLog.log >> C:\source\MissedFiles.txt
cls
color 4f
ECHO **************************************************************
ECHO *                                                            *
ECHO * Here is a list of files that were not copied because       *
ECHO * they were in use, could not be found or access was denied. *
ECHO * ---------------------------------------------------------- *
ECHO * Please review this list and manually copy anything         *
ECHO * that needs to be copied.                                   *
ECHO *                                                            *
ECHO * ---------------------------------------------------------- *
ECHO * The full list can be found on your external drive          *
ECHO * at the location:   %drvletter%\_Users                      *
ECHO * Press any key to view a list of these files                *
ECHO **************************************************************
pause >null
type C:\source\MissedFiles.txt
REM Copy the MissedFiles.txt to our external
copy /y C:\source\MissedFiles.txt %drvletter%\_Users\%PrimaryUserName%.%computername%
pause
color 2f
ECHO Gathering user list, wallpapers, and sticky notes ...
REM For some reason, the C.Root folder ends up hidden + system, so we'll remove those attrributes. This is probably because robocopy is applying parent folder permissions. 
attrib -s -h %drvletter%\_Users\%PrimaryUserName%.%computername%\C.Root
REM Loop through all of our known users and grab specific items from their AppData folders. Add/remove folders/paths as necessary
for /f "usebackq" %%m in (`dir /b c:\users`) do (
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\sticky Notes\%%m"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Wallpaper\%%m"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\Chrome\%%m"
mkdir "%drvletter%\_Users\%PrimaryUserName%.%computername%\EdgeBookmarks\%%m"
copy /y "C:\Users\%%m\AppData\Roaming\Microsoft\Sticky Notes\*.*" "%drvletter%\_Users\%PrimaryUserName%.%computername%\sticky Notes\%%m"
copy /y "C:\Users\%%m\AppData\Roaming\Microsoft\Windows\Themes\*.*" "%drvletter%\_Users\%PrimaryUserName%.%computername%\Wallpaper\%%m\"
copy /y "C:\Users\%%m\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "%drvletter%\_Users\%PrimaryUserName%.%computername%\Chrome\%%m\"
copy /y "C:\Users\%%m\AppData\Local\MicrosoftEdge\User\Default\*.*" "%drvletter%\_Users\%PrimaryUserName%.%computername%\EdgeBookmarks\%%m"
REM robocopy /e /w:1 /r:1 C:\Users\%%m\AppData\Local\SomeFolder\ %drvletter%\_Users\%PrimaryUserName%.%computername%\SomeFolder\%%m
REM robocopy /e /w:1 /r:1 C:\Users\%%m\AppData\Roaming\SomeOtherFolder\ %drvletter%\_Users\%PrimaryUserName%.%computername%\SomeOtherFolder\%%m
REM put the file extension back onto everyone's wallpaper
rename "%drvletter%\_Users\%PrimaryUserName%.%computername%\Wallpaper\%%m\TranscodedWallpaper" TranscodedWallpaper.bmp
)
GOTO END
PAUSE
:EOF
exit




