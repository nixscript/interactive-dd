#!/bin/bash
# UTF-8
# Author: grigruss@ya.ru (vk.com/grigruss)
# Group in VK vk.com/nixscript
# Группа в ВК vk.com/nixscript
# Github: github.com/grigruss/interactive-dd
# Interactive shell for dd.
# Интерактивная обёртка для команды dd
# Упростит использование команды,
# поможет выбрать устройство и другие параметры.
# Лицензия MIT, читайте файл LICENSE.md

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
	echo -e "\\e[37;45m\\e[2J\\e[1;0H"
	if [[ ${LANG:0:2} != "ru" ]]; then
		echo -e "\\e[37;45;4m\\tINTERACTIVE COMMAND SHELL dd (v0.3)\\e[0m\\e[37;45;1m"
		echo -e "\\e[37;45;1m    \\e[4mIn order to:\\e[0m\\e[37;45;1m\\n\\tRussian Community of Open Source Software (ROSPO)"
		echo -e "\\e[37;45;1m\\tTo develop and improve the quality of Russian OSS."
		echo -e "\\e[37;45;1m    \\e[4mThanks for the consultations:\\e[0m\\e[37;45;1m\\n\\tMikhail (vk.com/mikhailnov) and Sergey (vk.com/disable_enable)"
	else
		echo -e "\\e[37;45;4m\\tИНТЕРАКТИВНАЯ ОБОЛОЧКА КОМАНДЫ dd (v0.3)\\e[0m\\e[37;45;1m"
		echo -e "\\e[37;45;1m    \\e[4mВ целях:\\e[0m\\e[37;45;1m\\n\\tРоссийского Общества Свободного Программного Обеспечения (РОСПО)"
		echo -e "\\e[37;45;1m\\tДля развития и улучшения качества российского СПО."
		echo -e "\\e[37;45;1m    \\e[4mБлагодарность за консультации:\\e[0m\\e[37;45;1m\\n\\tМихаилу (vk.com/mikhailnov) и Сергею (vk.com/disable_enable)"
	fi
	echo -e "\\e[37;45;1m\\n\\tya@grigrus.ru vk.com/nixscript\\n\\t\\t License MIT \\n\\e[0m\\e[47m\\e[0J"
}

