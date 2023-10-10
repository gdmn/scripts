#! /usr/bin/env bash

script="$(realpath "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")"
download="$(xdg-user-dir DOWNLOAD)"
share="${XDG_DATA_HOME:-$HOME/.local/share}"
dest="$download/simplex-desktop-x86_64.AppImage"
link="$share/applications/simplex-desktop-appimage.desktop"
icon="$share/icons/simplex.svg"
#icon_url='https://raw.githubusercontent.com/simplex-chat/simplex-chat/stable/apps/multiplatform/common/src/commonMain/resources/distribute/simplex.png'
#icon_url='https://raw.githubusercontent.com/simplex-chat/website/master/app-demo/assets/assets/simpleX.png'
icon_url='https://raw.githubusercontent.com/simplex-chat/simplex-chat/stable/website/src/img/new/logo-symbol-light.svg'
url="$(curl -sL https://api.github.com/repos/simplex-chat/simplex-chat/releases | grep AppImage | grep x86_64 | grep https: | grep browser_download_url | sort | tail -n 1 | sed -E 's/.+https(.+)AppImage.*/https\1AppImage/')"

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
Name=SimpleX Chat Desktop
Exec=$script
Comment=Run $script
Icon=$(basename "$icon")
Terminal=false
Type=Application
MimeType=
Categories=Chat;InstantMessaging;Network;
GenericName=Secure chat client
Keywords=chat;messaging;privacy;
EOF
    chmod +x "$link"
    update-desktop-database -v "$(dirname "$link")"
else
    echo "Link: $link"
fi

echo "To uninstall, run rm -f \"$dest\" \"$link\" \"$icon\""
echo "Executing $dest"
chmod +x "$dest" && "$dest"

