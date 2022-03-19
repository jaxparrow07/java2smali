#!/usr/bin/env bash


out_dir="$(pwd)"
j2s_dir="$(dirname $(realpath $0) )"

source "${j2s_dir}/config.sh"

function showhelp() {

cat << EOF
Java2Smali : Simple yet advanced java to smali compiling script ( for Android )

Usage : java2smali [options] <source-file>

Options:

	-h, --help               Prints out this help menu
	-v, --verbose            Verbose output ( for javac )
	-s, --sdk <file>         Name of the sdk jar file ( \$J2S_SDKS directory can be configured via config.sh )
	-o, --out <dir>          Compiles output into the given direcotry              


Required Variables:

Configured through config.sh

	\$J2S_SDKS               Path to a directory to look for sdks ( used by -s and \$J2S_DEFAULT_SDK )
	\$J2S_DEFAULT_SDK        Default sdk jar name ( looks for file in \$J2S_SDKS )
	\$J2S_FRAMEWORK          Path to any android framework jar ( /system/framework/framework.jar )
	\$J2S_DX                 Path to dx script ( found in android build-tools )
	\$J2S_BAKSMALI           Path to baksmali.jar

EOF

}

function compile() {

	local source_file="$1"
	local sdk_file="$sdk_dir/$2"
	local output="$3"
	local verbose="$4"

	local real_file=`realpath "$source_file"`
	local real_dir=`dirname "$real_file"`
	local real_name="${real_file//$real_dir}"

	local package_dir=`cat "$source_file" | head -n 1 | awk '{print $2;}'`
	local package_dir="${package_dir//./\/}"
	local package_dir="${package_dir//\;}"

	cp "$real_file" "$j2s_dir/temp/"

	mkdir -p "$j2s_dir/temp/cls/"

	javac $verbose -classpath "$sdk_file" -classpath "$J2S_FRAMEWORK" "$j2s_dir/temp/$real_name" -d "$j2s_dir/temp/cls/"


	if [[ $? -ne 0 ]];then

		echo "error : can't compile"
		rm "${j2s_dir}/temp/"* -rf
		exit 1

	fi


	"$J2S_DX" --dex --output="$j2s_dir/temp/classes.dex" "$j2s_dir/temp/cls/"

	java -jar "$J2S_BAKSMALI" d "$j2s_dir/temp/classes.dex" -o "$j2s_dir/temp/out/"

	if [[ "$output" == "D-E=F-@-U-/_-T" ]];then

		cp "$j2s_dir/temp/out/${package_dir}/"*.smali "$real_dir/"

	else

		[[ ! -d "$output" ]] && mkdir "$output"
		cp "$j2s_dir/temp/out/${package_dir}/"*.smali "$output/"

	fi

	rm ${j2s_dir}/temp/* -rf

}


set -o errexit -o pipefail -o noclobber -o nounset

! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    exit 1
fi

OPTIONS=s:o:vh
LONGOPTS=sdk:,out:,verbose,help

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 2
fi

eval set -- "$PARSED"

sdk_arg="default" output_arg="D-E=F-@-U-/_-T" verbose_arg=

while true; do
    case "$1" in
    	-h|--help)
			showhelp
			exit
			;;
        -s|--sdk)
            sdk_arg=$2
            shift 2
            ;;
        -v|--verbose)
			verbose_arg="-verbose"
			shift
			;;
		-o|--out)
			output_arg="$(realpath $2)"
			shift 2
			;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

if [[ $# -ne 1 ]];then
    echo "error: A single input file is required."
    exit 4
fi

if [[ -f "$1" ]];then

	echo "Source: $1"

	if [[ $sdk_arg != "default" ]];then

		sdk_dir=`realpath "$J2S_SDKS"`

		if [[ -f "$sdk_dir/$sdk_arg" ]];then
			echo "Sdk: $sdk_arg"
		else
			echo "Sdk not found : Setting to $J2S_DEFAULT_SDK"
			sdk_arg="$J2S_DEFAULT_SDK"
		fi

	else
		echo "Sdk not specified : Setting to $J2S_DEFAULT_SDK"
		sdk_arg="$J2S_DEFAULT_SDK"
	fi

	compile "$1" "$sdk_arg" "$output_arg" "$verbose_arg"


else
	echo "error: No such file"
fi
