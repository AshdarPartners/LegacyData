function Compare-DbaseTableMetaData {
    <#
	.SYNOPSIS
	Simple comparison of tables in a pair of (or the same) Dbase databases.

    .DESCRIPTION
	Simple comparison of tables in a pair of (or the same) Dbase databases.

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
	Compare-DbaseTableMetaData -source:"c:\Dbase" -target:"C:\Dbase_copy"

    This example shows how to query an access database.


    .LINK
    Get-DbaseTable
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

        [switch] $IncludeEqual,

        [switch] $ExcludeDifferent
    )

    process {
        # Get the objects for the source and target
        $r1 = Get-DbaseTableMetaData -Path $SourcePath -TableName $TableName
        $r2 = Get-DbaseTableMetaData -Path $TargetPath -TableName $TableName

        # compare the reports and send the output down the pipeline.
        Compare-Object $r1 $r2 -SyncWindow:(($r1.count + $r2.count) / 2) -Property 'TableName' -IncludeEqual $IncludeEqual -ExcludeDifferent $ExcludeDifferent -PassThru |
            Select-Object @{Name = 'ObjectType'; e = { "Table" } }, TableName,
            @{Name = 'SourcePath'; e = { $SourcePath } },
            SideIndicator,
            @{Name = 'TargetPath'; e = { $TargetPath } }
    }

}

