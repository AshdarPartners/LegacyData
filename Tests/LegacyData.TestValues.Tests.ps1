$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

$SqlLoginCredential = (Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestCredential.ps1')).SqlServerUser

$cp = @{
    Provider   = 'sqloledb'
    Credential = $SqlLoginCredential
    DataSource = $TestConfiguration.SqlOleDbHostName
    # Invoke-OleDbQuery doesn't suport a -DatabaseName or -InitialCatalog
    # If we wanted to specify a particular database, we'd have to stuff thisinthe Extended properties parameter.
    # or we could cheat by using a FROM clause and a three-part name. That would only work with SqlServer.
}


Describe "Check AccessPresidentPath to a test MDB" -Tag TestValues {

    $AccessFilePath = Join-Path -Path $Path -ChildPath $TestConfiguration.AccessPresidentPath

    $Report = Test-path -path $AccessFilePath

    It "MDB should exist" {
        $Report | Should -BeTrue
    }
}

Describe "Check DBaseNorthWindDbPath FoxPro path should exist" -Tag TestValues {

    $Report = Test-path -path $TestConfiguration.DBaseNorthWindDbPath

    It "DBase should exist" {
        $Report | Should -BeTrue
    }
}

Describe "Check FoxProNorthWindDbPath FoxPro path should exist" -Tag TestValues {

    $Report = Test-path -path $TestConfiguration.FoxProNorthWindDbPath

    It "MDB should exist" {
        $Report | Should -BeTrue
    }
}

Describe "Check SQL Server parameters work for '$($cp.DataSource)'" -Tag TestValues {

    $Report = Invoke-OleDbQuery @cp -query 'select 1'

    It "MDB should exist" {
        $Report | Should -BeTrue
    }
}
