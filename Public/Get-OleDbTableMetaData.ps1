#Require -Version 5.0

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

    .PARAMETER Credential
    Use alternative credentials. Accepts credential objects provided by Get-Credential.

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
        [System.Management.Automation.PSCredential] $Credential,

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
                $OleDbConn = Get-OleDbConnection -DataSource $DataSource -Provider $Provider -ExtendedProperties $ExtendedProperties -Credential $Credential
            }
        }

        # Doc for parameters for GetOleDbSchemaTable call:
        # https://social.msdn.microsoft.com/Forums/en-US/75fb3085-bc3d-427c-9257-30631235c3af/getoledbschematableoledboledbschemaguidindexes-how-to-access-included-columns-on-index?forum=vblanguage
        # because of the way that this call works, the four parameters here can't be declared as [string] in PowerShell.
        # It seems to have to do with the nullability of the variables. There seems to be a difference between:
        # [string], [nullable][string] and <no datatype declaration>.

        ($OleDbConn.GetOleDbSchemaTable([OleDbSchemaGuid]::Tables, ($TableCatalog, $TableSchema, $TableName, $Type))).ForEach({
                [PSCustomObject] @{
                    TableCatalog  = $_.TABLE_CATALOG
                    TableSchema   = $_.TABLE_SCHEMA
                    TableName     = $_.TABLE_NAME
                    Type          = $_.TABLE_TYPE
                    TableGUID     = $_.TABLE_GUID
                    Description   = $_.DESCRIPTION
                    TablePropGUID = $_.TABLE_PROPID
                    DateCreated   = $_.DATE_CREATED
                    DateModified  = $_.DATE_CMODIFIED
                    Datasource    = $Datasource
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
