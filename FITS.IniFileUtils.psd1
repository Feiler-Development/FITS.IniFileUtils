@{
    RootModule        = 'FITS.IniFileUtils.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '7d2556e7-20ae-4c15-9b0d-a6fee14c03a3'
    Author            = 'Daniel Feiler'
    CompanyName       = 'FITS - Feiler IT Scripting Tools'
    Copyright         = '(c) Daniel Feiler. All rights reserved.'
    Description       = 'Read, write and manipulate INI files. Supports sections, subsections, comments, comma-separated value lists and full roundtrip serialisation.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Get-IniContent'
        'New-IniFileContentString'
        'New-IniFileSection'
        'Remove-IniFileSection'
        'Clear-IniFileSection'
        'Move-IniFileSection'
        'Add-ValueToIniFileContent'
        'Remove-ValueFromIniFileContent'
        'Move-IniFileValues'
    )

    CmdletsToExport   = @()
    AliasesToExport   = @()
    VariablesToExport = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('INI', 'Configuration', 'FileFormat', 'PSEdition_Desktop', 'PSEdition_Core', 'FITS')
            ProjectUri   = 'https://github.com/Feiler-Development/FITS.IniFileUtils'
            LicenseUri   = 'https://github.com/Feiler-Development/FITS.IniFileUtils/blob/main/LICENSE'
            # HelpInfoUri  = 'https://help.feilers.dev/modules/FITS.IniFileUtils/'
            ReleaseNotes = 'Initial release.'
        }
    }
}
