# Roadmap

## What's blocking the Chart release

- [x] Support of Azure OpenAI by Ingestion Worker
- [x] User insights feature implemented with Azure OpenAI instead of OpenAI

## Fixes

- [x] Make services restart when changing env in configmap

## Test Suite

The following are the scenarios we need to test before the release.

### Chart Installation

- [x] Installation with default values: check that all the components are installed and running, and the genrated
  names and labels are correct.
- [x] Installation with custom names: check that all the components are installed and running, and the genrated
  names and labels are correct.
- [x] Installation providing the credentials through existing secrets
- [x] Test DB secrets store
- [x] Test KeyVault secrets store

### Smoke test

- Install the Platform with the Ingress configuration for exposing: Backend, Frontend, Event Ingestion API.
- Open Frontend page and check that it's working
- Send a request to the Event Ingestion API and check that it's working

### Authentication

- [x] Username/password authentication
    - Install the Platform with username/password authentication, specifying the value for the initial admin password
    - Check that the admin user can log in with the specified password
- [x] Microsoft SSO authentication
    - Install the Platform with Microsoft SSO authentication enabled
    - Check that the login with SSO works

### Data processing

- [x] Check that the data is being processed by the Ingestion Worker (actions, interactions, topics, insights).