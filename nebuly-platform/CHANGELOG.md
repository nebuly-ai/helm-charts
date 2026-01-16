# Changelog

## v1.79.0

### Features
* Kafka now uses KRaft as consesus algorithm and deprecates Zookeeper

### Breaking changes
* If using Kafka through Strimzi operator:
  - The upgrade to this version **MUST** be done from v1.78.0
  - First set in the values.yaml **kafka.kraft=disabled**, then **kafka.kraft=migration**
  - and finally, after it is finished, remove it so it will default to **enabled**
  
## v1.78.1

### Fixes
* Fix to broken SQL query in the backend

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
