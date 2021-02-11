. "$PSScriptRoot\constants.ps1"

$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName 
Import-Module $ManifestFile -DisableNameChecking -Force

$cp = @{
    Provider   = 'sqloledb' 
    DataSource = $Script:SqlInstance 
    Credential = $Script:SqlOleDbCredential 
}
Describe "Get-OleDbColumnMetadata with -datasource to '$($cp.DataSource)', foo->$(($cp.Credential).Username )<-foo" -Tag $CommandName, DataSource, OLEDB {

    # this will take a long while to bring back a lot of columns from 'master', so we will just bring back one table's worth of columns
    $Report = Get-OleDbColumnMetadata @cp -TableCatalog 'master' -TableName 'MSreplication_options'

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
Describe "Get-OleDbColumnMetadata with -ConnectionString to '$($cp.DataSource)'" -Tag $CommandName, ConnectionString, OLEDB {
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

    # this will take a long while to bring back a lot of columns from 'master', so we will just bring back one table's worth of columns
    $Report = Get-OleDbColumnMetadata -TableCatalog 'master' -TableName 'MSreplication_options' -ConnectionString $builder.ConnectionString

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-OleDbColumnMetadata with -Connection to '$($cp.DataSource)'" -Tag $CommandName, Connection, OLEDB {
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

    # this will take a long while to bring back a lot of columns from 'master', so we will just bring back one table's worth of columns
    $Report = Get-OleDbColumnMetadata -TableCatalog 'master' -TableName 'MSreplication_options' -Connection $cn

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
