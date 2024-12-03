# Azure IMDS Authentication Component for ColdFusion

This ColdFusion component provides a simple interface to obtain an access token from Azure's Instance Metadata Service (IMDS). It enables applications running on Azure Virtual Machines or App Services to authenticate securely without the need for hardcoded credentials.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Initialization](#initialization)
  - [Authentication](#authentication)
- [Properties](#properties)
- [Methods](#methods)
- [Example](#example)
- [License](#license)

## Introduction

Azure's Instance Metadata Service (IMDS) provides information about currently running virtual machine instances and allows applications to securely obtain access tokens for Azure resources. This component abstracts the process of constructing the appropriate requests to IMDS and parsing the responses.

## Prerequisites

- ColdFusion 2016 or later
- An application running on an Azure Virtual Machine or App Service with Managed Identity enabled
- Network access to the IMDS endpoint (`169.254.169.254`)

## Installation

1. **Download the Component**

   Save the component code into a file named `AzureIMDS.cfc`.

2. **Include in Your Project**

   Place the `AzureIMDS.cfc` file in your project's directory or in a location accessible to your application.

## Usage

### Initialization

Create an instance of the component and initialize it with optional dynamic properties.

```coldfusion
imdsAuth = new AzureIMDS();
```

You can also pass a struct of dynamic properties to override the defaults:

```coldfusion
imdsAuth = new AzureIMDS({
    "api-version": "2020-06-01",
    "resource": "https://management.azure.com/"
});
```

### Authentication

Call the `Auth()` method to obtain an access token.

```coldfusion
accessTokenResponse = imdsAuth.Auth();
```

The `Auth()` method returns a struct containing the access token and other related information.

## Properties

- **api-version** (`string`)

  - **Default**: `"2018-02-01"`
  - **Description**: The API version to use when making requests to the IMDS.

- **resource** (`string`)

  - **Default**: `"https://vault.azure.net/"`
  - **Description**: The Azure resource URI for which the access token is requested.

- **imsEndpoint** (`string`)

  - **Description**: The full endpoint URL of the IMDS. This is constructed during initialization and typically does not need to be set manually.

## Methods

### `init(struct dynamicProperties = {})`

Initializes the component with optional dynamic properties.

- **Parameters**:
  - `dynamicProperties` (`struct`, optional): A struct of properties to override the defaults.

- **Returns**: The initialized component instance.

### `Auth()`

Sends a request to the IMDS to obtain an access token.

- **Returns**: A struct containing the access token and associated metadata.

## Example

```coldfusion
<cfscript>
// Create an instance of the IMDS Authentication component
imdsAuth = new AzureIMDS();

// Optionally, initialize with custom properties
imdsAuth.init({
    "api-version": "2020-06-01",
    "resource": "https://management.azure.com/"
});

// Obtain the access token
accessTokenResponse = imdsAuth.Auth();

// Extract the access token
accessToken = accessTokenResponse.access_token;

// Use the access token in subsequent API calls
httpService = new Http(
    url = "https://management.azure.com/subscriptions?api-version=2020-01-01",
    method = "GET"
);
httpService.addParam(
    type = "header",
    name = "Authorization",
    value = "Bearer " & accessToken
);
apiResponse = httpService.send().getPrefix();

// Process the API response
if (structKeyExists(apiResponse, "fileContent") && IsJSON(apiResponse.fileContent)) {
    apiData = DeserializeJSON(apiResponse.fileContent);
    // Work with the API data
}
</cfscript>
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
