#Require -Version 5.0
using namespace System.Data.OleDb

function Get-OleDbColumnMetadata {
    <#
    .SYNOPSIS
    Shows column metadata for OleDb databases

    .DESCRIPTION
    Shows column metadata for OleDb databases

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

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .EXAMPLE
    Get-OleDbColumnMetadata -DataSource '.\SQL2016' -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes"

    .EXAMPLE
    Get-OleDbColumnMetadata -DataSource '.\SQL2016' -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -TableCatalog 'AdventureWorks2016' -TableSchema 'Sales' -TableType 'TABLE'

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

        $TableCatalog,
        $TableSchema,
        $TableName
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
        $OleDbConn.GetOleDbSchemaTable([OleDbSchemaGuid]::Columns, ($TableCatalog, $TableSchema, $TableName, $TableType)) |
            Select-Object  @{n = "TableCatalog"; e = { $_.TABLE_CATALOG } },
            @{n = "TableSchema"; e = { $_.TABLE_SCHEMA } },
            @{n = "TableName"; e = { $_.TABLE_NAME } },
            @{n = "ColumnName"; e = { $_.COLUMN_NAME } },
            @{n = "OrdinalPosition"; e = { $_.ORDINAL_POSITION } },
            @{n = "ColumnHasDefault"; e = { $_.COLUMN_HASDEFAULT } },
            @{n = "ColumnDefault"; e = { $_.COLUMN_DEFAULT } },
            # .TODO
            # is this a bitwise column?
            # Can you translate this, either at this, the ADO layer, or at the caller layer?
            @{n = "ColumnFlags"; e = { $_.COLUMN_FLAGS } },
            @{n = "IsNullable"; e = { $_.IS_NULLABLE } },
            @{n = "DataType"; e = { $_.DATA_TYPE } },
            # I am adding this as a user convenience; looking at the Raw data_type IDs is not helpful
            @{n = "DataTypeDescription"; e = { [OleDbType]($_.DATA_TYPE) } },

            @{n = "NumericPrecision"; e = { $_.NUMERIC_PRECISION } },
            @{n = "NumericScale"; e = { $_.NUMERIC_SCALE } },
            @{n = "CharacterMaximumLength"; e = { $_.CHARACTER_MAXIMUM_LENGTH } },
            @{n = "CharacterOctetLength"; e = { $_.CHARACTER_OCTET_LENGTH } },

            @{n = "CharacterSetCatalog"; e = { $_.CHARACTER_SET_CATALOG } },
            @{n = "CharacterSetSchema"; e = { $_.CHARACTER_SET_SCHEMA } },
            @{n = "CharacterSetName"; e = { $_.CHARACTER_SET_NAME } },

            @{n = "CollationCatalog"; e = { $_.COLLATION_CATALOG } },
            @{n = "CollationSchema"; e = { $_.COLLATION_SCHEMA } },
            @{n = "CollationName"; e = { $_.COLLATION_NAME } },

            @{n = "DomainCatalog"; e = { $_.DOMAIN_CATALOG } },
            @{n = "DomainSchema"; e = { $_.DOMAIN_SCHEMA } },
            @{n = "DomainName"; e = { $_.DOMAIN_NAME } },

            @{n = "IsComputed"; e = { $_.IS_COMPUTED } },
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
