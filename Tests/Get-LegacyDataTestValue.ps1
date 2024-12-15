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

#region Allow override of OleDB values
if ($env:LegacyDataOleDBInstanceName) {
    $TestConfiguration.OleDbOleDbHostName = $env:LegacyDataOleDbInstanceName
}

if ($env:LegacyDataOleDbDatabaseName) {
    $TestConfiguration.OleDbOleDbDatabaseName = $env:LegacyDataOleDbDatabaseName
}

if ($env:LegacyDataOleDBUser) {
    $TestConfiguration.OleDBOleDbUser = $env:LegacyDataOleDBUser
}

if ($env:LegacyDataOleDbPassword) {
    $TestConfiguration.OleDbDbPassword = $env:LegacyDataOleDbDbPassword
}

# $EncryptedPassword = ConvertTo-SecureString $TestConfiguration.OleDbPassword -AsPlainText -Force
# $TestConfiguration.LegacyDataOleDbCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $TestConfiguration.OleDbUser, $EncryptedPassword

#endregion

#region Allow override of SqlClient values
if ($env:LegacyDataSqlClientInstanceName) {
    $TestConfiguration.SqlClientDbHostName = $env:LegacyDataSqlClientInstanceName
}

if ($env:LegacyDataSqlClientDatabaseName) {
    $TestConfiguration.SqlClientDbDatabaseName = $env:LegacyDataSqlClientDatabaseName
}

if ($env:LegacyDataSqlClientDBUser) {
    $TestConfiguration.SqlClientDBUser = $env:LegacyDataSqlClientDBUser
}

if ($env:LegacyDataSqlClientDBPassword) {
    $TestConfiguration.SqlClientDBPassword = $env:LegacyDataSqlClientDBPassword
}

#endregion

# $PasswordFilePath = "~\OneDrive - Ashdar Partners\Active Projects\LegacyData-Helper\Docker\sapassword.env"
# $Env:SA_PASSWORD = (Get-Content $PasswordFilePath).Replace('SA_PASSWORD=','')

# # set up the credential
# $password = ConvertTo-SecureString $Env:SA_PASSWORD -AsPlainText -Force
# $SqlCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sa", $password

# Resolve a fully qualified file path for the mdb file
$TestConfiguration.AccessPresidentPath = Join-Path -Path $PSScriptRoot -Child $TestConfiguration.AccessPresidentPath

if (-not (Test-Path -Path $TestConfiguration.AccessPresidentPath)) {
    $Message = "The Access President database was not found at '{0}'" -f @($TestConfiguration.AccessPresidentPath)
    Throw [System.IO.FileNotFoundException] $Message
}

Write-Verbose -Message "Read Test values from '$ConfigurationFilePath'"

$TestConfiguration

