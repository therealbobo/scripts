#! /bin/bash


USER_STORAGE="/storage/emulated/0"
BACKUPDIR="$HOME/Documents/backups"

mkdir -p "$BACKUPDIR"

DIRS=
DATE=$(date +%4Y%m%d)
DEST="${BACKUPDIR}/$DATE"
adb shell rm -r "/storage/emulated/0/DCIM/.thumbnails"
while read DIR; do
	adb pull -a "${USER_STORAGE}/$DIR" "$DEST"
done < <(adb shell ls $USER_STORAGE | grep -v Android)
cd $BACKUPDIR
tar -czf $BACKUPDIR/${DATE}.tar.gz -C $BACKUPDIR/${DATE} .
rm -r $BACKUPDIR/$DATE
