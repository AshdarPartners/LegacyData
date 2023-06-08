<#
THe standard dbase or foxpro connection string looks like this
Provider=Microsoft.ACE.OLEDB.12.0;Data Source=c:\folder;Extended Properties=dBASE IV;User ID=Admin;
#>

try {

    $Query = "select * from customers"

    $DataSource = "C:\Program Files (x86)\Microsoft Visual FoxPro OLE DB Provider\Samples\Northwind"
    if (-not (Test-Path -path $DataSource)) {
        $Message = "Can not find '{0}'" -f @($DataSource)
        Throw $Message
    }

    $OdbcBuilder = New-Object 'System.Data.Odbc.OdbcConnectionStringBuilder'
    # $OdbcBuilder.Driver = "Microsoft.ACE.OLEDB.12.0"
    $OdbcBuilder.Driver = "Microsoft.Jet.OLEDB.4.0"
    $OdbcBuilder.Add("Data Source", $DataSource)
    $OdbcBuilder.Add("Extended Properties", "dBASE IV")
    $OdbcBuilder.Add("User ID", "Admin")
    $OdbcBuilder.Add("Password", "")

    Write-Host $OdbcBuilder.ConnectionString
    Invoke-OdbcQuery -CommandText $Query -ConnectionString $OdbcBuilder.ConnectionString

}

catch {
    Throw
}