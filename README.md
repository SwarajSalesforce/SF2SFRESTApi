# SalesforceToSalesforce Integation with Lightening Component

### Step 1--

Create connected app in the destination org from which you want to fetch the data.Get Client secret,Client Id.
Use these details in the GetAccountContactDetails as i mentioned there.

### Step 2--

Create Class named AccountContactService in your destination org.
You will find it in the  repository.

/*********************************************************************************************************************

     @Name             : AccountContactService
     @Description      : This class will send list of Account with Contacts as response to the calling System
     @CreatedBy        : Swaraj Behera
     
**********************************************************************************************************************/

@RestResource(urlMapping = '/AccountContactDetails/*')
global class AccountContactService{

    @HttpGet
/ ***************************************************************************************************

      @ Method Name: getAccountContactInfo
      @ Description: This method gets called for REST GET request.
      @ Params: 
      @ Return type :Void    
      
****************************************************************************************************/

    global static void getAccountContactInfo() {
        list<lead> lstLead = new list<lead>();
       
      try{
            RestRequest req = RestContext.request;                        
            Map<String, String> jsonHeaderElements = new Map<String, String>();
            
            for(String param: RestContext.request.params.keySet()){
                jsonHeaderElements.put(param, RestContext.request.params.get(param));                
            }

            List<Account> accountList = new List<Account>([select id,name,phone,industry,(select lastName from contacts) from account Where Id IN (Select AccountId From Contact) limit 50]);
            
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(accountList));
            RestContext.response.statusCode=200;  
                          
            }
        catch(Exception e){  
            
        }
    
    }
    }

### Step 3--

Create a lightening component named AccountContactDisplay in the Source Org and Use the javascript controller and Apex controller mentioned in the repository. Change the client id,client secret,Username,password and Instance URL in the GetAccountContactDetails.

/*

@Function Name : myAction
@Param         : component, event, helper
@CreatedBy     : Swaraj Behera

*/
({

	myAction : function(component, event, helper) {
		var action =component.get("c.getAccountContactDetails");
		
         action.setCallback(this, function(a){              
            component.set("v.accounts", a.getReturnValue());         
        });
        
        $A.enqueueAction(action);
	}
    
})


/*************************************************************************************************************************
   @ Name             : GetAccountContactDetails 
   
   @ Description      : This Class is Used to get AccountDetails from another Salesforce Org. 
   			This class is used in the AccountContactDisplay Lightening Component to show the response
			
   @ Created By       : Swaraj Behera
   
   @ Created Date     : 02/11/2017
**************************************************************************************************************************/

public  class GetAccountContactDetails {
	
private static final String CLIENTID     = 'USER_YOURCLIENTID';
private static final String CLIENTSECRET = 'USER_YOURCLIENTSECRET';
private static final String USERNAME     = 'YOUR_USERNAME';
private static final String PASSWORD     = 'YOUR_PASSWORD';
private static final String URL          = 'YOUR_INSTANCE_URL';

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
      req1.setEndpoint(URL+'/services/apexrest/AccountContactDetails');
      //URL will be your Salesforce REST API end point where you will do POST,PUT,DELETE orGET
      HttpResponse res1 = h1.send(req1);
      system.debug('RESPONSE_BODY'+res1 .getbody());
        
        List<Account> acclst = new List<Account>();

        // Parse the data according to the AccountList class
        acclst  = (List<account>)JSON.deserialize(res1.getBody(), List<account>.class);
        
        System.debug('Account list====>'+ acclst );
        
 	  return acclst;
    }
    
}

### Step 4--

Create and App call the component to see it.

<aura:application extends="force:slds">
    <c:AccountContactDisplay />
</aura:application>

Below are screenshot of it.

![lighte](https://user-images.githubusercontent.com/18612751/32320412-ba47ca74-bfe3-11e7-8353-66d53fc756cb.PNG)

Enjoy!!!!!!
