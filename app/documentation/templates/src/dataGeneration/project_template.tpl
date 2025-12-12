import java.nio.file.Files

import groovy.json.JsonOutput

@Field Project project

section 2, "${project.name} json descriptor"

newLine()



newLine()


writeModel(project)


def writeModel(project) {
	//File f = new File("documentation/static/model.json")
	File f = File.createTempFile('model','.json')
	f.text = toJson(project)

	newLine()
	write ".${f.absolutePath}"
write '''
[source,json]
----
'''
	write "include::documentation/static/model.json[]"
	write '''
----'''
	newLine()
	
}


newLine()

section 2, "Data generation groovy utils"

newLine()

def utils = [
    'ArrayUtil',
    'LoggerUtil',
    'ProcessUtil',
    'UserUtil'
]

utils.each {
    write """.${it}.groovy
[source,Groovy]
----
"""

    write "include::src-groovy/com/bonitasoft/data/initialization/utils/${it}.groovy[]"

    newLine()
    write '''
----
'''
    newLine()
}


def toJson(def project) {
    def json =  JsonOutput.toJson(project)
    def pretty = JsonOutput.prettyPrint(json)
    pretty
}