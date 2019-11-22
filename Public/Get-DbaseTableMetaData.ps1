function Get-DbaseTableMetaData {
    <#
    .SYNOPSIS
    Displays metadata for Dbase tables, given a location.

    .DESCRIPTION
    Displays metadata for Dbase tables, given a location.

    .PARAMETER DataSource
    Which Dbase location is of interest?

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .NOTES
    The tricky part is ensuring that the drivers are available for your system.
    It is easy to run PowerShell as 64 bit, even though only 32 bit drivers are installed.

    .EXAMPLE
    Get-DbaseTableMetaData  -datasource '\\server\share\path'
    # Shows all of the tables at that location.

    .EXAMPLE
    Get-DbaseTableMetaData  -datasource '\\server\share\path' -TableName "dept"
    # Shows the column information for all of the columns in the table named 'dept'.

    #>

    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        $TableName
    )

    try {
        $cn = Get-DbaseConnection -DataSource $Datasource
        Get-OleDbTableMetadata -Connection $cn -TableName $TableName |
            Select-Object TableName, Type, Description, DateCreated
    }

    finally {
        $cn.Close()
        $cn.Dispose()
    }
}