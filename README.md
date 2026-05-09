# LinuxArma3SyncHelper
Scripts and application to run arma3sync on linux
# ArmA3Sync Launcher for Linux

A bash script that automates launching ArmA 3 through Steam with mods managed by ArmA3Sync on Linux.

## What It Does

1. Launches the ArmA3Sync Java application
2. Lets you select mods and click "Play" (just like on Windows)
3. Captures the generated mod list from ArmA3Sync's output
4. Automatically closes ArmA3Sync after the mod list is generated
5. Launches ArmA 3 via Steam with the captured mod parameters
6. Optionally runs Arma3Helper.sh and/or OpenTrack

## Features

- Download and manage mods exactly as you would on Windows
- Add extra startup parameters (e.g., `--force-grab-cursor`, `-noWindowBorder -window`)
- Start with profile and unit support
- Mod order is preserved like in ArmA3Sync
- Events and Join Server functionality works

## Known Limitations

- Cannot launch external applications like on Windows
- AIA and tools have not been tested
- Not all DLC have been tested (DLC can be launched via startup parameters)
- Do not use this to launch an ArmA or ArmA3Sync server

## Important

ArmA3Sync will freeze after clicking "Play". The script automatically handles this by waiting for the mod list to be generated before closing the application. This is expected behavior and is required to capture the output.

## Dependencies

- Java Runtime Environment (JRE)
- Steam (installed and logged in)
- ArmA3Sync (Java application)
- protontricks (only if using OpenTrack)

## Prerequisites

1. **Launch ARMA 3 to the desktop BEFORE running this script.**
   This ensures the Steam overlay and Proton environment are ready.

2. **Create an empty `dummy.sh` file in your ArmA3Sync folder.**
   In ArmA3Sync, set the launch parameters to point to this `dummy.sh`.
   The script intercepts the launch command from the `dummy.sh` output.

3. **Configure the variables in `arma3sync.sh`** to match your system paths.

## Configuration

Edit the variables at the top of `arma3sync.sh`:

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `ARMA3SYNC_DIR` | ArmA3Sync installation folder | `/home/hazardouschurch/Arma/ArmA3Sync` |
| `JAR_FILE` | ArmA3Sync JAR filename | `ArmA3Sync.jar` |
| `STEAM_APP_ID` | Steam App ID for Arma 3 | `107410` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `ARMA3_HELPER` | Path to helper script. Leave empty to disable. | `~/Arma3Helper.sh` |
| `OPENTRACK_ENABLED` | Enable OpenTrack via protontricks | `false` |
| `OPENTRACK_PATH` | Path to opentrack.exe | *(see script)* |

### Java Memory

| Variable | Description | Default |
|----------|-------------|---------|
| `JAVA_MIN_MEM` | Initial heap size | `256m` |
| `JAVA_MAX_MEM` | Maximum heap size | `256m` |

## Usage

```bash
./arma3sync.sh
```

1. Launch Arma 3 to the desktop first (to initialize Steam/Proton)
2. Run the script
3. Use ArmA3Sync as normal - select mods, set parameters, click Play
4. The script will automatically close ArmA3Sync and launch Arma 3 via Steam

## Troubleshooting

**ArmA3Sync doesn't close after clicking Play:**
- This is expected - the script handles it automatically
- The script waits for the mod list to be fully written before killing the process

**Processed log is empty:**
- Make sure `dummy.sh` exists in your ArmA3Sync folder
- Check that ArmA3Sync launch parameters point to `dummy.sh`
- Verify the log file is being written to

**Optional applications not launching:**
- Check that `ARMA3_HELPER` path is correct (use full path or `~` for home)
- For OpenTrack, ensure protontricks is installed and `OPENTRACK_ENABLED=true`

**Mods not loading in game:**
- Ensure the mod paths in ArmA3Sync are correct

- Check that the `Z:"` prefix is being added to paths (handled automatically by script)

#  Looking for a Unit
  -We are open and welcoming of all players at ARCOMM
  -ARCOMM is a unit started in 2016
  -Operations are on Saturdays
https://discord.com/invite/7ehwg7F

#   Need the Arma3Helper Script
  -Follow the guide here 
  -https://9lo.re/project/armaonlinux/
#   Need the OpenTrack
  -https://github.com/opentrack/opentrack/releases
  -All I did was get the portable installation, extract it, and put the entire folder inside of my ARMA3.EXE location.
  -For open track I had to add these three additional dll into the portable holder because I believe the installation is broken. Its in the optional folder
#   Want to get your own ArmA3Sync jars
How I got mine was getting a docker instance of Windows and extracting a fresh ArmA3Sync installer there. I copied the entire folder to get the jars.You could do this on a regular version of Windows and you can delete a lot of it except for what I have present in the GitHub. I also copied my dlls for opentrack from there.
