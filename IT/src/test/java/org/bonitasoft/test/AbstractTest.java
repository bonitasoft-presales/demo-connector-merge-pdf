package org.bonitasoft.test;

import com.bonitasoft.test.toolkit.model.ProcessInstance;
import com.bonitasoft.test.toolkit.model.Task;
import com.bonitasoft.test.toolkit.model.TaskState;
import org.bonitasoft.test.internal.TaskComparatorById;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class AbstractTest {

    public static final Logger logger = LoggerFactory.getLogger("org.bonitasoft.test");

    protected static void logProcessInstanceDetails(ProcessInstance processInstance) {
        List<String> seenInstances = new ArrayList<>();
        logAllProcessInstanceDetails(processInstance, seenInstances);
    }

    private static void logAllProcessInstanceDetails(ProcessInstance processInstance, List<String> seenInstances) {
        logger.error("Process instance [{}] didn't finished in expected time", processInstance.getId());
        logger.error("Process instance [{}] has [{}] failed flowNodes", processInstance.getId(), processInstance.getNumberOfFailedFlowNodes());
        final List<Task> tasks = processInstance.searchTasks();
        TaskComparatorById taskComparatorById = new TaskComparatorById();
        tasks.sort(taskComparatorById);
        for (Task task : tasks) {
            final TaskState state = task.getState();
            if (state.equals(TaskState.FAILED)) {
                logger.error("task #{} [{}] [{}] - state: [{}]", task.getId(), task.getType(), task.getName(), state);
            } else {
                logger.info("task #{} [{}] [{}] - state: [{}]", task.getId(), task.getType(), task.getName(), state);
            }
        }
    }
}
