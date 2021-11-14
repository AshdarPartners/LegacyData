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
    Get-AdoColumnMetaData -Datasource ".\TestData\presidents.mdb" -columnname "e" -Provider "Microsoft.Ace.OLEDB.12.0"

    .EXAMPLE
    Get-AdoColumnMetaData -Datasource ".\TestData\presidents.mdb" -Provider "Microsoft.Jet.OLEDB.4.0"

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
        [string] $TableName = '.*',
        [string] $ColumnName = '.*'
    )


    begin {
        $adSchemaColumns = 4
    }

    process {
        (Get-AdoSchemaMetaData -SchemaType $adSchemaColumns -Provider $Provider -Datasource $Datasource -ExtendedProperties $ExtendedProperties |
            Where-Object { ($_.TABLE_NAME -match $TableName) -and ($_.COLUMN_NAME -match $ColumnName) }).ForEach(
            {
                [PSCustomObject] @{
                    TableName              = $_.TABLE_NAME
                    ColumnName             = $_.COLUMN_NAME
                    OrdinalPosition        = $_.ORDINAL_POSITION
                    ColumnHasDefault       = $_.COLUMN_HASDEFAULT
                    ColumnDefault          = $_.COLUMN_DEFAULT
                    # .TODO
                    # is this  a bitwise column?
                    # Can you translate this, either at this, the ADO layer, or at the caller layer?
                    ColumnFlags            = $_.COLUMN_FLAGS
                    IsNullable             = $_.IS_NULLABLE
                    DataType               = $_.DATA_TYPE
                    NumericPrecision       = $_.NUMERIC_PRECISION
                    NumericScale           = $_.NUMERIC_SCALE
                    CharacterMaximumLength = $_.CHARACTER_MAXIMUM_LENGTH
                    CharacterOctetLength   = $_.CHARACTER_OCTET_LENGTH
                    Datasource             = $Datasource
                }
            }
        )
    }
}
