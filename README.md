Welcome to the Bonita Presales Team Template Repository.

The purpose of this template is to provide the most used artifacts or point of extensions not included in a new Bonita Project .

For a quick documentation here are the artifacts included .

## Table of Contents

- [Bonita Studio](#bonita-studio)
   - [Organization](#organization-acme)
   - [Presales Theme](#presales-theme)
   - [REST API Extensions](#rest-api-extensions)
- [UI Designer](#ui-designer)
   - [Presales Layout](#presales-layout)
   - [CustomWidgets](#customwidgets)
- [Others](#others)
   - [Presales Jenkins File](#presales-jenkins-file)

## Bonita Studio

### Organization (ACME)
Default ACME organization provided with any new Bonita Project.

### Presales Theme
Default Theme with an added CSS resource (presalesCSS.scss). This resource includes custom classes for the construction of pages and forms, the classes are:
- ***container-box-shadow:*** To use for delimiting a section of a form or page, adds a cast shadow under the container and raises the Z level.
- ***container-box-content:*** Used to set the properties of the content in a section, raising the Z level to avoid any over casted shadow.
- ***container-header:*** Applies a color background for the header of a section.
- ***fixedFooter:*** In case a fixed footer should be added to fix a container to the bottom of a screen (in case of actions to be always shown).
- ***itemLine:*** To use in repetable containers using collections. It sets a Zebra-like theme color to separate each item.
- ***simple-header:*** A simple white background for a section or a header.

### REST API Extensions
Here is the list of available REST API Extensions in this template.
- ***SQLQueries*** The process *BDM - SampleData*  cleans the BDM and start a basic setup. It starts 30s after auto deployement 
then navigate to http://localhost:8080/bonita/API/extension/bdmQueries?queryId=sample. Note that if you need to add parameters to queries, you may add extra conf, since Postgres requires to explicit parameter type (not required on H2)

## UI Designer

### Presales Layout
A simple layout (same as given by default). But added as a UI Designer component to allow easy modifications (new logos, etc.).

### CustomWidgets
Here is the list of available Custom Widgets in this template.
- ***ButtonGroup:*** Custom widget to allow grouping several buttons in a tight group. For the configuration of this widget, a JSON file should be created with each button to be added, here is an example code:

```
 return [
        {
            "label" : "<i class=\"glyphicon glyphicon-plus-sign\"></i> <span class=\"hidden-xs\">Task</span>",
            "style" : "primary",
            "action" : "Open modal",
            "modalId" : "createActivity"
        },
        {
            "label" : "<span class='glyphicon glyphicon-gift'></span> Déclaration cadeau",
            "style" : "link",
            "action" : "POST",
            "method" : "POST",
            "url" : $data.getProcessURL,
            "dataToSend" : $data.newCadeau,
            "targetUrlOnSuccess" : "/bonita/apps/mesDCCP/myTasks"
        },
        {
            "label" : "<span class='glyphicon glyphicon-option-vertical'></span> Autre avantage",
            "style" : "link",
            "action" : "POST",
            "method" : "POST",
            "url" : $data.getProcessURL,
            "dataToSend" : $data.newAvantages,
            "targetUrlOnSuccess" : "/bonita/apps/mesDCCP/myTasks"
            
        }
]
```
## Others

### Presales Jenkins File
In case of using the presales CI platform, a Jenkins file defining the pipeline to be executed when deploying this application.
