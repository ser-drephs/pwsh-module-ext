function New-ModuleStructure {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)][string]$Name,
        [Parameter(Position = 1)][ValidateSet("None", "Access", "Simple", "")][string]$FunctionSeparation

    )
    $_path = Get-Location
    if (Test-Path "$_path/*.psd1") { throw "$_path already contains a module manifest. A new module cannot be created here." }
    if ($Name -notlike "*.psd1") { $Name = "$Name.psd1" }
    $_rootModule = "$($Name.Split(".")[0]).psm1"
    switch ($FunctionSeparation) {
        "None" {
            New-ModuleManifest $Name -RootModule $_rootModule
            @(
                "# Start Coding your functions here...",
                "# Remember to add to be exposed functions to the ``-Functions`` parameter of ``Export-ModuleMember``.",
                "# Remember to add to be exposed aliases to the ``Alias`` parameter of ``Export-ModuleMember``.",
                "Export-ModuleMember -Function * -Alias *"
             ) | Out-File $_rootModule
        }
        "Access" {
            New-ModuleManifest $Name -RootModule $_rootModule -FunctionsToExport "*" -AliasesToExport "*"
            New-Item "public" -ItemType Directory
            New-Item "private" -ItemType Directory
            @(
                "`$private = @(Get-ChildItem (Join-Path `$PSScriptRoot `"private`") -Recurse -Filter `"*.ps1`" -ErrorAction SilentlyContinue)"
                "`$private | ForEach-Object { `$fn = `$_; try { Write-Verbose `"Importing `$(`$fn.FullName)`"; . `$fn.FullName } catch { Write-Error `"Failed to import function `$(`$fn.FullName): `$_`" } }"
                "`$public = @(Get-ChildItem (Join-Path `$PSScriptRoot `"public`") -Recurse -Filter `"*.ps1`" -ErrorAction SilentlyContinue)"
                "`$public | ForEach-Object { `$fn = `$_; try { Write-Verbose `"Importing `$(`$fn.FullName)`"; . `$fn.FullName; } catch { Write-Error `"Failed to import function `$(`$fn.FullName): `$_`" } }"
                "`$fns = `$public | Select-Object -ExpandProperty BaseName"
                "Export-ModuleMember -Function `$fns -Alias *"
            ) | Out-File $_rootModule
            @(
                "## Getting started",
                "Write your functions inside the desired 'visibility' folder.",
                "Only function where the script name matches the function name will be exposed."
                "For Example: ``New-MyFunction.ps1`` contains two functions ``New-MyFunction`` and ``Get-OtherThings``. Only ``New-MyFunction`` will be visible after ``Import-Module``."
                "Note: All aliases are exposed!"
            ) | Out-File "Readme.md"
        }
        Default {
            # FunctionSeparation = Simple is default
            New-ModuleManifest $Name -RootModule $_rootModule
            New-Item "functions" -ItemType Directory
            @(
                "`$fns = @(Get-ChildItem (Join-Path `$PSScriptRoot `"functions`") -Recurse -Filter `"*.ps1`" -ErrorAction SilentlyContinue)",
                "`$fns | ForEach-Object { `$fn = `$_; try { Write-Verbose `"Importing `$(`$fn.FullName)`"; . `$fn.FullName } catch { Write-Error `"Failed to import function `$(`$fn.FullName): `$_"
            ) | Out-File $_rootModule
            @(
                "## Getting started",
                "Write your functions in scripts inside the ``functions` folder.",
                "Add to be exposed functions to ``FunctionsToExport`` and aliases to ``AliasesToExport`` arrays inside ``.psd1`` file manually."
            ) | Out-File "Readme.md"
        }
    }
    New-Item "tests" -ItemType Directory
}