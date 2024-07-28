<#
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Module: PSPassPhrase
Function: Dot-Source the Public & Private .ps1 Function Files
Author:	Martin Cooper (@mc1903)
Date: 18-07-2024
GitHub Repo: https://github.com/mc1903/PSPassPhrase
Version: 1.0.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#>

If ($MyInvocation.Line -Match "-Verbose") {
    $VerbosePreference = "Continue"
}

$Public = @(Get-ChildItem -Path $PSScriptRoot\Src\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Src\Private\*.ps1 -ErrorAction SilentlyContinue)

ForEach ($Module in @($Public + $Private)) {
    Try {
        . $Module.FullName
    } Catch {
        Write-Error -Message `"Failed to import function $($Module.FullName): $_`"
    }
}

Export-ModuleMember -Function $Public.BaseName
Export-ModuleMember -Function $Private.BaseName

$VerbosePreference = "SilentlyContinue"

