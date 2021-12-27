@{
    ModuleToProcess      = 'pwsh-module-ext.psm1'
    ModuleVersion        = '0.0.1'
    CompatiblePSEditions = @('Core')
    GUID                 = '02bc1650-e68a-45f5-98aa-64703ad31ece'
    Author               = 'Ser-Drephs and contributors'
    CompanyName          = '-'
    Copyright            = '(c) Ser-Drephs and contributors.'
    Description          = 'Provides convenience functions for creating and building complete powershell modules.'
    PowerShellVersion    = '7.0.0'
    FunctionsToExport    = @('Compress-Module','New-ModuleStructure')
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags                     = @('pwsh module')
            LicenseUri               = 'https://github.com/ser-drephs/pwsh-module-pack/blob/main/LICENSE'
            ProjectUri               = 'https://github.com/ser-drephs/pwsh-module-pack'
            ReleaseNotes             = 'https://github.com/ser-drephs/pwsh-module-pack/blob/main/CHANGELOG.md'
            RequireLicenseAcceptance = $false
        }
    }
}
