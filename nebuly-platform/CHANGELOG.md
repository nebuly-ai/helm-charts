# Changelog

## v1.15.0

### Breaking changes

* Rename value `openai.frustrationDetectionDeployment` to `openai.gpt4oDeployment`
* Rename value `actionsProcessing` to `primaryProcessing`
* Merge values `ingestionWorker.topicsClustering`
  and `ingestionWorker.suggestionsGeneration` into
  `secondaryProcessing`
* New `reprocessing` format:
  ```yaml
    reprocessing:
        modelSuggestions:
            enabled: false
        topicsAndActions:
            enabled: false
    ```