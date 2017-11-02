/***************************************************************************************************************************************************************************************
   @ Name             : GetAccountContactDetails 
   @ Description      : This Class is Used to get AccountDetails from another Salesforce Org. 
   						This class is used in the AccountContactDisplay Lightening Component to show the response
   @ Created By       : Swaraj Behera
   @ Created Date     : 02/11/2017
**************************************************************************************************************************/

public  class GetAccountContactDetails {
	
private static final String CLIENTID     = '3MVG9ZL0ppGP5UrACnoIGIA9ErWLEWNjpJ4do7KxYllu_eVX4G8CUebI8NkHmGX0EDqaU19zAwlaN4zTnH6mR';
private static final String CLIENTSECRET = '1872222491789468577';
private static final String USERNAME     = 'swaraj.salesforce@outlook.com';
private static final String PASSWORD     = 'health@123';
private static final String URL          = 'https://swaraj1933-dev-ed.my.salesforce.com';

/****************************************************************************************************
    @Method Name: getAccountContactDetails
    @Description: This method gets called from the lightening Component
    @Params: 
    @Return type :list<account>    
****************************************************************************************************/   
@AuraEnabled
public static list<account> getAccountContactDetails(){
    String accessToken = getAccessToken();
    if(accessToken != null){
        list<account> accountList = new List<account>();
        accountList = getAccountContact(accessToken);
        if(accountList != null){
            return accountList;     
        }
    }
    return null;
}
/****************************************************************************************************
    @Method Name : getAccessToken
    @Description : This method gets the access token from another instance
    @Params      : 
    @Return type :String   
****************************************************************************************************/   
public static String getAccessToken(){
String reqbody = 'grant_type=password&client_id='+CLIENTID+'&client_secret='+CLIENTSECRET+'&username='+USERNAME+'&password='+PASSWORD;

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint(URL+'/services/oauth2/token');//Note if my domain is set up use the proper domain name else use login.salesforce.com for prod or developer or test.salesforce.com for sandbox instance
		
		System.debug('Request Token Body===>' + reqbody );
		System.debug('Set EndPoint' + reqbody );
		HttpResponse res = h.send(req);
		System.debug('Response==>'+ res);
		
		OAuth2 objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
        if(objAuthenticationInfo.access_token!=null){
            System.debug('Token==>'+ objAuthenticationInfo.access_token);
            return String.valueof(objAuthenticationInfo.access_token);
        }
     return null;
}
/***********************************************************************************************************************
    @Method Name : getAccountContact
    @Description : This method calls to the external Salesforce System's REST API and get the result from that.
    @Params      : 
    @Return type : list<Account>   
*************************************************************************************************************************/  
public static list<Account> getAccountContact(String accessToken){
        
      Http h1 = new Http();
      HttpRequest req1 = new HttpRequest();
      req1.setHeader('Authorization','Bearer '+accessToken);
      req1.setHeader('Content-Type','application/json');
      req1.setHeader('accept','application/json');
    
      req1.setMethod('GET');
      req1.setEndpoint(URL+'/services/apexrest/AccountContactDetails');//URL will be your Salesforce REST API end point where you will do POST,PUT,DELETE orGET
      HttpResponse res1 = h1.send(req1);
      system.debug('RESPONSE_BODY'+res1 .getbody());
        
        List<Account> acclst = new List<Account>();

        // Parse the data according to the AccountList class
        acclst  = (List<account>)JSON.deserialize(res1.getBody(), List<account>.class);
        
        System.debug('Account list====>'+ acclst );
        
 	  return acclst;
    }
    
}