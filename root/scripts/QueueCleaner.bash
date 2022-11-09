#!/usr/bin/env bash
scriptVersion="1.0.007"

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

log () {
  m_time=`date "+%F %T"`
  echo $m_time" :: QueueCleaner :: $scriptVersion :: "$1
}

# auto-clean up log file to reduce space usage
if [ -f "/config/logs/QueueCleaner.txt" ]; then
	find /config/logs -type f -name "QueueCleaner.txt" -size +1024k -delete
fi

touch "/config/logs/QueueCleaner.txt"
chmod 666 "/config/logs/QueueCleaner.txt"
exec &> >(tee -a "/config/logs/QueueCleaner.txt")

CleanerProcess () {
  arrQueueData="$(curl -s "$arrUrl/api/v3/queue?page=1&pagesize=200&sortDirection=descending&sortKey=progress&includeUnknownSeriesItems=true&apikey=${arrApiKey}" | jq -r .records[])"
  arrQueueIds=$(echo "$arrQueueData" | jq -r 'select(.status=="completed") | select(.trackedDownloadStatus=="warning") | .id')
  arrQueueIdsCount=$(echo "$arrQueueData" | jq -r 'select(.status=="completed") | select(.trackedDownloadStatus=="warning") | .id' | wc -l)
  if [ $arrQueueIdsCount -eq 0 ]; then
    log "No items in queue to clean up..."
  else
	  for queueId in $(echo $arrQueueIds); do
      arrQueueItemData="$(echo "$arrQueueData" | jq -r "select(.id==$queueId)")"
      arrQueueItemTitle="$(echo "$arrQueueItemData" | jq -r .title)"
      arrEpisodeId="$(echo "$arrQueueItemData" | jq -r .episodeId)"
      arrEpisodeData="$(curl -s "$arrUrl/api/v3/episode/$arrEpisodeId?apikey=${arrApiKey}")"
      arrEpisodeTitle="$(echo "$arrEpisodeData" | jq -r .title)"
      arrEpisodeSeriesId="$(echo "$arrEpisodeData" | jq -r .seriesId)"
      if [ "$arrEpisodeTitle" == "TBA" ]; then
        log "ERROR :: Episode title is \"$arrEpisodeTitle\" and prevents auto-import, refreshing series..."
        refreshSeries=$(curl -s "$arrUrl/api/v3/command" -X POST -H 'Content-Type: application/json' -H "X-Api-Key: $arrApiKey" --data-raw "{\"name\":\"RefreshSeries\",\"seriesId\":$arrEpisodeSeriesId}")
        continue
      else
        log "Removing Failed Queue Item ID: $queueId ($arrQueueItemTitle) from Sonarr..."
        curl -sX DELETE "$arrUrl/api/v3/queue/$queueId?removeFromClient=true&blocklist=true&apikey=${arrApiKey}"
      fi
	  done
  fi
}

CleanerProcess

exit
