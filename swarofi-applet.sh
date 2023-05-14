#!/bin/bash
set -euo pipefail

check_updates() {
    upgrade_check_output=$(rpm-ostree upgrade --check 2>&1 || true)
    available_updates=$(echo "$upgrade_check_output" | grep 'AvailableUpdate:' || true)
    flatpak_updates_output=$(flatpak remote-ls --updates 2>&1 || true)
    num_flatpak_updates=$(echo "$flatpak_updates_output" | grep -oP '^[^\s]+\s+[^\s]+' | wc -l || true)

    num_rpm_ostree_updates=0
    if [ -n "$available_updates" ]; then
        num_rpm_ostree_updates=$(echo "$upgrade_check_output" | grep -oP '(?<=Diff: )[0-9]+')
    fi

    if [ "$num_rpm_ostree_updates" -gt 0 ] || [ "$num_flatpak_updates" -gt 0 ]; then
        total_updates=$((num_rpm_ostree_updates + num_flatpak_updates))

        update_icon=""
        message="RPM-OSTree updates: $num_rpm_ostree_updates | Flatpak updates: $num_flatpak_updates"
        echo "$update_icon $total_updates"
        echo "$message"

        last_update_count=0
        if [ -f "/tmp/swarofi_last_update_count.txt" ]; then
            last_update_count=$(cat /tmp/swarofi_last_update_count.txt)
        fi

        if [ "$last_update_count" -ne "$total_updates" ]; then
            dunstify -r 1616 "System Update Available" "$message"
            echo "$total_updates" > /tmp/swarofi_last_update_count.txt
        fi

        return 0
    else
        if [ -f "/tmp/swarofi_last_update_count.txt" ]; then
            rm /tmp/swarofi_last_update_count.txt
        fi
        return 1
    fi
}

check_updates
