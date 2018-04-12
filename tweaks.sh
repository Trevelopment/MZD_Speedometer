#!/bin/sh
# tweaks.sh - MZD Speedometer Version 5.6
# Configurable Installer
# By Diginix, Trezdog44, & Many Others
# GitHub Repo: https://github.com/Trevelopment/MZD_Speedometer
# License: GPLv3 - https://www.gnu.org/licenses/gpl-3.0.html
# Enjoy, Trezdog44 - https://mazdatweaks.com

# Time
hwclock --hctosys

# AIO Variables
AIO_VER=5.6
AIO_DATE=2018.04.13

# Set to 1 to skip confirmation (configure settings in speedometer-config.js)
SKIPCONFIRM=0
# Set to 1 to force inteactive config installer
SPD_CONFIG=0
# Set to 1 to force uninstall (also works with SKIPCONFIRM=1)
UNINSTALL=0

# Installation functions
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

# CASDK functions
#MZD_APP_SD=/tmp/mnt/sd_nav
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
  #/jci/tools/jci-dialog --confirm --title="INSTALL SPEEDOMETER?" --text="$*" --ok-label="YES - GO ON" --cancel-label="NO - ABORT"
  /jci/tools/jci-dialog --3-button-dialog --title="INSTALL SPEEDOMETER?" --text="$*" --ok-label="Install" --cancel-label="Config" --button3-label="Uninstall"
  METHOD=$?
  killall jci-dialog
  if [ $METHOD -eq 0 ]
  then
    return
  elif [ $METHOD -eq 1 ]
  then
    SPD_CONFIG=1
    return
  else
    UNINSTALL=1
    return
  fi
}
# Shotrhand for location of additionalApps.json
ADDITIONAL_APPS_JSON="/jci/opera/opera_dir/userjs/additionalApps.json"
add_app_json()
{
  # check if entry in additionalApps.json still exists, if so nothing is to do
  count=$(grep -c '{ "name": "'"${1}"'"' ${ADDITIONAL_APPS_JSON})
  if [ $count -eq 0 ]
  then
    log_message "===  ${2:0:10} not found in additionalApps.json, first installation  ==="
    mv ${ADDITIONAL_APPS_JSON} ${ADDITIONAL_APPS_JSON}.old
    sleep 2
    # delete last line with "]" from additionalApps.json
    grep -v "]" ${ADDITIONAL_APPS_JSON}.old > ${ADDITIONAL_APPS_JSON}
    sleep 2
    cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps${1}-2._delete_last_line.json"
    # check, if other entrys exists
    count=$(grep -c '}' ${ADDITIONAL_APPS_JSON})
    if [ $count -ne 0 ]
    then
      # if so, add "," to the end of last line to additionalApps.json
      echo "$(cat ${ADDITIONAL_APPS_JSON})", > ${ADDITIONAL_APPS_JSON}
      sleep 2
      cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps${1}-3._add_comma_to_last_line.json"
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
    cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps${1}-4._add_entry_to_last_line.json"
    echo "]" >> ${ADDITIONAL_APPS_JSON}
    sleep 2
    rm -f ${ADDITIONAL_APPS_JSON}.old
  else
    log_message "===         ${2:0:10} already exists in additionalApps.json          ==="
  fi
  cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps${1}-5._after.json"
  if [ -e /jci/opera/opera_dir/userjs/nativeApps.js ]
  then
    echo "additionalApps = $(cat ${ADDITIONAL_APPS_JSON})" > /jci/opera/opera_dir/userjs/nativeApps.js
    log_message "===                    Updated nativeApps.js                          ==="
  fi
}
remove_app_json()
{
  # check if app entry in additionalApps.json still exists, if so, then it will be deleted
  count=$(grep -c '{ "name": "'"${1}"'"' ${ADDITIONAL_APPS_JSON})
  if [ "$count" -gt "0" ]
  then
    log_message "====   Remove ${count} entry(s) of ${1:0:10} found in additionalApps.json   ==="
    mv ${ADDITIONAL_APPS_JSON} ${ADDITIONAL_APPS_JSON}.old
    # delete last line with "]" from additionalApps.json
    grep -v "]" ${ADDITIONAL_APPS_JSON}.old > ${ADDITIONAL_APPS_JSON}
    sleep 2
    cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps${1}-2._delete_last_line.json"
    # delete all app entrys from additionalApps.json
    sed -i "/${1}/d" ${ADDITIONAL_APPS_JSON}
    sleep 2
    json="$(cat ${ADDITIONAL_APPS_JSON})"
    # check if last sign is comma
    rownend=$(echo -n $json | tail -c 1)
    if [ "$rownend" == "," ]
    then
      # if so, remove "," from back end
      echo ${json%,*} > ${ADDITIONAL_APPS_JSON}
      sleep 2
      log_message "===  Found comma at last line of additionalApps.json and deleted it   ==="
    fi
    cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps${1}-3._delete_app_entry.json"
    # add "]" again to last line of additionalApps.json
    echo "]" >> ${ADDITIONAL_APPS_JSON}
    sleep 2
    first=$(head -c 1 ${ADDITIONAL_APPS_JSON})
    if [ "$first" != "[" ]
    then
      sed -i '1s/^/[\n/' ${ADDITIONAL_APPS_JSON}
      log_message "===             Fixed first line of additionalApps.json               ==="
    else
      sed -i '1s/\[/\[\n/' ${ADDITIONAL_APPS_JSON}
    fi
    rm -f ${ADDITIONAL_APPS_JSON}.old
  else
    log_message "===            ${1:1:10} not found in additionalApps.json            ==="
  fi
  cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps${1}-4._after.json"
  if [ -e /jci/opera/opera_dir/userjs/nativeApps.js ]
  then
    echo "additionalApps = $(cat ${ADDITIONAL_APPS_JSON})" > /jci/opera/opera_dir/userjs/nativeApps.js
    log_message "===                    Updated nativeApps.js                          ==="
  fi
}
# Start Installation
start_install()
{
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

  log_message "========================================================================="
  log_message "=======================   START LOGGING TWEAKS...  ======================"
  log_message "==================== SPEEDOMETER v.${AIO_VER}  -  ${AIO_DATE} ==================="
  log_message "======================= CMU_SW_VER = ${CMU_SW_VER} ======================"
  log_message "=======================  COMPATIBILITY_GROUP  = ${COMPAT_GROUP} ======================="
  #log_message "======================== CMU_VER = ${CMU_VER} ====================="
  if [ $CASDK_MODE -eq 1 ]; then
    log_message "=============================  CASDK MODE ==============================="
    WELCOME_MSG="====== MZD SPEEDOMETER ${AIO_VER} ======\n\n===**** CASDK MODE ****===="
  else
    log_message ""
    WELCOME_MSG="==== MZD SPEEDOMETER ${AIO_VER} ====="
  fi
  log_message "=======================   MYDIR = ${MYDIR}    ======================"
  log_message "==================      DATE = $(timestamp)        ================="

  show_message "${WELCOME_MSG}"
}

