function Get-DbaseConnection {
    <#
    .SYNOPSIS
    Returns an OleDB connection to a DBase database

    .DESCRIPTION
    Returns an OleDB connection to a DBase database. 
    
    This *seems* to work for FoxPro as well, but there has not been extenstive testing.

    www.connectionstrings.com is an excellent resource for connection strings for specfic drivers.

    .NOTES
    This cmdlet uses "ACE", which is available for 32 bit and 64 bit versions of Windows. It is freely downloadable from 
    Microsoft's site. Installing both, side-by-side, seems to be difficult/impossible. Google for details.

    AFAIK, this cmdlet will work with FoxPro data for simple reads and writes, up to and including Visual Fox Pro 9.0. 
    Tables with memo fields are not compatible between dBase and FoxPro. If you have a FoxPro table with a memo field, dBase will
    barf.
    
    Indexes are also a problem. I wouldn't trust using indexes in cross FoxPro/dBase environment.

    If you have trouble using this cmdlet with FoxPro data, try the *-FoxPro* cmdlets in this module. They use Vfpoledb, which has
    it's own quirks and features, but should work better.

    Back in the 1990s, many dBase and (non-Visual) FoxPro applications got into trouble because file caching was a new feature
    that was implemented in the networking layer of Windows workstations and file caching was common on Windows file servers. Dbase
    doesn't understand file caching. It can't open files in write-through mode. This can lead to issues where different workstations
    try to update the same records in the wrong order, try to insert records into the same "empty" spot at the end of the file and
    so forath. This is a ++ likely source of trouble in your applications.

    .OUTPUTS
    [System.Data.OleDb.OleDbConnection]

    .PARAMETER DataSource
    This is a file path to a DBase database.

    .PARAMETER ExtendedProperties
    Some providers use a bevy of 'extended properties' in the connection string, this is a bucket into which you can throw them.
    The exact capability and syntax is provider-specific.
    The are usually key-value pairs in the format "Prop=something;AnotherProp=SomethingElse".
    No attempt is made to validate these properties or even validate the string. The first indication of trouble is usually that the Open() call will fail.

    .PARAMETER Credential
    This should be a 'standard' PSCredential object. Defaults to User="Admin", password = ""

    .EXAMPLE
    $cn = Get-DbaseConnection -DataSource (get-psdrive temp).root
    Invoke-DbaseQuery -Connect $cn -query 'select * from nrthwind'
    $cn.close()
    $cn.dispose()
    $cn = $null

    .EXAMPLE
    try {
        $cn = Get-DbaseConnection -DataSource 'c:\dbfiles'
        # do stuff
    }
    finally {
        # clean up. This step is key or you risk leaking resources
        $cn.Close()
        $cn.Dispose()

    }

    .LINK
    https://www.connectionstrings.com/

    #>
    [OutputType([System.Data.OleDb.OleDbConnection])]
    param (
        [Parameter(Mandatory = $true)]
        [string] $DataSource,
        [System.Management.Automation.PSCredential] $Credential

    )

    # Jet and ACE strings. Jet was 32 bit only, ACE has 32 bit and 64 bit builds.
    # Having 32 bit is more popular, apparently, even on 64 bit OSes as MS has been pushing 32 bit Office until 2018 or 2019.
    # Installing 32 bit and 64 bit side-by-side seems to be complex; google for it.
    #
    # Provider=Microsoft.Jet.OLEDB.4.0;Data Source=c:\folder;Extended Properties=dBASE IV; User ID=Admin; Password=;
    # Provider=Microsoft.ACE.OLEDB.12.0; Data Source=c:\folder;Extended Properties=dBASE IV; User ID=Admin;

    # FIXME: Which version to use?
    # I've always just hard-coded whatever is on my workstation, BUT there must be a better way to pick one.
    # right now, Get-InstalledDatabaseDriverList shows these 32 bit Ace OLEDB drivers. BUT, the only one
    # that works is 16.0. I believe that this corresponds to Access 2016. Wierdly, both 12.0 and 15.0
    # claime to be version 15.0.4873.1000
    # [string] $Provider = 'Microsoft.ACE.OLEDB.12.0'
    # [string] $Provider = 'Microsoft.ACE.OLEDB.15.0'

    # How do I know which version of the provider to use? Can't I just say "use ACE" and let the system find the best version? 
    [string] $Provider = 'Microsoft.ACE.OLEDB.12.0'
    [string] $Provider = 'Microsoft.ACE.OLEDB.16.0'

    [string] $ExtendedProperties = 'dBASE IV;'

    if (-not $Credential) {
        # I found the ToCharArray() and AppendChar() magic here:
        # https://stackoverflow.com/questions/6239647/using-powershell-credentials-without-being-prompted-for-a-password
        # IIRC, every dBase or FoxPro file I've ever accessed were protected only by file ACLs and used credentials like such:
        $username = "Admin"
        $password = ""
        $secstr = New-Object -TypeName System.Security.SecureString
        $password.ToCharArray() | ForEach-Object { $secstr.AppendChar($_) }
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $secstr
    }

    Try {
        Get-OleDbConnection -DataSource $DataSource -Provider $Provider -ExtendedProperties $ExtendedProperties -Credential $Credential
    }
    Catch {
        Throw
    }
}
