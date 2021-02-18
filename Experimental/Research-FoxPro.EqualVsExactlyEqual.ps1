<#
.SYNOPSIS
How does "equal" vs. "exactly equal" ("=" vs. "==") really work?

.LINK
http://www.yaldex.com/fox_pro_tutorial/html/31f9c8c3-414e-4930-aa7f-2239f07b19e6.htm
Talks about EQUALS vs. EXACTLY EQUALS

.LINK
http://www.yaldex.com/fox_pro_tutorial/html/7d2d6409-f972-4452-9c6d-91ac5c9a2a5e.htm
Talks about ANSI
#>
function main {
    [cmdletbinding()]
    param ()

    $FoxProDbPath = Join-Path -Path $PSScriptRoot -child "TestData"

    Write-Verbose -Message "FoxPro Db Path: $FoxProDbPath"

    if (-not (Test-Path $FoxProDbPath)) {
        New-Item -Path $FoxProDbPath -ItemType 'Directory' | Out-Null
    }


    # clean up from last time
    Get-ChildItem -Path $FoxProDbPath -Filter 'foo.*' | Remove-Item

    try {
        <# 
        An experiment: I tried executing this CREATE TABLE statement with a 'dbase connection'. 
        It failed on syntax.

        ACE doesn't like CREATE TABLE DDL? How would I create a dBase table with ACE, then?
        
        $cn = Get-dbaseConnection -DataSource $FoxProDbPath
        Invoke-Dbase Query -as NonQuery -Connection $cn -Query "CREATE TABLE foo(ref v(20), diff v(20))"
        #>

        $cn = Get-FoxProConnection -DataSource $FoxProDbPath
        write-verbose -message "Got a connection"

        # This creates a test table
        # this is "reference" vs. "difference"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query "CREATE TABLE foo(ref v(20), diff v(20))"

        write-verbose -Message "Created a table"

        # Now that we have the table built, we can put some data into it.
        # Note that some of these have trailing space chars and some don't-
        # this can affect = results
        $QueryInsert = "insert into foo (ref,diff) values ('abc','abc')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('ab','abc')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('abc','ab')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('abc','ab ')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('ab ','ab')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('','ab')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('ab','')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('  ','')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $QueryInsert = "insert into foo (ref,diff) values ('','   ')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        # Examples behond what is in the linked URL
        $QueryInsert = "insert into foo (ref,diff) values ('TWIN','TWINE')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert
        $QueryInsert = "insert into foo (ref,diff) values ('TWINE','TWIN')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert
        $QueryInsert = "insert into foo (ref,diff) values ('TWINE','TWINE')"
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

        $Report = Invoke-FoxProQuery -Connection $cn -Query 'SELECT COUNT(*) cnt FROM foo'

        write-verbose -Message "Inserted $($Report.cnt) row(s) into the table"

        # if ANSI is off and EXACT is off and we use = (not ==), then it's a problem.
        #       "TWIN" equals "TWINE"? What the heck?
        # IF ANSI is ON and EXACT is ON, there is no problem if we use = or ==

        # ANSI=ON means "trim trailing spaces from string". SqlServer has a similar thing.
        # turning ANSI OFF or ON makes a big difference. ANSI is ON by default

        $EQUALS = '='
        # $EQUALS = '=='


        # First, try it OFF
        $ANSI = "OFF"
        $EXACT = "OFF"

        $QuerySet = "SET EXACT " + $EXACT
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QuerySet

        $QuerySet = "SET ANSI " + $ANSI
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QuerySet

        # show the data we just inserted, but look for equivalencies
        $Query = "SELECT '$EXACT' exact, '$ANSI' ansi, '$EQUALS' equals, recno() recno, *, IIF(ref$($EQUALS)diff, .T.,.F.) match FROM foo "
        Invoke-FoxProQuery -Connection $cn -Query $Query | Format-Table -AutoSize

        write-verbose -Message "Ran the query with ANSI = $ANSI and EXACT = $EXACT"


        # Now try it ON
        $ANSI = "ON"
        $EXACT = "ON"

        $QuerySet = "SET EXACT " + $EXACT
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QuerySet

        $QuerySet = "SET ANSI " + $ANSI
        Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QuerySet

        # show the data we just inserted, but look for equivalencies
        $Query = "SELECT '$EXACT' exact, '$ANSI' ansi, '$EQUALS' equals, recno() recno, *, IIF(ref$($EQUALS)diff, .T.,.F.) match FROM foo "
        Invoke-FoxProQuery -Connection $cn -Query $Query | Format-Table -AutoSize

        write-verbose -Message "Ran the query with ANSI = $ANSI and EXACT = $EXACT"
    }
    catch {
        Throw $Error[0]
    }

    Finally {
        $cn.Close()
        $cn.Dispose()
        $cn = $null
        # clean up
        Get-ChildItem -Path $FoxProDbPath -Filter foo.* | Remove-Item
    }

}

# call main
main -verbose