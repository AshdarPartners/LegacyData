<#
.SYNOPSIS
Retrieves values to use in a test configuration. Ex: server names, paths to data files.

.NOTES
THis should not be used to source credentials. See Get-LegacyDataCredential.ps1 for that.

This pulls values the locations of "test data" from a JSON file and puts in a hash for easy access.

You can override the values used for the SQL OLEDB and SQL (Server) Client tests with environment variables.

The (vague) idea is that this file will decide where to get test values from. Those sources might be:
1. A JSON file in this folder (which is the current implementation)
2. The environment ($env:)
3. A JSON file in a different location

#>
[CmdletBinding()]
param(
    [string] $ConfigurationFilePath
)

if (-not $ConfigurationFilePath) {

    $Path = $(Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))

    $Path = Join-Path -Path $path -Child "Tests"

    $ConfigurationFilePath = Join-Path -Path $path -Child "LegacyData.TestValues.json"

}

$TestConfiguration = Get-Content -Path $ConfigurationFilePath -Raw |
    ConvertFrom-Json

if ($env:LegacyDataSqlInstanceName) {
    $TestConfiguration.SqlOleDbHostName = $env:LegacyDataSqlInstanceName
}

if ($env:LegacyDataSqlDatabaseName) {
    $TestConfiguration.SqlOleDbDatabaseName = $env:LegacyDataSqlDatabaseName
}

Write-Verbose -Message "Read Test values from '$ConfigurationFilePath'"

$TestConfiguration
