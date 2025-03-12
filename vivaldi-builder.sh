#!/bin/sh

APP=vivaldi

# TEMPORARY DIRECTORY
mkdir -p tmp
cd ./tmp || exit 1

# DOWNLOAD APPIMAGETOOL
if ! test -f ./appimagetool; then
	wget -q https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
	chmod a+x ./appimagetool
fi

# CREATE VIVALDI BROWSER APPIMAGES

_create_vivaldi_appimage(){
	if wget --version | head -1 | grep -q ' 1.'; then
		wget -q --no-verbose --show-progress --progress=bar "https://repo.vivaldi.com/snapshot/deb/pool/main/$(curl -Ls https://repo.vivaldi.com/snapshot/deb/pool/main/ | grep -i "$APP-$CHANNEL" | grep amd64 | tail -1 | grep -o -P '(?<=href=").*(?=">vivaldi)')"
	else
		wget "https://repo.vivaldi.com/snapshot/deb/pool/main/$(curl -Ls https://repo.vivaldi.com/snapshot/deb/pool/main/ | grep -i "$APP-$CHANNEL" | grep amd64 | tail -1 | grep -o -P '(?<=href=").*(?=">vivaldi)')"
	fi
	ar x ./*.deb
	tar xf ./data.tar.xz
	mkdir "$APP".AppDir
	mv ./opt/*/* ./"$APP".AppDir/
	mv ./usr/share/applications/*.desktop ./"$APP".AppDir/
	if [ "$CHANNEL" = "stable" ]; then
		cp ./"$APP".AppDir/*128.png ./"$APP".AppDir/"$APP".png
	else
		cp ./"$APP".AppDir/*128.png ./"$APP".AppDir/"$APP"-"$CHANNEL".png
	fi
	tar xf ./control.tar.xz
	VERSION=$(cat control | grep Version | cut -c 10-)

	cat <<-'HEREDOC' >> ./"$APP".AppDir/AppRun
	#!/bin/sh
	APP=CHROME
	HERE="$(dirname "$(readlink -f "${0}")")"
	export UNION_PRELOAD="${HERE}"
	export LD_LIBRARY_PATH="${HERE}"/lib/:"${LD_LIBRARY_PATH}"
	exec "${HERE}"/$APP "$@" &&
	exec ${HERE}/update-ffmpeg --user 2> /dev/null
	HEREDOC
	chmod a+x ./"$APP".AppDir/AppRun
	if [ "$CHANNEL" = "stable" ]; then
		sed -i "s/CHROME/$APP/g" ./"$APP".AppDir/AppRun
	else
		sed -i "s/CHROME/$APP-$CHANNEL/g" ./"$APP".AppDir/AppRun
	fi

	ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 \
	-u "gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|Vivaldi-appimage|continuous|*-$CHANNEL-*x86_64.AppImage.zsync" \
	./"$APP".AppDir Vivaldi-"$CHANNEL"-"$VERSION"-x86_64.AppImage || exit 1
}

CHANNEL="stable"
mkdir -p "$CHANNEL" && cp ./appimagetool ./"$CHANNEL"/appimagetool && cd "$CHANNEL" || exit 1
_create_vivaldi_appimage
cd ..
mv ./"$CHANNEL"/*.AppImage* ./

CHANNEL="snapshot"
mkdir -p "$CHANNEL" && cp ./appimagetool ./"$CHANNEL"/appimagetool && cd "$CHANNEL" || exit 1
_create_vivaldi_appimage
cd ..
mv ./"$CHANNEL"/*.AppImage* ./

cd ..
mv ./tmp/*.AppImage* ./
