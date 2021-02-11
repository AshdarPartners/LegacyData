. "$PSScriptRoot\constants.ps1"

$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

$Provider = 'sqloledb'

$cp = @{
    Provider = $Provider 
    DataSource =$Script:SqlInstance 
    Credential= $Script:SqlOleDbCredential 
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
