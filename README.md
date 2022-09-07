# [RandomNinjaAtk/sonarr-extended](https://github.com/RandomNinjaAtk/docker-sonarr-extended)
[![Docker Build](https://img.shields.io/docker/cloud/automated/randomninjaatk/sonarr-extended?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sonarr-extended)
[![Docker Pulls](https://img.shields.io/docker/pulls/randomninjaatk/sonarr-extended?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sonarr-extended)
[![Docker Stars](https://img.shields.io/docker/stars/randomninjaatk/sonarr-extended?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sonarr-extended)
[![Docker Hub](https://img.shields.io/badge/Open%20On-DockerHub-blue?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sonarr-extended)

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/RandomNinjaAtk/unraid-templates/master/randomninjaatk/img/sonarr.png" width="200"></td>
    <td><img src="https://github.com/RandomNinjaAtk/docker-lidarr-extended/raw/main/.github/plus.png" width="100"></td>
    <td><img src="https://raw.githubusercontent.com/RandomNinjaAtk/unraid-templates/master/randomninjaatk/img/amtd.png" width="200"></td>
  </tr>
 </table>



### What is Sonarr Extended:

* Linuxserver.io Sonarr docker container (develop tag)
* Additional packages and scripts added to the container to provide additional functionality

Sonarr itself is not modified in any way, all changes that are pushed to Sonarr via public Sonarr API's. This is strictly Sonarr Develop branch

For more details, visit the [Wiki](https://github.com/RandomNinjaAtk/docker-sonarr-extended/wiki)

This containers base image is provided by: [linuxserver/sonarr](https://github.com/linuxserver/docker-sonarr)

## Features
* Downloading TV **Trailers** and **Extras** using online sources for use in popular applications (Plex): 
  * Connects to Sonarr to automatically download trailers for Movies in your existing library
  * Downloads videos using yt-dlp automatically
  * Names videos correctly to match Plex naming convention
* Auto Configure Sonarr with optimized settings
  * Optimized file/folder naming (based on trash guides)
  * Configures media management settings
  * Configures metadata settings
* Daily Series Episode Trimmer
  * Keep only the latest 14 episodes of a daily series
* Recyclarr built-in
  * Auto configures Release Profiles + Scores
  * Auto configures optimzed quality definitions
* Plex Notify Script
  * Reduce Plex scanning by notifying Plex the exact folder to scan
* Queue Cleaner Script
  * Automatically removes downloads that have a "warning" or "failed" status that will not auto-import into Sonarr, which enables Radarr to automatically re-search for the Title

### Plex Example
![](https://raw.githubusercontent.com/RandomNinjaAtk/docker-amtd/master/.github/amvtd-plex-example.jpg)

## Supported Architectures

The architectures supported by this image are:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| multi | ✅ | latest |
| x86-64 | ✅ | amd64 |
| arm64v8 | ✅ | arm64v8 |

## Version Tags

| Tag | Description |
| :----: | --- |
| latest | Sonarr Develop + Extended Scripts|

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8989` | The port for the Sonarr webinterface |
| `-v /config` | Database and sonarr configs |
| `-v /storage` | Location of TV and Downloads Library |
| `-e enableAutoConfig=true` | true = enabled :: Enables AutoConfig script to run after startup |
| `-e enableRecyclarr=true` | true = enabled :: Enables Recyclarr to run every 4 hours |
| `-e enableQueueCleaner=true` | true = enabled :: Enables QueueCleaner Script that automatically removes stuck downloads that cannot be automatically imported on a 15 minute interval |
| `-e enableExtras=true` | true = enabled :: Enables Extras script to run during download import process |
| `-e extrasType=all` | all or trailers :: all downloads all available videos (trailers, clips, featurette, etc...) :: trailers only downloads trailers |
| `-e extrasLanguages=en` | Set the primary desired language, if not found, fallback to next langauge in the list... (this is a "," separated list of ISO 639-1 language codes) |
| `-e extrasOfficialOnly=false` | true = enabled :: Skips extras that are not considered/marked as Official from TMDB site. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London, this is required for Sonarr |
| `-e UMASK_SET=022` | control permissions of files and directories created by Sonarr |

## Application Setup

Access the webui at `<your-ip>:8989`, for more information check out [Sonarr](https://sonarr.tv/).

## Docker Examples:
These examples are untested, but should work or at least give you a good starting point....

### docker

```
docker create \
  --name=sonarr-extended \
  -v /path/to/config/files:/config \
  -p 8989:8989 \
  -e TZ=America/New_York \
  -e PUID=1000 \
  -e PGID=1000 \
  -e enableAutoConfig=true \
  -e enableRecyclarr=true \
  -e enableQueueCleaner=true \
  -e enableExtras=true \
  -e extrasType=all \
  -e extrasLanguages=en \
  -e extrasOfficialOnly=false \
  -e plexUrl=http://x.x.x.x:32400 \
  -e plexToken=Token_Goes_Here \
  randomninjaatk/radarr-extended:latest
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
version: "2.1"
services:
  sonarr-extended:
    image: randomninjaatk/sonarr-extended:latest
    container_name: sonarr-extended
    volumes:
      - /path/to/config/files:/config
    environment:
      - TZ=America/New_York
      - PUID=1000
      - PGID=1000
      - enableAutoConfig=true
      - enableRecyclarr=true
      - enableQueueCleaner=true
      - enableExtras=true
      - extrasType=all
      - extrasLanguages=en
      - extrasOfficialOnly=false
      - plexUrl=http://x.x.x.x:32400
      - plexToken=Token_Goes_Here
    ports:
      - 8989:8989
    restart: unless-stopped
```

# Credits
- [ffmpeg](https://ffmpeg.org/)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [linuxserver/sonarr](https://github.com/linuxserver/docker-sonarr) Base docker image
- [Sonarr](https://sonarr.tv/)
- [The Movie Database](https://www.themoviedb.org/)
- [Recyclarr](https://github.com/recyclarr/recyclarr)
- Icons made by <a href="http://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
