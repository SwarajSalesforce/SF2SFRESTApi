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