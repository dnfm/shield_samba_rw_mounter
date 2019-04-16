#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# REPLACE THESE VALUES WITH ONES THAT MAKE SENSE FOR YOUR SETUP.
SAMBA_USER=username
SAMBA_PASSWORD=password
CIFS_HOST=host/ip
SHARE_NAME=sharename

mkdir -p /data/media/0/media
mkdir -p /storage/emulated/0/media

# This script will be executed in late_start service mode
# More info in the main Magisk thread
echo -n "Setting SELinux to permissive... "

until [ "$permissive" == "1" ]; do
    setenforce Permissive

    if [ "$(getenforce)" == "Permissive" ]; then
        permissive=1
    else
        sleep 2
    fi
done

echo "done."
echo -n "Mounting samba share... "

until [ "$samba_mounted" == "1" ]; do
    /sbin/su --mount-master -c /data/adb/magisk/busybox mount -o username=$SAMBA_USER,password=$SAMBA_PASSWORD,rw,iocharset=utf8,noperm,dir_mode=0777,file_mode=0777 -t cifs //$CIFS_HOST/$SHARE_NAME /data/media/0/media

    if grep -q retroarch /proc/mounts; then
        samba_mounted=1
    else
        sleep 2
    fi
done

/sbin/su --mount-master -c /data/adb/magisk/busybox mount --bind /data/media/0/media /storage/emulated/0/media

echo "done."
echo -n "Setting SELinux back to enforcing... "

until [ "$enforcing" == "1" ]; do
    setenforce Enforcing

    if [ "$(getenforce)" == "Enforcing" ]; then
        enforcing=1
    else
        sleep 2
    fi
done

echo "done."
