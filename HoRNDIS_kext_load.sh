#!/bin/bash
#
#
#
#

#set -x

LIB_EX_KEXT=0
SYS_LIB_EX_KEXT=0
KEXT_LOAD=0
DIR="$PWD"
SAMSUNG_KEXT=0

check_kext_dir()
{
	cd /Library/Extensions 
	if [[ ! -d HoRNDIS.kext ]] ; then
		LIB_EX_KEXT=2
	else
		LIB_EX_KEXT=1
	fi
	
	cd /System/Library/Extensions 
	if [[ ! -d HoRNDIS.kext ]] ; then
		SYS_LIB_EX_KEXT=2
	else
		SYS_LIB_EX_KEXT=1
	fi
	cd $DIR
}

check_kext_load()
{
	if [[ "$(kextstat | grep HoRNDIS >/dev/null; echo $? )" -eq 0 ]] ; then
		KEXT_LOAD=1
	else 
		KEXT_LOAD=2
	fi
}

move_kext_in()
{
	printf '%s\n' " > move HoRNDIS.kext <"
	if [[ LIB_EX_KEXT -eq 1 ]] && [[ SYS_LIB_EX_KEXT -eq 1 ]] ; then
		printf '%s\n' ""
		printf '%s\n' " > No need to move HoRNDIS.kext. It was found in /Library/Extensions and /System/Library/Extensions"
	elif [[ LIB_EX_KEXT -eq 1 ]] && [[ SYS_LIB_EX_KEXT -eq 2 ]] ; then
		printf '%s\n' ""
		printf '%s\n' " > HoRNDIS.kext found in /Library/Extensions but !NOT! in /System/Library/Extensions"
		printf '%s\n' " > This is a problem"
		printf '%s\n' " - Removing HoRNDIS.kext from /Library/Extensions..."	
		sudo rm -rf /Library/Extensions/HoRNDIS.kext
		printf '%s\n' " - Moving HoRNDIS.kext to /Library/Extensions..."	
		sudo ditto $DIR/kext/lib/HoRNDIS.kext /Library/Extensions/HoRNDIS.kext		
		printf '%s\n' " - Moving HoRNDIS.kext to /System/Library/Extensions..."	
		sudo ditto $DIR/kext/syslib/HoRNDIS.kext /System/Library/Extensions/HoRNDIS.kext
		printf '%s\n' " - Setting HoRNDIS.kext permissions..."	
		sudo chown -R root:wheel /Library/Extensions/HoRNDIS.kext
		sudo chown -R root:wheel /System/Library/Extensions/HoRNDIS.kext
		post_move_check
	elif [[ LIB_EX_KEXT -eq 2 ]] && [[ SYS_LIB_EX_KEXT -eq 1 ]] ; then
		printf '%s\n' ""
		printf '%s\n' " > HoRNDIS.kext found in /System/Library/Extensions but !NOT! in /Library/Extensions"
		printf '%s\n' " > This is a problem"
		printf '%s\n' " - Removing HoRNDIS.kext from /System/Library/Extensions..."	
		sudo rm -rf /System/Library/Extensions/HoRNDIS.kext
		printf '%s\n' " - Moving HoRNDIS.kext to /Library/Extensions..."	
		sudo ditto $DIR/kext/lib/HoRNDIS.kext /Library/Extensions/HoRNDIS.kext
		printf '%s\n' " - Moving HoRNDIS.kext to /System/Library/Extensions..."	
		sudo ditto $DIR/kext/syslib/HoRNDIS.kext /Library/Extensions/HoRNDIS.kext		
		printf '%s\n' " - Setting HoRNDIS.kext permissions..."	
		sudo chown -R root:wheel /Library/Extensions/HoRNDIS.kext
		sudo chown -R root:wheel /System/Library/Extensions/HoRNDIS.kext
		post_move_check
	elif [[ LIB_EX_KEXT -eq 2 ]] && [[ SYS_LIB_EX_KEXT -eq 2 ]] ; then
		printf '%s\n' ""
		printf '%s\n' " > HoRNDIS.kext found neither in /System/Library/Extensions nor in /Library/Extensions"
		printf '%s\n' " - Moving HoRNDIS.kext to /Library/Extensions..."	
		sudo ditto $DIR/kext/lib/HoRNDIS.kext /Library/Extensions/HoRNDIS.kext		
		printf '%s\n' " - Moving HoRNDIS.kext to /System/Library/Extensions..."	
		sudo ditto $DIR/kext/syslib/HoRNDIS.kext /System/Library/Extensions/HoRNDIS.kext
		printf '%s\n' " - Setting HoRNDIS.kext permissions..."	
		sudo chown -R root:wheel /Library/Extensions/HoRNDIS.kext
		sudo chown -R root:wheel /System/Library/Extensions/HoRNDIS.kext
		post_move_check
	fi
}	
	
