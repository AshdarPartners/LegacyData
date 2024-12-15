$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# go "one up" from the Tests folder
$Path = Split-Path -Parent -Path $PSScriptRoot

$ManifestFile = (Get-ChildItem  -Path $Path -Filter "*.psd1").FullName
Import-Module $ManifestFile -DisableNameChecking -Force

$TestConfiguration = Invoke-Expression -Command (Join-Path -Path $PSScriptRoot -ChildPath 'Get-LegacyDataTestValue.ps1')

if ([Environment]::Is64BitProcess) {
    # If this fails, you might try ACE versions other than 12 like 13, 14, 15, 16 and so forth
    # ACE has 32 bit and 64 bit drivers.
    $Provider = 'Microsoft.ACE.OLEDB.12.0'
}
else {
    # Jet was 32 bit only.
    $Provider = 'Microsoft.Jet.OLEDB.4.0'
}


$cp = @{
    Provider   = $Provider
    DataSource = $TestConfiguration.AccessPresidentPath
}

Describe "Get-AdoColumnMetaData with -datasource to '$($cp.DataSource)'" -Tag $CommandName, DataSource, ADO {

    $Report = Get-AdoColumnMetaData @cp

    It "should return a result set" {
        $Report |
            Should -Not -BeNullOrEmpty
    }
}

# Get-AdoColumnMetaData doesn't support -ConnectionString yet. I will leave this code here, to use as a template in the future.

# Describe "Get-AdoColumnMetaData with -ConnectionString to '$($cp.DataSource)'" -Tag $CommandName, ConnectionString, OLEDB {
#     $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
#     $builder."Data Source" = $cp.DataSource
#     $builder."Provider" = $cp.Provider

#     if ($cp.Credential) {
#         $builder["Trusted_Connection"] = $false
#         $builder["User ID"] = $cp.Credential.UserName
#         $builder["Password"] = $cp.Credential.GetNetworkCredential().Password
#     }
#     else {
#         $builder["Trusted_Connection"] = $true
#     }

#     # this will take a long while to bring back a lot of columns from 'master', so we will just bring back one table's worth of columns
#     $Report = Get-AdoColumnMetaData -TableCatalog 'master' -TableName 'MSreplication_options' -ConnectionString $builder.ConnectionString

#     It "should return a result set" {
#         $Report |
#             Should -Not -BeNullOrEmpty
#     }
# }

# Describe "Get-AdoColumnMetaData with -Connection to '$($cp.DataSource)'" -Tag $CommandName, Connection, OLEDB {
#     $builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
#     $builder."Data Source" = $cp.DataSource
#     $builder."Provider" = $cp.Provider

#     if ($cp.Credential) {
#         $builder["Trusted_Connection"] = $false
#         $builder["User ID"] = $cp.Credential.UserName
#         $builder["Password"] = $cp.Credential.GetNetworkCredential().Password
#     }
#     else {
#         $builder["Trusted_Connection"] = $true
#     }

#     $Cn = Get-OleDbConnection -ConnectionString $builder.ConnectionString
#     It "should return a valid connection" {
#         $cn |
#             Should -Not -BeNullOrEmpty
#     }

#     # this will take a long while to bring back a lot of columns from 'master', so we will just bring back one table's worth of columns
#     $Report = Get-AdoColumnMetaData -TableCatalog 'master' -TableName 'MSreplication_options' -Connection $cn

#     It "should return a result set" {
#         $Report |
#             Should -Not -BeNullOrEmpty
#     }
# }
