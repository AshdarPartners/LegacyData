#Require -Version 5.0

function Get-SqlClientIndexMetadata {
    <#
    .SYNOPSIS
    Retrieve index metadata from any SqlClient source, given a driver and a location

    .DESCRIPTION
    Retrieve index metadata from any SqlClient source, given a driver and a location

    .PARAMETER DataSource
    Which location is of interest? This is uusally some sort of server hostname or a file path.

    .PARAMETER DatabaseName
    Which database is of interest? The default will be 'master', or whatever the user has configured as their default database

    .PARAMETER Credential
    Use alternative credentials. Accepts credential objects provided by Get-Credential.

    .PARAMETER Connection
    If the caller provides a "live", open connection, it will be used. The connection will not be closed.

    .PARAMETER ConnectionString
    If the caller provides a connection string, use that.

    .PARAMETER ExtendedProperties
    What extended property values should be used by the SqlClient provider?

    .PARAMETER TableCatalog
    What is the name of the table(s) of interest? Null means 'the default catalog'.
    For databases like SQL Server 'TableCatalog' means 'database name'.

    .PARAMETER TableSchema
    What is the schema name of the table(s) of interest? Null means 'all schemas'.

    .PARAMETER IndexName
    What is the name of the index(es) of interest? Null means 'all indexes'.

    .PARAMETER Type
    What is the type of indexes of interest? Null means 'all types'.

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .EXAMPLE
    Get-SqlClientIndexMetadata -DataSource '.\SQL2016' -ExtendedProperties "Trusted_Connection=Yes"

    .EXAMPLE
    Get-SqlClientIndexMetadata -DataSource '.\SQL2016' -ExtendedProperties "Trusted_Connection=Yes" -TableCatalog 'AdventureWorks2016' -TableSchema 'Sales' -TableType 'TABLE'

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
        $IndexName = '.*',
        $Type = '.*',
        $TableName = '.*'
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

        # .GetSchema() shows a list of possible objects, one of which is "Indexes", which seems to have stuff for master.
        $Output = $SqlClientConn.GetSchema("Indexes")
        $Output.ForEach({
                [PSCustomObject] @{
                    TableCatalog = $_.TABLE_CATALOG
                    TableSchema  = $_.TABLE_SCHEMA
                    TableName    = $_.TABLE_NAME
                    IndexName    = $_.INDEX_NAME
                    Description  = $_.TYPE_DESC
                    # It appears that none of these useful attributes are available to us through this interface.
                    #     IndexCatalog    = $_.INDEX_CATALOG
                    #     IndexSchema     = $_.INDEX_SCHEMA
                    #     PrimaryKey      = $_.PRIMARY_KEY
                    #     Unique          = $_.UNIQUE
                    #     Clustered       = $_.CLUSTERED
                    #     Type            = $_.TYPE
                    #     FillFactor      = $_.FILL_FACTOR
                    #     InitialSize     = $_.INITIAL_SIZE
                    #     Nulls           = $_.NULLS
                    #     SortBookmarks   = $_.SORT_BOOKMARKS
                    #     AutoUpdate      = $_.AUTO_UPDATE
                    #     NullCollation   = $_.NULL_COLLATION
                    #     OrdinalPosition = $_.ORDINAL_POSITION
                    #     ColumnName      = $_.COLUMN_NAME
                    #     ColumnGuid      = $_.COLUMN_GUID
                    #     ColumnPropID    = $_.COLUMN_PROPID
                    #     Collation       = $_.COLLATION
                    #     Cardinality     = $_.CARDINALITY
                    #     Pages           = $_.PAGES
                    #     FilterCondition = $_.FILTER_CONDITION
                    #     Integrated      = $_.INTEGRATED
                    #     # 'Expression' is in the ADO version of this tool, but not in the SqlClient version.
                    #     # Expression = $_.EXPRESSION
                    Datasource   = $Datasource
                }
            }
        )

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
