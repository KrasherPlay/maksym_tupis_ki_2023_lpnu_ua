#!/bin/sh
set -eu

BASE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROPERTIES_FILE="$BASE_DIR/.mvn/wrapper/maven-wrapper.properties"

if [ ! -f "$PROPERTIES_FILE" ]; then
  echo "Maven Wrapper properties not found: $PROPERTIES_FILE" >&2
  exit 1
fi

distribution_url=$(sed -n 's/^distributionUrl=//p' "$PROPERTIES_FILE")
case "$distribution_url" in
  https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/*-bin.zip) ;;
  *)
    echo "Unsupported or missing Maven distributionUrl in $PROPERTIES_FILE" >&2
    exit 1
    ;;
esac

version=$(printf '%s\n' "$distribution_url" | sed -E 's#.*/apache-maven-([^/]+)-bin\.zip#\1#')
cache_root="${HOME}/.m2/wrapper/dists/apache-maven-${version}"
distribution_dir="${cache_root}/apache-maven-${version}"
maven_executable="${distribution_dir}/bin/mvn"
archive_path="${cache_root}/apache-maven-${version}-bin.zip"

if [ ! -x "$maven_executable" ]; then
  mkdir -p "$cache_root"
  if [ ! -f "$archive_path" ]; then
    echo "Downloading Maven ${version}..."
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$distribution_url" -o "$archive_path"
    elif command -v wget >/dev/null 2>&1; then
      wget -q "$distribution_url" -O "$archive_path"
    else
      echo "Maven Wrapper requires curl or wget to download Maven." >&2
      exit 1
    fi
  fi

  temporary_dir="${cache_root}/extract-$$"
  mkdir -p "$temporary_dir"
  cleanup() { rm -rf "$temporary_dir"; }
  trap cleanup EXIT HUP INT TERM
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$archive_path" -d "$temporary_dir"
  else
    echo "Maven Wrapper requires unzip to extract Maven." >&2
    exit 1
  fi
  if [ ! -x "$temporary_dir/apache-maven-${version}/bin/mvn" ]; then
    echo "Downloaded Maven archive has an unexpected layout." >&2
    exit 1
  fi
  mv "$temporary_dir/apache-maven-${version}" "$distribution_dir"
  chmod +x "$maven_executable"
fi

exec "$maven_executable" -f "$BASE_DIR/pom.xml" "$@"