post_move_check()
{		
		check_kext_dir
		printf '%s\n' ""
		printf '%s\n' " > post move checks <"
		if [[ LIB_EX_KEXT -eq 1 ]] && [[ SYS_LIB_EX_KEXT -eq 1 ]] ; then
			printf '%s\n' ""
			printf '%s\n' " > HoRNDIS.kext found in /Library/Extensions and /System/Library/Extensions"
			printf '%s\n' " > Everything seems ok"
		elif [[ LIB_EX_KEXT -eq 1 ]] && [[ SYS_LIB_EX_KEXT -eq 2 ]] ; then
			printf '%s\n' ""
			printf '%s\n' " > Something went wrong. HoRNDIS.kext only found in /Library/Extensions"	
			printf '%s\n' " > It's missing in /System/Library/Extensions"
			printf '%s\n' " - Trying to fix this..."
			move_kext_in
		elif [[ LIB_EX_KEXT -eq 2 ]] && [[ SYS_LIB_EX_KEXT -eq 1 ]] ; then
			printf '%s\n' ""
			printf '%s\n' " > Something went wrong. HoRNDIS.kext only found in /System/Library/Extensions"	
			printf '%s\n' " > It's missing in /Library/Extensions"
			printf '%s\n' " - Trying to fix this..."
			move_kext_in
		elif [[ LIB_EX_KEXT -eq 2 ]] && [[ SYS_LIB_EX_KEXT -eq 2 ]] ; then
			printf '%s\n' ""
			printf '%s\n' " > Something went wrong. HoRNDIS.kext found neither in /Library/Extensions, nor in /System/Library/Extensions"	
			printf '%s\n' " - Trying to fix this..."
			move_kext_in
		fi
}

move_kext_out()
{
	printf '%s\n' "Removing HoRNDIS.kext from /Library/Extensions and /System/Library/Extensions"	
	sudo rm -rf /System/Library/Extensions/HoRNDIS.kext
	sudo rm -rf /Library/Extensions/HoRNDIS.kext
	check_kext_dir
}

load_kext()
{
	move_kext_in
		printf '%s\n' ""
		printf '%s\n' " > load HoRNDIS.kext <"
	if [[ KEXT_LOAD -eq 1 ]] ; then
		printf '%s\n' ""
		printf '%s\n' " > HoRNDIS.kext already loaded"
		printf '%s\n' " > Everything seems ok"	
	else	
		printf '%s\n' " - Loading HoRNDIS.kext..."
		sudo kextload -b com.joshuawise.kexts.HoRNDIS
		check_kext_load	
	fi
}	

unload_kext()
{
	printf '%s\n' "Unloading HoRNDIS.kext..."
	sudo kextunload -b com.joshuawise.kexts.HoRNDIS
	move_kext_out
}

samsung_kext()
{
	if [[ "$(kextstat | grep com.devguru.driver.SamsungComposite >/dev/null; echo $? )" -eq 0 ]] ; then
		SAMSUNG_KEXT=1
	else 
		SAMSUNG_KEXT=2
	fi
}
	
while true ; do
	check_kext_dir
	check_kext_load
	samsung_kext
	clear

	printf '%s\n' "This script will load or unload HoRNDIS.kext"
	printf '%s\n' ""
	
	if [[ LIB_EX_KEXT -eq 1 ]] && [[ SYS_LIB_EX_KEXT -eq 1 ]] ; then
		printf '\t%s\n' "HoRNDIS.kext appears to be in it's extension folders"
		if [[ KEXT_LOAD -eq 1 ]] ; then
			printf '\t%s\n' "HoRNDIS.kext appears to be loaded"
		else
			printf '\t%s\n' "HoRNDIS.kext appears not to be loaded"
		fi
	elif [[ NO_KEXT -eq 2 ]] ; then
		printf '\t%s\n' "HoRNDIS.kext appears to be not in it's extension folders"
	fi
	if [[ SAMSUNG_KEXT -eq 1 ]] ; then
		printf '\t%s\n' "It looks like you have Samsung Drivers installed."
	fi
	if [[ SAMSUNG_KEXT -eq 1 ]] ; then
		printf '%s\n' " - Unloading Samsung kext..."
		sudo kextunload -b com.devguru.driver.SamsungComposite
	fi


	printf '%s\n' ""
	printf '%s\n' " 1 - load HoRNDIS.kext"
	printf '%s\n' " 2 - unload HoRNDIS.kext"
	printf '%s\n' " x - Exit"
	printf '%s\n' ""

	read -p "Please choose: " CHOICE
	case $CHOICE in
		1) 	load_kext ;;
		2)	unload_kext ;;
		x) exit 0 ;;
	esac
done
exit 0