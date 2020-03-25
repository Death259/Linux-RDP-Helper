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
while true
do
	action=$(yad --center --width 400 --title "Connect via RDP" \
	    --window-icon="gtk-connect" \
	    --form \
	    --field="Server" "$Server" \
	    --field="Port" "$Port" \
	    --field="Remote Gateway" "$Gateway" \
	    --field="Username" "$Username" \
	    --field="Domain" "$Domain" \
	    --field="Compression Level":CBE "0!1!2" \
	    --field="BPP":CBE "32!24!16" \
	    --field="Multi Monitor":CHK true \
	    --field="Fullscreen":CHK true \
	    --field="Redirect Clipboard":CHK true \
	    --field="Show Theme":CHK true \
	    --field="Show Wallpaper":CHK true \
	    --field="Auto Reconnect":CHK true \
	    --button="gtk-connect:0" --button="gtk-close:1")
	ret=$?


	[[ $ret -eq 1 ]] && exit 0

	Server=$(echo $action 		| awk -F '|' '{ print $1 }')
	Port=$(echo $action 		| awk -F '|' '{ print $2 }')
	Gateway=$(echo $action 		| awk -F '|' '{ print $3 }')
	Username=$(echo $action 	| awk -F '|' '{ print $4 }')
	Domain=$(echo $action 		| awk -F '|' '{ print $5 }')
	BPP=$(echo $action 		| awk -F '|' '{ print $6 }')
	CompressionLevel=$(echo $action 		| awk -F '|' '{ print $7 }')
	MultiMonitor=$(echo $action 	| awk -F '|' '{ print $8 }')
	Fullscreen=$(echo $action 	| awk -F '|' '{ print $9 }')
	RedirectClipboard=$(echo $action 	| awk -F '|' '{ print $10 }')
	ShowTheme=$(echo $action 	| awk -F '|' '{ print $11 }')
	ShowWallpaper=$(echo $action 	| awk -F '|' '{ print $12 }')
	AutoReconnect=$(echo $action 	| awk -F '|' '{ print $13 }')


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
	if [ -n "$CompressionLevel" ] ; then
	    xfreerdpCommand="$xfreerdpCommand /compression /compression-level:$CompressionLevel"
	fi
	if [ "$MultiMonitor" = "TRUE" ] ; then
	    xfreerdpCommand="$xfreerdpCommand /multimon"
	fi
	if [ "$Fullscreen" = "TRUE" ] ; then
	    xfreerdpCommand="$xfreerdpCommand /f"
	fi
	if [ "$RedirectClipboard" = "TRUE" ] ; then
	    xfreerdpCommand="$xfreerdpCommand +clipboard"
	fi
	if [ "$ShowTheme" != "TRUE" ] ; then
	    xfreerdpCommand="$xfreerdpCommand -themes"
	fi
	if [ "$ShowWallpaper"  != "TRUE" ] ; then
	    xfreerdpCommand="$xfreerdpCommand -wallpaper"
	fi
	if [ "$AutoReconnect"  = "TRUE" ] ; then
	    xfreerdpCommand="$xfreerdpCommand /auto-reconnect"
	fi

	eval "$xfreerdpCommand"
	#xfreerdp /v:"$Server" /port:$Port /g:"$Gateway" +clipboard /multimon /u:"$Username"
done
