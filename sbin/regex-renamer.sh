#!/bin/bash

function __rnx_input {
	__rnx_output=""
	__rnx_pattern=""
	__rnx_directory=""
	__rnx_test=0

	while (( "$#" )); do
		case $1 in
		--pattern|-p)
			__rnx_pattern="$2"
			shift 2
			;;

		--output|-o)
			__rnx_output="$2"
			shift 2
			;;

		--test|-t)
			__rnx_test=1
			shift
			;;
		-*)
			echo "Unknown Option $1"
			__rnx_usage
			;;
		*)
			__rnx_directory="$1"
			shift
			;;
		esac
	done

	if [ -z "$__rnx_pattern" ]; then
		__rnx_usage
	fi

	if [ -z "$__rnx_output" ]; then
        __rnx_usage
    fi

	if [ -z "$__rnx_directory" ]; then
		__rnx_directory="."
	fi

	__rnx_rename
}

function __rnx_usage {
    echo
    echo "Usage: $0 -p <regex> -o <replacement> [directory]"
    echo "  -p --pattern : a regex that matches the part of the files you want renamed."
    echo "  -o --output  : replace the matched part of the filename with this."
    echo "  -t --test    : perform a dry run (output filenames don't move anything)"
    echo
    echo "Recommendation: *** Use single quotes in pattern / output to prevent bash from manipulating the strings."
    echo
    echo "Example: rnx --test -p '(.*)([0-9]{2})(.*)' -o '$2--$1datafile$3' example/data"
    echo " Dry Run: example/data/another-03.readme -> example/data/03--another-datafile.readme"
    echo " Dry Run: example/data/infologs-01.logs -> example/data/01--infologs-datafile.logs"
    echo " Dry Run: example/data/textfilenamed-00.txt -> example/data/00--textfilenamed-datafile.txt"
    echo
    exit 1
}

function __rnx_rename {
	__rnx_oldifs=$IFS
	IFS=$'\n'
	
	__rnx_files=$( find $__rnx_directory -maxdepth 1 )
	
	
	for __rnx_file in $__rnx_files; do
		__rnx_base=`basename $__rnx_file`
		__rnx_dir=`dirname $__rnx_file`

		if [[ "$__rnx_base" =~ $__rnx_pattern ]]; then
			if [ ${#BASH_REMATCH[@]} == "1" ]; then
				__rnx_target="$__rnx_dir/$( echo "$__rnx_base" | sed "s/$__rnx_pattern/$__rnx_output/gi" )"
			else
				__rnx_target="$__rnx_output"
				for (( __rnx_idx=1; __rnx_idx < ${#BASH_REMATCH[@]}; __rnx_idx++ )); do
					__rnx_target="$( echo "$__rnx_target" | sed "s/\$$__rnx_idx/${BASH_REMATCH[__rnx_idx]}/g" )"
				done
				__rnx_target="$__rnx_dir/$__rnx_target"
			fi
			
			if [ $__rnx_test == "1" ]; then
				echo "Dry Run: $__rnx_file -> $__rnx_target"
			else
				mv "$__rnx_file" "$__rnx_target"
				echo "Renamed: $__rnx_file -> $__rnx_target"
			fi
		fi	
	done
}

__rnx_input "$@"
