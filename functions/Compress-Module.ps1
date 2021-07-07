function Compress-Module {
    [CmdletBinding()]
    param (
        [Parameter()][string]$ParameterName
    )
    $_path = Get-Location
    # error checks
    if (-not (Test-Path "$_path/*.psd1")) { throw "$_path does not contain a module manifest." }
    if (-not (Test-Path "$_path/function*") -and -not ((Test-Path "$_path/private") -and (Test-Path "$_path/public"))) { throw "$_path does not contain 'functions' or 'public'/'private' folder." }
    # get all scripts
    $_scripts = Get-ChildItem function*/*.ps1, public/*.ps1, private/*.ps1 -Recurse -Exclude *.Tests.ps1 -ErrorAction SilentlyContinue
    if ($_scripts.Count -eq 0) { throw "No scripts found inside $_path. Make sure the scripts are located either inside a 'functions' or 'public'/'private' folder." }
    # get module manifest contents
    $_modulename = Get-Item "*.psd1"
    $_manifest = Import-PowerShellDataFile $_modulename.FullName
    $_rootModule = if ( $_manifest.ModuleToProcess ) { $_manifest.ModuleToProcess } else { $_manifest.RootModule }
    # concat contents
    $_contents = @()
    $_scripts | ForEach-Object { $_contents += Get-Content $_.FullName -Raw }
    # create new folder structure
    New-Item "C$($_modulename.BaseName)" -ItemType Directory
    # Copy module manifest
    Copy-Item "*.psd1" -Destination "C$($_modulename.BaseName)" -ErrorAction SilentlyContinue
    # Create module script module
    $_contents | Out-File (Join-Path "C$($_modulename.BaseName)" $_rootModule) -Force
}