#Preinstall Operations
preinstall_ops()
{
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
    if [ $SKIPCONFIRM -eq 1 ]
    then
      show_message "MZD Speedometer v.${AIO_VER}\nDetected compatible version ${CMU_SW_VER}\nContinuing Installation With Default Settings..."
      sleep 5
    else
      show_message_OK "MZD Speedometer v.${AIO_VER}\nDetected compatible version ${CMU_SW_VER}\nContinue Installation With Default Settings?\nTo Configure Settings Choose Config\nOr Choose To Uninstall"
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
  show_message "START SPEEDOMETER INSTALLATION\n\nMZD Speedometer v.${AIO_VER}"
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

  if [ $UNINSTALL -eq 1 ]
  then
    show_message "UNINSTALL SPEEDOMETER ..."
    log_message "==========************** UNINSTALLING SPEEDOMETER ************==========="
  else
    show_message "INSTALL SPEEDOMETER v${AIO_VER} ..."
    log_message "==========**************** INSTALL SPEEDOMETER *****************========="
  fi
  log_message " "

  cp /jci/scripts/stage_wifi.sh "${MYDIR}/bakups/test/stage_wifi_speedometer-before.sh"
  cp /jci/opera/opera_dir/userjs/additionalApps.json "${MYDIR}/bakups/test/additionalApps_speedometer-1._before.json"

  ### kills all WebSocket daemons
  pkill websocketd

  ### save speedometer-config.js
  if [ -e /jci/gui/apps/_speedometer/js/speedometer-config.js ]
  then
    cp -a /jci/gui/apps/_speedometer/js/speedometer-config.js /tmp/root
    log_message "===             Save Temporary Copy of speedometer-config.js          ==="
  fi
}

