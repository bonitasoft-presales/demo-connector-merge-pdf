package org.bonitasoft.test.internal;

import com.bonitasoft.test.toolkit.model.Task;

import java.util.Comparator;

/**
 * order tasks by internal ID, which is a good approximation to execution order
 */
public class TaskComparatorById implements Comparator<Task>
{
    @Override
    public int compare(Task o1, Task o2) {
        return (int) (Long.parseLong(o1.getId()) - Long.parseLong(o2.getId()));
    }
}
