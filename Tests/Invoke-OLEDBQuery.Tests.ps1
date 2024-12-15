$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')
$EncryptedPassword = ConvertTo-SecureString $TestConfiguration.OleDbDBPassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $TestConfiguration.OleDbDbUser, $EncryptedPassword

$cp = @{
    Provider   = 'sqloledb'
    DataSource = $TestConfiguration.OleDbHostName
    # Invoke-OleDbQuery doesn't support a -DatabaseName or -InitialCatalog
    # If we wanted to specify a particular database, we'd have to stuff this in the Extended properties parameter.
    # or we could cheat by using a FROM clause and a three-part name. That would only work with SqlServer.
    # DataSource = $TestConfiguration.SqlClientDbDatabaseName
}

if ($Credential) {
    $cp.Credential = $Credential
}

Describe "SQLOLEDB simple query to '$($cp.DataSource)'" -Tag $CommandName, OLEDB {
    $Query = 'select getdate() RightNow'
    $Report = Invoke-OleDbQuery @cp -query $Query
    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

# Describe "SQLOLEDB query with SQLParameter to '$($cp.DataSource)'" -Tag $CommandName, OLEDB {
#     # this query uses the ? as a placeholder and not @SomeName because we are using oledb and not sqlclient
#     $Query = "select getdate() RightNow where getdate() > ? "
#     $Params = @{WasThen = "1/1/1980 1:00 PM" }
#     $Report = Invoke-OleDbQuery @cp -query $Query -SqlParameters $Params
#     It "should return a result set" {
#         $Report |
#             Should -Not -BeNullOrEmpty
#     }
# }
