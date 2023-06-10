# Test Environment

## SQL Credential

Some of the tests use old middleware (OLEDB) to talk to "a database". That database is SQL Server, which is why there is support
for creating a file with a sql credential stored in it and then using that credential when testing. The creation of the credential
only needs to happen once.

## SqlOleDbHostName

This value is found in the TestValues JSON file. It is set to "127.0.0.1", rather than "localhost". This is because Windows 10
wants to use IPv6. It appears that neither Docker nor Podman support IPv6 "out of the box". Rather than force a configuration
just to run a test, I'm essentially hardcoding "connect to localhost with IPv4".

## These tests were coded against Pester 4.10.1 or thereabouts

The "discovery" processing add in Pester version 5 breaks these tests.

## Data Sources

The TestData files were pulled from another project which was a demo for SQL Server "linked server" queries.

The "presidents.txt" file is a "tab-delimited" version of the same data in the "presidents.csv" file.
