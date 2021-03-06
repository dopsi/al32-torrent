# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#! /bin/bash
set -euo pipefail

function join_by { local IFS="$1"; shift; echo "$*"; }

usage () {
	echo "Usage: $0 [-d date] [-w webdir] [-t hefurdir] [arch...]"
}

fg_green="\033[32m"
fg_red="\033[31m"
fg_blue="\033[34m"
fg_reset="\033[0m"
fg_bold="\033[1m"

MIRRORLIST_FILE="https://raw.githubusercontent.com/archlinux32/packages/master/core/pacman-mirrorlist/mirrorlist"

function cleanup () {
	echo -n -e "$fg_reset${fg_bold}Cleaning up directory...$fg_reset "
	rm -f ./*.sig ./*.torrent ./*.rss sha512sums
}

function create_torrent_for_arch () {
	declare -a available_mirrors
	mirrorlist="$(curl "$MIRRORLIST_FILE" 2>/dev/null | grep Server | cut -d '=' -f 2 | sed -e 's/\s//g;s_$arch/$repo_archisos/_')"

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
	if [ -f "$iso_string.torrent" ] ; then
		rm "$iso_string.torrent"
	fi
	mktorrent --announce=http://dopsi.ch:6969/announce --web-seed="$(join_by ',' "${available_mirrors[@]}")" "$iso_string"

	echo -e "$fg_reset${fg_bold}Create magnet link...$fg_reset"
	magnet_link="$(transmission-show --magnet "$iso_string.torrent")"
	echo "$magnet_link"

	echo -e "$fg_reset${fg_bold}Create RSS feed files...$fg_reset"
	python magnet2feed.py "$magnet_link" "$iso_date"
}

function upload_file_to_remote_dir {
	if [ -f "$1" ] && [ -n "$2" ] ; then
		echo -e "$fg_reset${fg_bold}Uploading file$fg_reset ${fg_blue}$1$fg_reset ${fg_bold}to$fg_reset ${fg_blue}$1$fg_reset $fg_bold...$fg_reset"
		scp "$1" "$2"
	fi
}

### Check for if required programs are present

which mktorrent 2>&1 >/dev/null || (
	echo "Missing mktorrent"
	exit 1
)

python -c "import feedgenerator" 2>/dev/null || (
	echo "Missing python module feedgenerator"
	exit 1
)

which transmission-show 2>&1 >/dev/null || (
	echo "Missing transmission-show"
	exit 1
)

### Actual program

declare -a architectures=("i686" "dual")
iso_date=''
web_dir=''
hefur_dir=''

while getopts "d:w:t:h" o; do
	case "${o}" in
		d)
			iso_date=${OPTARG}
			;;
		t)
			hefur_dir=${OPTARG}
			;;
		w)
			web_dir=${OPTARG}
			;;
		h)
			usage
			exit
			;;
		*)
			echo "$0: unknown option ${o}" >&2
			usage
			;;
	esac
done
shift $((OPTIND-1))

if [ "$#" -gt 0 ] ; then
	architectures=($@)
fi

[ -z "$iso_date" ] && read -r -p "Date of the ISO: " iso_date

cleanup

for a in "${architectures[@]}" ; do
	create_torrent_for_arch "$a"
done

for a in "${architectures[@]}" ; do
	torrent_filename="archlinux-$iso_date-$a.iso.torrent"
	if [ -n "$web_dir" ] ; then
		feed_filename="feed_$a.rss"
		upload_file_to_remote_dir "$torrent_filename" "$web_dir"
		upload_file_to_remote_dir "$feed_filename" "$web_dir"
	fi
	if [ -n "$hefur_dir" ] ; then
		upload_file_to_remote_dir "$torrent_filename" "$hefur_dir"
	fi
done

# vim: set ts=4 sw=4:
