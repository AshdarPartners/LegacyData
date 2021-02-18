<#
.SYNOPSIS
Show how FoxPro (and dBase) 'soft deletes' work


.NOTES
When you delete records from a FoxPro table, they are only marked as deleted.
They remain in the table, unseen, until you "PACK" that table.

You can see these records using the "SET DELETED OFF" command, which means
"show the deleted rows". It seems backwards but has been proven experimentally.

Once you issue the "SET DELETED OFF" command, you can tell the difference
between deleted rows and non-deleted rows by using the IsDeleted() function.

FoxPro and dBase work the same way, in this respect.

#>

$ConstantsFile = Join-Path -Path (Split-Path $PSScriptRoot) -childpath "Tests\constants.ps1"
. $ConstantsFile 

Write-Verbose -Verbose -Message "FoxPro Db Path: $script:FoxProDbPath"

# clean up from last time
Get-ChildItem -path $FoxProDbPath -Filter presdent.* | Remove-Item


try {

    $cn = Get-FoxProConnection -DataSource $FoxProDbPath

    # This creates a test table, with indexing
    # the basic idea is here: https://stackoverflow.com/questions/11653407/oledb-and-visual-foxpro
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query "CREATE TABLE presdent(fname v(20), lname v(20), presdentid i)"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query "EXECSCRIPT([USE presdent IN SELECT(0) EXCLUSIVE])"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query "EXECSCRIPT([INDEX ON lname TAG idx_lname])"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query "EXECSCRIPT([INDEX ON fname + lname TAG idx_xname])"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query "EXECSCRIPT([INDEX ON presdentid TAG pkpresdent CANDIDATE])"

    # Note: indexing on DELETED doesn't work here.
    # Why? See 'binary indexes', https://www.codemag.com/Article/0404022/What's-New-with-Data-in-Visual-FoxPro-9
    # "EXECSCRIPT([INDEX ON DELETED() TAG DELETED BINARY])"

    # Now that we have the table built, we can put some data into it.
    $QueryInsert = "insert into presdent (fname,lname,presdentid) values ('george','washington',1)"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

    $QueryInsert = "insert into presdent (fname,lname,presdentid) values ('john','adams',2)"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

    $QueryInsert = "insert into presdent (fname,lname,presdentid) values ('thomas','jefferson',3)"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

    # show the data we just inserted
    $Query = "SELECT 'initial' event, *, deleted() isdeleted, recno() RowNo FROM presdent"
    Invoke-FoxProQuery -Connection $cn -Query $Query |
        Format-Table -AutoSize

    $QueryDelete = "DELETE FROM presdent WHERE presdentid = 2"
    Invoke-FoxProQuery -Connection $cn -as NonQuery -Query $QueryDelete

    $Query = "SELECT 'deleted1' event, *, deleted() isdeleted, recno() RowNo FROM presdent"
    Invoke-FoxProQuery -Connection $cn -Query $Query |
        Format-Table -AutoSize

    # "SET DELETED OFF" means "show the deleted rows". It seems backwards but has been proven experimentally.
    $QuerySet = "SET DELETED OFF"
    Invoke-FoxProQuery -Connection $cn -as NonQuery -Query $QuerySet

    $Query = "SELECT 'deletedoff' event, *, deleted() isdeleted, recno() RowNo FROM presdent"
    Invoke-FoxProQuery -Connection $cn -Query $Query |
        Format-Table -AutoSize

    # If you don't go through this to reset the connection, PACK can't get exclusive access to the table.
    # I presume there is an easier way to do this, but I don't know it and this works.
    # dstrait, 2019/08/10
    $cn.Close()
    $cn.Dispose()
    $cn = $null
    $cn = Get-FoxProConnection -DataSource $FoxProDbPath

    # Now, pack, set DELETED again and show that Adams is really gone.
    # You can verify this by looking at the RowNo values.
    $QueryInsert = "PACK presdent"
    Invoke-FoxProQuery -as NonQuery -Connection $cn -Query $QueryInsert

    $QuerySet = "SET DELETED OFF"
    Invoke-FoxProQuery -Connection $cn -as NonQuery -Query $QuerySet

    $Query = "SELECT 'postpack' event, *, deleted() isdeleted, recno() RowNo FROM presdent"
    Invoke-FoxProQuery -Connection $cn -Query $Query |
        Format-Table -AutoSize
}

catch {
    throw
}


Finally {
    $cn.Close()
    $cn.Dispose()
    $cn = $null
}

# clean up
Get-ChildItem -path $FoxProDbPath -Filter presdent.* | Remove-Item
