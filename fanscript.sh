#!/bin/bash
## The $GPUTEMP var is determined from querying the nvidia-smi cli tool, then using the invert grep function to clip off excess data
## Visit the following page for more information on nvidia-smi queries: https://nvidia.custhelp.com/app/answers/detail/a_id/3751/~/useful-nvidia-smi-queries
GPUTEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv | grep -v "temperature.gpu")
## The below thresholds are for my system and will need to be adjusted for your system and situation
GPUTEMPTHRESHOLD1="41"
GPUTEMPTHRESHOLD2="48"
GPUTEMPTHRESHOLD3="54"
GPUTEMPTHRESHOLD4="60"
GPUTEMPTHRESHOLD5="70"
GPUTEMPTHRESHOLD6="75"
GPUTEMPTHRESHOLD7="79"
GPUTEMPTHRESHOLD8="81"
GPUTEMPTHRESHOLD9="85"

## The $CPUTEMP var is determined by using the ipmitool to query the local iDRAC/ipmi interface for the current cpu temp, then using various tools to clip the excess data
CPUTEMP=$(ipmitool sdr type temperature | grep "Temp" | grep -v "Inlet Temp" | cut -d"|" -f5 | cut -d" " -f2)
## The below thresholds are for my system and will need to be adjusted for your system and situation
CPUTEMPTHRESHOLD1="35"
CPUTEMPTHRESHOLD2="44"
CPUTEMPTHRESHOLD3="57"
CPUTEMPTHRESHOLD4="68"
CPUTEMPTHRESHOLD5="75"
CPUTEMPTHRESHOLD6="82"
CPUTEMPTHRESHOLD7="87"
CPUTEMPTHRESHOLD8="91"
CPUTEMPTHRESHOLD9="94"

## Place the desired path to the simple log file below
LOGDIR="fanscript.sh.log"

DATE=$(date +%m-%d-%H:%M:%S)

## Use IPMI to set fan control to manual with 0x00 identifyer
## This is necessary for the next commands to stick and not be overwritten by automatic PWM control
ipmitool raw 0x30 0x30 0x01 0x00

## Create log file
touch $LOGDIR

echo "$DATE GPU Temp = $GPUTEMP C" >> $LOGDIR
echo "$DATE CPU Temp = $CPUTEMP C" >> $LOGDIR

# GPU Threshold 0<=1
if (( $GPUTEMP<=$GPUTEMPTHRESHOLD1 && $GPUTEMP>0 ))
then
  echo "$DATE GPU floor, setting fan 1 speed to 15% (min)" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 15% fan speed (0x0F)
  ipmitool raw 0x30 0x30 0x02 0x00 0x0F

# GPU Threshold 1<=2
elif (( $GPUTEMP<=$GPUTEMPTHRESHOLD2 && $GPUTEMP>$GPUTEMPTHRESHOLD1 ))
then
  echo "$DATE GPU temp very low, setting fan 1 speed to 20%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 20% fan speed (0x14)
  ipmitool raw 0x30 0x30 0x02 0x00 0x14

# GPU Threshold 2<=3
elif (( $GPUTEMP <= $GPUTEMPTHRESHOLD3 )) && (( $GPUTEMP > $GPUTEMPTHRESHOLD2 ))
then
  echo "$DATE GPU temp low, setting fan 1 speed to 30%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 30% fan speed (0x1E)
  ipmitool raw 0x30 0x30 0x02 0x00 0x1E

# GPU Threshold 3<=4
elif (( $GPUTEMP <= $GPUTEMPTHRESHOLD4 )) && (( $GPUTEMP > $GPUTEMPTHRESHOLD3 ))
then
  echo "$DATE GPU temp mid, setting fan 1 speed to 40%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 40% fan speed (0x28)
  ipmitool raw 0x30 0x30 0x02 0x00 0x28

# GPU Threshold 4<=5
elif (( $GPUTEMP <= $GPUTEMPTHRESHOLD5 )) && (( $GPUTEMP > $GPUTEMPTHRESHOLD4 ))
then
  echo "$DATE GPU temp mid-high, setting fan 1 speed to 50%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 50% fan speed (0x32)
  ipmitool raw 0x30 0x30 0x02 0x00 0x32

# GPU Threshold 5<=6
elif (( $GPUTEMP <= $GPUTEMPTHRESHOLD6 )) && (( $GPUTEMP > $GPUTEMPTHRESHOLD5 ))
then
  echo "$DATE GPU temp high, setting fan 1 speed to 60%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 60% fan speed (0x3C)
  ipmitool raw 0x30 0x30 0x02 0x00 0x3C

# GPU Threshold 6<=7
elif (( $GPUTEMP <= $GPUTEMPTHRESHOLD7 )) && (( $GPUTEMP > $GPUTEMPTHRESHOLD6 ))
then
  echo "$DATE GPU temp very high, setting fan 1 speed to 70%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 70% fan speed (0x46)
  ipmitool raw 0x30 0x30 0x02 0x00 0x46

# GPU Threshold 7<=8
elif (( $GPUTEMP <= $GPUTEMPTHRESHOLD8 )) && (( $GPUTEMP > $GPUTEMPTHRESHOLD7 ))
then
  echo "$DATE GPU temp extremely high, setting fan 1 speed to 80%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 80% fan speed (0x50)
  ipmitool raw 0x30 0x30 0x02 0x00 0x50

# GPU Threshold 8<=9
elif (( $GPUTEMP <= $GPUTEMPTHRESHOLD9 )) && (( $GPUTEMP > $GPUTEMPTHRESHOLD8 ))
then
  echo "$DATE GPU temp nearly critical, setting fan 1 speed to 90%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 90% fan speed (0x5A)
  ipmitool raw 0x30 0x30 0x02 0x00 0x5A

# CAP GPU Threshold >9
elif (( $GPUTEMP > $GPUTEMPTHRESHOLD9 ))
then
  echo "$DATE GPU temp critical, setting fan 1 speed to 100%" >> $LOGDIR
## Target individual fans, specifically fan 1 (0x00) and set to 100% fan speed (0x64)
  ipmitool raw 0x30 0x30 0x02 0x00 0x64

else
  echo "$DATE GPU temp out of expected range" >> $LOGDIR
fi

# CPU Threshold 0<=1
if (( $CPUTEMP<=$CPUTEMPTHRESHOLD1 && $CPUTEMP>0 ))
then
  echo "$DATE CPU temp floor, setting fans 2, 3, and 4 speeds to 15% (min)" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 15% (0x0F)
  ipmitool raw 0x30 0x30 0x02 0x02 0x0F && ipmitool raw 0x30 0x30 0x02 0x03 0x0F && ipmitool raw 0x30 0x30 0x02 0x01 0x0F

# CPU Threshold 1<=2
elif (( $CPUTEMP<=$CPUTEMPTHRESHOLD2 && $CPUTEMP>$CPUTEMPTHRESHOLD1 ))
then
  echo "$DATE CPU temp very low, setting fans 2, 3, and 4 speeds to 20%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 20% (0x14)
  ipmitool raw 0x30 0x30 0x02 0x02 0x14 && ipmitool raw 0x30 0x30 0x02 0x03 0x14 && ipmitool raw 0x30 0x30 0x02 0x01 0x14

# CPU Threshold 2<=3
elif (( $CPUTEMP <= $CPUTEMPTHRESHOLD3 )) && (( $CPUTEMP > $CPUTEMPTHRESHOLD2 ))
then
  echo "$DATE CPU temp low, setting fans 2, 3, and 4 speeds to 30%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 20% (0x14)
  ipmitool raw 0x30 0x30 0x02 0x02 0x1E && ipmitool raw 0x30 0x30 0x02 0x03 0x1E && ipmitool raw 0x30 0x30 0x02 0x01 0x1E

# CPU Threshold 3<=4
elif (( $CPUTEMP <= $CPUTEMPTHRESHOLD4 )) && (( $CPUTEMP > $CPUTEMPTHRESHOLD3 ))
then
  echo "$DATE CPU temp mid, setting fans 2, 3, and 4 speeds to 40%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 40% (0x28)
  ipmitool raw 0x30 0x30 0x02 0x02 0x28 && ipmitool raw 0x30 0x30 0x02 0x03 0x28 && ipmitool raw 0x30 0x30 0x02 0x01 0x28

# CPU Threshold 4<=5
elif (( $CPUTEMP <= $CPUTEMPTHRESHOLD5 )) && (( $CPUTEMP > $CPUTEMPTHRESHOLD4 ))
then
  echo "$DATE CPU temp mid-high, setting fans 2, 3, and 4 speeds to 50%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 50% (0x32)
  ipmitool raw 0x30 0x30 0x02 0x02 0x32 && ipmitool raw 0x30 0x30 0x02 0x03 0x32 && ipmitool raw 0x30 0x30 0x02 0x01 0x32

# CPU Threshold 5<=6
elif (( $CPUTEMP <= $CPUTEMPTHRESHOLD6 )) && (( $CPUTEMP > $CPUTEMPTHRESHOLD5 ))
then
  echo "$DATE CPU temp high, setting fans 2, 3, and 4 speeds to 60%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 60% (0x3C)
  ipmitool raw 0x30 0x30 0x02 0x02 0x3C && ipmitool raw 0x30 0x30 0x02 0x03 0x3C && ipmitool raw 0x30 0x30 0x02 0x01 0x3C

# CPU Threshold 6<=7
elif (( $CPUTEMP <= $CPUTEMPTHRESHOLD7 )) && (( $CPUTEMP > $CPUTEMPTHRESHOLD6 ))
then
  echo "$DATE CPU temp very high, setting fans 2, 3, and 4 speeds to 70%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 80% (0x46)
  ipmitool raw 0x30 0x30 0x02 0x02 0x46 && ipmitool raw 0x30 0x30 0x02 0x03 0x46 && ipmitool raw 0x30 0x30 0x02 0x01 0x46

# CPU Threshold 7<=8
elif (( $CPUTEMP <= $CPUTEMPTHRESHOLD8 )) && (( $CPUTEMP > $CPUTEMPTHRESHOLD7 ))
then
  echo "$DATE CPU temp extremely high, setting fans 2, 3, and 4 speeds to 80%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 80% (0x50)
  ipmitool raw 0x30 0x30 0x02 0x02 0x50 && ipmitool raw 0x30 0x30 0x02 0x03 0x50 && ipmitool raw 0x30 0x30 0x02 0x01 0x50

# CPU Threshold 8<=9
elif (( $CPUTEMP<=$CPUTEMPTHRESHOLD9 && $CPUTEMP>$CPUTEMPTHRESHOLD8 ))
then
  echo "$DATE CPU temp nearly critical, setting fans 2, 3, and 4 speeds to 90%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 90% (0x5A)
  ipmitool raw 0x30 0x30 0x02 0x02 0x5A && ipmitool raw 0x30 0x30 0x02 0x03 0x5A && ipmitool raw 0x30 0x30 0x02 0x01 0x5A

# CAP CPU Threshold >9
elif (( $CPUTEMP > $CPUTEMPTHRESHOLD9 ))
then
  echo "$DATE CPU temp critical, setting fans 2, 3, and 4 speeds to 100%" >> $LOGDIR
## Set fans 2 (0x01) 3 (0x02) and 4 (0x03) to 100% (0x64)
  ipmitool raw 0x30 0x30 0x02 0x02 0x64 && ipmitool raw 0x30 0x30 0x02 0x03 0x64 && ipmitool raw 0x30 0x30 0x02 0x01 0x64

else
  echo "$DATE CPU temp out of expected range" >> $LOGDIR
fi
