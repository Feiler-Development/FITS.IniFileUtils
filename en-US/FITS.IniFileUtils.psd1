ConvertFrom-StringData @'
    ModuleRemoved              = FITS.IniFileUtils: module removed.
    SectionNotFound            = Section '{0}' not found — no changes made.
    SectionAlreadyExists       = Section '{0}' already exists — skipping.
    SectionNotEmpty            = Section '{0}' is not empty ({1} entries). Use -RemoveAllValues to force removal.
    SectionRemoved             = Section '{0}' removed ({1} entries discarded).
    SectionCleared             = Section '{0}' cleared ({1} entries removed, section kept).
    SectionAppended            = Section '{0}' appended at end.
    SectionInsertedAfter       = Section '{0}' inserted after '{1}' (index {2}).
    SectionInsertedBefore      = Section '{0}' inserted before '{1}' (index {2}).
    SectionMovedAfter          = Section '{0}' moved after '{1}' (index {2}).
    SectionMovedBefore         = Section '{0}' moved before '{1}' (index {2}).
    SectionMovedToStart        = Section '{0}' moved to start.
    SectionMovedToEnd          = Section '{0}' moved to end.
    RefSectionNotFound         = Reference section '{0}' not found. Appending at end.
    SourceSectionNotFound      = Source section '{0}' not found — no changes made.
    DestSectionNotFound        = Destination section '{0}' not found — no changes made.
    KeyNotFound                = Key '{0}' not found in '{1}' — skipped.
    KeyAlreadyExists           = Key '{0}' already exists in '{1}'. Use -Overwrite to replace — skipped.
    KeyTransferred             = {0} '{1}': '{2}' -> '{3}'.
    ActionMove                 = Move
    ActionCopy                 = Copy
    ShouldProcessRemoveSection = Remove INI section
    ShouldProcessClearSection  = Clear all entries from INI section
    VerboseSection             = Section: [{0}]
    VerboseComment             = Comment: {0}
    VerboseKey                 = Key: {0} = {1}
'@
