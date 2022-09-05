#!/usr/bin/env bash
scriptVersion="1.0.000"

if [ -z "$arrUrl" ] || [ -z "$arrApiKey" ]; then
  arrUrlBase="$(cat /config/config.xml | xq | jq -r .Config.UrlBase)"
  if [ "$arrUrlBase" == "null" ]; then
    arrUrlBase=""
  else
    arrUrlBase="/$(echo "$arrUrlBase" | sed "s/\///g")"
  fi
  arrApiKey="$(cat /config/config.xml | xq | jq -r .Config.ApiKey)"
  arrPort="$(cat /config/config.xml | xq | jq -r .Config.Port)"
  arrUrl="http://127.0.0.1:${arrPort}${arrUrlBase}"
fi

# auto-clean up log file to reduce space usage
if [ -f "/config/logs/AutoConfig.txt" ]; then
	find /config/logs -type f -name "AutoConfig.txt" -size +1024k -delete
fi

exec &>> "/config/logs/AutoConfig.txt"
chmod 666 "/config/logs/AutoConfig.txt"

log () {
  m_time=`date "+%F %T"`
  echo $m_time" :: AutoConfig :: "$1
}

log "Getting Trash Guide Recommended Sonarr Naming..."
standardNaming="$(curl -s https://raw.githubusercontent.com/TRaSH-/Guides/master/docs/Sonarr/Sonarr-recommended-naming-scheme.md | grep "{Series" | head -n 1)"
dailyNaming="$(curl -s https://raw.githubusercontent.com/TRaSH-/Guides/master/docs/Sonarr/Sonarr-recommended-naming-scheme.md | grep "{Series" | grep "{Air-Date}")"
animeNaming="$(curl -s https://raw.githubusercontent.com/TRaSH-/Guides/master/docs/Sonarr/Sonarr-recommended-naming-scheme.md | grep "{Series" | grep "{absolute")"
seriesNaming="$(curl -s https://raw.githubusercontent.com/TRaSH-/Guides/master/docs/Sonarr/Sonarr-recommended-naming-scheme.md | grep "{Series" | head -n4 | tail -n1)"

log "Updating Sonarr File Naming..."
updateArr=$(curl -s "$arrUrl/api/v3/config/naming" -X PUT -H "Content-Type: application/json" -H "X-Api-Key: $arrApiKey" --data-raw '{
	\"renameEpisodes\":true,
	\"replaceIllegalCharacters\":true,
	\"multiEpisodeStyle\":4,
	\"standardEpisodeFormat\":\"$standardNaming\",
	\"dailyEpisodeFormat\":\"$dailyNaming\",
	\"animeEpisodeFormat\":\"$animeNaming\",
	\"seriesFolderFormat\":\"$seriesNaming\",
	\"seasonFolderFormat\":\"Season {season:00}\",
	\"specialsFolderFormat\":\"Season {season:00}\",
	\"includeSeriesTitle\":false,
	\"includeEpisodeTitle\":false,
	\"includeQuality\":false,
	\"replaceSpaces\":true,
	\"separator\":\" - \",
	\"numberStyle\":\"S{season:00}E{episode:00}\",
	\"id\":1
	}')    
log "Complete"

log "Updating Sonrr Media Management..."
updateArr=$(curl -s "$arrUrl/api/v3/config/mediamanagement" -X PUT -H "Content-Type: application/json" -H "X-Api-Key: $arrApiKey" --data-raw '{"autoUnmonitorPreviouslyDownloadedEpisodes":false,
  "recycleBin":"",
  "recycleBinCleanupDays":7,
  "downloadPropersAndRepacks":"doNotPrefer",
  "createEmptySeriesFolders":false,
  "deleteEmptyFolders":true,
  "fileDate":"none",
  "rescanAfterRefresh":"always",
  "setPermissionsLinux":true,
  "chmodFolder":"777",
  "chownGroup":"abc",
  "episodeTitleRequired":"always",
  "skipFreeSpaceCheckWhenImporting":false,
  "minimumFreeSpaceWhenImporting":100,
  "copyUsingHardlinks":true,
  "importExtraFiles":true,
  "extraFileExtensions":"srt",
  "enableMediaInfo":true,"id":1}')
log "Complete"

log "Updating Sonarr Medata Settings..."
updateArr=$(curl -s "$arrUrl/api/v3/metadata/1?" -X PUT -H "Content-Type: application/json" -H "X-Api-Key: $arrApiKey" --data-raw '{"enable":true,"name":"Kodi (XBMC) / Emby","fields":[{"name":"seriesMetadata","value":true},{"name":"seriesMetadataUrl","value":false},{"name":"episodeMetadata","value":true},{"name":"seriesImages","value":true},{"name":"seasonImages","value":true},{"name":"episodeImages","value":true}],"implementationName":"Kodi (XBMC) / Emby","implementation":"XbmcMetadata","configContract":"XbmcMetadataSettings","infoLink":"https://wiki.servarr.com/sonarr/supported#xbmcmetadata","tags":[],"id":1}'

log "Configuring Sonarr Custom Scripts"
if curl -s "$arrUrl/api/v3/notification" -H "X-Api-Key: ${arrApiKey}" | jq -r .[].name | grep "PlexNotify.bash" | read; then
	log "PlexNotify.bash already added to Radarr custom scripts"
else
	log "Adding PlexNotify.bash to Sonarr custom scripts"
  # Send a command to check file path, to prevent error with adding...
	updateArr=$(curl -s "$arrUrl/api/v3/filesystem?path=%2Fconfig%2Fextended%2Fscripts%2FPlexNotify.bash&allowFoldersWithoutTrailingSlashes=true&includeFiles=true" -H "X-Api-Key: ${arrApiKey}")
  
  # Add PlexNotify.bash
  updateArr=$(curl -s "$arrUrl/api/v3/notification?" -X POST -H "Content-Type: application/json" -H "X-Api-Key: ${arrApiKey}" --data-raw '{"onGrab":false,"onDownload":true,"onUpgrade":true,"onRename":true,"onSeriesDelete":true,"onEpisodeFileDelete":true,"onEpisodeFileDeleteForUpgrade":true,"onHealthIssue":false,"onApplicationUpdate":false,"supportsOnGrab":true,"supportsOnDownload":true,"supportsOnUpgrade":true,"supportsOnRename":true,"supportsOnSeriesDelete":true,"supportsOnEpisodeFileDelete":true,"supportsOnEpisodeFileDeleteForUpgrade":true,"supportsOnHealthIssue":true,"supportsOnApplicationUpdate":true,"includeHealthWarnings":false,"name":"PlexNotify.bash","fields":[{"name":"path","value":"/config/extended/scripts/PlexNotify.bash"},{"name":"arguments"}],"implementationName":"Custom Script","implementation":"CustomScript","configContract":"CustomScriptSettings","infoLink":"https://wiki.servarr.com/sonarr/supported#customscript","message":{"message":"Testing will execute the script with the EventType set to Test, ensure your script handles this correctly","type":"warning"},"tags":[]}')
  log "Complete"
fi

exit
