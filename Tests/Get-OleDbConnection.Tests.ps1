. "$PSScriptRoot\constants.ps1"

$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

<#
OleDb can connect to pretty much any database.
The module deals with "ISAM"-style databases.
I am testing this with SQL because I always have an instance running and I'm familiar with it.
I intend to create specfic tests for the various databases that are supported.
#>

$cp = @{
    Provider   = 'sqloledb' 
    DataSource = $Script:SqlInstance 
    Credential = $Script:SqlOleDbCredential 
}

Describe "Get a connection with -Datasource to '$($cp.DataSource)'" -Tag $CommandName, DataSource, OLEDB {
    $Cn = Get-OleDbConnection @cp

    It "should return a non-null object" {
        $Cn |
            Should -Not -BeNullOrEmpty
    }
    It "should return an object of type [System.Data.OleDb.OleDbConnection]" {
        $Cn |
            Should -BeOfType [System.Data.OleDb.OleDbConnection]
    }
}

Describe "Get a connection with -ConnectionString to '$($cp.DataSource)'" -Tag $CommandName, ConnectionString, OLEDB {
    $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
    $builder."Data Source" = $cp.DataSource
    $builder."Provider" = $cp.Provider

    if ($cp.Credential) {
        $builder["Trusted_Connection"] = $false
        $builder["User ID"] = $cp.Credential.UserName
        $builder["Password"] = $cp.Credential.GetNetworkCredential().Password
    }
    else {
        $builder["Trusted_Connection"] = $true
    }

    $Cn = Get-OleDbConnection -ConnectionString $builder.ConnectionString 

    It "should return a non-null object" {
        $Cn |
        Should -Not -BeNullOrEmpty
    }
    It "should return an object of type [System.Data.OleDb.OleDbConnection]" {
        $Cn |
        Should -BeOfType [System.Data.OleDb.OleDbConnection]
    }
}
