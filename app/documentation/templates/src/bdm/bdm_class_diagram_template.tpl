package bdm

@Field BusinessDataModel businessDataModel
@Field ResourceBundle messages

write '@startuml'
2.times { newLine() }

businessDataModel.packages.each{ Package pckg ->

    write "package $pckg.name {"
    2.times { newLine() }

    pckg.businessObjects.each{  BusinessObject businessObject ->

        if(businessObject.description) {
            writeIndent "note top of $businessObject.name : "
            write StringsUtil.escapeNewLineChar(businessObject.description)
            newLine()
        }

        writeIndent "class $businessObject.name {"
        newLine()

        businessObject.attributes.each{ Attribute attribute ->
            writeIndent 2, "+$attribute.name : ${attribute.multiple ? "List<$attribute.type>" : attribute.type}"
            newLine()
        }

        if(businessObject.customQueries) {
            writeIndent 2, "== ${messages.getString('customQueries')} =="
            newLine()

            businessObject.customQueries.each{ Query query ->
                def parameterSignature = query.parameters.collect{ QueryParameter parameter -> "$parameter.type $parameter.name" }.join(", ")
                writeIndent 2, "+${query.name}($parameterSignature) : $query.returnType"
                newLine()
            }
        }

        writeIndent '}'
        2.times { newLine() }
    }
    
    write '}'
    2.times { newLine() }
}

businessDataModel.packages.businessObjects.flatten().each{ BusinessObject businessObject ->
    
    businessObject.relations.each { Relation relation ->
         write "$businessObject.name ${relation.relationType == 'COMPOSITION' ? '*' :  'o'}-- ${relation.multiple ? '"*"' : ''} $relation.type : $relation.name"
         newLine()
    }
    
}

newLine()
write 'legend top left'
newLine()
write '&#9830; '
write messages.getString('compositionRelation')
write '  '
write '&#9826; '
write messages.getString('aggregationRelation')
write '  '
write '&#42; '
write messages.getString('multipleRelation')
newLine()
write 'endlegend'
2.times { newLine() }

write '@enduml'
newLine()
