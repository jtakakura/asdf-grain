#!/bin/bash

set -eo pipefail

GITHUB_REPO="https://github.com/grain-lang/grain"
REGISTRY_URL="https://api.github.com/repos/grain-lang/grain/releases"
cmd="curl -s"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

function download_meatadata() {
  $cmd "$REGISTRY_URL"
}

# stolen from https://github.com/rbenv/ruby-build/pull/631/files#diff-fdcfb8a18714b33b07529b7d02b54f1dR942
function sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

function extract_version() {
  grep -oE "tag_name\": \".{1,20}\"," | sed 's/tag_name\": \"v//;s/\",//'
}

function check_install_type() {
  if [ "$ASDF_INSTALL_TYPE" != "version" ]; then
    fail "asdf-grain currently supports release install only"
  fi
}

function get_download_path() {
  local version=$1
  local base_path=$2

  echo "$base_path/grain-${version}.tgz"
}

function download_source() {
  local version=$1
  local base_path=$2

  local source_url="${GITHUB_REPO}/archive/v${version}.tar.gz"
  local download_path="$(get_download_path $version $base_path)"

  echo "downloading Grain $version source..."
  $cmd --output "$download_path" -C - "$source_url"
}
