#!/bin/sh

PWD=$(pwd)
DEBUG=0
LOG="/mnt/us/extensions/clock_todoist/clock.log"
#LOG="/dev/null"
#LOG="/dev/pts/0"
FBINK="/mnt/us/extensions/MRInstaller/bin/PW2/fbink -q"
FONT="regular=/usr/java/lib/fonts/Palatino-Regular.ttf"
FONT2="regular=/usr/java/lib/fonts/Futura-Medium.ttf"
API_KEY="$(cat api_key.txt)"
LINK="https://api.todoist.com/api/v1/sync"
FRIEND_PATH="/mnt/us/images/tails_logo_small_bg.png"


#PW2 binaries
FBROTATE="echo 270 > /sys/devices/platform/imx_epdc_fb/graphics/fb0/rotate"
BACKLIGHT="/sys/devices/platform/imx-i2c.0/i2c-0/0-003c/max77696-bl.0/backlight/max77696-bl/brightness"
BATTERY="/sys/devices/system/wario_battery/wario_battery0/battery_capacity"
TEMP_SENSOR="/sys/devices/platform/imx-i2c.0/i2c-0/0-003c/max77696-battery.0/power_supply/max77696-battery/temp"

# Constants
COLUMNS=2
ROWS=9
COLUMN_WIDTH=290
ROW_HEIGHT=50
NIGHT_START=3
NIGHT_END=9

log() {
    echo "`date '+%Y-%m-%d_%H:%M:%S'`: $1" >> $LOG
}

wait_for_wifi() {
  return `lipc-get-prop com.lab126.wifid cmState | grep -e "CONNECTED" | wc -l`
}


