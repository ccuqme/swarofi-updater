#!/bin/bash
set -euo pipefail

check_updates() {
    upgrade_check_output=$(rpm-ostree upgrade --check 2>&1)
    available_updates=$(echo "$upgrade_check_output" | grep 'AvailableUpdate:' || true)
    flatpak_updates_output=$(flatpak remote-ls --updates 2>&1)
    num_flatpak_updates=$(echo "$flatpak_updates_output" | grep -oP '^[^\s]+\s+[^\s]+' | wc -l)

    num_rpm_ostree_updates=0
    if [ -n "$available_updates" ]; then
        num_rpm_ostree_updates=$(echo "$upgrade_check_output" | grep -oP '(?<=Diff: )[0-9]+')
    fi

    if [ "$num_rpm_ostree_updates" -gt 0 ] || [ "$num_flatpak_updates" -gt 0 ]; then
        total_updates=$((num_rpm_ostree_updates + num_flatpak_updates))

        version=$(echo "$upgrade_check_output" | grep -oP '(?<=Version: )[^\s]+' || echo "N/A")
        commit=$(echo "$upgrade_check_output" | grep -oP '(?<=Commit: )[^\s]+' || echo "N/A")
        gpg_signature=$(echo "$upgrade_check_output" | grep -oP '(?<=GPGSignature: )[^\n]+' || echo "N/A")

        update_icon=""
        message="Version: $version | Commit: $commit | GPGSignature: $gpg_signature | Diff: $num_rpm_ostree_updates rpm-ostree, $num_flatpak_updates Flatpak | Total: $total_updates upgraded"
        echo "$update_icon $total_updates"
        echo "$message"
        notify-send "System Update Available" "$message"
        return 0
    else
        return 1
    fi
}

check_updates