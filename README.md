# Convert videos for Plex
Converts all videos in nested folders to h264 and audio to aac using [HandBrakeCLI](https://handbrake.fr/docs/en/latest/cli/cli-options.html) with the 'Fast 1080p30' preset. This saves [Plex](https://www.plex.tv/) from having to [transcode files which is CPU intensive](https://support.plex.tv/hc/en-us/articles/200250377-Transcoding-Media) and not possible on certain underpowered NaSs (I'm looking at you [Seagate PersonalCloud](https://forums.plex.tv/discussion/151449/seagate-personal-cloud-support-for-plex)). This script is only tested on Max OSX High Sierra, although it should work on Linux.

Shameless plugs for search error messages:
* Plex browser web player: "This server is not powerful enough to convert video."
* Google Chromecast: "unable to cast. This server is not powerful enough to convert video."
* iOS app casting: "Uh-oh! Something went wrong playing your media. Please try again.""

This library is for batch transcoding an existing bunch of movies with minimal effort. For the fully featured gold plated whizz bang all singing and all dancing video transcoding pipeline check out the awesome [sickbeard_mp4_automator](https://github.com/mdhiggins/sickbeard_mp4_automator).

## Prerequisites

Requires [HandBrakeCLI](https://handbrake.fr/docs/en/latest/cli/cli-options.html) (for transcoding) and [media-info](https://mediaarea.net/nn/MediaInfo) (for interrogation). Install with [Homebrew](http://brew.sh/).

```bash
$ brew install handbrake
$ brew install media-info
```

Packages are also available on Linux, here's an example using Arch, package names may vary per repo:

```bash
$ sudo pacman -S handbrake-cli mediainfo
```

This script uses glob patterns for traversing directories, which requires Bash 4+ and globstar enabled.

```bash
$ bash --version
```

[Instructions on how to install bash 4+ on Mac OSX](https://gist.github.com/reggi/475793ea1846affbcfe8)

## Usage

```bash
Command line options:
-a          Select an audio track to use.
-b          Select a subtitle track to burn in.
-c          Codec to modify. Default is MPEG-4
-d          Delete original.
-f          Force overwriting of files if already exist in output destination.
-o          Output folder directory path.
            Default is the same directory as the input file.
-p          The directory path of the movies to be tidied.
            Default is '.', the location of this script.
-q          Quality of HandBrake encoding preset. Default is 'Fast 1080p30'.
            For a full list of presets in CMD line run:
            HandBrakeCLI --preset-list
            https://handbrake.fr/docs/en/latest/workflow/select-preset.html
-r          Run transcoding. Exclude for dry run.
-s          Skip transcoding if there is already a matching file name in the output destination.
            Force takes precedence over skipping files and will overwrite them if both flags present.
            This is recommended when running multiple machines on the same shared directory.
-w          Workspace directory path for processing. Set a local directory for faster transcoding over network.

Examples:
    Dry run all movies in the Movies directory
   
    `.convert-videos-for-plex.sh -p Movies`

    Transcode all movies in the current directory force overwriting matching .mp4 files.
        .convert-videos-for-plex.sh -fr

    Transcode all network movies using Desktop as temp directory and delete original files.
        .convert-videos-for-plex.sh -rd -p /Volumes/Public/Movies -w ~/Desktop

    Transcode all network movies from multiple machines (note the 's' parameter).
        .convert-videos-for-plex.sh -rds -p /Volumes/Public/Movies -w ~/Desktop
```

## Things to consider

* **Run a test on a single movie first.** Run a test on a folder with only one movie inside first before running on your entire library and leaving for work/sleep/holiday. You don't want to come back and find the house on fire, or at least the video working as expected: will it play on your relevant devices, is the quality and file size acceptable.
* **Do a dry run.** Run a dry run first and read the output, before using the ```-r``` switch. Make sure everything looks right and fix anything that doesn't manually. For example if you run without the force switch (-f) and have films with .mp4 extension then it is going to be prompting you Y/N to overwrite each and every one.
* **Break transcoding your library into chunks.** Transcoding your hours of christmas home movie and wedding footage TAKES A LONG TIME! If you have gigs of the stuff, do it in managable chunks. If you computer goes to sleep, or one of the kids jumps on it then you'll end up scrambling around trying to work out what transcoded and what didn't.
* **Your file sizes may increase.** This uses the HandBrake 'Fast 1080p30' preset which may increase the size of your movie file depending on how efficiently it was encoded to start with. Make sure you have more space on your hard drive.
* **Changes are permanent.** Beware using the delete flag ```-d```, you cannot get the original films back once you delete them.
* **Files may fail.** I have found that sometimes the Handbrake CLI fails to transcode the entire movie: ```incomplete frame```, ```Header missing```, ```marker does not match f_code```. The total playable length may end up shorter and file size signifcantly lower. This will be due to a less than ideal file (maybe slightly corrupted) but most video players can compensate so it is not obviously noticable when watching. After running on a folder, I use the ```tree -h``` command (```brew install tree```) to output file names and size, then do a manual compare in excel to alert me to any files which seem erroneous. Using the [HandBrake GUI](https://handbrake.fr/) application appears to work around many of the issues, otherwise you may need to try another converter e.g. [ffmpeg](https://trac.ffmpeg.org/wiki/CompilationGuide/MacOSX). *If someone asks, I could add a before/after file size comaprison with percentage tolerance and option to alert or not perform transformation. However currently I don't need it.*
* **Handbrake can lock files.** Sometimes Handbrake doesn't end properly; the process will lock the original file so the script can't delete it. You will need to unlock these files (context menu > info > click lock icon) to delete them manually.

## Running multiple machines

So. You've got yourself a few computers lying around. Good for you. Now - time to put that distributed CPU power to good use!

This setup is especially effective on shared NAS drives, where video files can be accessed from multiple devices at once.

To avoid multiple machines stepping on each other's toes, a `.lock` file is created to let other computers know that the given file is already been looked at. When the script is iterating over the files, it will first check if a `.lock` file exists. If it does find one, it will move over to the next file. As soon as it starts analysing the file, it creates the lock file. At the point that the script is complete, it will remove the lock file and move on.

With this process, multiple machines can be working on the same directory, leapfrogging over each other to get the job done faster.

#### Caveats

- **If you don't** enable either `skip (-s)` or `force(-f)`, you will most likely be prompted about existing files, effectively halting the task.
- If you stop a process early, the `.lock` file may not be removed. To start the process again, you will need to manually delete the file.
- If using on a NAS drive, accessing files from multiple sources may cause read and write speeds to suffer.

## Disclaimer

This is an automated script for modifying your home movie collection. Please be aware that things may go wrong or unexpected, my code could be awful or the software update gods decide to change the environment from when this was written. You may be holding your tongue out of the left side of your mouth while I'm holding mine out the right. **I bear no responsibility for any loss of priceless "first steps" videos, use this software at your own risk!** At least I hope this can be useful for someone else out there.

## Credit

Stole the core of HandBrake CLI usage from http://pastebin.com/9JnS23fK.

