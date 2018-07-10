#!/bin/bash
sudo apt-get -y update && sudo apt-get -y upgrade
sudo dpkg-reconfigure tzdata

sudo apt-get -y install shutter 
sudo apt-get -y install clamav
sudo apt-get -y install clamtk
sudo apt-get -y install numlockx
numlockx on
sudo ufw enable
pacmd set-card-profile 2 output:iec958-stereo


#echo "Installing FreeRDP..."
#sudo apt-get -qq install freerdp-x11 yad zenity
sudo apt-get -y install freerdp2-x11
echo "What is the username?"
read -r username
echo "What is the UPN?"
read -r UPN
echo "What is the Domain?"
read -r domain
echo "What is the gateway?"
read -r gateway
echo "What is the computer name?"
read -r computerName

#echo "Installing Remmina and Setting up a RDP Connection..."
#sudo apt-get -qq update
#sudo apt-get -qq install remmina remmina-plugin-rdp
#echo -e "full address:s:$computerName" > ~/Desktop/$computerName.rdp
#echo -e "gatewayhostname:s:$gateway" >> ~/Desktop/$computerName.rdp
#echo -e "promptcredentialonce:i:1" >> ~/Desktop/$computerName.rdp
#echo -e "prompt for credentials:i:1" >> ~/Desktop/$computerName.rdp

echo -e "#!/bin/bash" > ~/Desktop/$computerName-Local.sh
echo -e "xfreerdp /v:$computerName +clipboard /multimon /u:\"$domain\\$username\" /audio-mode:0" >> ~/Desktop/$computerName-Local.sh
chmod +x ~/Desktop/$computerName-Local.sh

echo -e "#!/bin/bash" > ~/Desktop/$computerName-Remote.sh
echo -e "xfreerdp /v:$computerName +clipboard /multimon /u:\"$username@$UPN\" /g:\"$gateway\" /audio-mode:0" >> ~/Desktop/$computerName-Remote.sh
chmod +x ~/Desktop/$computerName-Remote.sh

while [[ -z "$computer2" ]]
do
    read -p "Would you like to add another computer? (Y/N) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "What is the computer name?"
        read -r computer2
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
