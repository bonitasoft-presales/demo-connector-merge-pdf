package organization

@Field Organization organization
@Field ResourceBundle messages

section 2, messages.getString('organization')

newLine()

if(organization.groups) {
    section 3, messages.getString('groups')
    
    newLine()
    
    if(includeDiagrams) {
        write '// '
        write messages.getString('uncommentInOrganizationTemplates')
        newLine()
        // Comment groups.svg inclusion by default
        write '// '
        // Insert the Group hierarchy diagram svg image generated from the plantuml file (see organization/groups_diagram_template.tpl)
        write 'image::groups.svg[link=images/groups.svg]'
        newLine()
    }else{ //Graphviz is not installed
        comment messages.getString('graphvizSetupInstruction')
    }
  
    newLine()
    
    def List<Group> groupList = []
    flatten(organization.groups, groupList)
    
    write true, new Table(headers: [messages.getString('path'), messages.getString('displayName'), messages.getString('description')],
        columnsFormat: ['1','1e','3a'],
        columms: [
            groupList.path,
            groupList.displayName,
            groupList.description.collect { it ?: ""}
            ])
    
    
    newLine()

}

if(organization.roles) {
    section 3, messages.getString('roles')
    
    newLine()
    
    write true, new Table(headers: [messages.getString('name'), messages.getString('displayName'), messages.getString('description')],
                          columnsFormat: ['1','1e','3a'],
                          columms: [
                              organization.roles.name,
                              organization.roles.displayName,
                              organization.roles.description.collect { it ?: ""}
                              ])
    
    newLine()
}

if(organization.profiles) {
    section 3, messages.getString('profiles')
    
    newLine()
    
    write true, new Table(headers: [messages.getString('name'), messages.getString('description')],
        columnsFormat: ['1e','3a'],
        columms: [
            organization.profiles.name.collect { "${new XRef(id: "profile.$it").inlinedRefTag()}$it" } ,
            organization.profiles.description.collect { it ?: ""}
            ])
    
    newLine()
}

def flatten(Object groups, Object groupList) {
    groups.collect {
        groupList.add(it)
        if(it.subGroups) {
            flatten(it.subGroups, groupList)
        }
    }
}