function Invoke-ExcelQuery {
    <#
    .SYNOPSIS
    Super quickie query script for Excel. This uses ODBC to do the 'dirty work'.

    .DESCRIPTION
    Super quickie query script for Excel. This uses ODBC to do the 'dirty work'.

    .PARAMETER ExcelFilePath
    Where is the file to be queried?

    .PARAMETER CommandText
    What is the query that you would like to run?

    .NOTES
    This was a massive rush-job, there was no real testing and there's no help or good examples, etc.

    .EXAMPLE
    Invoke-ExcelQuery -ExcelFilepath:"C:\temp\Book1.xlsx" -Command:"Select * From [Sheet1$]"

    .LINK
    https://www.simple-talk.com/sql/database-administration/getting-data-between-excel-and-sql-server-using-odbc/
    #>
    param (
        #the full path of the excel workbook
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string] $ExcelFilePath,
        [Parameter(Mandatory = $true)]
        [string] $CommandText
    )


    if ([Environment]::Is64BitProcess) {
        Write-warning "The chances are that only 32 bit Excel drivers are installed, which are not compatible with 64 bit PowerShell. Consider starting a 32 bit PowerShell (x86) session to run your process."
    }

    # If the *old* style driver name (Office 2007?) works, use that or else use the newer style driver name.
    # Becuase Get-InstalledDatabaseDriverList uses -match and not -eq, you must add those \slashes\
    if ($(Get-InstalledDatabaseDriverList -Name 'Microsoft Excel Driver \(\*.xls, \*.xlsx, \*.xlsm, \*.xlsb\)') ) {
        $DriverName = 'Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)'
    }
    else {
        $DriverName = 'Microsoft Excel Driver (*.xls)'
    }

    # todo: This string doesn't seem to work on any computer except for the one that I wrote this function on.
    $ConStr = 'Driver={' + $DriverName + '};DBQ=' + $ExcelFilePath + '; Extended Properties="Mode=ReadWrite;ReadOnly=false; HDR=YES"'
    Invoke-ODBCQuery -Command:$CommandText -ConnectionString:$ConStr

    # this is an oledb string that doesn't seem to behave, either. I don't know if I'd be better off using OLEDB or not
    #$Provider = "Microsoft.ACE.OLEDB.12.0"
    #$EP = "Excel 12.0 Xml;HDR=YES;"

    #Invoke-OLEDBQuery -CommandText:$Command -Provider:$Provider -ExtendedProperties:$EP -DataSource:$ExcelFilePath
}

