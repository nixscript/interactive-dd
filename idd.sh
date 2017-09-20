#!/bin/bash
# Author: grigruss@ya.ru (vk.com/grigruss)
# Group in VK vk.com/nixscript
# Группа в ВК vk.com/nixscript
# Github: github.com/interactive-dd/interactive-dd
# Interactive shell for dd.
# Интерактивная обёртка для команды dd
# Упростит использование команды,
# поможет выбрать устройство и другие параметры.
# Лицензия MIT, читайте файл LICENSE.md

# Global vars
# Глобальные переменные
idev= # Источник (Input device)
odev= #	Приёмник (Output device)
bs=   #	Размер блока (BlockSize)
d=    # Под всякую чушь (Temporary var)
list= # Для списков файлов/дисков (For lists of files/disks)

idd_header=
idd_target=
idd_target1=
idd_thankfulness=
idd_author_lic=
idd_choise_source=
idd_choise_f=
idd_choise_d=
idd_choise_source1=
idd_choise_source2=
idd_read_source_dest=
idd_read_source_dest1=
idd_type_filename=
idd_type_filename1=
idd_file_exists=
idd_file_not_found=
idd_source=
idd_choise_destination=
idd_file_exists_exit=
idd_destination=
idd_filelist=
idd_type_from_kbd=
idd_partitions=
idd_umount=
idd_mount=
idd_source_choised=
idd_dest_choised=
idd_bs=
idd_command=
idd_check_cmd=
idd_ready_to_write=
idd_umount_dev=
idd_process=
idd_done=
idd_alldone=

# Check root
if [[ $(whoami) != "root" ]]; then
    echo -e "\\n\\t\\e[33;5mRun as root! You have no rights.\\e[0m\\n"
    exit 2
fi

# Load locales
IFS=$'\n'
while IFS= read -r line; do
    if [[ ! $line ]]; then continue; fi
    nm=${line%%=*}
    if [[ ${nm:0:3} != "idd" ]]; then continue; fi
    var=${line##*=}
    export "$nm"="$var"
done <"/usr/share/idd/${LANG:0:2}.trans"

# Load locales
IFS=$'\n'
for line in $(cat "/usr/share/idd/${LANG:0:2}.trans"); do
    idx1=$(expr index "$line" =)
    idx=$(expr "$idx1" - 1)
    nm="${line:0:$idx}"
    if [[ ${nm:0:3} != "idd" ]]; then continue; fi
    var="${line:$idx1}"
    export "$nm"="$var"
done

# Show header
# Рисует шапку/заголовок
field() {
    echo -e "\\e[37;45m\\e[2J\\e[1;0H"
    echo -e "$idd_header dd (v0.4.1)\\e[0m\\e[37;45;1m"
    echo -e "$idd_target"
    echo -e "$idd_target1"
    echo -e "$idd_thankfulness"
    echo -e "$idd_author_lic"
}

# Choise 1, device from
# Выбор устройства, с которого читать
chs1() {
    field
    echo -e "$idd_choise_source"
    read -r -n 1 c
    case "$c" in
    f)
        d="$idd_choise_f"
        echo -e "$idd_choise_source1"
        ;;
    d)
        d="$idd_choise_d"
        echo -e "$idd_choise_source2"
        ;;
    *) chs1 ;;
    esac
    if [[ $d == "$idd_choise_f" ]]; then
        showfiles
    else
        showdevices
    fi
    echo -e "$idd_read_source_dest $d$idd_read_source_dest1"
    read -r file
    sl="${#list[*]}"
    if [[ $d == "$idd_choise_f" && $file == "$sl" ]]; then
        echo -e "$idd_type_filename $d$idd_type_filename1"
        read -r ff
        if [[ -e "$ff" ]]; then
            echo -e "$idd_file_exists"
            list[$sl]="$ff"
        else
            echo -e "$idd_file_not_found"
            exit 2
        fi
    fi
    field
    echo -e "$idd_source $d ${list[$file]}\\e[30;47m\\e[13H\\e[0J"
    idev="${list[$file]}"
    echo -e "\\e[30B\\e[0m\\n"
}

