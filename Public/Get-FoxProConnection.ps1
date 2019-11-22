function Get-FoxProConnection {
    <#
    .SYNOPSIS
    Returns an OleDB connection to a FoxPro database

    .DESCRIPTION
    Returns an OleDB connection to a FoxPro database
    www.connectionstrings.com is an excellent resource for connection strings for specfic drivers.

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
