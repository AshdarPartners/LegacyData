<#
.LINK
https://github.com/sqlcollaborative/dbatools/blob/development/tests/constants.ps1
I lifted the idea for this file from that file, as I needed to abstract away hardcoded aspects of my environment
#>

$LocalFile = Join-Path -Path $env:TEMP -ChildPath 'constants.ps1'
if (Test-Path C:\temp\constants.ps1) {
    Write-Verbose "$LocalFile found."
    . $LocalFile
}
elseif (Test-Path "$PSScriptRoot\constants.local.ps1") {
    Write-Verbose "tests\constants.local.ps1 found."
    . "$PSScriptRoot\constants.local.ps1"
}
else {
    $script:legacydataci_computer = "localhost"
    # $script:SqlInstance = "localhost\sql2008r2sp2"
    # $script:SqlInstance = "localhost\sql2012"
    # $script:SqlInstance = "localhost\sql2016"
    # $script:SqlInstance = "localhost\sql2017"
    $script:SqlInstance = "localhost\sql2019"
    #    $script:appveyorlabrepo = "C:\github\appveyor-lab"
    # $instances = @($script:instance1, $script:instance2)
}

if ($env:appveyor) {
    $PSDefaultParameterValues['*:WarningAction'] = 'SilentlyContinue'
}