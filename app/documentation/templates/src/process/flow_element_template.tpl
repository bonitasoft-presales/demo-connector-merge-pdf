package process

@Field FlowElement flowElement
@Field ResourceBundle messages

def iterationTypeImage = ''
if(flowElement.iterationType) {
    iterationTypeImage = " image:icons/${flowElement.iterationType}.png[title=\"${messages.getString(flowElement.iterationType)}\"]"
}

section 4, "${new XRef(id: "${flowElement.process}.flowElement.$flowElement.name").inlinedRefTag()}image:icons/${flowElement.bpmnType}.png[title=\"${flowElement.bpmnType}\"]$iterationTypeImage $flowElement.name"

newLine()

write flowElement.description ?: "_${messages.getString('descriptionPlaceholder')}_"

2.times { newLine() }

if(flowElement.incomings) {
    write "*${messages.getString('previousFlowElements')}*: ${flowElement.incomings.source.collect{ new XRef(id: "${flowElement.process}.flowElement.$it", label: it).refLink() }.join(', ')}"
    2.times { newLine() }
}

if(flowElement.actorFilter) {
    layout 'process/actor_filter_template.tpl', actorFilter:flowElement.actorFilter, messages:messages, level:5
}

if(flowElement.formMapping && flowElement.formMapping.type != 'NONE') {
    layout 'process/form_mapping_template.tpl', mapping:flowElement.formMapping, level:5, messages:messages
}

if(flowElement.contract?.inputs) {
    section 5, "icon:list-alt[] ${messages.getString('contractInputs')}"
    newLine()
    layout 'process/contract_inputs_template.tpl', contract:flowElement.contract, messages:messages
}

if(flowElement.contract?.constraints) {
    section 5, "icon:check-circle[] ${messages.getString('contractConstraints')}"
    newLine()
    layout 'process/contract_constraints_template.tpl', contract:flowElement.contract, messages:messages
}


if(flowElement.connectorsIn) {
    section 5, "icon:plug[] ${messages.getString('connectorsIn')}"
    newLine()
    layout 'process/connectors_template.tpl', connectors:flowElement.connectorsIn, messages:messages
}

if(flowElement.bpmnType == 'CallActivity') {
    section 5, "icon:plus-square[] ${messages.getString('calledProcess')}"
    newLine()
    
    if(flowElement.calledProcessName.type == ExpressionType.CONSTANT && flowElement.calledProcessName.content && flowElement.calledProcessVersion.type == ExpressionType.CONSTANT) {
        write new XRef(id: "process.${flowElement.calledProcessName.content}-${flowElement.calledProcessVersion.content}", label: "image:icons/Pool.png[title=\"${messages.getString('process')}\"] $flowElement.calledProcessName.content ($flowElement.calledProcessVersion.content)").refLink()
        newLine()
    }else {
        write true, new Block(title: messages.getString('nameExpression'),
                              properties: ['source', 'groovy'],
                              content: flowElement.calledProcessName.content.trim())
        if(flowElement.calledProcessVersion?.content) {
          write true, new Block(title: messages.getString('versionExpression'),
                    properties: ['source', 'groovy'],
                    content: flowElement.calledProcessVersion.content.trim())
        }
    }
    newLine()
}

if(flowElement.boundaryEvents) {
    section 5, "icon:bolt[] ${messages.getString('boundaryEvents')}"
    newLine()
    layout 'process/boundary_events_template.tpl', events:flowElement.boundaryEvents, process:flowElement.process, messages:messages
}

if(flowElement.connectorsOut) {
    section 5, "icon:plug[] ${messages.getString('connectorsOut')}"
    newLine()
    layout 'process/connectors_template.tpl', connectors:flowElement.connectorsOut, messages:messages
}


if(flowElement.outgoings) {
    section 5, "icon:arrow-right[] ${messages.getString('outgoingTransitions')}"

    newLine()

    flowElement.outgoings.collect{ SequenceFlow transition ->
        layout 'process/transition_template.tpl', transition:transition, messages:messages, process:flowElement.process
    }

}

