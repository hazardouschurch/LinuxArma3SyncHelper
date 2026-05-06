#!/bin/bash
# ============================================================================
# LinuxArma3SyncHelper Launcher Script for Linux
# ============================================================================
# 
# This script automates the process of launching ArmA 3 through Steam with
# mods managed by ArmA3Sync on Linux.
#
# WHAT IT DOES:
#   1. Launches the ArmA3Sync Java application
#   2. Waits for you to select mods and click "Play"
#   3. Captures the generated mod list from ArmA3Sync's output
#   4. Automatically closes ArmA3Sync after the mod list is generated
#   5. Launches ArmA 3 via Steam with the captured mod parameters
#   6. Optionally runs Arma3Helper.sh and/or OpenTrack
#
# FEATURES:
#   - Download and manage mods exactly as you would on Windows
#   - Add extra startup parameters. highly suggested (--force-grab-cursor, -noWindowBorder -window)
#   - Start with profile and unit supported
#   - Mod order is preserved like in ArmA3Sync
#   - Events and Join Server functionality works
#
# KNOWN LIMITATIONS:
#   - Cannot launch external applications like on Windows
#   - AIA and tools have not been tested
#   - Not all DLC have been tested (DLC can be launched via startup parameters)
#   - Do not use this to launch an ArmA/ArmA3Sync server there are better methods
#
# IMPORTANT:
#   ArmA3Sync will freeze after clicking "Play". The script automatically
#   handles this by waiting for the mod list to be generated before closing
#   the application. This is expected behavior and is required to capture the
#   output. Since its working I wont be fixing this.
#
# DEPENDENCIES:
#   - Java Runtime Environment (JRE)
#   - Steam (installed and logged in)
#   - ArmA3Sync (Java application)
#   - protontricks (only if using OpenTrack)
#
# PREREQUISITES:
#   1. Launch ARMA 3 to the desktop BEFORE running this script.
#      This ensures the Steam overlay and Proton environment are ready.
#   2. Create an empty dummy.sh file in your ArmA3Sync folder.
#      In ArmA3Sync, set the launch parameters to point to this dummy.sh.
#      The script intercepts the launch command from the dummy.sh output.
#   3. Configure the variables below to match your system paths.
#   4. Use the jar files I provide or copy the install from windows vm. 
#
# CONFIGURATION:
#   Edit the variables in the CONFIGURATION section below.
#   Only the REQUIRED variables must be changed.
#   Optional features are disabled by default.
#
# USAGE:
#   ./arma3sync.sh
#   you can also make it launchable with a desktop application
#   In my distro omarchy you make a arma3sync.desktop file in the ~/.local/share/applications/
#   here is mine as an example
#   [Desktop Entry]
#   Name=Arma3Sync
#   Comment=use to download mods and play modded arma3
#   Exec=/home/hazardouschurch/Arma/ArmA3Sync/LinuxArma3SyncHelper.sh
#   Icon=/home/hazardouschurch/Arma/ArmA3Sync/ArmA3Sync.ico
#   Terminal=false
#   Type=Application
#   Categories=Game;
#
#   If you are looking for a unit
#   We are open and welcoming of all players at ARCOMM
#   https://arcomm.co.uk/
# ============================================================================

source ~/.bashrc
cd "$(dirname "$0")"

# ============================================
# CONFIGURATION - Edit these for your setup
# ============================================

# REQUIRED - ArmA3Sync installation folder
# This is the folder containing ArmA3Sync.jar
# Example /home/hazardouschurch/Arma/ArmA3Sync
ARMA3SYNC_DIR="/home/church/Arma/ArmA3Sync/test"

# REQUIRED - ArmA3Sync JAR filename
# Usually this is ArmA3Sync.jar and does not need to be changed
JAR_FILE="ArmA3Sync.jar"

# REQUIRED - Steam App ID for Arma 3
# Default is 107410. Only change if you know what you're doing.
STEAM_APP_ID="107410"

# OPTIONAL - Arma3Helper script
# Set to the full path of your helper script, or leave empty to disable.
# Example: ARMA3_HELPER="/home/username/Arma3Helper.sh"
ARMA3_HELPER=""

