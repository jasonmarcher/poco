@{
    ## Module Info
    ModuleVersion      = '1.1.0'
    Description        = "Interactive filtering command based on peco"
    GUID               = 'fcdcab47-0505-4ba8-b845-538effc1d88e'
    # HelpInfoURI        = ''

    ## Module Components
    RootModule         = @("poco.psm1")
    ScriptsToProcess   = @()
    TypesToProcess     = @()
    FormatsToProcess   = @()
    FileList           = @()

    ## Public Interface
    CmdletsToExport    = ''
    FunctionsToExport  = @("Select-Poco")
    VariablesToExport  = @()
    AliasesToExport    = @("poco")
    # DscResourcesToExport = @()
    # DefaultCommandPrefix = ''

    ## Requirements
    # CompatiblePSEditions = @()
    PowerShellVersion      = '3.0'
    # PowerShellHostName     = ''
    # PowerShellHostVersion  = ''
    RequiredModules        = @()
    RequiredAssemblies     = @()
    ProcessorArchitecture  = 'None'
    DotNetFrameworkVersion = '2.0'
    CLRVersion             = '2.0'

    ## Author
    Author             = 'yumura'
    CompanyName        = ''
    Copyright          = ''

    ## Private Data
    PrivateData        = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @("productivity","filter")

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = @"
## 2016-02-19 - Version 1.1.0 - Jason Archer

Features:

- Improved performance and responsiveness
  - Faster code
  - Batch processing of key presses
  - Only filter object list when necessary
  - Filter object list with LINQ

## 2016-02-19 - Version 1.0.0 - yumura

A peco implementation in PowerShell

"@
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
