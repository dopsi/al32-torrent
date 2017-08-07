from feedgenerator import Rss201rev2Feed
import sys
from os.path import basename

feed_url = 'https://static.dopsi.ch/al32/feed_{arch}.rss'
architectures = ['i686', 'dual']


def main(link, date):
    for arch in architectures:
        feed = Rss201rev2Feed(title='ArchLinux32 torrent download feed ({arch} ISO)'.format(arch=arch),
                              link=feed_url,
                              description="A torrent feed to download the latest ArchLinux32 {arch} iso".format(
                                  arch=arch
                              ),
                              language='en')

        feed.add_item(title='ArchLinux32 {arch} {date}'.format(arch=arch, date=date),
                      link=link,
                      description='ArchLinux32 {arch} {date}'.format(arch=arch, date=date))

        with open(basename(feed_url).format(arch=arch), mode='w') as feed_file:
            feed.write(feed_file, 'utf-8')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Error: {cmd} magnet date'.format(cmd=sys.argv[0]))

    main(link=sys.argv[1], date=sys.argv[2])
