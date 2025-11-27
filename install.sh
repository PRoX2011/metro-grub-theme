#!/bin/bash

# Theme name and installation directory
THEME_NAME="metro"
THEME_DIR="/boot/grub/themes/$THEME_NAME"
THEME_FILE="theme.txt"
BG_FILE="background.png"
SELECT_C_FILE="select_c.png"
GRUB_CONFIG="/etc/default/grub"
FONT="saira.pf2"

# --- Step 1: Checking permissions and theme file existence ---
if [ "$EUID" -ne 0 ]; then
echo "The script must be run with superuser (root) privileges. Use 'sudo'."
exit 1
fi

if [ ! -f "$THEME_FILE" ]; then
echo "The theme file '$THEME_FILE' was not found in the current directory."
exit 1
fi

echo "Starting installation of theme '$THEME_NAME'..."
echo "---"

# --- Step 2: Creating the theme directory and copying the file ---
echo "Creating the theme directory: $THEME_DIR"
mkdir -p "$THEME_DIR"

echo "Copying the theme file to: $THEME_DIR/$THEME_FILE"
cp "$THEME_FILE" "$THEME_DIR/theme.txt"

cp "$BG_FILE" "$THEME_DIR/background.png"

cp "$SELECT_C_FILE" "$THEME_DIR/select_c.png"

cp "$FONT" "$THEME_DIR/saira.pf2"

# --- Step 3: Modifying the GRUB configuration file ---
echo "Modifying the GRUB configuration file: $GRUB_CONFIG"

# Delete previous theme settings, if any
sed -i '/^GRUB_THEME=/d' "$GRUB_CONFIG"

# Add a new theme setting
echo "GRUB_THEME=\"$THEME_DIR/theme.txt\"" >> "$GRUB_CONFIG"

# Make sure the GRUB_TERMINAL_OUTPUT variable doesn't interfere with the display
# Comment it out if it exists so the theme works
sed -i 's/^GRUB_TERMINAL_OUTPUT/#GRUB_TERMINAL_OUTPUT/' "$GRUB_CONFIG"

# --- Step 4: Updating GRUB configuration ---
echo "Updating GRUB configuration. This may take some time."

if command -v update-grub &> /dev/null; then
update-grub
elif command -v grub-mkconfig &> /dev/null; then
grub-mkconfig -o /boot/grub/grub.cfg
else
echo "No command found to update the GRUB configuration (update-grub or grub-mkconfig)."
echo "Please run the update command manually after the script completes."
exit 1
fi

echo "---"
echo "✅ Theme installation for '$THEME_NAME' is complete."
echo "The new theme will be active after reboot."
