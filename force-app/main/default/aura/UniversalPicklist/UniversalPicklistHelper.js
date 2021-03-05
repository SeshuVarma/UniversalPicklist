({
    getRecordTypes : function(cmp) {
        cmp.set("v.spinner", true);
        var actionSelected = cmp.find('action').get('v.value');
        if(actionSelected == 'Create'){
            cmp.set("v.disablePicklistValue", true); 
            cmp.set("v.displayAvailableAndSelectedRecordTypes", false);
        }
        else if(actionSelected == 'Update'){
            cmp.set("v.disablePicklistValue", false); 
        }
        var action = cmp.get("c.getAllRecordTypes");
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value')
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    var items = [];
                    var a = response.getReturnValue();
                    for (var i = 0; i < a.length; i++) {
                        var valueAfterSplit = a[i].split(',');
                        var item = {
                            "label": valueAfterSplit[0],
                            "value": valueAfterSplit[1]
                        };
                        items.push(item);
                    }
                    cmp.set("v.listOfAvailableRecordTypes", items);
                    cmp.set("v.spinner", false);
                    break;
            }
        });
        $A.enqueueAction(action);
    },
    
    createNewPicklistValue : function(cmp, e, helper){
        cmp.set("v.spinner", true);
        var listOfSelectedRecordTypes = cmp.get("v.listOfSelectedRecordTypes");
        var picklistFieldSelected = cmp.find('picklistFieldSelected').get('v.value');
        var picklistValueSelected = cmp.get("v.picklistValueSelected");
        var valueInTheDescription = cmp.get("v.valueInTheDescription");
        var selectedAction = cmp.get("v.selectedAction");
        
        var action = cmp.get("c.createNewPicklistValue");
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value'),
            "picklistFieldSelected": picklistFieldSelected,
            "valueInTheDescription" : valueInTheDescription,
            "selectedAction": selectedAction
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    this.updateRecordTypeDuringPickValueCreation(cmp, e, helper);
                    break;
                case 'ERROR':
                    cmp.set("v.spinner", false);
                    var errors = response.getError();
                    this.showToast(cmp, e, helper, errors[0].message, 'error');
                    window.scrollTo(0, 0);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateRecordTypeDuringPickValueCreation : function(cmp, e, helper){
        var listOfSelectedRecordTypes = cmp.get("v.listOfSelectedRecordTypes");
        var picklistFieldSelected = cmp.find('picklistFieldSelected').get('v.value');
        var picklistValueSelected = cmp.get("v.picklistValueSelected");
        var valueInTheDescription = cmp.get("v.valueInTheDescription");
        
        var action = cmp.get("c.updateRecordTypeDuringPickValueCreation");
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value'),
            "picklistFieldSelected" : picklistFieldSelected,
            "listOfSelectedRecordTypes": listOfSelectedRecordTypes,
            "valueInTheDescription" : valueInTheDescription
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    cmp.set("v.spinner", false);
                    this.showToast(cmp, e, helper, 'The picklist value has been created successfully.', 'success');
                    window.scrollTo(0, 0);
                    break;
                case 'ERROR':
                    cmp.set("v.spinner", false);
                    var errors = response.getError();
                    if(errors[0].message.includes('SUCCESS')){
                        this.showToast(cmp, e, helper, 'Picklist value has been successfully created. Since no RecordType is selected, value is added into any of the RecordTypes', 'success');
                    }
                    else {
                        this.showToast(cmp, e, helper, errors[0].message, 'error');
                    }
                    window.scrollTo(0, 0);
            }
        });
        $A.enqueueAction(action);
    },
    
    updatePicklistValue : function(cmp, e, helper){
        cmp.set("v.spinner", true);
        var listOfSelectedRecordTypes = cmp.get("v.listOfSelectedRecordTypes");
        var picklistFieldSelected = cmp.find('picklistFieldSelected').get('v.value');
        var picklistValueSelected = cmp.get("v.picklistValueSelected");
        var valueInTheDescription = cmp.get("v.valueInTheDescription");
        var selectedAction = cmp.get("v.selectedAction");
        var action = cmp.get("c.updatePicklistValue");
        
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value'),
            "picklistFieldSelected": picklistFieldSelected,
            "picklistValueSelected": picklistValueSelected,
            "valueInTheDescription" : valueInTheDescription,
            "selectedAction": selectedAction
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    this.updateRecordTypeDuringPickValueUpdation(cmp, e, helper);
                    break;
                case 'ERROR':
                    var errors = response.getError();
                    cmp.set("v.spinner", false);
                    this.showToast(cmp, e, helper, errors[0].message, 'error');
                    window.scrollTo(0, 0);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateRecordTypeDuringPickValueUpdation : function(cmp, e, helper){
        var listOfSelectedRecordTypes = cmp.get("v.listOfSelectedRecordTypes");
        var listOfAvailableRecordTypes = cmp.get("v.listOfAvailableRecordTypes");
        var picklistFieldSelected = cmp.find('picklistFieldSelected').get('v.value');
        var picklistValueSelected = cmp.get("v.picklistValueSelected");
        var valueInTheDescription = cmp.get("v.valueInTheDescription");
        var selectedAction = cmp.get("v.selectedAction");
        
        var action = cmp.get("c.updateRecordTypeDuringPickValueUpdation");
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value'),
            "picklistFieldSelected" : picklistFieldSelected,
            "listOfSelectedRecordTypes" : listOfSelectedRecordTypes,
            "picklistValueSelected" : picklistValueSelected,
            "valueInTheDescription" : valueInTheDescription,
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    this.removeValueFromRecordType(cmp, e, helper)
                    break;
                case 'ERROR':
                    var errors = response.getError();
                    cmp.set("v.spinner", false);
                    if(errors[0].message.includes('SUCCESS') || errors[0].message.includes('IO Exception: Read timed out')){
                        this.showToast(cmp, e, helper, 'Picklist value has been successfully updated. Since no RecordType is selected, value is not added into any of the RecordTypes', 'success');
                        this.removeValueFromRecordType(cmp, e, helper)
                    }
                    else {
                        this.showToast(cmp, e, helper, errors[0].message, 'error');
                    }
                    window.scrollTo(0, 0);
            }
        });
        $A.enqueueAction(action);
    },
    
    removeValueFromRecordType : function(cmp, e, helper){
        var listOfSelectedRecordTypes = cmp.get("v.listOfSelectedRecordTypes");
        var listOfAvailableRecordTypes = cmp.get("v.listOfAvailableRecordTypes");
        var picklistFieldSelected = cmp.find('picklistFieldSelected').get('v.value');
        var picklistValueSelected = cmp.get("v.picklistValueSelected");
        var valueInTheDescription = cmp.get("v.valueInTheDescription");
        var selectedAction = cmp.get("v.selectedAction");
        var lst = [];
        for(var i=0; i<listOfAvailableRecordTypes.length; i++){
            lst.push(listOfAvailableRecordTypes[i]['value']);
        }
        
        var action = cmp.get("c.removeValueFromRecordType");
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value'),
            "picklistFieldSelected" : picklistFieldSelected,
            "listOfSelectedRecordTypes" : listOfSelectedRecordTypes,
            "listOfAvailableRecordTypes" : lst,
            "picklistValueSelected" : picklistValueSelected,
            "valueInTheDescription" : valueInTheDescription,
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    cmp.set("v.spinner", false);
                    this.showToast(cmp, e, helper, 'The picklist value has been updated successfully.', 'success');
                    window.scrollTo(0, 0);
                    break;
                case 'ERROR':
                    var errors = response.getError();
                    cmp.set("v.spinner", false);
                    if(errors[0].message.includes('IO Exception: Read timed out')){
                        this.showToast(cmp, e, helper, 'The picklist value has been updated successfully.', 'success');
                    }
                    else{
                        this.showToast(cmp, e, helper, errors[0].message, 'error');
                    }
                    window.scrollTo(0, 0);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(cmp, e, helper, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": message,
            "type": type,
        });
        toastEvent.fire();
    },
    
})