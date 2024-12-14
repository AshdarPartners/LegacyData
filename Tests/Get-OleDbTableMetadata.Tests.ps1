$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force


$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

# 'User' is one of several possible users.
$SqlLoginCredential = (Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestCredential.ps1')).SqlServerUser

$cp = @{
    Provider   = 'sqloledb'
    Credential = $SqlLoginCredential
    DataSource = $TestConfiguration.SqlOleDbHostName
    # Invoke-OleDbQuery doesn't support a -DatabaseName or -InitialCatalog
    # If we wanted to specify a particular database, we'd have to stuff thisinthe Extended properties parameter.
    # or we could cheat by using a FROM clause and a three-part name. That would only work with SqlServer.
    # DataSource = $TestConfiguration.SqlOleDbDatabaseName
}

Describe "Get-OleDbTableMetadata with -datasource to '$($cp.DataSource)'"  -Tag $CommandName, DataSource, OLEDB {

    $Report = Get-OleDbTableMetadata @cp -TableCatalog 'master'

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
Describe "Get-OleDbTableMetadata with -ConnectionString to '$($cp.DataSource)'" -Tag $CommandName, ConnectionString, OLEDB {
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

    $Report = Get-OleDbTableMetadata -TableCatalog 'master' -ConnectionString $builder.ConnectionString

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-OleDbTableMetadata with -Connection to '$($cp.DataSource)'" -Tag $CommandName, Connection, OLEDB {
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
    It "should return a valid connection" {
        $cn |
            Should -Not -BeNullOrEmpty
    }

    $Report = Get-OleDbTableMetadata -TableCatalog 'master' -Connection $cn

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
