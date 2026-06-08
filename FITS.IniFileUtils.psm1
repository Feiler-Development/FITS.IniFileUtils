# Load localized strings — automatic fallback to en-US if culture file is missing
Import-LocalizedData -BindingVariable script:Strings -FileName FITS.IniFileUtils -ErrorAction SilentlyContinue
if (-not $script:Strings) {
    Import-LocalizedData -BindingVariable script:Strings -FileName FITS.IniFileUtils `
                         -UICulture 'en-US' -ErrorAction SilentlyContinue
}

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Write-Verbose $script:Strings.ModuleRemoved
    Remove-Variable -Name Strings -Scope Script -ErrorAction SilentlyContinue
}

# ─────────────────────────────────────────────────────────────────────────────
#  Get-IniContent
# ─────────────────────────────────────────────────────────────────────────────
function Get-IniContent {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string] $FilePath
    )

    # Case-SENSITIVE keys — intentional: INI files may have keys that differ
    # only in case (e.g. some Exchange / application config files).
    $ini          = New-Object System.Collections.Specialized.OrderedDictionary
    $section      = '_global'
    $commentCount = 0
    $ini[$section] = New-Object System.Collections.Specialized.OrderedDictionary

    switch -regex -file $FilePath {
        '^\[(.+)\]' {
            $section       = $matches[1]
            $commentCount  = 0
            $ini[$section] = New-Object System.Collections.Specialized.OrderedDictionary
            Write-Verbose ($script:Strings.VerboseSection -f $section)
        }
        '^(;.*)$' {
            $commentCount++
            $ini[$section]["Comment$commentCount"] = $matches[1]
            Write-Verbose ($script:Strings.VerboseComment -f $matches[1])
        }
        '(.+?)\s*=(.*)' {
            $name, $value    = $matches[1..2]
            $ini[$section][$name] = $value.Trim()
            Write-Verbose ($script:Strings.VerboseKey -f $name, $value.Trim())
        }
    }

    if ($ini['_global'].Count -eq 0) { $ini.Remove('_global') }
    return $ini
}

# ─────────────────────────────────────────────────────────────────────────────
#  New-IniFileContentString
# ─────────────────────────────────────────────────────────────────────────────
function New-IniFileContentString {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent
    )

    $sb           = New-Object System.Text.StringBuilder
    $firstSection = $true

    foreach ($section in $IniFileContent.Keys) {
        if (-not $firstSection) { $sb.AppendLine('') | Out-Null }
        $sb.AppendLine("[$section]") | Out-Null

        foreach ($key in $IniFileContent[$section].Keys) {
            if ($key -match '^Comment\d+$') {
                $sb.AppendLine($IniFileContent[$section][$key]) | Out-Null
            }
            else {
                $sb.AppendLine("$key = $($IniFileContent[$section][$key])") | Out-Null
            }
        }
        $firstSection = $false
    }
    return $sb.ToString()
}

# ─────────────────────────────────────────────────────────────────────────────
#  New-IniFileSection
# ─────────────────────────────────────────────────────────────────────────────
function New-IniFileSection {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding(DefaultParameterSetName = 'Append')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $SectionName,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent,

        [Parameter(ParameterSetName = 'InsertAfter')]
        [string] $InsertAfter,

        [Parameter(ParameterSetName = 'InsertBefore')]
        [string] $InsertBefore
    )

    if ($IniFileContent.Contains($SectionName)) {
        Write-Warning ($script:Strings.SectionAlreadyExists -f $SectionName)
        return
    }

    $newSection = New-Object System.Collections.Specialized.OrderedDictionary

    switch ($PSCmdlet.ParameterSetName) {
        'InsertAfter' {
            if (-not $IniFileContent.Contains($InsertAfter)) {
                Write-Warning ($script:Strings.RefSectionNotFound -f $InsertAfter)
                $IniFileContent[$SectionName] = $newSection
                return
            }
            $index = $IniFileContent.Keys.IndexOf($InsertAfter) + 1
            $IniFileContent.Insert($index, $SectionName, $newSection)
            Write-Verbose ($script:Strings.SectionInsertedAfter -f $SectionName, $InsertAfter, $index)
        }
        'InsertBefore' {
            if (-not $IniFileContent.Contains($InsertBefore)) {
                Write-Warning ($script:Strings.RefSectionNotFound -f $InsertBefore)
                $IniFileContent[$SectionName] = $newSection
                return
            }
            $index = $IniFileContent.Keys.IndexOf($InsertBefore)
            $IniFileContent.Insert($index, $SectionName, $newSection)
            Write-Verbose ($script:Strings.SectionInsertedBefore -f $SectionName, $InsertBefore, $index)
        }
        default {
            $IniFileContent[$SectionName] = $newSection
            Write-Verbose ($script:Strings.SectionAppended -f $SectionName)
        }
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  Add-ValueToIniFileContent
# ─────────────────────────────────────────────────────────────────────────────
function Add-ValueToIniFileContent {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $SectionName,

        [Parameter(Mandatory)]
        [string[]] $ValueName,

        [Parameter(Mandatory)]
        [string] $Value,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent,

        [switch] $AppendValue
    )

    if (-not $IniFileContent.Contains($SectionName)) {
        Write-Warning ($script:Strings.SectionNotFound -f $SectionName)
        return
    }

    $valueList = New-Object System.Collections.Generic.List``1[System.String]

    foreach ($keyName in $ValueName) {
        if ($IniFileContent[$SectionName].Contains($keyName) -and $AppendValue) {
            $existing = $IniFileContent[$SectionName][$keyName]
            if (-not [string]::IsNullOrWhiteSpace($existing)) {
                $valueList.AddRange([string[]]($existing -split ','))
            }
        }
        $valueList.Add($Value)
        $IniFileContent[$SectionName][$keyName] = $valueList -join ','
        $valueList.Clear()
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  Remove-ValueFromIniFileContent
# ─────────────────────────────────────────────────────────────────────────────
function Remove-ValueFromIniFileContent {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $SectionName,

        [Parameter(Mandatory, ParameterSetName = 'SpecificValue')]
        [Parameter(Mandatory, ParameterSetName = 'ValueExpression')]
        [string[]] $ValueName,

        [Parameter(Mandatory, ParameterSetName = 'SpecificValue')]
        [Parameter(Mandatory, ParameterSetName = 'ValueForAllKeys')]
        [string] $Value,

        [Parameter(Mandatory, ParameterSetName = 'ValueExpression')]
        [Parameter(Mandatory, ParameterSetName = 'ValueExpressionForAllKeys')]
        [string] $ValueRegEx,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent,

        [switch] $RemoveSettingIfEmpty,

        [Parameter(Mandatory, ParameterSetName = 'ValueExpressionForAllKeys')]
        [Parameter(Mandatory, ParameterSetName = 'ValueForAllKeys')]
        [switch] $RemoveValueFromAllKeys
    )

    if (-not $IniFileContent.Contains($SectionName)) {
        Write-Warning ($script:Strings.SectionNotFound -f $SectionName)
        return
    }

    $valueList  = New-Object System.Collections.Generic.List``1[System.String]
    $targetKeys = if ($PSCmdlet.ParameterSetName -match 'ForAllKeys') {
        [string[]]($IniFileContent[$SectionName].Keys)
    } else { $ValueName }

    $filter = if ($PSCmdlet.ParameterSetName -match 'ValueExpression') {
        [scriptblock]::Create("`$args -imatch '$ValueRegEx'")
    } else {
        [scriptblock]::Create("`$args -ieq `"$Value`"")
    }

    foreach ($keyName in $targetKeys) {
        if (-not $IniFileContent[$SectionName].Contains($keyName)) { continue }

        $existing = $IniFileContent[$SectionName][$keyName]
        if (-not [string]::IsNullOrWhiteSpace($existing)) {
            $valueList.AddRange([string[]]($existing -split ','))
        }

        $filtered = @($valueList | Where-Object { -not (& $filter $_) })
        $valueList.Clear()
        if ($filtered.Count -gt 0) { $valueList.AddRange([string[]]$filtered) }

        if ($valueList.Count -eq 0 -and $RemoveSettingIfEmpty) {
            $IniFileContent[$SectionName].Remove($keyName)
        } else {
            $IniFileContent[$SectionName][$keyName] = $valueList -join ','
        }
        $valueList.Clear()
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  Remove-IniFileSection
# ─────────────────────────────────────────────────────────────────────────────
function Remove-IniFileSection {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $SectionName,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent,

        [switch] $RemoveAllValues
    )

    if (-not $IniFileContent.Contains($SectionName)) {
        Write-Warning ($script:Strings.SectionNotFound -f $SectionName)
        return
    }

    $entryCount = $IniFileContent[$SectionName].Count

    if ($entryCount -gt 0 -and -not $RemoveAllValues) {
        Write-Warning ($script:Strings.SectionNotEmpty -f $SectionName, $entryCount)
        return
    }

    if ($PSCmdlet.ShouldProcess($SectionName, $script:Strings.ShouldProcessRemoveSection)) {
        $IniFileContent.Remove($SectionName)
        Write-Verbose ($script:Strings.SectionRemoved -f $SectionName, $entryCount)
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  Clear-IniFileSection
# ─────────────────────────────────────────────────────────────────────────────
function Clear-IniFileSection {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $SectionName,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent
    )

    if (-not $IniFileContent.Contains($SectionName)) {
        Write-Warning ($script:Strings.SectionNotFound -f $SectionName)
        return
    }

    if ($PSCmdlet.ShouldProcess($SectionName, $script:Strings.ShouldProcessClearSection)) {
        $count = $IniFileContent[$SectionName].Count
        $IniFileContent[$SectionName].Clear()
        Write-Verbose ($script:Strings.SectionCleared -f $SectionName, $count)
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  Move-IniFileSection
# ─────────────────────────────────────────────────────────────────────────────
function Move-IniFileSection {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding(DefaultParameterSetName = 'MoveAfter')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $SectionName,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent,

        [Parameter(Mandatory, ParameterSetName = 'MoveAfter')]
        [string] $After,

        [Parameter(Mandatory, ParameterSetName = 'MoveBefore')]
        [string] $Before,

        [Parameter(Mandatory, ParameterSetName = 'MoveToStart')]
        [switch] $ToStart,

        [Parameter(Mandatory, ParameterSetName = 'MoveToEnd')]
        [switch] $ToEnd
    )

    if (-not $IniFileContent.Contains($SectionName)) {
        Write-Warning ($script:Strings.SectionNotFound -f $SectionName)
        return
    }

    $content = $IniFileContent[$SectionName]
    $IniFileContent.Remove($SectionName)

    switch ($PSCmdlet.ParameterSetName) {
        'MoveAfter' {
            if (-not $IniFileContent.Contains($After)) {
                Write-Warning ($script:Strings.RefSectionNotFound -f $After)
                $IniFileContent[$SectionName] = $content
                return
            }
            $index = $IniFileContent.Keys.IndexOf($After) + 1
            $IniFileContent.Insert($index, $SectionName, $content)
            Write-Verbose ($script:Strings.SectionMovedAfter -f $SectionName, $After, $index)
        }
        'MoveBefore' {
            if (-not $IniFileContent.Contains($Before)) {
                Write-Warning ($script:Strings.RefSectionNotFound -f $Before)
                $IniFileContent[$SectionName] = $content
                return
            }
            $index = $IniFileContent.Keys.IndexOf($Before)
            $IniFileContent.Insert($index, $SectionName, $content)
            Write-Verbose ($script:Strings.SectionMovedBefore -f $SectionName, $Before, $index)
        }
        'MoveToStart' {
            $IniFileContent.Insert(0, $SectionName, $content)
            Write-Verbose ($script:Strings.SectionMovedToStart -f $SectionName)
        }
        'MoveToEnd' {
            $IniFileContent[$SectionName] = $content
            Write-Verbose ($script:Strings.SectionMovedToEnd -f $SectionName)
        }
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  Move-IniFileValues
# ─────────────────────────────────────────────────────────────────────────────
function Move-IniFileValues {
    <#
    .ExternalHelp FITS.IniFileUtils-Help.xml
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [string] $SourceSection,

        [Parameter(Mandatory)]
        [string] $DestinationSection,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary] $IniFileContent,

        [string[]] $Keys,
        [switch]   $Copy,
        [switch]   $Overwrite
    )

    if (-not $IniFileContent.Contains($SourceSection)) {
        Write-Warning ($script:Strings.SourceSectionNotFound -f $SourceSection)
        return
    }
    if (-not $IniFileContent.Contains($DestinationSection)) {
        Write-Warning ($script:Strings.DestSectionNotFound -f $DestinationSection)
        return
    }

    $targetKeys = if ($Keys) { $Keys } else { [string[]]($IniFileContent[$SourceSection].Keys) }
    $action     = if ($Copy) { $script:Strings.ActionCopy } else { $script:Strings.ActionMove }

    foreach ($keyName in $targetKeys) {
        if (-not $IniFileContent[$SourceSection].Contains($keyName)) {
            Write-Warning ($script:Strings.KeyNotFound -f $keyName, $SourceSection)
            continue
        }
        if ($IniFileContent[$DestinationSection].Contains($keyName) -and -not $Overwrite) {
            Write-Warning ($script:Strings.KeyAlreadyExists -f $keyName, $DestinationSection)
            continue
        }
        if ($PSCmdlet.ShouldProcess("$SourceSection\$keyName -> $DestinationSection", $action)) {
            $IniFileContent[$DestinationSection][$keyName] = $IniFileContent[$SourceSection][$keyName]
            if (-not $Copy) { $IniFileContent[$SourceSection].Remove($keyName) }
            Write-Verbose ($script:Strings.KeyTransferred -f $action, $keyName, $SourceSection, $DestinationSection)
        }
    }
}