# Choise 2, device to
# Выбор устройства на которое пишем
chs2() {
    field
    echo -e "$idd_choise_destination"
    read -r -n 1 c
    case "$c" in
    f)
        d="$idd_choise_f"
        echo -e "$idd_choise_source1"
        ;;
    d)
        d="$idd_choise_d"
        echo -e "$idd_choise_source2"
        ;;
    *) chs2 ;;
    esac
    if [[ $d == "$idd_choise_d" ]]; then
        showdevices
        echo -e "$idd_read_source_dest $d$idd_read_source_dest1"
        read -r file
    else
        echo -e "$idd_type_filename $d$idd_type_filename1"
        read -r ff
        if [[ -e "$ff" && $ff != "/dev/null" ]]; then
            echo -e "$idd_file_exists_exit"
            exit 2
        fi
        file=0
        list=("$ff")
    fi
    field
    echo -e "$idd_destination $d ${list[$file]}\\e[30;47m\\e[13H\\e[0J"
    odev="${list[$file]}"
    echo -e "\\e[30B\\e[0m\\n"
}

# Show numbered list of files from current directory
# Вывод нумерованного списка файлов в текущей директории
showfiles() {
    echo -e "$idd_filelist"
    count=1
    flist=("$(ls ./*.i* 2>/dev/null)")
    for file in ${flist[*]}; do
        echo -e "\\t\\t$count) $file"
        list[$count]=$file
        count=$((count + 1))
    done
    echo -e "\\t\\t$count$idd_type_from_kbd"
}

# Show numbered list of devices
# Вывод нумерованного списка устройств с разделами
showdevices() {
    count=1
    l=
    tfile="/tmp/idd.tmp"
    fdisk -l | grep "\\/dev\\/" >$tfile
    IFS=$'\n'
    while read -r l; do
        if [[ ${l:1:3} == "dev" ]]; then
            echo -e "\\t$l"
        else
            IFS=$' '
            mapfile -t g <<<"$l"
            gl=${#g[1]}
            gl=$(gl - 1)
            list[$count]="${g[1]:0:$gl}"
            IFS=$'\n'
            echo -e "$count$idd_partitions"
            count=$(count + 1)
        fi
    done <$tfile
    rm -rf $tfile
}

# Get device block size
# Определение размера блока
getbs() {
    if [[ ! -e /sys/block/$bsdev/queue/logical_block_size ]]; then
        bs=
        return
    fi
    bsdev=
    if [[ ${odev:0:4} == "/dev" ]]; then bsdev="${odev:5}"; else
        bsdev="no"
        return
    fi
    blocksize=$(cat /sys/block/$bsdev/queue/logical_block_size)
    range=$(cat /sys/block/$bsdev/range)
    bs=$($blocksize \* "$range")
    bs=$(bs / 1024)
    if [[ ! $bs ]]; then bs=; else bs="${bs}M"; fi
}

# Show params, confirm and run dd
# Вывод собранных данных, подтверждение и выполнение dd
showdata() {
    mdev=$(mount | grep "$odev")
    if [[ ! $mdev ]]; then mnt="$idd_umount"
    else
        IFS=$' '
        mapfile -t m <<<"$mdev"
        mnt="$idd_mount ${m[2]}"
    fi
    field
    echo -e "\\e[30;47m\\e[12H\\e[0J"
    echo -e "$idd_source_choised\\t$idev"
    echo -e "$idd_dest_choised\\t$odev\\t$mnt\\e[0m\\e[30;47m"
    echo -e "$idd_bs\\t$bs"
    if [[ ! $bs ]]; then pbs=""; else pbs="bs=$bs "; fi
    echo -e "$idd_command\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m"
    echo -e "$idd_check_cmd"
    echo -e "$idd_ready_to_write $idev -> $odev ? [y/N]"
    read -r y
    if [[ $y == "y" || $y == "Y" ]]; then
        if [[ $mdev ]]; then
            echo -e "$idd_umount_dev $odev? [y/N]"
            read -r -n 1 u
            if [[ $u == "y" || $u == "Y" ]]; then umount "$odev"; fi
        fi
        echo -e "$idd_process\\e[0m\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m\\e[0J"
        if [[ ! $bs ]]; then
            dd if="$idev" of="$odev" status=progress
        else
            dd if="$idev" of="$odev" bs="$bs" status=progress
        fi
        echo -e "$idd_done\\e[0m\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m"
        echo -e "$idd_alldone"
        read -r -n 1
    fi
}
field
chs1
chs2
getbs
showdata
echo -e "\\e[0m\\e[0J"
