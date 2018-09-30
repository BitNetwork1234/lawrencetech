@echo off
REM Filename: backup.bat
REM Version: W0.1
REM Description: minecraft automated backup script
REM Usage: set script, source, and backup variables
REM        place backup.bat into directory where you intend it to remain
REM        set the worlds to backup (on line 39)
REM        OPTIONAL: change the backup name formatting
REM        double click the file once... done
REM        at this point don't move the batch file or the scheduled task will not know where it is located
REM            if moved run this command: SCHTASKS /Delete /TN "Minecraft Backup" /F
REM            and run backup.bat again from its new location
REM Requirements: MS Vista or newer (XP or earlier might not have all the commands)

REM script variable to be set to the directory this batch file is located in
    set script=C:\Users\username\servers
REM source variable to be set to the lowest common directory of all minecraft world folders
    set source=C:\Users\username\servers
REM backup variable to be set to the location where backups are to be stored
    set backup=C:\Users\username\servers\backup
REM WARNING: by default folders in the backup directory are deleted after 2 days
REM spaces are okay in folder names

schtasks /query /tn "Minecraft Backup">nul
if errorlevel 1 (
REM to change backup interval modify the number after /ri
REM /ri [backup interval in minutes]
REM default is hourly backups
    schtasks /create /tn "Minecraft Backup" /ru SYSTEM /sc DAILY /ri 60 /du 24:00 /tr "%script%\backup.bat"
)

REM by default backups are deleted after 2 days
REM to change when backups are delete modify the number after /d -
REM /d -[n days to keep old backups]
forfiles /p "%backup%" /d -2 /c "cmd /c rd /q /s @path"
REM if you do not want to delete old backups add REM to the beginning of the line above

REM set the worlds between the parentheses below (location relative to source variable)
for %%a in (\yourServer1\world1 \yourServer2\world2) do (
REM separate worlds with one space
    for /f "tokens=2-4 delims=/ " %%b in ('echo %date%') do call:setdate %%d %%b %%c
    for /f "tokens=1-3 delims=:." %%e in ('echo %time%') do call:settime %%e %%f %%g
    call:copy %%a
)
goto end

:setdate
REM the line below is to change the formatting of the date (default: YYYY-MM-DD)
    set dvar=%1-%2-%3
    goto end

:settime
REM the line below is to change the formatting of the time (default: hh.mm.ss)
    if %1 LEQ 9 (set tvar=0%1.%2.%3) else set tvar=%1.%2.%3
    goto end

:copy
REM the line below is to set the rest of the backup name formatting (default: world_YYYY-MM-DD_hh.mm.ss)
    set filename=%~nx1_%dvar%_%tvar%
    if exist "%source%%1" (
        xcopy /e /h /q /g /j "%source%%1\*" "%backup%\%filename%\%~nx1\*"
    )
    if exist "%source%%1_nether" (
        xcopy /e /h /q /g /j "%source%%1_nether\*" "%backup%\%filename%\%~nx1_nether\*"
    )
    if exist "%source%%1_the_end" (
        xcopy /e /h /q /g /j "%source%%1_the_end\*" "%backup%\%filename%\%~nx1_the_end\*"
    )
    goto end

:end