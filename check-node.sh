#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------- 
# - Hi! Feel free to view this open source batch file. There is no harm here.	DO NOT MODIFY!				- 
# - This batch file checks  your balance file and compares every 12 minutes on changes 				- 
# - If you ran in to any problems please use the command /help in the bot. Still have questions or			- 
# - Suggestions? Open this telegram channel: https://t.me/+fXzI53axtsI0NGE0                                             - 
# - 											Greetings Primera (NL)		- 
# ----------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------- 

# Server variables
# Matched with server DO NOT CHANGE!
version=0.10
waittime=12
looptime=$(expr $waittime \* 60 / 3)
taskloop=10
os=Linux

echo -e "Starting $os ETCMCNODE monitoring bot - version: $version \n"
echo -e "ETCPOW Donations are welcome to keep this bot running :)"
echo -e "0x1c1193B3B19d997676abC43D1Bd0f7dA514aFAA0 \n"
echo -e "Do you want to stay up-to-date or do you have questions about this bot?"
echo -e "Join the telegram group by using the /help_telegramgroup command. \n"
echo -e "Checking internal files and connection to server.."

# Setting working directories
MONNODEDIR=/app/Etcmcnodecheck
cd ..
GETHFOLDER=/app/ETCMC

if [ ! -f "$MONNODEDIR/local/debug-etcmcmon.txt" ]; then echo -e "Detected new installation, welcome to the ETCMC monitoring bot! \n" ; fi

#- Starting Debug file
timestamp=$(date "+%F %T") 
echo -e "$timestamp - Started monitoring" > "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "Monitoring bot directory: $MONNODEDIR" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "Geth directory: $GETHFOLDER" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "\n" >> "$MONNODEDIR/local/debug-etcmcmon.txt"

#- Checking if config files exist
if [ ! -f "$MONNODEDIR/etcmcnodemonitoringid.txt" ]
then 
echo -e "ERROR: Could not find etcmcnodemonitoringid.txt"
echo -e "ERROR: Could not find etcmcnodemonitoringid.txt" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
exit 1
fi

# Check if CURL installed
which curl &> /dev/null || echo -e "Error: Curl not installed - installing"
which curl &> /dev/null || sudo apt install curl
echo -e "\nCURL version information " >> "$MONNODEDIR/local/debug-etcmcmon.txt"
curl -V >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "" >> "$MONNODEDIR/local/debug-etcmcmon.txt"

