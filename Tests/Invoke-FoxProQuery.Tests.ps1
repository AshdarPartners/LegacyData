$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

if ([Environment]::Is64BitProcess) {
    Write-Error "Visual Foxpro drivers only work in 32 bit processes"
}

$cp = @{
    DataSource = $TestConfiguration.FoxProNorthWindDbPath
}

Describe "FoxPro simple query to '$($cp.DataSource)'" -Tag $CommandName, FoxPro {
    $Query = 'select * from employees'
    $Report = Invoke-FoxProQuery @cp -Query $Query -As 'SingleValue'
    It "should return a result set" {
        $Report | Should -Not -BeNullOrEmpty
    }
}

# Invoke-AdoQuery does not support '-SqlParameters' like Invoke-OLEDBQuery does yet, so I'm commenting this out for use as a
# template at some point in the future.
Describe "FoxPro query with SQLParameter to '$($cp.DataSource)'" -Tag $CommandName, FoxPro {

    # this query uses the ? as a placeholder and not @SomeName because we are using ado and not sqlclient
    $Query = 'select COUNT(*) from employees where lastname = ?'
    $Params = @{lastname = "Dodsworth" }
    $Report = Invoke-FoxProQuery @cp -query $Query -SqlParameters $Params -As SingleValue

    It "should return a result" {
        $Report | Should -Not -BeNullOrEmpty
    }

    It "should return a result set with a single result" {
        $Report | Should -Be 1
    }
}
