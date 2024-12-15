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

Describe "Get-SqlClientIndexMetadata with -datasource '$($cp.DataSource)'" -Tag $CommandName, DataSource, SqlClient {

    $Report = Get-SqlClientIndexMetadata @cp -DatabaseName $TestConfiguration.SqlClientDbDatabaseName

    It "should return a result set" {
        Set-ItResult -Skipped -Because "We are testing against master. GetSchema() reports no indexes in master. We need a custom test database, which is a lot of work."
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-SqlClientIndexMetadata with -ConnectionString '$($cp.DataSource)'" -Tag $CommandName, ConnectionString, SqlClient {
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder."Data Source" = $cp.DataSource
    $builder."Initial Catalog" = $TestConfiguration.SqlClientDbDatabaseName

    if ($cp.Credential) {
        $builder["Trusted_Connection"] = $false
        $builder["User ID"] = $cp.Credential.UserName
        $builder["Password"] = $cp.Credential.GetNetworkCredential().Password
    }
    else {
        $builder["Trusted_Connection"] = $true
    }

    $Report = Get-SqlClientIndexMetadata -ConnectionString $builder.ConnectionString

    It "should return a result set" {
        Set-ItResult -Skipped -Because "We are testing against master. GetSchema() reports no indexes in master. We need a custom test database, which is a lot of work."
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-SqlClientIndexMetadata with -Connection '$($cp.DataSource)'" -Tag $CommandName, Connection, SqlClient {
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder."Data Source" = $cp.DataSource
    $builder."Provider" = $cp.Provider
    $builder."Initial Catalog" = $TestConfiguration.SqlClientDbDatabaseName

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

    $Report = Get-SqlClientIndexMetadata -TableCatalog 'master' -Connection $cn

    It "should return a result set" {
        Set-ItResult -Skipped -Because "We are testing against master. GetSchema() reports no indexes in master. We need a custom test database, which is a lot of work."
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
