package process

@Field SequenceFlow transition
@Field String process
@Field ResourceBundle messages

def hasCondition = transition.useDecisionTable || transition.condition?.content
def asList = hasCondition || transition.description

def transitionName = transition.name ? "$transition.name: " : ''
if(!asList) {
    write '*'
}
write "$transitionName${messages.getString('to')} ${new XRef(id: "${process}.flowElement.$transition.target", label: transition.target).refLink()}"
if(transition.defaultFlow) {
    write true, " (${messages.getString('default')})"
}
if(asList) {
    write '::'
}else {
    write '*'
    newLine()
}
if(transition.description) {
    write true, ' '
    write transition.description
    newLine()
    if(hasCondition) {
        write '+'
        newLine()
    }
}
if(hasCondition) {
    newLine()
    write '+'
    newLine()
    write ".${messages.getString('when')}:"
    newLine()
    if(!transition.useDecisionTable) {
        write true, new Block(properties: ['source','groovy'],
                              content: transition.condition.content.trim())
    }else {
        def conditionColumn = transition.decisionTable.lines.collect { it.conditions.content.collect{ "`$it`"}.join(" ${messages.getString('and')} ") }
        def decisionColumn =  transition.decisionTable.lines.collect { it.takeTransition ? messages.getString('takeTransition') : messages.getString('doNotTakeTransition') }
        write true, new Table(headers: [messages.getString('conditions'), messages.getString('decision')],
                              footers :[messages.getString('byDefault').capitalize(), transition.decisionTable.defaultTakeTransition ?  messages.getString('takeTransition') : messages.getString('doNotTakeTransition')],
                              stripes: 'none',
                              columnsFormat: ['4', '1'],
                              columms: [conditionColumn, decisionColumn])
    }
}
newLine()