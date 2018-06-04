#!/bin/sh
powershell_running=`ps aux | grep -i "pwsh" | grep -v "grep" | wc -l`
if [ $powershell_running -ge 1 ]
   then
        echo "Already processing downloads."
   else
        powershell -file /Volumes/Data/Downloads/scripts/move_tagged_files.ps1
        powershell_still_running=`ps aux | grep -i "pwsh" | grep -v "grep" | wc -l`
	while [ $powershell_still_running -ge 1 ]; do
		sleep 30
		powershell_still_running=`ps aux | grep -i "pwsh" | grep -v "grep" | wc -l`
	done
        /usr/bin/pwsh -file /Volumes/Data/Downloads/scripts/move_movies.ps1
fi

