function Get-DbaseColumnMetaData {
    <#
    .SYNOPSIS
    Displays metadata for Dbase columns

    .DESCRIPTION
    Displays metadata for Dbase columns

    .PARAMETER DataSource
    Which Dbase location is of interest?

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .PARAMETER ColumnName
    What is the name of the column(s) of interest? Null means 'all tables'.

    .EXAMPLE
    Get-DbaseColumnMetaData  -datasource '\\server\share\path'
    # Shows all of the columns in the tables at that location.

    .EXAMPLE
    Get-DbaseColumnMetaData  -datasource '\\server\share\path' -TableName "dept"
    # Shows the column information for all of the columns in the table named 'dept'.

    .EXAMPLE
    Get-DbaseColumnMetaData  -datasource '\\server\share\path' -ColumnName "fname"
    Shows the column information for the column 'fname' in all tables found at that location.
    This can be very handy to look for differences in column definitions.

    #>

    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        $TableName,
        $ColumnName
    )

    try {
        $cn = Get-DbaseConnection -DataSource $Datasource

        # Get-OleDbColumnMetadata doesn't provide for restricting by column name, so we will do that here.
        # Dbase doesn't support many of the metadata columns here, so we will restrict the output
        Get-OleDbColumnMetadata -Connection $cn |
            Where-Object { $_.ColumnName -eq $ColumnName -or $Null -eq $ColumnName } |
            Select-Object TableName,
            ColumnName, OrdinalPosition,
            ColumnFlags,
            IsNullable,
            DataType, DataTypeDescription,
            NumericPrecision, NumericScale,
            CharacterMaximumLength, CharacterOctetLength
        # TableCatalog, TableScema
        # ColumnHasDefault, ColumnDefault,
        # CharacterSetCatalog, CharacterSetSchema, CharacterSetName,
        # CollationCatalog, CollationSchema, CollationName,
        # DomainCatalog, DomainSchema, DomainName,
        # IsComputed
    }

    finally {
        $cn.Close()
        $cn.Dispose()
    }

}
