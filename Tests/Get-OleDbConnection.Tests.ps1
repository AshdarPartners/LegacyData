param (
    $DataSource = '.\sql2012'
)
$FileName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

<#
OleDb can connect to pretty much any database.
The module deals with "ISAM"-style databases.
I am testing this with SQL because I always have an instance running and I'm familiar with it.
I intend to create specfic tests for the various databases that are supported.
#>

Describe "Get a connection with -Datasource to '$DataSource'" -Tag $FileName, DataSource, OLEDB {
    $Cn = Get-OleDbConnection -DataSource $DataSource -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes"

    It "should return a non-null object" {
        $Cn |
            Should -Not -BeNullOrEmpty
    }
    It "should return an object of type [System.Data.OleDb.OleDbConnection]" {
        $Cn |
            Should -BeOfType [System.Data.OleDb.OleDbConnection]
    }
}

Describe "Get a connection with -ConnectionString to '$DataSource'" -Tag $FileName, ConnectionString, OLEDB {
    $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
    $builder."Data Source" = $DataSource
    $builder."Provider" = "sqloledb"
    $builder."Trusted_Connection" = "Yes"

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
