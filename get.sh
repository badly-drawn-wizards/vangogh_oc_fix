export UNAME=$(uname -r)
export VERSION=$(echo $(UNAME) |awk -F"-" '{print $NF}')
CUT=${UNAME/-/.}
CUT=${CUT/-neptune-$VERSION/}
curl -L https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/jupiter-main/linux-neptune-${VERSION}-${CUT}.src.tar.gz -O - | tar -xz
mv linux-neptune-* linux-pkg
