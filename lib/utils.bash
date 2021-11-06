#!/usr/bin/env bash

set -euo pipefail

ASDF_CMAKE_FORCE_SOURCE_INSTALL=${ASDF_CMAKE_FORCE_SOURCE_INSTALL:-0}

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for <YOUR TOOL>.
GH_REPO="https://github.com/Kitware/CMake"
TOOL_NAME="cmake"
TOOL_TEST="cmake"

fail() {
  echo -e "asdf-$TOOL_NAME: [ERR] $*"
  exit 1
}

log() {
  echo -e "asdf-$TOOL_NAME: [INFO] $*"
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if CMake is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  list_github_tags
}

extract() {
  local archive_path=$1
  local target_dir=$2

  tar -xzf "$archive_path" -C "$target_dir" --strip-components=1 || fail "Could not extract $archive_path"
}

get_source_download_url() {
  local version=$1

  if [[ "$version" =~ ^[0-9]+\.* ]]; then
    # if version is a release number, prepend v
    echo "https://github.com/Kitware/CMake/archive/v${version}.zip"
  else
    # otherwise it can be a branch name or commit sha
    echo "https://github.com/Kitware/CMake/archive/${version}.zip"
  fi
}

download_source() {
  local version filepath url

  version="$1"
  filepath="$2"

  url=$(get_source_download_url "$version")
  curl "${curl_opts[@]}" -o "$filepath" "$url" || fail "Could not download $url"
  return 0
}

download_binary() {
  local version filepath url
  version="$1"
  filepath="$2"

  local platforms=()
  local kernel arch
  kernel="$(uname -s)"
  arch="$(uname -m)"

  case "$kernel" in
  Darwin)
    platforms=("macos-universal" "Darwin-${arch}")
    ;;
  Linux)
    platforms=("linux-${arch}" "Linux-${arch}")
    ;;
  esac

  log "Downloading $TOOL_NAME release $version..."
  for platform in ${platforms[*]}; do
    url="$GH_REPO/releases/download/v${version}/${TOOL_NAME}-${version}-${platform}.tar.gz"
    log "Trying ${url} ..."
    curl "${curl_opts[@]}" -o "$filepath" -C - "$url" && return 0
  done

  return 1
}

binary_download_and_extract() {
  # Puts the extracted files in $ASDF_DOWNLOAD_PATH/bin

  local version=$1
  local download_dir=$2

  local extract_dir="${download_dir}/bin"
  mkdir -p "$extract_dir"

  local download_file="${download_dir}/${TOOL_NAME}-${version}-bin.tar.gz"

  if download_binary "$version" "${download_file}"; then
    extract "${download_file}" "${extract_dir}"
    rm "${download_file}"
    return 0
  fi

  return 1
}

source_download_and_extract() {
  # Puts the extracted files in $ASDF_DOWNLOAD_PATH/src

  local version=$1
  local download_dir=$2

  local extract_dir="${download_dir}/src"
  mkdir -p "$extract_dir"

  local download_file="${download_dir}/${TOOL_NAME}-${version}-src.tar.gz"

  if download_source "$version" "${download_file}"; then
    extract "${download_file}" "${extract_dir}"
    rm "${download_file}"
    return 0
  fi

  return 1
}

download_and_extract() {

  local install_type="$1"
  local version="$2"
  local download_dir="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
    # TODO: support refs
  fi

  if [ "$ASDF_CMAKE_FORCE_SOURCE_INSTALL" == 1 ]; then
    log "Skipping binary download because ASDF_CMAKE_FORCE_SOURCE_INSTALL=1"
  else
    ## Binary Download & Extract
    if binary_download_and_extract "$version" "${download_dir}"; then
      return 0
    else
      log "Could not find a suitable binary download for $TOOL_NAME $version, falling back to source..."
    fi
  fi

  ## Source Download & Extract
  source_download_and_extract "$version" "${download_dir}"
}

source_build_install() {

  local src_dir=$1
  local install_path=$2
  (
    cd "$src_dir"
    if [ -v QTBINDIR ] && [ -d "$QTBINDIR" ]; then
      PATH=$PATH:$QTBINDIR ./bootstrap --prefix="$install_path" --qt-gui --parallel="$ASDF_CONCURRENCY" -- -DCMAKE_BUILD_TYPE=Release
    else
      ./bootstrap --prefix="$install_path" --parallel="$ASDF_CONCURRENCY" -- -DCMAKE_BUILD_TYPE=Release
    fi
    make -j "$ASDF_CONCURRENCY"
    make install
  )
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"

    if [ -d "$ASDF_DOWNLOAD_PATH"/bin ]; then

      log "Installing download binary in ${ASDF_DOWNLOAD_PATH}/bin"

      cp -r "${ASDF_DOWNLOAD_PATH}/bin"/* "$install_path"

      (
        cd "$install_path"
        if [ -d CMake.app ]; then
          ln -sf CMake.app/Contents/bin ./bin
        fi
      )
    elif [ -d "$ASDF_DOWNLOAD_PATH"/src ]; then
      source_build_install "$ASDF_DOWNLOAD_PATH"/src "$install_path"
    fi

    # TODO: Asert <YOUR TOOL> executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    log "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
