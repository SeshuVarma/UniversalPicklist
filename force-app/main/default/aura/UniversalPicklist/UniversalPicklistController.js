({
    loadData: function(cmp) {
        var action = cmp.get("c.fetchDataOfUniversalPicklist");
        action.setCallback(this, function(response){
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    cmp.set("v.listOfObjectNames", response.getReturnValue().uniqueObjectNames);
                    var mapOfObjectNamesAndFieldNames = response.getReturnValue().mapOfObjectNamesAndFieldNames;
                    var custs = [];
                    for ( var key in mapOfObjectNamesAndFieldNames ) {
                        custs.push({value:mapOfObjectNamesAndFieldNames[key], key:key});
                    }
                    cmp.set("v.lstOfMap", custs);
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecordTypes : function(cmp, e, helper){
        helper.getRecordTypes(cmp);
    },
    
    fetchPicklistFields : function(cmp, e, helper){
        cmp.set("v.disableFields", false);
        var objectSeleted = cmp.find('objectName').get('v.value');
        var map = cmp.get('v.lstOfMap');
        var items = [];
        for(var i=0; i<map.length; i++){
            if(map[i].key == objectSeleted){
                var responseAfterSplit = map[i].value;
                for(var j=0; j<responseAfterSplit.length; j++){
                    var splitEachValue = responseAfterSplit[j].split("-");
                    var item = {
                        "label": splitEachValue[0],
                        "value": splitEachValue[1]
                    };
                    items.push(item);
                }
            }
        }
        cmp.set("v.listOfPicklistFields", items);
    },
    
    fetchPicklistValues : function(cmp, e, helper){
        var picklistFieldSelected = cmp.find("picklistFieldSelected").get("v.value");
        var action = cmp.get("c.getPicklistFieldsAndValues");
        cmp.set("v.disableAction",false);
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value'),
            "picklistField": picklistFieldSelected
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    cmp.set("v.listOfPicklistValues", response.getReturnValue());
                    break;
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchRecordTypesOfSelectedValue : function(cmp, e, helper){
        cmp.set("v.spinner", true);
        helper.getRecordTypes(cmp);
        var action = cmp.get("c.getRecordTypesOfSelectedValue");
        var picklistFieldSelected = cmp.find("picklistFieldSelected").get("v.value");
        var picklistValueSelected = cmp.get("v.picklistValueSelected");
        cmp.set("v.valueInTheDescription", picklistValueSelected);
        action.setParams({
            "objectName": cmp.find('objectName').get('v.value'),
            "picklistField": picklistFieldSelected,
            "picklistValue": picklistValueSelected
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            switch (status){
                case 'SUCCESS':
                    cmp.set("v.displayAvailableAndSelectedRecordTypes", true);
                    var items = [];
                    var items1 = [];
                    var a = response.getReturnValue();
                    for(var i = 0; i < a.length; i++){
                        var valueAfterSplit = a[i].split(',');
                        var item = {
                            "label": valueAfterSplit[0],
                            "value": valueAfterSplit[1]
                        };
                        items1.push(valueAfterSplit[1]);
                        items.push(item);
                    }
                    //cmp.set("v.listOfAvailableRecordTypes",items)
                    cmp.set("v.listOfSelectedRecordTypes", items1);
                    cmp.set("v.spinner", false);
                    break;
            }
        });
        $A.enqueueAction(action);
    },
    
    onSave : function(cmp, e, helper){
        var selectedAction = cmp.get("v.selectedAction");
        if(selectedAction == 'Create'){
            helper.createNewPicklistValue(cmp);
        }
        if(selectedAction == 'Update'){
            helper.updatePicklistValue(cmp);
        }
    }
})