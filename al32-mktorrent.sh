#! /bin/bash
set -euo pipefail

function join_by { local IFS="$1"; shift; echo "$*"; }

usage () {
	echo "Usage: $0 [i686|dual]"
}

if [ "$#" -eq 0 ] ; then 
	echo "No architecture specified, selecting 'i686'"
	arch="i686"
elif [ "$#" -eq 1 ] ; then
	echo "Selecting architecture '$1'"
	arch="$1"
else
	usage
	echo "Too many arguments, exiting" >&2
	exit 1
fi

fg_green="\033[32m"
fg_red="\033[31m"
fg_blue="\033[34m"
fg_reset="\033[0m"
fg_bold="\033[1m"

MIRRORLIST_FILE="https://raw.githubusercontent.com/archlinux32/packages/master/core/pacman-mirrorlist/mirrorlist"

mirrorlist="$(curl "$MIRRORLIST_FILE" 2>/dev/null | grep Server | cut -d '=' -f 2 | sed -e 's/\s//g;s_$arch/$repo_archisos/_')"

declare -a available_mirrors

read -r -p "Date of the ISO: " iso_date

iso_string="archlinux-$iso_date-$arch.iso"

for i in $mirrorlist ; do
	echo -n -e "$fg_reset${fg_bold}Checking $fg_reset$fg_blue$i$fg_reset "
	curl -g "$i" 2>/dev/null | grep -q "$iso_string" && (
		echo -e "$fg_reset${fg_green}OK$fg_reset"
	) || ( echo -e "$fg_reset${fg_red}Failed$fg_reset" ; false ) || continue
	available_mirrors=(${available_mirrors[@]} "$i")
done

echo "${#available_mirrors[@]} mirrors available"


if [ ! -f "$iso_string" ] ; then
	echo -e "$fg_reset${fg_bold}Downloading iso...$fg_reset"
	curl -O "${available_mirrors[0]}$iso_string"
else
	echo -e "$fg_reset${fg_bold}Reusing already downloaded iso...$fg_reset"
fi


echo -e "$fg_reset${fg_bold}Downloading verification files...$fg_reset"
curl -O "${available_mirrors[0]}$iso_string.sig"
curl -O "${available_mirrors[0]}sha512sums"

echo -n -e "$fg_reset${fg_bold}Checking PGP signature...$fg_reset "
gpg --verify "$iso_string.sig" "$iso_string" || exit 100
echo -e "$fg_reset${fg_green}OK"

echo -e "$fg_reset${fg_bold}Checking SHA512 sums...$fg_reset"
sha512sum --ignore-missing --check sha512sums || exit 101

echo -e "$fg_reset${fg_bold}Create torrent file...$fg_reset"
mktorrent --announce=http://dopsi.ch:6969/announce --web-seed="$(join_by ',' "${available_mirrors[@]}")" "$iso_string" 

# vim: set ts=4 sw=4:
