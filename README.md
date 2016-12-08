# Convert videos for Plex
Converts all videos in nested folders to h264 and audio to aac using HandBrake with the Universal preset. This saves Plex from having to transcode files which is CPU intensive.

This is only tested on Max OSX.

## Prerequisites

Requires HandBrackCLI (for transcoding) and media-info (for interrogation).

```bash
$ brew cask install handbrakecli
$ brew install media-info
```

This script uses glob patterns, which requires Bash 4+ and globstar enabled.

```bash
$ bash --version
```

[Instruction on how to install bash 4+ on Mac OSX](https://gist.github.com/reggi/475793ea1846affbcfe8)

## Usage

```bash
Command line options:
-c          Codec to modify. Default is MPEG-4
-f          Force overwriting of files if already exist in output destination.
-o          Output folder directory path.
            Default is the same directory as the input file.
-p          The directory path of the movies to be tidied.
            Default is '.', the location of this script.
-r          Run transcoding. Default is dry run.
-s          Skip transcoding if there is already a matching file name in the output destination.
            Force takes precedence over skipping files and will overwrite them if both flags present.

Examples:
    Dry run all movies in the Movies directory
        .convert-videos-for-plex.sh -p Movies

    Transcode all movies in the current directory force overwriting matching files.
        .convert-videos-for-plex.sh -fr
```