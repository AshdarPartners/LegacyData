$script:PSModuleRoot = $PSScriptRoot
foreach ($function in (Get-ChildItem "$script:PSModuleRoot\Public\*.ps1")) {
    . $function.FullName
}
