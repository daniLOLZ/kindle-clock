DEBUG=0

BASE_DIR_KINDLE="/mnt/us/extensions/tasknotes_weather"
LOG="$BASE_DIR_KINDLE/clock.log"

# Paths
FBINK="/mnt/us/extensions/MRInstaller/bin/PW2/fbink -q"
FONT="regular=/usr/java/lib/fonts/Palatino-Regular.ttf"
FONT2="regular=/usr/java/lib/fonts/Futura-Medium.ttf"
PREFERENCES_FILE="./preferences.json"

TASK_SERVER="dani@192.168.1.2"
TASK_REMOTE_PATH="/home/dani/logs/tasks.json"
TASK_LOCAL="./tasks.json"

log() {
  echo "$(date '+%Y-%m-%d_%H:%M:%S'): $1" >>$LOG
}

clear_screen() {
  $FBINK -f -c
  $FBINK -f -c
}

wait_for_wifi() {
  return $(lipc-get-prop com.lab126.wifid cmState | grep -e "CONNECTED" | wc -l)
}
