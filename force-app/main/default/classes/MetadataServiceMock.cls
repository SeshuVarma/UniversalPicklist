@isTest
public class MetadataServiceMock implements WebServiceMock {
    public static final String[] CUSTOM_FIELD_FULL_NAMES = new String[] {
        'Contact.Email',
        'cve__BenefitClaimed__c.cve__DateOfDiagnosis__c'
    };
    public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
            ) {

        if (request instanceof MetadataApiService.readMetadata_element) {
            MetadataApiService.readMetadata_element r = (MetadataApiService.readMetadata_element) request;
            if(r.type_x == 'RecordType'){
                MetadataApiService.PicklistValue picklistValue = new MetadataApiService.PicklistValue();
                picklistValue.fullName = 'Pending';
                
                MetadataApiService.RecordTypePicklistValue recordTypePicklistValue = new MetadataApiService.RecordTypePicklistValue();
                recordTypePicklistValue.picklist = 'cve__Status__c';
                recordTypePicklistValue.values = new MetadataApiService.PicklistValue[] {picklistValue};
                    
                    MetadataApiService.RecordType recordType = new MetadataApiService.RecordType();
                recordType.fullName = 'cve__BenefitClaimed__c.cve__ShortTermDisability';
                recordType.picklistValues = new MetadataApiService.RecordTypePicklistValue[] {recordTypePicklistValue};
                    
                    MetadataApiService.ReadRecordTypeResult result = new MetadataApiService.ReadRecordTypeResult();
                result.records = new MetadataApiService.RecordType[] {recordType};
                    
                    MetadataApiService.readRecordTypeResponse_element responseElement = new MetadataApiService.readRecordTypeResponse_element();
                responseElement.result = result;
                
                response.put('response_x', responseElement);
            }
            else if(r.type_x == 'StandardValueSet'){
                
                MetadataApiService.StandardValue standardValue = new MetadataApiService.StandardValue();
                standardValue.fullName = 'Pending';
                
                MetadataApiService.StandardValueSet picklistapiname = new MetadataApiService.StandardValueSet();
                picklistapiname.fullName = 'cve__BenefitClaimed__c.cve__ShortTermDisability';
                picklistapiname.standardValue = new MetadataApiService.StandardValue[] {standardValue};
                
                MetadataApiService.ReadStandardValueSetResult result = new MetadataApiService.ReadStandardValueSetResult();
                result.records = new MetadataApiService.StandardValueSet[] { picklistapiname };
                
                MetadataApiService.readStandardValueSetResponse_element responseElement = new MetadataApiService.readStandardValueSetResponse_element();
                responseElement.result = result;
                
                response.put('response_x', responseElement);
            }
            else if(r.type_x == 'CustomField'){
                MetadataApiService.CustomValue customValue = new MetadataApiService.CustomValue();
                customValue.fullName = 'Custom';
                
                MetadataApiService.ValueSetValuesDefinition valueSetDef = new MetadataApiService.ValueSetValuesDefinition();
                valueSetDef.value = new MetadataApiService.CustomValue[] {customValue};
                
                MetadataApiService.ValueSet valueSet = new MetadataApiService.ValueSet();
                valueSet.valueSetName = 'New ValueSet';
                valueSet.valueSetDefinition = valueSetDef;
                
                MetadataApiService.CustomField customField = new MetadataApiService.CustomField();
                customField.fullName = 'Pending';
                customField.valueSet = valueSet;
                
                MetadataApiService.ReadCustomFieldResult result = new MetadataApiService.ReadCustomFieldResult();
                result.records = new MetadataApiService.CustomField[] { customField };
                
                MetadataApiService.readCustomFieldResponse_element responseElement = new MetadataApiService.readCustomFieldResponse_element();
                responseElement.result = result;
                
                response.put('response_x', responseElement);
            }

        } else if (request instanceof MetadataApiService.updateMetadata_element) {

            MetadataApiService.SaveResult result = new MetadataApiService.SaveResult();
            result.success = true;

            MetadataApiService.updateMetadataResponse_element responseElement = new MetadataApiService.updateMetadataResponse_element();
            responseElement.result = new MetadataApiService.SaveResult[] {result};

            response.put('response_x', responseElement);

        } else if (request instanceof MetadataApiService.upsertMetadata_element) {

            MetadataApiService.UpsertResult result = new MetadataApiService.UpsertResult();
            result.success = true;

            MetadataApiService.upsertMetadataResponse_element responseElement = new MetadataApiService.upsertMetadataResponse_element();
            responseElement.result = new MetadataApiService.UpsertResult[] {result};

            response.put('response_x', responseElement);

        }
         else if(request instanceof MetadataApiService.renameMetadata_element){
                MetadataApiService.SaveResult result = new MetadataApiService.SaveResult();
                result.success = TRUE;
                
                MetadataApiService.renameMetadataResponse_element responseElement = new MetadataApiService.renameMetadataResponse_element();
                responseElement.result = result;
                
                response.put('response_x', responseElement);
            }
    }
    
    public static MetadataApiService.CustomField createContactEmailField() {

        MetadataApiService.CustomField f = new MetadataApiService.CustomField();
        f.type_x = String.valueOf(DisplayType.Email);
        f.fullName = CUSTOM_FIELD_FULL_NAMES[0];
        f.label = 'Email';
        f.length = 80;
        f.encrypted = false;

        return f;
    }

    public static MetadataApiService.CustomField createBenefitClaimedDateOfDiagnosisField() {

        MetadataApiService.CustomField f = new MetadataApiService.CustomField();
        f.type_x = String.valueOf(DisplayType.Date);
        f.fullName = CUSTOM_FIELD_FULL_NAMES[1];
        f.label = 'Date';
        f.encrypted = false;

        return f;
    }
}