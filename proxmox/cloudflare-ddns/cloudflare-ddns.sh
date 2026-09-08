#!/usr/bin/env bash

set -euo pipefail

readonly api_base_url='https://api.cloudflare.com/client/v4'
readonly ipv4_endpoint='https://api.ipify.org?format=json'
readonly ipv6_endpoint='https://api6.ipify.org?format=json'

if [[ -z "${CF_API_TOKEN:-}" ]]; then
  printf 'CF_API_TOKEN is required\n' >&2
  exit 1
fi

if [[ -z "${CF_DOMAIN_NAMES:-}" ]]; then
  printf 'CF_DOMAIN_NAMES is required\n' >&2
  exit 1
fi

readonly CF_TTL="${CF_TTL:-1}"
readonly CF_PROXIED="${CF_PROXIED:-false}"
readonly CF_COMMENT="${CF_COMMENT:-}"
readonly CF_ENABLE_IPV6="${CF_ENABLE_IPV6:-true}"

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  printf 'curl and jq are required\n' >&2
  exit 1
fi

if ! [[ "${CF_TTL}" =~ ^[0-9]+$ ]] || (( CF_TTL != 1 && CF_TTL < 60 )); then
  printf 'CF_TTL must be 1 (automatic) or at least 60\n' >&2
  exit 1
fi

if [[ "${CF_PROXIED}" != 'true' && "${CF_PROXIED}" != 'false' ]]; then
  printf 'CF_PROXIED must be true or false\n' >&2
  exit 1
fi

if [[ "${CF_ENABLE_IPV6}" != 'true' && "${CF_ENABLE_IPV6}" != 'false' ]]; then
  printf 'CF_ENABLE_IPV6 must be true or false\n' >&2
  exit 1
fi

api_request() {
  local method="$1"
  local url="$2"
  local payload="${3:-}"
  local response

  if [[ -n "${payload}" ]]; then
    response="$(curl -fsS \
      -H "Authorization: Bearer ${CF_API_TOKEN}" \
      -H 'Content-Type: application/json' \
      -X "${method}" \
      --data "${payload}" \
      "${url}")"
  else
    response="$(curl -fsS \
      -H "Authorization: Bearer ${CF_API_TOKEN}" \
      -H 'Content-Type: application/json' \
      -X "${method}" \
      "${url}")"
  fi

  if ! jq -e '.success == true' >/dev/null <<<"${response}"; then
    printf 'Cloudflare API request failed: %s\n' "${url}" >&2
    return 1
  fi

  printf '%s\n' "${response}"
}

find_zone_id() {
  local record_name="$1"
  local candidate="${record_name}"
  local response
  local zone_id

  while [[ "${candidate}" == *.* ]]; do
    response="$(api_request GET "${api_base_url}/zones?name=${candidate}")"
    zone_id="$(jq -r '.result[0].id // empty' <<<"${response}")"
    if [[ -n "${zone_id}" ]]; then
      printf '%s\n' "${zone_id}"
      return 0
    fi

    candidate="${candidate#*.}"
  done

  printf 'No Cloudflare zone found for %s\n' "${record_name}" >&2
  return 1
}

record_payload() {
  local record_type="$1"
  local record_name="$2"
  local address="$3"

  jq -cn \
    --arg type "${record_type}" \
    --arg name "${record_name}" \
    --arg content "${address}" \
    --arg comment "${CF_COMMENT}" \
    --argjson ttl "${CF_TTL}" \
    --argjson proxied "${CF_PROXIED}" \
    '{type: $type, name: $name, content: $content, ttl: $ttl, proxied: $proxied, comment: $comment}'
}

sync_record() {
  local zone_id="$1"
  local record_type="$2"
  local record_name="$3"
  local address="$4"
  local response
  local record_id
  local payload
  local current_content
  local current_ttl
  local current_proxied
  local current_comment

  payload="$(record_payload "${record_type}" "${record_name}" "${address}")"
  response="$(api_request GET "${api_base_url}/zones/${zone_id}/dns_records?type=${record_type}&name=${record_name}")"
  record_id="$(jq -r '.result[0].id // empty' <<<"${response}")"

  if [[ -z "${record_id}" ]]; then
    api_request POST "${api_base_url}/zones/${zone_id}/dns_records" "${payload}" >/dev/null
    printf 'Created %s record for %s\n' "${record_type}" "${record_name}"
    return 0
  fi

  current_content="$(jq -r '.result[0].content // empty' <<<"${response}")"
  current_ttl="$(jq -r '.result[0].ttl // empty' <<<"${response}")"
  current_proxied="$(jq -r '.result[0].proxied // false' <<<"${response}")"
  current_comment="$(jq -r '.result[0].comment // empty' <<<"${response}")"

  if [[ "${current_content}" == "${address}" &&
    "${current_ttl}" == "${CF_TTL}" &&
    "${current_proxied}" == "${CF_PROXIED}" &&
    "${current_comment}" == "${CF_COMMENT}" ]]; then
    printf '%s record for %s is current\n' "${record_type}" "${record_name}"
    return 0
  fi

  api_request PATCH "${api_base_url}/zones/${zone_id}/dns_records/${record_id}" "${payload}" >/dev/null
  printf 'Updated %s record for %s\n' "${record_type}" "${record_name}"
}

fetch_address() {
  local endpoint="$1"
  local address

  address="$(curl -fsS "${endpoint}" | jq -er '.ip')"
  if [[ -z "${address}" ]]; then
    printf 'No address returned by %s\n' "${endpoint}" >&2
    return 1
  fi

  printf '%s\n' "${address}"
}

readonly public_ipv4="$(fetch_address "${ipv4_endpoint}")"
public_ipv6=''
if [[ "${CF_ENABLE_IPV6}" == 'true' ]]; then
  public_ipv6="$(fetch_address "${ipv6_endpoint}")"
fi
readonly public_ipv6

IFS=',' read -r -a domain_names <<<"${CF_DOMAIN_NAMES}"
for raw_domain_name in "${domain_names[@]}"; do
  domain_name="${raw_domain_name//[[:space:]]/}"
  if [[ -z "${domain_name}" ]]; then
    printf 'CF_DOMAIN_NAMES contains an empty domain name\n' >&2
    exit 1
  fi

  zone_id="$(find_zone_id "${domain_name}")"
  sync_record "${zone_id}" A "${domain_name}" "${public_ipv4}"
  if [[ "${CF_ENABLE_IPV6}" == 'true' ]]; then
    sync_record "${zone_id}" AAAA "${domain_name}" "${public_ipv6}"
  fi
done