DEBUG=0

BASE_DIR_KINDLE="/mnt/us/extensions/tasknotes_weather"
LOG="$BASE_DIR_KINDLE/clock.log"

# Paths
FBINK="/mnt/us/extensions/MRInstaller/bin/PW2/fbink -q"
FONT="regular=/usr/java/lib/fonts/Palatino-Regular.ttf"
FONT2="regular=/usr/java/lib/fonts/Futura-Medium.ttf"
PREFERENCES_FILE="./preferences.json"

TASK_SERVER=$(jq -r '.server_address' $PREFERENCES_FILE)
TASK_REMOTE_PATH=$(jq -r '.server_task_path' $PREFERENCES_FILE)
TASK_LOCAL=$(jq -r '.local_task_path' $PREFERENCES_FILE)

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
