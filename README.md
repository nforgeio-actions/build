# build

**INTERNAL USE ONLY:** This GitHub action is not intended for general use.  The only reason why this repo is public is because GitHub requires it.

Builds a neonFORGE solution, optionally including installers and code documentation.  Note that by default, the
action will succeed even when there are build errors.  Subsequent steps can use the **success** output to detect
the error in this case.

You can set the **fail-on-error** input to **true** to have the action step fail for build errors.  Note that the 
**success** and any other outputs will not be returned when the action fails.

## Examples

**neonCLOUD: Full build**
```
uses: nforgeio-actions/build
with:
  repo: neonCLOUD
  build-tools: true
  build-installer: true
  build-codedoc: true
  build-log-path: ${{ github.workspace }}/build.log
```

**neonCLOUD: Build code only**
```
uses: nforgeio-actions/build
with:
  repo: neonCLOUD
  build-log-path: ${{ github.workspace }}/build.log
```

**neonCLOUD: Build code only (jeff branch)**
```
uses: nforgeio-actions/build
with:
  repo: neonCLOUD
  build-branch: jeff
  build-log-path: ${{ github.workspace }}/build.log
```

**neonCLOUD: Build code only**
```
uses: nforgeio-actions/build
with:
  repo: neonCLOUD
  build-log-path: ${{ github.workspace }}/build.log
```

**neonCLOUD: Build code only and capture build log**
```
steps:
- id: build
  uses: nforgeio-actions/build
  with:
    repo: neonCLOUD
    build-log-path: ${{ github.workspace }}/build.log
- uses: nforgeio-actions/capture-log
  if: ${{ always() }}
  with:
    path: ${{ github.workspace }}/${{ env.build.log }}
    group: build.log
    type: build-log
    success: ${{ steps.build.success }}     # This step will fail when the build failed
```

**neonFORGE: Build code and fail the step for errors**

```
steps:
- id: build
  uses: nforgeio-actions/build
  with:
    repo: neonFORGE
    build-log-path: ${{ github.workspace }}/build.log
    fail-on-error: true
- uses: nforgeio-actions/capture-log
  if: ${{ always() }}
  with:
  path: ${{ github.workspace }}/${{ build.log }}
  group: build.log
  type: build-log
  fail-on-error: ${{ steps.build.outputs.success }}
```
