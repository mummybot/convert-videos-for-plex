# Convert videos for Plex
Converts all videos in nested folders to h264 and audio to aac using [HandBrakeCLI](https://handbrake.fr/docs/en/latest/cli/cli-options.html) with the Universal preset. This saves [Plex](https://www.plex.tv/) from having to [transcode files which is CPU intensive](https://support.plex.tv/hc/en-us/articles/200250377-Transcoding-Media) and not possible on certain underpowered NaSs (I'm looking at you [Seagate PersonalCloud](https://forums.plex.tv/discussion/151449/seagate-personal-cloud-support-for-plex)). This script is only tested on Max OSX Sierra.

Shameless plugs for search error messages:
* Plex browser web player: "This server is not powerful enough to convert video."
* Google Chromecast: "unable to cast. This server is not powerful enough to convert video."
* iOS app casting: "Uh-oh! Something went wrong playing your media. Please try again.""

This library is for batch transcoding an existing bunch of movies with minimal effort. For the fully featured gold plated whizz bang all singing and all dancing video transcoding pipeline check out the awesome [sickbeard_mp4_automator](https://github.com/mdhiggins/sickbeard_mp4_automator).

## Prerequisites

Requires [HandBrackCLI](https://handbrake.fr/docs/en/latest/cli/cli-options.html) (for transcoding) and [media-info](https://mediaarea.net/nn/MediaInfo) (for interrogation). Install with [Homebrew](http://brew.sh/).

```bash
$ brew cask install handbrakecli
$ brew install media-info
```

This script uses glob patterns for traversing directories, which requires Bash 4+ and globstar enabled.

```bash
$ bash --version
```

[Instructions on how to install bash 4+ on Mac OSX](https://gist.github.com/reggi/475793ea1846affbcfe8)

## Usage

```bash
Command line options:
-c          Codec to modify. Default is MPEG-4
-d          Delete original.
-f          Force overwriting of files if already exist in output destination.
-o          Output folder directory path.
            Default is the same directory as the input file.
-p          The directory path of the movies to be tidied.
            Default is '.', the location of this script.
-r          Run transcoding. Default is dry run.
-s          Skip transcoding if there is already a matching file name in the output destination.
            Force takes precedence over skipping files and will overwrite them if both flags present.
-w          Workspace directory path for processing. Set a local directory for faster transcoding over network.

Examples:
    Dry run all movies in the Movies directory
        .convert-videos-for-plex.sh -p Movies

    Transcode all movies in the current directory force overwriting matching .mp4 files.
        .convert-videos-for-plex.sh -fr

    Transcode all network movies using Desktop as temp directory and delete original files.
        .convert-videos-for-plex.sh -rd -p /Volumes/Public/Movies -w ~/Desktop
```

## Things to consider

* **Run a test on a single movie first.** Run a test on a folder with only one movie inside first before running on your entire library and leaving for work/sleep/holiday. You don't want to come back and find the house on fire, or at least the video working as expected: will it play on your relevant devices, is the quality and file size acceptable.
* **Do a dry run.** Run a dry run first and read the output, before using the ```-r``` switch. Make sure everything looks right and fix anything that doesn't manually. For example if you run without the force switch (-f) and have films with .mp4 extension then it is going to be prompting you Y/N to overwrite each and every one.
* **Break transcoding your library into chunks.** Transcoding your hours of christmas home movie and wedding footage TAKES A LONG TIME! If you have gigs of the stuff, do it in managable chunks. If you computer goes to sleep, or one of the kids jumps on it then you'll end up scrambling around trying to work out what transcoded and what didn't.
* **Your file sizes may increase.** This uses the HandBrake universal preset which may increase the size of your movie file depending on how efficiently it was encoded to start with. Make sure you have more space on your hard drive.
* **Changes are permanent.** Beware using the delete flag ```-d```, you cannot get the original films back once you delete them.

## Disclaimer

This is an automated script for modifying your home movie collection. Please be aware that things may go wrong or unexpected, my code could be awful or the software update gods decide to change the environment from when this was written. You may be holding your tongue out of the left side of your mouth while I'm holding mine out the right. **I bear no responsibility for any loss of priceless "first steps" videos, use this software at your own risk!** At least I hope this can be useful for someone else out there.

## Credit

Stole the core of HandBracke CLI usage from http://pastebin.com/9JnS23fK.

