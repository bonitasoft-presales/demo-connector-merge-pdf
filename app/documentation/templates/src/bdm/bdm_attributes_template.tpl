package bdm

@Field BusinessObject businessObject
@Field ResourceBundle messages

section 5, "icon:list[] ${messages.getString('attributes')}"

newLine()

def allFields = businessObject.attributes + businessObject.relations

def nameColumn = allFields.collect { "${new AttributeXRef(businessObject : businessObject, attributeName : it.name).inlinedRefTag()}${it.hasProperty('relationType') ? "${relationSymbol(it.relationType)} " : ''}$it.name${it.mandatory ? '*' : ''}" }
def typeColumn = allFields.collect { it.multiple ? "List<${typeReference(it)}>" : typeReference(it)}
def descriptionColumn = allFields.collect { it.description ?: '' }

def keepIndent = true
write  keepIndent, new Table(headers : [messages.getString('name'), messages.getString('type'), messages.getString('description')],
                columnsFormat: ['1','1e','3a'],
                columms : [nameColumn, typeColumn, descriptionColumn])

newLine()

def String relationSymbol(Object relationType) {
    relationType == 'COMPOSITION' ? BLACK_DIAMOND : WHITE_DIAMOND
}

def String typeReference(Object attribute) {
    attribute.hasProperty('relationType') ? "<<$attribute.type>>" : attribute.type
}