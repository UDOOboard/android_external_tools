#!/system/bin/sh

node="/dev/block/mmcblk0"
part="${node}p"

part1start="513"   # boot
part1end="1024"

part2start="1025"  # recovery
part2end="1536"

part3start="1537"  # extended
part3end="67712"

part4start="67713" # data

part5size="1500M"  # system
part6size="512M"   # cache
part7size="20M"    # device
part8size="8M"     # misc
part9size="8M"     # vendor


function wait_boot
{
	while (true) {
		bootends=`getprop sys.boot_completed`
		if [ "x${bootends}" == "x1" ]
		  then
			break;
		fi
		sleep 5
	}
}

function start_install_app
{
	mkdir  /data/local/tmp/com.seco.emmcinstaller/
	cp -v eMMCinstaller.apk /data/local/tmp/com.seco.emmcinstaller/eMMCinstaller.apk
	
	chmod 755 /data/local/tmp/com.seco.emmcinstaller/
	chmod 644 /data/local/tmp/com.seco.emmcinstaller/eMMCinstaller.apk
	
	pm install -g -t -r "/data/local/tmp/com.seco.emmcinstaller/eMMCinstaller.apk"
	sleep 2
	am start -n com.seco.emmcinstaller/.MainActivity
}

function wait_start
{
	while (true) {
		readytostart=`getprop emmcInstallStart`
		if [ "x${readytostart}" == "x1" ]
		  then
			break;
		fi
		sleep 2
	}
}




function partition_android
{
        echo "Creating android partition..."
        setprop installation_progress "Creating android partition..."

        # destroy the partition table
        dd if=/dev/zero of=${node} bs=1024 count=1 >/dev/null 2>&1

        sleep 1
        echo -e "n\np\n1\n${part1start}\n${part1end}\n""n\np\n2\n${part2start}\n${part2end}\n""n\ne\n3\n${part3start}\n${part3end}\n\n""n\np\n${part4start}\n\n""n\n\n+${part5size}\n""n\n\n+${part6size}\n""n\n\n+${part7size}\n""n\n\n+${part8size}\n""n\n\n+${part9size}\n""w\n" | /system/bin/fdisk ${node} > /dev/null 2>&1 
	sync
        /system/bin/fdisk -l ${node} 
}

function format_android
{
    echo "Formatting partitions..."
    setprop installation_progress  "Formatting partitions..."
    sleep 2
    metadata_opt=""
    echo " ->  ${part}4 [data]"
    setprop installation_progress  "    ->  ${part}4 [data]"
    mke2fs -t ext4 ${metadata_opt} -F -Ldata ${part}4    >/dev/null 2>&1
    sleep 0.5
    echo " ->  ${part}5 [system]"
    setprop installation_progress  "    ->  ${part}5 [system]"
    mke2fs -t ext4 ${metadata_opt} -F -Lsystem ${part}5  >/dev/null 2>&1
    # sleep 0.5
    echo " ->  ${part}6 [cache]"
    setprop installation_progress  "    ->  ${part}6 [cache]"
    mke2fs -t ext4 ${metadata_opt} -F -Lcache ${part}6   >/dev/null 2>&1
    sleep 0.5
    echo " ->  ${part}7 [device]"
    setprop installation_progress  "    ->  ${part}7 [device]"
    mke2fs -t ext4 ${metadata_opt} -F -Ldevice ${part}7  >/dev/null 2>&1
    sleep 0.5
    echo " ->  ${part}8 [misc]"
    setprop installation_progress  "    ->  ${part}8 [misc]"
    mke2fs -t ext4 ${metadata_opt} -F -Lmisc ${part}8    >/dev/null 2>&1
    sleep 0.5
    echo " ->  ${part}9 [vendor]"
    setprop installation_progress  "    ->  ${part}9 [vendor]"
    mke2fs -t ext4 ${metadata_opt} -F -Lvendor ${part}9  >/dev/null 2>&1
    sleep 0.5
}

function flash_android
{
    echo "Flashing android images..."
    setprop installation_progress  "Flashing android images..."
    sleep 2
    dd if=/dev/zero of=${node} bs=1k  seek=512  count=1
    dd if=/dev/zero of=${node} bs=512 seek=1536 count=16 
    echo " ->  ${part}0 [u-boot.imx]"
    setprop installation_progress  "    ->  ${part}0 [u-boot.imx]"
    dd if=u-boot.imx of=${node} bs=1k seek=1 
    echo " ->  ${part}1 [boot]"
    setprop installation_progress  "    ->  ${part}1 [boot]"
    dd if=boot.img of=${part}1 bs=8k 
    echo " ->  ${part}2 [recovery]"
    setprop installation_progress  "    ->  ${part}2 [recovery]"
    dd if=recovery.img of=${part}2 bs=8k 
    echo " ->  ${part}5 [system]"
    setprop installation_progress  "    ->  ${part}5 [system]"
    busybox zcat system_raw.img.gz | dd of=${part}5 bs=16384k
    echo "Resizing ${part}5 ..."
    setprop installation_progress  "Resizing ${part}5 ..."
    fsck.f2fs -f ${part}5
    resize2fs ${part}5
}


cd /data/A62_Android60_installer

setprop installation_status 0
wait_boot
start_install_app
wait_start
setprop installation_status 1
partition_android
format_android
flash_android
setprop installation_status 3
echo "Done."
setprop installation_progress  "Done."

exit 0