# OPTIONAL - OpenTrack via protontricks
# Set OPENTRACK_ENABLED to true to enable OpenTrack launching.
# OPENTRACK_PATH should point to your opentrack.exe.
# OpenTrack portable should be copied into your Arma 3 EXE folder.
# Example: "/home/hazardouschurch/.steam/root/steamapps/common/Arma 3/opentrackportable/opentrack.exe"
OPENTRACK_ENABLED=false
OPENTRACK_PATH=""

# Java memory settings (recommended: 256m)
# Increase if ArmA3Sync crashes with OutOfMemory errors
JAVA_MIN_MEM="256m"
JAVA_MAX_MEM="256m"

# ============================================
# END OF CONFIGURATION
# ============================================

# Expand tildes in optional paths
ARMA3_HELPER="${ARMA3_HELPER/#\~/$HOME}"

LOG_FILE="$ARMA3SYNC_DIR/ArmA3Sync.log"
PROCESSED_LOG="$ARMA3SYNC_DIR/ArmA3Sync_processed.log"

> "$LOG_FILE"
> "$PROCESSED_LOG"

java -Djava.net.preferIPv4Stack=true -Xms$JAVA_MIN_MEM -Xmx$JAVA_MAX_MEM -XX:-HeapDumpOnOutOfMemoryError -XX:HeapDumpPath="/" -XX:+ShowMessageBoxOnError -Dsun.java2d.d3d=false -jar "$ARMA3SYNC_DIR/$JAR_FILE" 2>&1 | tr -d '\r' | tee "$LOG_FILE" &
TEE_PID=$!

(
    # Wait for the line to appear
    while ! grep -q "Starting ArmA 3 with command line:" "$LOG_FILE"; do
        sleep 1
    done
    
    # Wait for the file to stop growing (check 3 times in a row, 2s apart)
    STABLE_COUNT=0
    LAST_SIZE=0
    while [ "$STABLE_COUNT" -lt 3 ]; do
        sleep 2
        CURRENT_SIZE=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
        if [ "$LAST_SIZE" -eq "$CURRENT_SIZE" ]; then
            STABLE_COUNT=$((STABLE_COUNT + 1))
        else
            STABLE_COUNT=0
            LAST_SIZE=$CURRENT_SIZE
        fi
    done
    
    # Small safety buffer after file is confirmed stable
    sleep 3
    
    pkill -TERM -f "ArmA3Sync.jar"
    sleep 2
    pkill -KILL -f "ArmA3Sync.jar" 2>/dev/null
    kill $TEE_PID 2>/dev/null
) &

wait $TEE_PID 2>/dev/null

# Small delay to ensure log is flushed
sleep 2

grep "Starting ArmA 3 with command line:" "$LOG_FILE" | tail -n 1 | sed 's/.*dummy.sh //' | sed 's/-mod=\/home/-mod=Z:"\/home/g' | sed 's/;/&"/g'  > "$PROCESSED_LOG"

# Verify the processed log was actually written
if [ ! -s "$PROCESSED_LOG" ]; then
    echo "ERROR: $PROCESSED_LOG is empty! The mod line may not have been captured. Or application closed." >&2
    exit 1
fi

# Wait 5 seconds before launching Steam
sleep 5

# Launch Steam with all parameters from the processed log
steam -applaunch $STEAM_APP_ID -noLauncher $(cat "$PROCESSED_LOG")
# Can be tuned as needed. Both the helper and opentrack depend on it getting launched first
sleep 30

# Run optional applications
# Both must be launched on the same line to share terminal output properly
if [ -n "$ARMA3_HELPER" ] && [ -f "$ARMA3_HELPER" ] && [ "$OPENTRACK_ENABLED" = true ] && [ -f "$OPENTRACK_PATH" ]; then
    "$ARMA3_HELPER" & protontricks -c "wine $(echo "$OPENTRACK_PATH" | sed 's/ /\\ /g')" $STEAM_APP_ID &
elif [ -n "$ARMA3_HELPER" ] && [ -f "$ARMA3_HELPER" ]; then
    "$ARMA3_HELPER" &
elif [ "$OPENTRACK_ENABLED" = true ] && [ -f "$OPENTRACK_PATH" ]; then
    protontricks -c "wine $(echo "$OPENTRACK_PATH" | sed 's/ /\\ /g')" $STEAM_APP_ID &
fi
