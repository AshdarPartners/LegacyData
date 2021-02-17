<#
.SYNOPSIS
Pester test to verify the content of the manifest and the documentation of each functions.

.DESCRIPTION
Pester test to verify the content of the manifest and the documentation of each functions.

.NOTES
Module and manifest tests are essentially the same from project to project, so 
I am using this fellow's implementation, then tweaking it as required. Mainly, that 
means adjusting paths to me my file structure. 

.LINK
https://github.com/lazywinadmin/AdsiPS/blob/master/Tests/ADSIPs.Integration.Tests.ps1
#>
[CmdletBinding()]
param (
    $ModuleName = "LegacyData"
)

# Make sure one or multiple versions of the module are not loaded
Get-Module -Name $ModuleName | Remove-Module


# Find the Manifest file
#$ManifestFile = "$(Split-path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))\$ModuleName\$ModuleName.psd1"
$Path = $(Split-Path -Parent -path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))
$ManifestFile = Join-Path -Path $Path -ChildPath "$ModuleName.psd1"

# Import the module and store the information about the module
$ModuleInformation = Import-Module -Name $ManifestFile -PassThru

# Get the functions present in the Manifest
$ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.name

# Get the functions present in the Public folder
#$PS1Functions = Get-ChildItem -path "$(Split-path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))\$ModuleName\public\*.ps1"

$PS1FunctionFiles = Join-Path -Path $Path -ChildPath "public"
# write-host $PS1FunctionFiles
$PS1FunctionFiles = Join-Path -Path $PS1FunctionFiles -ChildPath "*.ps1"
$PS1Functions = Get-ChildItem -path "$PS1FunctionFiles"



Describe "$ModuleName Module - Testing Manifest File (.psd1)" -Tag 'Integration' {

    Context 'Module Version' { 'Loaded Version vs Get-Command return for the module' }
    Context 'Manifest' {
        It "has a valid manifest" {
            { Test-ModuleManifest -Path $ManifestFile -ErrorAction Stop -WarningAction SilentlyContinue | Should Not Throw }
        }
        
        It 'Should contain RootModule' { $ModuleInformation.RootModule | Should not BeNullOrEmpty }
        It 'Should contain Author' { $ModuleInformation.Author | Should not BeNullOrEmpty }
        It 'Should contain Company Name' { $ModuleInformation.CompanyName | Should not BeNullOrEmpty }
        It 'Should contain Description' { $ModuleInformation.Description | Should not BeNullOrEmpty }
        It 'Should contain Copyright' { $ModuleInformation.Copyright | Should not BeNullOrEmpty }
        It 'Should contain License' { $ModuleInformation.LicenseURI | Should not BeNullOrEmpty }
        It 'Should contain a Project Link' { $ModuleInformation.ProjectURI | Should not BeNullOrEmpty }
        It 'Should contain a Tags (For the PSGallery)' { $ModuleInformation.Tags.count | Should not BeNullOrEmpty }

        It 'Should have equal number of Function Exported and the PS1 files found' {
            $ExportedFunctions.count -eq $PS1Functions.count | Should BeGreaterthan 0 }
        It "Compare the missing function" {
            if (-not($ExportedFunctions.count -eq $PS1Functions.count)) {
                $Compare = Compare-Object -ReferenceObject $ExportedFunctions -DifferenceObject $PS1Functions.basename
                $Compare.inputobject -join ',' |
                    Should BeNullOrEmpty
            }
        }
    }
}


