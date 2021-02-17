function Get-FoxProConnection {
    <#
    .SYNOPSIS
    Returns an OleDB connection to a FoxPro database

    .DESCRIPTION
    Returns an OleDB connection to a FoxPro database
    www.connectionstrings.com is an excellent resource for connection strings for specfic drivers.

    .NOTES
    This cmdlet uses "vfpoledb", the "Visual FoxPro OLE DB" driver. This was the 'official' way to get to FoxPro data and, AFAIK,
    it was used by the Visual FoxPro IDE and runtime enviroment to run all commands. IOW, the driver holds the "engine" similar to
    the way that a SQL Server or Oracle instances holds the "engine" for those RDBMS. This means that the driver should understand 
    all of the goodies that Visual Fox Pro 9 supported (were not supported by the earlier "DOS versions" of Fox Pro (up to 2.6a)):
    1. "dbc" files, IOW-"real" FoxPro databases and not just "loose tables"
    2. Transactions
    3. The "Rushmore" index technology
    4. foreign keys
    5. And so forth

    Vfpoledb has two major issues:
    
    1.  This driver is not built for 64 bit systems. The 32 bit version of the driver works with 32 bit applications running on 
        64 bit windows. For example, it can be used by 32 bit PowerShell running on a 64 bit Windows 10 OS.
    
    2.  Microsoft stopped supporting this driver in 2015. The last release was Visual FoxPro 9 Service Pack 2. 

    OTOH:

    1.  The Vfpoledb driver is freely downloadable and seems to be free to use.

    2.  Any FoxPro code that was sluggish in the 1990s absolutely flies on hardware built after 2010.

    Also AFAIK, the "modern" (IOW "still maintained") ACE drivers provide most functionality that an app wants for simple 
    read/write of FoxPro data. You just need to use using the "dBASE IV" flavor of the driver. I don't know if they support all 
    of the advanced features that were only in Visual FoxPro (like .dbc files and Rushmore)
    
    Is it possible that using ACE instead of VFPOLEB nmeans that some features are not available? Yes. I don't have a way of 
    validating every possible VFP 9.0 command against the ACE driver. OTOH, if Microsoft already had workable FoxPro drivers 
    from VFP 9.0, I expect that they would have tried their best to simply reuse that code when they built ACE.

    If you want to use ACE, simply use the *-dBAse* cmdlets in this module and make sure you *test*. It's pretty easy to switch 
    the cmdlets back and forth.


    .OUTPUTS
    [System.Data.OleDb.OleDbConnection]

    .PARAMETER DataSource
    This is a file path to a FoxPro database.

    .PARAMETER ExtendedProperties
    Some providers use a bevy of 'extended properties' in the connection string, this is a bucket into which you can throw them.
    The exact capability and syntax is provider-specific.
    The are usually key-value pairs in the format "Prop=something;AnotherProp=SomethingElse".
    No attempt is made to validate these properties or even validate the string. The first indication of trouble is usually that the Open() call will fail.

    .EXAMPLE
    try {
        $cn = Get-FoxProConnection -DataSource 'c:\foxprofiles'
        # do stuff
    }
    catch {
        # re-throw
        Throw
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
        [string] $ExtendedProperties
    )

    if ([Environment]::Is64BitProcess -eq $true) {
        throw "This cmdlet only works in 32-bit PowerShell (x86) sessions because 64-bit Visual FoxPro OLEDB drivers are not available."
    }

    [string] $Provider = 'vfpoledb'

    Try {
        Get-OleDbConnection -DataSource $DataSource -Provider $Provider -ExtendedProperties $ExtendedProperties
    }

    Catch {
        Throw
    }
}
