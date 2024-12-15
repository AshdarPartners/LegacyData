$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force


$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

# 'User' is one of several possible users.
$EncryptedPassword = ConvertTo-SecureString $TestConfiguration.SqlClientDBPassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $TestConfiguration.SqlClientDbUser, $EncryptedPassword

$cp = @{
    Credential = $Credential
    DataSource = $TestConfiguration.SqlClientDbHostName
    # Invoke-OleDbQuery doesn't support a -DatabaseName or -InitialCatalog
    # If we wanted to specify a particular database, we'd have to stuff this in the Extended properties parameter.
    # or we could cheat by using a FROM clause and a three-part name. That would only work with SqlServer.
    # DataSource = $TestConfiguration.SqlClientDbDatabaseName
}

Describe "Get-SqlClientTableMetadata with -datasource to '$($cp.DataSource)'"  -Tag $CommandName, DataSource, SqlClient {

    $Report = Get-SqlClientTableMetadata @cp -TableCatalog 'master'

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
Describe "Get-SqlClientTableMetadata with -ConnectionString to '$($cp.DataSource)'" -Tag $CommandName, ConnectionString, SqlClient {
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
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

    $Report = Get-SqlClientTableMetadata -TableCatalog 'master' -ConnectionString $builder.ConnectionString

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-SqlClientTableMetadata with -Connection to '$($cp.DataSource)'" -Tag $CommandName, Connection, SqlClient {
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
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

    $Cn = Get-SqlClientConnection -ConnectionString $builder.ConnectionString
    It "should return a valid connection" {
        $cn |
            Should -Not -BeNullOrEmpty
    }

    $Report = Get-SqlClientTableMetadata -TableCatalog 'master' -Connection $cn

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
