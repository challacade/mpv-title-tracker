-- title-tracker.lua writes the current media title to a text file
-- useful for streaming with OBS, to display song title

local mp = require 'mp'
local utils = require 'mp.utils'

-- Default saves to MPV config directory, change path as needed
local output_file = mp.command_native({"expand-path", "~~/current_song.txt"})

-- Fallback if expand-path fails
if not output_file or output_file == "" then
    local config_dir = os.getenv("APPDATA") and (os.getenv("APPDATA") .. "\\mpv") or "."
    output_file = config_dir .. "\\current_song.txt"
end

local default_text = "..."
local last_written_title = nil  -- Track what was last written to prevent duplicates

-- Function to write title to file
local function write_title_to_file(title)
    local title_to_write = title or default_text
    
    -- Only write if the title has actually changed
    if title_to_write == last_written_title then
        return  -- Skip writing if it's the same as last time
    end
    
    local file = io.open(output_file, "w")
    if file then
        file:write(title_to_write)
        file:close()
        last_written_title = title_to_write  -- Remember what we wrote
        mp.msg.info("Title written to file: " .. title_to_write)
    else
        mp.msg.error("Could not open file for writing: " .. output_file)
    end
end

-- Function to get the current title
local function get_current_title()
    -- Try to get title from metadata first
    local title = mp.get_property("media-title")
    
    -- If no media title, try other metadata fields
    if not title or title == "" then
        title = mp.get_property("metadata/title")
    end
    
    -- If still no title, try artist - title format
    if not title or title == "" then
        local artist = mp.get_property("metadata/artist")
        local track_title = mp.get_property("metadata/title")
        
        if artist and track_title then
            title = artist .. " - " .. track_title
        elseif track_title then
            title = track_title
        elseif artist then
            title = artist
        end
    end
    
    -- If still no title, use filename without extension
    if not title or title == "" then
        local filename = mp.get_property("filename")
        if filename then
            -- Remove file extension
            title = filename:match("(.+)%..+$") or filename
        end
    end
    
    return title
end

-- Function called when a new file starts playing
local function on_file_loaded()
    local title = get_current_title()
    write_title_to_file(title)
end

-- Function called when playback ends
local function on_end_file()
    --write_title_to_file(default_text) -- Disabled by default
end

-- Function called when metadata changes (useful for streaming audio)
local function on_metadata_change()
    local title = get_current_title()
    if title and title ~= "" then
        write_title_to_file(title)
    end
end

-- Register event handlers
mp.register_event("file-loaded", on_file_loaded)
mp.register_event("end-file", on_end_file)

-- Also watch for metadata changes (useful for radio streams)
mp.observe_property("metadata", "native", function()
    on_metadata_change()
end)

-- Initialize with default text when script loads
write_title_to_file(default_text)

-- Print status message
mp.msg.info("Title Tracker loaded; titles will be written to: " .. output_file)