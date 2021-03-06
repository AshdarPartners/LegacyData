function Invoke-DBaseQuery {
    <#
    .SYNOPSIS
    Runs a query against DBase tables using the last official Visual Fox Pro OLEDB driver from Microsoft.

    .DESCRIPTION
    Runs a query against DBase tables using the last official Visual Fox Pro OLEDB driver from Microsoft.

    .PARAMETER Connection
    An OleDb connection to a DBase database. This can be useful (read: more efficient) if
    you need to execute many statements against a single data source. See the example.

    .PARAMETER Query
    What query should be executed?

    .PARAMETER DataSource
    Where is the DBase data?

    .PARAMETER As
    This determines the type of object returned to the caller or passed down the pipeline.

    Currently, the following object types are valid: "DataSet", "DataTable", "DataRow","SingleValue" or "NonQuery".

    Detail is "DataRow"

    .PARAMETER SqlParameters
    Specifies a hashtable of parameters for parameterized SQL queries.  http://blog.codinghorror.com/give-me-parameterized-sql-or-give-me-death/
    The values should be in a hash, which is easily/invisibly cast to an IDictionary by PowerShell. See the example.

    .NOTES
    The last Visual Fox Pro driver released by Microsoft was 32 bit only. Microsoft did not relase 64 bit
    version of this driver.

    If you need 64 bit support, you may have successs using the "AWE" drivers available
    via Microsoft Office. (These used to be called "Jet", up until about office 2003 or 2007).

    Install the 64 bit drivers can be a problem if you are using 32 bit versions of the Office apps, which
    may people still do as Microsoft offered (and might still continue to offer) 32 bit as a default.

    Note that the ACE driver will let traverse subfolders. This may be handy or may be dangerous, depending on your point of view
    and how well locked down your stuff is. This works fine:

    Invoke-DBASEQuery -DataSource "c:" -Query "SELECT * FROM c:\users\somebody\my\secret\fox\database\empsalry"

    That ought to work with fileshares as well, ex: "SELECT * FROM \\BFS\someshare\users\somebody\my\secret\fox\database\empsalry"

    .EXAMPLE
    Invoke-DBaseQuery -Query "Select count(*) as countOf From dept" -datasource "c:\fpdata"

    .EXAMPLE
    Invoke-DBaseQuery -Query "Select top (1) * From dept order by deptid" -datasource "c:\fpdata"

    .EXAMPLE
    Invoke-DBaseQuery -Query "Select * From dept where deptid = '1234'" -datasource "c:\fpdata"

    .EXAMPLE
    Invoke-DBaseQuery -Query "create table dept (deptid int) " -datasource "c:\temp" -As 'NonQuery'

    .EXAMPLE
    try {
        $cn = Get-DBaseConnection -DataSource 'c:\fpdata'
        Invoke-DBaseQuery -Connection $cn -Query $Query1 -SqlP $Param1
        Invoke-DBaseQuery -Connection $cn -Query $Query2 -SqlP $Param2
        Invoke-DBaseQuery -Connection $cn -Query $Query3 -SqlP $Param3
    }
    catch {
        # re-throw
        Throw
    }
    finally {
        # clean up. This step is key or you risk leaking resources
        $cn.Close()
        $cn.Dispose()
    }


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

        [Parameter(Mandatory = $true)]
        [string] $Query,

        [ValidateSet("DataSet", "DataTable", "DataRow", "SingleValue", "NonQuery")]
        [string] $As = "DataRow",
        [System.Collections.IDictionary] $SqlParameters
    )

    try {

        switch ($PSCmdlet.ParameterSetName) {
            'WithDataSource' {
                $cn = Get-DbaseConnection -DataSource $DataSource
            }
            'WithConnection' {
                $cn = $Connection
            }
        }

        Invoke-OleDbQuery -As $As -Query $Query -SqlParameters $SqlParameters -Connection $cn

    }

    catch {
        throw
    }

    finally {
        if ($PSCmdlet.ParameterSetName -ne 'WithConnection') {
            $cn.Close()
            $cn.Dispose()
        }
    }
}