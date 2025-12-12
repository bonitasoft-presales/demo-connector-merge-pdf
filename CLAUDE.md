# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Bonita BPM project (version 10.3.1) demonstrating the merge-pdf connector functionality. It uses the Bonita presales template as a base.

## Build Commands

```bash
# Build the project with Maven
mvn clean package -Dbonita.environment=presales

# Build using the LA builder script
./build.sh

# Run integration tests against a running Bonita server
cd IT && mvn clean verify -Dbonita.url=http://localhost:8080/bonita
# Or use the convenience script:
./runIT.sh
```

## Project Structure

- **app/** - Main Bonita application module
  - `diagrams/` - BPMN process definitions (.proc files)
  - `src-groovy/` - Groovy source files for data initialization utilities
  - `web_widgets/` - Custom UI Designer widgets
  - `web_page/` - UI Designer pages
  - `organizations/` - Organization definitions
  - `attachments/` - Sample PDF files for connector testing
  - `documentation/` - Templates for generating project documentation

- **extensions/** - Extension modules (connectors, REST API extensions)

- **IT/** - Integration tests using Bonita Test Toolkit
  - Tests use JUnit 5 with AssertJ and Awaitility
  - Tests run via maven-failsafe-plugin

- **infrastructure/** - Infrastructure configuration files

## Key Dependencies

- `connector-merge-pdf:1.2` - The PDF merge connector being demonstrated
- `bonita-presales-common` - Shared presales utilities
- `bonita-test-toolkit` - Bonita integration testing framework

## Maven Profiles

- `bundle` - Creates a standalone Bonita bundle with the application
- `docker` - Builds a Docker image for deployment

## CI/CD

The project includes a Jenkinsfile for the presales CI platform that:
1. Creates a Bonita runtime on AWS
2. Builds the project
3. Deploys to the created runtime
4. Runs integration tests