# Choise 1, device from
# Выбор устройства, с которого читать
chs1(){
	field
	if [[ ${LANG:0:2} != "ru" ]]; then
		echo -e "\\e[30;47m\\e[12H\\e[0J\\t\\e[30mSelect source type\\n\\t\\tf) File\\td) Disk\\e[1A"
	else
		echo -e "\\e[30;47m\\e[12H\\e[0J\\t\\e[30mВыберите источник\\n\\t\\tf) Файл\\td) Диск\\e[1A"
	fi
	read -n 1 c
	case "$c" in
		f)if [[ ${LANG:0:2} != "ru" ]]; then d="file"; echo -e "\\e[1D\\e[0K\\t\\t\\e[34mf) File\\t\\e[30md) Disk"; else d="файл"; echo -e "\\e[1D\\e[0K\\t\\t\\e[34mf) Файл\\t\\e[30md) Диск"; fi;;
		d)if [[ ${LANG:0:2} != "ru" ]]; then d="disk"; echo -e "\\e[1D\\e[0K\\t\\tf) File\\t\\e[34md) Disk\\e[30m"; else d="диск"; echo -e "\\e[1D\\e[0K\\t\\tf) Файл\\t\\e[34md) Диск\\e[30m"; fi;;
		*)chs1;;
	esac
	if [[ $d == "файл" || $d == "file" ]]; then
		showfiles
	else
		showdevices
	fi
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tSelect the number of $d and press Enter"; else echo -e "\\tВыберите номер $dа и нажмите Enter"; fi
	read file
	sl="${#list[*]}"
	echo -e "$sl"
	if [[ $d == "файл" || $d == "file" && $file == "$sl" ]]; then
		if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tType name of $d:"; else echo -e "\\tВведите имя $dа:"; fi
		read ff
		if [[ -e "$ff" ]]; then if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tFile $ff is exist."; else echo -e "\\tФайл $ff найден."; fi
		list[$sl]="$ff"
		else
			if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\t\\e[30;43m File $ff not found!!! \\e[0m\\e[30;47m\\n\\tCheck path to file before run or from file directory.\\n\\n\\e[0m\\e[0J"
        else echo -e "\\t\\e[30;43m Файл $ff не найден!!! \\e[0m\\e[30;47m\\n\\tПроверьте правильность пути к файлу перед запуском, или запустите из директории с файлом.\\n\\n\\e[0m\\e[0J"; fi
			exit 2; fi
	fi
	field
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\e[30;47m\\e[12H\\tSource is $d ${list[$file]}\\e[30;47m\\e[13H\\e[0J"
else echo -e "\\e[30;47m\\e[12H\\tИсточником выбран $d ${list[$file]}\\e[30;47m\\e[13H\\e[0J"; fi
	idev="${list[$file]}"
	echo -e "\\e[30B\\e[0m\\n"
}

# Choise 2, device to
# Выбор устройства на которое пишем
chs2(){
	field
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\e[30;47m\\e[12H\\e[0J\\t\\e[30mSelect type of destination\\n\\t\\tf) File\\td) Disk\\e[1A"
else echo -e "\\e[30;47m\\e[12H\\e[0J\\t\\e[30mВыберите приёмник\\n\\t\\tf) Файл\\td) Диск\\e[1A"; fi
	read -n 1 c
	case "$c" in
		f)if [[ ${LANG:0:2} != "ru" ]]; then d="file"; echo -e "\\e[1D\\e[0K\\t\\t\\e[34mf) File\\t\\e[30md) Disk"; else d="файл"; echo -e "\\e[1D\\e[0K\\t\\t\\e[34mf) Файл\\t\\e[30md) Диск"; fi;;
		d)if [[ ${LANG:0:2} != "ru" ]]; then d="disk"; echo -e "\\e[1D\\e[0K\\t\\tf) File\\t\\e[34md) Disk\\e[30m"; else d="диск"; echo -e "\\e[1D\\e[0K\\t\\tf) Файл\\t\\e[34md) Диск\\e[30m"; fi;;
		*)chs2;;
	esac
	if [[ $d == "диск" || $d == "disk" ]]; then
		showdevices
		if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tSelect number of $d and press Enter"
    else echo -e "\\tВыберите номер $dа и нажмите Enter"; fi
		read file
	else
		if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tВведите имя файла:"
    else echo -e "\\tВведите имя файла:"; fi
		read ff
		if [[ -e "$ff" && $ff != "/dev/null" ]]; then if [[ ${LANG:0:2} != "ru" ]]; then
				echo -e "\\t\\e[30;43m File $ff is exist!!!\\e[0m\\e[30;47m\\n\\tRestart $0 and type other name of file.\\n\\n\\e[0m\\e[0J"; exit 2
			else echo -e "\\t\\e[30;43m Файл $ff существует!!!\\e[0m\\e[30;47m\\n\\tПерезапустите и укажите другое имя файла.\\n\\n\\e[0m\\e[0J"; exit 2; fi
		fi
		file=0
		list=("$ff")
	fi
	field
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\e[30;47m\\e[12H\\tDestination $d is ${list[$file]}\\e[30;47m\\e[13H\\e[0J"
else echo -e "\\e[30;47m\\e[12H\\tПриёмником выбран $d ${list[$file]}\\e[30;47m\\e[13H\\e[0J"; fi
	odev="${list[$file]}"
	echo -e "\\e[30B\\e[0m\\n"
}

# Show numbered list of files from current directory
# Вывод нумерованного списка файлов в текущей директории
showfiles(){
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tList of files:"
else echo -e "\\tСписок файлов:"; fi
	flist=$(ls ./*.i*)
	count=1
	for file in ${flist[*]}; do
		echo -e "\\t\\t$count) $file"
		list[$count]=$file
		count=$(expr $count + 1)
	done
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\t\\t$count) Type from keyboard"
else echo -e "\\t\\t$count) Ввести с клавиатуры"; fi
}

# Show numbered list of devices
# Вывод нумерованного списка устройств с разделами
showdevices(){
	count=1
	l=
	tfile="/tmp/idd.tmp"
	fdisk -l | grep "\\/dev\\/" > $tfile
	IFS=$'\\n'
	for l in $(cat $tfile); do
		if [[ ${l:1:3} == "dev" ]]; then
			echo -e "\\t$l"
		else
			IFS=$' '
			g=("$l")
			gl=$(expr length "${g[1]}"); gl=$(expr "$gl - 1")
			list[$count]="${g[1]:0:$gl}"
			IFS=$'\\n'
			if [[ ${LANG:0:2} != "ru" ]]; then echo -e "$count) \\e[4m$l\\e[0m\\e[30;47m\\n\\t    partitions:"
        else echo -e "$count) \\e[4m$l\\e[0m\\e[30;47m\\n\\t    разделы:"; fi
			count=$(expr $count + 1)
		fi
	done
	rm -rf $tfile
}

# Get device block size
# Определение размера блока
getbs(){
	bsdev=
	if [[ ${odev:0:4} == "/dev" ]]; then bsdev="${odev:5}"; else bsdev="no"; return; fi
	blocksize=$(cat /sys/block/$bsdev/queue/logical_block_size)
	range=$(cat /sys/block/$bsdev/range)
	bs=$(expr "$blocksize" \* "$range")
	bs=$(expr "$bs" / 1024)
	if [[ ! $bs ]]; then bs=; else bs="${bs}M"; fi
}

# Show params, confirm and run dd
# Вывод собранных данных, подтверждение и выполнение dd
showdata(){
	mdev=$(mount | grep "$odev")
	if [[ ! $mdev ]]; then if [[ ${LANG:0:2} != "ru" ]]; then mnt="\\e[32mUmounted"; else mnt="\\e[32mНе монтирован"; fi
	else
		IFS=$' '
		m=("$mdev")
		if [[ ${LANG:0:2} != "ru" ]]; then mnt="\\e[33;40m Mounted to ${m[2]} "; else mnt="\\e[33;40m Смонтирован в ${m[2]} "; fi
	fi
	field
	echo -e "\\e[30;47m\\e[12H\\e[0J"
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tSource      $idev"; else echo -e "\\tИсточником выбран $idev"; fi
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tDestination $odev\\t$mnt\\e[0m\\e[30;47m"; else echo -e "\\tПриёмником выбран $odev\\t$mnt\\e[0m\\e[30;47m"; fi
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tBlock size  $bs"; else echo -e "\\tРазмер блока      $bs"; fi
	if [[ ! $bs ]]; then pbs=""; else pbs="bs=$bs "; fi
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\n\\tCommand to run:\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m"
else echo -e "\\n\\tКоманда на выполнение:\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m"; fi
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\n\\t\\e[30;43;5m Check the command!!! \\e[0m\\e[30;47m\\n\\t\\e[30;43m Не соглашайтесь на выполнение, если в чём-то не уверены!!! \\e[0m\\e[30;47m"
else echo -e "\\n\\t\\e[30;43;5m Проверьте правильность команды!!! \\e[0m\\e[30;47m\\n\\t\\e[30;43m Не соглашайтесь на выполнение, если в чём-то не уверены!!! \\e[0m\\e[30;47m"; fi
	if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\tAre you ready to write from $idev to $odev ? [y/N]"
else echo -e "\\tВы готовы к записи c $idev на $odev ? [y/N]"; fi
	read y
	if [[ $y == "y" || $y == "Y" ]]; then
		if [[ $mdev ]]; then
			if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\e[19H\\e[0J\\tUnmount $odev? [y/N]"
        else echo -e "\\e[19H\\e[0J\\tОтмонтировать $odev? [y/N]"; fi
			read -n 1 u
			if [[ $u == "y" || $u == "Y" ]]; then umount "$odev"; fi
		fi
		if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\e[19H\\e[0K\\t\\e[30;5mIn process:\\e[0m\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m\\e[0J"
    else echo -e "\\e[19H\\e[0K\\t\\e[30;5mВыполнение:\\e[0m\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m\\e[0J"; fi
		if [[ ! $bs ]]; then
			dd if="$idev" of="$odev" status=progress
		else
			dd if="$idev" of="$odev" bs="$bs" status=progress
		fi
		if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\e[19H\\e[0K\\tAll done:\\e[0m\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m"
    else echo -e "\\e[19H\\e[0K\\tВыполнено:\\e[0m\\e[30;43m dd if=$idev of=$odev ${pbs}status=progress \\e[0m\\e[30;47m"; fi
		if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\e[25H\\tРабота выполнена!\\n\\tдля выхода нажмите любую клавишу.\\e[0J"
    else echo -e "\\e[25H\\tРабота выполнена!\\n\\tдля выхода нажмите любую клавишу.\\e[0J"; fi
		read -n 1
	fi
}
field
if [[ $(whoami) != "root" ]]; then if [[ ${LANG:0:2} != "ru" ]]; then echo -e "\\t\\e[30;43m You have no rights. You must start it as root.\\n\\n\\n\\e[0m\\e[0J"; exit 2
else echo -e "\\t\\e[30;43m Не достаточно прав. Запустите от имени root.\\n\\n\\n\\e[0m\\e[0J"; exit 2; fi fi
chs1
chs2
getbs
showdata
echo -e "\\e[0m\\e[0J"
