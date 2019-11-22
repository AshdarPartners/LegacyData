param (
    #fixme: hard-coded param is bad practice
    $DataSource = '.\sql2012'
)
$FileName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

Describe "SQLOLEDB simple query to '$DataSource'" -Tag $FileName, OLEDB {
    $Report = Invoke-OleDbQuery -DataSource $DataSource -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -query 'select getdate() RightNow'
    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "SQLOLEDB query with SQLParameter to '$DataSource'" -Tag $FileName, OLEDB {
    # this query uses the ? as a placeholder and not @SomeName because we are using oledb and not sqlclient
    $Query = "select getdate() RightNow where getdate() > ? "
    $Params = @{WasThen = "1/1/1980 1:00 PM" }
    $Report = Invoke-OleDbQuery -DataSource $DataSource -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -query $Query -SqlParameters $Params
    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
