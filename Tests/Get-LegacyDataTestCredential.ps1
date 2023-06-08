<#
.SYNOPSIS
Get a stored set of credentials for testing this project.

.LINK
See https://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/
While Export- and Import-Clixml is pretty widely used, I took the basic structure of the XML file from Jaap Brasser's blog

#>
[CmdletBinding()]
param()

$FileDirectory = "${env:\userprofile}"
$FileName = 'LegacyData.Tests.cred'

$FilePath = Join-Path -Path $FileDirectory -child $FileName

if (Test-Path -Path $FilePath) {

    $Hash = Import-Clixml -Path $FilePath

    Write-Verbose -Message "Read credentials from '$FilePath'"

    # I used this as a test, when coding this script
    # invoke-sqlcmd2 -ServerInstance localhost -Query 'select getdate() RightNow, @@servername sn' -Credential $Hash.User

    $Hash
}
else {
    Write-Warning -Message "Can not read credentials from missing file '$FilePath'"
}
