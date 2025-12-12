package process

@Field Lane lane
@Field ResourceBundle messages

section 4, "image:icons/Lane.png[title=\"Lane\"] $lane.name${lane.actor ? " (${new XRef(id: "${lane.process}.actor.$lane.actor", label: "icon:user[title=\"${messages.getString('actor')}\"] $lane.actor").refLink()})" : ''}"
        
newLine()
        
write lane.description ?: "_${messages.getString('descriptionPlaceholder')}_"
        
2.times { newLine() }
        
if(lane.actorFilter) {
   layout 'process/actor_filter_template.tpl', actorFilter:lane.actorFilter, messages:messages, level:5
}
    