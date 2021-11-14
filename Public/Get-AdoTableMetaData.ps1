function Get-AdoTableMetaData {
    <#
    .SYNOPSIS
    Retrieves a list of tables in an ADO datasource

    .DESCRIPTION
    Retrieves a list of tables in an ADO datasource

    .PARAMETER Provider
    What describes the provider? Often this, is the guts that describe a "dsn-less" connection. It is used to choose the drivers that will be used to do to work of retrieving the data.

    .PARAMETER Datasource
    This describes the source of the data.

    .PARAMETER ExtendedProperties
    This allows the caller to provide extended property information, when required.

    .PARAMETER TableName
    What is the table of interest? This parameter uses -match semantics.

    .LINK
    http://www.carlprothman.net/Technology/ConnectionStrings/ODBCDSNLess/tabid/90/Default.aspx

    .EXAMPLE
    Get-AdoTableMetaData -Datasource:"c:\temp\presidents.mdb" -provider:"Microsoft.Ace.OLEDB.12.0"

    #>
    param (
        [Parameter(Mandatory = $true)]
        [string] $Provider,
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        [string] $ExtendedProperties,
        [string] $TableName = '.*'
    )

    begin {
        $adSchemaTables = 20
    }

    process {
        (Get-AdoSchemaMetaData -SchemaType $adSchemaTables -Provider $Provider -Datasource $Datasource -ExtendedProperties $ExtendedProperties |
            Where-Object { $_.TABLE_NAME -match $TableName }).ForEach(
            {
                [PSCustomObject] @{
                    TableCatalog  = $_.TABLE_CATALOG
                    TableSchema   = $_.TABLE_SCHEMA
                    TableName     = $_.TABLE_NAME
                    TableType     = $_.TABLE_TYPE
                    TableGUID     = $_.TABLE_GUID
                    Description   = $_.DESCRIPTION
                    TablePropGUID = $_.TABLE_PROPID
                    DateCreated   = $_.DATE_CREATED
                    DateModified  = $_.DATE_CMODIFIED
                    Datasource    = $_.Datasource
                }
            }
        )
    }
}


