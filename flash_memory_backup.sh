echo "> Flash Memory BackUp..."
echo "> The backup time is about 2-30 minutes"
echo "> Please make sure that the remaining memory space is enough (more than 20GB...)"
echo "> Start backing up the partition..."
echo "> Please do not interrupt..."
echo "-------------------------------------------------------"
sleep 3
#文件位置初始化
model=$(getprop ro.product.model)
serial_no=$(getprop ro.serialno)
date_str=$(date "+%Y%m%d")
dir_name="/sdcard/${model}_${serial_no}_${date_str}"
if [ ! -d "$dir_name" ]; then
    mkdir -p "$dir_name"
else
    rm -rf "$dir_name/*"
fi
if [ ! -d "$dir_name/images" ]; then
    mkdir "$dir_name/images"
fi
echo "" >> "$dir_name/fastboot.sh"
chmod +x "$dir_name/fastboot.sh"
# 过滤分区列表
exclude_partitions=(
"userdata"
"mmcblk0"
"sda"
"backup"
"sdb"
"sdc"
"sdd"
"sde"
"sdf"
"sdg"
)
fastboot_cmd=""
# 获取分区信息
all_partitions=$(ls /dev/block/bootdevice/by-name/)
for partition in ${all_partitions}
do
    rs="No" 
    for exclude_partition in ${exclude_partitions[@]}
    do
        if [[ "$exclude_partition" == "$partition" ]]; then
            rs="Yes"
            break
        fi
    done
    if [[ "Yes" == "$rs" ]]; then
        continue
    fi
    echo "> Backup [$partition] partition"
    dd if="/dev/block/bootdevice/by-name/$partition" of="$dir_name/images/$partition.img"
    echo ""
    
    fastboot_cmd="${fastboot_cmd}fastboot flash $partition ./images/$partition.img\n"
done
# 输出fastboot命令至文件
echo "$fastboot_cmd" > "$dir_name/fastboot.bat"
fastboot_cmd="# !/usr/bin/env bash\n# encoding: utf-8.0\n\n$fastboot_cmd"
echo "$fastboot_cmd" > "$dir_name/fastboot.sh"
# 信息提示
echo "-------------------------------------------------------"
echo "> After the partition backup is completed, all the backup partition images are in the $dir_name directory..."
echo "> Please put your phone into fastboot mode and flash fastboot.bat/fastboot.sh on your computer"
echo "> Modified by @tiangesec.org.cn"
echo "> Original author: Ku'an @Rannki"
exit 0