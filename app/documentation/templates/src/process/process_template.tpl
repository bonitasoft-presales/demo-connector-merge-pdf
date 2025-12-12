package process

@Field Process process
@Field ResourceBundle messages

def keepIndent = true

section 3, "image:icons/Pool.png[title=\"${messages.getString('process')}\"] ${new XRef(id: "process.$process.name-$process.version").inlinedRefTag()}$process.name ($process.version)"

newLine()

if(process.displayName) {
    write "*${messages.getString('displayName')}:* $process.displayName + "
    newLine()
}
write process.description ?: "_${messages.getString('descriptionPlaceholder')}_"

2.times { newLine() }

write "image::processes/$process.name-${process.version}.png[]"

2.times { newLine() }

if(process.actors) {
    section 4, "icon:users[] ${messages.getString('actors')}"
    newLine()
    write keepIndent, new Table( headers: [messages.getString('name'), messages.getString('description')],
        columnsFormat: ['1','3a'],
        columms: [
            process.actors.collect { "${new XRef(id: "$process.name-${process.version}.actor.$it.name").inlinedRefTag()}$it.name${it.initiator ? " icon:play-circle[title=\"${messages.getString('processInitiator')}\"]" : ''}" },
            process.actors.description])
    newLine()
}

if(process.parameters) {
    section 4, "icon:cog[] ${messages.getString('parameters')}"
    newLine()
    write keepIndent, new Table( headers: [messages.getString('name'), messages.getString('type'), messages.getString('description')],
                                 columnsFormat: ['1','1e','3a'],
                                 columms: [
                                     process.parameters.name,
                                     process.parameters.type,
                                     process.parameters.description])
    newLine()
}

if(process.documents) {
    section 4, "icon:file[] ${messages.getString('documents')}"
    newLine()
    write keepIndent, new Table( headers: [messages.getString('name'), messages.getString('description')],
                                 columnsFormat: ['1','3a'],
                                 columms: [
                                     process.documents.collect { "${new XRef(id: "$process.name-${process.version}.doc.$it.name").inlinedRefTag()}$it.name${it.multiple ? " icon:files-o[title=\"${messages.getString('multiple')}\"]" : ''}" },
                                     process.documents.description])
    newLine()
    
}

if(process.formMapping && process.formMapping.type != 'NONE') {
   section 4, messages.getString('instantiationForm')
   newLine()
   layout 'process/form_mapping_template.tpl', mapping:process.formMapping, level:5, messages:messages
}

if(process.contract?.inputs) {
    section 4, "icon:list-alt[] ${messages.getString('contractInputs')}"
    newLine()
    layout 'process/contract_inputs_template.tpl', contract:process.contract, messages:messages
}

if(process.contract?.constraints) {
    section 4, "icon:check-circle[] ${messages.getString('contractConstraints')}"
    newLine()
    layout 'process/contract_constraints_template.tpl', contract:process.contract, messages:messages
}

if(process.connectorsIn) {
    section 4, "icon:plug[] ${messages.getString('connectorsIn')}"
    newLine()
    layout 'process/connectors_template.tpl', connectors:process.connectorsIn, messages:messages
}

if(process.connectorsOut) {
    section 4, "icon:plug[] ${messages.getString('connectorsOut')}"
    newLine()
    layout 'process/connectors_template.tpl', connectors:process.connectorsOut, messages:messages
}

if(process.lanes) {
    process.lanes.each { Lane lane ->
        layout 'process/lane_template.tpl', lane:lane, messages:messages
    }
}

if(process.flowElements) {
    process.flowElements.each { FlowElement flowElement -> layout 'process/flow_element_template.tpl', flowElement:flowElement, messages:messages }
}

if(process.eventSubprocesses) {
    process.eventSubprocesses.each { EventSubProcess eventSubprocess ->
         section 4, "image:icons/SubProcessEvent.png[] $eventSubprocess.name" 
         newLine()
         write eventSubprocess.description ?: "_${messages.getString('descriptionPlaceholder')}_"
         2.times { newLine() }
         eventSubprocess.flowElements.each { FlowElement flowElement->
             layout 'process/flow_element_template.tpl', flowElement:flowElement, messages:messages
         }
   }
}
