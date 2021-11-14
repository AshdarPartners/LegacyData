function Get-AdoIndexMetaData {
    <#
	.SYNOPSIS
	Shows metadata indexes in an ADO datasource

    .DESCRIPTION
	Shows metadata indexes in an ADO datasource

    .PARAMETER Provider
    What describes the provider? Often this, is the guts that describe a "dsn-less" connection. It is used to choose the drivers that will be used to do to work of retrieving the data.

    .PARAMETER Datasource
    This describes the source of the data.

    .PARAMETER ExtendedProperties
    This allows the caller to provide extended property information, when required.

    .PARAMETER TableName
    What is the table of interest? This parameter uses -match semantics.

    .EXAMPLE
    Get-AdoIndexMetaData -Datasource:"$c:\dev\presidents.mdb" -columnname:"e" -provider:"Microsoft.Ace.OLEDB.12.0"

    .LINK
    http://www.carlprothman.net/Technology/ConnectionStrings/ODBCDSNLess/tabid/90/Default.aspx

    .LINK
	http://webcoder.info/reference/MSSQLDataTypes.html
	#>

    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $true)]
        [string] $Provider,
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        [string] $ExtendedProperties,
        [string] $TableName = '.*'
    )

    begin {
        $adSchemaIndexes = 12
    }

    process {

        (Get-AdoSchemaMetaData -SchemaType $adSchemaIndexes -Provider $Provider -Datasource $Datasource -ExtendedProperties $ExtendedProperties |
            Where-Object { ($_.TABLE_NAME -match $TableName) }).ForEach(
            {
                [PSCustomObject] @{

                    TableCatalog    = $_.TABLE_CATALOG
                    TableSchema     = $_.TABLE_SCHEMA
                    TableName       = $_.TABLE_NAME
                    IndexCatalog    = $_.INDEX_CATALOG
                    IndexSchema     = $_.INDEX_SCHEMA
                    IndexName       = $_.INDEX_NAME
                    PrimaryKey      = $_.PRIMARY_KEY
                    Unique          = $_.UNIQUE
                    Clustered       = $_.CLUSTERED
                    type            = $_.TYPE
                    FillFactor      = $_.FILL_FACTOR
                    InitialSize     = $_.INITIAL_SIZE
                    Nulls           = $_.NULLS
                    SortBookmarks   = $_.SORT_BOOKMARKS
                    AutoUpdate      = $_.AUTO_UPDATE
                    NullCollation   = $_.NULL_COLLATION
                    OrdinalPosition = $_.ORDINAL_POSITION
                    ColumnName      = $_.COLUMN_NAME
                    ColumnGuid      = $_.COLUMN_GUID
                    ColumnPropID    = $_.COLUMN_PROPID
                    Collation       = $_.COLLATION
                    Cardinality     = $_.CARDINALITY
                    Pages           = $_.PAGES
                    FilterCondition = $_.FILTER_CONDITION
                    Integrated      = $_.INTEGRATED
                    Expression      = $_.EXPRESSION
                    Datasource      = $Datasource
                }
            }
        )
    }
}
