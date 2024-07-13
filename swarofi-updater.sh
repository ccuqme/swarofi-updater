#!/bin/bash

# skip updates on metered connections
skip_metered() {
    active_connection_uuid="$(nmcli -t -m multiline -f UUID connection show --active | head -n1 | cut -c 6-)"
    is_metered=$(nmcli -t -m multiline -f connection.metered connection show "$active_connection_uuid" | cut -c 20-)
    if [ "$is_metered" = "yes" ]; then
        echo "connections is metered, skipping updates"
        exit 0
    fi
}

# Set variables
dir="$(dirname "$(realpath "$0")")"
theme="style-1"

# Function to check RPM-OSTree updates
check_rpmostree_updates() {
  current_commit="$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted) | .checksum')"
  upgrade_check_output="$(rpm-ostree upgrade --check 2>&1)"
  available_rpmostree_updates=$(echo "$upgrade_check_output" | awk '/AvailableUpdate:|No updates available./' || true)

  if [[ "$available_rpmostree_updates" != "No updates available." ]]; then
    num_updates=$(echo "$upgrade_check_output" | awk -F ' ' '/Diff:/ {print $2}')
    version=$(echo "$upgrade_check_output" | awk -F ' ' '/Version:/ {print $2}')
    commit=$(echo "$upgrade_check_output" | awk -F ' ' '/Commit:/ {print $2}')
    gpg_signature=$(echo "$upgrade_check_output" | awk -F ': ' '/GPGSignature:/ {print $2}')

    rpmostree_update_options="Update System\n"
    rpmostree_update_message="RPM-OSTree updates available: $num_updates\nVersion: $version\nCommit: $commit\nGPGSignature: $gpg_signature\n\n"
    rpmostree_update_message+="Diff output:\n<span size=\"small\">$(rpm-ostree db diff "$current_commit" "$commit" | tr '\n' ' ')</span>\n"
  else
    rpmostree_update_options=""
    rpmostree_update_message="No RPM-OSTree updates available.\n"
  fi
}

# Function to check Flatpak updates
check_flatpak_updates() {
  flatpak update --appstream
  flatpak_update_check_output="$(flatpak remote-ls --updates --columns=ref,version)"

  if [[ -n "$flatpak_update_check_output" ]]; then
    flatpak_num_updates=$(echo "$flatpak_update_check_output" | wc -l)
    flatpak_updates_formatted=$(echo "$flatpak_update_check_output" | awk -F '/' '{print $2}' | while read -r app; do
    current_version=$(flatpak list --app --columns=application,version | awk -v app="$app" '$1 == app {print $2}')
    new_version=$(echo "$flatpak_update_check_output" | awk -v app="$app" '$0 ~ app && $2 != "" {print $NF}')
    if [[ -n "$new_version" ]]; then
      echo "  $app $current_version → $new_version"
    else
      echo "  $app "
    fi
  done)

    flatpak_update_message="Flatpak updates available: $flatpak_num_updates\n$flatpak_updates_formatted\n"
    flatpak_update_options="Update Flatpak\n"
  else
    flatpak_update_message="No Flatpak updates available.\n"
    flatpak_update_options=""
  fi
}


# Function to handle post-update actions
handle_post_update() {
  post_update_action="$(echo -e "Close\nReboot\nShutdown" | rofi -dmenu -i -mesg "$(echo -e "$output")" -p "Update completed" -theme "${dir}"/${theme}.rasi)"
  case "$post_update_action" in
    "Reboot")
      systemctl reboot
      ;;
    "Shutdown")
      systemctl poweroff
      ;;
    "Close"|*)
      pkill -SIGRTMIN+8 waybar
      ;;
  esac
}

skip_metered
check_rpmostree_updates
check_flatpak_updates

update_message=$(echo -e "$rpmostree_update_message─────────────────────\n$flatpak_update_message")

if [[ -n "$rpmostree_update_options" && -n "$flatpak_update_options" ]]; then
  update_options="Update All\n${rpmostree_update_options}${flatpak_update_options}"
else
  update_options="${rpmostree_update_options}${flatpak_update_options}"
fi

update_options+="Close"
selected_option="$(echo -e "$update_options" | rofi -dmenu -i -mesg "$update_message" -p "Updates" -theme "${dir}/${theme}.rasi" -theme-str 'window {width: 80%;}' )"

case "$selected_option" in
  "Update All")
    confirmation="$(echo -e "Yes\nNo" | rofi -dmenu -i -mesg "Are you sure you want to update both your system and Flatpak apps?" -p "Confirm Update" -theme "${dir}"/${theme}.rasi)"
    if [ "$confirmation" == "Yes" ]; then
      dunstify -r 1616 "Update Status" "Updating..."
      output=$(rpm-ostree upgrade | awk '!/Run "systemctl reboot" to start a reboot/')
      flatpak_output=$(flatpak update -y | awk '/ID|Updates complete./' | tr -cd '\11\12\15\40-\176')
      updated_flatpaks=$(echo -e "$flatpak_updates_formatted" | sed 's/\\n/\n/g')
      output+="\n─────────────────────\nUpdated Flatpak apps:\n$updated_flatpaks\n$flatpak_output"
      dunstify -r 1616 "Update Status" "Update completed"
      handle_post_update
    fi
    ;;
  "Update System")
    confirmation="$(echo -e "Yes\nNo" | rofi -dmenu -i -mesg "Are you sure you want to update your system?" -p "Confirm Update" -theme "${dir}"/${theme}.rasi)"
    if [ "$confirmation" == "Yes" ]; then
      dunstify -r 1616 "Update Status" "Updating..."
      output=$(rpm-ostree upgrade | awk '!/Run "systemctl reboot" to start a reboot/')
      dunstify -r 1616 "Update Status" "Update completed"
      handle_post_update
    fi
    ;;
  "Update Flatpak")
    confirmation="$(echo -e "Yes\nNo" | rofi -dmenu -i -mesg "Are you sure you want to update Flatpak apps?" -p "Confirm Update" -theme "${dir}"/${theme}.rasi)"
    if [ "$confirmation" == "Yes" ]; then
      dunstify -r 1616 "Update Status" "Updating..."
      output=$(flatpak update -y | awk '/ID|Updates complete./' | tr -cd '\11\12\15\40-\176')
      dunstify -r 1616 "Update Status" "Update completed"
      updated_flatpaks=$(echo -e "$flatpak_updates_formatted" | sed 's/\\n/\n/g')
      post_update_action="$(echo -e "Close" | rofi -dmenu -i -mesg "$(echo -e "Updated Flatpak apps:\n$updated_flatpaks")" -p "Update completed" -theme "${dir}"/${theme}.rasi)"
      pkill -SIGRTMIN+8 waybar
    fi
    ;;
  "Close")
    ;;
esac
