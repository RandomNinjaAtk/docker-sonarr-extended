#!/usr/bin/env bash
scriptVersion="1.0.2"
arrEventType="$sonarr_eventtype"

# auto-clean up log file to reduce space usage
if [ -f "/config/logs/SMA.txt" ]; then
	find /config/logs -type f -name "SMA.txt" -size +1024k -delete
fi

touch "/config/logs/SMA.txt"
chmod 666 "/config/logs/SMA.txt"
exec &> >(tee -a "/config/logs/SMA.txt")

log () {
    m_time=`date "+%F %T"`
    echo $m_time" :: SMA :: $scriptVersion :: "$1
}

if [ "$arrEventType" == "Test" ]; then
	log "Tested Successfully"
	exit
fi

Extras () {
    # Extras Script
    bash /config/extended/scripts/Extras.bash "$sonarr_series_id"
}

NotifyPlex () {
    # Process item with PlexNotify.bash if plexToken is configured
    if [ ! -z "$plexToken" ]; then
        # update plex
        log "$itemTitle :: Using PlexNotify.bash to update Plex...."
        bash /config/extended/scripts/PlexNotify.bash "$sonarr_series_path"
    fi
}

ProcessWithSma () {
    log "Processing :: $sonarr_episodefile_path"
    if python3 /usr/local/sma/manual.py --config "/config/extended/configs/sma.ini" -i "$sonarr_episodefile_path" -tvdb $sonarr_series_tvdbid -s $sonarr_episodefile_seasonnumber -e $sonarr_episodefile_episodenumbers -a; then
        sleep 0.01
        log "COMPLETE!"
        rm  /usr/local/sma/config/*log*
    else
        log "ERROR :: SMA Processing Error"
    fi
}

ProcessWithSma
Extras
NotifyPlex

exit
