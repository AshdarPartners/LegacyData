# LegacyData
A PowerShell module to simplify dealing with certain legacy data formats, mainly dBASE, FoxPro and Excel

# Situation Report
This is a migration of an older project called "Ashdar.data". 

The goals are:
1. Break this code out of a monstrous, monolithic project with roots dating back ten years, which contains several other *entirely* unrelated things.
1. Adopt a more modern approach to deploying a module
1. Provide code that someone in the wider world else might find useful

# Licensing
I believe that none of this code is encumbered. If you diagree, let me know. 

# Testing Requirement
This requires Pester 4.x, but does not support 5.x or higher. It's probably best to use something like:
Install-Module -Name Pester -MaximumVersion 4.99.9999 

If you have not installed Pester on your computer before, you may be 'stuck' with version 3.4.1. In that case, this worked for me:
Install-Module -Name Pester -MaximumVersion 4.99.9999 -Force -SkipPublisherCheck

If you are testing the type of data source that requires a credential, you'll need to create one and have it available to the environment before running the Tests scripts. The PowerShell password or secrets "vault" module/technology seems to be a few months away from being released, so you will probably need to make due with a globally-scoped $Credential of some sort. 

#FIXME Need a good tactic for providing credentials for testing database managers like SqlServer. 

# Recent Work
When it comes to RDBMS, I am a SQL Server person. 

While I used this code in a relatively superfical way in the distant past, for the last couple of years I have been working with FoxPro data in a more exacting way. This data is mainly managed by FoxPro (for DOS), not Visual FoxPro (for Windows). Visual FoxPro seems leaps and bounds better than FoxPro (for DOS), but we can't always choose what we need to work with. I've been spoiled by modern RDBMS and I am often confounded by FoxPro's quirks. 

