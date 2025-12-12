package process

@Field List<Connector> connectors
@Field ResourceBundle messages

connectors.each { Connector connector ->
    if(connector.description) {
        write "$connector.definitionName: $connector.name:: "
        write connector.description
    }else {
        write "*$connector.definitionName: $connector.name*"
    }
    newLine()
}
newLine()