$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force


$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

if (-not (Test-Path $TestConfiguration.DBaseNorthWindDbPath )) {
    throw "This script requires the 'Northwind' sample database, which is part of the Visual DBase OLEDB driver installation package."
}
$BecauseWeDoNotHaveGoodDbaseTestFiles = "we do not have good dBase test files"

Describe "Get-DBaseTableMetaData with -Datasource to 'Northwind'"  -Tag 'Get-DBaseTableMetaData', DataSource, OLEDB {
    
    It "should return a result set" {
        Set-ItResult -Skipped -Because $BecauseWeDoNotHaveGoodDbaseTestFiles
        Get-DBaseTableMetaData -Datasource $TestConfiguration.DBaseNorthWindDbPath |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-DBaseIndexMetaData with -Connection to '$($cp.DataSource)'" -Tag Get-DBaseIndexMetaData, DataSource, OLEDB {
    $TableName = 'employees'
    
    It "should return a result set for '$TableName'" {
        Set-ItResult -Skipped -Because $BecauseWeDoNotHaveGoodDbaseTestFiles
        Get-DBaseIndexMetaData -Datasource $TestConfiguration.DBaseNorthWindDbPath -TableName $TableName |
            Should -Not -BeNullOrEmpty
    }
}
