function Get-FoxProTableMetaData {
    <#
    .SYNOPSIS
    Displays metadata for FoxPro tables, given a location.

    .DESCRIPTION
    Displays metadata for FoxPro tables, given a location.

    .PARAMETER DataSource
    Which FoxPro location is of interest?

    .PARAMETER TableName
    What is the name of the table(s) of interest? Null means 'all tables'.

    .EXAMPLE
    $Path = 'C:\Program Files (x86)\Microsoft Visual FoxPro OLE DB Provider\Samples\Northwind'
    Get-FoxProTableMetaData  -datasource $Path
    # Shows all of the tables at that location.

    .EXAMPLE
    $Path = 'C:\Program Files (x86)\Microsoft Visual FoxPro OLE DB Provider\Samples\Northwind'
    Get-FoxProTableMetaData  -datasource $Path -TableName 'employees'
    # Shows the table named 'employees'.

    #>

    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        $TableName
    )

    try {
        $cn = Get-FoxProConnection -DataSource $Datasource
        Get-OleDbTableMetadata -Connection $cn -TableName $TableName |
            Select-Object TableName, Type, Description, DateCreated
    }

    finally {
        $cn.Close()
        $cn.Dispose()
    }
}