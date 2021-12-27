<#
.SYNOPSIS
Splits a large `.ps1` file into seperate `.ps1` files.

.DESCRIPTION
Split a large `.ps1` file into seperate `.ps1` files named like the functions inside the initial `.ps1` file.

.EXAMPLE
PS> .\split-tomodulefunctions.ps1 -Scripts @('large.ps1','another-large.ps1')
Creates seperate scripts for all functions inside `large.ps1` and `another-large.ps1`.

.NOTES
Duplicate functions will overwrite the created files.
#>
function Split-Module {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string[]]
        $Scripts
    )
    foreach ($item in $Scripts) {
        $functions = @()
        $itemObj = Get-Item $item
        $itemDir = Join-Path $itemObj.Directory ".." "Diamant-ReleaseManagement", "functions", ($itemObj.Name -split "-")[0].ToLower()
        # $itemDir = ($itemObj.FullName -replace $itemObj.Extension, "") -replace "private\\", "Diamant-ReleaseManagement\\functions\\"
        if (-not (Test-Path $itemDir)) { New-Item -ItemType Directory $itemDir }
        $contents = get-content $item
        try {
            Push-Location $itemDir
            $functions = $contents | Select-string "function (.*){"
            foreach ($function in $functions) {
                if (Test-Path $name) { Remove-Item $name }
                $name = $function.Matches.Groups[1].Value.Trim()
                $start = $contents.IndexOf($function)
                $end = $contents[$start..$contents.Count].IndexOf("}")
                $functionText = $contents[$start..($start + $end)]
                Set-Content -Path ("{0}.ps1" -f $name) $functionText
            }
        }
        finally {
            Pop-Location
        }
    }
}