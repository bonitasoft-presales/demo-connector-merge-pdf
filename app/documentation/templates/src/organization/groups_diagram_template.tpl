package organization

@Field Organization organization

write '@startuml'
2.times { newLine() }

def List<String> links = []
createGroups(organization.groups, links)

links.each { 
    write it
    newLine()
}

write '@enduml'
newLine()

def createGroups(Object groups, List<String> links) {
    groups.each{ Group group ->
        
            write "object \"$group.name\" as ${StringsUtil.normalize(group.name, '.', ['-'])}"
            
            if(group.description || group.displayName) {
                write true, ' {'
                
                newLine()
                
                if(group.displayName) {
                    writeIndent 1, group.displayName
                    newLine()
                }
                
                if(group.description) {
                    StringsUtil.wrap(group.description, 50).eachLine {  String line ->
                        writeIndent 1, line
                        newLine()
                    }
                }
                
                write '}'
            }
            
            newLine()
            
            if(group.subGroups) {
                group.subGroups.each { Group subGroup ->
                    links << "${StringsUtil.normalize(group.name, '.')} -- ${StringsUtil.normalize(subGroup.name, '.', ['-'])}"
                }
                newLine()
                createGroups(group.subGroups, links)
            }else {
                newLine()
            }
        }
}
