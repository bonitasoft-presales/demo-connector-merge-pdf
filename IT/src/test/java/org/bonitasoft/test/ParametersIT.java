package org.bonitasoft.test;

import com.bonitasoft.test.toolkit.BonitaTestToolkit;
import com.bonitasoft.test.toolkit.junit.extension.BonitaTests;
import com.bonitasoft.test.toolkit.model.ProcessDefinition;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@BonitaTests
public class ParametersIT extends AbstractTest {

    @BeforeEach
    void beforeEach(BonitaTestToolkit toolkit) {
        toolkit.deleteBDMContent();
        toolkit.deleteProcessInstances();
    }

    @Test
    void parametersTest(BonitaTestToolkit toolkit) {
        ProcessDefinition processWithServerUrlParam = toolkit.getProcessDefinition("_processWithServerUrlParam");
        String serverUrl = processWithServerUrlParam.getParameterValue("serverUrl");
        logger.info("serverUrl value: {}",serverUrl);
        assertThat(serverUrl).as("should have a value").isNotEmpty();

    }

}
