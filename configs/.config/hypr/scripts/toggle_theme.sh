#!/bin/bash
#!/bin/bash
#!/bin/bash

# ================= Configuration =================
# Themes (Must be installed on your system)
DARK_THEME="Adwaita-dark"
LIGHT_THEME="Adwaita"

# Icon Theme (Papirus is best for Arch)
ICON_THEME="Papirus"
CURSOR_THEME="Adwaita"

# Qt/KDE Color Schemes (Files usually in /usr/share/color-schemes/)
# You can find these names by running `ls /usr/share/color-schemes/`
QT_DARK_SCHEME="BreezeDark"
QT_LIGHT_SCHEME="BreezeLight"

# Config Files
GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"
GTK4_FILE="$HOME/.config/gtk-4.0/settings.ini"
QT5_FILE="$HOME/.config/qt5ct/qt5ct.conf"
QT6_FILE="$HOME/.config/qt6ct/qt6ct.conf"

# ================= Logic =================

# 1. Check current mode using GSettings
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$CURRENT_MODE" == "'prefer-dark'" ]; then
  # Switch to LIGHT
  echo "☀️ Switching to Light Mode..."
  NEW_SCHEME="default"
  NEW_THEME="$LIGHT_THEME"
  QT_SCHEME="$QT_LIGHT_SCHEME"
  GTK_PREFER_DARK=0
  NOTIFY_ICON="weather-clear"
  NOTIFY_MSG="Light Mode Active"
else
  # Switch to DARK
  echo "🌑 Switching to Dark Mode..."
  NEW_SCHEME="prefer-dark"
  NEW_THEME="$DARK_THEME"
  QT_SCHEME="$QT_DARK_SCHEME"
  GTK_PREFER_DARK=1
  NOTIFY_ICON="weather-clear-night"
  NOTIFY_MSG="Dark Mode Active"
fi

# 2. Apply GSettings (Modern GTK Apps)
gsettings set org.gnome.desktop.interface color-scheme "$NEW_SCHEME"
gsettings set org.gnome.desktop.interface gtk-theme "$NEW_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"

# 3. Update GTK 3.0 & 4.0 Configs (Legacy GTK)
for CONFIG in "$GTK3_FILE" "$GTK4_FILE"; do
  mkdir -p "$(dirname "$CONFIG")"
  cat >"$CONFIG" <<EOF
[Settings]
gtk-application-prefer-dark-theme=$GTK_PREFER_DARK
gtk-theme-name=$NEW_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-cursor-theme-name=$CURSOR_THEME
gtk-font-name=Cantarell 11
EOF
done

# 4. Update Qt/KDE Configs (qt5ct/qt6ct)
# This uses 'sed' to replace the "color_scheme_path" line in your config
if [ -f "$QT5_FILE" ]; then
  sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/color-schemes/${QT_SCHEME}.colors|g" "$QT5_FILE"
  sed -i "s|^icon_theme=.*|icon_theme=${ICON_THEME}|g" "$QT5_FILE"
fi

if [ -f "$QT6_FILE" ]; then
  sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/color-schemes/${QT_SCHEME}.colors|g" "$QT6_FILE"
  sed -i "s|^icon_theme=.*|icon_theme=${ICON_THEME}|g" "$QT6_FILE"
fi

# 5. Flatpak Overrides
if command -v flatpak &>/dev/null; then
  flatpak override --user --env=GTK_THEME="$NEW_THEME"
fi

# 6. Notify User
notify-send -u normal -i "$NOTIFY_ICON" -t 2000 "System Theme" "$NOTIFY_MSG"

echo "✅ Done. Note: Qt apps may need a restart."
