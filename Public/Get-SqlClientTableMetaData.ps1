#Require -Version 5.0

function Get-SqlClientTableMetadata {
    <#
    .SYNOPSIS
    Show metadata for SqlClient tables

    .DESCRIPTION
    Show metadata for SqlClient tables

    .PARAMETER DataSource
    Which SqlClient location is of interest?

    .PARAMETER DatabaseName
    Which database is of interest? The default will be 'master', or whatever the user has configured as their default database

    .PARAMETER Connection
    If the caller provides a "live", open connection, it will be used. The connection will not be closed.

    .PARAMETER ConnectionString
    If the caller provides a connection string, use that.

    .PARAMETER Credential
    Use alternative credentials. Accepts credential objects provided by Get-Credential.

    .PARAMETER ExtendedProperties
    What extended property values should be used by the SqlClient provider?

    .PARAMETER TableCatalog
    What is the name of the table(s) of interest? Null means 'the default catalog'.
    For databases like SQL Server 'TableCatalog' means 'database name'.

    .PARAMETER TableSchema
    What is the schema name of the table(s) of interest? Null means 'all schemas'.

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .PARAMETER Type
    What is the type of the table(s) of interest? Null means 'all types'.

    .EXAMPLE
    Get-SqlClientTableMetadata -DataSource '.\SQL2016' -ExtendedProperties "Trusted_Connection=Yes" -TableCatalog 'AdventureWorks2016'

    .EXAMPLE
    Get-SqlClientTableMetadata -DataSource '.\SQL2016' -ExtendedProperties "Trusted_Connection=Yes" -TableCatalog 'AdventureWorks2016' -TableSchema 'Sales' -TableType 'TABLE'

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.data.SqlClient.SqlClientconnection.getSqlClientschematable?view=netframework-4.7.2
    #>
    param (
        [Parameter(
            ParameterSetName = 'WithConnection',
            Mandatory = $true
        )]
        [System.Data.SqlClient.SqlConnection] $Connection,

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
            ParameterSetName = 'WithDataSource'
        )]
        [string] $DatabaseName,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [string] $ExtendedProperties,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [System.Management.Automation.PSCredential] $Credential,

        $TableCatalog = '.*',
        $TableSchema = '.*',
        $TableName = '.*',
        $Type = '.*'
    )


    Try {
        switch ($PSCmdlet.ParameterSetName) {
            'WithConnection' {
                $SqlClientConn = $Connection
            }
            'WithConnectionString' {
                $SqlClientConn = Get-SqlClientConnection -ConnectionString $ConnectionString
            }
            'WithDataSource' {
                $SqlClientConn = Get-SqlClientConnection -DataSource $DataSource -ExtendedProperties $ExtendedProperties -Credential $Credential -DatabaseName $DatabaseName
            }
        }

        # Doc for parameters for GetSqlClientSchemaTable call:
        # https://social.msdn.microsoft.com/Forums/en-US/75fb3085-bc3d-427c-9257-30631235c3af/getSqlClientschematableSqlClientSqlClientschemaguidindexes-how-to-access-included-columns-on-index?forum=vblanguage
        # because of the way that this call works, the four parameters here can't be declared as [string] in PowerShell.
        # It seems to have to do with the nullability of the variables. There seems to be a difference between:
        # [string], [nullable][string] and <no datatype declaration>.
        $Output = $SqlClientConn.GetSchema("Tables")
        $Output.ForEach({
                [PSCustomObject] @{
                    TableCatalog  = $_.TABLE_CATALOG
                    TableSchema   = $_.TABLE_SCHEMA
                    TableName     = $_.TABLE_NAME
                    Type          = $_.TABLE_TYPE
                    Datasource    = $Datasource
                }
            }
        ) | Where-Object {
            $_.TableCatalog -match $TableCatalog -and
            $_.TableSchema -match $TableSchema -and
            $_.TableName -match $TableName -and
            $_.ColumnName -match $ColumnName
        }

    }

    Catch {
        Throw
    }

    Finally {
        # if we were passed a connection, do not close it. Closing it is the responsibility of the caller.
        if ($PSCmdlet.ParameterSetName -ne 'WithConnection') {
            # Do not free connections that don't exist
            if ($SqlClientConn) {
                $SqlClientConn.Close()
                $SqlClientConn.Dispose()
            }
        }
    }

}
