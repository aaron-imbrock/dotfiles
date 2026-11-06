#!/usr/bin/env bash

set -eu

# Default values
wait_before_switch=30
convert_to_png=false

usage()
{
  cat <<EOF

Usage: ${0##*/} [OPTION...]

Capture X11 framebuffer from a local TTY and save to an xwd file under the user's home directory
before sleeping a set number of seconds.

Options:
    -c          Convert xwd file to png
    -s <N>      Sleep <N> seconds between making screenshots (default: 120)
    -h          Show this help message and exit

EOF
}

get_epoch()
{
    echo "$(date +%s)"
}

get_screencapture()
{
    local filename=$(get_epoch).xwd
    DISPLAY=':0' xwd -silent -root -out ~/"$filename"
    echo "$filename"
}

convert2png()
{
    local input_file="$1"
    local output_file="${input_file%.xwd}.png"
    convert "$input_file" "$output_file" && echo "Converted $input_file to $output_file"
}

# Parse options
while getopts 'cs:h' arg; do
    case "$arg" in
        c)
            convert_to_png=true
            ;;
        s)
            wait_before_switch="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

# Main loop
while true; do
    captured_file=$(get_screencapture)
    echo "Captured screenshot: $captured_file"
    if [ "$convert_to_png" = true ]; then
        convert2png "$captured_file"
    fi
    sleep "$wait_before_switch"
done
