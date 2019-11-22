function Get-FoxProIndexMetaData {
    <#
    .SYNOPSIS
    Displays metadata for FoxPro indexes

    .DESCRIPTION
    Displays metadata for FoxPro indexes

    .NOTES
    For what it is worth, FoxPro does not seem to support "keys", either primary keys or alternate keys.
    It does support indexes. There are columns in the output that indicate uniqueness, etc.

    .PARAMETER DataSource
    Which FoxPro location is of interest?

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .PARAMETER IndexName
    What is the name of the index(es) of interest? Null means 'all indexes'.

    .EXAMPLE
    $Path = 'C:\Program Files (x86)\Microsoft Visual FoxPro OLE DB Provider\Samples\Northwind'
    Get-FoxProIndexMetaData  -datasource $Path
    # Shows the index information for all of the tables at that location

    .EXAMPLE
    $Path = 'C:\Program Files (x86)\Microsoft Visual FoxPro OLE DB Provider\Samples\Northwind'
    Get-FoxProIndexMetaData  -datasource $Path -TableName 'employees'
    # Shows the index information for the table named 'employees'.

    .EXAMPLE
    Get-FoxProIndexMetaData  -datasource '\\server\share\path' -TableName "dept"
    # Shows all of the primary keys for the named table at that location.
    #>

    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        $TableName,
        $IndexName
    )
    try {
        $cn = Get-FoxProConnection -DataSource $Datasource

        # Not all of the columns that OleDbSchemaIndex returns are useful/valid/supported in Dbase
        # and I commented those out.
        Get-OleDbIndexMetadata -Connection $cn -TableName $TableName -IndexName $IndexName |
            Select-Object TableName,
            # TableCatalog,
            # TableSchema,
            # IndexCatalog,
            # IndexSchema,
            IndexName,
            PrimaryKey,
            Unique,
            # Clustered,
            Type,
            # FillFactor,
            # InitialSize,
            Nulls,
            SortBookmarks,
            # AutoUpdate,
            NullCollation,
            OrdinalPosition,
            ColumnName,
            # ColumnGuid,
            # ColumnPropID,
            Collation,
            Cardinality,
            # Pages,
            # FilterCondition,
            Integrated,
            Expression
    }

    finally {
        $cn.Close()
        $cn.Dispose()
    }

}