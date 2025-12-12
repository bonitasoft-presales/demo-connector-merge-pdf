package process

@Field ActorFilter actorFilter
@Field int level
@Field ResourceBundle messages

section level, "icon:filter[] ${messages.getString('actorFilter')}"
newLine()
if(actorFilter.description) {
    write "$actorFilter.definitionName: $actorFilter.name:: "
    write actorFilter.description
}else {
    write "*$actorFilter.definitionName: $actorFilter.name*"
}
2.times { newLine() }