update_todoist() {
    TASKS_str=$(curl -f -s -m 5 https://api.todoist.com/api/v1/sync -H "Authorization: Bearer $API_KEY" -d resource_types='["items"]' | python3 get_tasks.py)
    num_tasks=$(( $(echo $TASKS_str | sed -e "s/;/\n/g" | wc -l) -1 ))
    log "Got $num_tasks tasks. ($TASKS_str, RC=$RC)"
}

clear_screen(){
    $FBINK -f -c
    $FBINK -f -c
}

draw_recurrent(){
  
    ## Adjusted coordinates according to display resolution. This is for PW2.
   
    $FBINK -b -k top=55,left=340,width=260,height=200
    $FBINK -b -O -t $FONT,size=118,top=18,bottom=0,left=0,right=0 "$TIME"
    $FBINK -b    -t $FONT2,size=12,top=10,bottom=0,left=540,right=0 "$BAT%"    
}

draw_hourly(){
	
	# Add tasks in a grid
	COL_cur=0
	ROW_cur=0
	position_cur=0

	# while [ "$ROW_cur" -lt "$ROWS" ]; do
	while [ "$position_cur" -lt "$num_tasks" ]; do
		position_cur=$(($COL_cur+$ROW_cur*$COLUMNS+1))
		TEXT_cur=$(echo "$TASKS_str" | cut -d';' -f "$position_cur" -s)
		X_cur=$((20+$COL_cur*$COLUMN_WIDTH))
		right_margin=$(( ($COLUMNS-$COL_cur-1) * $COLUMN_WIDTH + 15))
		Y_cur=$((337+$ROW_cur*$ROW_HEIGHT))
		bottom_margin=$(( ($ROWS-$ROW_cur-1) * $ROW_HEIGHT + 20))
		color_bg="WHITE"

		# Add checkerboard pattern
		if [ "$(( ( $COL_cur + $ROW_cur ) % 2 ))" -eq 0 ]; then
		    color_bg="GRAYD"
		fi
		$FBINK -b -B $color_bg -k top=$(($Y_cur-11)),left=$(($X_cur-5)),width=$COLUMN_WIDTH,height=$ROW_HEIGHT

		$FBINK -b -o -m -t $FONT2,size=10,top=$Y_cur,bottom=$bottom_margin,left=$X_cur,right=$right_margin "$TEXT_cur"

		COL_cur=$(($COL_cur+1))
		if [ "$COL_cur" -ge "$COLUMNS" ]; then
		    COL_cur="0"
		    ROW_cur=$(($ROW_cur+1))
		fi
	done

	# Make separation lines
	$FBINK -b -k top=320,left=5,width=10,height=460
	$FBINK -b -B BLACK -k top=320,left=8,width=2,height=460
	$FBINK -b -k top=320,left=295,width=10,height=460
	$FBINK -b -B BLACK -k top=320,left=299,width=2,height=460
	$FBINK -b -k top=320,left=585,width=10,height=460
	$FBINK -b -B BLACK -k top=320,left=590,width=2,height=460
	$FBINK -b -B BLACK -k top=320,left=8,width=584,height=2
	$FBINK -b -B BLACK -k top=780,left=8,width=584,height=2
	# Clear space after the grid
	$FBINK -b -k top=782,left=8,width=584,height=15

	# Text updated with low frequency
	# Date assumes that the hourly update happens at xx:00
        $FBINK -b -m -t $FONT,size=20,top=250,bottom=0,left=0,right=0 "$DATE" 
	if [ "$NOWIFI" = "1" ]; then
	     $FBINK -b -t $FONT2,size=12,top=10,bottom=0,left=50,right=0 "No Wifi!"
	fi
	# Print a friend
	eips -g $FRIEND_PATH -x 270 -y 10


}

update_data() {
    BAT=$(cat $BATTERY)
    TIME=$(date '+%H:%M')
    DATE=$(date '+%A %-d %B %Y')
    # Inefficient but who cares
    DATE=$(echo $DATE | sed -e "s/Monday/Lunedì/g" -e "s/Tuesday/Martedì/g" -e "s/Wednesday/Mercoledì/g" -e "s/Thursday/Giovedì/g" -e "s/Friday/Venerdì/g" -e "s/Saturday/Sabato/g" -e "s/Sunday/Domenica/g" -e "s/January/Gennaio/g" -e "s/February/Febbraio/g" -e "s/March/Marzo/g" -e "s/April/Aprile/g" -e "s/May/Maggio/g" -e "s/June/Giugno/g" -e "s/July/Luglio/g" -e "s/August/Agosto/g" -e "s/September/Settembre/g" -e "s/October/Ottobre/g" -e "s/November/Novembre/g" -e "s/December/Dicembre/g" )
}

### Prep Kindle...
log " ------------- Startup ------------" 

### No way of running this if wifi is down.
if [ `lipc-get-prop com.lab126.wifid cmState` != "CONNECTED" ]; then
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

$FBINK -w -c -f -m -t $FONT,size=20,top=380,bottom=0,left=0,right=0 "Starting Clock..." > /dev/null 2>&1

sleep 1

### turn off 270 degree rotation of framebuffer device
# eval $FBROTATE

### Set lowest cpu clock
echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
### Disable Screensaver
lipc-set-prop com.lab126.powerd preventScreenSaver 1

### set time/weather/tasks as we start up
ntpdate -s it.pool.ntp.org
update_todoist
update_data
clear_screen
draw_recurrent
draw_hourly

while true; do
    log "Top of loop (awake!)." 
    ### Backlight off
    # echo -n 0 > $BACKLIGHT

    ### Set time via ntpdate every hour
    HOUR=`date "+%H"`
    MINUTE=`date "+%M"`
    HOURLY_UPDATE="0"
    if [ "$MINUTE" = "00" ]; then 
	HOURLY_UPDATE="1"
    fi
    # Don't update during the night, saves api calls, still clear the hour to avoid overlapping
    if [ "$HOUR" -ge $NIGHT_START ] || [ "$HOUR" -lt $NIGHT_END ]; then
	log "Night time, skipping the hourly update"
    	$FBINK -b -k top=55,left=0,width=260,height=200
	HOURLY_UPDATE="0"
    fi
    if [ "$HOURLY_UPDATE" = "1" ]; then
	log "Fetch hourly data"
        ### Enable WIFI, disable wifi first in order to have a defined state
	# if [ `lipc-get-prop com.lab126.cmd wirelessEnable` = "0" ]; then
            log "Enabling Wifi" 
            lipc-set-prop com.lab126.cmd wirelessEnable 1
	    # ifconfig wlan0 up
	    start wifid
	# fi
        TRYCNT=0
        NOWIFI=0
        ### Wait for wifi to come up
    	while wait_for_wifi; do
            if [ ${TRYCNT} -gt 30 ]; then
                ### waited long enough
                log "No Wifi... ($TRYCNT)" 
                NOWIFI=1
                break
            fi
            WIFISTATE=$(lipc-get-prop com.lab126.wifid cmState)
            log "Waiting for Wifi... (try $TRYCNT: $WIFISTATE)" 
            ### Are we stuck in READY state?
            if [ "$WIFISTATE" = "READY" ]; then
                ### we have to reconnect
                log "Reconnecting to Wifi..." 
                /usr/bin/wpa_cli -i wlan0 reconnect

                ### Could also be that kindle forgot the wpa ssid/psk combo
                #if [ wpa_cli status | grep INACTIVE | wc -l ]; then...
            fi
	    ### Are we stuck in NA state, whatever that is?
            if [ "$WIFISTATE" = "NA" ]; then
		# Try disabling and reenabling???
		log "Apparently stuck in NA state, checking wifid"
		log "$(status wifid)"
	    fi
    	    sleep 1
            let TRYCNT=$TRYCNT+1
    	done
	log "wifiEnabled? `lipc-get-prop com.lab126.cmd wirelessEnable`"
        log "wifi: `lipc-get-prop com.lab126.wifid cmState`" 
        log "wifi: `wpa_cli status`" 

        if [ `lipc-get-prop com.lab126.wifid cmState` = "CONNECTED" ]; then
            ### Finally, set time
            log "Setting time..." 
            ntpdate -s it.pool.ntp.org
            RC=$?
            log "Time set. ($RC)" 
            # Update todoist tasks every day at 6
            # if [ $HOUR == "06" ]; then
            update_todoist
            log "Todoist updated." 
            # fi
        fi
        clear_screen
    fi

    ### Disable WIFI
    if     [ "$DEBUG" = "0" ] \
        && [ `lipc-get-prop com.lab126.cmd wirelessEnable` != "0" ]; then
	log "Before disabling: `lipc-get-prop com.lab126.wifid cmState`, `lipc-get-prop com.lab126.cmd wirelessEnable`, `wpa_cli status`"
        lipc-set-prop com.lab126.cmd wirelessEnable 0
	# ifconfig wlan0 down
	stop wifid
	log "After disabling: `lipc-get-prop com.lab126.wifid cmState`, `lipc-get-prop com.lab126.cmd wirelessEnable`, `wpa_cli status`"
    fi

    update_data

    draw_recurrent

    if [ "$HOURLY_UPDATE" = "1" ]; then
	draw_hourly
    fi	
 
    ### update framebuffer
    $FBINK -w -s

    log "Battery: $BAT" 

    if [ "$DEBUG" = "1" ]; then
        exit
    fi

    ### Set Wakeuptimer
	#echo 0 > /sys/class/rtc/rtc1/wakealarm
	#echo ${WAKEUP_TIME} > /sys/class/rtc/rtc1/wakealarm
    NOW=$(date +%s)
    # Reduce update frequency at night
    if [ "$HOUR" -ge $NIGHT_START ] && [ "$HOUR" -lt $NIGHT_END ]; then  
    	let WAKEUP_TIME="((($NOW + 599)/60)*60)" # Hack to get next 10 minutes
    else
    	let WAKEUP_TIME="((($NOW + 59)/60)*60)" # Hack to get next minute
    fi
    let SLEEP_SECS=$WAKEUP_TIME-$NOW

    ### Prevent SLEEP_SECS from being negative or just too small
    ### if we took too long
    if [ $SLEEP_SECS -lt 5 ]; then
        let SLEEP_SECS=$SLEEP_SECS+60
    fi
    rtcwake -d /dev/rtc1 -m no -s $SLEEP_SECS
    log "Going to sleep for $SLEEP_SECS s" 
	### Go into Suspend to Memory (STR)
	echo "mem" > /sys/power/state
done
