package process

@Field FormMapping mapping
@Field int level
@Field ResourceBundle messages

if(mapping.type == 'URL') {
    write '[horizontal]'
    newLine()
    write messages.getString('externalURL')
    write ':: '
    write "$mapping.url[$mapping.url]"
    2.times { newLine() }
}else if(mapping.form){
    layout 'page/page_template.tpl', page:mapping.form, level:level, messages:messages
}else {
    write """|[CAUTION]
             |====
             |${messages.getString('invalidInternalFormMapping')}
             |====""".stripMargin()
    2.times { newLine() }
}