# Clean up speedometer files - This always runs before
# speedo_install to uninstall old versions
speedo_cleanup()
{
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
  sed -i '/55554/d' /jci/scripts/stage_wifi.sh
  sed -i '/9969/d' /jci/scripts/stage_wifi.sh
  sed -i '/## Speedometer/d' /jci/scripts/stage_wifi.sh

  # delete empty lines
  sed -i '/^ *$/ d' /jci/scripts/stage_wifi.sh
  sed -i '/#!/ a\ ' /jci/scripts/stage_wifi.sh

  # Remove startup file from userjs
  rm -f /jci/opera/opera_dir/userjs/speedometer-startup.js
  rm -f /jci/opera/opera_dir/userjs/speedometer.js
}

# Choose Language for installation config
choose_language()
{
  killall jci-dialog
  /jci/tools/jci-dialog --3-button-dialog --title="SPEEDOMETER CONFIG" --text="SPEEDOMETER LANGUAGE?" --ok-label="English" --cancel-label="German" --button3-label="More"
  CHOICE=$?
  killall jci-dialog
  if [ $CHOICE -eq 1 ]
  then
    sed -i 's/var language = .*;/var language = "DE";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
    log_message "===              CHANGED SPEEDOMETER TO GERMAN VERSION               ==="
  elif [ $CHOICE -eq 2 ]
  then
    /jci/tools/jci-dialog --3-button-dialog --title="SPEEDOMETER CONFIG" --text="SPEEDOMETER LANGUAGE?" --ok-label="Spanish" --cancel-label="French" --button3-label="More"
    CHOICE=$?
    killall jci-dialog
    if [ $CHOICE -eq 0 ]
    then
      # change to spanish version
      # show_message "CHANGE SPEEDOMETER TO SPANISH..."
      sed -i 's/var language = .*;/var language = "ES";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
      log_message "===              CHANGED SPEEDOMETER TO SPANISH VERSION               ==="
    elif [ $CHOICE -eq 1 ]
    then
      # change to french version
      # show_message "CHANGE SPEEDOMETER TO FRENCH..."
      sed -i 's/var language = .*;/var language = "FR";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
      log_message "===              CHANGED SPEEDOMETER TO FRENCH VERSION                ==="
    else
      /jci/tools/jci-dialog --3-button-dialog --title="SPEEDOMETER CONFIG" --text="SPEEDOMETER LANGUAGE?" --ok-label="Polish" --cancel-label="Italian" --button3-label="More"
      CHOICE=$?
      killall jci-dialog
      if [ $CHOICE -eq 0 ]
      then
        # change to polish version
        # show_message "CHANGE SPEEDOMETER TO POLISH..."
        sed -i 's/var language = .*;/var language = "PL";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===               CHANGED SPEEDOMETER TO POLISH VERSION               ==="
      elif [ $CHOICE -eq 1 ]
      then
        # change to Italian version
        # show_message "CHANGE SPEEDOMETER TO ITALIAN..."
        sed -i 's/var language = .*;/var language = "IT";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===               CHANGED SPEEDOMETER TO ITALIAN VERSION              ==="
      else
        /jci/tools/jci-dialog --3-button-dialog --title="SPEEDOMETER CONFIG" --text="SPEEDOMETER LANGUAGE?" --ok-label="Slovak" --cancel-label="Turkish" --button3-label="Back To 1st"
        CHOICE=$?
        killall jci-dialog
        if [ $CHOICE -eq 0 ]
        then
          # change to slovak version
          # show_message "CHANGE SPEEDOMETER TO SLOVAK..."
          sed -i 's/var language = .*;/var language = "SK";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
          log_message "===                CHANGED SPEEDOMETER TO SLOVAK VERSION              ==="
        elif [ $CHOICE -eq 1 ]
        then
          # change to Turkish version
          # show_message "CHANGE SPEEDOMETER TO TURKISH..."
          sed -i 's/var language = .*;/var language = "TR";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
          log_message "===              CHANGED SPEEDOMETER TO TURKISH VERSION               ==="
        else
          # If we have gotten this far we need to start over
          choose_language
        fi
      fi
    fi
  fi
}
statusbar_speedo_mods()
{
  /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="DIGITAL CLOCK FONT?" --ok-label="YES" --cancel-label="NO"
  CHOICE=$?
  killall jci-dialog
  if [ $CHOICE -eq 0 ]
  then
    # Digital Clock Mod
    sed -i '/Remove this/d' /jci/gui/apps/_speedometer/css/StatusBarSpeedometer.css
    log_message "===                     APPLY DIGITAL CLOCK MOD                       ==="
  fi

  /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="EXTRA STATUSBAR VALUES?\n\n1. OUTSIDE TEMPERATURE & FUEL EFFICIENCY\n2. HEADING & ALTITUDE" --ok-label="1.TEMP/FUEL" --cancel-label="2.HEAD/ALT"
  CHOICE=$?
  killall jci-dialog
  if [ $CHOICE -eq 0 ]
  then
    sed -i 's/var sbTemp = .*;/var sbTemp = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
    log_message "===                   ADD TEMPERATURE TO STATUSBAR                    ==="
  fi
  
  /jci/tools/jci-dialog --3-button-dialog --title="SPEEDOMETER CONFIG" --text="STATUSBAR FUEL GUAGE?" --ok-label="TOP" --cancel-label="BOTTOM" --button3-label="NONE"
  CHOICE=$?
  killall jci-dialog
  if [ $CHOICE -eq 1 ]
  then  
    sed -i 's/var sbfbPos = .*;/var sbfbPos = "bottombar";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
    log_message "===                   ADD FUEL GAUGE TO STATUSBAR                    ==="
  elif [ $CHOICE -eq 0 ]
  then
    /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="STATUSBAR FUEL GUAGE TOP OF THE SCREEN\nABOVE OR BELOW THE STATUSBAR?\n(IN REVERSE THE FUEL BAR MOVES TO THE TOP OF THE SCREEN)" --ok-label="ABOVE" --cancel-label="BELOW"
    CHOICE=$?
    if [ $CHOICE -eq 0 ]
    then
      sed -i 's/var sbfbPos = .*;/var sbfbPos = "topbar";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
    else
      sed -i 's/var sbfbPos = .*;/var sbfbPos = "default";/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
    fi
  fi
}

