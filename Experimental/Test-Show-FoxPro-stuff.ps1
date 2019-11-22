<#
.SYNOPSIS
This is not a property .tests. Pester file, I am still researching how to build a FoxPro db and testing mah stuhf.

#>

Get-ChildItem *.psd1 | Import-Module -Force
#$Path = 'c:\temp\foxprotest'
$Path = 'C:\Program Files (x86)\Microsoft Visual FoxPro OLE DB Provider\Samples\Northwind'

# if a folder has no dbc files, which define a foxpro database, it is just  "free tables".
# there is a DBC for the Northwind example VFPOLEDB database, though
# ls -path $Path -Filter *.dbc

# there are dbf files
# ls -path $Path -Filter *.dbf

# I do not see any idx files
# ls -path $Path -Filter *.idx
# becasue they are cdx files:
# cdx stands for "Compound inDeX"
# ls -path $Path -Filter *.cdx

# the memo file seems to be "FoxPro Text"
# note that foxuser.fpt is "special"
# ls -path $Path -Filter *.fpt
# ls -path $Path -Filter foxuser.*

$TableName = 'employees'
# both of these work against the VFPOLEDB example files
#Get-FoxProTableMetaData -Datasource $Path
#Get-DbaseTableMetaData -Datasource $Path
#Get-DbaseTable -Datasource $Path  -TableName $TableName
#Get-DbaseColumnMetaData -Datasource $Path  -TableName $TableName | ogv
Get-DbaseIndexMetaData -Datasource $Path  -TableName $TableName | Out-GridView
