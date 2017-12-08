# al32-mktorrent

Torrent creation script for [ArchLinux32](https://archlinux32.org), with upload
capabilities via `scp` and to [hefur](https://github.com/abique/hefur).

The latest torrents are hosted on [static.dopsi.ch](https://static.dopsi.ch/al32/)
along with the RSS feeds (for [i686](https://static.dopsi.ch/al32/feed_i686.rss) and
[dual](https://static.dopsi.ch/al32/feed_dual.rss)).

## Usage

    al32-mktorrent.sh [ -d date ] [ -w webdir ] [ -t hefurdir ] [ arch... ]

If no `arch` is specified both `i686` and `dual` will be generated.
If no `date` is specified, the script will prompt for a date during the process.
If `hefurdir` or `webdir` is not specified no file will be uploaded to 
the corresponding server.

## Features

  * [X] Torrent creation
    * [X] Create a torrent file per architecture
      * [X] Obtain the latest mirrorlist
      * [X] Check mirrors for ISO availability
      * [X] Download ISO
      * [X] Check ISO
    * [X] Create both torrent files at once
    * [X] Create a magnet link per architecture
  * [ ] Torrent upload
    * [X] Upload the torrent file to a web server via SSH
    * [X] Upload the torrent file to a torrent tracker via SSH
    * [ ] Upload the torrent to transmission-server
  * [ ] Inform the world of the new torrent file
    * [X] Add the magnet link to a RSS feed
    * [X] Upload the new RSS feed to the server
    * [ ] Send an email to the arch-ports list

## License

> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU General Public License as published by
> the Free Software Foundation, either version 3 of the License, or
> (at your option) any later version.
>
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU General Public License for more details.
>
> You should have received a copy of the GNU General Public License
> along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Author

Copyright (c) 2017 Simon Doppler (dopsi)
