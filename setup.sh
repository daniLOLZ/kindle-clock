#!/bin/sh
. ./shared.sh

### Prep Kindle...
log " ------------- Startup ------------"

### Flags
while getopts "d:" option; do
  case "$option" in
  d) DEBUG=${OPTARG} ;;
  esac
done

### No way of running this if wifi is down.
if [ $(lipc-get-prop com.lab126.wifid cmState) != "CONNECTED" ]; then
  log "No wifi, exiting..."
  exit 1
fi

### stop processes that we don't need
#K4
#/etc/init.d/framework stop
#/etc/init.d/pmond stop
#/etc/init.d/phd stop
#/etc/init.d/cmd stop
#/etc/initd./tmd stop
#/etc/init.d/browserd stop
#/etc/init.d/webreaderd stop
#/etc/init.d/lipc-daemon stop
#/etc/init.d/powerd stop
log "Stopping processes..."
#PW2/3
if [ "$DEBUG" = "0" ]; then
  stop framework
  stop lab126_gui
  stop otaupd
  stop phd
  stop tmd
  stop x
  stop todo
  stop sshd
  # stop mcsd
  # Cercane altri da bruciare con ps
fi
log "Stopped all useless processes"

$FBINK -w -c -f -m -t $FONT,size=20,top=380,bottom=0,left=0,right=0 "Starting Dashboard..." >/dev/null 2>&1

sleep 1

### turn off 270 degree rotation of framebuffer device
# eval $FBROTATE

### Set lowest cpu clock
echo powersave >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
### Disable Screensaver
lipc-set-prop com.lab126.powerd preventScreenSaver 1
