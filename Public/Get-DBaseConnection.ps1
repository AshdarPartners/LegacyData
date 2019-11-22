function Get-DbaseConnection {
    <#
    .SYNOPSIS
    Returns an OleDB connection to a DBase database

    .DESCRIPTION
    Returns an OleDB connection to a DBase database
    www.connectionstrings.com is an excellent resource for connection strings for specfic drivers.

    .OUTPUTS
    [System.Data.OleDb.OleDbConnection]

    .PARAMETER DataSource
    This is a file path to a DBase database.

    .PARAMETER ExtendedProperties
    Some providers use a bevy of 'extended properties' in the connection string, this is a bucket into which you can throw them.
    The exact capability and syntax is provider-specific.
    The are usually key-value pairs in the format "Prop=something;AnotherProp=SomethingElse".
    No attempt is made to validate these properties or even validate the string. The first indication of trouble is usually that the Open() call will fail.

    .EXAMPLE
    $cn = Get-DbaseConnection -DataSource (get-psdrive temp).root
    $cn = Get-DbaseConnection -DataSource  (join-path -path ((get-psdrive repo).root) -child 'ems\testdata\fox\ems\000'
    Invoke-DbaseQuery -Connect $cn -query 'select * from mstrlst'
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
        [string] $DataSource
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
    [string] $Provider = 'Microsoft.ACE.OLEDB.16.0'
    [string] $UserID = "Admin"
    [string] $ExtendedProperties = "dBASE IV"
    Try {
        Get-OleDbConnection -DataSource $DataSource -Provider $Provider -UserID $UserID -ExtendedProperties $ExtendedProperties
    }

    Catch {
        Throw
    }
}
