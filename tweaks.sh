#!/bin/sh
# tweaks.sh - MZD Speedometer Version 5.2
# Installer made with MZD-AIO  v2.7.6 https://github.com/Trevelopment/MZD-AIO
# By Diginix, Trezdog44, & Many Others
# For more information visit https://mazdatweaks.com
# Enjoy, Trezdog44 - Trevelopment.com

# Time
hwclock --hctosys

# AIO Variables
AIO_VER=5.2
AIO_DATE=2018.01.28

KEEPBKUPS=1
TESTBKUPS=1
SKIPCONFIRM=0

timestamp()
{
  date +"%D %T"
}
get_cmu_sw_version()
{
  _ver=$(grep "^JCI_SW_VER=" /jci/version.ini | sed 's/^.*_\([^_]*\)\"$/\1/')
  _patch=$(grep "^JCI_SW_VER_PATCH=" /jci/version.ini | sed 's/^.*\"\([^\"]*\)\"$/\1/')
  _flavor=$(grep "^JCI_SW_FLAVOR=" /jci/version.ini | sed 's/^.*_\([^_]*\)\"$/\1/')

  if [ ! -z "${_flavor}" ]; then
    echo "${_ver}${_patch}-${_flavor}"
  else
    echo "${_ver}${_patch}"
  fi
}
get_cmu_ver()
{
  _ver=$(grep "^JCI_SW_VER=" /jci/version.ini | sed 's/^.*_\([^_]*\)\"$/\1/' | cut -d '.' -f 1)
  echo ${_ver}
}
log_message()
{
  echo "$*" 1>&2
  echo "$*" >> "${MYDIR}/AIO_log.txt"
  /bin/fsync "${MYDIR}/AIO_log.txt"
}
aio_info()
{
  if [ ${KEEPBKUPS} -eq 1 ]
  then
    echo "$*" 1>&2
    echo "$*" >> "${MYDIR}/AIO_info.json"
    /bin/fsync "${MYDIR}/AIO_info.json"
  fi
}
# CASDK functions
MZD_APP_SD=/tmp/mnt/sd_nav
MZD_APP_DIR=/tmp/mnt/resources/aio/mzd-casdk/apps
get_casdk_mode()
{
  if [ -e /jci/casdk/casdk.aio ]; then
    echo 1
  else
    echo 0
  fi
}
add_casdk_app()
{
  CASDK_APP=${2}
  if [ ${1} -eq 1 ] && ! grep -Fq "app.${CASDK_APP}" ${MZD_APPS_JS}
  then
    echo "  \"app.${CASDK_APP}\"," >> ${MZD_APPS_JS}
    cp -a ${MYDIR}/casdk/apps/app.${CASDK_APP} ${MZD_APP_DIR}
    CASDK_APP="${CASDK_APP}         "
    log_message "===                 Installed CASDK App: ${CASDK_APP:0:10}                   ==="
  fi
}
compatibility_check()
{
  # Compatibility check falls into 5 groups:
  # 59.00.5XX ($COMPAT_GROUP=5)
  # 59.00.4XX ($COMPAT_GROUP=4)
  # 59.00.3XX ($COMPAT_GROUP=3)
  # 58.00.XXX ($COMPAT_GROUP=2)
  # 55.00.XXX - 56.00.XXX ($COMPAT_GROUP=1)
  _VER=$(get_cmu_ver)
  _VER_EXT=$(grep "^JCI_SW_VER=" /jci/version.ini | sed 's/^.*_\([^_]*\)\"$/\1/' | cut -d '.' -f 3)
  _VER_MID=$(grep "^JCI_SW_VER=" /jci/version.ini | sed 's/^.*_\([^_]*\)\"$/\1/' | cut -d '.' -f 2)
  if [ $_VER_MID -ne "00" ] # Only development versions have numbers other than '00' in the middle
  then
    echo 0 && return
  fi
  if [ $_VER -eq 55 ] || [ $_VER -eq 56 ]
  then
    echo 1 && return
  elif [ $_VER -eq 58 ]
  then
    echo 2 && return
  elif [ $_VER -eq 59 ]
  then
    if [ $_VER_EXT -lt 400 ] # v59.00.300-400
    then
      echo 3 && return
    elif [ $_VER_EXT -lt 500 ] # v59.00.400-500
    then
      echo 4 && return
    elif [ $_VER_EXT -lt 599 ]
    then
      echo 5 && return # 59.00.502 is another level because it is not compatible with USB Audio Mod
    else
      echo 0 && return
    fi
  else
    echo 0
  fi
}
remove_aio_css()
{
  sed -i "/.. MZD-AIO-TI *${2} *CSS ../,/.. END AIO *${2} *CSS ../d" "${1}"
  INPUT="${1##*/}               "
  log_message "===               Removed CSS From ${INPUT:0:20}               ==="
}
remove_aio_js()
{
  sed -i "/.. MZD-AIO-TI.${2}.JS ../,/.. END AIO.${2}.JS ../d" "${1}"
  INPUT=${1##*/}
  log_message "===            Removed ${2:0:11} JavaScript From ${INPUT:0:13}    ==="
}
show_message()
{
  sleep 5
  killall jci-dialog
  #	log_message "= POPUP: $* "
  /jci/tools/jci-dialog --info --title="MZD Speedometer  v.${AIO_VER}" --text="$*" --no-cancel &
}
show_message_OK()
{
  sleep 4
  killall jci-dialog
  #	log_message "= POPUP: $* "
  /jci/tools/jci-dialog --confirm --title="INSTALL SPEEDOMETER?" --text="$*" --ok-label="YES - GO ON" --cancel-label="NO - ABORT"
  if [ $? != 1 ]
  then
    killall jci-dialog
    return
  else
    log_message "********************* INSTALLATION ABORTED *********************"
    show_message "INSTALLATION ABORTED! PLEASE UNPLUG USB DRIVE"
    sleep 10
    killall jci-dialog
    exit 0
  fi
}
add_app_json()
# script by vic_bam85
{
  # check if entry in additionalApps.json still exists, if so nothing is to do
  count=$(grep -c '{ "name": "'"${1}"'"' /jci/opera/opera_dir/userjs/additionalApps.json)
  if [ "$count" = "0" ]
  then
    log_message "===  ${2:0:10} not found in additionalApps.json, first installation  ==="
    mv /jci/opera/opera_dir/userjs/additionalApps.json /jci/opera/opera_dir/userjs/additionalApps.json.old
    sleep 2
    # delete last line with "]" from additionalApps.json
    grep -v "]" /jci/opera/opera_dir/userjs/additionalApps.json.old > /jci/opera/opera_dir/userjs/additionalApps.json
    sleep 2
    cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps${1}-2._delete_last_line.json"
    # check, if other entrys exists
    count=$(grep -c '}' /jci/opera/opera_dir/userjs/additionalApps.json)
    if [ "$count" != "0" ]
    then
      # if so, add "," to the end of last line to additionalApps.json
      echo "$(cat /jci/opera/opera_dir/userjs/additionalApps.json)", > /jci/opera/opera_dir/userjs/additionalApps.json
      sleep 2
      cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps${1}-3._add_comma_to_last_line.json"
      log_message "===           Found existing entrys in additionalApps.json            ==="
    fi
    # add app entry and "]" again to last line of additionalApps.json
    log_message "===        Add ${2:0:10} to last line of additionalApps.json         ==="
    echo '  { "name": "'"${1}"'", "label": "'"${2}"'" }' >> /jci/opera/opera_dir/userjs/additionalApps.json
    sleep 2
    if [ ${3} != "" ]
    then
      sed -i 's/"label": "'"${2}"'" \}/"label": "'"${2}"'", "preload": "'"${3}"'" \}/g' /jci/opera/opera_dir/userjs/additionalApps.json
    fi
    cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps${1}-4._add_entry_to_last_line.json"
    echo "]" >> /jci/opera/opera_dir/userjs/additionalApps.json
    sleep 2
    cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps${1}-5._after.json"
    rm -f /jci/opera/opera_dir/userjs/additionalApps.json.old
  else
    log_message "===         ${2:0:10} already exists in additionalApps.json          ==="
  fi
  if [ -e /jci/opera/opera_dir/userjs/nativeApps.js ]
  then
    echo "additionalApps = $(cat /jci/opera/opera_dir/userjs/additionalApps.json)" > /jci/opera/opera_dir/userjs/nativeApps.js
    log_message "===                    Updated nativeApps.js                          ==="
  fi
}
remove_app_json()
# script by vic_bam85
{
  unix2dos /jci/opera/opera_dir/userjs/additionalApps.json
  # check if app entry in additionalApps.json still exists, if so, then it will be deleted
  count=$(grep -c '{ "name": "'"${1}"'"' /jci/opera/opera_dir/userjs/additionalApps.json)
  if [ "$count" -gt "0" ]
  then
    log_message "====   Remove ${count} entry(s) of ${1:0:10} found in additionalApps.json   ==="
    mv /jci/opera/opera_dir/userjs/additionalApps.json /jci/opera/opera_dir/userjs/additionalApps.json.old
    # delete last line with "]" from additionalApps.json
    grep -v "]" /jci/opera/opera_dir/userjs/additionalApps.json.old > /jci/opera/opera_dir/userjs/additionalApps.json
    sleep 2
    cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps${1}-2._delete_last_line.json"
    # delete all app entrys from additionalApps.json
    sed -i "/${1}/d" /jci/opera/opera_dir/userjs/additionalApps.json
    sleep 2
    json="$(cat /jci/opera/opera_dir/userjs/additionalApps.json)"
    # check if last sign is comma
    rownend=$(echo -n $json | tail -c 1)
    if [ "$rownend" = "," ]
    then
      # if so, remove "," from back end
      echo ${json%,*} > /jci/opera/opera_dir/userjs/additionalApps.json
      sleep 2
      log_message "===  Found comma at last line of additionalApps.json and deleted it   ==="
    fi
    cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps${1}-3._delete_app_entry.json"
    # add "]" again to last line of additionalApps.json
    echo "]" >> /jci/opera/opera_dir/userjs/additionalApps.json
    sleep 2
    first=$(head -c 1 /jci/opera/opera_dir/userjs/additionalApps.json)
    if [ $first != "[" ]
    then
      sed -i "1s/^/[\n/" /jci/opera/opera_dir/userjs/additionalApps.json
      log_message "===             Fixed first line of additionalApps.json               ==="
    fi
    rm -f /jci/opera/opera_dir/userjs/additionalApps.json.old
    cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps${1}-4._after.json"
  else
    log_message "===            ${1:0:10} not found in additionalApps.json            ==="
  fi
  dos2unix /jci/opera/opera_dir/userjs/additionalApps.json
  if [ -e /jci/opera/opera_dir/userjs/nativeApps.js ]
  then
    echo "additionalApps = $(cat /jci/opera/opera_dir/userjs/additionalApps.json)" > /jci/opera/opera_dir/userjs/nativeApps.js
    log_message "===                    Updated nativeApps.js                          ==="
  fi
}
# disable watchdog and allow write access
echo 1 > /sys/class/gpio/Watchdog\ Disable/value
mount -o rw,remount /
# mount resources
mount -o rw,remount /tmp/mnt/resources/

MYDIR=$(dirname "$(readlink -f "$0")")
CMU_VER=$(get_cmu_ver)
CMU_SW_VER=$(get_cmu_sw_version)
COMPAT_GROUP=$(compatibility_check)
CASDK_MODE=$(get_casdk_mode)

# save logs
mkdir -p "${MYDIR}/bakups/test/"
if [ -f "${MYDIR}/AIO_log.txt" ]; then
  if [ ! -f "${MYDIR}/bakups/count.txt" ]; then
    echo 0 > "${MYDIR}/bakups/count.txt"
  fi
  logcount=$(cat ${MYDIR}/bakups/count.txt)
  mv "${MYDIR}/AIO_log.txt" "${MYDIR}/bakups/AIO_log-${logcount}.txt"
  echo $((logcount+1)) > "${MYDIR}/bakups/count.txt"
fi
rm -f "${MYDIR}/AIO_info.json"

log_message "========================================================================="
log_message "=======================   START LOGGING TWEAKS...  ======================"
log_message "======================= AIO v.${AIO_VER}  -  ${AIO_DATE} ======================"
log_message "======================= CMU_SW_VER = ${CMU_SW_VER} ======================"
log_message "=======================  COMPATIBILITY_GROUP  = ${COMPAT_GROUP} ======================="
#log_message "======================== CMU_VER = ${CMU_VER} ====================="
if [ $CASDK_MODE -eq 1 ]; then
  log_message "=============================  CASDK MODE ==============================="
  WELCOME_MSG="====== MZD SPEEDOMETER ${AIO_VER} ======\n\n===**** CASDK MODE ****===="
else
  log_message ""
  WELCOME_MSG="==== MZD SPEEDOMETER  ${AIO_VER} ====="
fi
log_message "=======================   MYDIR = ${MYDIR}    ======================"
log_message "==================      DATE = $(timestamp)        ================="

show_message "${WELCOME_MSG}"

aio_info '{"info":{'
aio_info \"CMU_SW_VER\": \"${CMU_SW_VER}\",
aio_info \"AIO_VER\": \"${AIO_VER}\",
aio_info \"USB_PATH\": \"${MYDIR}\",
aio_info \"KEEPBKUPS\": \"${KEEPBKUPS}\"
aio_info '},'
# first test, if copy from MZD to usb drive is working to test correct mount point
cp /jci/sm/sm.conf "${MYDIR}"
if [ -e "${MYDIR}/sm.conf" ]
then
  log_message "===         Copytest to sd card successful, mount point is OK         ==="
  log_message " "
  rm -f "${MYDIR}/sm.conf"
else
  log_message "===     Copytest to sd card not successful, mount point not found!    ==="
  /jci/tools/jci-dialog --title="ERROR!" --text="Mount point not found, have to reboot again" --ok-label='OK' --no-cancel &
  sleep 5
  reboot
fi
if [ $COMPAT_GROUP -eq 0 ] && [ $CMU_VER -lt 55 ]
then
  show_message "PLEASE UPDATE YOUR CMU FW TO VERSION 55 OR HIGHER\nYOUR FIRMWARE VERSION: ${CMU_SW_VER}\n\nUPDATE TO VERSION 55+ TO USE AIO"
  mv ${MYDIR}/tweaks.sh ${MYDIR}/_tweaks.sh
  show_message "INSTALLATION ABORTED REMOVE USB DRIVE NOW" && sleep 5
  log_message "************************* INSTALLATION ABORTED **************************" && reboot
  exit 1
fi
 # Compatibility Check
if [ $COMPAT_GROUP -ne 0 ]
then
  if [ ${SKIPCONFIRM} -eq 1 ]
  then
    show_message "MZD Speedometer v.${AIO_VER}\nDetected compatible version ${CMU_SW_VER}\nContinuing Installation..."
    sleep 5
  else
    show_message_OK "MZD Speedometer v.${AIO_VER}\nDetected compatible version ${CMU_SW_VER}\n\n To continue installation choose YES\n To abort choose NO"
  fi
  log_message "=======        Detected compatible version ${CMU_SW_VER}          ======="
else
  # Removing the comment (#) from the following line will allow MZD-AIO-TI to run with unknown fw versions ** ONLY MODIFY IF YOU KNOW WHAT YOU ARE DOING **
  # show_message_OK "Detected previously unknown version ${CMU_SW_VER}!\n\n To continue anyway choose YES\n To abort choose NO"
  log_message "Detected previously unknown version ${CMU_SW_VER}!"
  show_message "Sorry, your CMU Version is not compatible with MZD Speedometer\nE-mail aio@mazdatweaks.com with your\nCMU version: ${CMU_SW_VER} for more information"
  sleep 10
  show_message "UNPLUG USB DRIVE NOW"
  sleep 15
  killall jci-dialog
  # To run unknown FW you need to comment out or remove the following 2 lines
  mount -o ro,remount /
  exit 0
fi
# a window will appear for 4 seconds to show the beginning of installation
show_message "START OF TWEAK INSTALLATION\nMZD Speedometer v.${AIO_VER} By: Trezdog44 & Diginix\n(This and the following message popup windows\n DO NOT have to be confirmed with OK)\nLets Go!"
log_message " "
log_message "======***********    BEGIN PRE-INSTALL OPERATIONS ...    **********======"

# disable watchdogs in /jci/sm/sm.conf to avoid boot loops if something goes wrong
if [ ! -e /jci/sm/sm.conf.org ]
then
  cp -a /jci/sm/sm.conf /jci/sm/sm.conf.org
  log_message "===============  Backup of /jci/sm/sm.conf to sm.conf.org  =============="
else
  log_message "================== Backup of sm.conf.org already there! ================="
fi
sed -i 's/watchdog_enable="true"/watchdog_enable="false"/g' /jci/sm/sm.conf
sed -i 's|args="-u /jci/gui/index.html"|args="-u /jci/gui/index.html --noWatchdogs"|g' /jci/sm/sm.conf
log_message "===============  Watchdog In sm.conf Permanently Disabled! =============="

# -- Enable userjs and allow file XMLHttpRequest in /jci/opera/opera_home/opera.ini - backup first - then edit
if [ ! -e /jci/opera/opera_home/opera.ini.org ]
then
  cp -a /jci/opera/opera_home/opera.ini /jci/opera/opera_home/opera.ini.org
  log_message "======== Backup /jci/opera/opera_home/opera.ini to opera.ini.org ========"
else
  log_message "================== Backup of opera.ini already there! ==================="
fi
sed -i 's/User JavaScript=0/User JavaScript=1/g' /jci/opera/opera_home/opera.ini
count=$(grep -c "Allow File XMLHttpRequest=" /jci/opera/opera_home/opera.ini)
skip_opera=$(grep -c "Allow File XMLHttpRequest=1" /jci/opera/opera_home/opera.ini)
if [ "$skip_opera" -eq "0" ]
then
  if [ "$count" -eq "0" ]
  then
    sed -i '/User JavaScript=.*/a Allow File XMLHttpRequest=1' /jci/opera/opera_home/opera.ini
  else
    sed -i 's/Allow File XMLHttpRequest=.*/Allow File XMLHttpRequest=1/g' /jci/opera/opera_home/opera.ini
  fi
  log_message "============== Enabled Userjs & Allowed File Xmlhttprequest ============="
  log_message "==================  In /jci/opera/opera_home/opera.ini =================="
else
  log_message "============== Userjs & File Xmlhttprequest Already Enabled ============="
fi

# Remove fps.js if still exists
if [ -e /jci/opera/opera_dir/userjs/fps.js ]
then
  mv /jci/opera/opera_dir/userjs/fps.js /jci/opera/opera_dir/userjs/fps.js.org
  log_message "======== Moved /jci/opera/opera_dir/userjs/fps.js to fps.js.org ========="
fi
# Fix missing /tmp/mnt/data_persist/dev/bin/ if needed
if [ ! -e /tmp/mnt/data_persist/dev/bin/ ]
then
  mkdir -p /tmp/mnt/data_persist/dev/bin/
  log_message "======== Restored Missing Folder /tmp/mnt/data_persist/dev/bin/ ========="
fi
log_message "=========************ END PRE-INSTALL OPERATIONS ***************========="
log_message " "
log_message "==========************* BEGIN INSTALLING TWEAKS **************==========="
log_message " "

# start JSON array of backups
if [ "${KEEPBKUPS}" -eq 1 ]
then
  aio_info '"Backups": ['
fi

# Speedometer v4.8
show_message "INSTALL SPEEDOMETER v5.2 ..."
log_message "==========**************** INSTALL SPEEDOMETER *****************========="

log_message "===                 Begin Installation of Speedometer                 ==="
if [ "${TESTBKUPS}" = "1" ]
then
  cp /jci/scripts/stage_wifi.sh "${MYDIR}/bakups/test/stage_wifi_speedometer-before.sh"
  cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps_speedometer-1._before.json"
fi

### kills all WebSocket daemons
pkill websocketd

### save speedometer-config.js
if [ -e /jci/gui/apps/_speedometer/js/speedometer-config.js ]
then
  cp -a /jci/gui/apps/_speedometer/js/speedometer-config.js /tmp/root
  log_message "===             Save Temporary Copy of speedometer-config.js          ==="
fi

### cleanup old versions
rm -fr /jci/gui/addon-player
rm -fr /jci/gui/addon-speedometer
rm -fr /jci/gui/speedometer
rm -fr /jci/gui/apps/_speedometer

sed -i '/Speedo-Compass-Video/d' /jci/scripts/stage_wifi.sh
sed -i '/v3.2/d' /jci/scripts/stage_wifi.sh
sed -i '/Removed requirement/d' /jci/scripts/stage_wifi.sh
sed -i '/# mount /d' /jci/scripts/stage_wifi.sh
sed -i '/Added additional/d' /jci/scripts/stage_wifi.sh
sed -i '/get-vehicle-speed/d' /jci/scripts/stage_wifi.sh
sed -i '/get-vehicle-data-other/d' /jci/scripts/stage_wifi.sh
sed -i '/get-gps-data/d' /jci/scripts/stage_wifi.sh
sed -i '/Need to set defaults/d' /jci/scripts/stage_wifi.sh
sed -i '/myVideoList /d' /jci/scripts/stage_wifi.sh
sed -i '/playbackAction /d' /jci/scripts/stage_wifi.sh
sed -i '/playbackOption /d' /jci/scripts/stage_wifi.sh
sed -i '/playbackStatus /d' /jci/scripts/stage_wifi.sh
sed -i '/playback/d' /jci/scripts/stage_wifi.sh
sed -i '/myVideoList/d' /jci/scripts/stage_wifi.sh
sed -i '/Video player action watch/d' /jci/scripts/stage_wifi.sh
sed -i '/playback-action.sh/d' /jci/scripts/stage_wifi.sh
sed -i '/Log data collection/d' /jci/scripts/stage_wifi.sh
sed -i '/get-log-data.sh/d' /jci/scripts/stage_wifi.sh
sed -i '/addon-speedometer.sh &/d' /jci/scripts/stage_wifi.sh
sed -i '/addon-player.sh &/d' /jci/scripts/stage_wifi.sh
sed -i '/stage_vehSpeed.sh/d' /jci/scripts/stage_wifi.sh
sed -i '/mount of SD card/d' /jci/scripts/stage_wifi.sh
sed -i '/sleep 40/d' /jci/scripts/stage_wifi.sh
sed -i '/sleep 55/d' /jci/scripts/stage_wifi.sh
sed -i '/sleep 50/d' /jci/scripts/stage_wifi.sh
sed -i '/umount -l/d' /jci/scripts/stage_wifi.sh
sed -i '/sleep 25/d' /jci/scripts/stage_wifi.sh
sed -i '/sleep 4/d' /jci/scripts/stage_wifi.sh
sed -i '/sleep 6/d' /jci/scripts/stage_wifi.sh

# remove old websocket
if grep -Fq "55554" /jci/scripts/stage_wifi.sh
then
  sed -i '/55554/d' /jci/scripts/stage_wifi.sh
  sed -i '/9969/d' /jci/scripts/stage_wifi.sh
  sed -i '/## Speedometer/d' /jci/scripts/stage_wifi.sh
fi

# delete empty lines
sed -i '/^ *$/ d' /jci/scripts/stage_wifi.sh
sed -i '/#!/ a\ ' /jci/scripts/stage_wifi.sh

# Remove startup file from userjs
rm -f /jci/opera/opera_dir/userjs/speedometer-startup.js
rm -f /jci/opera/opera_dir/userjs/speedometer.js

cp -a ${MYDIR}/config/speedometer/jci/gui/apps/* /jci/gui/apps/
log_message "===             Copied folder /jci/gui/apps/_speedometer              ==="
find /jci/gui/apps/_*/ -type f -name '*.js' -exec chmod 755 {} \;
find /jci/gui/apps/_*/ -type f -name '*.sh' -exec chmod 755 {} \;

if [ ! -e /jci/gui/addon-common/websocketd ]  || [ ! -e /jci/gui/addon-common/cufon-yui.js ]; then
  cp -a "${MYDIR}/config/jci/gui/addon-common/" /jci/gui/
  chmod 755 /jci/gui/addon-common/websocketd
  log_message "===   Copied websocketd and jquery.min.js to /jci/gui/addon-common/   ==="
else
  log_message "===       websocketd and jquery.min.js available, no copy needed      ==="
fi

# check for 1st line of stage_wifi.sh
if grep -Fq "#!/bin/sh" /jci/scripts/stage_wifi.sh
then
  log_message "===                 1st line of stage_wifi.sh is OK                   ==="
else
  echo "#!/bin/sh" > /jci/scripts/stage_wifi.sh
  log_message "===         Missing 1st line of stage_wifi.sh, copied new one         ==="
fi

# add commands for speedometer to stage_wifi.sh
if [ -e /jci/scripts/stage_wifi.sh ]
then
  if grep -Fq "speedometer.sh &" /jci/scripts/stage_wifi.sh
  then
    log_message "===  Speedometer entry already exists in /jci/scripts/stage_wifi.sh   ==="
  else
    sed -i '/#!/ a\### Speedometer' /jci/scripts/stage_wifi.sh
    sleep 1
    sed -i '/Speedometer/ i\ ' /jci/scripts/stage_wifi.sh
    sed -i '/### Speedometer/ a\/jci/gui/addon-common/websocketd --port=9969 /jci/gui/apps/_speedometer/sh/speedometer.sh &' /jci/scripts/stage_wifi.sh
    log_message "===       Added speedometer entry to /jci/scripts/stage_wifi.sh       ==="
    cp /jci/scripts/stage_wifi.sh "${MYDIR}/bakups/test/stage_wifi_speedometer-after.sh"
  fi
fi

# copy additionalApps.js, if not already present
if [ $CASDK_MODE -eq 0 ]
then
  log_message "===           No additionalApps.js available, will copy one           ==="
  cp -a ${MYDIR}/config/jci/opera/opera_dir/userjs/additionalApps.js /jci/opera/opera_dir/userjs/ && CASDK_MODE=1
  find /jci/opera/opera_dir/userjs/ -type f -name '*.js' -exec chmod 755 {} \;
fi

# create additionalApps.json file from scratch if the file does not exist
if [ ! -e /jci/opera/opera_dir/userjs/additionalApps.json ]
then
  echo "[" > /jci/opera/opera_dir/userjs/additionalApps.json
  echo "]" >> /jci/opera/opera_dir/userjs/additionalApps.json
  chmod 755 /jci/opera/opera_dir/userjs/additionalApps.json
  log_message "===                   Created additionalApps.json                     ==="
fi

# call function add_app_json to modify additionalApps.json
add_app_json "_speedometer" "Speedometer" "speedometer-startup.js"

# add preload to the AA json entry if needed
if ! grep -q "speedometer-startup.js" /jci/opera/opera_dir/userjs/additionalApps.json
then
	sed -i 's/"label": "Speedometer" \}/"label": "Speedometer", "preload": "speedometer-startup.js" \}/g' /jci/opera/opera_dir/userjs/additionalApps.json
	log_message "===     Added speedometer-startup.js to speedometer json entry        ==="
fi

# change compass rotating depending on NAV SD card inside or not
if [ ! -d /mnt/sd_nav/content/speedcam ] || [ ${COMPAT_GROUP} -ne 1  ]
then
  sed -i 's/var noNavSD = false;/var noNavSD = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
  log_message "===    Changed compass rotating, because no NAV SD card is inside     ==="
fi
if [ ${SPEEDCOLOR} != 0 ]
then
  rm -f /jci/gui/common/images/*.aio
  touch /jci/gui/common/images/${SPEEDCOLOR}.aio
  log_message "===                   Set Speedometer Color: ${SPEEDCOLOR}                    ==="
fi

# if another color scheme is active, then change speeometer graphics too
if [ -e /jci/gui/common/images/Blue.aio ]
then
  cp -a ${MYDIR}/config/speedometer/color/Blue/* /jci/gui/apps/_speedometer/templates/SpeedoMeter/images/
  log_message "===               Change speedometer graphics to blue                 ==="
fi

if [ -e /jci/gui/common/images/Green.aio ]
then
  cp -a ${MYDIR}/config/speedometer/color/Green/* /jci/gui/apps/_speedometer/templates/SpeedoMeter/images/
  log_message "===               Change speedometer graphics to green                ==="
fi

if [ -e /jci/gui/common/images/Orange.aio ]
then
  cp -a ${MYDIR}/config/speedometer/color/Orange/* /jci/gui/apps/_speedometer/templates/SpeedoMeter/images/
  log_message "===               Change speedometer graphics to orange               ==="
fi

if [ -e /jci/gui/common/images/Pink.aio ]
then
  cp -a ${MYDIR}/config/speedometer/color/Pink/* /jci/gui/apps/_speedometer/templates/SpeedoMeter/images/
  log_message "===                Change speedometer graphics to pink                ==="
fi

if [ -e /jci/gui/common/images/Purple.aio ]
then
  cp -a ${MYDIR}/config/speedometer/color/Purple/* /jci/gui/apps/_speedometer/templates/SpeedoMeter/images/
  log_message "===               Change speedometer graphics to purple               ==="
fi

if [ -e /jci/gui/common/images/Silver.aio ]
then
  cp -a ${MYDIR}/config/speedometer/color/Silver/* /jci/gui/apps/_speedometer/templates/SpeedoMeter/images/
  log_message "===               Change speedometer graphics to silver               ==="
fi

if [ -e /jci/gui/common/images/Yellow.aio ]
then
  cp -a ${MYDIR}/config/speedometer/color/Yellow/* /jci/gui/apps/_speedometer/templates/SpeedoMeter/images/
  log_message "===               Change speedometer graphics to yellow               ==="
fi

# change to english version
# show_message "CHANGE SPEEDOMETER TO ENGLISH..."
sed -i 's/var language = "DE";/var language = "EN";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
log_message "===              CHANGED SPEEDOMETER TO ENGLISH VERSION               ==="

# change to version with mph
# show_message "CHANGE SPEEDOMETER TO MPH ..."
sed -i 's/var isMPH = false;/var isMPH = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
log_message "===                    CHANGED SPEEDOMETER TO MPH                     ==="

# csetting speedometer variant start in analog mode
# show_message "SETTING ANALOG STARTUP MODE ..."
sed -i 's/var startAnalog = false;/var startAnalog = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
log_message "===               START MODED SPEEDOMETER IN ANALOG MODE              ==="

# Original speedometer background
# show_message "SET ORIGINAL SPEEDOMETER BACKGROUND ..."
sed -i 's/var original_background_image = false;/var original_background_image = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
log_message "===                SET ORIGINAL SPEEDOMETER BACKGROUND                ==="

# change temp from C to F
sed -i 's/var tempIsF = false;/var tempIsF = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
log_message "===                   TEMPERATURE SET TO FAHRENHEIT                   ==="

# Digital Clock Mod
sed -i '/Remove this/d' /jci/gui/apps/_speedometer/css/StatusBarSpeedometer.css
log_message "===                     APPLY DIGITAL CLOCK MOD                       ==="

if [ ${TESTBKUPS} = "1" ]
then
  cp -a /jci/gui/apps/_speedometer/js/speedometer-startup.js ${MYDIR}/bakups/test/
  cp -a /jci/scripts/stage_wifi.sh ${MYDIR}/bakups/test/stage_wifi-after_speedo.sh
fi

log_message "=======**********    END INSTALLATION OF SPEEDOMETER    **********======="
log_message " "

# show_message "INSTALL SPEEDOMETER VARIANT"
log_message "========************* INSTALL SPEEDOMETER VARIANT ... ***********========"

# Copy modded speedo files
cp -a ${MYDIR}/config/speedometer_mod/jci /
log_message "===                  Speedometer Variant Installed                    ==="

chmod 755 /jci/fonts/Crysta.ttf
chmod 755 /jci/fonts/CHN/Crysta.ttf
chmod 755 /jci/fonts/JP/Crysta.ttf

log_message "=======******** END INSTALLATION OF SPEEDOMETER VARIANT *********========"
log_message " "

# Speedometer v5.0
# show_message "INSTALL DIGITAL BAR SPEEDOMETER VARIANT ..."
log_message "=========********** INSTALL DIGITAL BAR SPEEDOMETER ************========="

cp -a ${MYDIR}/config/speedometer_bar/jci /
log_message "===                 Speedometer Bar Variant Installed                 ==="

sed -i 's/var barSpeedometerMod = false;/var barSpeedometerMod = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
log_message "===       Set flag for bar speedometer in speedometer-startup.js      ==="

if [ -e ${MYDIR}/config/speedometer_bar/speedometer-config.js ]
then
  cp -a ${MYDIR}/config/speedometer_bar/speedometer-config.js /jci/gui/apps/_speedometer/js
  log_message "===                  Copied Speedometer Config File                   ==="
elif [ -e /tmp/root/speedometer-config.js ]
then
  cp -a /tmp/root/speedometer-config.js /jci/gui/apps/_speedometer/js
  log_message "===               Reuse Previous Speedometer Config File              ==="
else
  log_message "===       NO 'speedometer-config.js' FILE FOUND... USING DEFAULT      ==="
fi

log_message "=========************ END DIGITAL BAR SPEEDOMETER **************========="
log_message " "

log_message " "
sleep 2
log_message "======================= END OF TWEAKS INSTALLATION ======================"
show_message "========== END OF SPEEDOMETER INSTALLATION =========="
if [ "${KEEPBKUPS}" = "1" ]
then
  json="$(cat ${MYDIR}/AIO_info.json)"
  rownend=$(echo -n $json | tail -c 1)
  if [ "$rownend" = "," ]
  then
    # if so, remove "," from back end
    echo -n ${json%,*} > ${MYDIR}/AIO_info.json
    sleep 2
  fi
  aio_info ']}'
fi
# a window will appear before the system reboots automatically
sleep 3
killall jci-dialog
/jci/tools/jci-dialog --info --title="MZD Speedometer Installed" --text="THE SYSTEM WILL REBOOT IN A FEW SECONDS!" --no-cancel &
sleep 10
killall jci-dialog
/jci/tools/jci-dialog --info --title="MZD Speedometer v.${AIO_VER}" --text="YOU CAN REMOVE THE USB DRIVE NOW\n\nENJOY!" --no-cancel &
reboot
killall jci-dialog
