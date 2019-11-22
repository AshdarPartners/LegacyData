param (
    #fixme: hard-coded param is bad practice
    $DataSource = ".\sql2012"
)
$ModuleName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force
$Provider = 'sqloledb'

Describe "Get-OleDbIndexMetadata with -datasource to '$DataSource'" -Tag $ModuleName, DataSource, OLEDB {

    $Report = Get-OleDbIndexMetadata -TableCatalog 'master' -DataSource $DataSource -Provider $Provider -ExtendedProperties "Trusted_Connection=Yes"

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-OleDbIndexMetadata with -ConnectionString to '$DataSource'" -Tag $ModuleName, ConnectionString, OLEDB {
    $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
    $builder."Data Source" = $DataSource
    $builder."Provider" = $Provider
    $builder."Trusted_Connection" = "Yes"

    $Report = Get-OleDbIndexMetadata -TableCatalog 'master' -ConnectionString $builder.ConnectionString

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-OleDbIndexMetadata with -Connection to '$DataSource'" -Tag $ModuleName, Connection, OLEDB {
    $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
    $builder."Data Source" = $DataSource
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
