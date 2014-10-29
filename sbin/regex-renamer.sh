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
			exit 1
			;;
		*)
			__rnx_directory="$1"
			shift
			;;
		esac
	done

	if [ -z "$__rnx_pattern" ]; then
		echo "No Pattern Specified"
		exit 1	
	fi

	if [ -z "$__rnx_output" ]; then
                echo "No Output Specified"
                exit 1
        fi


	if [ -z "$__rnx_directory" ]; then
		__rnx_directory="."
	fi

	__rnx_rename
}

function __rnx_rename {
	__rnx_oldifs=$IFS
	IFS=$'\n'
	
	__rnx_files=$( find $__rnx_directory -maxdepth 1 )
	
	
	for __rnx_file in $__rnx_files; do
		#IFS=$__rnx_oldifs
		
		if [[ "$__rnx_file" =~ $__rnx_pattern ]]; then
			if [ ${#BASH_REMATCH[@]} == "1" ]; then
				__rnx_target="$( echo "$__rnx_file" | sed "s/$__rnx_pattern/$__rnx_output/gi" )"
			else
				__rnx_target="$__rnx_output"
				for (( __rnx_idx=1; __rnx_idx < ${#BASH_REMATCH[@]}; __rnx_idx++ )); do
					__rnx_target="$( echo "$__rnx_target" | sed "s/\$$__rnx_idx/${BASH_REMATCH[__rnx_idx]}/g" )"
				done
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
