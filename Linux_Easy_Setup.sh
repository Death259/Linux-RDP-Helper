#!/bin/bash

function getComputerInformation {
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
}

function setupSnap {
	if [ -n "$(type -t snap)" ] ; then
		eval $packageManager -y install snapd
	fi

	if [ -z "$(ls / -l | grep '^l' | grep snap)" ] ; then
		ln -s /var/lib/snapd/snap /snap
	fi
}

if [ -n "$(type -t yum)" ] ; then
    linuxDistro="Fedora"
    packageManager="yum"
elif [ -n "$(type -t apt-get)" ] ; then
    linuxDistro="Debian"
    packageManager="apt-get"
elif [ -n "$(type -t zypper)" ] ; then
    linuxDistro="openSUSE"
    packageManager="zypper"
fi

currentUser=$(whoami)
if [ "$currentUser" == "root" ] ; then
    #Update/Upgrade the OS
    if [ $linuxDistro == "Debian" ] ; then
        eval $packageManager -y update && apt-get -y upgrade
    elif [ $linuxDistro == "Fedora" ] ; then
	#add the RPM Fusion Repository
	yum install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        eval $packageManager check-update
	dnf install gstreamer1-{ffmpeg,libav,plugins-{good,ugly,bad{,-free,-nonfree}}} --setopt=strict=0
	dnf install ffmpeg-libs
    else
        eval $packageManager -y update && apt-get -y upgrade
    fi

    #Allow the user to change timezone and keyboard
    if [ $linuxDistro == "Debian" ] ; then
        dpkg-reconfigure keyboard-configuration
        dpkg-reconfigure tzdata
    elif [ $linuxDistro == "Fedora" ] ; then
        eval $packageManager install system-config-keyboard
        system-config-keyboard
        tzselect
    fi

    #Change clock to be in 12 hour or 24 hour format
    echo 'Which clock format would you like?: '
    clockFormatOptions=("12 Hour" "24 Hour")
    select opt in "${clockFormatOptions[@]}"
    do
        case $opt in
            "12 Hour")
                dconf write /org/mate/panel/objects/clock/prefs/format "'12-hour'"
                break;
                ;;
            "24 Hour")
                dconf write /org/mate/panel/objects/clock/prefs/format "'24-hour'"
                break;
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    echo
    
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
    #else if firewalld exists and it's not active, then activate it
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
    IDEOptions=("jedit" "kdevelop" "scite" "VS Code" "None")
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
            "VS Code")
                #snap install powershell --classic
                if [ $linuxDistro == "Debian" ] ; then
                    dpkg-reconfigure keyboard-configuration
                    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
                    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
                    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
                    eval $packageManager update
                    eval $packageManager -y install code
                elif [ $linuxDistro == "Fedora" ] ; then
                    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                    eval $packageManager check-update
                    eval $packageManager -y install code
                fi
                break;
                ;;
            "spyder")
                eval $packageManager -y install spyder
                break;
                ;;
            "None")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    echo

    echo 'Which Email Client Would you Like to Install?: '
    IDEOptions=("Mailspring" "Thunderbird" "Evolution" "None")
    select opt in "${IDEOptions[@]}"
    do
        case $opt in
            "Mailspring")
                setupSnap
		snap install Mailspring
                break;
                ;;
            "Thunderbird")
                eval $packageManager -y install thunderbird
                break;
                ;;
            "Evolution")
                eval $packageManager -y install evolution
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

    echo 'Which Music Client Would you Like to Install?: '
    ScreenShotToolOptions=("Spotify" "Pithos (Pandora)" "None")
    select opt in "${ScreenShotToolOptions[@]}"
    do
        case $opt in
            "Spotify")
		setupSnap
		snap install spotify
                break;
                ;;
            "Pithos (Pandora)")
                eval $packageManager -y install pithos
                break;
                ;;
            "None")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    echo
    
    read -p "Would you like to install Microsft Teams? (Y/N) "
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
	if [ $linuxDistro == "Debian" ] ; then
		curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list'
		apt update
		apt install teams
	elif [ $linuxDistro == "Fedora" ] ; then
		rpm --import https://packages.microsoft.com/keys/microsoft.asc
		sh -c 'echo -e "[teams]\nname=teams\nbaseurl=https://packages.microsoft.com/yumrepos/ms-teams\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/teams.repo' 
		yum check-update
		yum install teams
	elif [ $linuxDistro == "openSUSE" ] ; then
		rpm --import https://packages.microsoft.com/keys/microsoft.asc
		sh -c 'echo -e "[teams]\nname=teams\nbaseurl=https://packages.microsoft.com/yumrepos/ms-teams\nenabled=1\nautorefresh=1\nkeeppackages=0\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/teams.repo'
		zypper refresh
		zypper install teams
	fi
    fi
    echo

    echo 'Which RDP Client Would you Like to Install?: '
    RDPClientOptions=("Remmina" "FreeRDP" "None")
    select opt in "${RDPClientOptions[@]}"
    do
        case $opt in
            "Remmina")
                getComputerInformation
                localRDPFileName=/home/$USER/Desktop/$computerName-Local.rdp
                remoteRDPFileName=/home/$USER/Desktop/$computerName-Remote.rdp
                if [ $linuxDistro == "Debian" ] ; then
                    localRDPFileName=~/Desktop/$computerName-Local.rdp
                    remoteRDPFileName=~/Desktop/$computerName-Remote.rdp
                fi
                eval $packageManager -y install remmina remmina-plugin-rdp
                echo -e "full address:s:$computerName" > $remoteRDPFileName
                echo -e "gatewayhostname:s:$gateway" >> $remoteRDPFileName
                echo -e "promptcredentialonce:i:1" >> $remoteRDPFileName
                echo -e "prompt for credentials:i:1" >> $remoteRDPFileName

                echo -e "full address:s:$computerName" > $localRDPFileName
                echo -e "promptcredentialonce:i:1" >> $localRDPFileName
                echo -e "prompt for credentials:i:1" >> $localRDPFileName
                break;
                ;;
            "FreeRDP")
                getComputerInformation
                eval $packageManager -y install freerdp2-x11
                eval $packageManager -y install freerdp
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
    
    read -p "Would you like to turn on numlock? (Y/N) "
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
	    eval $packageManager -y install numlockx
	    numlockx on
    fi

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
