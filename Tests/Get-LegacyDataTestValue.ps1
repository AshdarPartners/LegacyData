<#
.SYNOPSIS
Retrieves values to use in a test configuration. Ex: server names, paths to data files.

.NOTES
THis should not be used to source credentials. See Get-LegacyDataCredential.ps1 for that.

The (vauge) idea is that this file will decide where to get test values from. Those sources might be:
1. A JSON file in this folder (which is the current implementation)
2. The environmentment ($env:)
3. A JSON file in a different location

#>
[CmdletBinding()]
param()

$Path = $(Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))

$Path = Join-Path -Path $path -Child "Tests"

$ConfigurationFile = Join-Path -Path $path -Child "LegacyData.TestValues.json"

$TestConfiguration = Get-Content -Path $ConfigurationFile -Raw |
    ConvertFrom-Json

Write-Verbose -Message "Read Test values from '$ConfigurationFile'"
$TestConfiguration

<#

I'm leaving this hear as an untested example of what we might do, it's more for the idea than a good
example of an implementation


$FileDirectory = "${env:\userprofile}"
$FileName = 'LegacyData.Tests.cred'

$LocalFile = Join-Path -path $FileDirectory -child $FileName

$ProjectFile = Join-Path -path $FileDirectory -child $FileName


if (Test-Path $LocalFile) {
    Write-Verbose "$LocalFile found."
    $UseThisFile = $LocalFile

}
elseif (Test-Path $ProjectFile )") {
    Write-Verbose "$ProjectFile found."
    $UseThisFile = $ProjectFile
}
else {
    # Pull things from $env:

    # the trick with this is that it has to match what comes out of the JSON file

    $TestConfigurationEnvironment = @{
        SqlInstance = $env:SqlInstanceName
        SqlDatabase = $env:SqlDatabase
        # and so forth.

    }
}

if ($TestConfigurationEnvironment) {
    $TestConfigurationEnvironment
}
else {
    $TestConfiguration = Get-Content -Path $UseThisFile -Raw |
        ConvertFrom-Json
    $TestConfiguration
}


#>