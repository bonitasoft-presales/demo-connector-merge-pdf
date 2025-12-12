package org.bonitasoft.test;

import com.bonitasoft.test.toolkit.BonitaTestToolkit;
import com.bonitasoft.test.toolkit.contract.ContractBuilder;
import com.bonitasoft.test.toolkit.junit.extension.BonitaTests;
import com.bonitasoft.test.toolkit.model.Document;
import com.bonitasoft.test.toolkit.model.ProcessDefinition;
import com.bonitasoft.test.toolkit.model.ProcessInstance;
import com.bonitasoft.test.toolkit.model.User;
import com.bonitasoft.test.toolkit.model.UserTask;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

@BonitaTests
public class MergePdfConnectorIT extends AbstractTest {

    private static final String PROCESS_NAME = "demo-merge-pdf";
    private static final String REVIEW_TASK_NAME = "review documents";

    @BeforeEach
    void beforeEach(BonitaTestToolkit toolkit) {
        toolkit.deleteBDMContent();
        toolkit.deleteProcessInstances();
    }

    @Test
    void should_merge_pdf_documents(BonitaTestToolkit toolkit) throws IOException {
        // Given
        ProcessDefinition processDefinition = toolkit.getProcessDefinition(PROCESS_NAME);
        User walter = toolkit.getUser("walter.bates");

        // Get page counts of input PDFs
        int pdf1PageCount = getPageCount("/documents/mypdf1.pdf");
        int pdf2PageCount = getPageCount("/documents/mypdf2.pdf");
        int expectedPageCount = pdf1PageCount + pdf2PageCount;
        logger.info("Input PDFs: mypdf1.pdf has {} pages, mypdf2.pdf has {} pages, expected merged: {} pages",
                pdf1PageCount, pdf2PageCount, expectedPageCount);

        // When - Start process with two PDF files from classpath resources
        logger.info("Starting process {} with 2 PDF files", PROCESS_NAME);
        ProcessInstance processInstance = processDefinition.startProcessFor(walter,
                ContractBuilder.newContract()
                        .multipleFileInput("inputPdfsDocumentInput", List.of("/documents/mypdf1.pdf", "/documents/mypdf2.pdf"))
                        .textInput("mergedDocumentName", "merged_result.pdf")
                        .build());

        assertThat(processInstance).as("Process instance should be created").isNotNull();
        logger.info("Process instance {} created", processInstance.getId());

        // Then - Wait for the review task to be ready (connector executes ON_ENTER)
        logger.info("Waiting for task '{}' to be ready", REVIEW_TASK_NAME);
        await().atMost(Duration.ofSeconds(30))
                .pollInterval(Duration.ofSeconds(1))
                .untilAsserted(() -> {
                    UserTask task = processInstance.getFirstPendingUserTask(REVIEW_TASK_NAME);
                    assertThat(task).as("Task '%s' should be pending", REVIEW_TASK_NAME).isNotNull();
                });

        UserTask reviewTask = processInstance.getFirstPendingUserTask(REVIEW_TASK_NAME);
        logger.info("Task '{}' is ready (id: {})", REVIEW_TASK_NAME, reviewTask.getId());

        // Verify the merged document was created by the connector
        Document mergedDoc = processInstance.getDocument("mergedDocument");
        assertThat(mergedDoc)
                .as("Merged document should exist after connector execution")
                .isNotNull();

        byte[] mergedContent = mergedDoc.getContent();
        logger.info("Merged document created: {} (size: {} bytes)",
                mergedDoc.getFileName(), mergedContent.length);

        assertThat(mergedContent.length)
                .as("Merged document should have content")
                .isGreaterThan(0);

        // Verify merged PDF page count equals sum of input PDFs
        int mergedPageCount = getPageCount(mergedContent);
        logger.info("Merged document has {} pages (expected: {})", mergedPageCount, expectedPageCount);

        assertThat(mergedPageCount)
                .as("Merged PDF page count should equal sum of input PDF page counts (%d + %d)", pdf1PageCount, pdf2PageCount)
                .isEqualTo(expectedPageCount);

        // Complete the review task (task contract requires the merged document)
        logger.info("Completing task '{}'", REVIEW_TASK_NAME);
        reviewTask.execute(walter, ContractBuilder.newContract()
                .fileInput("mergedDocumentDocumentInput", "/documents/mypdf1.pdf")
                .build());

        // Wait for process to complete
        logger.info("Waiting for process to complete");
        await().atMost(Duration.ofSeconds(30))
                .pollInterval(Duration.ofSeconds(1))
                .untilAsserted(() -> {
                    assertThat(processInstance.isArchived())
                            .as("Process should be archived (completed)")
                            .isTrue();
                });

        logger.info("Process {} completed successfully", processInstance.getId());
    }

    private int getPageCount(String classpathResource) throws IOException {
        try (InputStream is = getClass().getResourceAsStream(classpathResource);
             PDDocument document = PDDocument.load(is)) {
            return document.getNumberOfPages();
        }
    }

    private int getPageCount(byte[] pdfContent) throws IOException {
        try (PDDocument document = PDDocument.load(pdfContent)) {
            return document.getNumberOfPages();
        }
    }
}
