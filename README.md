# Swarofi Updater

Swarofi (Sericea/Sway, Waybar, Rofi) Updater is a GUI Updater & Waybar Applet for Fedora Sericea.

This repository contains a shell script and a Waybar applet specifically designed for Fedora Sericea to notify of updates and to update Flatpak and RPM-OSTree packages. The script uses Rofi to create windows for user interaction. Modifications be required to make it work on other RPM-OSTRee based distributions.


## Demo


[Swarofi](https://user-images.githubusercontent.com/63260355/236719998-e2eca2ac-5def-4ac6-80cc-9d3f7973f09b.webm)


## Applet Screenshot

![Waybar Applet Screenshot](https://i.imgur.com/4HNa6Wk.png)

## Usage

1. Clone this repository to your desired location:

```bash
git clone https://github.com/ccuqme/swarofi-updater.git
```

2. Make the scripts rpm-ostree_updater.sh and rpm-ostree_applet.sh executable:

```chmod +x swarofi-updater/swarofi-updater.sh swarofi-updater/swarofi-applet.sh```

3. Configure the Waybar applet by adding the following to your Waybar configuration file:
```json
{
  "custom/rpm_ostree": {
    "format": "Updates: {}",
    "interval": 3600,
    "return-type": "json",
    "exec": "path/to/swarofi-updater/swarofi-applet.sh",
    "on-click": "path/to/swarofi-updater/swarofi-updater.sh"
  }
}
```
Replace `path/to/swarofi-updater` with the actual path to the repository.

4. Add `custom/swarofi-updates` to left, center or right module (e.g. `"modules-right": ["custom/swarofi-updates", "tray", "idle_inhibitor", "pulseaudio", "clock"]`)

5. Reload your Waybar configuration (By reloading Sway)

Now you should see the update notifications in your Waybar and be able to run the RPM-OSTree updater script.

## Customization
### Rofi Appearance
To customize the Rofi appearance, modify the style-1.rasi file. This style is a barely customized version of type-1 and style-1 from [github.com/adi1090x/rofi/tree/master/files/applets](https://github.com/adi1090x/rofi/tree/master/files/applets), so the other styles from this repo should work by changing window width to 820px, and listview layout to "horizontal". I don't think I changed anything else.

### Color Schemes
To change the color scheme, edit the `shared/colors.rasi` file by changing the import line, for example:

```arduino
@import "~/.config/rofi/colors/dracula.rasi"
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
