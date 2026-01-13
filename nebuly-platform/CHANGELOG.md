# Changelog

## v1.78.0

### Features
* Strimzi Kafka Operator now uses NodePools CR to manage brokers

## v1.17.0

### Features
* New LLMs
* Improved telemetry authentication

### Breaking changes
* A new API Key is required for the telemetry.

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
