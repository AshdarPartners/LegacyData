<#
.SYNOPSIS
Get a stored set of credentials for testing this project.

.EXAMPLE
$Credential = Get-LegacyDataTestCredential.ps1
invoke-sqlcmd2 -ServerInstance localhost -Query 'select getdate() RightNow, @@servername sn' -Credential $Credential.User

I used this as a test, when coding this script

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

    $Hash
}
else {
    $Message = "Can not find credentials file '{0}'" -f @($FilePath)
    Write-Verbose -Message $Message
}
