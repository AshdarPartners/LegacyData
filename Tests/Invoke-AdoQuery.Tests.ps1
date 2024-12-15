$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

# We won't be needing any credentials for this set of tests
# $SqlLoginCredential = (Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestCredential.ps1')).SqlServerUser

if ([Environment]::Is64BitProcess) {
    # If this fails, you might try ACE verisons other than 12 like 13, 14, 15, 16 and so forth
    # ACE has 32 bit and 64 bit drivers.
    $Provider = 'Microsoft.ACE.OLEDB.12.0'
}
else {
    # Jet was 32 bit only.
    $Provider = 'Microsoft.Jet.OLEDB.4.0'
}


$cp = @{
    Provider   = $Provider
    DataSource = $TestConfiguration.AccessPresidentPath
}

Describe "Ado simple query to '$($cp.DataSource)'" -Tag $CommandName, ADO {
    $Query = 'select * from presidents'
    $Report = Invoke-AdoQuery @cp -query $Query
    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

# Invoke-AdoQuery does not support '-SqlParameters' like Invoke-OLEDBQuery does yet, so I'm commenting this out for use as a
# template at some point in the future.
Describe "Ado query with SQLParameter to '$($cp.DataSource)'" -Tag $CommandName, ADO {

    # this query uses the ? as a placeholder and not @SomeName because we are using ado and not sqlclient
    $Query = 'select * from presidents where lastname = ?'
    $Params = @{LastName = "roosevelt" }

    It "should return a result set" {
        Set-ItResult -Skipped -Because "Invoke-AdoQuery does not support parameterized queries at this time."

        $Report = Invoke-AdoQuery @cp -query $Query -SqlParameters $Params
        $Report | Should -Not -BeNullOrEmpty
    }
}
