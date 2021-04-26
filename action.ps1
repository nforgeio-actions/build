#------------------------------------------------------------------------------
# FILE:         action.ps1
# CONTRIBUTOR:  Jeff Lill
# COPYRIGHT:    Copyright (c) 2005-2021 by neonFORGE LLC.  All rights reserved.
#
# The contents of this repository are for private use by neonFORGE, LLC. and may not be
# divulged or used for any purpose by other organizations or individuals without a
# formal written and signed agreement with neonFORGE, LLC.
      
# Verify that we're running on a properly configured neonFORGE jobrunner 
# and import the deployment and action scripts from neonCLOUD.
      
# NOTE: This assumes that the required [$NC_ROOT/Powershell/*.ps1] files
#       in the current clone of the repo on the runner are up-to-date
#       enough to be able to obtain secrets and use GitHub Action functions.
#       If this is not the case, you'll have to manually pull the repo 
#       first on the runner.
      
$ncRoot = $env:NC_ROOT
      
if ([System.String]::IsNullOrEmpty($ncRoot) -or ![System.IO.Directory]::Exists($ncRoot))
{
    throw "Runner Config: neonCLOUD repo is not present."
}
      
$ncPowershell = [System.IO.Path]::Combine($ncRoot, "Powershell")
      
Push-Location $ncPowershell
. ./includes.ps1
Pop-Location
      
# Read the inputs and initialize other variables.
      
$repo            = Get-ActionInput "repo"
$buildLogPath    = Get-ActionInput "build-log-path"
$buildTools      = $(Get-ActionInput "build-tools") -eq "true"
$buildInstallers = $(Get-ActionInput "build-installers") -eq "true"
$buildCodeDoc    = $(Get-ActionInput "build-codedoc") -eq "true"

# Initialize some outputs.

Set-ActionOutput "build-branch"     $buildBranch
Set-ActionOutput "build-commit"     $buildCommit

# Perform the operation in a try/catch.

try
{
    # Delete any existing build log file.
      
    if ([System.IO.File]::Exists($buildLogPath))
    {
        [System.IO.File]::Delete($buildLogPath)
    }
      
    Switch ($repo)
    {
        ""
        {
            throw "[inputs.repo] is required."
        }
          
        "neonCLOUD"
        {
            $buildScript      = [System.IO.Path]::Combine($env:NC_TOOLBIN, "neoncloud-builder.ps1")
            $toolsOption      = ""
            $installersOption = ""
            $codeDocOption    = ""
              
            if ($buildTools)
            {
                $toolsOption = "-tools"
            }
              
            if ($buildInstallers)
            {
                $installersOption = "-installers"
            }
              
            if ($buildCodeDoc)
            {
                $codeDocOption = "-codedoc"
            }
              
            # Set the commit URI output.

            Set-ActionOutput "build-commit-uri" "https://github.com/nforgeio/neonCLOUD/commit/$buildCommit"

            # Perform the build.

            & pwsh $buildScript $toolsOption $installersOption $codeDocOption >> $buildLogPath
            ThrowOnExitCode

            # Set the build outputs based on the local repo configuration.

            Push-Location $env:NC_ROOT

                $buildBranch = $(& git branch --show-current).Trim()
                ThrowOnExitCode

                $buildCommit = $(& git rev-parse HEAD).Trim()
                ThrowOnExitCode

            Pop-Location
            Break
        }
          
        "neonKUBE"
        {
            $buildScript      = [System.IO.Path]::Combine($env:NF_TOOLBIN, "neon-builder.ps1")
            $toolsOption      = ""
            $installersOption = ""
            $codeDocOption    = ""
              
            if ($buildTools)
            {
                $toolsOption = "-tools"
            }
              
            if ($buildInstallers)
            {
                $installersOption = "-installers"
            }
              
            if ($buildCodeDoc)
            {
                $codeDocOption = "-codedoc"
            }

            # Set the commit URI output.

            Set-ActionOutput "build-commit-uri" "https://github.com/nforgeio/neonCLOUD/commit/$buildCommit"

            # Perform the build.

            & pwsh $buildScript $toolsOption $installersOption $codeDocOption >> $buildLogPath
            
            if ($LastExitCode -ne 0)
            {
                Write-ActionError 
            }

            # Set the build outputs based on the local repo configuration.

            Push-Location $env:NF_ROOT

                $buildBranch = $(& git branch --show-current).Trim()
                ThrowOnExitCode

                $buildCommit = $(& git rev-parse HEAD).Trim()
                ThrowOnExitCode

            Pop-Location
            Break
        }
          
        "neonLIBRARY"
        {
            throw "[neonLIBRARY] build is not implemented."
            Break
        }
          
        "cadence-samples"
        {
            throw "[cadence-samples] build is not implemented."
            Break
        }
          
        "temporal-samples"
        {
            throw "[temporal-samples] build is not implemented."
            Break
        }
          
        default
        {
            throw "[$repo] is not a supported repo."
            Break
        }
    }
}
catch
{
    Write-ActionError "****************************************************************"
    Write-ActionError "* BUILD FAILED!                                                *"
    Write-ActionError "*                                                              *"
    Write-ActionError "* Check the captured log in the next step for more information *"
    Write-ActionError "****************************************************************"
    Write-ActionException $_

    Set-ActionOutput "success" "false"
    return
}

Set-ActionOutput "success" "true"
