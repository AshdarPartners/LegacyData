$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

<#
OleDb can connect to pretty much any database.
The module deals with "ISAM"-style databases.
I am testing this with SQL because I always have an instance running and I'm familiar with it.
I intend to create specific tests for the various databases that are supported.
#>

$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')
$EncryptedPassword = ConvertTo-SecureString $TestConfiguration.OleDbDbPassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $TestConfiguration.OleDbDbUser, $EncryptedPassword

$cp = @{
    Provider   = 'sqloledb'
    Credential = $Credential
    DataSource = $TestConfiguration.OleDbHostName
    # Invoke-OleDbQuery doesn't support a -DatabaseName or -InitialCatalog
    # If we wanted to specify a particular database, we'd have to stuff this in the Extended properties parameter.
    # or we could cheat by using a FROM clause and a three-part name. That would only work with SqlServer.
    # DataSource = $TestConfiguration.SqlOleDbDatabaseName
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
