package bdm

@Field BusinessDataModel businessDataModel
@Field boolean includeDiagrams
@Field ResourceBundle messages

section 2, messages.getString('businessDataModel')

newLine()

if(includeDiagrams) {
    // Insert the BDM class diagram svg image generated from the plantuml file (see bdm/bdm_class_diagram_template.tpl)
    write 'image::bdm.svg[link=images/bdm.svg]'
    newLine()
}else{ //Graphviz is not installed
    comment messages.getString('graphvizSetupInstruction')
}

newLine()

businessDataModel.packages.each { Package pckg ->
    
    section 3, "Package $pckg.name"
    newLine()
    
    pckg.businessObjects.each { BusinessObject object ->
        section 4, object.name
        newLine()
        write object.description ?: "_${messages.getString('descriptionPlaceholder')}_"
        2.times { newLine() }
        
        if(object.attributes || object.relations) layout 'bdm/bdm_attributes_template.tpl', businessObject:object, messages:messages
        if(object.rules) layout 'bdm/bdm_access_rules_template.tpl', businessObject:object, messages:messages
        if(object.uniqueConstraints) layout 'bdm/bdm_constraints_template.tpl', businessObject:object, messages:messages
        if(object.customQueries) layout 'bdm/bdm_queries_template.tpl', businessObject:object, messages:messages
    }

}