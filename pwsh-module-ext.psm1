$fns = @(Get-ChildItem (Join-Path $PSScriptRoot "functions") -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue)
$fns | ForEach-Object { $fn = $_; try { Write-Verbose "Importing $($fn.FullName)"; . $fn.FullName } catch { Write-Error "Failed to import function $($fn.FullName): $_" } }
