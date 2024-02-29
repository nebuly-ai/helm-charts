# Roadmap

## What's blocking the Chart release

- [ ] Support of Azure OpenAI by Ingestion Worker
- [ ] User insights feature implemented with Azure OpenAI instead of OpenAI

## Fixes

- [ ] Make services restart when changing env in configmap

## Test Suite

The following are the scenarios we need to test before the release.

### Chart Installation

- [ ] Installation with default values: check that all the components are installed and running, and the genrated
  names and labels are correct.
- [ ] Installation with custom names: check that all the components are installed and running, and the genrated
  names and labels are correct.
- [ ] Installation providing the credentials through existing secrets
- [ ] Test DB secrets store
- [ ] Test KeyVault secrets store

### Smoke test

- Install the Platform with the Ingress configuration for exposing: Backend, Frontend, Event Ingestion API.
- Open Frontend page and check that it's working
- Send a request to the Event Ingestion API and check that it's working

### Authentication

- [ ] Username/password authentication
    - Install the Platform with username/password authentication, specifying the value for the initial admin password
    - Check that the admin user can log in with the specified password
- [ ] Microsoft SSO authentication
    - Install the Platform with Microsoft SSO authentication enabled
    - Check that the login with SSO works

### Data processing

- [ ] Check that the data is being processed by the Ingestion Worker (actions, interactions, topics, insights).