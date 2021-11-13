function Get-AdoColumnMetaData {
    <#
	.SYNOPSIS
	Retrieves a list of columns for tables in an ADO datasource

    .DESCRIPTION
    Retrieves a list of columns for tables in an ADO datasource

    .PARAMETER Provider
    What describes the provider? Often this, is the guts that describe a "dsn-less" connection. It is used to choose the drivers that will be used to do to work of retrieving the data.

    .PARAMETER Datasource
    This describes the source of the data.

    .PARAMETER ExtendedProperties
    This allows the caller to provide extended property information, when required.

    .PARAMETER TableName
    What is the table of interest? This parameter uses -match semantics.

    .PARAMETER ColumnName
    What is the table of interest? This parameter uses -match semantics.

    .EXAMPLE
    Get-AdoColumnMetaData -Datasource:"$c:\dev\presidents.mdb" -columnname:"e" -provider:"Microsoft.Ace.OLEDB.12.0"

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
        [string] $TableName = ".*",
        [string] $ColumnName = ".*"
    )


    begin {
        $adSchemaColumns = 4
    }

    process {
        #FIXME: Rework to be more like the ForEach() tactic that Get-OleDbTableMetadata uses
        Get-AdoSchemaMetaData -SchemaType $adSchemaColumns -Provider $Provider -Datasource $Datasource -ExtendedProperties $ExtendedProperties |
            Where-Object {($_.TABLE_NAME -match $TableName) -and ($_.COLUMN_NAME -match $ColumnName)} |
            Select-Object @{n = "TableName"; e = {$_.TABLE_NAME}},
        @{n = "ColumnName"; e = {$_.COLUMN_NAME}},
        @{n = "OrdinalPosition"; e = {$_.ORDINAL_POSITION}},
        @{n = "ColumnHasDefault"; e = {$_.COLUMN_HASDEFAULT}},
        @{n = "ColumnDefault"; e = {$_.COLUMN_DEFAULT}},
        # .TODO
        # is this  a bitwise column?
        # Can you translate this, either at this, the ADO layer, or at the caller layer?
        @{n = "ColumnFlags"; e = {$_.COLUMN_FLAGS}},
        @{n = "IsNullable"; e = {$_.IS_NULLABLE}},
        @{n = "DataType"; e = {$_.DATA_TYPE}},
        @{n = "NumericPrecision"; e = {$_.NUMERIC_PRECISION}},
        @{n = "NumericScale"; e = {$_.NUMERIC_SCALE}},
        @{n = "CharacterMaximumLength"; e = {$_.CHARACTER_MAXIMUM_LENGTH}},
        @{n = "CharacterOctetLength"; e = {$_.CHARACTER_OCTET_LENGTH}},
        @{n = "Datasource"; e = {$Datasource}}

    }

}

