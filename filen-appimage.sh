#! /usr/bin/env bash

script="$(realpath "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")"
download="$(xdg-user-dir DOWNLOAD)"
share="${XDG_DATA_HOME:-$HOME/.local/share}"
dest="$download/filen_x86_64.AppImage"
link="$share/applications/filen-desktop-appimage.desktop"
icon="$share/icons/filen.png"
icon_url='https://raw.githubusercontent.com/FilenCloudDienste/filen-desktop/master/src/assets/images/dark_logo.png'
url="$(curl -sL https://api.github.com/repos/FilenCloudDienste/filen-desktop/releases | grep AppImage | grep x86_64 | grep https: | sort | head -n 1 | sed -E 's/.+https(.+)_x86_64.AppImage.*/https\1_x86_64.AppImage/')"

echo "Downloading $url to $dest"
curl -sSL -z "$dest" "$url" -o "$dest"
if [ ! -e "$dest" ]; then
    echo 'Not downloaded'
    exit 1
fi

if [ ! -e "$icon" ]; then
    echo "Downloading $icon_url to $icon"
    curl -sSL "$icon_url" -o "$icon"
else
    echo "Icon: $icon"
fi

if [ ! -e "$link" ]; then
    echo "Creating $link"
    mkdir -p "$(dirname "$link")"
    cat <<EOF >"$link"
[Desktop Entry]
Name=Filen Desktop
Exec=$script
Comment=Run $script
Icon=$(basename "$icon")
Terminal=false
Type=Application
MimeType=
Categories=Network;
Keywords=privacy;
EOF
    chmod +x "$link"
    update-desktop-database -v "$(dirname "$link")"
else
    echo "Link: $link"
fi

echo "To uninstall, run rm -f \"$dest\" \"$link\" \"$icon\""
echo "Executing $dest"
chmod +x "$dest" && "$dest"
