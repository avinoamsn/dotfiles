# Helpful bash/terminal config & tips

## VSCode

- add this markdownlint config line to the bottom of `commit.md`: `<!-- markdownlint-configure-file { "first-line-heading": false } -->`

- regex search to match all characters (including whitespaces) up to a given string: `<start_string>[\s\S\n]+?<end_string>` (source: <https://community.dynamics.com/blogs/post/?postid=046196e4-2510-4af8-a93e-82214bee3d3a>)
  - example: `<PrimaryButton[\s\S\n^>]+?text=[^>]+?>` - finds `PrimaryButton` els w/ `text=` prop assignment inside the tag

## Powershell config

- enable winget (if it's not automatically available):

  ```bash
  Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
  ```

  ([more info](https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget))

- install/update powershell 7:

  ```bash
  winget install --id Microsoft.Powershell --source winget
  ```

- install chocolatey:

  ```bash
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('<https://chocolatey.org/install.ps1>'))
  ```

- install scoop:

  ```bash
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
  ```

## Bash

### use an argument from the previous command

```bash
!^      # first argument
!$      # last argument
!*      # all arguments
!:2     # second argument

!:2-3   # second to third arguments
!:2-$   # second to last arguments
!:2*    # second to last arguments
!:2-    # second to next to last arguments

!:0     # the command
!!      # repeat the previous line
```
