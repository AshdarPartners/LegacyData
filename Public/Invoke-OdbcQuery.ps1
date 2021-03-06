function Invoke-OdbcQuery {
    <#

    .SYNOPSIS
    Runs a query againsta an ODBC connection string.

    .DESCRIPTION
    Given a connection string and query, makes the connection and runs the query. Assumes we are returning a
    result set.

    .PARAMETER ConnectionString
    What is the data source that you would like to run a query on?

    .PARAMETER CommandText
    What is the query that you would like to run?

    .NOTES
    This would need to be 'generified' to become a "odbc" query, rather than a "Excel" query script.
    I grabbed the inital code from a web site, but I have heavily modified it.

    This was a massive rush-job, there was no real testing and there's no help or good examples, etc.

    Invoke-OdbcQuery only works with ADO or (MAYBE) OLEDB drivers. If they aren't handy, I've got nothing to use.
    So, this, which I grabbed from a web site in a hurry.

    .EXAMPLE
    Invoke-OdbcQuery -Query $Query -Provider:"Microsoft.ACE.OLEDB.12.0" -DataSource:$ExcelFile

    .LINK
    https://www.simple-talk.com/sql/database-administration/getting-data-between-excel-and-sql-server-using-odbc/
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string] $ConnectionString,
        [Parameter(Mandatory = $true)]
        [string] $CommandText
    )
    $ErrorActionPreference = "stop"

    try {
        $Connection = New-Object system.data.odbc.odbcconnection
        $Connection.ConnectionString = $ConnectionString
        $Connection.Open()
    }
    catch {
        throw $_.Exception
        exit
    }

    try {
        $Query = New-Object system.data.odbc.odbccommand
        $Query.Connection = $connection
        $Query.CommandText = $CommandText

        #get the datareader and just get the result in one gulp
        $Reader = $Query.ExecuteReader([System.Data.CommandBehavior]::SequentialAccess)

        #get it just once
        $Counter = $Reader.FieldCount

        #initialise the empty array of rows
        # $result = @() 
        while ($Reader.Read()) {
            $Tuple = New-Object -TypeName 'System.Management.Automation.PSObject'
            foreach ($i in (0..($Counter - 1))) {
                Add-Member -InputObject $Tuple -MemberType NoteProperty -Name $Reader.GetName($i) -Value $Reader.GetValue($i).ToString()
            }
            # $Result += $Tuple
            $Tuple
        }
        # $result
    }
    finally {
        if ($Reader) {
            $Reader.Close()
        }
        if ($Connection) {
            $Connection.Close()
        }
    }
}
