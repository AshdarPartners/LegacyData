$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force


$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

if (-not (Test-Path $TestConfiguration.FoxProNorthWindDbPath )) {
    throw "This script requires the 'Northwind' sample database, which is part of the Visual FoxPro OLEDB driver installation package."
}

$BecauseFPOleDbHasNo64BitDriver = "FPOleDb driver has no 64-bit version, only a 32-bit version"
Describe "Get-FoxProTableMetaData with -Datasource to 'Northwind'" -Tag 'Get-FoxProTableMetaData', DataSource, OLEDB {
    
    It "should return a result set" {
        if ([Environment]::Is64BitProcess) { Set-ItResult -Skipped -Because $BecauseFPOleDbHasNo64BitDriver }

        Get-FoxProTableMetaData -Datasource ($TestConfiguration.FoxProNorthWindDbPath) |
            Should -Not -BeNullOrEmpty
    }
}

Describe "Get-FoxProIndexMetaData with -Connection to '$($cp.DataSource)'" -Tag Get-FoxProIndexMetaData, DataSource, OLEDB {
    $TableName = 'employees' 
    
    It "should return a result set for '$TableName'" {
        if ([Environment]::Is64BitProcess) { Set-ItResult -Skipped -Because $BecauseFPOleDbHasNo64BitDriver }
        Get-FoxProIndexMetaData -Datasource $TestConfiguration.FoxProNorthWindDbPath -TableName $TableName |
            Should -Not -BeNullOrEmpty
    }
}
