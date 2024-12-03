# ims.cfc - Azure Instance Metadata Service (IMS) Component

## Overview

`ims.cfc` is a ColdFusion component designed to interact with Azure's Instance Metadata Service (IMS) to obtain access tokens for Azure resources secured by Azure Active Directory (AAD). This component is particularly useful when running applications on Azure Virtual Machines (VMs) or other services that support Managed Identities, allowing your application to authenticate to Azure services without embedding credentials in your code.

## Features

- **Easy Authentication**: Simplifies the process of obtaining access tokens using Azure Managed Identities.
- **Configurable**: Allows customization of API version and target resource.
- **Integration Ready**: Can be easily integrated into existing ColdFusion applications running in Azure environments.

## Requirements

- **Adobe ColdFusion or Lucee**: Compatible with ColdFusion servers capable of running CFC components.
- **Azure Environment**: Must be running within an Azure service that supports Managed Identities (e.g., Azure VMs, Azure App Service).
- **Network Access**: The application must have network access to Azure's Instance Metadata Service (`http://169.254.169.254`).

## Installation

1. **Download the `ims.cfc` File**: Place the `ims.cfc` file into your application's components directory (e.g., `components/` or `cfc/`).

2. **Verify Azure Configuration**:
   - Ensure that Managed Identity is enabled for your Azure service.
   - Assign necessary permissions to the Managed Identity for accessing Azure resources (e.g., Key Vault, Azure Storage).

## Usage

### Initialization

Instantiate the `ims.cfc` component in your application. You can optionally pass a struct of dynamic properties to override the default settings.

```coldfusion
<!--- Default Initialization --->
<cfset ims = new ims()>

<!--- Custom Initialization --->
<cfset ims = new ims({
    "api-version" = "2019-08-01",
    "resource"    = "https://management.azure.com/"
})>
```

### Obtaining an Access Token

Use the `Auth()` method to retrieve an access token.

```coldfusion
<!--- Get Access Token --->
<cfset tokenResponse = ims.Auth()>

<!--- Extract Token Details --->
<cfset accessToken = tokenResponse.access_token>
<cfset expiresIn   = tokenResponse.expires_in>
<cfset tokenType   = tokenResponse.token_type>
```

### Using the Access Token

Include the access token in the `Authorization` header when making requests to Azure services.

```coldfusion
<cfhttp url="https://myresource.azure.net/api/data" method="GET">
    <cfhttpparam type="header" name="Authorization" value="Bearer #accessToken#">
</cfhttp>

<!--- Handle Response --->
<cfoutput>#cfhttp.fileContent#</cfoutput>
```

## Properties

The component includes the following properties, which can be set during initialization or via setters:

| Property       | Type     | Default Value                 | Description                                                     |
|----------------|----------|-------------------------------|-----------------------------------------------------------------|
| `api-version`  | `string` | `"2018-02-01"`                | Specifies the IMS API version to use.                           |
| `resource`     | `string` | `"https://vault.azure.net/"`  | The Azure resource URI for which to obtain the access token.    |
| `imsEndpoint`  | `string` | *Constructed internally*      | The IMS endpoint URL. Typically does not need to be set manually.|

### Property Details

- **`api-version`**: The version of the IMS API to interact with. Update this if you need features from a newer API version.
- **`resource`**: The target resource URI for which the access token is requested (e.g., Azure Key Vault, Azure Management API).
- **`imsEndpoint`**: Automatically constructed based on the `api-version` and `resource`. Overrides are not usually necessary.

## Methods

### `init(struct dynamicProperties = {})`

Initializes the component and sets properties.

- **Parameters**:
  - `dynamicProperties` (optional): A struct containing property names and values to override defaults.
- **Returns**: The component instance (`this`).

**Example**:

```coldfusion
<cfset ims = new ims({
    "api-version" = "2019-08-01",
    "resource"    = "https://management.azure.com/"
})>
```

### `Auth()`

Fetches an access token from the Azure Instance Metadata Service.

- **Parameters**: None.
- **Returns**: A struct containing token information (`access_token`, `expires_in`, `token_type`).

**Example**:

```coldfusion
<cfset tokenResponse = ims.Auth()>
```

## Examples

### Accessing Azure Key Vault

```coldfusion
<!--- Initialize ims.cfc for Key Vault --->
<cfset ims = new ims({
    "resource" = "https://vault.azure.net/"
})>

<!--- Obtain Access Token --->
<cfset tokenResponse = ims.Auth()>
<cfset accessToken   = tokenResponse.access_token>

<!--- Access a Secret from Key Vault --->
<cfhttp url="https://mykeyvault.vault.azure.net/secrets/mySecret?api-version=7.0" method="GET">
    <cfhttpparam type="header" name="Authorization" value="Bearer #accessToken#">
</cfhttp>

<!--- Output Secret Value --->
<cfoutput>#cfhttp.fileContent#</cfoutput>
```

### Listing Azure Resource Groups

```coldfusion
<!--- Initialize ims.cfc for Azure Management API --->
<cfset ims = new ims({
    "resource" = "https://management.azure.com/"
})>

<!--- Obtain Access Token --->
<cfset tokenResponse = ims.Auth()>
<cfset accessToken   = tokenResponse.access_token>

<!--- List Resource Groups --->
<cfhttp url="https://management.azure.com/subscriptions/{subscription-id}/resourcegroups?api-version=2020-06-01" method="GET">
    <cfhttpparam type="header" name="Authorization" value="Bearer #accessToken#">
</cfhttp>

<!--- Output Resource Groups --->
<cfoutput>#cfhttp.fileContent#</cfoutput>
```

## Troubleshooting

- **Connection Issues**: Ensure your application is running in an Azure environment with network access to `http://169.254.169.254`.
- **Authentication Errors**: Verify that the Managed Identity has the necessary permissions for the target resource.
- **Incorrect API Version**: Update the `api-version` property if you encounter compatibility issues.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

Feel free to contribute to this project by submitting issues or pull requests.
