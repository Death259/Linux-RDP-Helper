#!/bin/bash
if [ -n "$(type -t yum)" ] ; then
    linuxDistro="Fedora"
    packageManager="yum"
elif [ -n "$(type -t apt-get)" ] ; then
    linuxDistro="Debian"
    packageManager="apt-get"
fi

if [ -z "$(type -t xfreerdp)" ] ; then
    eval sudo $packageManager -y install freerdp2-x11
    eval sudo $packageManager -y install freerdp
fi

#yad --center --title "Test"

#hostname /v:server
#port /port:number
#width /w:width
#height /h:height
#fullscreen /f
#color depth /bpp:depth
#domain /d:domain
#gateway /g:gateway[:port]
#user /u:[domain\]user or user[@domain]

action=$(yad --center --width 300 --title "Connect via RDP" \
    --window-icon="gtk-connect" \
    --form \
    --field="Server" $Server "server.website.com" \
    --field="Port" $Port "3389" \
    --field="Remote Gateway" $Gateway "remote.website.com" \
    --field="Username" $Username "Username" \
    --field="Multi Monitor?":CHK $MultiMonitor true \
    --field="Fullscreen":CHK $Fullscreen true \
    --button="gtk-connect:0" --button="gtk-close:1" )
ret=$?

[[ $ret -eq 1 ]] && exit 0

Server=$(echo $action | awk -F '|' '{ print $1 }')
Port=$(echo $action | awk -F '|' '{ print $2 }')
Gateway=$(echo $action | awk -F '|' '{ print $3 }')
Username=$(echo $action | awk -F '|' '{ print $4 }')
MultiMonitor=$(echo $action | awk -F '|' '{ print $5 }')
Fullscreen=$(echo $action | awk -F '|' '{ print $6 }')

xfreerdp /v:"$Server" /port:$Port /g:"$Gateway" +clipboard /multimon /u:"$Username"
