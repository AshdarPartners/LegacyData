<# 
.SYNOPSIS
Does a row count of all tables in a folder.

#>

param (
    $Path 
)

Get-ChildItem -path $Path -Filter *.dbf | ForEach-Object{
        Invoke-foxproQuery -DataSource $Path -Query "SELECT '$($_.Basename)' AS TableName, COUNT(*) AS COUNT_OfRows FROM $($_.Basename)" 
    }