# Install speedometer
speedo_install()
{
  if [ $UNINSTALL -eq 0 ]
  then
    cp -a ${MYDIR}/config/jci/gui/apps/* /jci/gui/apps/
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
      cp -a ${MYDIR}/config/jci/opera/opera_dir/userjs/*.js /jci/opera/opera_dir/userjs/ && CASDK_MODE=1
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

    # Remove old json entries
    if ! grep -Fq "speedometer-startup.js" /jci/opera/opera_dir/userjs/additionalApps.json
    then
      remove_app_json "_speedometer"
    fi

    # call function add_app_json to modify additionalApps.json
    add_app_json "_speedometer" "Speedometer" "speedometer-startup.js"

    # change compass rotating depending on NAV SD card inside or not
    if [ ! -d /mnt/sd_nav/content/speedcam ] || [ $COMPAT_GROUP -ne 1  ]
    then
      sed -i 's/var noNavSD = .*;/var noNavSD = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
      log_message "===    Changed compass rotating, because no NAV SD card is inside     ==="
    fi

    if [ $SPD_CONFIG -eq 1 ]
    then
      choose_language
      killall jci-dialog

      /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="SPEED UNIT?" --ok-label="KM/H" --cancel-label="MPH"
      CHOICE=$?
      killall jci-dialog
      # change to version with mph
      # show_message "CHANGE SPEEDOMETER TO MPH ..."
      if [ $CHOICE -eq 0 ]
      then
        sed -i 's/var isMPH = .*;/var isMPH = false;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===                   CHANGED SPEEDOMETER TO KM/H                     ==="
      fi

      /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="SPEEDOMETER BACKGROUND?" --ok-label="YES" --cancel-label="NO"
      CHOICE=$?
      killall jci-dialog
      if [ $CHOICE -eq 0 ]
      then
        # Original speedometer background
        # show_message "SET ORIGINAL SPEEDOMETER BACKGROUND ..."
        sed -i 's/var original_background_image = false;/var original_background_image = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===                SET ORIGINAL SPEEDOMETER BACKGROUND                ==="
      fi

      /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="TEMPERATURE UNIT?" --ok-label="C" --cancel-label="F"
      CHOICE=$?
      killall jci-dialog
      if [ $CHOICE -eq 1 ]
      then
        # change temp from C to F
        sed -i 's/var tempIsF = .*;/var tempIsF = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===                   TEMPERATURE SET TO FAHRENHEIT                   ==="
      fi

      /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="START SPEEDOMETER?" --ok-label="BAR" --cancel-label="CLASSIC"
      CHOICE=$?
      killall jci-dialog
      if [ $CHOICE -eq 1 ]
      then
        # Bar Speedo Mod
        sed -i 's/var barSpeedometerMod = .*;/var barSpeedometerMod = false;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===       Set flag for bar speedometer in speedometer-startup.js      ==="
      fi

      /jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="MODDED SPEEDOMETER?" --ok-label="ANALOG" --cancel-label="DIGITAL"
      CHOICE=$?
      killall jci-dialog
      if [ $CHOICE -eq 0 ]
      then
        # Speedo Variant
        sed -i 's/var startAnalog = .*;/var startAnalog = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===               START MODED SPEEDOMETER IN ANALOG MODE              ==="
      fi

      killall jci-dialog
      /jci/tools/jci-dialog --3-button-dialog --title="SPEEDOMETER CONFIG" --text="STATUSBAR SPEEDOMETER?" --ok-label="Car Speed" --cancel-label="GPS Speed" --button3-label="None"
      CHOICE=$?
      killall jci-dialog
      if [ $CHOICE -eq 0 ]
      then
        # show the vehicle speed instead of the gps speed in the small speedometer
        # show_message "CHANGE TO VEHICLE SPEED IN SMALL SPEEDO ..."
        sed -i 's/<div class="gpsSpeedValue">0<\/div>/<div class="vehicleSpeed">0<\/div>/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        sed -i 's/.gpsSpeedValue/.vehicleSpeed/g' /jci/gui/apps/_speedometer/css/StatusBarSpeedometer.css
        log_message "===              CHANGE TO VEHICLE SPEED IN SMALL SPEEDO              ==="
      elif [ $CHOICE -eq 2 ]
      then
        # no small speedometer in statusbar
        # show_message "DISABLE SMALL SPEEDOMETER IN STATUSBAR ..."
        sed -i 's/var enableSmallSbSpeedo = .*;/var enableSmallSbSpeedo = false;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
        log_message "===              DISABLE SMALL SPEEDOMETER IN STATUSBAR               ==="
      fi

      if [ $CHOICE -eq 0 ] || [ $CHOICE -eq 1 ]
      then
        statusbar_speedo_mods
      fi

      #/jci/tools/jci-dialog --confirm --title="SPEEDOMETER CONFIG" --text="SPEED COUNTER ANIMATION?" --ok-label="ENABLE" --cancel-label="DISABLE"
      #CHOICE=$?
      #killall jci-dialog
      #if [ $CHOICE -eq 0 ]
      #then
      # Enable counter animation
      #  sed -i 's/var speedAnimation = false;/var speedAnimation = true;/g' /jci/gui/apps/_speedometer/js/speedometer-startup.js
      #  log_message "===                 DISABLE SPEED COUNTER ANIMATION                   ==="
      #fi
    fi

    show_message "INSTALLING SPEEDOMETER ...."

    if [ -e ${MYDIR}/config/speedometer-config.js ]
    then
      cp -a ${MYDIR}/config/speedometer-config.js /jci/gui/apps/_speedometer/js
      log_message "===                  Copied Speedometer Config File                   ==="
    elif [ -e /tmp/root/speedometer-config.js ]
    then
      cp -a /tmp/root/speedometer-config.js /jci/gui/apps/_speedometer/js
      log_message "===               Reuse Previous Speedometer Config File              ==="
    else
      log_message "===       NO 'speedometer-config.js' FILE FOUND... USING DEFAULT      ==="
    fi
    cp -a ${MYDIR}/config/speedometer-controls.js /jci/gui/apps/_speedometer/js
    log_message "===                Copied Speedometer Controls File                   ==="
    cat ${MYDIR}/config/barThemes.css > /jci/gui/apps/_speedometer/css/_speedometerApp.css
    log_message "===                 Copied Bar Speedometer Themes                     ==="

    chmod -R 755 /jci/gui/apps/_speedometer/

    log_message " "
    sleep 2
    log_message "======================= END OF TWEAKS INSTALLATION ======================"
    show_message "========== END OF SPEEDOMETER INSTALLATION =========="
  else
    remove_app_json "_speedometer"
    log_message "====================== END OF TWEAKS UNINSTALLATION ====================="
    show_message "========== END OF SPEEDOMETER UNINSTALLATION =========="
  fi
}

# End of installation
end_install()
{
  sed -i '/^ *$/ d' ${ADDITIONAL_APPS_JSON}
  cp ${ADDITIONAL_APPS_JSON} "${MYDIR}/bakups/test/additionalApps.after.json"
  cp -a /jci/gui/apps/_speedometer/js/speedometer-startup.js ${MYDIR}/bakups/test/
  cp -a /jci/scripts/stage_wifi.sh ${MYDIR}/bakups/test/stage_wifi-after_speedo.sh

  # a window will appear before the system reboots automatically
  sleep 3
  killall jci-dialog
  /jci/tools/jci-dialog --info --title="MZD Speedometer Installed" --text="THE SYSTEM WILL REBOOT IN A FEW SECONDS!" --no-cancel &
  sleep 10
  killall jci-dialog
  /jci/tools/jci-dialog --info --title="MZD Speedometer v.${AIO_VER}" --text="YOU CAN REMOVE THE USB DRIVE NOW\n\nENJOY!" --no-cancel &
  reboot
  killall jci-dialog
}
# END INSTALLATION FUNCTIONS

## RUN INSTALLATION
start_install

preinstall_ops

speedo_cleanup

speedo_install

end_install
