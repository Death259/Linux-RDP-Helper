#!/bin/bash
if [ -n "$(type -t yum)" ] ; then
    linuxDistro="Fedora"
    packageManager="yum"
    eval sudo $packageManager -y -qq install freerdp yad
elif [ -n "$(type -t apt-get)" ] ; then
    linuxDistro="Debian"
    packageManager="apt-get"
    eval sudo $packageManager -y -qq install freerdp2-x11 yad
fi

#if [ -z "$(type -t xfreerdp)" ] ; then
#    eval sudo $packageManager -qq install freerdp2-x11 yad
#    eval sudo $packageManager -qq install freerdp yad
#fi

action=$(yad --center --width 400 --title "Connect via RDP" \
    --window-icon="gtk-connect" \
    --form \
    --field="Server" "" \
    --field="Port" "" \
    --field="Remote Gateway" "" \
    --field="Username" "" \
    --field="Domain" "" \
    --field="BPP":CBE "32!24!16" \
    --field="Multi Monitor":CHK true \
    --field="Fullscreen":CHK true \
    --field="Redirect Clipboard":CHK true \
    --button="gtk-connect:0" --button="gtk-close:1")
ret=$?

[[ $ret -eq 1 ]] && exit 0

Server=$(echo $action 		| awk -F '|' '{ print $1 }')
Port=$(echo $action 		| awk -F '|' '{ print $2 }')
Gateway=$(echo $action 		| awk -F '|' '{ print $3 }')
Username=$(echo $action 	| awk -F '|' '{ print $4 }')
Domain=$(echo $action 		| awk -F '|' '{ print $5 }')
BPP=$(echo $action 		| awk -F '|' '{ print $6 }')
MultiMonitor=$(echo $action 	| awk -F '|' '{ print $7 }')
Fullscreen=$(echo $action 	| awk -F '|' '{ print $8 }')
RedirectClipboard=$(echo $action 	| awk -F '|' '{ print $9 }')

xfreerdpCommand="xfreerdp "
if [ -n "$Server" ] ; then
    xfreerdpCommand="$xfreerdpCommand /v:\"$Server\""
fi
if [ -n "$Port" ] ; then
    xfreerdpCommand="$xfreerdpCommand /port:$Port"
fi
if [ -n "$Gateway" ] ; then
    xfreerdpCommand="$xfreerdpCommand /g:\"$Gateway\""
fi
if [ -n "$Username" ] ; then
    xfreerdpCommand="$xfreerdpCommand /u:\"$Username\""
fi
if [ -n "$Domain" ] ; then
    xfreerdpCommand="$xfreerdpCommand /d:\"$Domain\""
fi
if [ -n "$Bpp" ] ; then
    xfreerdpCommand="$xfreerdpCommand /bpp:$Bpp"
fi
if [ $MultiMonitor ] ; then
    xfreerdpCommand="$xfreerdpCommand /multimon"
fi
if [ $Fullscreen ] ; then
    xfreerdpCommand="$xfreerdpCommand /f"
fi
if [ $RedirectClipboard ] ; then
    xfreerdpCommand="$xfreerdpCommand +clipboard"
fi

eval "$xfreerdpCommand"
#xfreerdp /v:"$Server" /port:$Port /g:"$Gateway" +clipboard /multimon /u:"$Username"
