function Invoke-OleDbQuery {
    <#
    .SYNOPSIS
    Queries an OleDb data source, given an OleDb provider, DataSource and query. Returns a DataTable

    .DESCRIPTION
    Queries an OleDb data source, given an OleDb provider, DataSource and query. Returns a DataTable
    www.connectionstrings.com is an excellent resource for connection strings for specific drivers.

    .OUTPUTS
    DataSet, DataTable, DataRow, SingleValue or None. This is controlled by the -As parameter.

    .PARAMETER Connection
    If the caller provides a "live", open connection, it will be used. The connection will not be closed.

    .PARAMETER ConnectionString
    If the caller provides a connection string, it will be used. The connection will be closed before returning.

    .PARAMETER DataSource
    This highly dependant on the provider to be used. For MDB, DBF, EXCEL, etc, it's a file path. For RDBMS like SQL Server or MySQL, it will be a server hostname. Other variations are possible.

    .PARAMETER Provider
    Which OleDb provider should be used?

    .PARAMETER ExtendedProperties
    Some providers use a bevy of 'extended properties' in the connection string, this is a bucket into which you can throw them.
    The exact capability and syntax is provider-specific.
    The are usually key-value pairs in the format "Prop=something;AnotherProp=SomethingElse".
    No attempt is made to validate these properties or even validate the string. The first indication of trouble is usually that the Open() call will fail.

    .PARAMETER CommandText
    A/K/A "Query". What query should be run against the source? At it's simplest, this allows you to specify the table of interest and a specific list of columns. You can use "select *" if you want to. You can also join in the source, provide WHERE clauses, etc.
    For parameterized queries:
        1. Use ? as a placeholder and NOT @SomeName (which is SqlClient-specific and doesn't work with OleDb.)
        2. Do not need to specify quotes when providing a parameterizing: "select * from dept where deptname = ?", not "select * from dept where deptname = '?'"

    .PARAMETER CommandTimeout
    This limits the running time on the query for the source data.

    .PARAMETER As
    This determines the type of object returned to the caller or passed down the pipeline.

    Currently, the following object types are valid: "DataSet", "DataTable", "DataRow","SingleValue" or "NonQuery".

    Detail is "DataRow"

    .PARAMETER SqlParameters
    Specifies a hashtable of parameters for parameterized SQL queries.  http://blog.codinghorror.com/give-me-parameterized-sql-or-give-me-death/
    The values should be in a hash, which is easily/invisibly cast to an IDictionary by PowerShell). See the example.

    .PARAMETER Credential
    Use alternative credentials. Accepts credential objects provided by Get-Credential.

    .EXAMPLE
    Invoke-OleDbQuery -provider:"vfpoledb" -DataSource:'c:\temp\ADOLoad' -query:"Select count(*) CountOf from UNIT"
    This reads a Visual Fox Pro table, which is similar to dBase, xBase, etc, using the Visual FoxPro OleDb driver.

    .EXAMPLE
    Invoke-OleDbQuery -provider:"Microsoft.ACE.OLEDB.12.0" -DataSource:'c:\temp\ADOLoad' -query:"Select count(*) CountOf from UNIT" -ExtendedProperties:"dBASE IV;User ID=Admin;"
    This reads a Visual Fox Pro table, which is similar to dBase, xBase, etc, using "ACE", which are the drivers that come with Office 2007 and later.
    Watch out for the version numbers, they change with each version of Office.

    .EXAMPLE
    Invoke-OleDbQuery -DataSource 'hal9000' -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -query 'select getdate() RightNow'
    This reads a SQL Server database.

    .EXAMPLE
    $Query = "select getdate() RightNow where getdate() > ? "
    $Params = @{WasThen = "1/1/1980"}
    $Report = Invoke-OLEDBQuery -DataSource $DataSource -Provider 'sqloledb' -ExtendedProperties "Trusted_Connection=Yes" -query $Query -SqlParameters $params
    This shows a parameterized query. This query uses the ? as a placeholder and not @SomeName becuase we are using oledb and not sqlclient.

    .LINK
    http://stackoverflow.com/questions/10149910/use-powershell-to-save-a-datatable-as-a-csv

    .LINK
    Invoke-DbaQuery
    I have lifted some ideas straight out of CodingHorror/SqlCollaborative's work.

    .LINK
    https://www.connectionstrings.com/

    #>

    param (
        [Parameter(
            ParameterSetName = 'WithConnection',
            Mandatory = $true
        )]
        [System.Data.OleDb.OleDbConnection] $Connection,

        [Parameter(
            ParameterSetName = 'WithDataSource',
            Mandatory = $true
        )]
        [string] $DataSource,

        [Parameter(
            ParameterSetName = 'WithDataSource',
            Mandatory = $true
        )]
        [string] $Provider,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [string] $ExtendedProperties,

        [Parameter(
            ParameterSetName = 'WithConnectionString',
            Mandatory = $true
        )]
        [string] $ConnectionString,

        [Parameter(Mandatory = $true)]
        [Alias('Query')]
        [string] $CommandText,

        [int] $CommandTimeout = 300,

        [ValidateSet('DataSet', 'DataTable', 'DataRow', 'SingleValue', 'NonQuery')]
        [string] $As = 'DataRow',

        [System.Collections.IDictionary] $SqlParameters,

        [Parameter(
            ParameterSetName = 'WithDataSource'
        )]
        [System.Management.Automation.PSCredential] $Credential
    )

    <#
    This is a mashup of that SO.com link and Invoke-SQLCmd2 (which was an ancestor of DbaTools\Invoke-DbaQuery),
    mainly to get the -AS functionality the root nugget is that we change a datatable to a dataset, then we can
    pick out the da table if the caller wants it.
    The code is pretty much boilerplate.
    #>
    Try {
        # If we were handed a connection, use it. If we were not, create one.
        switch ($PSCmdlet.ParameterSetName) {
            'WithConnection' {
                $OleDbConn = $Connection
            }
            'WithConnectionString' {
                $OleDbConn = Get-OleDbConnection -ConnectionString $ConnectionString
            }
            'WithDataSource' {
                $OleDbConn = Get-OleDbConnection -DataSource $DataSource -ExtendedProperties $ExtendedProperties -Provider $Provider -Credential $Credential
            }
        }

        $command = New-Object System.Data.OleDb.OleDbCommand
        $command.Connection = $OleDbConn
        $command.CommandTimeout = $CommandTimeout
        $command.CommandText = $CommandText

        if ($null -ne $SqlParameters) {
            $SqlParameters.GetEnumerator() |
                ForEach-Object {
                    if ($null -ne $_.Value) {
                        $command.Parameters.AddWithValue($_.Key, $_.Value)
                    }
                    else {
                        $command.Parameters.AddWithValue($_.Key, [DBNull]::Value)
                    }
                } | Out-Null
        }

        <#
        IF we are running a 'non-query', which is a SQL statement that does not return a
        result set, we need to call .ExecuteNonQuery().
        Otherwise, all statements that return a result set need to create a Dataset object and then fill
        #>
        switch ($As) {
            'NonQuery' {
                # "$Null = " is alledged to be slighlty faster than " | Out-Null", in most cases
                $Null = $command.ExecuteNonQuery()
            }
            default {
                $ds = New-Object System.Data.DataSet
                $da = New-Object system.Data.OleDb.OleDbDataAdapter($command)
                # "$Null = " is alledged to be slighlty faster than " | Out-Null", in most cases
                $Null = $da.Fill($ds)
            }
        }

        <#
        Now, we just need to figure out what object type to return to the caller/send down the pipeline
        #>
        switch ($As) {
            'NonQuery' {
                <#
                This particular query does not return a result set (ex: an UPDATE statement or a DELETE statement),
                so there is nothing to return to the caller or feed to the pipeline.
                #>
            }
            'DataSet' {
                $ds
            }
            'DataTable' {
                $ds.Tables
            }
            'DataRow' {
                $ds.Tables[0]
            }
            'SingleValue' {
                $ds.Tables[0] |
                    Select-Object -ExpandProperty $ds.Tables[0].Columns[0].ColumnName
            }
            'PSObject' {
                Throw "This function does not implement 'PSObject'."
            }
        }
    }

    Catch {
        Throw
    }

    Finally {
        # if we were passed a connection, do not close it. Closing it is the responsibility of the caller.
        if ($PSCmdlet.ParameterSetName -ne 'WithConnection') {
            if ($OleDbConn) {
                $OleDbConn.Close()
                $OleDbConn.Dispose()
            }
        }
    }
}
