#!/bin/bash

HEIGHT=0
CHOICE_HEIGHT=10
WIDTH=0
BACKTITLE="MRROBOT.OS SYSTEM MENU"
TITLE="[ M A I N - M E N U ]"
MENU="Tasks:"

function change_wallpaper() {

	local f="$1"

	local m="$0: file $f select"

	if [ -f $f ]
	then
        if [[ $f =~ \.jpg$ ]] || [[ $f =~ \.jpeg$ ]] || [[ $f =~ \.png$ ]]; then

		    m="$0: $f file selected."
        else
            m="$f is not a image."
        fi
	else
		m="$0: $f is not a file."
	fi

    var=$(cat ~/.xmonad/xmonad.hs | grep feh | awk '{print $4}' | sed 's/\"//g')

    var2=$(cat ~/.xsessionrc | grep bg-scale | awk '{print $3}')

    sed -i "s%${var}%${f}%" ~/.xmonad/xmonad.hs

    sed -i "s%${var2}%${f}%" ~/.xsessionrc

    xmonad -recompile

	dialog --title "Wallpaper has been changed" --clear --msgbox "$m" 0 0
}

OPTIONS=(

Network/IP   "IP Settings"

Network/DNS  "DNS Settings"

Network/IFCS "Network Interfaces"

Network/Speedtest "Check connection speed"

Keybindings "Xmonad Key bindings"

"System Information" "Sys. info, disk spaces,"

"System Scripts" "Wallpaper, themes and others"

Timezone "Set Time Zone"

"Hints&Documentation" "Useful hints & New features"

Update       "System Update"

Reboot       "Reboot the System"

Shutdown     "Shutdown the System"

Logout/Exit  "Logout the Session"

Edit         "Edit the settings menu"

Shell        "Exit to Shell"
)

CHOICE=$(dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --menu "$MENU" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >/dev/tty)

clear

