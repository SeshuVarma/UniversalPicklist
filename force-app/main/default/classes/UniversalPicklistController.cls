public with sharing class UniversalPicklistController {
    
    @AuraEnabled
    public static wrapperClass fetchDataOfUniversalPicklist(){
        Map<String, List<String>> mapOfObjectNamesAndFieldNames =  new Map<String, List<String>>();
        List<String> uniqueObjectNames = new List<String>();
        
        List<Universal_PickList__c> allRecords = new List<Universal_PickList__c>([SELECT id, Name, Object_Name__c, Picklist__c FROM Universal_PickList__c]);
        
        for(Universal_PickList__c objectName : allRecords){
            if(!uniqueObjectNames.contains(objectName.Object_Name__c)){
                uniqueObjectNames.add(objectName.Object_Name__c);
            }
        }
        for(Universal_PickList__c rec : allRecords) {
            if(mapOfObjectNamesAndFieldNames.containsKey(rec.Object_Name__c)) {
                List<String> fieldNames = mapOfObjectNamesAndFieldNames.get(rec.Object_Name__c);
                fieldNames.add(rec.Name+'-'+rec.Picklist__c);
                mapOfObjectNamesAndFieldNames.put(rec.Object_Name__c, fieldNames);
            } else {
                mapOfObjectNamesAndFieldNames.put(rec.Object_Name__c, new List<String> { rec.Name+'-'+rec.Picklist__c });
            }
        }
        wrapperClass returnwrapperClass = new  wrapperClass ();
        returnwrapperClass.uniqueObjectNames = uniqueObjectNames;
        returnwrapperClass.mapOfObjectNamesAndFieldNames = mapOfObjectNamesAndFieldNames;
        return returnwrapperClass;
    }
    
    @AuraEnabled
    public static List<String> getAllRecordTypes(String objectName){
        List<String> recordTypes = new List<String>();
        for(RecordType recordType : [SELECT Name, DeveloperName FROM RecordType WHERE sObjectType =:objectName]){
            recordTypes.add(recordType.Name +','+ recordType.DeveloperName);
        }
        return recordTypes;
    }
    
    @AuraEnabled
    public static List<String> getPicklistFieldsAndValues(String objectName, String picklistField){
        List<String> listOfPicklistValues = new list<String>();
        List<String> listOfPicklistFields = new List<String>();
        if(String.isBlank(picklistField)){
            SObjectType accountType = Schema.getGlobalDescribe().get(objectName);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            for(String fieldAPIName : mfields.keySet()){
                Schema.DisplayType fieldtype = mfields.get(fieldAPIName).getDescribe().getType();
                if(String.ValueOf(fieldtype) == 'PICKLIST'){
                    String fieldLabel = mfields.get(fieldAPIName).getDescribe().getLabel();
                    String returnString = fieldLabel +','+ fieldAPIName;
                    listOfPicklistFields.add(returnString);
                }
            }
            return listOfPicklistFields;
        }
        else if(!String.isBlank(picklistField)){
            Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
            Sobject genericObject = convertType.newSObject();
            sObject obj = (sObject)convertType.newSObject();
            Schema.sObjectType objType = obj.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            
            // Get a map of fields for the SObject
            map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
            
            // Get the list of picklist values for this field.
            list < Schema.PicklistEntry > values =
                fieldMap.get(picklistField).getDescribe().getPickListValues();
            
            // Add these values to the selectoption list.
            for (Schema.PicklistEntry a: values) {
                listOfPicklistValues.add(a.getValue());
            }
            return listOfPicklistValues;
        }
        return NULL;
    }
    
    @AuraEnabled
    public static list<String> getRecordTypesOfSelectedValue(String objectName, String picklistField, String picklistValue){
        List<String> listOfAllRecordTypes = getAllRecordTypes(objectName);
        Map<String, List<String>> picklistValuesByRecordType = getDependentPicklistValuesByRecordType(objectName, listOfAllRecordTypes, picklistField);
        List<String> listOfSelectedOptions = new List<String>();
        
        for(String recordType : listOfAllRecordTypes){
            String[] valueAfterSplit = recordType.split(',');
            if( picklistValuesByRecordType.containsKey(valueAfterSplit[0]) 
               && picklistValuesByRecordType.get(valueAfterSplit[0]).contains(picklistValue) ){
                   listOfSelectedOptions.add(valueAfterSplit[0] +','+ valueAfterSplit[1]);
               }
        }
        return listOfSelectedOptions;
    }
    
    public static Map<String, List<String>> getDependentPicklistValuesByRecordType(String objectName, List<String> recordTypes, String fieldName){
        Map<String, List<String>> recordTypePicklistValuesMap = new Map<String, List<String>>();
        List<String> listofavailablevalue = new List<String>();
        List<String> listOfStrings = new List<String>();
        for(String r : recordTypes){
            String[] valueAfterSplit = r.split(',');
            String objectRecordType = objectName + '.' + valueAfterSplit[1];
            listOfStrings.add(objectRecordType);
        }
        
        // Create serviceMetadataService.MetadataPort service = createService();
            MetadataApiService.MetadataPort service = createService();
        
        
        //MetadataApiService.RecordType recordType = (MetadataApiService.RecordType) service.readMetadata('RecordType', new String[] { 'Account.Billing' }).getRecords()[0];
        
        list<MetadataApiService.RecordType> recordType = new List<MetadataApiService.RecordType>();
        for(String s : listOfStrings){
            MetadataApiService.RecordType r = (MetadataApiService.RecordType)service.readMetadata('RecordType', new String[] { s }).getRecords()[0];
            recordType.add(r);
        }
        for( MetadataApiService.RecordType rt : recordType ){
            for ( MetadataApiService.RecordTypePicklistValue rpk : rt.picklistValues ) {
                if ( rpk.picklist == fieldName ) {
                    for ( MetadataApiService.PicklistValue pk : rpk.values ) {
                        if(recordTypePicklistValuesMap.containsKey(rt.label)) {
                            List<String> values = recordTypePicklistValuesMap.get(rt.label);
                            values.add(EncodingUtil.urlDecode(String.valueof(pk.fullName),'UTF-8'));
                            recordTypePicklistValuesMap.put(rt.label, values);
                        } else {
                            recordTypePicklistValuesMap.put(rt.label, new List<String> { EncodingUtil.urlDecode(String.valueof(pk.fullName),'UTF-8') });
                        }
                    }
                }
            }
        }
        return recordTypePicklistValuesMap;
    }
    
    @AuraEnabled
    public static void createNewPicklistValue(String objectName, String picklistFieldSelected, String valueInTheDescription, String selectedAction ){
        if(picklistFieldSelected.contains('__c')){
            createPickValueForCustomField(objectName, picklistFieldSelected, valueInTheDescription, selectedAction);
        }
        else{
            createPickValueForStandardField(objectName, picklistFieldSelected, valueInTheDescription, selectedAction);
        }
    }
    
    public static void createPickValueForCustomField(String objectName, String picklistFieldSelected, String valueInTheDescription, String selectedAction){
        MetadataApiService.MetadataPort service = createService(); 
        
        String picklistapiname = objectName+'.'+picklistFieldSelected;
        
        MetadataApiService.CustomField customField = (MetadataApiService.CustomField) service.readMetadata('CustomField', new String[] { picklistapiname }).getRecords()[0];
        
        //Custom
        MetadataApiService.CustomValue two = new MetadataApiService.CustomValue();
        two.fullName = valueInTheDescription;
        two.default_x = false;
        customField.valueSet.valueSetDefinition.value.add(two); 
        
        // Update 
        List<MetadataApiService.SaveResult> lstResults = service.updateMetadata( new MetadataApiService.Metadata[] { customField });
        for (MetadataApiService.SaveResult objResult : lstResults) {
            if (objResult.success) {
                System.debug('Successfully updated');
            }
            else {                       
                if(objResult.errors.size() > 0){
                    System.debug('eror : ' + objResult.errors[0].message);
                    throw new AuraHandledException('eror : ' + objResult.errors[0].message);
                }
            }
        }
    }
    
    public static void createPickValueForStandardField(String objectName, String picklistFieldSelected, String valueInTheDescription, String selectedAction){
        MetadataApiService.MetadataPort service = createService(); 
        
        String picklistapiname;
        Map<String, Universal_PickList__c> mapOfStandardValueSet = new Map<String, Universal_PickList__c>();
        for(Universal_PickList__c stdvalue : [SELECT Picklist__c, StandardValueSet_Format__c, Object_Name__c From Universal_PickList__c WHERE Object_Name__c =: objectName]){
            mapOfStandardValueSet.put(stdvalue.Picklist__c.toLowerCase(), stdvalue);
        }
        if(mapOfStandardValueSet.keySet().contains(picklistFieldSelected.toLowerCase())){
            picklistapiname = mapOfStandardValueSet.get(picklistFieldSelected.toLowerCase()).StandardValueSet_Format__c;
        }
        
        //Standard
        MetadataApiService.StandardValueSet StandardField = (MetadataApiService.StandardValueSet) service.readMetadata('StandardValueSet', new String[] { picklistapiname }).getRecords()[0];
        
        MetadataApiService.StandardValue three = new MetadataApiService.StandardValue();
        three.fullName = valueInTheDescription;
        three.default_x = false;
        StandardField.standardValue.add(three);
        
        // Update 
        List<MetadataApiService.SaveResult> lstResults = service.updateMetadata( new MetadataApiService.Metadata[] { StandardField });
        for (MetadataApiService.SaveResult objResult : lstResults) {
            if (objResult.success) {
                System.debug('Successfully updated');
            }
            else {                       
                if(objResult.errors.size() > 0){
                    System.debug('eror : ' + objResult.errors[0].message);
                    throw new AuraHandledException('eror : ' + objResult.errors[0].message);
                }
            }
        }
    }
    
    @AuraEnabled
    public static void updateRecordTypeDuringPickValueCreation(String objectName, String picklistFieldSelected, List<String> listOfSelectedRecordTypes, String valueInTheDescription ){
        if(!listOfSelectedRecordTypes.isEmpty()){
            MetadataApiService.MetadataPort service = createService(); 
            
            List<String> recordTypeNames = new List<String>();
            for(String recordType : listOfSelectedRecordTypes){
                String recordTypeSelected = objectName +'.'+ recordType;
                recordTypeNames.add(recordTypeSelected);
            }
            //recordTypeNames.add('Account.Main');
            
            List<MetadataApiService.PicklistValue> pickVals = new List<MetadataApiService.PicklistValue>();
            
            MetadataApiService.PicklistValue pickVal = new MetadataApiService.PicklistValue();
            pickVal.fullName = valueInTheDescription;
            pickVal.default_x = false;
            pickVals.add(pickVal);
            
            List<MetadataApiService.Metadata> mdRecordTypes = service.readMetadata('RecordType', recordTypeNames).getRecords();
            List<MetadataApiService.RecordType> recordTypes = (List<MetadataApiService.RecordType>) mdRecordTypes;  
            
            MetadataApiService.RecordTypePicklistValue rtPickValue = new MetadataApiService.RecordTypePicklistValue();
            
            // Create the recordtypepicklist and add it to the list of picklist fields for the record type
            rtPickValue.picklist = picklistFieldSelected;
            rtPickValue.values = pickVals;
            
            for(MetadataApiService.RecordType RT : recordTypes){
                RT.active = true;
                RT.PicklistValues.add(rtPickValue);
            }
            
            List<MetadataApiService.SaveResult> rtResults = service.updateMetadata( recordTypes );
            
            for (MetadataApiService.SaveResult objResult : rtResults) {
                if (objResult.success) {
                    System.debug('Successfully updated recordtype');
                } else {                       
                    if(objResult.errors.size() > 0){
                        System.debug('eror : ' + objResult.errors[0].message);
                        throw new AuraHandledException('eror : ' + objResult.errors[0].message);
                    }
                }
            }  
        }
        else{
            throw new AuraHandledException('SUCCESS: Picklist Value has been created successfully');
        }
    }
    
    @AuraEnabled
    public static void updatePicklistValue( String objectName, String picklistFieldSelected, String picklistValueSelected, String valueInTheDescription, String selectedAction ){
        if(picklistFieldSelected.contains('__c')){
            updatePicklistValueForCustomField(objectName, picklistFieldSelected, picklistValueSelected, valueInTheDescription, selectedAction);
        }
        else{
            updatePicklistValueForStandardField(objectName, picklistFieldSelected, picklistValueSelected, valueInTheDescription, selectedAction);
        }
    }
    
    public static void updatePicklistValueForStandardField(String objectName, String picklistFieldSelected, String picklistValueSelected, String valueInTheDescription, String selectedAction ){
        MetadataApiService.MetadataPort service = createService(); 
        
        String picklistapiname;
        String oldname, newName;
        Map<String, Universal_PickList__c> mapOfStandardValueSet = new Map<String, Universal_PickList__c>();
        for(Universal_PickList__c stdvalue : [SELECT Picklist__c, StandardValueSet_Format__c From Universal_PickList__c WHERE Object_Name__c =: objectName]){
            mapOfStandardValueSet.put(stdvalue.Picklist__c.toLowerCase(), stdvalue);
        }
        if(mapOfStandardValueSet.keySet().contains(picklistFieldSelected.toLowerCase())){
            picklistapiname = mapOfStandardValueSet.get(picklistFieldSelected.toLowerCase()).StandardValueSet_Format__c;
        }
        
        //Standard
        MetadataApiService.StandardValueSet StandardField = (MetadataApiService.StandardValueSet) service.readMetadata('StandardValueSet', new String[] { picklistapiname }).getRecords()[0];
        if(selectedAction == 'Update'){
            for(MetadataApiService.StandardValue picklistValue : StandardField.standardValue){
                if(picklistValue.fullName == picklistValueSelected){ // API Name
                    //picklistValue.fullName = valueInTheDescription; // New API Value
                    oldname = picklistapiname+'.'+picklistValue.fullName;
                    picklistValue.label = valueInTheDescription; // New Label value
                    newName = picklistapiname+'.'+picklistValue.label;
                }
            }
        }
        List<MetadataApiService.SaveResult> lstResults = service.updateMetadata( new MetadataApiService.Metadata[] { StandardField });
        
        for (MetadataApiService.SaveResult objResult : lstResults) {
            if (objResult.success) {
                System.debug('Successfully updated');
                MetadataApiService.SaveResult renameresults = service.renameMetadata('StandardValue', oldname, newName);
            }
            else {                       
                if(objResult.errors.size() > 0){
                    System.debug('eror : ' + objResult.errors[0].message);
                    throw new AuraHandledException('eror : ' + objResult.errors[0].message);
                }
            }
        }
    }
    
    public static void updatePicklistValueForCustomField(String objectName, String picklistFieldSelected, String picklistValueSelected, String valueInTheDescription, String selectedAction ){
        MetadataApiService.MetadataPort service = createService(); 
        String picklistapiname = objectName+'.'+picklistFieldSelected;
        //String picklistapiname = 'Account.Active__c';
        String oldname, newName;
        MetadataApiService.CustomField customField = (MetadataApiService.CustomField) service.readMetadata('CustomField', new String[] { picklistapiname }).getRecords()[0];
        if(selectedAction == 'Update'){
            for(MetadataApiService.CustomValue objCustomValue : customField.valueSet.valueSetDefinition.value){
                if(objCustomValue.fullName == picklistValueSelected){ // API Name
                    //  objCustomValue.fullName = valueInTheDescription; // New API Value
                    oldname = picklistapiname+'.'+objCustomValue.fullName;
                    objCustomValue.label = valueInTheDescription; // New Label value
                    newName = picklistapiname+'.'+objCustomValue.label;
                }
            }
        }
        List<MetadataApiService.SaveResult> lstResults = service.updateMetadata( new MetadataApiService.Metadata[] { customField });
        
        for (MetadataApiService.SaveResult objResult : lstResults) {
            if (objResult.success) {
                System.debug('Successfully updated');
                MetadataApiService.SaveResult renameresults = service.renameMetadata('CustomValue', oldname, newName);
            }
            else {                       
                if(objResult.errors.size() > 0){
                    System.debug('eror : ' + objResult.errors[0].message);
                }
            }
        }
    }
    
    @AuraEnabled
    public static void updateRecordTypeDuringPickValueUpdation(String objectName, String picklistFieldSelected, List<String> listOfSelectedRecordTypes, String picklistValueSelected, String valueInTheDescription){
        if(!listOfSelectedRecordTypes.isEmpty()){
            MetadataApiService.MetadataPort service = createService(); 
            
            List<String> recordTypeNames = new List<String>();
            for(String recordType : listOfSelectedRecordTypes){
                String recordTypeSelected = objectName +'.'+ recordType;
                recordTypeNames.add(recordTypeSelected);
            }
            //recordTypeNames.add('Account.Main');
            
            List<MetadataApiService.PicklistValue> pickVals = new List<MetadataApiService.PicklistValue>();
            
            MetadataApiService.PicklistValue pickVal = new MetadataApiService.PicklistValue();
            pickVal.fullName = valueInTheDescription;
            pickVal.default_x = false;
            pickVals.add(pickVal);
            
            List<MetadataApiService.Metadata> mdRecordTypes = service.readMetadata('RecordType', recordTypeNames).getRecords();
            List<MetadataApiService.RecordType> recordTypes = (List<MetadataApiService.RecordType>) mdRecordTypes;  
            
            MetadataApiService.RecordTypePicklistValue rtPickValue = new MetadataApiService.RecordTypePicklistValue();
            
            // Create the recordtypepicklist and add it to the list of picklist fields for the record type
            rtPickValue.picklist = picklistFieldSelected;
            rtPickValue.values = pickVals;
            
            for(MetadataApiService.RecordType RT : recordTypes){
                RT.active = true;
                RT.PicklistValues.add(rtPickValue);
            }
            
            List<MetadataApiService.SaveResult> rtResults = service.updateMetadata( recordTypes );
            //removeValueFromRecordType(objectName, picklistFieldSelected, listOfSelectedRecordTypes, listOfAvailableRecordTypes, picklistValueSelected, valueInTheDescription);
            for (MetadataApiService.SaveResult objResult : rtResults) {
                if (objResult.success) {
                    System.debug('Successfully updated recordtype');
                } else {                       
                    if(objResult.errors.size() > 0){
                        System.debug('eror : ' + objResult.errors[0].message);
                    }
                }
            }
        }
        else{
            throw new AuraHandledException('SUCCESS: Picklist Value has been updated successfully');
        }
    }
    
    @AuraEnabled
    public static void removeValueFromRecordType(String objectName, String picklistFieldSelected, List<String> listOfSelectedRecordTypes, List<String> listOfAvailableRecordTypes, String picklistValueSelected, String valueInTheDescription){
        MetadataApiService.MetadataPort service = createService(); 
        for(String removeRecordTypes : listOfSelectedRecordTypes){
            if(listOfAvailableRecordTypes.contains(removeRecordTypes)){
                Integer index = listOfAvailableRecordTypes.indexof(removeRecordTypes);
                listOfAvailableRecordTypes.remove(index);
            }
        }
        List<String> recordTypeNames = new List<String>();
        for(String recordType : listOfAvailableRecordTypes){
            String recordTypeSelected = objectName +'.'+ recordType;
            recordTypeNames.add(recordTypeSelected);
        }
        //recordTypeNames.add('Account.Main');
        
        List<MetadataApiService.PicklistValue> pickVals = new List<MetadataApiService.PicklistValue>();
        
        MetadataApiService.PicklistValue pickVal = new MetadataApiService.PicklistValue();
        pickVal.fullName = valueInTheDescription;
        pickVal.default_x = false;
        pickVals.add(pickVal);
        system.debug('recordTypeNames=='+recordTypeNames);
        if(!recordTypeNames.isEmpty()){
        List<MetadataApiService.Metadata> mdRecordTypes = service.readMetadata('RecordType', recordTypeNames).getRecords();
        
            List<MetadataApiService.RecordType> recordTypes = (List<MetadataApiService.RecordType>) mdRecordTypes;  
            
            //List<MetadataApiService.RecordTypePicklistValue> rtPickValues = new List<MetadataApiService.RecordTypePicklistValue>();
            MetadataApiService.RecordTypePicklistValue rtPickValue = new MetadataApiService.RecordTypePicklistValue();
            
            // Create the recordtypepicklist and add it to the list of picklist fields for the record type
            rtPickValue.picklist = picklistFieldSelected;
            rtPickValue.values = pickVals;
            //rtPickValues.add(rtPickValue);
            
            for(MetadataApiService.RecordType RT : recordTypes){
                Integer index;
                RT.active = true;
                for(MetadataApiService.RecordTypePicklistValue r : RT.PicklistValues){
                    If(r.picklist == rtPickValue.picklist){
                        for(MetadataApiService.PicklistValue r1 : r.values){
                            if(r1.fullName == pickVal.fullName){
                                index = r.values.indexof(r1);
                            }  
                        }
                        if(index >= 0 && r.values.size() >= index){
                            r.values.remove(index); 
                        }
                    }
                }
            }
            
            List<MetadataApiService.SaveResult> rtResults = service.updateMetadata( recordTypes );
            
            for (MetadataApiService.SaveResult objResult : rtResults) {
                if (objResult.success) {
                    System.debug('Successfully updated recordtype');
                } else {                       
                    if(objResult.errors.size() > 0){
                        System.debug('eror : ' + objResult.errors[0].message);
                        throw new AuraHandledException('eror : ' + objResult.errors[0].message);
                    }
                }
            }  
        }
    }
    
    public class MetadataApiServiceExamplesException extends Exception { }
    
    public static void handleSaveResults(MetadataApiService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + saveResult.fullName + '.');
            for(MetadataApiService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataApiServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataApiServiceExamplesException('Request failed with no specified error.');
    }
    
    public static MetadataApiService.MetadataPort createService(){
        MetadataApiService.MetadataPort service = new MetadataApiService.MetadataPort();
        service.SessionHeader = new MetadataApiService.SessionHeader_element();
        //service.SessionHeader.sessionId = '00D2w000003ywGR!ASAAQBAfIgDcjHC6Y29NbGg6dlYIPBCXTxPcUZ0Yi4cYoC_BvrsoHIT0KL5n.aJBzWgEy8iu9N4HSdG1yh6xSUcd98p6FbtV';
        PageReference reportPage = Page.UniversalPicklistCntrlSessionIdGenerator;
        service.SessionHeader.sessionId = UniversalPicklistControllerUtils.getSessionIdFromVFPage(reportPage);
        return service;
    }
    
    public class wrapperClass{
        @AuraEnabled public List<String> uniqueObjectNames {get;set;}
        @AuraEnabled public Map<String, List<String>> mapOfObjectNamesAndFieldNames {get;set;}
    }
}