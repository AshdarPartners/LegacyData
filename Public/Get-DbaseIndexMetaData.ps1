function Get-DbaseIndexMetaData {
    <#
    .SYNOPSIS
    Displays metadata for Dbase indexes

    .DESCRIPTION
    Displays metadata for Dbase indexes

    .NOTES
    For what it is worth, Dbase does not seem to support "keys", either primary keys or alternate keys.
    It does support indexes. There are columns in the output that indicate uniqueness, etc.

    .PARAMETER DataSource
    Which Dbase location is of interest?

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .PARAMETER IndexName
    What is the name of the index(es) of interest? Null means 'all indexes'.

    .EXAMPLE    
    Get-DbaseIndexMetaData  -datasource '\\server\share\path'
    # Shows all of the primary keys for the tables at that location.

    .EXAMPLE    
    Get-DbaseIndexMetaData  -datasource '\\server\share\path' -TableName "dept"
    # Shows all of the primary keys for the named table at that location.
    #>

    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        $TableName,
        $IndexName
    )

    try {
        $cn = Get-DbaseConnection -DataSource $Datasource

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