package process

@Field Diagram diagram
@Field ResourceBundle messages

section 3, "$diagram.name ($diagram.version)"

newLine()

write diagram.description ?: "_${messages.getString('descriptionPlaceholder')}_"

2.times { newLine() }

write "image::diagrams/$diagram.name-${diagram.version}.png[]"

2.times { newLine() }


