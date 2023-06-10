# Overview

The LegacyData is built upon the basis of the ancient (pre-2012?) Ashdar.data module, which was never released publicly.

"Legacy" is a set of scripts that wrap the functionality of different database access technologies. It's not very brilliant, but it
has proven very useful in the last few years.

There is no rocket science here, it's about convenience and organization.

The last official version of Ashdar.data was 2.0.3. To provide a cleaner migration, the first version of the LegacyData module
will be 3.0.0 and will have a new module GUID.

I am leaving the pre-3.0.0 changes here in this changelog for archaeological reasons.

## Version Information

## 3.2.1 - Unreleased

### Changed

- Clean up some environmental issues with the tests. Moved from Docker to Podman.
- Bump the version number

## 3.2.0 - 2021-11-14

### Added

- Pester tests for the ADO functionality which existed but was untested, Pester-wise.

### Changed

- Do not try to free OLEDB connections that don't exist
- Faster syntax/tactic for renaming OLDEDB metadata columns to something more friendly.
- Tweak the way that the Sql Server credential is handled for the Pester tests.
- Add some files full of test data for testing of the ISAM-style code.
- Restructured this changelog to more closely follow a [standard format](https://keepachangelog.com/en/1.0.0/)

## 3.1.0 - 2021-02-17

### Added

1. Added -Credential to Invoke-OleDbQuery, which had no prior provision for UserId and Password.
1. Added -Credential support to Get-FoxProConnection and Get-DBaseConnection

### Changed

- Replace the old, non-best-practice -UserId and -Password parameters with a single -Credential parameter, which is a more modern and flexible approach.
- The tests now have a way to abstract out credential and environment-specific information.
- Miscellaneous research on differences between FoxPro via VFPOLEDB and "ACE".
- Started on some Pester tests for dBase and FoxPro.

### Removed

- Various FIXME comments into the Github bug tracker. There are currently 13 open issues and 0 closed issues.

### Fixed

- Miscellaneous bug fixes.

## 3.0.0 - 2021-02-11

### Added

- Initial support for DBase

### Changed

- Radical rework of connection string creation. Everything now passes through "Get-Connection" for it's access subtype: OleDb,
FoxPro, Dbase.OleDb is pretty much done, but FoxPro and Dbase remain.


## 2.0.3 - ????-??-??

### Changed

- Provide output type for Get-OleDbConnection and Get-FoxProConnection.

## 2.0.2 - ????-??-??

### Changed

- Break out Get-OleDbConnection and Get-FoxProConnection.

## 2.0.1 - ????-??-??

### Changed

- Update to DbaTools 1.0.

## 2.0.0 - ????-??-??

### Changed

- Cmdlet names were confusing.
- "Show" wasn't the correct verb to use here, changed to the more-generic "Get" for clarity.
- Many cmdlet names should have 'MetaData' at the end because they are retrieve data about database objects. For clarity.
- The code now follows best practice suggestions from PSSA more closely.

### Removed

- "NonQuery" did not deserve its' own function.

## 1.1.4 - ????-??-??

### Removed

- Some fixme comments.

## 1.1.3 - ????-??-??

### Added

- Show-ADOIndex
- Show-OleDBSchema for tables, indexes and columns
- Invoke-FoxProQuery and Invoke-FoxProNonQuery, including support for parameterized queries
- Invoke-DbaseQuery and Invoke-DbaseNonQuery, including support for parameterized queries
- Show-FoxPro for tables, indexes and columns.
- Show-dBase for tables, indexes and columns.
- This change file was implemented

### Changed

- Some modernization of the existing "Show" cmdlets.
- Updated the 'About' module help.

### Fixed

- A lot of cmdlet documentation
