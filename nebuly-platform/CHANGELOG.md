# Changelog

## [Unreleased]

### Breaking changes

* Rename value `openai.deploymentFrustration` to `openai.gpt4oDeployment`
* Rename value `actionsProcessing` to `primaryProcessing`
* Merge values `ingestionWorker.secondaryProcessing`
  and `ingestionWorker.secondaryProcessing` into
  `secondaryProcessing`
* New `reprocessing` format:
  ```yaml
    reprocessing:
        modelSuggestions:
            enabled: false
        topicsAndActions:
            enabled: false
    ```