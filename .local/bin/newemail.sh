#!/bin/bash
# takes unix timestamp and converts to base36
# ht: https://en.wikipedia.org/wiki/Base36#bash_implementation

value=$(date +%s)
result=""
base36="0123456789abcdefghijklmnopqrstuvwxyz"
while true; do
	result=${base36:((value%36)):1}${result}
	if [ $((value=${value}/36)) -eq 0 ]; then
		break
	fi
done

echo ""
echo "$result"@sizza.net
echo ""

if command -v xclip >/dev/null 2>&1; then
    echo "$result"@sizza.net | xclip -selection clipboard
else
    echo "xclip is not installed"
fi

sleep 10s
