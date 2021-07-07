BeforeAll {
    $ModuleManifestName = "pwsh-module-ext.psd1"
    $ModuleManifestFile = Join-Path ".." $ModuleManifestName
    $Mocks = Join-path $PSScriptRoot "mock"
    # $TestModuleManifestPath = Join-Path $PSScriptRoot $ModuleManifestName
    Import-Module $ModuleManifestFile -Force -ErrorAction Stop
    if (-not (Test-Path $TestDrive)) { New-Item $TestDrive -ItemType Directory -Force }
}
Describe 'function tests' {
    Context 'compress-module' {
        Context 'error checks' {
            Context 'files and folder structure' {
                BeforeAll {
                    Push-Location $TestDrive
                }
                AfterAll {
                    Pop-Location
                }
                It 'should throw exception because *.psm1 file was not found' {
                    { Compress-Module } | Should -Throw "*does not contain a module manifest." -ErrorAction Continue
                }
                It 'should throw exception because neither functions nor public/private folder were found' {
                    New-Item "sample.psd1"
                    { Compress-Module } | Should -Throw "*does not contain 'functions' or 'public'/'private' folder." -ErrorAction Continue
                }
            }
            Context 'function/s folder' {
                BeforeAll {
                    Push-Location $TestDrive
                    New-Item "sample.psd1"
                }
                AfterAll {
                    Pop-Location
                }
                It 'should throw exception because "function" folder does not contains any scripts' {
                    New-Item "function" -ItemType Directory
                    { Compress-Module } | Should -Throw "No scripts found inside *. Make sure the scripts are located either inside a 'functions' or 'public'/'private' folder." -ErrorAction Continue
                    Remove-Item "function"
                }
                It 'should throw exception because "functions" folder does not contains any scripts' {
                    New-Item "functions" -ItemType Directory
                    { Compress-Module } | Should -Throw "No scripts found inside *. Make sure the scripts are located either inside a 'functions' or 'public'/'private' folder." -ErrorAction Continue
                    Remove-Item "functions"
                }
            }
            Context 'public/private folder' {
                BeforeAll {
                    Push-Location $TestDrive
                    New-Item "sample.psd1"
                }
                AfterAll {
                    Pop-Location
                }
                It 'should throw exception because only "public" exists' {
                    New-Item "public" -ItemType Directory
                    { Compress-Module } | Should -Throw "*does not contain 'functions' or 'public'/'private' folder." -ErrorAction Continue
                    Remove-Item "public"
                }
                It 'should throw exception because only "private" exists' {
                    New-Item "private" -ItemType Directory
                    { Compress-Module } | Should -Throw "*does not contain 'functions' or 'public'/'private' folder." -ErrorAction Continue
                    Remove-Item "private"
                }
                It 'should throw exception because "public"/"private" folder does not contains any scripts' {
                    New-Item "public" -ItemType Directory
                    New-Item "private" -ItemType Directory
                    { Compress-Module } | Should -Throw "No scripts found inside *. Make sure the scripts are located either inside a 'functions' or 'public'/'private' folder." -ErrorAction Continue
                    Remove-Item "public"
                    Remove-Item "private"
                }
            }
        }
        Context 'function folder' {
            BeforeAll {
                Copy-Item (Join-Path $Mocks "function-compression/*") -Destination "$TestDrive/" -Recurse
                Push-Location $TestDrive
                Get-ChildItem -File -Path "function" -Recurse | Should -HaveCount 3
                Compress-Module
            }
            AfterAll {
                Pop-Location
            }
            It 'should not recreate functions folder structure' {
                Get-ChildItem -Path "Cfunction-compression" -Recurse -Directory | Should -HaveCount 0
            }
            It 'should read module to process "sample_fns.psm1" from manifest and create create a module script file' {
                Test-Path "Cfunction-compression/sample_fns.psm1" | Should -BeTrue
            }
            Context 'script module file contents from functions folder' {
                BeforeAll {
                    $_content = Get-Content "Cfunction-compression/sample_fns.psm1"
                }
                It 'should include scripts in functions folder' {
                    $_content | Should -Contain "function Get-Sample {"
                    $_content | Should -Contain "function Start-Sample {"
                }
                It 'should include scripts in functions sub folders' {
                    $_content | Should -Contain "function Get-NestedSample {"
                }
            }
        }
        Context 'public and private folder' {
            BeforeAll {
                Copy-Item (Join-Path $Mocks "public-private-functions/*") -Destination "$TestDrive/" -Recurse
                Push-Location $TestDrive
                Get-ChildItem -File -Path "public" -Recurse | Should -HaveCount 2
                Get-ChildItem -File -Path "private" -Recurse | Should -HaveCount 2
                Compress-Module
            }
            AfterAll {
                Pop-Location
            }
            It 'should not recreate public/private folder structure' {
                Get-ChildItem -Path "Cpublic-private-functions" -Recurse -Directory | Should -HaveCount 0
            }
            It 'should read moudle to process "sample_public.psm1" from manifest and create create a module script file' {
                Test-Path "Cpublic-private-functions/sample_public.psm1" | Should -BeTrue
            }
            Context 'script module file contents from public/private folders' {
                BeforeAll {
                    $_content = Get-Content "Cpublic-private-functions/sample_public.psm1"
                }
                It 'should include scripts in public/private folder' {
                    $_content | Should -Contain "function Get-Sample {"
                    $_content | Should -Contain "function Start-Sample {"
                    $_content | Should -Contain "function Get-PrivateSample {"
                }
                It 'should include scripts in public/private sub folders' {
                    $_content | Should -Contain "function Get-PrivateNestedSample {"
                }
            }
        }
        Context 'exclude tests folder' {
            BeforeAll {
                Copy-Item (Join-Path $Mocks "function-compression-no-test/*") -Destination "$TestDrive/" -Recurse
                Push-Location $TestDrive
                Get-ChildItem -File -Path "functions" -Recurse | Should -HaveCount 3
                Get-ChildItem -File -Path "tests" -Recurse | Should -HaveCount 1
                Compress-Module
            }
            AfterAll {
                Pop-Location
            }
            It 'should not create tests folder' {
                Get-ChildItem -Path "function-compression-no-test" -Recurse -Directory | Should -HaveCount 0
            }
            It 'should read module to process "sample_test.psm1" from manifest and create create a module script file' {
                Test-Path "Cfunction-compression-no-test/sample_test.psm1" | Should -BeTrue
            }
            Context 'script module file contents from functions folder without tests' {
                BeforeAll {
                    $_content = Get-Content "Cfunction-compression-no-test/sample_test.psm1"
                }
                It 'should not contain *.Tests code' {
                    $_content | Should -Not -Contain "Describe `"DescribeName`" {"
                }
            }
        }
    }
    Context 'new-modulestructure' {
        Context 'parameter validation' {
            It 'should be one of "None;Access;Simple" with parameter names' {
                { New-ModuleStructure -Name "name" -FunctionSeparation "Just" } | Should -Throw "*The argument `"Just`" does not belong to the set `"None;Access;Simple;`"*"
            }
            It 'should be one of "None;Access;Simple"' {
                { New-ModuleStructure "name" "Just" } | Should -Throw "*The argument `"Just`" does not belong to the set `"None;Access;Simple;`"*"
            }
        }
        Context 'default' {
            BeforeAll {
                Push-Location $TestDrive
                New-ModuleStructure "SimpleModule"
            }
            AfterAll{
                Pop-Location
            }
            It 'should create default module structure (simple) without explicit -FunctionSeparation parameter'{
                Test-Path "SimpleModule.psm1" | Should -BeTrue -ErrorAction Continue
                Test-Path "SimpleModule.psd1" | Should -BeTrue -ErrorAction Continue
                Test-Path "functions" | Should -BeTrue -ErrorAction Continue
                Test-Path "tests" | Should -BeTrue -ErrorAction Continue
                Test-Path "readme.md" | Should -BeTrue -ErrorAction Continue
            }
            It 'should not create other folders using default'{
                Test-Path "private" | Should -BeFalse -ErrorAction Continue
                Test-Path "public" | Should -BeFalse -ErrorAction Continue
            }
        }
        Context 'simple' {
            BeforeAll {
                Push-Location $TestDrive
                New-ModuleStructure "SimpleModule" -FunctionSeparation "simple"
            }
            AfterAll{
                Pop-Location
            }
            It 'should create simple module structure'{
                Test-Path "SimpleModule.psm1" | Should -BeTrue -ErrorAction Continue
                Test-Path "SimpleModule.psd1" | Should -BeTrue -ErrorAction Continue
                Test-Path "functions" | Should -BeTrue -ErrorAction Continue
                Test-Path "tests" | Should -BeTrue -ErrorAction Continue
                Test-Path "readme.md" | Should -BeTrue -ErrorAction Continue
            }
            It 'should not create other folders using simple'{
                Test-Path "private" | Should -BeFalse -ErrorAction Continue
                Test-Path "public" | Should -BeFalse -ErrorAction Continue
            }
        }
        Context 'access' {
            BeforeAll {
                Push-Location $TestDrive
                New-ModuleStructure "SimpleModule" -FunctionSeparation "access"
            }
            AfterAll{
                Pop-Location
            }
            It 'should create access module structure'{
                Test-Path "SimpleModule.psm1" | Should -BeTrue -ErrorAction Continue
                Test-Path "SimpleModule.psd1" | Should -BeTrue -ErrorAction Continue
                Test-Path "private" | Should -BeTrue -ErrorAction Continue
                Test-Path "public" | Should -BeTrue -ErrorAction Continue
                Test-Path "tests" | Should -BeTrue -ErrorAction Continue
                Test-Path "readme.md" | Should -BeTrue -ErrorAction Continue
            }

        }
        Context 'none' {
            BeforeAll {
                Push-Location $TestDrive
                New-ModuleStructure "SimpleModule" -FunctionSeparation "none"
            }
            AfterAll{
                Pop-Location
            }
            It 'should create no module structure'{
                Test-Path "SimpleModule.psm1" | Should -BeTrue -ErrorAction Continue
                Test-Path "SimpleModule.psd1" | Should -BeTrue -ErrorAction Continue
                Test-Path "tests" | Should -BeTrue -ErrorAction Continue
            }
            It 'should not create other folders using none'{
                Test-Path "readme.md" | Should -BeFalse -ErrorAction Continue
                Test-Path "private" | Should -BeFalse -ErrorAction Continue
                Test-Path "public" | Should -BeFalse -ErrorAction Continue
                Test-Path "functions" | Should -BeFalse -ErrorAction Continue
            }
        }
    }
}