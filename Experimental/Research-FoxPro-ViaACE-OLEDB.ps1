
try {

    $Query = "select * from customers"

    $DataSource = "C:\Program Files (x86)\Microsoft Visual FoxPro OLE DB Provider\Samples\Northwind\"
    if (-not (Test-Path -path $DataSource)) {
        $Message = "Can not find '{0}'" -f @($DataSource)
        Throw $Message
    }

    $OleDbBuilder = New-Object 'System.Data.OleDb.OleDbConnectionStringBuilder'
    # $OleDbBuilder.Provider = "Microsoft.ACE.OLEDB.12.0"
    $OleDbBuilder.Provider = "Microsoft.Jet.OLEDB.4.0"
    $OleDbBuilder.Add("Data Source", $DataSource)
    $OleDbBuilder.Add("Extended Properties", "dBASE IV")
    $OleDbBuilder.Add("User ID", "Admin")
    $OleDbBuilder.Add("Password", "")

    Write-Host $OleDbBuilder.ConnectionString

    Invoke-OleDbQuery -ConnectionSTring $OleDbBuilder.ConnectionString -query $Query
    }

catch {
    Throw
}