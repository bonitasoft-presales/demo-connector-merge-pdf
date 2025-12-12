package bdm

@Field BusinessObject businessObject
@Field ResourceBundle messages

section 5, "icon:lock[] ${messages.getString('accessRules')}"

newLine()

def keepIndent = true
write  keepIndent, new Table(headers : [messages.getString('name'), messages.getString('description'), messages.getString('attributes'), messages.getString('profilesWithAccess')],
                columnsFormat: ['1','3a','2','2'],
                columms : [
                    businessObject.rules.name, 
                    businessObject.rules.description, 
                    businessObject.rules.attributes.collect { it.join(System.lineSeparator()) },
                    businessObject.rules.profiles.collect { List<String> profiles ->
                        profiles.collect { new XRef(id: "profile.$it", label: it).refLink() }.join(System.lineSeparator())
                      }
                    ])

newLine()