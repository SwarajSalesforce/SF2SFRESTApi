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


/*********************************************************************************************************************
* Name             : AccountContactService
* Description      : This class will send list of Account with Contacts as response to the calling System
**********************************************************************************************************************/

@RestResource(urlMapping = '/AccountContactDetails/*')
global class AccountContactService{

    @HttpGet
       
    // ***************************************************************************************************
    // Method Name: getAccountContactInfo
    // Description: This method gets called for REST GET request.
    // Params: 
    // Return type :Void    
    //****************************************************************************************************

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

### Step 4--

Create and App call the component to see it.

<aura:application extends="force:slds">
    <c:AccountContactDisplay />
</aura:application>

Below are screenshot of it.

![lighte](https://user-images.githubusercontent.com/18612751/32320412-ba47ca74-bfe3-11e7-8353-66d53fc756cb.PNG)

Enjoy!!!!!!
