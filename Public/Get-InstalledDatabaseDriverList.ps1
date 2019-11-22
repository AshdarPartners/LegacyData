function Get-InstalledDatabaseDriverList {
    <# 
    .SYNOPSIS
    Lists the database drivers loaded on this system. 

    .PARAMETER Name
    This is a way to filter for drivers that you are interested in. This follows 'match' semantics', not 'like' or 'equals'.

    .DESCRIPTION
    Lists the database drivers loaded on this system. The Microsoft-provided Get-OdbcDriver only lists ODBC drivers, not OLEDB drivers.

    In a 64 bit environment, 32 and 64-bit drivers are shown.

    In a 32 bit environment, only 32 bit drivers are shown. I run 64 bit 99% of the time, and I am disinclined to find a 32->64 interface, if even there is one.

    In the output, I feel that "Name" ought to be what you use to specify a particular driver in a connection string.

    .PARAMETER Name
    Allows the caller to limit the list of drivers to a 'regex' search string. This uses 'match' semantics, not 'like' or 'equal' semantics.

    .NOTES
    This is a combination of two earlier programs which I found online. One found ODBC drivers and the other found OLEDB drivers.

    I have altered them significantly, but I want to give credit where any might be due. See the link section for URLs.

    .EXAMPLE
    Get-InstalledDatabaseDriverList 
    #>

    param (
        [string] $Name = '.*'
    )


    ### Helper functions ############################################################################

    function Get-OLEDBDriver {
        param ( 
            [string] $Name = '.*'
        )
        <# 
        .SYNOPSIS
        Get a list of OLEDB drivers. This will not include ODBC drivers. Note that there are different lists for 32 bit vs. 64 bit.

        .NOTES
        Based Loosely on this VB script using a commercial ActiveX object to interrogate the registry. 

        .EXAMPLE
        Get-OLEDBDriver.ps1 | Export-CSV -noTypeInformation

        .LINK
        https://gist.github.com/zippy1981/1164836

        .LINK
        http://www.motobit.com/help/regedit/sa117.htm 

        #>

        # First, look at the native environment. This could be 32 bit or 64 bit.
        $OLEDBRegPath = "HKLM:\SOFTWARE\Classes\CLSID"
        Get-ChildItem $OLEDBRegPath | ForEach-Object { 
            $regKey = $_; 
            if ($null -ne $regKey.GetValue('OLEDB_SERVICES') -and $null -ne $regKey.OpenSubKey("OLE DB Provider")) { 
                [string] $Item = $regKey.OpenSubKey("InprocServer32").GetValue("") -replace '%CommonProgramFiles%', 'Program Files\Common Files'
                $Driver = Get-Item $Item
                $DriverName = $regKey.GetValue("")
                if ($DriverName -match $Name) { 
                    $hash = [ordered] @{ 
                        'Name'        = $DriverName 
                        'Type'        = 'OLEDB'
                        'Platform'    = $PlatformStringNative
                        'Description' = $regKey.OpenSubKey("OLE DB Provider").GetValue("")
                        'Version'     = $(if (Test-Path -Path $Driver) {$(((get-item $Driver).versionInfo)).FileVersion} else {''})
                    }
                    New-Object -TypeName:PSObject -Property:$hash 
                }
            } 
        }

        # Second, look for the 32 bit classes at the 'magic' location that 64 bit provides. 
        # If that 'magic' registry location exists, we are running 64 bit.
        $OLEDBRegPath = "HKLM:\SOFTWARE\Wow6432Node\Classes\CLSID"
        if (Test-Path -Path:$OLEDBRegPath -PathType:Container) {
            Get-ChildItem $OLEDBRegPath | ForEach-Object { 
                $regKey = $_; 
                if ($null -ne $regKey.GetValue('OLEDB_SERVICES') -and $null -ne $regKey.OpenSubKey("OLE DB Provider")) { 
                    [string] $file = $regKey.OpenSubKey("InprocServer32").GetValue("") -replace '%CommonProgramFiles%', 'Program Files (x86)\Common Files'
                    $DriverName = $regKey.GetValue("")
                    if ($DriverName -match $Name) { 
                        $hash = [ordered] @{ 
                            'Name'        = $DriverName 
                            'Type'        = 'OLEDB'
                            'Platform'    = $PlatformString32Bit
                            'Description' = $regKey.OpenSubKey("OLE DB Provider").GetValue("")
                            #'Version' = $(((get-item $item.Driver -ErrorAction SilentlyContinue).versionInfo)).FileVersion
                            'Version'     = $(if (Test-Path -Path $file) {$(((get-item $file).versionInfo)).FileVersion} else {''})
                        }
                        if ($hash.Name -match $Name) { 
                            New-Object -TypeName:PSObject -Property:$hash 
                        }
                    } 
                }
            }
        }
    }

    ###############################################################################
    function Get-ODBCDriver {
        <#
        .SYNOPSIS
        Get a list of ODBC drivers. This will not include OLEDB drivers. Note that there are different lists for 32 bit vs. 64 bit.
        Starting with Windows 8.1 and Windows Server 2012 R2, there is a cmdlet version of this command. 

        .EXAMPLE
        Get-ODBCDriver.ps1 | Export-CSV -noTypeInformation

        .LINK
        http://superuser.com/questions/453978/exporting-a-list-of-odbc-datasource-drivers
        #>
        param (
            [string] $Name = '.*'
        )

        # this works just like the first half, but at a slightly different registry location with
        # a slighly different layout

        # first, assume 'native'. We don't care if it's 32 bit or 64 bit.
        $ODBCRegPath = "HKLM:\SOFTWARE\odbc\odbcinst.ini\Odbc drivers"
        $ODBCDriverRegPath = "HKLM:\SOFTWARE\odbc\odbcinst.ini\"
        Get-ItemProperty -Path $ODBCRegPath |
            Get-Member |
            Where-Object {$_.Definition -match "=Installed"} | 
            ForEach-Object { 
            $DriverName = $_.Name
            if ($DriverName -match $Name) {
                $item = Get-ItemProperty -path $($ODBCDriverRegPath + $_.Name) 
                $Hash = [ordered] @{
                    'Name'        = $DriverName 
                    'Type'        = 'ODBC'
                    'Platform'    = $PlatformStringNative
                    'Description' = $_.Name
                    'Version'     = $(if (Test-Path -Path $Item.Driver) {$(((get-item $item.Driver).versionInfo)).FileVersion} else {''})
                }
                New-Object -TypeName:PSObject -Property:$hash 
            }
        } 

        # Second, look for the 32 bit location in the registry. If it's there we are probably in 64 bit mode.
        $ODBCRegPath = "HKLM:\SOFTWARE\Wow6432Node\odbc\odbcinst.ini\Odbc drivers"
        $ODBCDriverRegPath = "HKLM:\SOFTWARE\Wow6432Node\odbc\odbcinst.ini\"
        if (Test-Path -Path:$ODBCRegPath -PathType:Container) {
            Get-ItemProperty -Path $ODBCRegPath |
                Get-Member |
                Where-Object {$_.Definition -match "=Installed"} | 
                ForEach-Object { 
                $DriverName = $_.Name
                if ($DriverName -match $Name) { 
                    $item = Get-ItemProperty -path $($ODBCDriverRegPath + $_.Name) 
                    # On 64 bit systems, the drivers are copied to syswow64 and not to system32, so we need to change the path
                    # This probably isn't the best way to do this, but it should work for the system I run on.
                    $Path = $($item.Driver -replace ':\\WINDOWS\\system32', ':\WINDOWS\SysWOW64')
                    $Driver = if (Test-path $path) {Get-Item -path:$Path} else {''}
                    $Hash = [ordered] @{
                        'Name'        = $DriverName
                        'Type'        = 'ODBC'
                        'Platform'    = $PlatformString32Bit
                        'Description' = $_.Name
                        'Version'     = $((($Driver).versionInfo)).FileVersion
                    }
                    New-Object -TypeName:PSObject -Property:$hash 
                }
            } 
        }
    }

    ###########################################################################
    ### Main body of Get-InstalledDatabaseDriverList starts here ##############
    ###########################################################################

    # some 'nice' strings for display and reuse
    [string] $PlatformString32Bit = '32-bit'
    [string] $PlatformString64Bit = '64-bit'

    # figure out what we are running in, and set the appropriate value for 'native'
    if ([Environment]::Is64BitProcess) {
        $PlatformStringNative = $PlatformString64Bit
    }
    else {
        $PlatformStringNative = $PlatformString32Bit
    }

    # call the two helper functions.
    Get-ODBCDriver -Name:$Name
    Get-OLEDBDriver -Name:$Name

}


