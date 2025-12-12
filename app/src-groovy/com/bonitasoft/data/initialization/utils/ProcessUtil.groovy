package com.bonitasoft.data.initialization.utils

import java.util.concurrent.TimeoutException

import org.bonitasoft.engine.bpm.flownode.ActivityStates
import org.bonitasoft.engine.bpm.flownode.HumanTaskInstanceSearchDescriptor
import org.bonitasoft.engine.identity.UserNotFoundException
import org.bonitasoft.engine.search.SearchOptionsBuilder

import com.bonitasoft.engine.api.APIAccessor

trait ProcessUtil implements LoggerUtil{

	def startProcessInstance(APIAccessor apiAccessor, long userId, String processName, def contract) {
		def processDefinitionId = getProcessDefinitionId(apiAccessor,processName)
		log ("""
start process in latest version:${processName}
*********
contract:
$contract""")
		startProcess(apiAccessor,userId,processDefinitionId,contract)
	}
	
	def startProcessInstance(APIAccessor apiAccessor, long userId, String processName, String processVersion, def contract) {
		def processDefinitionId = getProcessDefinitionId(apiAccessor,processName,processVersion)
		log ("""
start process:${processName} in version:${processVersion}
*********
contract:
$contract""")
		startProcess(apiAccessor,userId,processDefinitionId,contract)
	}
	
	def startProcess(APIAccessor apiAccessor, long userId, long processDefinitionId, def contract) {
		def processInstanceId = apiAccessor.getProcessAPI()
				.startProcessWithInputs(userId, processDefinitionId ,contract).id
		apiAccessor.getProcessAPI().addProcessCommentOnBehalfOfUser(processInstanceId, "Started by DataInitialization process", userId)
			processInstanceId
	}

	def taskId(APIAccessor apiAccessor, long rootProcessInstanceId, String taskName) {

		log ("searching task - rootProcessInstanceId:$rootProcessInstanceId - taskName:$taskName")
		long taskId = -1
		Condition.loop {
			def searchResult = apiAccessor.getProcessAPI().searchHumanTaskInstances(new SearchOptionsBuilder(0, 1)
					.filter(HumanTaskInstanceSearchDescriptor.NAME, taskName)
					.filter(HumanTaskInstanceSearchDescriptor.ROOT_PROCESS_INSTANCE_ID, rootProcessInstanceId)
					.filter(HumanTaskInstanceSearchDescriptor.STATE_NAME, ActivityStates.READY_STATE)
					.done())
			taskId = searchResult.count == 1 ? searchResult.getResult()[0].id : -1
			log ("search task - rootProcessInstanceId:$rootProcessInstanceId - taskName:$taskName - taskId:$taskId")
		} until { taskId >= 0 }
		return taskId
	}

	def assignAndExecuteTask(APIAccessor apiAccessor, long userId, long processInstanceId , def contract, def taskName){
		execute(apiAccessor, userId,processInstanceId,contract,taskName,true)
	}

	def executeTask(APIAccessor apiAccessor,long userId, long processInstanceId , def contract, def taskName){
		execute(apiAccessor, userId,processInstanceId,contract,taskName,false)
	}

	long getProcessDefinitionId(APIAccessor apiAccessor,String processName) {
		apiAccessor.getProcessAPI().getLatestProcessDefinitionId(processName)
	}

	long getProcessDefinitionId(APIAccessor apiAccessor,String processName, String processVersion) {
		apiAccessor.getProcessAPI().getProcessDefinitionId(processName,processVersion)
	}


	def execute(APIAccessor apiAccessor,long userId, long processInstanceId , def contract, def taskName,boolean assign){
		def taskId=taskId(apiAccessor,processInstanceId,taskName)
		//logContract(taskName, contract)

		log ("""$taskName
*********
$contract
 """)
		if (assign) {
			apiAccessor.getProcessAPI().assignAndExecuteUserTask(userId, taskId , contract)
		}else {
			apiAccessor.getProcessAPI().executeUserTask(userId, taskId, contract)
		}
		apiAccessor.getProcessAPI().addProcessCommentOnBehalfOfUser(processInstanceId, "$taskName done by DataInitialization process", userId)
	}

	def getParameterValue(APIAccessor apiAccessor, long processDefinitionId,String parameterName) {
		def value = apiAccessor.getProcessAPI().getParameterInstance(processDefinitionId, parameterName).value
		log ("parameter $parameterName=$value")
		value
	}

}



class Condition {

	private Closure code

	int timeout = 0

	static Condition loop( Closure code ) {
		new Condition(code:code)
	}

	void until( Closure test ) {
		if(timeout > 30000) {
			throw new TimeoutException("Condition cannot be evaluated to true before the timeout expires.")
		}
		Thread.sleep(100)
		code()
		while (!test()) {
			Thread.sleep(100)
			timeout += 100
			code()
		}
	}
}

