# mpv-title-tracker

MPV is an open-source media player, and this script (title-tracker.lua) will update a text file whenever a new song starts playing. This is useful for streamers, since OBS can read from this file to display the song title.

## Installing MPV Lua Scripts

1. **Locate your MPV config directory:**
   - **Windows:** `C:\Users\[username]\AppData\Roaming\mpv\`
   - **Linux/macOS:** `~/.config/mpv/`

2. **Add the script:**
   - Create a `scripts` folder if it does not already exist
   - Place the file `title-tracker.lua` in the `scripts` folder

3. **Restart MPV** - the script will load automatically

**Example path:** `C:\Users\username\AppData\Roaming\mpv\scripts\title-tracker.lua`
