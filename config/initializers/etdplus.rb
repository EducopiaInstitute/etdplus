# This is a dictionary with tools as keys, and metadata entries as items in a list. The items
# added will not be displayed in the user interface. An asterisk ('*') means that NO ITEMS from
# that tool will be displayed.
Etdplus::Application.config.x.fits_display_blacklist = {
  #'Jhove': ['size', 'well-formed'],
  #'Exiftool': ['creatingApplicationName'],
  #'NLNZ Metadata Extractor': ['*'],
}

# This is a dictionary with tools as keys, and metadata entries as items in a list. The items
# added will be exported with the METS metadata in any Bagit bag. An asterisk ('*') means that
# ALL ITEMS from that tool will be exported.
Etdplus::Application.config.x.fits_export_whitelist = {
  #'Jhove': ['valid', 'version'],
  #'OIS File Information': ['md5checksum']
  #'Droid': ['*']
}

# If a virus is detected in a file, by default the file will be deleted. If this is false, the
# file will be forced to a private visibility.
Etdplus::Application.config.x.destroy_viruses_immediately = true

# If PII is detected in a file, by default the file will be deleted. If this is false, the
# file will be forced to a private visibility.
Etdplus::Application.config.x.destroy_pii_immediately = true

# Zaru sanitizes filenames. These options are passed to it when a file is saved.
Etdplus::Application.config.x.filename_options = {
  # The options provided by default below mimic the way detox works. (http://detox.sourceforge.net/)
  #length: 255, # The max length of the final filename. Default is 255.
  #allow_unicode: false, # Can filenames include unicode? Default is false.
  replace: '_', # Replacement for bad characters. Default is '', which deletes them.
  whitespace: '', # Replacement for whitespace characters. Default is ' ', which collapses multiples.
}
