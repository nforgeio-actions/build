# neon-build

**INTERNAL USE ONLY:** This GitHub action is not intended for general use.  The only reason why this repo is public is because GitHub requires it.

Builds a neonFORGE solution, optionally including installers and code documentation

## Examples

**neonCLOUD: Full build**
```
uses: nforgeio-actions/neon-build
with:
  repo: neonCLOUD
  build-tools: true
  build-installer: true
  build-codedoc: true
  build-log-path: ${{ github.workspace }}/build.log
```

**neonCLOUD: Build code only**
```
uses: nforgeio-actions/neon-build
with:
  repo: neonCLOUD
  build-log-path: ${{ github.workspace }}/build.log
```

