# Swarofi Updater

Swarofi (Sericea/Sway, Waybar, Rofi) Updater is a GUI Updater & Waybar Applet for Fedora Sericea.

This repository contains a shell script and a Waybar applet specifically designed for Fedora Sericea to notify of updates and to update Flatpak and RPM-OSTree packages. The script uses Rofi to create windows for user interaction. Modifications might be required to make it work on other OSTRee based distributions, and is definitely required for non-OSTRee based ones.


## Demo


[swarofi.webm](https://github.com/ccuqme/swarofi-updater/assets/63260355/4aa7cf84-a9fc-4615-8181-294d3f75ffd7)


## Screenshots

### Updater
![updates_available](https://github.com/ccuqme/swarofi-updater/assets/63260355/add2187e-3e14-4ef1-9a1c-06b5a0cdb570)
![updated](https://github.com/ccuqme/swarofi-updater/assets/63260355/86cb0869-cdae-4b4b-bb47-d91ea8d61eb6)

### Applet
![applet](https://user-images.githubusercontent.com/63260355/236722308-8ac29db4-a01f-46e4-9f78-ca9f62a04897.png)


## Usage

1. Clone this repository to your desired location:

```bash
git clone https://github.com/ccuqme/swarofi-updater.git
```

2. Make the scripts swarofi-updater.sh and swarofi-applet.sh executable:

```chmod +x swarofi-updater/swarofi-updater.sh swarofi-updater/swarofi-applet.sh```

3. Configure the Waybar applet by adding the following to your Waybar configuration file:
```json
{
  "custom/swarofi-updates": {
    "format": "Updates: {}",
    "interval": 3600,
    "exec": "path/to/swarofi-updater/swarofi-applet.sh",
    "on-click": "path/to/swarofi-updater/swarofi-updater.sh",
    "signal": 8
  }
}
```
Replace `path/to/swarofi-updater` with the actual path to the repository.

4. Add `custom/swarofi-updates` to left, center or right module (e.g. `"modules-right": ["custom/swarofi-updates", "tray", "idle_inhibitor", "pulseaudio", "clock"]`)

5. Reload your Waybar configuration (By reloading Sway)

Now you should see the update notifications in your Waybar when there is updates available. It should not show when there is 0 updates.

## Customization
### Rofi Appearance
To customize the Rofi appearance, modify the style-1.rasi file. This style is a barely customized version of type-1 and style-1 from [github.com/adi1090x/rofi/tree/master/files/applets](https://github.com/adi1090x/rofi/tree/master/files/applets), so the other styles from this repo should work by changing window width to 820px, and listview layout to "horizontal". I don't think I changed anything else.

### Color Schemes
To change the color scheme, edit the `shared/colors.rasi` file by changing the import line, for example:

```arduino
@import ./colors/dracula.rasi"
```

####  Available color schemes:

* adapta
* arc
* black
* catppuccin
* cyberpunk
* dracula
* everforest
* gruvbox
* lovelace
* navy
* nord
* onedark
* paper
* solarized
* yousai


## Credits
This project uses theme and style files from [adi1090x/rofi](https://github.com/adi1090x/rofi).
