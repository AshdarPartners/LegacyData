function Get-OleDbConnection {
    <#
    .SYNOPSIS
    Returns a connection to an OleDbSource

    .DESCRIPTION
    Returns a connection to an OleDbSource

    .OUTPUTS
    [System.Data.OleDb.OleDbConnection]

    .PARAMETER DataSource
    This highly dependant on the provider to be used. For MDB, DBF, EXCEL, etc, it's a file path. For RDBMS like SQL Server or MySQL, it will be a server hostname. Other variations are possible.

    .PARAMETER ConnectionString
    If the caller provides a connection string, it will be used instead of the datasource

    .PARAMETER Provider
    Which OleDb provider should be used?

    .PARAMETER ExtendedProperties
    Some providers use a bevy of 'extended properties' in the connection string, this is a bucket into which you can throw them.
    The exact capability and syntax is provider-specific.
    The are usually key-value pairs in the format "Prop=something;AnotherProp=SomethingElse".
    No attempt is made to validate these properties or even validate the string. The first indication of trouble is usually that the Open() call will fail.

    .PARAMETER UserID
    For databases that take a user, you can provide that here.

    .PARAMETER Password
    This is a secure string.

    .EXAMPLE
    try {
        $cn = Get-OleDbConnection -DataSource 'c:\fpdata' -Provider 'vfpoledb'
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
        [Parameter(
            ParameterSetName = 'WithConnectionString',
            Mandatory = $true
        )]
        [string] $ConnectionString,

        [Parameter(
            ParameterSetName = 'WithDataSource',
            Mandatory = $true
        )]
        [string] $DataSource,

        [Parameter(
            ParameterSetName = 'WithDataSource',
            Mandatory = $true
        )]
        [string] $Provider,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [string] $ExtendedProperties,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [string] $UserID,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [Securestring] $Password
    )

    switch ($PSCmdlet.ParameterSetName) {
        'WithConnectionString' {
            [string] $connString = $ConnectionString
        }
        'WithDataSource' {
            $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
            $builder."Data Source" = $DataSource
            $builder."Provider" = $Provider
            if ($ExtendedProperties) {
                $builder."Extended Properties" = $ExtendedProperties
            }
            if ($UserID) {
                $builder."User ID" = $UserID
            }
            if ($Password) {
                $builder.Password = $Password
            }
            [string] $connString = $builder.ConnectionString
        }
    }

    Try {
        $OleDbConn = New-Object System.Data.OleDb.OleDbConnection($connString)
        $OleDbConn.Open()
        $OleDbConn
    }

    Catch {
        Throw
    }
}
