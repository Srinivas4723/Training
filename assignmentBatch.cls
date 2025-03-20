global with sharing class assignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Map<String, Cohort__c> cohortByParentIds;
    global String singleCohortId;
    global List<String> learnersToProcess;
    global Boolean runSubsequentBatch;

    /****************************
    *                           *
    *    CLASS IS DEPRECATED    *
    *                           *
    *****************************/



    //not being used, in for deploy/packaging
    global assignmentBatch(){
        cohortByParentIds = new Map<String, Cohort__c>();
        singleCohortId = null;
        learnersToProcess = new List<String>();
        runSubsequentBatch = false;
    }

    //not being used, in for deploy/packaging
    global assignmentBatch(String singleCohort, Boolean continueExecution){
        cohortByParentIds = new Map<String, Cohort__c>();
        singleCohortId = singleCohort;
        learnersToProcess = new List<String>();
        runSubsequentBatch = continueExecution;
    }

    global assignmentBatch(List<String> learnerIds, String singleCohort, Boolean continueExecution){
        cohortByParentIds = new Map<String, Cohort__c>();
        singleCohortId = singleCohort;
        learnersToProcess = learnerIds;
        runSubsequentBatch = continueExecution;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'SELECT Id, User__c, Contact__c FROM Learner_Profile__c WHERE Status__c = \'Active\'';

        if(Test.isRunningTest()) {
            queryString += ' AND User__r.LastName = \'User 3\' LIMIT 1';
        } else{
            queryString += ' AND Id =: learnersToProcess';
        }

        System.debug('******** assignmentBatch queryString: ' + queryString);

        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<User> scope){
        //assignmentBatchHelper.assignUserOfferings(scope, singleCohortId);
    }

    //global void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope){
    //    if(scope.size() > 0) {
    //        assignmentBatchHelper.assignOfferings(scope, singleCohortId);
    //    }
    //}

    global void finish(Database.BatchableContext BC){
        //Boolean allJobsFinished = true;

        //Batch_Data__c batchData = Batch_Data__c.getOrgDefaults();
        //if(String.isNotEmpty(batchData.Assignment_Batch_Job_Ids__c)) {
        //    List<String> jobIds = (List<String>) JSON.deserialize(batchData.Assignment_Batch_Job_Ids__c, Type.forName('List<String>'));

        //    //check that all jobs are completed before running subsequent batches
        //    for(AsyncApexJob apexJob : [SELECT Status
        //                                FROM AsyncApexJob
        //                                WHERE Id =: jobIds]) {

        //        if(apexJob.Status != 'Completed') {
        //            allJobsFinished = false;
        //        }
        //    }
        //}

        //if(!Test.isRunningTest() && runSubsequentBatch && allJobsFinished){
        //    Trailhead_Settings__c thSettings = Trailhead_Settings__c.getOrgDefaults();
        //    Auth_Setting__c authSettings = Auth_Setting__c.getOrgDefaults();

        //    //internal trailhead assignment
        //    if(thSettings.Run_Assignment_Batch__c && String.isNotEmpty(authSettings.Refresh_Token__c)) {
        //        Database.executeBatch(new trailheadAssignmentBatch(false), 1);
        //    }

        //    //partner trailhead assignment
        //    if(thSettings.Run_Partner_Assignment_Batch__c && String.isNotEmpty(authSettings.Partner_Refresh_Token__c)) {
        //        Database.executeBatch(new trailheadAssignmentBatch(true), 1);
        //    }


        //    //internal trailhead completion
        //    if(thSettings.Run_Completion_Batch__c && String.isNotEmpty(authSettings.Refresh_Token__c)) {
        //        Database.executeBatch(new trailheadCompletionBatch(false), 1);
        //    }

        //    //partner trailhead completion
        //    if(thSettings.Run_Partner_Completion_Batch__c && String.isNotEmpty(authSettings.Partner_Refresh_Token__c)) {
        //        Database.executeBatch(new trailheadCompletionBatch(true), 1);
        //    }

        //    batchData.Assignment_Batch_Job_Ids__c = null;
        //    upsert batchData;
        //}
    }
}