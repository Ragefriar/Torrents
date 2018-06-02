#!/bin/sh
clear
powershell_running=`ps aux | grep -i "pwsh" | grep -v "grep" | wc -l`
if [ $powershell_running -ge 1 ]
   then
        echo "Yes, Powershell script is running"
        echo ""
   else
        echo "No, Powershell script does not appear to be running"
	echo ""
fi

