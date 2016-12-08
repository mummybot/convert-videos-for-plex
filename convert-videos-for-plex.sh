#!/bin/bash

# Initialise variables
function showHelp() {
echo "----------------"
echo "Convert videos for Plex Media Server"
echo "----------------"
echo "Converts all videos in nested folders to h264 and audio to aac using HandBrake with the Universal preset."
echo "This saves Plex from having to transcode files which is CPU intensive."
echo
echo "Prerequisites"
echo
echo "Requires HandBrackCLI and media-info."
echo "    $ brew cask install handbrakecli"
echo "    $ brew install media-info"
echo "This script uses glob patterns, which requires Bash 4+ and globstar enabled"
echo "    $ bash --version"
echo "    Mac https://gist.github.com/reggi/475793ea1846affbcfe8"
echo
echo "----------------"
echo
echo "Command line options:"
echo "-c          Codec to modify. Default is MPEG-4"
echo "-d          Delete original."
echo "-f          Force overwriting of files if already exist in output destination."
echo "-o          Output folder directory path."
echo "            Default is the same directory as the input file."
echo "-p          The directory path of the movies to be tidied."
echo "            Default is '.', the location of this script."
echo "-r          Run transcoding. Default is dry run."
echo "-s          Skip transcoding if there is already a matching file name in the output destination."
echo "            Force takes precedence over skipping files and will overwrite them if both flags present."
echo "-w          Workspace directory path for processing. Set a local directory for faster transcoding over network."
echo
echo "Examples:"
echo "    Dry run all movies in the Movies directory"
echo "        .convert-videos-for-plex.sh -p Movies"
echo
echo "    Transcode all movies in the current directory force overwriting matching .mp4 files."
echo "        .convert-videos-for-plex.sh -fr"
echo
echo "    Transcode all network movies using Desktop as temp directory and delete original files."
echo "        .convert-videos-for-plex.sh -rd -p /Volumes/Public/Movies -w ~/Desktop"
echo
}

codec="MPEG-4"
delete=false
path="./"
out=""
name=""
ext=".mp4"
force=false
skip=false
forceOverwrite=false
run=false
workspace=""
fileIn=""
fileOut=""
count=0

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

while getopts "h?dfsrp:o:c:w:" opt; do
    case "$opt" in
    h|\?)
        showHelp
        exit 0
        ;;
    d)  del=true
        ;;
    f)  force=true
        ;;
    s)  skip=true
        ;;
    r)  run=true
        ;;
    p)  path="$OPTARG"
        ;;
    o)  out="$OPTARG"
        ;;
    c)  codec="$OPTARG"
        ;;
    w)  workspace="$OPTARG"
        ;;
    esac
done

# Reset OPTIND
shift $((OPTIND-1))

# iterate through all avi/mkv/iso/img/mp4 files
# for i in $path/*.avi $path/*.mkv $path/*.iso $path/*.img $path/*.mp4; do
echo
if [[ $run == true ]]; then
    echo -e "${BLUE}TRANSCODING${NC}"
else
    echo -e "${BLUE}DRY RUN${NC}"
fi
echo "----------------"

for i in $path{,**/}*.*; do
    forceOverwrite=false

    # Prevent processing on non-files
    if [[ $i !=  *\*.* ]]; then

        if [[ $i == *.avi || $i == *.mkv || $i == *.iso || $i == *.img || $i == *.mp4 ]]; then
            ((count++))
            echo
            echo "${count}) Checking: "$i

            if [[ $(mediainfo --Inform="Video;%Format%" "$i") == *$codec* ]]; then
                # Get file name minus extension
                name=${i%.*}

                # Set out directory if different from current
                if [[ $out != "" ]]; then
                    name=${name##*/}
                    name=$out/$name
                fi

                # if there is already an .mp4 file overwrite or skip it (continue)
                if [[ -e $name$ext ]]; then
                    if [[ $force == false ]]; then
                        if [[ $skip == false ]]; then

                            read -p "'$name$ext' already exists. Do you wish to overwrite it?" -n 1 -r
                            echo
                            if [[ $REPLY =~ ^[Yy]$ ]]; then
                                forceOverwrite=true
                                echo -e "${BLUE}Overwriting:${NC} "$name$ext
                            else
                                echo -e "${RED}Skipping (already exists):${NC} "$name$ext
                                continue
                            fi
                        else
                            echo -e "${RED}Skipping (already exists):${NC} "$name$ext
                            continue
                        fi
                    else
                        forceOverwrite=true
                        echo -e "${BLUE}Overwriting:${NC} "$name$ext
                    fi
                fi

                echo "Transcoding: "${i} to $name$ext

                if [[ $run == true ]]; then
                    if [[ $workspace == "" ]]; then
                        $fileIn=$i
                        $fileOut="${name}"
                    else
                        echo $i $workspace
                        cp "$i" "${workspace}"
                        fileIn=$workspace${i##*/}
                        fileOut=${fileIn%.*}
                    fi

                    HandBrakeCLI -i "$fileIn" -o "$fileOut""_processing""${ext}" --preset="Universal" -O -N eng --native-dub -s "scan"
         
                    # if HandBrake did not exit gracefully, continue with next iteration
                    if [[ $? -ne 0 ]]; then
                        continue
                    else
                        if [[ $del == true ]]; then
                            rm -f $i
                        elif [[ $forceOverwrite == true ]]; then
                            rm -f "${name}""${ext}"
                        fi

                        mv "${fileOut}""_processing""${ext}" "${fileOut}""${ext}"
                        chmod 666 "${fileOut}""${ext}"

                        if [[ $workspace != "" ]]; then
                            echo "Copying from workspace ""${fileOut}""${ext}"" to "$(dirname "${name}""${ext}")
                            cp "${fileOut}""${ext}" $(dirname "${name}""${ext}")
                            rm -f "$fileIn"
                            rm -f "${fileOut}""${ext}"
                        fi
                        echo -e "${GREEN}Transcoded:${NC} "$name$ext
                    fi

                else
                    echo -e "${GREEN}Transcoded (DRY RUN):${NC} "$name$ext
                fi
            else
                echo -e "${RED}Skipping (not ${codec}, will already play in Plex)${NC}"
            fi
        fi
    fi
done

exit 0
