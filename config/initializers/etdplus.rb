EtdPlus.config do |config|
  # This is a dictionary with tools as keys, and metadata entries as items in a list. The items
  # added will not be displayed in the user interface.
  config.fits_display_blacklist = {
    #'Jhove': ['size', 'well-formed'],
    #'Exiftool': ['creatingApplicationName'],
    #'NLNZ Metadata Extractor': ['hasForms'],
  }

  # This is a dictionary with tools as keys, and metadata entries as items in a list. The items
  # added will be exported with the METS metadata in any Bagit bag.
  config.fits_export_whitelist = {
    #'Jhove': ['valid', 'version'],
    #'OIS File Information': ['md5checksum']
  }

  # If a virus is detected in a file, by default the file will be deleted. If this is false, the
  # file will be forced to a private visibility.
  config.destroy_viruses_immediately = True

  # If PII is detected in a file, by default the file will be deleted. If this is false, the
  # file will be forced to a private visibility.
  config.destroy_pii_immediately = True
