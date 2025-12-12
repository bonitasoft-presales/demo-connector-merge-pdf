package process

@Field Contract contract
@Field ResourceBundle messages

contract.constraints.each { ContractConstraint constraint ->
    write "$constraint.name:: "
    write constraint.description ?: "_${messages.getString('descriptionPlaceholder')}_"
    newLine()
    write '+'
    newLine()
    write true, new Block(title: messages.getString('expression'),
                          properties: ['source','groovy'],
                          content: constraint.expression.trim())
    if(constraint.errorMessage) {
        write '+'
        newLine()
        write true, new Block(title: messages.getString('technicalErrorMessage'),
                              content: constraint.errorMessage.trim())
    }
}

newLine()
