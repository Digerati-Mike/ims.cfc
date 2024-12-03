component accessors="true" {
    
	property 
		name="api-version"
		type="string"
		setter=true
    default="2018-02-01"
		hint="API Version to use when running requests against the internal metadata service.";


	property 
		name="resource"
		type="string"
		setter=true
    default="https://vault.azure.net/"
		hint="Resource / API to obtain a JWT token for.";
    

	property 
		name="imsEndpoint"
		type="string"
		setter=true
		hint="Endpoint of the internal metadata service";


    /**
    * @hint Initialize Component properties
    * @retrunType any
    **/
    public function init( struct dynamicProperties = {} ){
        
        // Set the default properties
        for (var key in dynamicProperties) {

            variables[ Trim(key) ] = dynamicProperties[ key ];
        };  

        // Set the IMS Query String with the concantenated values
        Variables.ImsQueryString = "api-version=" & Variables['api-version'] & "&resource=" & Variables['resource']

        // Construct the final imsEndpoint url
        variables.imsEndpoint = "http://169.254.169.254/metadata/identity/oauth2/token?" & variables.imsQueryString
        

        return this
    };

    
    /**
    * @hint Get access_token
    * @retrunType struct
    **/
    public function Auth(){
        
        // Initialize The httpService
        httpService = new Http( 
            url = variables.imsEndpoint, 
            method = "GET"
        );


        // Add the Headers
        httpService.addParam(
            type = "header", 
            name = "Metadata", 
            value = true
        );
        

        // Send the api request and set the response to a variable
        Variables.response = httpService.send().getPrefix();
        

        // check if the content is JSON and automatically deserialize if it is
        if (structKeyExists(Variables.response, "fileContent") && IsJSON( Variables.response.fileContent ) ) {

            Variables.response = DeserializeJSON( Variables.response.fileContent )
            
        }
        
        return Variables.response;
    }
}
