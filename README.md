# LegacyData
A PowerShell module to simplify dealing with certain legacy data formats, mainly dBASE, FoxPro and Excel

# Situation Report
This is a migration of an older project called "Ashdar.data". 

The goals are:
1. Break this code out of a monstrous, monolithic project with roots dating back before 2010, which contains several other *entirely* unrelated things.
1. Adopt a more modern approach to deploying a module
1. Provide code that someone in the wider world else might find useful

# Licensing
I believe that none of this code is encumbered. If you disagree, let me know and we'll fix that. 

# Scope
At it's core, this module is a wrapper around OLEDB and ADO drivers. It also warehouses some notes/tips about how to use those drivers.

I am leaving SNAC/System.Data.SqlClient out of this because it's not 'legacy' by any stretch. Similar for XML and JSON. OleDb, ODBC and Ado (we use COM-based ADO here, not .Net-based ADO.NET) are 'legacy', even though there are .net classes for them, because I said so.

# Testing Requirement
This requires Pester 4.x, but does not support 5.x or higher. It's probably best to use something like:
Install-Module -Name Pester -MaximumVersion 4.99.9999 

If you have not installed Pester on your computer before, you may be 'stuck' with version 3.4.1. In that case, this worked for me:
Install-Module -Name Pester -MaximumVersion 4.99.9999 -Force -SkipPublisherCheck

If you are testing the type of data source that requires a credential, you'll need to create one and have it available to the environment before running the Tests scripts. The PowerShell password or secrets "vault" module/technology seems to be a few months away from being released. For the time being, there is some credential management code in the .\Tests folder. 

I've been testing against a local SQL Server via Docker that I start manually. I need to get skilled up before I can implement a "real CI/CD pipeline" via Github. 

# Recent Work
When it comes to RDBMS, I am a SQL Server person. 

While I used this code in a relatively superficial way in the distant past, for the last couple of years I have been working with FoxPro data in a more exacting way. This data is mainly managed by FoxPro (for DOS), not Visual FoxPro (for Windows). Visual FoxPro seems leaps and bounds better than FoxPro (for DOS), but we can't always choose what we need to work with. I've been spoiled by modern RDBMS and I am often confounded by FoxPro's quirks. 

