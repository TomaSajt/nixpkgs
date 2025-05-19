#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages curl prefetch-yarn-deps semver-tool git

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

nixpkgs="$(git rev-parse --show-toplevel)"

# we need to manually search through tags as releases aren't really made
# consistently upstream
versions=$(curl -fsSL "https://api.github.com/repos/logseq/logseq/tags" | jq -r '.[].name | ltrimstr("v")')

# two loops to keep it simple

declare -a valid_versions
for version in $versions; do
  if [ "$(semver validate "$version")" = "valid" ]; then
    valid_versions+=("$version")
  fi
done

if [ ${#valid_versions[@]} -eq 0 ]; then
  echo "no valid semver versions found"
  exit 1
fi

echo "considering versions ${valid_versions[@]}"

latest_version="0.0.0"
for version in ${valid_versions[@]}; do
  if [ "$(semver compare $latest_version $version)" = "-1" ] &&
    [ -z "$(semver get prerel $version)" ]; then
    latest_version=$version
  fi
done

echo "found latest version $latest_version"

# stolen from etcd
setKV() {
  sed -i "s|$1 = \".*\"|$1 = \"${2:-}\"|" package.nix
}

nixflags=(
  --extra-experimental-features
  'nix-command flakes'
)

repo_info="$(
  nix flake prefetch \
    "${nixflags[@]}" \
    --json "github:logseq/logseq/$latest_version"
)"

repo_hash="$(jq -r '.hash' <<<"$repo_info")"
repo_path="$(jq -r '.storePath' <<<"$repo_info")"

setKV logseqVersion "$latest_version"
setKV logseqHash "$repo_hash"

# for now, skip {cjlsTime,bbTasks}{Hash,Rev} as it will need to be manually
# patched as well, not updated much it seems

# stolen from sonic-pi
stripwhitespace() {
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

maven_hash="$(
  nix-build "$nixpkgs" -A logseq.mavenRepo 2>&1 |
    tail -n3 |
    grep -F got: |
    cut -d: -f2- |
    stripwhitespace
)"

setKV mavenDepsHash "$maven_hash"

# partially stolen from myself, #407741
setHash() {
  local almost_yarn_hash="$(prefetch-yarn-deps "$2/yarn.lock")"
  local yarn_hash="$(nix "${nixflags[@]}" hash convert --hash-algo sha256 "$almost_yarn_hash")"

  setKV "$1" "$yarn_hash"
}

setHash yarnOfflineCacheRootHash "$repo_path"
setHash yarnOfflineCacheStaticResourcesHash "$repo_path/static"
setHash yarnOfflineCacheAmplifyHash "$repo_path/packages/amplify"
setHash yarnOfflineCacheTldrawHash "$repo_path/tldraw"
