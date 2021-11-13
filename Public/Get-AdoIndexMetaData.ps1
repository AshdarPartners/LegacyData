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
        [string] $TableName = ".*"
    )

    begin {
        $adSchemaIndexes = 12
    }

    process {
        #FIXME: Rework to be more like the ForEach() tactic that Get-OleDbTableMetadata uses
        Get-AdoSchemaMetaData -SchemaType $adSchemaIndexes -Provider $Provider -Datasource $Datasource -ExtendedProperties $ExtendedProperties |
            Where-Object {($_.TABLE_NAME -match $TableName)} |
            Select-Object @{n = "TableCatalog"; e = {$_.TABLE_CATALOG}},
        @{n = "TableSchema"; e = {$_.TABLE_SCHEMA}},
        @{n = "TableName"; e = {$_.TABLE_NAME}},
        @{n = "IndexCatalog"; e = {$_.INDEX_CATALOG}},
        @{n = "IndexSchema"; e = {$_.INDEX_SCHEMA}},
        @{n = "IndexName"; e = {$_.INDEX_NAME}},

        @{n = "PrimaryKey"; e = {$_.PRIMARY_KEY}},
        @{n = "Unique"; e = {$_.UNIQUE}},
        @{n = "Clustered"; e = {$_.CLUSTERED}},
        @{n = "Type"; e = {$_.TYPE}},

        @{n = "FillFactor"; e = {$_.FILL_FACTOR}},
        @{n = "InitialSize"; e = {$_.INITIAL_SIZE}},

        @{n = "Nulls"; e = {$_.NULLS}},
        @{n = "SortBookmarks"; e = {$_.SORT_BOOKMARKS}},
        @{n = "AutoUpdate"; e = {$_.AUTO_UPDATE}},
        @{n = "NullCollation"; e = {$_.NULL_COLLATION}},
        @{n = "OrdinalPosition"; e = {$_.ORDINAL_POSITION}},

        @{n = "ColumnName"; e = {$_.COLUMN_NAME}},
        @{n = "ColumnGuid"; e = {$_.COLUMN_GUID}},
        @{n = "ColumnPropID"; e = {$_.COLUMN_PROPID}},
        @{n = "Collation"; e = {$_.COLLATION}},
        @{n = "Cardinality"; e = {$_.CARDINALITY}},
        @{n = "Pages"; e = {$_.PAGES}},
        @{n = "FilterCondition"; e = {$_.FILTER_CONDITION}},
        @{n = "Integrated"; e = {$_.INTEGRATED}},
        @{n = "Expression"; e = {$_.EXPRESSION}},
        @{n = "Datasource"; e = {$Datasource}}
    }

}
