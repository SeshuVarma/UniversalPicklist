@isTest
public class UniversalPicklistControllerTest {
    
    private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof  MetadataApiService.retrieve_element)
				response.put('response_x', new  MetadataApiService.retrieveResponse_element());
			else if(request instanceof  MetadataApiService.checkDeployStatus_element)
				response.put('response_x', new  MetadataApiService.checkDeployStatusResponse_element());
			else if(request instanceof  MetadataApiService.listMetadata_element)
				response.put('response_x', new  MetadataApiService.listMetadataResponse_element());
			else if(request instanceof  MetadataApiService.checkRetrieveStatus_element)
				response.put('response_x', new  MetadataApiService.checkRetrieveStatusResponse_element());
			else if(request instanceof  MetadataApiService.describeMetadata_element)
				response.put('response_x', new  MetadataApiService.describeMetadataResponse_element());
			else if(request instanceof  MetadataApiService.deploy_element)
				response.put('response_x', new  MetadataApiService.deployResponse_element());
            else if(request instanceof  MetadataApiService.updateMetadata_element)
                response.put('response_x', new  MetadataApiService.updateMetadataResponse_element());
            else if(request instanceof  MetadataApiService.renameMetadata_element)
                response.put('response_x', new  MetadataApiService.renameMetadataResponse_element());
            else if(request instanceof   MetadataApiService.cancelDeploy_element)
                response.put('response_x', new  MetadataApiService.cancelDeployResponse_element());
            else if(request instanceof   MetadataApiService.deleteMetadata_element)
                response.put('response_x', new  MetadataApiService.deleteMetadataResponse_element());
            else if(request instanceof   MetadataApiService.upsertMetadata_element)
                response.put('response_x', new  MetadataApiService.upsertMetadataResponse_element());
            else if(request instanceof   MetadataApiService.createMetadata_element)
                response.put('response_x', new  MetadataApiService.createMetadataResponse_element());
            else if(request instanceof   MetadataApiService.deployRecentValidation_element)
                response.put('response_x', new  MetadataApiService.deployRecentValidationResponse_element());
            else if(request instanceof  MetadataApiService.describeValueType_element)
                response.put('response_x', new  MetadataApiService.describeValueTypeResponse_element());
            else if(request instanceof  MetadataApiService.checkRetrieveStatus_element)
                response.put('response_x', new  MetadataApiService.checkRetrieveStatusResponse_element());
			return;
		}
	}
    
    @IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
         MetadataApiService metaDataService = new  MetadataApiService();
        // Invoke operations     
        Test.startTest();    
         MetadataApiService.MetadataPort metaDataPort = new  MetadataApiService.MetadataPort();
        Test.stopTest();
	}
	
	@IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {    	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
         MetadataApiService metaDataService = new  MetadataApiService();
        // Invoke operations    
        Test.startTest();     
         MetadataApiService.MetadataPort metaDataPort = new  MetadataApiService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
         MetadataApiService metaDataService = new  MetadataApiService();
        // Invoke operations     
        Test.startTest();    
         MetadataApiService.MetadataPort metaDataPort = new  MetadataApiService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchDataOfUniversalPicklistTest(){
        list<String> recordTypesAvailable = new list<String> {'Billing','Enterprise','Main'};
        list<String> recordTypesSelected = new list<String> {'Billing'};
        
        Universal_PickList__c uniPick = new Universal_PickList__c();
        uniPick.Name = 'Active';
        uniPick.Object_Name__c = 'Account';
        uniPick.Picklist__c = 'Active__c';
        insert uniPick;
        Test.setMock(WebServiceMock.class, new MetadataServiceMock());
        test.startTest();
        UniversalPicklistController.fetchDataOfUniversalPicklist();
        UniversalPicklistController.getAllRecordTypes('Account');
        UniversalPicklistController.getPicklistFieldsAndValues('Account', 'Rating');
        UniversalPicklistController.getPicklistFieldsAndValues('Account', '');
        UniversalPicklistController.getRecordTypesOfSelectedValue('Account', 'Active__c', 'Yes');
        UniversalPicklistController.createNewPicklistValue('Account', 'Active__c', 'Active 1', 'Update');
        UniversalPicklistController.createNewPicklistValue('Account', 'Rating', 'Active 1', 'Update');
        UniversalPicklistController.updateRecordTypeDuringPickValueCreation('Account', 'Active__c', recordTypesAvailable, 'New');
        UniversalPicklistController.removeValueFromRecordType('Account', 'Rating', recordTypesSelected, recordTypesAvailable, 'Hot', 'Hoter');
        UniversalPicklistController.updateRecordTypeDuringPickValueUpdation('Account', 'Rating', recordTypesSelected, 'Hot', 'Hoter');
        UniversalPicklistController.updatePicklistValue('Contact', 'Email', 'Active 1', 'New', 'Update');
        UniversalPicklistController.updatePicklistValue('Account', 'Active__c', 'Active 1', 'New', 'Update');
        test.stopTest();
    }
}