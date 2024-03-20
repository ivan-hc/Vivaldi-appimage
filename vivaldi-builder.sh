#!/bin/sh

#------------------- VIVALDI STABLE ------------------------
APP=vivaldi-stable
VERSION=$(wget -q https://repo.vivaldi.com/snapshot/deb/pool/main/ -O - | grep $APP | grep amd64 | tail -1 | grep -o -P '(?<=href="vivaldi-stable_).*(?=_amd64.deb">vivaldi)')
URL=$(echo "https://repo.vivaldi.com/snapshot/deb/pool/main/$(wget -q https://repo.vivaldi.com/snapshot/deb/pool/main/ -O - | grep $APP | grep amd64 | tail -1 | grep -o -P '(?<=href=").*(?=">vivaldi)')")

mkdir tmp
cd ./tmp
wget -q $(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | grep -v zsync | grep -i continuous | grep -i appimagetool | grep -i x86_64 | grep browser_download_url | cut -d '"' -f 4 | head -1) -O appimagetool
chmod a+x ./appimagetool

wget $URL
ar x ./*.deb
tar xf ./data.tar.xz
mkdir $APP.AppDir
mv ./opt/*/* ./$APP.AppDir/
mv ./usr/share/applications/*.desktop ./$APP.AppDir/
cp ./$APP.AppDir/*128.png ./$APP.AppDir/vivaldi.png

cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_LIBRARY_PATH=/lib/:/lib64/:/lib/x86_64-linux-gnu/:/usr/lib/:"${HERE}"/:"${HERE}"/lib/:LD_LIBRARY_PATH
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
exec ${HERE}/vivaldi "$@" &&
exec ${HERE}/update-ffmpeg --user 2> /dev/null
EOF
chmod a+x ./$APP.AppDir/AppRun
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./$APP.AppDir
cd ..
mv ./tmp/*AppImage ./Vivaldi-Stable-$VERSION-x86_64.AppImage

#------------------- VIVALDI SNAPSHOT ------------------------
APP=vivaldi-snapshot
VERSION=$(wget -q https://repo.vivaldi.com/snapshot/deb/pool/main/ -O - | grep $APP | grep amd64 | tail -1 | grep -o -P '(?<=href="vivaldi-snapshot_).*(?=_amd64.deb">vivaldi)')
URL=$(echo "https://repo.vivaldi.com/snapshot/deb/pool/main/$(wget -q https://repo.vivaldi.com/snapshot/deb/pool/main/ -O - | grep $APP | grep amd64 | tail -1 | grep -o -P '(?<=href=").*(?=">vivaldi)')")

mkdir tmp2
cd ./tmp2
wget -q $(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | grep -v zsync | grep -i continuous | grep -i appimagetool | grep -i x86_64 | grep browser_download_url | cut -d '"' -f 4 | head -1) -O appimagetool
chmod a+x ./appimagetool

wget $URL
ar x ./*.deb
tar xf ./data.tar.xz
mkdir $APP.AppDir
mv ./opt/*/* ./$APP.AppDir/
mv ./usr/share/applications/*.desktop ./$APP.AppDir/
cp ./$APP.AppDir/*128.png ./$APP.AppDir/$APP.png

cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_LIBRARY_PATH=/lib/:/lib64/:/lib/x86_64-linux-gnu/:/usr/lib/:"${HERE}"/:"${HERE}"/lib/:LD_LIBRARY_PATH
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
exec ${HERE}/vivaldi-snapshot "$@" &&
exec ${HERE}/update-ffmpeg --user 2> /dev/null
EOF
chmod a+x ./$APP.AppDir/AppRun
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./$APP.AppDir
cd ..
mv ./tmp2/*AppImage ./Vivaldi-Snapshot-$VERSION-x86_64.AppImage