while true; do

    case $CHOICE in

        Network/IP)

            touch /tmp/network && cat /etc/hosts > /tmp/network

            dialog --textbox  /tmp/network 0 0

            rm /tmp/network

            exec "$0"

            ;;

        Network/DNS)

            #sudo nano /etc/resolv.conf

            touch /tmp/dns && cat /etc/resolv.conf > /tmp/dns

            dialog --textbox /tmp/dns 0 0

            rm /tmp/dns

            exec "$0"

            ;;

        Network/IFCS)
            #sudo nano /etc/network/interfaces
            touch /tmp/interfaces && ifconfig > /tmp/interfaces

            dialog --textbox /tmp/interfaces 0 0

            rm /tmp/interfaces

            exec "$0"

            ;;

        Network/Speedtest)

            echo "$(speedtest)" > /tmp/speedtest &

            for i in {1..100}; do echo $i; sleep .5; done | dialog --title "Network/Speedtest" --gauge "Please wait..." 10 70 0

            dialog --textbox /tmp/speedtest 0 0

            exec "$0"

            ;;

        Keybindings)

            ./keybindings.sh

            exec "$0"

            ;;

        "System Information")

            DIALOG_CANCEL=1
            DIALOG_ESC=255
            HEIGHT=0
            WIDTH=0

            display_result() {
                dialog --title "$1" \
                --no-collapse \
                --msgbox "$result" 0 0
            }

            while true; do
              exec 3>&1
              selection=$(dialog \
                --title "System Information" \
                --clear \
                --cancel-label "Back" \
                --menu "Please select:" 0 0 4 \
                "1" "Display System Information" \
                "2" "Display Disk Space" \
                "3" "Display Home Space Utilization" \
                2>&1 1>&3)
              exit_status=$?
              exec 3>&-
              case $exit_status in
                $DIALOG_CANCEL)
                  clear
                  exec "$0"
                  #exit
                  ;;
                $DIALOG_ESC)
                  clear
                  exec "$0"
                  #echo "Program aborted." >&2
                  #exit 1
                  ;;
              esac
              case $selection in
                1 )
                  result=$(echo "Hostname: $HOSTNAME"; uptime)
                  display_result "System Information"
                  ;;
                2 )
                  result=$(df -h)
                  display_result "Disk Space"
                  ;;
                3 )
                  if [[ $(id -u) -eq 0 ]]; then
                    result=$(du -sh /home/* 2> /dev/null)
                    display_result "Home Space Utilization (All Users)"
                  else
                    result=$(du -sh $HOME 2> /dev/null)
                    display_result "Home Space Utilization ($USER)"
                  fi
                  ;;
              esac
            done

            ;;

        #Sounds)

        #    vol=$(pamixer --get-volume)

        #    dialog --gauge  "Volume: " 18 78 "$vol" --and-widget --begin 4 4 --yesno "" 30 30 \

        #    ;;

        #Display)

        #    ;;

        "System Scripts")

            options=(1 "Change wallpaper"
                     2 "Change SSDM Theme"
                     3 "Change Plymouth Theme")

            choice=$(dialog --clear \
                    --title "Wallpaper&Themes" \
                    --menu "Wallpaper&Themes" \
                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                    "${options[@]}" \
                    2>&1 >/dev/tty)

            clear

            case $choice in

                1)  XMONAD_CONFIG="~/.xmonad/xmonad.hs"

                    XSESSION_CONFIG="~/.xsessionrc"

                    PICTURES_FOLDER="~/Pictures/"

                    # select filename using dialog
                    # store it to $FILE
                    FILE=$(dialog --title "Select a image" --stdout --title "Please choose a file to change wallpaper" --fselect ~/Pictures/ 0 0)

                    # select file
                    change_wallpaper "$FILE"

                    exec "$0"

                ;;

#                2)  FILE=$(dialog --title "Select a SDDM Theme" --stdout --title "Please choose a theme" --fselect /usr/share/sddm/themes/ 14 48)
#
#                    #echo $FILE > /tmp/deneme.txt
#
#                    theme="Current=$FILE"
#
#                    current=$(grep -w "Current" /etc/sddm.conf.d/kde_settings.conf)
#                    #echo $chosen >> /tmp/deneme.txt
#
#                    #echo $current >> /tmp/deneme.txt
#
#                    sudo sed -i "s/$theme/$match/" /etc/sddm.conf.d/kde_settings.conf
#                    dialog --title "SDDM Theme has been changed to $chosen from $current" --clear --msgbox "$m" 10 50
#
#                    exec "$0"
#
#                    FILE=$(dialog --title "Select a SDDM Theme" --stdout --title "Please choose a theme" --fselect /usr/share/sddm/themes/ 14 48)
#
#                    #echo $FILE > /tmp/deneme.txt
#
#                    theme="Current=$FILE"
#
#                    current=$(grep -w "Current" /etc/sddm.conf.d/kde_settings.conf)
#                    echo $chosen >> /tmp/deneme.txt
#
#                    echo $current >> /tmp/deneme.txt
#
#                    sudo sed -i "s/$theme/$match/" /etc/sddm.conf.d/kde_settings.conf
#                    dialog --title "SDDM Theme has been changed to $chosen from $current" --clear --msgbox "$m" 10 50
#
#                    exec "$0"
#
                2)  FILE=$(dialog --title "Select a SDDM Theme" --stdout --title "Please choose a theme" --fselect /usr/share/sddm/themes/ 0 0)

                    FILE="$(echo $FILE | rev | cut -d '/' -f 1 | rev)"

#THEMES=/usr/share/sddm/themes;

                    CONF_FILE=/etc/sddm.conf.d/kde_settings.conf;

                    match="Current=$FILE";

                    #echo "$match"

                    theme=$(grep -w "Current" $CONF_FILE);

                    echo "$theme"

                    sudo sed -i "s/$theme/$match/" $CONF_FILE;

                     dialog --title "SDDM Theme has been successfully changed." --clear --msgbox "$m" 0 0

                     exec "$0"

                ;;
                    #THEME_OPTIONS=("SDDM Themes" "Change SDDM Theme"
                    #"Plymouth Themes" "Change Plymouth Theme"
                    #3 "Option 3")

                3) FILE=$(dialog --title "Select a Plymouth Theme" --stdout --title "Please choose a theme" --fselect /usr/share/plymouth/themes/ 0 0)

                    #echo $FILE > /tmp/deneme.txt
                    FILE="$(echo $FILE | rev | cut -d '/' -f 1 | rev)"

                    match="Theme=$FILE"

                    theme=$(grep -w "Theme" /etc/plymouth/plymouthd.conf)

                    #echo $match >> /tmp/deneme.txt

                    #echo $theme >> /tmp/deneme.txt

                    sudo sed -i "s/$theme/$match/" /etc/plymouth/plymouthd.conf

                    sudo mkinitcpio -P

                    dialog --title "Plymouth Theme has been changed successfully" --clear --msgbox "$m" 0 0

                    exec "$0"

                ;;

        esac

        ;;

        Timezone)

            selected=$(timedatectl status | grep "Time zone" | awk '{print $3}')

            var=$(timedatectl list-timezones | awk '{print $1}')

            option=$(dialog --no-tags --menu "Please choose a timezone" 0 0 18 $var 3>&1 1>&2 2>&3)

            exitstatus=$?

            if [ $exitstatus = 0 ]; then

    #echo $option

                touch /tmp/timezone

                echo $option > /tmp/timezone

                cat /tmp/timezone

                timedatectl set-timezone "$option"

                dialog --msgbox  "Timezone changed to $option from $selected" 0 0

            else

                exec "$0"

            fi

            ;;

        "Hints&Documentation") dialog --msgbox "Empty for now." 0 0

            ;;

        Reboot)

            reboot

            ;;

        Shutdown)
            poweroff
            ;;

        Exit)
            logout
            ;;

        Update)
            sudo pacman -Syu

            exec "$0"

            ;;

        Edit)
            sudo vim /usr/local/bin/smenu
            ;;

        Shell)
            exit
            ;;
        *)
            exit
            ;;
    esac

done
