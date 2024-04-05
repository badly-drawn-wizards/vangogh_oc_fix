#!/bin/bash
if sudo touch /usr/testfileforvangoghocfix 2>/dev/null
    then
        sudo rm /usr/testfileforvangoghocfix
        READONLY=false
        echo Read only is disabled, proceeding.
    else
        READONLY=true
        sudo steamos-readonly disable
        echo Read only is enabled, temporarily disabling.
fi
read -p "Desired cpu max clock speed (eg 3800): " clock
UNAME=$(uname -r)
if [[ $UNAME == 6.1.52-valve16-1-neptune-61 ]]
    then
        echo Already have current kernel in source code, installing!
        make build && sudo make install && sudo make install-conf MODULE_FREQ=$clock
        sudo cp ./vangogh_oc_fix.service /etc/systemd/system/
        sudo systemctl enable --now vangogh_oc_fix
    else
        echo No kernel sources found. Downloading current kernel from steamos mirror.
        cd linux-header-extract
        ./get.sh
        make linux-pkg-prepare
        ln -s linux-pkg/build .
        make linux-pkg-prepare
        make extract-headers
        cd ..
        echo Installing!
        make build && sudo make install && sudo make install-conf MODULE_FREQ=$clock
        sudo cp ./vangogh_oc_fix.service /etc/systemd/system/
        sudo systemctl enable --now vangogh_oc_fix
fi
if [[ $READONLY == true ]]
    echo Re-enabling read only.
    then sudo steamos-readonly enable
fi
