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

        [string] $TableCatalog,
        [string] $TableSchema,
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
        # because of the way that this call works, the four parameters here can't be declared as [string] in PowerShell.
        # It seems to have to do with the nullability of the variables. There seems to be a difference between:
        # [string], [nullable][string] and <no datatype declaration>.

        ($OleDbConn.GetOleDbSchemaTable([OleDbSchemaGuid]::Columns, ($TableCatalog, $TableSchema, $TableName, $Type))).ForEach({
                [PSCustomObject] @{
                    TableCatalog           = $_.TABLE_CATALOG
                    TableSchema            = $_.TABLE_SCHEMA
                    TableName              = $_.TABLE_NAME

                    ColumnName             = $_.COLUMN_NAME
                    OrdinalPosition        = $_.ORDINAL_POSITION
                    ColumnHasDefault       = $_.COLUMN_HASDEFAULT
                    ColumnDefault          = $_.COLUMN_DEFAULT
                    # .TODO
                    # is this a bitwise column?
                    # Can you translate this, either at this, the ADO layer, or at the caller layer?
                    ColumnFlags            = $_.COLUMN_FLAGS
                    IsNullable             = $_.IS_NULLABLE
                    DataType               = $_.DATA_TYPE
                    # I am adding this as a user convenience; looking at the Raw data_type IDs is not helpful
                    DataTypeDescription    = [OleDbType]($_.DATA_TYPE)
                    NumericPrecision       = $_.NUMERIC_PRECISION
                    NumericScale           = $_.NUMERIC_SCALE
                    CharacterMaximumLength = $_.CHARACTER_MAXIMUM_LENGTH
                    CharacterOctetLength   = $_.CHARACTER_OCTET_LENGTH
                    CharacterSetCatalog    = $_.CHARACTER_SET_CATALOG
                    CharacterSetSchema     = $_.CHARACTER_SET_SCHEMA
                    CharacterSetName       = $_.CHARACTER_SET_NAME
                    CollationCatalog       = $_.COLLATION_CATALOG
                    CollationSchema        = $_.COLLATION_SCHEMA
                    CollationName          = $_.COLLATION_NAME
                    DomainCatalog          = $_.DOMAIN_CATALOG
                    DomainSchema           = $_.DOMAIN_SCHEMA
                    DomainName             = $_.DOMAIN_NAME
                    IsComputed             = $_.IS_COMPUTED
                    Datasource             = $Datasource
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
            if ($OleDbConn) {
                $OleDbConn.Close()
                $OleDbConn.Dispose()
            }
        }
    }

}
