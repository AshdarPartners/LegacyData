<#
.SYNOPSIS
Get a stored set of credentials for testing this project.

.LINK
See https://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/
While Export- and Import-Clixml is pretty widely used, I took the basic structure of the XML file from Jaap Brasser's blog

#>




$FileDirectory = "${env:\userprofile}"
$FileName = 'LegacyData.Tests.cred'

$FilePath = Join-Path -path $FileDirectory -child $FileName

# I am only using 'User' at this time. 
$Hash = @{
    # 'Admin'      = Get-Credential -Message 'Please enter administrative credentials'
    # 'RemoteUser' = Get-Credential -Message 'Please enter remote user credentials'
    'User'       = Get-Credential -Message 'Please enter user credentials'
}
$Hash | Export-Clixml -Path $FilePath

Write-Verbose -verbose -Message "Wrote credentials to '$FilePath'"
