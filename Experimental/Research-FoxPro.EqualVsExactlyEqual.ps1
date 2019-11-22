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

$ConstantsFile = Join-Path -Path (Split-Path $PSScriptRoot) -childpath "Tests\constants.ps1"
. $ConstantsFile 

Write-Verbose -Verbose -Message "FoxPro Db Path: $script:FoxProDbPath"

# clean up from last time
Get-ChildItem -path $script:FoxProDbPath -Filter foo.* | Remove-Item


try {

    $cn = Get-FoxProConnection -DataSource $script:FoxProDbPath

    # This creates a test table
    # this is "reference" vs. "difference"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query "CREATE TABLE foo(ref v(20), diff v(20))"

    # Now that we have the table built, we can put some data into it.
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

    # if ANSI is off and EXACT is off and we use = (not ==), then it's problem.
    #       "TWIN" equals "TWINE"? What the heck?
    # IF ANSI is ON and EXACT is ON, there is no problem if we use = or ==
    $EQUALS = '='
    # $EQUALS = '=='
    $ANSI = "OFF"
    $ANSI = "ON"
    $EXACT = "OFF"
    $EXACT = "ON"

    # turning ANSI OFF or ON makes a big difference. ANSI is ON by default

    $QueryInsert = "SET EXACT " + $EXACT
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

    $QueryInsert = "SET ANSI " + $ANSI
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

    # show the data we just inserted, but look for equivalencies
    $Query = "SELECT '$EXACT' exact, '$ANSI' ansi, '$EQUALS' equals, recno() recno, *, IIF(ref$($EQUALS)diff, .T.,.F.) match FROM foo "
    Invoke-FoxProQuery -Connection $cn -Query $Query |
        Format-Table -AutoSize

}

Finally {
    $cn.Close()
    $cn.Dispose()
    $cn = $null
}

# clean up
Get-ChildItem -path $script:FoxProDbPath -Filter presdent.* | Remove-Item
