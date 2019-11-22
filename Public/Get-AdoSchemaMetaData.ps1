function Get-AdoSchemaMetaData {
    <#
	.SYNOPSIS
	Retrieves a list schema type from an ADO data source

    .DESCRIPTION
    Retrieves a list schema type from an ADO data source

    .PARAMETER Provider
    What describes the provider? Often this, is the guts that describe a "dsn-less" connection. It is used to choose the drivers that will be used to do to work of retrieving the data.

    .PARAMETER Datasource
    This describes the source of the data.

    .PARAMETER ExtendedProperties
    This allows the caller to provide extended property information, when required.

    .PARAMETER SchemaType
    What type of Schema 'report' do we want?

    All providers do not support all Schema types.

    There are many available, this cmdlet has been tested against only a few, so we ValidateSet() on this parameter.
    See the Microsoft link for full documentation.

    .NOTES
    Get-AdoSchemaMetaDataColumn, Get-AdoSchemaMetaDataIndex and Get-AdoSchemaMetaDataTable call this cmdlet. There is a fair amount
    of complicated code in here, with all of the looping over column names and rows, so it seems smarter to
    concentrate all of that in one function. If you look at the corresponding Get-OleDb* cmdlets, the code is
    much simpler so there is no Get-OleDbSchema.

    .EXAMPLE
    Get-AdoSchemaMetaData -Datasource "c:\temp\presidents.mdb" -provider "Microsoft.Ace.OLEDB.12.0" -SchemaType 20

    .LINK
    http://www.carlprothman.net/Technology/ConnectionStrings/ODBCDSNLess/tabid/90/Default.aspx

    .LINK
    https://docs.microsoft.com/en-us/sql/ado/reference/ado-api/schemaenum

    .LINK
    Get-AdoColumnMetaData

    .LINK
    Get-AdoIndexMetaData

    .LINK
    Get-AdoTableMetaData

	#>

    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $true)]
        # (adSchemaColumns = 4, adSchemaTables = 20, adSchemaKeyColumnUsage = 8, adSchemaPrimaryKeys = 28, adSchemaIndexes = 12)
        [ValidateSet(4, 8, 12, 20)]
        [int] $SchemaType,
        [Parameter(Mandatory = $true)]
        [string] $Provider,
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        [string] $ExtendedProperties
    )

    process {
        $objConnection = New-Object -comobject ADODB.Connection
        $objRecordset = New-Object -comobject ADODB.RecordSet

        $connectionString = "Provider=$provider;data source=$datasource;"
        if ($ExtendedProperties) {
            $connectionString += "Extended Properties=$ExtendedProperties"
        }


        $objConnection.Open($connectionString)
        trap [System.Runtime.InteropServices.COMException] {
            Write-Error "ERROR: $($_.Exception.Message)"
            # to keep processing, I'd use continue here
            break
        }

        $objRecordset = $objConnection.OpenSchema($SchemaType)
        $objRecordset.MoveFirst()

        # We need an object with appropriate properties to hold the data from the fields.
        # I am initializing the value here (even though we are going to overwrite in shortly)
        # so I get the correct data type associated with the property.
        $record = New-Object PSObject
        foreach ($field in $objRecordset.Fields) {
            $record | Add-Member -MemberType:noteproperty -Name:$field.Name -Value:$field.Value
    }

    do {
        # For whatevever reason, ADO returns a numeric constant rather than a string
        # for a data type, at least for Access files. That is translated here, for the
        # convenience of the caller.
        foreach ($field in $objRecordset.Fields) {
            if ($field.Name -eq "DATA_TYPE") {
                $record.$($field.Name) = [enum]::Parse("system.data.oledb.oledbtype", $field.Value)
            }
            else {
                $record.$($field.Name) = $field.Value
            }
        }
        # emit the working object to the pipeline, then move to the next record and loop
        $record
        $objRecordset.MoveNext()
    }
    until ($objRecordSet.EOF -eq $True)

    $objRecordset.Close()
    $objConnection.Close()

    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()

}

}
