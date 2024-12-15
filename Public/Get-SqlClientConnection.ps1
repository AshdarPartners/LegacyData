function Get-SqlClientConnection {
    <#
    .SYNOPSIS
    Returns a connection to an SqlClientSource

    .DESCRIPTION
    Returns a connection to an SqlClientSource

    .OUTPUTS
    [System.Data.SqlClient.SqlConnection]

    .PARAMETER DataSource
    This highly dependant on the provider to be used. For MDB, DBF, EXCEL, etc, it's a file path. For RDBMS like SQL Server or MySQL, it will be a server hostname. Other variations are possible.

    .PARAMETER ConnectionString
    If the caller provides a connection string, it will be used instead of the datasource

    .PARAMETER DatabaseName
    What is the name of the database of interest? If none is provided, the connection will be made to whatever the default database
    is set to for this particular user. 99.999% of the time, this will be 'master'.

    .PARAMETER ApplicationName
    What is the name that should be provided to SQL Server?

    .PARAMETER ExtendedProperties
    Some providers use a bevy of 'extended properties' in the connection string, this is a bucket into which you can throw them.
    The exact capability and syntax is provider-specific.
    The are usually key-value pairs in the format "Prop=something;AnotherProp=SomethingElse".
    No attempt is made to validate these properties or even validate the string. The first indication of trouble is usually that the Open() call will fail.

    .PARAMETER Credential
    Use alternative credentials. Accepts credential objects provided by Get-Credential.

    .EXAMPLE
    try {
        $cn = Get-SqlClientConnection -DataSource 'localhost'
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
    [OutputType([System.Data.SqlClient.SqlConnection])]
    param (
        [Parameter(
            ParameterSetName = 'WithConnectionString',
            Mandatory = $true
        )]
        [string] $ConnectionString,

        [Alias ('SqlInstance','Server', 'SqlServer')]
        [Parameter(
            ParameterSetName = 'WithDataSource',
            Mandatory = $true
        )]
        [string] $DataSource,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [string] $ExtendedProperties,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [string] $DatabaseName,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [string] $ApplicationName,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [System.Management.Automation.PSCredential] $Credential
    )

    switch ($PSCmdlet.ParameterSetName) {
        'WithConnectionString' {
            [string] $connString = $ConnectionString
        }
        'WithDataSource' {
            $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
            $builder."Data Source" = $DataSource

            if ($ExtendedProperties) {
                $builder."Extended Properties" = $ExtendedProperties
            }
            if ($Credential) {
                $builder["User ID"] = $Credential.UserName
                $builder["Password"] = $Credential.GetNetworkCredential().Password
            }
            else {
                $builder["Trusted_Connection"] = $true
            }

            if ($DatabaseName) {
                $builder["Database"] = $DatabaseName
            }

            if ($ApplicationName) {
                $builder["Application Name"] = $ApplicationName
            }

            [string] $connString = $builder.ConnectionString
        }
    }

    Try {
        $SqlClientConn = New-Object System.Data.SqlClient.SqlConnection($connString)
        $SqlClientConn.Open()
        $SqlClientConn
    }

    Catch {
        Throw
    }
}
