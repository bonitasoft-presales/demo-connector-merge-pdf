package process


@Field Process process
@Field ResourceBundle messages

def keepIndent = true

section 3, "image:icons/Pool.png[title=\"${messages.getString('process')}\"] ${new XRef(id: "process.$process.name-$process.version").inlinedRefTag()}$process.name ($process.version)"

newLine()

if (process.displayName) {
    write "*${messages.getString('displayName')}:* $process.displayName + "
    newLine()
}
write process.description ?: "_${messages.getString('descriptionPlaceholder')}_"

2.times { newLine() }


//write "image::processes/$process.name-${process.version}.png[]"

//2.times { newLine() }


def className = javaClassName(process.name)

write """

.${className}.groovy
[source,groovy]
----

package com.bonitasoft.data.initialization.process

import java.time.LocalDate
import java.time.LocalDateTime
import java.time.OffsetDateTime

import org.bonitasoft.engine.api.APIAccessor
import org.bonitasoft.engine.bpm.contract.FileInputValue

import com.bonitasoft.data.initialization.utils.ArrayUtil
import com.bonitasoft.data.initialization.utils.LoggerUtil
import com.bonitasoft.data.initialization.utils.ProcessUtil
import com.bonitasoft.data.initialization.utils.UserUtil
import com.github.javafaker.Faker

class ${className} implements LoggerUtil,ProcessUtil,UserUtil,ArrayUtil  {

    private static final String PROCESS_NAME = '${process.name}'
    private static final String PROCESS_VERSION = '${process.version}'
"""

def humanTasks = getHumanTasks(process)
humanTasks.each {
    write """
private static final String TASK_${toConstantName(it.name)} = '${it.name}' // ${it.bpmnType} """
}

write """

    APIAccessor apiAccessor
    Faker faker

    def ${className}(APIAccessor apiAccessor,Faker faker) {
        this.apiAccessor=apiAccessor
		this.faker=faker
	}    

    long startCase(long userId, def contract) {
        startProcessInstance(apiAccessor, userId, PROCESS_NAME, PROCESS_VERSION, contract)
    }

    def contractCase(){
"""


if (process.contract?.inputs) {
	layout 'dataGeneration/contract_inputs_template.tpl', contract: process.contract, messages: messages
}
else {
    write """
    emptyContract() //no contract for process
	}
"""
}

write '''    
    }
'''



humanTasks.each { humanTask-> 
    write """
    
        def task${toMethodName(humanTask.name)}(long userId, long processInstanceId ,def contract) {
            assignAndExecuteTask(apiAccessor, userId, processInstanceId, contract, TASK_${toConstantName(humanTask.name)})
        }
    
        def contract${toMethodName(humanTask.name)} (){
"""
        
        if (humanTask.contract?.inputs) { 
        	layout 'dataGeneration/contract_inputs_template.tpl', contract: humanTask.contract, messages: messages
        write '}'
        
            }
        else {
             write """
            emptyContract() //no contract for this task
        	}
        """
        }    


    

    
} //all human tasks

write '''
    def emptyContract(){
        [:]
    }
''' 

write '''
}
''' 


write '''
----
'''

def javaClassName(def processName) {
    getIdentifier("Process${processName}")
}

def toConstantName(def name) {
    getIdentifier(name).toUpperCase()
}

def getHumanTasks(def process) {
    def humanTasks = process?.flowElements?.findAll {
         'Task' == it.bpmnType
    }
    if (!humanTasks) {
        return []
    }
    return humanTasks
}


def toMethodName(def taskName) {
    getIdentifier(taskName)
}




def toJson(def project) {
    def json =  JsonOutput.toJson(project)
    def pretty = JsonOutput.prettyPrint(json)
    pretty
}


def  getIdentifier(def current) {
    String str = current as String
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < str.length(); i++) {
        if ((i == 0 && Character.isJavaIdentifierStart(str.charAt(i))) || (i > 0 && Character.isJavaIdentifierPart(str.charAt(i))))
            sb.append(str.charAt(i));
        else
            sb.append('_');
    }
    return sb.toString();
}

