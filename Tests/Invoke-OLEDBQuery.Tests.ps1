. "$PSScriptRoot\constants.ps1"

$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

$cp = @{
    Provider = 'sqloledb' 
    DataSource =$Script:SqlInstance 
    Credential= $Script:SqlOleDbCredential 
}

Describe "SQLOLEDB simple query to '$($cp.DataSource)'" -Tag $CommandName, OLEDB {
    $Query = 'select getdate() RightNow'
    $Report = Invoke-OleDbQuery @cp -query $Query 
    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

Describe "SQLOLEDB query with SQLParameter to '$($cp.DataSource)'" -Tag $CommandName, OLEDB {
    # this query uses the ? as a placeholder and not @SomeName because we are using oledb and not sqlclient
    $Query = "select getdate() RightNow where getdate() > ? "
    $Params = @{WasThen = "1/1/1980 1:00 PM" }
    $Report = Invoke-OleDbQuery @cp -query $Query -SqlParameters $Params
    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}
