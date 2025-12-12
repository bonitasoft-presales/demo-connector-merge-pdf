package page

@Field Page page
@Field int level
@Field ResourceBundle messages

section  level, "${new XRef("page.${page.name}").inlinedRefTag()}image:icons/page.png[] ${page.displayName ? "$page.displayName ($page.name)" : page.name}"

newLine()

write page.description ?: "_${messages.getString('descriptionPlaceholder')}_"

2.times { newLine() }

if(page.widgets) {
    write ".${messages.getString('widgets')}"
    newLine()
    write true, new Table(headers: [messages.getString('type'), messages.getString('label'),  messages.getString('description')],
                          columnsFormat: ['1','2','4a'],
                          caption: '',
                          columms: [
                              page.widgets.type,
                              page.widgets.label,
                              page.widgets.description
                              ])
    
    newLine()
}