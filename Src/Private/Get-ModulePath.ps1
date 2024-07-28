<#
.NOTES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Module: PSPassPhrase
Function: Get-ModulePath (PRIVATE)
Author:	Martin Cooper (@mc1903)
Date: 18-07-2024
GitHub Repo: https://github.com/mc1903/PSPassPhrase
Version: 1.0.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#>

Function Get-ModulePath {

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $false)]
        [string]$ModuleName = $MyInvocation.MyCommand.Module.Name
    )

    $module = Get-Module -Name $ModuleName -ListAvailable | Select-Object -First 1
    return $module.ModuleBase
}

