# ipmi_fan_script
Script for controlling server fans based on CPU/GPU temperature readings. Currently, only Linux is supported. 

The $GPUTEMP var is determined from querying the nvidia-smi cli tool, then using the invert grep function to clip off excess data. 

The $CPUTEMP var is determined by using ipmitool to query the local iDRAC/IPMI interface for the current CPU temp, then using various tools to clip the excess data

## Requirements
Install ipmitool
`apt-get install ipmitool -y`

Install nvidia-smi
`apt-get install nvidia-smi -y`


## Setup
1. Clone the repository
   `git clone https://github.com/ShiningLava/ipmi_fan_script.git`

Within `fanscript.sh`:
1. Edit the thresholds for CPU and GPU temperatures to set your own temperature curve.
2. Find the IPMI fan identifiers for your fans so that you can target specific fans with the script. I will include guidance for this in the future.
3. Change the script to include your fan's identifiers.
4. Save and Close the script
5. Make the script executable: `chmod +x fanscript.sh`

Create a cron job to run this script automatically at whatever time interval you desire. Recommended to run this script at least twice per minute. 
1. `cronjob -e`
2. Append the following:
```
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

# Need these to run on 30-sec boundaries, keep commands in sync.
# Change ./fanscript.sh to the location of the script. Probably ~/ipmi_fan_script/fanscript.sh
* * * * * ./fanscript.sh
* * * * * sleep 15; ./fanscript.sh
* * * * * sleep 30; ./fanscript.sh
* * * * * sleep 45; ./fanscript.sh

# The below command will erase the fanscript.sh.log file at midnight at the start of each month
# This is an easy way to prevent the file from growing indefinitely
0 0 1 * * rm fanscript.sh.log
```
3. Save and Close

Fan script should now be running at your desired time interval. To monitor the script, enter the following command:
`tail -f ~/ipmi_fan_script/fanscript.sh.log`
