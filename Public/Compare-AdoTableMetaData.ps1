function Compare-AdoTableMetaData {
    <#
	.SYNOPSIS
	Simple comparison of tables in a pair of (or the same) ADO databases.

    .DESCRIPTION
	Simple comparison of tables in a pair of (or the same) ADO databases.

    .PARAMETER SourcePath
    The path of the 'source' database.

    .PARAMETER TargetPath
    The path of the 'target' database.

    .PARAMETER TableName
    What table or tables would you like to compare? This uses -match semantics; it is not an array of table names.

    .PARAMETER Provider
    What describes the provider? Often this, is the guts that describe a "dsn-less" connection. It is used to choose the drivers that will be used to do to work of retrieving the data.

    .PARAMETER IncludeEqual
    Should tables that are "equal", or the same, be shown in the output? Default is $true.

    .PARAMETER ExcludeDifferent
    Should tables that are "equal", or are different, be shown in the output? Default is $false.

	.EXAMPLE
	Compare-AdoTableMetaData -source:"c:\dev\presidents.mdb" -target:"C:\release\presidents.mdb" -Provider:"Microsoft.ACE.OLEDB.12.0"

    This example shows how to query an access database.


    .LINK
    Get-AdoTableMetaData
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string] $SourcePath,
        [Parameter(Mandatory = $true)]
        [string] $TargetPath,
        [Parameter(Mandatory = $true)]
        [string] $Provider,
        [Parameter(ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $TableName = ".*",
        [switch] $IncludeEqual = $false,
        [switch] $ExcludeDifferent = $false
    )

    <#
    TODO: Extend comparisons to other object types, such as "query" and "report".
    #>

    process {
        # Get the objects for the source and target
        $r1 = Get-AdoTableMetaData -Path:$SourcePath -TableName:$TableName -Provider:$Provider
        $r2 = Get-AdoTableMetaData -Path:$TargetPath -TableName:$TableName -Provider:$Provider

        # compare the reports and send the output down the pipeline.
        $difference = Compare-Object $r1 $r2 -SyncWindow:(($r1.count + $r2.count) / 2) -Property:TableName -IncludeEqual:$IncludeEqual -ExcludeDifferent:$ExcludeDifferent  -PassThru
        $difference | Select-Object @{Name = 'ObjectType'; e = {"Table"}}, TableName,
				    @{Name = 'SourcePath'; e = {$SourcePath}},
				    SideIndicator,
				    @{Name = 'TargetPath'; e = {$TargetPath}}
    }

}

