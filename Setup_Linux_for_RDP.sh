#!/bin/bash
if [ -n "$(type -t yum)" ] ; then
    linuxDistro="Fedora"
    packageManager="yum"
elif [ -n "$(type -t apt-get)" ] ; then
    linuxDistro="Debian"
    packageManager="apt-get"
fi


currentUser=$(whoami)
if [ "$currentUser" == "root" ] ; then
    #Update/Upgrade the OS
    if [ $linuxDistro == "Debian" ] ; then
        eval $packageManager -y update && apt-get -y upgrade
    elif [ $linuxDistro == "Fedora" ] ; then
        eval $packageManager check-update
    else
        eval $packageManager -y update && apt-get -y upgrade
    fi

    #Allow the user to change timezone
    if [ $linuxDistro == "Debian" ] ; then
        dpkg-reconfigure tzdata
    elif [ $linuxDistro == "Fedora" ] ; then
        tzselect
    fi
    
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
    elif [ -n "$(type -t firewalld)" ] ; then
	if [ "$(systemctl status firewalld | grep Active | awk '{print $2}')" = "inactive" ] ; then
            read -p "Would you like to Enable the Firewall? (Y/N) "
            #echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                systemctl enable firewalld
                systemctl start firewalld
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
                eval $packageManager -y install jedit
                break;
                ;;
            "kdevelop")
                eval $packageManager -y install kdevelop
                break;
                ;;
            "scite")
                eval $packageManager -y install scite
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
                eval $packageManager -y install clamav clamtk
                break;
                ;;
            "Chkrootkit")
                eval $packageManager -y install chkrootkit
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
                eval $packageManager -y install shutter
                break;
                ;;
            "Kazam")
                eval $packageManager -y install kazam
                break;
                ;;
            "Flameshot")
                eval $packageManager -y install flameshot
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
                eval $packageManager -y install remmina remmina-plugin-rdp
                echo -e "full address:s:$computerName" > /home/$USER/Desktop/$computerName-Remote.rdp
                echo -e "gatewayhostname:s:$gateway" >> /home/$USER/Desktop/$computerName-Remote.rdp
                echo -e "promptcredentialonce:i:1" >> /home/$USER/Desktop/$computerName-Remote.rdp
                echo -e "prompt for credentials:i:1" >> /home/$USER/Desktop/$computerName-Remote.rdp

                echo -e "full address:s:$computerName" > /home/$USER/Desktop/$computerName-Local.rdp
                echo -e "promptcredentialonce:i:1" >> /home/$USER/Desktop/$computerName-Local.rdp
                echo -e "prompt for credentials:i:1" >> /home/$USER/Desktop/$computerName-Local.rdp
                break;
                ;;
            "FreeRDP")
                eval $packageManager -y install freerdp2-x11
                eval $packageManager -q -y install freerdp
                localRDPFileName=/home/$USER/Desktop/$computerName-Local.sh
                remoteRDPFileName=/home/$USER/Desktop/$computerName-Remote.sh
                if [ $linuxDistro == "Debian" ] ; then
                    localRDPFileName=~/Desktop/$computerName-Local.sh
                    remoteRDPFileName=~/Desktop/$computerName-Remote.sh
                fi
                echo -e "#!/bin/bash" > $localRDPFileName
                echo -e "xfreerdp /v:$computerName +clipboard /multimon /u:\"$domain\\$username\" /audio-mode:0" >> $localRDPFileName
                chmod +x $localRDPFileName

                echo -e "#!/bin/bash" > $remoteRDPFileName
                echo -e "xfreerdp /v:$computerName +clipboard /multimon /u:\"$username@$UPN\" /g:\"$gateway\" /audio-mode:0" >> $remoteRDPFileName
                chmod +x $remoteRDPFileName

                while [[ -z "$computer2" ]]
                do
                    read -p "Would you like to add another computer? (Y/N) "
                    if [[ $REPLY =~ ^[Yy]$ ]]
                    then
                        echo
                        echo "What is the computer name?"
                        read -r computer2
                        echo
                        localRDPFileName=/home/$USER/Desktop/$computer2-Local.sh
                        remoteRDPFileName=/home/$USER/Desktop/$computer2-Remote.sh
                        if [ $linuxDistro == "Debian" ] ; then
                            localRDPFileName=~/Desktop/$computer2-Local.sh
                            remoteRDPFileName=~/Desktop/$computer2-Remote.sh
                        fi
                        echo -e "#!/bin/bash" > $localRDPFileName
                        echo -e "xfreerdp /v:$computer2 +clipboard /multimon /u:\"$domain\\$username\" /audio-mode:0" >> $localRDPFileName
                        chmod +x $localRDPFileName

                        echo -e "#!/bin/bash" > $remoteRDPFileName
                        echo -e "xfreerdp /v:$computer2 +clipboard /multimon /u:\"$username@$UPN\" /g:\"$gateway\" /audio-mode:0" >> $remoteRDPFileName
                        chmod +x $remoteRDPFileName
                        
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
    
    eval $packageManager -qq -y install numlockx
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
