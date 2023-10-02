#!/bin/bash
# https://bbs.archlinux.org/viewtopic.php?pid=2017886#p2017886

locations=("newark" "singapore" "london" "frankfurt" "dallas" "toronto1" "syd1" "atlanta" "tokyo2" "mumbai1" "fremont")
sizes=("100MB" "1GB")
printf " 1. Newark, USA\n 2. Singapore\n 3. London, UK\n 4. Frankfurt, Deutschland\n\
 5. Dallas, USA\n 6. Toronto, Canada\n 7. Sidney, Australia\n 8. Atlanta, USA\n\
 9. 東京都 (Tokyo), 日本国 (Japan)\n10. मुंबई (Bombay), Bhārat (India)\n11. Fremont, USA\n"
read -p "Enter location: " location
location=${locations[location-1]}
printf " 1. 100MB\n 2. 1GB\n"
read -n 1 -p "Slect size: " size
size=${sizes[size-1]}
echo
wget -nv --show-progress -O /dev/null http://speedtest.${location}.linode.com/${size}-${location}.bin