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

# If a ill-formatted xml file is detected, by default the package will still be exported. If this
# is true, the package will not be exported.
Etdplus::Application.config.x.stop_xml_export = false

# Zaru sanitizes filenames. These options are passed to it when a file is saved.
Etdplus::Application.config.x.filename_options = {
  # The options provided by default below mimic the way detox works. (http://detox.sourceforge.net/)
  #length: 255, # The max length of the final filename. Default is 255.
  #allow_unicode: false, # Can filenames include unicode? Default is false.
  replace: '_', # Replacement for bad characters. Default is '', which deletes them.
  whitespace: '', # Replacement for whitespace characters. Default is ' ', which collapses multiples.
}

# Bags cen be generated without logging in if the user is in the IP adress range given below.
Etdplus::Application.config.x.ip_whitelist = IPAddr.new('127.0.0.1')
# Addresses can be IPv4 or IPv6, and can include range masks.
# Eg: '3ffe:505:2::1' or '192.168.2.0/24'

# Tools version
# e.g. ClamAV 0.98.7/21532/Thu May 12 12:56:01 2016
Etdplus::Application.config.x.clamav_version = `clamscan -V`
# e.g. bulk_extractor 1.5.5
Etdplus::Application.config.x.bulk_extractor_version = `bulk_extractor -V`
# e.g. nokogiri: 1.6.7.2
Etdplus::Application.config.x.nokogiri_version = `nokogiri -v | grep -m 1 nokogiri`

# default email to send virus checking result
Etdplus::Application.config.x.from_email_virus = 'no-reply@localhost'
# default email to send PII checking result
Etdplus::Application.config.x.from_email_pii = 'no-reply@localhost'
# default email to send XML validation result
Etdplus::Application.config.x.from_email_xml = 'no-reply@localhost'
# default email to send the contact form
Etdplus::Application.config.x.from_email_contact = 'root@localhost'

# The following settings are based on the University of Michigan's Deep Blue policies.
# For more info, visit https://deepblue.lib.umich.edu/static/about/deepbluepreservation.html
# This is a set of mime types that the repository provides the highest level of preservation
# support for.
Etdplus::Application.config.x.file_feedback_level1 =
  ['application/pdf', 'text/plain', 'application/sgml', 'image/jpeg', 'image/tiff', 'audio/aiff',
  'audio/wav', 'audio/x-wav', 'application/zip', 'application/x-gzip']
# This is a set of mime types that the repository provides limited preservation support for.
Etdplus::Application.config.x.file_feedback_level2 =
  ['text/xml', 'text/html', 'application/ps', 'text/richtext', 'application/msword',
  'application/vnd.ms-powerpoint', 'application/vnd.ms-excel', 'image/png', 'audio/basic',
  'audio/mpeg', 'audio/mp3', 'audio/m4a', 'audio/mp4', 'video/avi', 'video/msvideo',
  'video/x-msvideo', 'video/quicktime', 'video/x-quicktime', 'video/mpeg', 'video/mpeg2',
  'video/mp4']
# This is a set of mime types that the repository provides as-is preservation support for.
Etdplus::Application.config.x.file_feedback_level3 =
  ['application/x-latex', 'application/x-tex', 'image/x-ms-bmp', 'image/gif', 'image/x-photo-cd',
  'application/x-photoshop', 'audio/vnd.rn-realaudio', 'audio/x-ms-wma', 'video/x-ms-wmv']
