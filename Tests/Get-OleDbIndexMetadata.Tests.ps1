. "$PSScriptRoot\constants.ps1"

$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force
$Provider = 'sqloledb'

Describe "Get-OleDbIndexMetadata with -datasource to '$script:SqlInstance'" -Tag $CommandName, DataSource, OLEDB {

    $Report = Get-OleDbIndexMetadata -TableCatalog 'master' -DataSource $script:SqlInstance -Provider $Provider -ExtendedProperties "Trusted_Connection=Yes"

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-OleDbIndexMetadata with -ConnectionString to '$script:SqlInstance'" -Tag $CommandName, ConnectionString, OLEDB {
    $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
    $builder."Data Source" = $script:SqlInstance
    $builder."Provider" = $Provider
    $builder."Trusted_Connection" = "Yes"

    $Report = Get-OleDbIndexMetadata -TableCatalog 'master' -ConnectionString $builder.ConnectionString

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-OleDbIndexMetadata with -Connection to '$script:SqlInstance'" -Tag $CommandName, Connection, OLEDB {
    $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
    $builder."Data Source" = $script:SqlInstance
    $builder."Provider" = $Provider
    $builder."Trusted_Connection" = "Yes"

    $Cn = Get-OleDbConnection -ConnectionString $builder.ConnectionString
    It "should return a valid connection" {
        $cn |
            Should -Not -BeNullOrEmpty
    }

    $Report = Get-OleDbIndexMetadata -TableCatalog 'master' -Connection $cn


    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
