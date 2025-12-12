package org.bonitasoft.test;

import com.bonitasoft.test.toolkit.BonitaTestToolkit;
import com.bonitasoft.test.toolkit.junit.extension.BonitaTests;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@BonitaTests
public class UserIT extends AbstractTest{

  @BeforeEach
  void beforeEach(BonitaTestToolkit toolkit) {
    toolkit.deleteBDMContent();
    toolkit.deleteProcessInstances();
  }

  @Test
  void emptyTest(BonitaTestToolkit toolkit) {
    final com.bonitasoft.test.toolkit.model.User user = toolkit.getUser("walter.bates");

    assertThat(user.getFirstName()).isEqualTo("Walter");
    assertThat(user.getLastName()).isEqualTo("Bates");
  }

}