# Testing the Module
Describe "$ModuleName Module - HELP" -Tags 'Module', 'Integration' {
    #$Commands = (get-command -Module ADSIPS).Name

    FOREACH ($c in $ExportedFunctions) {
        $Help = Get-Help -Name $c -Full
        # $Notes = ($Help.alertSet.alert.text -split '\n')
        $FunctionContent = Get-Content function:$c
        $AST = [System.Management.Automation.Language.Parser]::ParseInput($FunctionContent, [ref]$null, [ref]$null)

        Context "$c - Help" {

            It "Synopsis" { $help.Synopsis | Should not BeNullOrEmpty }
            It "Description" { $help.Description | Should not BeNullOrEmpty }
            #It "Notes - Author" {$Notes[0].trim()| Should Be "Francois-Xavier Cat"}
            #It "Notes - Site" {$Notes[1].trim()| Should Be "Lazywinadmin.com"}
            #It "Notes - Twitter" {$Notes[2].trim()| Should Be "@lazywinadm"}
            #It "Notes - Github" {$Notes[3].trim() | Should Be "github.com/lazywinadmin"}
            #It "Notes - Github Project" {$Notes -contains "$GithubRepository$ModuleName" | Should Be $true}

            # Get the parameters declared in the Comment Based Help
            #  minus the RiskMitigationParameters
            $RiskMitigationParameters = 'Whatif', 'Confirm'
            $HelpParameters = $help.parameters.parameter | Where-Object name -NotIn $RiskMitigationParameters

            # Parameter Count VS AST Parameter
            $ASTParameters = $ast.ParamBlock.Parameters.Name.variablepath.userpath
            It "Parameter - Compare Count Help/AST" {
                $HelpParameters.name.count -eq $ASTParameters.count | Should Be $true }

            # Parameters Description
            # This breaks if the function has no parameters. My (@dstrait) fix is below.
            #$HelpParameters| ForEach-Object {
            #    It "Parameter $($_.Name) - Should contain description"{
            #        $_.description | Should not BeNullOrEmpty
            #    }
            #}
            ForEach ($HelpParameter in $HelpParameters) {
                It "Parameter $($HelpParameter.Name) - Should contain description" {
                    $HelpParameter.description | Should not BeNullOrEmpty
                }
            }

            # Parameters separated by a space
            # FIXME: This does not find the last parameter in the functions' parameter list 
            # becuase it looks for a trailing ','. 
            $ParamText = $ast.ParamBlock.extent.text -split '\r\n' # split on return
            $ParamText = $ParamText.trim()
            $ParamTextSeparator = $ParamText | Select-String ',$' #line that finish by a ','

            if ($ParamTextSeparator) {
                Foreach ($ParamLine in $ParamTextSeparator) {
                    It "Parameter - Variable and data type separated by space (Line $ParamLine)" {
                        $ParamLine -match '\s+' | Should Be $true
                        $ParamLine -match '^$|\s+' | Should Be $true
                    }
                }
            }
                

            # Examples
            It "Example - Count should be greater than 0" {
                $Help.examples.example.code.count | Should BeGreaterthan 0
                $Help.examples | Should not BeNullOrEmpty
            }

            # Validate Help start at the beginning of the line
            #(((get-content .\public\Get-ADSIForestDomain.ps1)) |select-string '.Synopsis') -match "^$($_.pattern)"
            #it "Help - Starts at the beginning of the line"{
            #    $Pattern = "\.Synopsis"
            #    ($FunctionContent -split '\r\n'|select-string $Pattern).line -match "^$Pattern" | Should Be $true
            #}

                
            
            <#
			    # Testing the Examples
			    $help.examples.example[0].code
			    $help.examples.example[0].introduction
			    $help.examples.example[0].remarks
			    $help.examples.example[0].title
                $help.examples.example[0].code
                $help.examples.example[0].introduction
                $help.examples.example[0].remarks
                $help.examples.example[0].title
                $help.parameters.parameter[0].defaultValue
                $help.parameters.parameter[0].description
                $help.Name
                $help.ModuleName
            
                $help.description
                $help.syntax
                $help.'xmlns:command'
                # AST
                # Parameters
                $ast = [System.Management.Automation.Language.Parser]::ParseInput((Get-Content function:Get-ADSIUser), [ref]$null, [ref]$null)
                $ast.ParamBlock.Parameters.Name.variablepath.userpath #without the S
                $ast.ParamBlock.Parameters.Name.Extent.Text # with the $
                # CmdletBinding
                $ast.ParamBlock.attributes.typename.fullname
                # check each help keyword for indent
                # check space between help keyword
                # check no text pass the 80 characters 
                # check PARAM is upper case
                # Check help keywords are upper.
                # check you have outputs
                # check you have [outputType()]
                # check for error handling
                # check for some verbose
                # check does not use accelerator in PARAM()
                # parameters in AST and Help are matching (same name)
                # PARAM() no type defined on a property
		    #>
        }
    }
}