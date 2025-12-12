package application

@Field ApplicationDescriptor application
@Field ResourceBundle messages

section 3, "$application.displayName ($application.version)"
newLine()

write application.description ?: "_${messages.getString('descriptionPlaceholder')}_"
2.times { newLine() }

write '[horizontal]'
newLine()
write messages.getString('profile')
write ':: '
write new XRef(id: "profile.$application.profile", label: "icon:user[title=\"${messages.getString('profile')}\"] $application.profile").refLink()
newLine()
write messages.getString('url')
write ':: '
write "../apps/$application.token"
if(application.homePage) {
    newLine()
    write messages.getString('homePage')
    write ':: '
    write  new XRef(id: "page.${application.homePage.name}", label: application.homePage.displayName).refLink()
}


2.times { newLine() }

section 4, messages.getString('lookAndFeel')
newLine()

write new Table(columnsFormat: ["1","2"],
                columms: [
                    [messages.getString('layout'), messages.getString('theme')],
                    [application.layout, application.theme]
                ])

newLine()

if(application.orphanPages || application.menus) {
    section 4, messages.getString('pages')
    newLine()
    
    if(application.menus) {
        layout 'application/application_navigation_template.tpl', application:application, messages:messages
    }
    
    if(application.orphanPages) {
        section 5, messages.getString('orphanPages')
        newLine()
        write new Table(headers: [messages.getString('applicationPage')],
                        columms: [application.orphanPages.collect{ new XRef(id: "page.${it.name}", label: it.displayName).refLink() }])
        newLine()
    }
 
}
