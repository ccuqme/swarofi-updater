#!/bin/bash

dir="$(dirname "$(realpath "$0")")"
theme="style-1"

current_commit="$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted) | .checksum')"
upgrade_check_output="$(rpm-ostree upgrade --check 2>&1)"
available_updates=$(echo "$upgrade_check_output" | grep -E 'AvailableUpdate:|No updates available.' || true)

flatpak_update_check_output="$(flatpak remote-ls --updates --columns=ref,version)"
if [[ -n "$flatpak_update_check_output" ]]; then
  flatpak_num_updates=$(echo "$flatpak_update_check_output" | wc -l)
  flatpak_updates_formatted=$(echo "$flatpak_update_check_output" | awk -F '/' '{print $2}' | while read -r app; do
  current_version=$(flatpak list --app --columns=application,version | grep -E "^$app\s" | awk '{print $2}')
  new_version=$(echo "$flatpak_update_check_output"| grep -E "^app/$app/" | awk '{print $2}')
  echo "  $app $new_version → $current_version"
done)

  flatpak_update_message="Flatpak updates available: $flatpak_num_updates\n$flatpak_updates_formatted\n"
  flatpak_update_options="Update Flatpak\n"
else
  flatpak_update_message="No Flatpak updates available.\n"
  flatpak_update_options=""
fi

if [[ "$available_updates" != "No updates available." ]]; then
  num_updates=$(echo "$upgrade_check_output" | grep -oP '(?<=Diff: )[0-9]+')
  version=$(echo "$upgrade_check_output" | grep -oP '(?<=Version: )[^\s]+')
  commit=$(echo "$upgrade_check_output" | grep -oP '(?<=Commit: )[^\s]+')
  gpg_signature=$(echo "$upgrade_check_output" | grep -oP '(?<=GPGSignature: )[^\n]+')

  update_options="Update system\n"
  update_message="RPM-OSTree updates available: $num_updates\nVersion: $version\nCommit: $commit\nGPGSignature: $gpg_signature\n\n"
  update_message+="Diff output:\n$(rpm-ostree db diff $current_commit $commit)\n─────────────────────\n$flatpak_update_message"
  update_message=$(echo -e "$update_message")
else
  update_options=""
  if [[ -z "$flatpak_update_options" ]]; then
    update_message="No updates available."
  else
    update_message=$(echo -e "No RPM-OSTree updates available.\n$flatpak_update_message")
  fi
fi

if [[ -n "$update_options" && -n "$flatpak_update_options" ]]; then
  update_options="Update all\n${update_options}${flatpak_update_options}"
else
  update_options="${update_options}${flatpak_update_options}"
fi
update_options+="Cancel"
update_message="$update_message"
selected_option="$(echo -e "$update_options" | rofi -dmenu -i -mesg "$update_message" -p "Updates" -theme "${dir}/${theme}.rasi")"

get_current_flatpak_version() {
  app_id="$1"
  current_version=$(flatpak list --app --columns=application,version | grep "$app_id" | awk '{print $2}')
  echo "$current_version"
}

case "$selected_option" in
  "Update all")
    confirmation="$(echo -e "Yes\nNo" | rofi -dmenu -i -mesg "Are you sure you want to update both your system and Flatpak apps?" -p "Confirm Update" -theme ${dir}/${theme}.rasi)"
    if [ "$confirmation" == "Yes" ]; then
      rofi -e "Updating..." -theme "${dir}/${theme}.rasi" &
      rofi_pid=$!
      output=$(rpm-ostree upgrade | grep -v "Run \"systemctl reboot\" to start a reboot")
      flatpak update -y
      kill $rofi_pid
      post_update_action="$(echo -e "Close\nReboot\nShutdown" | rofi -dmenu -i -mesg "$output" -p "Update completed" -theme ${dir}/${theme}.rasi)"

      case "$post_update_action" in
        "Reboot")
          systemctl reboot
          ;;
        "Shutdown")
          systemctl poweroff
          ;;
        "Close"|*)
          ;;
      esac
    fi
    ;;
  "Update system")
    confirmation="$(echo -e "Yes\nNo" | rofi -dmenu -i -mesg "Are you sure you want to update your system?" -p "Confirm Update" -theme ${dir}/${theme}.rasi)"
    if [ "$confirmation" == "Yes" ]; then
      rofi -e "Updating..." -theme "${dir}/${theme}.rasi" &
      rofi_pid=$!
      output=$(rpm-ostree upgrade | grep -v "Run \"systemctl reboot\" to start a reboot")
      kill $rofi_pid
      post_update_action="$(echo -e "Close\nReboot\nShutdown" | rofi -dmenu -i -mesg "$output" -p "Update completed" -theme ${dir}/${theme}.rasi)"

      case "$post_update_action" in
        "Reboot")
          systemctl reboot
          ;;
        "Shutdown")
          systemctl poweroff
          ;;
        "Close"|*)
          ;;
      esac
    fi
    ;;
  "Update Flatpak")
    confirmation="$(echo -e "Yes\nNo" | rofi -dmenu -i -mesg "Are you sure you want to update Flatpak apps?" -p "Confirm Update" -theme ${dir}/${theme}.rasi)"
    if [ "$confirmation" == "Yes" ]; then
      rofi -e "Updating..." -theme "${dir}/${theme}.rasi" &
      rofi_pid=$!
      flatpak update -y
      kill $rofi_pid
      updated_flatpaks=$(echo -e "$flatpak_updates_formatted" | sed 's/\\n/\n/g')
      post_update_action="$(echo -e "Close" | rofi -dmenu -i -mesg "$(echo -e "Updated Flatpak apps:\n$flatpak_updates_formatted")" -p "Update completed" -theme ${dir}/${theme}.rasi)"
      case "$post_update_action" in
        "Close"|*)
          ;;
      esac
    fi
    ;;

  "Cancel")
    ;;
esac