#!/bin/bash
# Author: grigruss@ya.ru (vk.com/grigruss)
# Group in VK vk.com/nixscript
# Группа в ВК vk.com/nixscript
# Github: github.com/grigruss/interactive-dd
# Interactive shell for dd.
# Интерактивная обёртка для команды dd
# Упростит использование команды,
# поможет выбрать устройство и другие параметры.
# Лицензия MIT, читайте файл LICENSE.md

# Check root
if [[ `whoami` != "root" ]]; then echo -e "\n\t\e[33;5mRun as root! You have no rights.\e[0\n"; exit 2; fi

# Load locales
IFS=$'\n'
iddlocale=
for line in $(cat "/usr/share/idd/idd.${LANG:0:2}"); do
	idx1=`expr index "$line"`
	idx=`expr $idx1 - 1`
	nm="${line:0:$idx}"
	if [[ ${nm:0:3} != "idd" ]]; then continue; fi
	var="${line:$idx1}"
	export $nm=$var
done

# Global vars
# Глобальные переменные
idev=	# Input device | Источник
odev=	# Output device | Приёмник
bs=		# BlockSize | Размер блока
d=		# Temporary var | Под всякую чушь
list=	# For lists of files/disks | Для списков файлов/дисков

# Show header
# Рисует шапку/заголовок
field(){
	echo -e "\e[37;45m\e[2J\e[1;0H"
	echo -e "$idd_header dd (v0.4.1)\e[0m\e[37;45;1m"
	echo -e "$idd_target"
	echo -e "$idd_target1"
	echo -e "$idd_thankfulness"
	echo -e "$idd_author_lic"
}

# Choise 1, device from
# Выбор устройства, с которого читать
chs1(){
	field
	echo -e "$idd_choise_source"
	read -n 1 c
	case "$c" in
		f)d="$idd_choise_f"; echo -e "$idd_choise_source1";;
		d)d="$idd_choise_d"; echo -e "$idd_choise_source2";;
		*)chs1;;
	esac
	if [[ $d == "$idd_choise_f" ]]; then
		showfiles
	else
		showdevices
	fi
	echo -e "$idd_read_source_dest"
	read file
	sl="${#list[*]}"
	if [[ $d == "$idd_choise_f" && $file == $sl ]]; then
		echo -e "$idd_type_filename $d$idd_type_filename1"
		read ff
		if [[ -e "$ff" ]]; then
			echo -e "$idd_file_exists"
			list[$sl]="$ff"
		else
			echo -e "$idd_file_not_found"
			exit 2
		fi
	fi
	field
	echo -e "$idd_source $d ${list[$file]}\e[30;47m\e[13H\e[0J"
	idev="${list[$file]}"
	echo -e "\e[30B\e[0m\n"
}

# Choise 2, device to
# Выбор устройства на которое пишем
chs2(){
	field
	echo -e "$idd_choise_destination"
	read -n 1 c
	case "$c" in
		f)d="$idd_choise_f"; echo -e "$idd_choise_source1";;
		d)d="$idd_choise_d"; echo -e "$idd_choise_source2";;
		*)chs2;;
	esac
	if [[ $d == $idd_choise_d ]]; then
		showdevices
		echo -e "$idd_read_source_dest"
		read file
	else
		echo -e "$idd_type_filename"
		read ff
		if [[ -e "$ff" && $ff != "/dev/null" ]]; then
			echo -e "$idd_file_exists_exit"; exit 2
		fi
		file=0
		list=("$ff")
	fi
	field
	echo -e "$idd_destination $d ${list[$file]}\e[30;47m\e[13H\e[0J"
	odev="${list[$file]}"
	echo -e "\e[30B\e[0m\n"
}

# Show numbered list of files from current directory
# Вывод нумерованного списка файлов в текущей директории
showfiles(){
	echo -e "$idd_filelist"
	flist=(`ls *.i*`)
	count=1
	for file in ${flist[*]}; do
		echo -e "\t\t$count) $file"
		list[$count]=$file
		count=`expr $count + 1`
	done
	echo -e "\t\t$count$idd_type_from_kbd"
}

# Show numbered list of devices
# Вывод нумерованного списка устройств с разделами
showdevices(){
	count=1
	l=
	tfile="/tmp/idd.tmp"
	fdisk -l | grep "\/dev\/" > $tfile
	IFS=$'\n'
	for l in $(cat $tfile); do
		if [[ ${l:1:3} == "dev" ]]; then
			echo -e "\t$l"
		else
			IFS=$' '
			g=($l)
			gl=`expr length "${g[1]}"`; gl=`expr $gl - 1`
			list[$count]="${g[1]:0:$gl}"
			IFS=$'\n'
			echo -e "$count$idd_partitions"
			count=`expr $count + 1`
		fi
	done
	rm -rf $tfile
}

# Get device block size
# Определение размера блока
getbs(){
	bsdev=
	if [[ ${odev:0:4} == "/dev" ]]; then bsdev="${odev:5}"; else bsdev="no"; return; fi
	blocksize=`cat /sys/block/$bsdev/queue/logical_block_size`
	range=`cat /sys/block/$bsdev/range`
	bs=`expr $blocksize \* $range`
	bs=`expr $bs / 1024`
	if [[ ! $bs ]]; then bs=; else bs="${bs}M"; fi
}

# Show params, confirm and run dd
# Вывод собранных данных, подтверждение и выполнение dd
showdata(){
	mdev=`mount | grep "$odev"`
	if [[ ! $mdev ]]; then mnt="$idd_umount"
	else
		IFS=$' '
		m=($mdev)
		mnt="$idd_mount ${m[2]}"
	fi
	field
	echo -e "\e[30;47m\e[12H\e[0J"
	echo -e "$idd_source_choised\t$idev"
	echo -e "$idd_dest_choised$odev\t$mnt\e[0m\e[30;47m"
	echo -e "$idd_bs\t$bs"
	if [[ ! $bs ]]; then pbs=""; else pbs="bs=$bs "; fi
	echo -e "$idd_command\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \e[0m\e[30;47m"
	echo -e "$idd_check_cmd"
	echo -e "$idd_ready_to_write $idev -> $odev ? [y/N]"
	read y
	if [[ $y == "y" || $y == "Y" ]]; then
		if [[ $mdev ]]; then
			echo -e "$idd_umount_dev $odev? [y/N]"
			read -n 1 u
			if [[ $u == "y" || $u == "Y" ]]; then umount "$odev"; fi
		fi
		echo -e "$idd_process\e[0m\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \e[0m\e[30;47m\e[0J"
		if [[ ! $bs ]]; then
			dd if=$idev of=$odev status=progress
		else
			dd if=$idev of=$odev bs=$bs status=progress
		fi
		echo -e "$idd_done\e[0m\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \e[0m\e[30;47m"
		echo -e "$idd_alldone"
		read -n 1
	fi
}
field
chs1
chs2
getbs
showdata
echo -e "\e[0m\e[0J"