# Check the connection to the server..
timestamp=$(date "+%F %T") 
servercheck=$(curl -s https://etcmcnodecheck.apritec.dev/node-servercheck.php)
if [ $servercheck = "connected" ]
then 
echo -e "Server connected" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
serverconnected="1"
else
echo -e "$timestamp - ERROR: Could not connect to the server (1/3)- retrying connection"
serverconnected="0"
sleep 60
fi

if [ $serverconnected = "0" ]
then
timestamp=$(date "+%F %T") 
servercheck=$(curl -s https://etcmcnodecheck.apritec.dev/node-servercheck.php)
if [ $servercheck = "connected" ]
then 
echo -e "$timestamp - Server connected after retry" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "$timestamp - Server connected after retry" 
serverconnected="1"
else
echo -e "$timestamp - ERROR: Could not connect to the server (2/3)- retrying connection"
serverconnected="0"
sleep 60
fi
fi

if [ $serverconnected = "0" ]
then
timestamp=$(date "+%F %T") 
servercheck=$(curl -s https://etcmcnodecheck.apritec.dev/node-servercheck.php)
if [ $servercheck = "connected" ]
then 
echo -e "$timestamp - Server connected after 2nd retry" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "$timestamp - Server connected after 2nd retry" 
serverconnected="1"
else
echo -e "$timestamp - Could not connect to the server" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "$timestamp - ERROR: Could not connect to the server (3/3)- please check your connection."
serverconnected="0"
exit 1
fi
fi

# Checking if balance file exist. If not then wait until is generated for the first time
until [ -f "$GETHFOLDER/write_only_etcpow_balance.txt" ]
do
date=$(date +%Y-%m-%d)
time=$(date +%H:%M:%S)
echo -e "$date $time - Could not connect find balance file. Waiting for balance increase.." 
sleep 300
done
echo -e "Balance file is found" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
 
# Start checking node registration with the bot.
echo -e "Checking monitoring and registration ID.."
Monitoringid=$(cat "$MONNODEDIR/etcmcnodemonitoringid.txt")
if [ "$Monitoringid" = "replacewithmonitoringid" ] 
then
echo -e "Monitoring id is replacewithmonitoringid" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "ERROR! You have not replaced you monitoring ID in the etcmcnodemonitoringid.txt file."
echo -e "Please replace and rerun this script. Need assistance? Go to telegram: Use /help in the bot."
exit 1
fi
echo -e "MONITORING ID FILE: $Monitoringid" >> "$MONNODEDIR/local/debug-etcmcmon.txt"

Registrationid=$(curl -s https://etcmcnodecheck.apritec.dev/node-regid.php?regid="$Monitoringid")
echo -e "Registered regid: $Registrationid" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
Nodename=$(curl -s https://etcmcnodecheck.apritec.dev/node-nodename.php?regid="$Monitoringid") 
echo -e "Registered Nodename: $Nodename" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "Monitoring id: $Monitoringid"
echo -e "Nodename: $Nodename"
if [ "$Registrationid" = "" ] 
then
echo ERROR! Your registration is incorrect. Did you used the correct monitoring ID? 
echo For assisance go to the bot and use /help_regerror
exit 1
fi
echo -e "MONITORING ID: $Monitoringid" >> "$MONNODEDIR/local/debug-etcmcmon.txt"

# Checking for update
if [ -f "$MONNODEDIR/local/updatesuccesfull.txt" ]
then  
echo -e "Your etcmcnodeclient has been succesfully updated to version $version"
echo -e "Update succesfull" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
rm "$MONNODEDIR/local/updatesuccesfull.txt"
autoupdatefailed="0"
curl -s "https://etcmcnodecheck.apritec.dev/version-updated.php?monid=$Monitoringid&regid=$Registrationid&version=$version&succes=1"
else
autoupdatefailed="0"
fi

if [ -f "$MONNODEDIR/local/updatefailed.txt" ]
then
echo -e "There was an error updating your etcmcnodecheck. Current version: $version"
echo -e "Update NOT succesfull" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "Please manually update by using /install at the nodecheck bot."
rm "$MONNODEDIR/local/updatefailed.txt"
autoupdatefailed="1"
curl -s "https://etcmcnodecheck.apritec.dev/version-updated.php?monid=$Monitoringid&regid=$Registrationid&version=$version&succes=0"
fi

latestversion=$(curl -s "https://etcmcnodecheck.apritec.dev/version-linux.php?monid=$Monitoringid&regid=$Registrationid&version=$version")
echo -e "Installed version: $version - server version: $latestversion" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
if [ ! "$latestversion" = "$version" ]
then 
echo -e "There is a new version! New version: $latestversion - your version: $version"
echo -e "The script will automatically try to update when the update task has due. Please wait a while."
echo -e "Startup update check - found new version " >> "$MONNODEDIR/local/debug-etcmcmon.txt"
fi

echo -e "\nPlease note: stopping this script will result an error."
echo -e "Change of state (OK/ERROR) can be delayed by 35 minutes.\n"

timestamp=$(date "+%F %T") 
echo -e "$timestamp - Monitoring started with polling time $waittime minutes - looptime $looptime - taskloop $taskloop - os $os" >> "$MONNODEDIR/local/debug-etcmcmon.txt"

# All checks are OK. Waking up the bot.
timestamp=$(date "+%F %T")
echo -e "$timestamp - Monitoring started!"
echo -e "$timestamp - Waking up the bot and saying hello to the bot developer"
curl -s "https://etcmcnodecheck.apritec.dev/node-start.php?monid=$Monitoringid&$Registrationid&wt=$waittime&task=$taskloop&os=$os" >> "$MONNODEDIR/local/debug-etcmcmon.txt"

# Starting first wait time
timestamp=$(date "+%F %T")
echo -e "$timestamp - Waiting $waittime minutes for balance change"

# START MONITORING LOOP
# DO NOT MODIFY!!
checkcount="0"
while true
do
checkcount=$(expr $checkcount + 1)
balanceold=$(cat "$GETHFOLDER/write_only_etcpow_balance.txt")
sleep $waittime'm'
balance=$(cat "$GETHFOLDER/write_only_etcpow_balance.txt")
if [ "$balance" = "$balanceold" ]
then
# BALANCE ERROR
timestamp=$(date "+%F %T") 
balanceupload=$(echo $balance | rev | cut -c10- | rev)
echo -e "$timestamp - ERROR - Your balance has not been changed!"
curl -s "https://etcmcnodecheck.apritec.dev/node-ping.php?monid=$Monitoringid&regid=$Registrationid&check=0&balance=$balanceupload"
curloutputcode=$?
if [ ! "$curloutputcode" -eq 0 ]
then
timestamp=$(date "+%F %T") 
echo -e "$timestamp - Warning: could not upload data to server (code: $curloutputcode), retrying in 5 min.."
echo -e "$timestamp - Could not upload balance $balanceupload to server - code $curloutputcode " >> "$MONNODEDIR/local/debug-etcmcmon.txt"
sleep 5m
timestamp=$(date "+%F %T") 
curl -s "https://etcmcnodecheck.apritec.dev/node-ping.php?monid=$Monitoringid&regid=$Registrationid&check=0&balance=$balanceupload"
curloutputcode=$?
if [ "$curloutputcode" -eq 0 ]
then echo -e "$timestamp - Retry succeeded. Waiting $waittime minutes for balance change.." 
else
echo -e "$timestamp - ERROR: Could not connect to bot server (code: $curloutputcode) please check your connection"
echo -e "$timestamp - Could not upload balance $balanceupload to server after retry - code $curloutputcode " >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "$timestamp - Waiting $waittime minutes for balance change.."
fi
fi

else
# BALANCE SUCCEED
timestamp=$(date "+%F %T") 
balanceupload=$(echo $balance | rev | cut -c10- | rev)
echo -e "$timestamp - Balance changed! Balance: $balanceupload"
curl -s "https://etcmcnodecheck.apritec.dev/node-ping.php?monid=$Monitoringid&regid=$Registrationid&check=1&balance=$balanceupload"
curloutputcode=$?
if [ ! "$curloutputcode" -eq 0 ]
then
timestamp=$(date "+%F %T") 
echo -e "$timestamp - Warning: could not upload data to server (code: $curloutputcode), retrying in 5 min.."
echo -e "$timestamp - Could not upload balance $balanceupload to server - code $curloutputcode " >> "$MONNODEDIR/local/debug-etcmcmon.txt"
sleep 5m
timestamp=$(date "+%F %T") 
curl -s "https://etcmcnodecheck.apritec.dev/node-ping.php?monid=$Monitoringid&regid=$Registrationid&check=1&balance=$balanceupload"
curloutputcode=$?
if [ "$curloutputcode" -eq 0 ]
then echo -e "$timestamp - Retry succeeded. Waiting $waittime minutes for balance change.." 
else
echo -e "$timestamp - ERROR: Could not connect to bot server (code: $curloutputcode) please check your connection"
echo -e "$timestamp - Could not upload balance $balanceupload to server after retry - code $curloutputcode " >> "$MONNODEDIR/local/debug-etcmcmon.txt"
echo -e "$timestamp - Waiting $waittime minutes for balance change.."
fi
fi
fi
# UPDATE LOOP
if [ "$checkcount" = "$taskloop" ] && [ "$autoupdatefailed" = "0" ]
then
timestamp=$(date "+%F %T") 
echo -e "$timestamp - Checking update.."
latestversion=$(curl -s "https://etcmcnodecheck.apritec.dev/version-linux.php?monid=$Monitoringid&regid=$Registrationid&version=$version")
if [ "$version" = "$latestversion" ]
then
echo -e "$timestamp - Your nodecheck version $version is up-to-date"
else
echo -e "$timestamp - Your nodecheck version $version outdated, new version is $latestversion. Downloading update"
echo -e "$timestamp - Update found! Current version: $version - new version:$latestversion" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
latestupdatefile=$(curl -s "https://etcmcnodecheck.apritec.dev/version-updatefile-linux.php")
curl -s "$latestupdatefile" --output "$MONNODEDIR/update/latestupdate.tar"
curloutputcode=$?
if [ "$curloutputcode" = "0" ]
then
timestamp=$(date "+%F %T") 
echo -e "$timestamp - New version has been succesfully downloaded. Starting update"
echo -e "$timestamp - File: $latestupdatefile has been downloaded. Starting update." >> "$MONNODEDIR/local/debug-etcmcmon.txt"
cd "$MONNODEDIR"
cd update
./node-update.sh "$MONNODEDIR" "$Monitoringid" "$GETHFOLDER"
exit 0
else
echo -e "$timestamp - Could not download new version. Please install manually."
echo -e "$timestamp - File: $latestupdatefile has NOT been downloaded. Curl code: $curloutputcode" >> "$MONNODEDIR/local/debug-etcmcmon.txt"
autoupdatefailed="1"
fi
fi
checkcount="0"
fi
done

# End of script. Normally you should not see this. Thx for viewing the source! Suggestions? Let me know!
echo -e "Script abnormally ended"
exit 1
