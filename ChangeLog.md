# Foreward:
The LegacyData is built upon the basis of the ancient Ashdar.data module. 

The last official version of Ashdar.data was 2.0.3. To provide a cleaner migration, the first version of the LegacyData module will be 3.0.0 and will have a new module GUID. I am leaving the pre-3.0.0 changes here in this changelog for archaeological reasons.


# Version Information
## FIXME: Planned for $next version
0. These items should be in Github's bugtracker, not listed here.
0. there is an interesting-looking OdbcConnect.GetSchema() method
0. I would like to look at using ACE drivers here, particular when using FoxPro data from 64 bit sessions. Is all of the VfpOleDb fucntionality in the ACE driver?
0. Functional tests for verious backends.
   1. Functional tests (ideally) mean Create table, insert data, select data, update data, delete data, drop table.
   1. For FoxPro (VfpOleDb and ACE), dBase. Maybe Excel and CSV?
0. Not everything supported -UserId and -Password, nor supports -Credential. Does this make sense for Excel, Fox and dBase?
0. I am leaving SNAC/System.Data.SqlClient out of this because it's not 'legacy' by any stretch. Similar for XML and JSON. OleDb, Odbc and Ado (we use COM-based ADO here, not .Net-based ADO.NET) are 'legacy', even though there are .net classes for them, becuase I said so.

## Implemented for 3.1.0 ($next version)
1. Replace the old -UserId and -Password with -Credential, which is a much more modern and flexible approach.
1. Added -Credential to Invoke-OleDbQuery, which had no prior provision for UserId and Passname.
1. The tests now have a way to abstract out credential and environment-specific information.
1. Miscellaneous bug fixes.

## Implemented for 3.0.0
1. Initial support for DBase, including radical rework of connection string creation.

Everything passes through "Get-Connection" for it's access subtype: OleDb, FoxPro, Dbase.
OleDb is pretty much done, but FoxPro and Dbase remain.


## Version 2.0.3
1. Provide output type for Get-OleDbConnection and Get-FoxProConnection.

## Version 2.0.2
1. Break out Get-OleDbConnection and Get-FoxProConnection.

## Version 2.0.1
1. Update to DbaTools 1.0.

## Version 2.0.0
1. Cmdlet names were confusing.
    1. "Show" wasn't the correct verb to use here, changed to the more-generic "Get".
    2. Many cmdlet names should have 'MetaData' at the end. They are retrieving data about 
        database objects
3. "NonQuery" did nt deserve its' own function.
4. The code now follows best practice suggestions from PSSA more closely.

## Version 1.1.4
1. Remove some fixme comments.

## Version 1.1.3
1. Some modernization of the existing "Show" cmdlets.
2. Added Show-ADOIndex
3. Added Show-OleDBSchema for tables, indexes and columns
4. Added Invoke-FoxProQuery and Invoke-FoxProNonQuery, including support for parameterized queries 
4. Added Invoke-DbaseQuery and Invoke-DbaseNonQuery, includig support for parameterized queries
5. Added Show-FoxPro for tables, indexes and columns.
6. Added Show-dBase for tables, indexes and columns.
7. Updated the 'About' module help.
9. Fixed a lot of cmdlet documentation.


## Version 1.1.2
This change file was not implemented when 1.1.2 was released.

