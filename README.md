# Documentation
ETDplus Workbench Documentation

# Requirements for a Collection to be exportable as a ProQuest package:

* When creating the Collection, should set "ProQuest ETD" as one of its resource types.
* Once the "ProQuest ETD" resource type being chosen, a ProQuest-specific form will be displayed and needs to be filled in.
* Among all the fields in the ProQuest-specific form, the following fields are required:
  * The author's last name and first name
  * Effective Date
  * Country Code
  * Area Code
  * E-mail
  * Description
  * Degree
  * Institution Code
  * Institution Name
  * Institution Contact
  * Advisor (Last name and First name)
* The fields that are set in the configuration file instead of asking the submitter to fill in are:
  * Author and advisor affiliations
  * Institution code, name and contact
* You can upload exactly one main ETD generic file and none or multiple supplementary generic files into this Collection.
* The main ETD generic file should have one of its resource types set as "Main ProQuest ETD PDF" and the file format should be in PDF.
* Before exporting the Collection along with its generic files as a ProQuest package, the system will check if the Collection has exactly one main ETD PDF file, otherwise, the export button will be unclickable.
