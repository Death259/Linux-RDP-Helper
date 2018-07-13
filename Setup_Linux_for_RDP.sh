#!/bin/bash
getLinuxDistro() {
    if [ -n "$(type -t yum)" ] ; then
	return "Fedora"
    elif [ -n "$(type -t apt-get)" ] ; then
	return "Debian"
    fi
}

currentUser=$(whoami)
if [ "$currentUser" == "root" ] ; then
    #Update/Upgrade the OS
    if [ getLinuxDistro == "Debian" ] ; then
        apt-get -y update && apt-get -y upgrade
    elif [ getLinuxDistro == "Debian" ] ; then
        yum check-update
    else
        apt-get -y update && apt-get -y upgrade	
    fi

    read
    #Allow the user to change timezone
    dpkg-reconfigure tzdata
    
    #Check if uncomplicated firewall exists and if so ask if the user wants to enable it
    if [ -n "$(type -t ufw)" ] ; then
        if [ "$(ufw status | awk '{print $2}')" = "inactive" ] ; then
            read -p "Would you like to Enable the Uncomplicated Firewall? (Y/N) "
            #echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                ufw enable
            fi
            echo
        fi
    fi

    echo 'Which IDE Would you Like to Install?: '
    IDEOptions=("jedit" "kdevelop" "scite" "None")
    select opt in "${IDEOptions[@]}"
    do
        case $opt in
            "jedit")
                apt-get -y install jedit
                break;
                ;;
            "kdevelop")
                apt-get -y install kdevelop
                break;
                ;;
            "scite")
                apt-get -y install scite
                break;
                ;;
            "None")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    echo

    echo 'Which AntiVirus Would you Like to Install?: '
    AntiVirusOptions=("ClamAV" "Chkrootkit" "None")
    select opt in "${AntiVirusOptions[@]}"
    do
        case $opt in
            "ClamAV")
                apt-get -y install clamav clamtk
                break;
                ;;
            "Chkrootkit")
                apt-get -y install chkrootkit
                break;
                ;;
            "None")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    echo

    echo 'Which ScreenShot Tool Would you Like to Install?: '
    ScreenShotToolOptions=("Shutter" "Kazam" "Flameshot" "None")
    select opt in "${ScreenShotToolOptions[@]}"
    do
        case $opt in
            "Shutter")
                apt-get -y install shutter
                break;
                ;;
            "Kazam")
                apt-get -y install kazam
                break;
                ;;
            "Flameshot")
                apt-get -y install flameshot
                break;
                ;;
            "None")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    echo

    #echo "Installing FreeRDP..."
    #sudo apt-get -qq install freerdp-x11 yad zenity
    #sudo apt-get -y install freerdp2-x11
    echo "What is the username?"
    read -r username
    echo

    echo "What is the UPN?"
    read -r UPN
    echo

    echo "What is the Domain?"
    read -r domain
    echo

    echo "What is the gateway?"
    read -r gateway
    echo

    echo "What is the computer name?"
    read -r computerName
    echo

    echo 'Which RDP Client Would you Like to Install?: '
    RDPClientOptions=("Remmina" "FreeRDP" "None")
    select opt in "${RDPClientOptions[@]}"
    do
        case $opt in
            "Remmina")
                apt-get -y install remmina remmina-plugin-rdp
                echo -e "full address:s:$computerName" > ~/Desktop/$computerName-Remote.rdp
                echo -e "gatewayhostname:s:$gateway" >> ~/Desktop/$computerName-Remote.rdp
                echo -e "promptcredentialonce:i:1" >> ~/Desktop/$computerName-Remote.rdp
                echo -e "prompt for credentials:i:1" >> ~/Desktop/$computerName-Remote.rdp

                echo -e "full address:s:$computerName" > ~/Desktop/$computerName-Local.rdp
                echo -e "promptcredentialonce:i:1" >> ~/Desktop/$computerName-Local.rdp
                echo -e "prompt for credentials:i:1" >> ~/Desktop/$computerName-Local.rdp
                break;
                ;;
            "FreeRDP")
                apt-get -y install freerdp2-x11
		#yum install freerdp
                echo -e "#!/bin/bash" > ~/Desktop/$computerName-Local.sh
                echo -e "xfreerdp /v:$computerName +clipboard /multimon /u:\"$domain\\$username\" /audio-mode:0" >> ~/Desktop/$computerName-Local.sh
                chmod +x ~/Desktop/$computerName-Local.sh

                echo -e "#!/bin/bash" > ~/Desktop/$computerName-Remote.sh
                echo -e "xfreerdp /v:$computerName +clipboard /multimon /u:\"$username@$UPN\" /g:\"$gateway\" /audio-mode:0" >> ~/Desktop/$computerName-Remote.sh
                chmod +x ~/Desktop/$computerName-Remote.sh

                while [[ -z "$computer2" ]]
                do
                    read -p "Would you like to add another computer? (Y/N) "
                    if [[ $REPLY =~ ^[Yy]$ ]]
                    then
                        echo
                        echo "What is the computer name?"
                        read -r computer2
                        echo
                        echo -e "#!/bin/bash" > ~/Desktop/$computer2-Local.sh
                        echo -e "xfreerdp /v:$computer2 +clipboard /multimon /u:\"$domain\\$username\" /audio-mode:0" >> ~/Desktop/$computer2-Local.sh
                        chmod +x ~/Desktop/$computer2-Local.sh

                        echo -e "#!/bin/bash" > ~/Desktop/$computer2-Remote.sh
                        echo -e "xfreerdp /v:$computer2 +clipboard /multimon /u:\"$username@$UPN\" /g:\"$gateway\" /audio-mode:0" >> ~/Desktop/$computer2-Remote.sh
                        chmod +x ~/Desktop/$computer2-Remote.sh
                        
                        computer2=""
                else
                        computer2="nothing"
                fi
                done
                break;
                ;;
            "None")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    
    apt-get -qq install numlockx
    numlockx on

#    pacmd set-card-profile 2 output:iec958-stereo


    #echo "Installing Remmina and Setting up a RDP Connection..."
    #sudo apt-get -qq update
    #sudo apt-get -qq install remmina remmina-plugin-rdp
    #echo -e "full address:s:$computerName" > ~/Desktop/$computerName.rdp
    #echo -e "gatewayhostname:s:$gateway" >> ~/Desktop/$computerName.rdp
    #echo -e "promptcredentialonce:i:1" >> ~/Desktop/$computerName.rdp
    #echo -e "prompt for credentials:i:1" >> ~/Desktop/$computerName.rdp

else
		echo "This script has to be running as root. Please try using sudo."
fi
