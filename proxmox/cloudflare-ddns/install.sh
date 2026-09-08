#!/usr/bin/env bash

set -euo pipefail

readonly service_user='cloudflare-ddns'
readonly install_directory='/usr/local/sbin'
readonly environment_directory='/etc/cloudflare-ddns'
readonly environment_file="${environment_directory}/ddns.env"
readonly systemd_directory='/etc/systemd/system'
readonly script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if (( EUID != 0 )); then
  printf 'Run this installer as root.\n' >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  printf 'Install curl and jq before enabling Cloudflare DDNS.\n' >&2
  exit 1
fi

if ! id -u "${service_user}" >/dev/null 2>&1; then
  useradd --system --user-group --home-dir /nonexistent --shell /usr/sbin/nologin "${service_user}"
fi

install -d -m 0755 "${install_directory}" "${environment_directory}"
install -m 0755 "${script_directory}/cloudflare-ddns.sh" "${install_directory}/cloudflare-ddns"
install -m 0644 "${script_directory}/cloudflare-ddns.service" \
  "${systemd_directory}/cloudflare-ddns.service"
install -m 0644 "${script_directory}/cloudflare-ddns.timer" \
  "${systemd_directory}/cloudflare-ddns.timer"

if [[ ! -e "${environment_file}" ]]; then
  install -m 0600 -o "${service_user}" -g "${service_user}" \
    "${script_directory}/ddns.env.example" "${environment_file}"
fi

chown "${service_user}:${service_user}" "${environment_file}"
chmod 0600 "${environment_file}"

systemctl daemon-reload
systemctl enable --now cloudflare-ddns.timer
printf 'Cloudflare DDNS timer is enabled. Populate %s before the first run.\n' "${environment_file}"