ConvertFrom-StringData @'
    ModuleRemoved              = FITS.IniFileUtils: Modul wurde entfernt.
    SectionNotFound            = Section '{0}' nicht gefunden — keine Aenderung.
    SectionAlreadyExists       = Section '{0}' existiert bereits — uebersprungen.
    SectionNotEmpty            = Section '{0}' ist nicht leer ({1} Eintraege). -RemoveAllValues zum Erzwingen verwenden.
    SectionRemoved             = Section '{0}' entfernt ({1} Eintraege verworfen).
    SectionCleared             = Section '{0}' geleert ({1} Eintraege entfernt, Section bleibt erhalten).
    SectionAppended            = Section '{0}' ans Ende angehaengt.
    SectionInsertedAfter       = Section '{0}' nach '{1}' eingefuegt (Index {2}).
    SectionInsertedBefore      = Section '{0}' vor '{1}' eingefuegt (Index {2}).
    SectionMovedAfter          = Section '{0}' nach '{1}' verschoben (Index {2}).
    SectionMovedBefore         = Section '{0}' vor '{1}' verschoben (Index {2}).
    SectionMovedToStart        = Section '{0}' an den Anfang verschoben.
    SectionMovedToEnd          = Section '{0}' ans Ende verschoben.
    RefSectionNotFound         = Referenz-Section '{0}' nicht gefunden. Wird ans Ende angehaengt.
    SourceSectionNotFound      = Quell-Section '{0}' nicht gefunden — keine Aenderung.
    DestSectionNotFound        = Ziel-Section '{0}' nicht gefunden — keine Aenderung.
    KeyNotFound                = Key '{0}' nicht gefunden in '{1}' — uebersprungen.
    KeyAlreadyExists           = Key '{0}' existiert bereits in '{1}'. -Overwrite zum Ersetzen verwenden — uebersprungen.
    KeyTransferred             = {0} '{1}': '{2}' -> '{3}'.
    ActionMove                 = Verschieben
    ActionCopy                 = Kopieren
    ShouldProcessRemoveSection = INI-Section entfernen
    ShouldProcessClearSection  = Alle Eintraege aus INI-Section entfernen
    VerboseSection             = Section: [{0}]
    VerboseComment             = Kommentar: {0}
    VerboseKey                 = Key: {0} = {1}
'@
