package com.bonitasoft.data.initialization.utils

import java.util.logging.Logger

import groovy.json.JsonOutput
import groovy.json.JsonSlurper

trait LoggerUtil {

    Logger logger = Logger.getLogger("org.bonitasoft")

    def log(def mess) {
        logger.info("""
********************
${mess}
********************

""" as String )
    }


    def logContract(def mess, def contract) {
        def json = JsonOutput.toJson(contract)
        def pretty = JsonOutput.prettyPrint(json)

        logger.info("""
********************
$mess:
----------
${pretty}
********************

""" as String )
    }
}

