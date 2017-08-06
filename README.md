# al32-mktorrent

Torrent creation script for [ArchLinux32](https://archlinux32.org)

## Usage

    al32-mktorrent.sh [ -d date ] [ i686 | dual ]

If no architecture is specified, the script will default to `i686`.
If no date is specified, the script will prompt for a date during the process.

## Features

* [ ] Torrent creation
  * [x] Create a torrent file per architecture
    * [x] Obtain the latest mirrorlist
    * [x] Check mirrors for ISO availability
    * [x] Download ISO
    * [x] Check ISO
  * [ ] Create both torrent files at once
  * [x] Create a magnet link per architecture
* [ ] Torrent upload
  * [ ] Upload the torrent file to a server via SSH (for sharing)
  * [ ] Upload the torrent to transmission-server
* [ ] Inform the world of the new torrent file
  * [ ] Add the magnet link to a RSS feed
  * [ ] Upload the new RSS feed to the server
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
