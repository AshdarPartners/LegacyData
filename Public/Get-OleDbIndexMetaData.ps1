#Require -Version 5.0
using namespace System.Data.OleDb

function Get-OleDbIndexMetadata {
    <#
    .SYNOPSIS
    Retrieve index metadata from any OleDb source, given a driver and a location

    .DESCRIPTION
    Retrieve index metadata from any OleDb source, given a driver and a location

    .PARAMETER DataSource
    Which location is of interest? This is uusally some sort of server hostname or a file path.

    .PARAMETER Credential
    Use alternative credentials. Accepts credential objects provided by Get-Credential.

    .PARAMETER Connection
    If the caller provides a "live", open connection, it will be used. The connection will not be closed.

    .PARAMETER ConnectionString
    If the caller provides a connection string, use that.

    .PARAMETER Provider
    Which OleDB provider should be used?

    .PARAMETER ExtendedProperties
    What extended property values should be used by the OleDB provider?

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
    Get-OleDbIndexMetadata -DataSource '.\SQL2016' -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes"

    .EXAMPLE
    Get-OleDbIndexMetadata -DataSource '.\SQL2016' -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -TableCatalog 'AdventureWorks2016' -TableSchema 'Sales' -TableType 'TABLE'

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.data.oledb.oledbconnection.getoledbschematable?view=netframework-4.7.2
    #>
    param (
        [Parameter(
            ParameterSetName = 'WithConnection',
            Mandatory = $true
        )]
        [System.Data.OleDb.OleDbConnection] $Connection,

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
        [System.Management.Automation.PSCredential] $Credential,

        [string] $TableCatalog,
        [string] $TableSchema,
        [string] $IndexName,
        [string] $Type,
        [string] $TableName
    )

    Try {
        switch ($PSCmdlet.ParameterSetName) {
            'WithConnection' {
                $OleDbConn = $Connection
            }
            'WithConnectionString' {
                $OleDbConn = Get-OleDbConnection -ConnectionString $ConnectionString
            }
            'WithDataSource' {
                $OleDbConn = Get-OleDbConnection -DataSource $DataSource -Provider $Provider -ExtendedProperties $ExtendedProperties -Credential $Credential
            }
        }

        # Doc for parameters for GetOleDbSchemaTable call:
        # https://social.msdn.microsoft.com/Forums/en-US/75fb3085-bc3d-427c-9257-30631235c3af/getoledbschematableoledboledbschemaguidindexes-how-to-access-included-columns-on-index?forum=vblanguage
        $OleDbConn.GetOleDbSchemaTable([OleDbSchemaGuid]::Indexes, ($TableCatalog, $TableSchema, $IndexName, $Type, $TableName)) |
            Select-Object @{n = "TableCatalog"; e = { $_.TABLE_CATALOG } },
            @{n = "TableSchema"; e = { $_.TABLE_SCHEMA } },
            @{n = "TableName"; e = { $_.TABLE_NAME } },
            @{n = "IndexCatalog"; e = { $_.INDEX_CATALOG } },
            @{n = "IndexSchema"; e = { $_.INDEX_SCHEMA } },
            @{n = "IndexName"; e = { $_.INDEX_NAME } },

            @{n = "PrimaryKey"; e = { $_.PRIMARY_KEY } },
            @{n = "Unique"; e = { $_.UNIQUE } },
            @{n = "Clustered"; e = { $_.CLUSTERED } },
            @{n = "Type"; e = { $_.TYPE } },

            @{n = "FillFactor"; e = { $_.FILL_FACTOR } },
            @{n = "InitialSize"; e = { $_.INITIAL_SIZE } },

            @{n = "Nulls"; e = { $_.NULLS } },
            @{n = "SortBookmarks"; e = { $_.SORT_BOOKMARKS } },
            @{n = "AutoUpdate"; e = { $_.AUTO_UPDATE } },
            @{n = "NullCollation"; e = { $_.NULL_COLLATION } },
            @{n = "OrdinalPosition"; e = { $_.ORDINAL_POSITION } },

            @{n = "ColumnName"; e = { $_.COLUMN_NAME } },
            @{n = "ColumnGuid"; e = { $_.COLUMN_GUID } },
            @{n = "ColumnPropID"; e = { $_.COLUMN_PROPID } },
            @{n = "Collation"; e = { $_.COLLATION } },
            @{n = "Cardinality"; e = { $_.CARDINALITY } },
            @{n = "Pages"; e = { $_.PAGES } },
            @{n = "FilterCondition"; e = { $_.FILTER_CONDITION } },
            @{n = "Integrated"; e = { $_.INTEGRATED } },
            # 'Expression' is in the ADO version of this tool, but not in the OleDb version.
            # @{n = "Expression"; e = {$_.EXPRESSION}}
            @{n = "Datasource"; e = { $Datasource } }

    }

    Catch {
        Throw
    }

    Finally {
        # if we were passed a connection, do not close it. Closing it is the responsibility of the caller.
        if ($PSCmdlet.ParameterSetName -ne 'WithConnection') {
            $OleDbConn.Close()
            $OleDbConn.Dispose()
        }
    }
}
