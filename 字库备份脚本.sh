#!/system/bin/sh

echo "> 闪存备份中..."
echo "> 备份时间约为 2-30 分钟"
echo "> 请确保剩余内存空间足够（20GB 以上）"
echo "> 即将开始备份分区..."
echo "> 请不要中断..."
echo "-------------------------------------------------------"
sleep 3

# 文件位置初始化
model=$(getprop ro.product.model)
serial_no=$(getprop ro.serialno)
date_str=$(date "+%Y%m%d")
dir_name="/sdcard/${model}_${serial_no}_${date_str}"

# 创建备份目录
if [ ! -d "$dir_name" ]; then
    mkdir -p "$dir_name"
else
    rm -rf "$dir_name/*"
fi
if [ ! -d "$dir_name/images" ]; then
    mkdir "$dir_name/images"
fi

# 创建 fastboot.sh 文件并赋予执行权限
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

    # 备份分区
    echo "> 正在备份 [$partition] 分区"
    dd if="/dev/block/bootdevice/by-name/$partition" of="$dir_name/images/$partition.img"
    echo ""
    
    # 生成 fastboot 命令
    fastboot_cmd="${fastboot_cmd}fastboot flash $partition ./images/$partition.img\n"
done

# 输出 fastboot 命令至文件
echo "$fastboot_cmd" > "$dir_name/fastboot.bat"
fastboot_cmd="# !/usr/bin/env bash\n# encoding: utf-8.0\n\n$fastboot_cmd"
echo "$fastboot_cmd" > "$dir_name/fastboot.sh"

# 信息提示
echo "-------------------------------------------------------"
echo "> 分区备份完成，所有备份的分区镜像存放在 $dir_name 目录下..."
echo "> 请将手机进入 fastboot 模式，然后在电脑上执行 fastboot.bat/fastboot.sh 进行刷机"
echo "> 修改者：酷安 @Quarters"
echo "> 原作者：酷安 @Rannki"
exit 0
