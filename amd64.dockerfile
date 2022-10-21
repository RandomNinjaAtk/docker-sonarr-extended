FROM linuxserver/sonarr:develop
LABEL maintainer="RandomNinjaAtk"

ENV SMA_PATH /usr/local/sma
ENV UPDATE_SMA FALSE
ENV SMA_APP Sonarr

RUN \
	echo "************ install packages ************" && \
	apt-get update && \
	apt-get install -y \
		git \
		wget \
		python3 \
		python3-pip \
		ffmpeg \
		mkvtoolnix \
		zip \
		unzip \
		tidy && \
	echo "************ install python packages ************" && \
	python3 -m pip install --no-cache-dir -U \
		yq \
		yt-dlp && \
	echo "************ setup SMA ************" && \
	echo "************ setup directory ************" && \
	mkdir -p ${SMA_PATH} && \
	echo "************ download repo ************" && \
	git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
	mkdir -p ${SMA_PATH}/config && \
	echo "************ create logging file ************" && \
	mkdir -p ${SMA_PATH}/config && \
	touch ${SMA_PATH}/config/sma.log && \
	chgrp users ${SMA_PATH}/config/sma.log && \
	chmod g+w ${SMA_PATH}/config/sma.log && \
	echo "************ install pip dependencies ************" && \
	python3 -m pip install --user --upgrade pip && \	
	pip3 install -r ${SMA_PATH}/setup/requirements.txt && \
	echo "************ install recyclarr ************" && \
	mkdir -p /recyclarr && \
	wget "https://github.com/recyclarr/recyclarr/releases/latest/download/recyclarr-linux-x64.zip" -O "/recyclarr/recyclarr.zip" && \
	unzip -o /recyclarr/recyclarr.zip -d /recyclarr && \
	chmod 777 /recyclarr/recyclarr
	
WORKDIR /config

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
