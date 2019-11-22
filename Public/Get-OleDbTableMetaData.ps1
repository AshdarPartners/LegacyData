#Require -Version 5.0
using namespace System.Data.OleDb

function Get-OleDbTableMetadata {
    <#
    .SYNOPSIS
    Show metadata for OleDb tables

    .DESCRIPTION
    Show metadata for OleDb tables

    .PARAMETER DataSource
    Which OleDB location is of interest?

    .PARAMETER Connection
    If the caller provides a "live", open connection, it will be used. The connection will not be closed.

    .PARAMETER ConnectionString
    If the caller provides a connection string, use that.

    .PARAMETER Provider
    Which OleDB provider should be used?

    .PARAMETER UserID
    For databases that take a user, you can provide that here.

    .PARAMETER Password
    This is a secure string.

    .PARAMETER ExtendedProperties
    What extended property values should be used by the OleDB provider?

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
    Get-OleDbTableMetadata -DataSource '.\SQL2016' -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -TableCatalog 'AdventureWorks2016'

    .EXAMPLE
    Get-OleDbTableMetadata -DataSource '.\SQL2016' -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -TableCatalog 'AdventureWorks2016' -TableSchema 'Sales' -TableType 'TABLE'

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
        [string] $UserID,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [Securestring] $Password,

        $TableCatalog,
        $TableSchema,
        $TableName,
        $Type
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
                $OleDbConn = Get-OleDbConnection -DataSource $DataSource -Provider $Provider -ExtendedProperties $ExtendedProperties -UserID $UserId -Password $Password
            }
        }

        # Doc for parameters for GetOleDbSchemaTable call:
        # https://social.msdn.microsoft.com/Forums/en-US/75fb3085-bc3d-427c-9257-30631235c3af/getoledbschematableoledboledbschemaguidindexes-how-to-access-included-columns-on-index?forum=vblanguage
        $OleDbConn.GetOleDbSchemaTable([OleDbSchemaGuid]::Tables, ($TableCatalog, $TableSchema, $TableName, $Type)) |
            Select-Object @{n = "TableCatalog"; e = { $_.TABLE_CATALOG } },
            @{n = "TableSchema"; e = { $_.TABLE_SCHEMA } },
            @{n = "TableName"; e = { $_.TABLE_NAME } },
            @{n = "Type"; e = { $_.TABLE_TYPE } },
            @{n = "TableGUID"; e = { $_.TABLE_GUID } },
            @{n = "Description"; e = { $_.DESCRIPTION } },
            @{n = "TablePropGUID"; e = { $_.TABLE_PROPID } },
            @{n = "DateCreated"; e = { $_.DATE_CREATED } },
            @{n = "DateModified"; e = { $_.DATE_CMODIFIED } },
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
