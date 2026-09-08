#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
script_path="${script_dir}/../cloudflare-ddns.sh"

output="$(env -u CF_API_TOKEN -u CF_DOMAIN_NAMES bash "${script_path}" 2>&1 || true)"

if [[ "${output}" != *"CF_API_TOKEN is required"* ]]; then
  printf 'Expected missing-token error, received: %s\n' "${output}" >&2
  exit 1
fi

temporary_directory="$(mktemp -d)"
trap 'rm -rf "${temporary_directory}"' EXIT

cat >"${temporary_directory}/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"${CURL_LOG}"
url="${!#}"

case "${url}" in
  'https://api.ipify.org?format=json')
    printf '%s\n' '{"ip":"198.51.100.42"}'
    ;;
  'https://api6.ipify.org?format=json')
    printf '%s\n' '{"ip":"2001:db8::42"}'
    ;;
  *'/zones?name=home.example.com')
    printf '%s\n' '{"success":true,"result":[]}'
    ;;
  *'/zones?name=example.com')
    printf '%s\n' '{"success":true,"result":[{"id":"zone-id"}]}'
    ;;
  *'/dns_records?type=A&name=home.example.com')
    printf '%s\n' '{"success":true,"result":[]}'
    ;;
  *'/dns_records?type=AAAA&name=home.example.com')
    printf '%s\n' '{"success":true,"result":[]}'
    ;;
  *)
    printf '%s\n' '{"success":true,"result":{"id":"record-id"}}'
    ;;
esac
EOF
chmod +x "${temporary_directory}/curl"

CURL_LOG="${temporary_directory}/curl.log" \
PATH="${temporary_directory}:${PATH}" \
CF_API_TOKEN='test-token' \
CF_DOMAIN_NAMES='home.example.com' \
bash "${script_path}"

created_records="$(grep -c -- '-X POST .*zones/zone-id/dns_records' "${temporary_directory}/curl.log" || true)"
if [[ "${created_records}" -ne 2 ]]; then
  printf 'Expected two DNS record creations, received: %s\n' "${created_records}" >&2
  exit 1
fi

: >"${temporary_directory}/curl.log"
CURL_LOG="${temporary_directory}/curl.log" \
PATH="${temporary_directory}:${PATH}" \
CF_API_TOKEN='test-token' \
CF_DOMAIN_NAMES='home.example.com' \
CF_ENABLE_IPV6=false \
bash "${script_path}"

created_records="$(grep -c -- '-X POST .*zones/zone-id/dns_records' "${temporary_directory}/curl.log" || true)"
if [[ "${created_records}" -ne 1 ]]; then
  printf 'Expected one DNS record creation with IPv6 disabled, received: %s\n' "${created_records}" >&2
  exit 1
fi

if grep -q 'api6.ipify.org\|type=AAAA' "${temporary_directory}/curl.log"; then
  printf 'IPv6 must not be queried when CF_ENABLE_IPV6=false\n' >&2
  exit 1
fi

service_path="${script_dir}/../cloudflare-ddns.service"
timer_path="${script_dir}/../cloudflare-ddns.timer"
installer_path="${script_dir}/../install.sh"

for required_path in "${service_path}" "${timer_path}" "${installer_path}"; do
  if [[ ! -f "${required_path}" ]]; then
    printf 'Expected deployment artifact: %s\n' "${required_path}" >&2
    exit 1
  fi
done

grep -q '^Type=oneshot$' "${service_path}"
grep -q '^User=cloudflare-ddns$' "${service_path}"
grep -q '^OnUnitActiveSec=1h$' "${timer_path}"
grep -q '^ExecStart=/usr/local/sbin/cloudflare-ddns$' "${service_path}"
grep -q '/etc/cloudflare-ddns/ddns.env' "${service_path}"
grep -q 'useradd --system' "${installer_path}"
grep -q 'chmod 0600' "${installer_path}"
grep -q 'command -v jq' "${installer_path}"