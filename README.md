# Swarofi (Sericea/Sway, Waybar, Rofi) Updater is a GUI Updater & Waybar Applet for Fedora Sericea

This repository contains a shell script and Waybar applet specifically designed for Fedora Sericea to manage RPM-OSTree updates and notifications. The script uses Rofi to create windows for user interaction. Modifications might be required to make it work on other distributions.

Flatpak integration is in the works, and should be done tomorrow.

## Demo


https://user-images.githubusercontent.com/63260355/236698967-b7fae5b7-2e57-4173-8e7f-1576543cf9ae.mp4


## Applet Screenshot

![Waybar Applet Screenshot](https://i.imgur.com/4HNa6Wk.png)

## Usage

1. Clone this repository to your desired location:

```bash
git clone https://github.com/ccuqme/swr-gui-updater.git
```

2. Make the scripts rpm-ostree_updater.sh and rpm-ostree_applet.sh executable:

```chmod +x swr-gui-updater/rpm-ostree_updater.sh rpm-ostree-updater/rpm-ostree_applet.sh```

3. Configure the Waybar applet by adding the following to your Waybar configuration file:
```json
{
  "custom/rpm_ostree": {
    "format": "Updates: {}",
    "interval": 3600,
    "return-type": "json",
    "exec": "path/to/swarofi-updater/rpm-ostree_applet.sh",
    "on-click": "path/to/swarofi-updater/rpm-ostree_updater.sh"
  }
}
```
Replace `path/to/swarofi-updater` with the actual path to the repository.

4. Add `custom/rpm-ostree_upgrade` to left, center or right module (e.g. `"modules-right": ["custom/rpm-ostree_upgrade", "tray", "idle_inhibitor", "pulseaudio", "clock"]`)

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
