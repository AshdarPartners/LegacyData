#Require -Version 5.0
using namespace System.Data.SqlClient

function Get-SqlClientColumnMetadata {
    <#
    .SYNOPSIS
    Shows column metadata for SqlClient databases

    .DESCRIPTION
    Shows column metadata for SqlClient databases

    .PARAMETER DataSource
    Which source is of interest? This is usually a SQL Server hostname or "localdb" specification

    .PARAMETER DatabaseName
    Which database is of interest? The default will be 'master', or whatever the user has configured as their default database

    .PARAMETER Credential
    Use alternative credentials. Accepts credential objects provided by Get-Credential.

    .PARAMETER Connection
    If the caller provides a "live", open connection, it will be used. The connection will not be closed.

    .PARAMETER ConnectionString
    If the caller provides a connection string, use that.

    .PARAMETER ExtendedProperties
    What extended property values should be used by the SqlClient?

    .PARAMETER TableCatalog
    What is the name of the table(s) of interest? Null means 'the default catalog'.
    For databases like SQL Server 'TableCatalog' means 'database name'.

    .PARAMETER TableSchema
    What is the schema name of the table(s) of interest? Null means 'all schemas'.

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .EXAMPLE
    Get-SqlClientColumnMetadata -DataSource '.\SQL2022'

    .EXAMPLE
    Get-SqlClientColumnMetadata -DataSource '.\SQL2022'-TableCatalog 'AdventureWorks2016' -TableSchema 'Sales'

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

        [Alias ('SqlInstance', 'Server', 'SqlServer')]
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

        [string] $TableCatalog = '.*',
        [string] $TableSchema = '.*',
        [string] $TableName = '.*',
        [string] $ColumnName = '.*'
    )

    Try {
        switch ($PSCmdlet.ParameterSetName) {
            'WithConnection' {
                $SqlClientConn = $Connection
                $DataSource = $Connection.DataSource
            }
            'WithConnectionString' {
                $SqlClientConn = Get-SqlClientConnection -ConnectionString $ConnectionString
            }
            'WithDataSource' {
                $SqlClientConn = Get-SqlClientConnection -DataSource $DataSource -ExtendedProperties $ExtendedProperties -Credential $Credential -DatabaseName $DatabaseName
            }
        }

        # Doc for parameters for GetSqlClientSchemaTable call, which is pre-.NET and ADO/OLEDB-based:
        # https://social.msdn.microsoft.com/Forums/en-US/75fb3085-bc3d-427c-9257-30631235c3af/getSqlClientschematableSqlClientSqlClientschemaguidindexes-how-to-access-included-columns-on-index?forum=vblanguage
        # because of the way that this call works, the four parameters here can't be declared as [string] in PowerShell.
        # It seems to have to do with the nullability of the variables. There seems to be a difference between:
        # [string], [nullable][string] and <no datatype declaration>.

        # More information on GetSchema(), which is the .NET version of GetSqlClientSchemaTable()
        # https://learn.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlconnection.getschema?view=net-8.0-pp
        # From that page:
        # For the array,
        #   0-member represents Catalog; // which will always be the current database, restricting it doesn't make much sense here
        #   1-member represents Schema;
        #   2-member represents Table Name;
        #   3-member represents Column Name.
        # Now we specify the Table_Name and Column_Name of the columns what we want to get schema information.

        # Try as I might, I can't get the 'restrictions' working on this GetSchema() call to limit the output to only what
        # the caller asked for. This works (in a similar way) for the other OleDb stuff, but it doesn't seem to work exactly the
        # same way here.
        #
        # IOW, none of this commented-out code works as I expect it to.
        #
        # $Output = $SqlClientConn.GetSchema("Columns", ($TableCatalog, $TableSchema, $TableName, $Type))
        # $Restrictions = ($TableCatalog, $TableSchema, $TableName, $ColumnName)
        # $Restrictions = @($null, $null, $null, $null)
        # $Output = $SqlClientConn.GetSchema("Columns", $Restrictions)
        # $Output = $SqlClientConn.GetSchema("Columns", ([string] $null, [string] $null, [string] $null, [string] $null))
        # $Output = $SqlClientConn.GetSchema("Columns", @($null))
        #
        # Instead of banging my head against this wall any more, I'll get everything and restrict the results on the way back out
        # to the caller with a conventional, PowerShell-ish "Where-Object {}"
        # Using RegEx to restrict this is more flexible for the caller, anyway.
        $Output = $SqlClientConn.GetSchema("Columns")
        $Output.ForEach({
                [PSCustomObject] @{

                    TableCatalog           = $_.TABLE_CATALOG
                    TableSchema            = $_.TABLE_SCHEMA
                    TableName              = $_.TABLE_NAME

                    ColumnName             = $_.COLUMN_NAME
                    OrdinalPosition        = $_.ORDINAL_POSITION

                    ColumnHasDefault       = if ($_.COLUMN_DEFAULT -match '\w') {$true} else {$false}
                    ColumnDefault          = $_.COLUMN_DEFAULT

                    IsNullable             = $_.IS_NULLABLE
                    DataType               = $_.DATA_TYPE

                    CharacterMaximumLength = $_.CHARACTER_MAXIMUM_LENGTH
                    CharacterOctetLength   = $_.CHARACTER_OCTET_LENGTH

                    NumericPrecision       = $_.NUMERIC_PRECISION
                    NumericPrecisionRadix  = $_.NUMERIC_PRECISION_RADIX
                    NumericScale           = $_.NUMERIC_SCALE
                    DatetimePrecision      = $_.DATETIME_PRECISION

                    CharacterSetCatalog    = $_.CHARACTER_SET_CATALOG
                    CharacterSetSchema     = $_.CHARACTER_SET_SCHEMA
                    CharacterSetName       = $_.CHARACTER_SET_NAME
                    CollationCatalog       = $_.COLLATION_CATALOG
                    IsSparse               = $_.IS_SPARSE
                    IsColumnSet            = $_.IS_COLUMN_SET
                    IsFilestream           = $_.IS_FILESTREAM

                    Datasource             = $Datasource

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
