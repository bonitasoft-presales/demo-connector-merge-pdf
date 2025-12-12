package process

import groovy.json.JsonOutput

@Field Contract contract
@Field ResourceBundle messages


addContractInputs('contractInputs_',contract.inputs)
newLine()
write "def contractInputs= [:]"
newLine()
contract.inputs.each{input ->
	write "contractInputs.${input.name} = contractInputs_${input.name}"
	newLine()
}
write 'return contractInputs'
newLine()

def addContractInputs(prefix, inputs) {
	try{
		inputs.each { input ->
			def inputType = input.type?.toString().toUpperCase().capitalize()
			def isComplex = isComplex(input)
			def isMultiple = input.multiple
			if (isComplex){
				addComplexInput("${prefix}${input.name}",input,isMultiple)
			}
			else {
				addSimpleInput ("${prefix}${input.name}",inputType,isMultiple)
			}
		}
	}
	catch(Exception e) {
		write e
		newLine()
	}
}


def addComplexInput(inputName,input,isMultiple) {
	try{
		
		write "def ${inputName} = [:] "
		newLine()
		input.children?.each{ child ->
			def inputType = child.type?.toString().toUpperCase().capitalize()
			def childIsMultiple = child.multiple
			def isComplex = isComplex(child)
			if (isComplex) {
				addComplexInput ("${inputName}_${child.name}",child,childIsMultiple)
			} else {
				addSimpleInput ("${inputName}_${child.name}",inputType,childIsMultiple)
			}
		}
		input.children?.each{ child ->
			write "${inputName}.${child.name} = ${inputName}_${child.name}"
			newLine()
		}
	}
	catch(Exception e) {
		write e
		newLine()
	}
}

def addSimpleInput(inputName, inputType,isMultiple) {
	def value = '?'
	switch (inputType) {
		case 'TEXT':
			value='"ABCD"'
			break
		case 'LOCALDATE':
			value= 'LocalDate.now()'
			break
		case 'DATE':
			value = 'new Date()'
			break
		case 'OFFSETDATETIME':
			value =  'OffsetDateTime.now()'
			break
		case 'LOCALDATETIME':
			value =  'LocalDateTime.now()'
			break
		
		case 'INTEGER':
			value='123'
			break
		case 'DECIMAL':
			value='456.78D'
			break
		case 'BOOLEAN':
			value='true'
			break
		case 'FILE':
			writeIndent """def ${inputName}_fileValue =  new FileInputValue("file.txt","Text/plain", "file content".bytes)"""
			newLine()
			value = "${inputName}_fileValue"
			break
		default:
			value = "type ${inputType} is not supported!"
	}
	write "def ${inputName} = ${isMultiple?'[':''}${value}${isMultiple?']':''} /* ${inputType} ${isMultiple?'multiple':'single'} */"
	newLine()
}

def addComplexContractInputReferences(input) {

	def name = input.name.capitalize()
	def nodes = input.children?.each{}

	newLine()
	write """def $name   /*



{
${toJson(input)}
}*/
"""

	newLine()
	write true, "    $nodes"
	newLine()
	write  '} */'
}

def createContractInputNodeDef(prefix, input) {
	def inputName = input.name
	def capitalizedInputName = input.name.capitalize()
	def inputType = input.type.toString().toLowerCase().capitalize()
	def multiple = input.multiple ? ", _multiple_" : ''
	def isComplex = isComplex(input)
	def description = input.description ? "    //${input.description}_" : ''
	def comment = "/* $inputType $description */"

	def node = isComplex
			? "def ${prefix}${inputName} = [:] $comment" //new ${getInputJavaType(input)} _$multiple)$description"
			: "def ${prefix}${inputName} $comment"// inputType ([olive]_${inputType}_$multiple)$description"
}


def inputName(input) {
	write " ${getInputType(input)} ${input.name} "
}
def inputType(input) {
	write " /* type ${input} */"
}

def writeIndent(message) {
	write "    $message"
}

def isComplex(input) {
	def inputType = input.type?.toString().toUpperCase().capitalize()
	def isComplex = inputType == "COMPLEX"
	isComplex
}

def toJson(def object) {
	def json =  JsonOutput.toJson(object)
	def pretty = JsonOutput.prettyPrint(json)
	pretty
}
