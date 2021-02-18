<#
.SYNOPSIS
This is not a property .tests. Pester file, I am still researching how to build a FoxPro db and testing mah stuhf.
#>

$ConstantsFile = Join-Path -Path (Split-Path $PSScriptRoot) -childpath "Tests\constants.ps1"
. $ConstantsFile 

Write-Verbose -Verbose -Message "FoxPro Db Path: $script:FoxProDbPath"

Get-ChildItem -path $script:FoxProDbPath -Filter *.dbf | Remove-Item -Verbose
try {
    $cn = Get-FoxProConnection -datasource $FoxProDbPath

    # https://social.msdn.microsoft.com/Forums/windows/en-US/4a3db1a3-28e4-4aaa-b500-cad6a8e3bcb5/create-database-command-in-vfp?forum=visualfoxprogeneral
    # Invoke-FoxProQuery -As 'NonQuery' -Query "create database [c:\temp\foxprotest\foxprotest] " -Connection $cn
    # Error: "Feature is not available."
    # apparently, I need a ".dbc" file to create primary keys.

    # No primary key?
    # Invoke-FoxProQuery -As 'NonQuery' -Query "create table dept (deptid int primary key) " -Connection $cn
    # Error: "Feature is not supported for non-.DBC tables." 
    # That means that PK needs Visual FoxPro "databases", not just FoxPro (for DOS) "loose tables"
    Write-Verbose -verbose -Message "creating table"
    Invoke-FoxProQuery -As 'NonQuery' -Query "create table dept (deptid int NOT NULL) " -datasource $script:FoxProDbPath

    # Get-FoxProColumnMetaData -Datasource $FoxProDbPath -TableName $tablename
    Write-Verbose -verbose -Message "insert some data"
    for ($i = 1; $i -lt 10; $i++) {
        Invoke-FoxProQuery -As 'NonQuery' -Query "insert into dept (deptid) values ($i) " -datasource $script:FoxProDbPath
    }
    #Invoke-FoxProQuery -Query "select * from dept " -Connection $cn
    Write-Verbose -verbose -Message "Inserted $i Row(s)"

    # that gives us sometjhing test with.

    # https://github.com/AshdarPartners/LegacyData/issues/13
    # Cannot run an index command of any kind on FoxPro?
    # I can't get these index commmands rigHt. Using the examples at the link (but my own table).
    # http://www.yaldex.com/fox_pro_tutorial/html/242d1feb-d43e-4831-9e4b-d0bb0b5fe4ae.htm
    #
    # error messages are vague
    # Exception calling "ExecuteNonQuery" with "0" argument(s): "One or more errors occurred during processing of command."
    #
    # One theory is that the DBF is somehow in use when I go to create the index.
    
    Write-Verbose -verbose -Message "use table"
    # EXCLUSIVE or not, no difference
    # Invoke-FoxProQuery -As 'NonQuery' -Query "USE dept  " -Connection $cn
    Invoke-FoxProQuery -As 'NonQuery' -Query "USE dept EXCLUSIVE " -Connection $cn

    Write-Verbose -verbose -Message "indexing table, Example #1"
    Invoke-FoxProQuery -As 'NonQuery' -Query "INDEX ON deptid TO deptid  " -Connection $cn

    # Write-Verbose -verbose -Message "indexing table, Example #3"
    # Invoke-FoxProQuery -As 'NonQuery' -Query "INDEX ON deptid TAG deptid  " -Connection $cn
    # Get-FoxProTableMetaData -Datasource $FoxProDbPath -TableName 'dept'


    # Invoke-FoxProQuery -As 'NonQuery' -Query "drop table dept " -Connection $cn

    Write-Verbose -verbose -Message "Test SUCCESFUL"
}

finally {
    if ($cn) {
        $cn.Close()
        $cn.Dispose()
    }

}