function Invoke-AdoQuery {
    <#
	.SYNOPSIS
	Retrieves a resultset from any ADO provider, using the ADO COM interface.

	.DESCRIPTION
	Retrieves a resultset from any ADO provider, using the ADO COM interface. This does not return .NET objects.

    .PARAMETER Query
    What query should be run against the datasource?

    .PARAMETER Provider
    What describes the provider? Often this, is the guts that describe a "dsn-less" connection. It is used to choose the drivers that will be used to do to work of retrieving the data.

    .PARAMETER Datasource
    This describes the source of the data.

    .PARAMETER ExtendedProperties
    This allows the caller to provide extended property information, when required.

    .LINK
    http://www.carlprothman.net/Technology/ConnectionStrings/ODBCDSNLess/tabid/90/Default.aspx

	.LINK
    http://www.microsoft.com/technet/scriptcenter/funzone/games/solutions07/apssol05.mspx
	The initial basis for this came from here. I added the code to build $obj and output it in a pipeline-friendly way.

	.NOTES
	This is pretty slow (10 seconds to read about 6,000 small Visual FoxPro records, but it does work.

	.EXAMPLE
	This string works with ACE for Excel 2007.
	Note that the 12 in the Provider string is the Provider version, not the internal Excel (or, presumably, Office) version.
	You might need to use Excel 12.0 or Excel 13.0, in the extended properties
	Invoke-AdoQuery -Query "Select count(*) countOf From [authors$]"
		-Provider:"Microsoft.ACE.OLEDB.12.0"
		-DataSource:"c:\temp\pubs.xls"
		# .TODO what about extended properties.
		#-Extended-Properties:`"Excel 12.0 Xml;HDR=YES`";"

	.EXAMPLE
	Connection String for Excel 2003:
	Invoke-AdoQuery -Query "Select count(*) countOf From [authors$]"
		-Provider "Microsoft.Jet.OLEDB.4.0"
		-DataSource= "c:\temp\pubs.xls"
		# .TODO what about extended properties.
		#-Extended-Properties=`"Excel 8.0 Xml;HDR=YES;IMEX=1`";"

	.EXAMPLE
	Invoke-AdoQuery -Query "Select count(*) countOf From authors"
						-provider "vfpoledb"
						-datasource "c:\MyFoxFiles\"

	.EXAMPLE
	$provider = "Microsoft.Jet.OLEDB.4.0"
    if ($header) {
	    $ExtendedProperties = "Excel 8.0;HDR=Yes"
	    }
    else {
	    $ExtendedProperties = "Excel 8.0;HDR=NO"
	    }
	$ds ="c:\temp\pubs.xls"
	# Note that the sheet name always seems to end in a dollar sign, '$'
	$cmd = 'select * from [authors$]'
	Invoke-AdoQuery -datasource:$ds -Provider:$provider -Query:$cmd -ExtendedProperties:$ExtendedProperties

	#>

    param (
        [Parameter(Mandatory = $true)]
        [string] $Query,
        [Parameter(Mandatory = $true)]
        [string] $Provider,
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [string] $Datasource,
        [string] $ExtendedProperties
    )

    begin {
        $adOpenstatic = 3
        $adLockOptimistic = 3
    }

    process {
        $objConnection = New-Object -comobject "ADODB.Connection"
        $objRecordSet = New-Object -comobject "ADODB.Recordset"

        $connectionString = "Provider=$provider;data source=$datasource;"
        if ($ExtendedProperties) {
            $connectionString += "Extended Properties=$ExtendedProperties"
        }

        $objConnection.Open($connectionString)
        trap [System.Runtime.InteropServices.COMException] {
            write-error "ERROR: $($_.Exception.Message)"
            # to keep processing, I'd use continue here
            break
        }

        $objRecordSet.Open($Query, $objConnection, $adOpenStatic, $adLockOptimistic)
        $objRecordset.MoveFirst()

        # We need an object with appropriate properties to hold the data from the fields.
        # I am initializing the value here (even though we are going to overwrite it shortly)
        # so I get the correct data type associated with the property.
        $record = New-Object PSObject
        foreach ($field in $objRecordset.Fields) {
            $record | Add-Member -membertype noteproperty -name $field.Name -value $field.Value
        }

        do {
            # get a record's worth of fields and put the values in our working object
            # with every trip through the do {} loop, we will overwrite what existed from
            # the last row.
            foreach ($field in $objRecordset.Fields) {
                $record.$($field.Name) = $field.Value
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

