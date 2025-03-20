/**
 * @description This class is responsible for generating ad hoc data and stage data for learning paths and stages.
 *              It includes methods for creating assignments, rendering email templates, and managing access.
 */
public class AssignmentPreviewer {
    private static Map<String, Included_Item__c> taskItemsById;
	private static Map<String, Map<String, List<String>>> generateAdHocDataAccess = new Map<String, Map<String, List<String>>> {
        'Learning_Path__c' => new Map<String, List<String>> {
            'Read' => new List<String> {
                'Id', 'Name', 'Milestone__c', 'Milestone_Completion_Type__c', 'Milestone_Completion_Ids__c', 'Externally_Available__c'
            }
        },
        'Included_Item__c' => new Map<String, List<String>>{
            'Read' => new List<String> {
                'Id', 'Learning_Offering__c','Learning_Path__c', 'Tasks__c', 'Order__c', 'Course_Narrative__c'
            }
        },
        'Learning_Offering__c' => new Map<String, List<String>> {
            'Read' => new List<String>{
                'Id', 'Type__c'
            }
        }
    };
	 private static Map<String, Map<String, List<String>>> generateStageDataAccess = new Map<String, Map<String, List<String>>> {
        'Learning_Path__c' => new Map<String, List<String>> {
            'Read' => new List<String> {
                'Id', 'Name', 'Milestone__c', 'Milestone_Completion_Type__c', 'Milestone_Completion_Ids__c', 'Externally_Available__c'
            }
        },
        'Included_Item__c' => new Map<String, List<String>>{
            'Read' => new List<String> {
                'Id', 'Learning_Offering__c', 'Learning_Path__c', 'Tasks__c', 'Order__c', 'Course_Narrative__c'
            }
        },
        'Learning_Offering__c' => new Map<String, List<String>> {
            'Read' => new List<String>{
                'Id', 'Type__c'
            }
        },
        'Stage__c' => new Map<String, List<String>> {
            'Read' => new List<String>{
                'Id', 'Name', 'Journey__c', 'End_Day__c', 'Start_Day__c'
            }
        },
        'Included_Path__c' => new Map<String, List<String>> {
            'Read' => new List<String>{
                'Id', 'Learning_Path__c', 'Order__c', 'Start_Date__c', 'Archive_Date__c'
            }
        }
    };
	/**
	 * @description Generates ad hoc data for a given learning path ID.
	 * @param lpId The ID of the learning path for which to generate ad hoc data.
	 * @return A JSON string containing the response data.
	 */
    @AuraEnabled
    public static String generateAdHocData(String lpId) {
        responseData rd = new responseData();
        Savepoint sp = Database.setSavepoint();

        try {
            checkAccess(generateAdHocDataAccess);

            taskItemsById = new Map<String, Included_Item__c>();
            Learning_Path__c path = [SELECT Id, Name, Milestone__c, Milestone_Completion_Type__c, Milestone_Completion_Ids__c, Externally_Available__c,
                                     (
                                         SELECT Id, Learning_Offering__c, Learning_Offering__r.Type__c, Learning_Path__c, Tasks__c, Order__c, Course_Narrative__c
                                         FROM Included_Items__r
                                         WHERE Is_Deleted__c = false
                                     )
                                     FROM Learning_Path__c
                                     WHERE Id =: lpId];

            Assigned_Path__c assignedPath = generateAP(path, 'Continuing Education', 30, null);
            insert assignedPath;

            List<Assignment__c> assignments = generateAssignments(assignedPath, path.Included_Items__r);
            insert assignments;

            generateTasks(assignments);

            List<String> templateNames = new List<String>{'Assigned_Continuing_Education', 'Continuing_Education_Time_is_Almost_Up', 'Continuing_Education_Time_is_Up'};
            List<Map<String, Object>> renderedTemplates = renderTemplates(templateNames, assignedPath.Id);

            //requery for path so we have all the lookups populated
            assignmentDashboard.getPathData(rd, assignedPath.Id);
            assignmentDashboard.getAps(rd, true, 0, 0);
            rd.put('emailTemplates', renderedTemplates);
            rd.put('firstName', assignmentDashboard.getFirstName());
            rd.put('previewName', path.Name);
            rd.put('isPartner', path.Externally_Available__c);
        } catch(Exception e) {
            rd.addError(e);
        }

        Database.rollback(sp);
        return rd.getJsonString();
    }

	/**
     * @description Generates stage data for a given stage ID.
     * @param stageId The ID of the stage for which to generate data.
     * @return A JSON string containing the response data.
     */
    @AuraEnabled
    public static String generateStageData(String stageId) {
        responseData rd = new responseData();
        Savepoint sp = Database.setSavepoint();

        try {
            checkAccess(generateStageDataAccess);

            taskItemsById = new Map<String, Included_Item__c>();
            List<Assignment__c> assignments = new List<Assignment__c>();
            List<Assigned_Path__c> aps = new List<Assigned_Path__c>();
            List<String> lpIds = new List<String>();

            Stage__c stage = [SELECT Id, Name, Journey__c, End_Day__c, Start_Day__c,
                              (
                                  SELECT Id, Learning_Path__c, Order__c, Learning_Path__r.Name, Learning_Path__r.Milestone__c,
                                  Learning_Path__r.Milestone_Completion_Ids__c, Learning_Path__r.Milestone_Completion_Type__c
                                  FROM Included_Paths__r
                                  WHERE (Start_Date__c = null OR Start_Date__c <= TODAY)
                                  AND (Archive_Date__c = null OR Archive_Date__c > TODAY)
                              )
                              FROM Stage__c
                              WHERE Id =: stageId];
            Decimal allotedTime = stage.End_Day__c - stage.Start_Day__c;

            Assigned_Journey__c assignedJourney = new Assigned_Journey__c(
                Journey__c = stage.Journey__c,
                Preview__c = true,
                User__c = UserInfo.getUserId(),
                OwnerId = UserInfo.getUserId(),
                Cancelled__c = false,
                Self_Assigned__c = false
            );
            insert assignedJourney;

            Assigned_Stage__c assignedStage = generateStage(stage);
            assignedStage.Assigned_Journey__c = assignedJourney.Id;
            insert assignedStage;

            for(Included_Path__c ip : stage.Included_Paths__r) {
                lpIds.add(ip.Learning_Path__c);
            }

            Map<Id, Learning_Path__c> lpById = new Map<Id, Learning_Path__c>([SELECT Id, Name, Milestone__c, Milestone_Completion_Type__c, Milestone_Completion_Ids__c,
                                                                              (
                                                                                  SELECT Id, Learning_Offering__c, Learning_Offering__r.Type__c, Learning_Path__c, Tasks__c, Order__c, Course_Narrative__c
                                                                                  FROM Included_Items__r
                                                                                  WHERE Is_Deleted__c = false
                                                                              )
                                                                              FROM Learning_Path__c
                                                                              WHERE Id =: lpIds]);

            for(Included_Path__c ip : stage.Included_Paths__r) {
                Assigned_Path__c ap = generateAP(lpById.get(ip.Learning_Path__c), 'Stage', Integer.valueOf(allotedTime), ip.Order__c);
                ap.Assigned_Stage__c = assignedStage.Id;
                ap.Stage__c = assignedStage.Stage__c;
                ap.Journey__c = assignedStage.Journey__c;
                aps.add(ap);
            }

            insert aps;

            for(Assigned_Path__c ap : aps) {
                List<Assignment__c> generatedAssignments = generateAssignments(ap, lpById.get(ap.Learning_Path__c).Included_Items__r);
                assignments.addAll(generatedAssignments);
            }

            insert assignments;
            generateTasks(assignments);

            List<String> templateNames = new List<String>{'Assigned_Stage', 'Time_is_Almost_Up', 'Time_is_Up'};
            List<Map<String, Object>> renderedTemplates = renderTemplates(templateNames, assignedStage.Id);

            assignmentDashboard.getAps(rd, true, 0, 0);
            rd.put('emailTemplates', renderedTemplates);
            rd.put('firstName', assignmentDashboard.getFirstName());
            rd.put('previewName', stage.Name);
        } catch(Exception e){
            rd.addError(e);
        }

        Database.rollback(sp);
        return rd.getJsonString();
    }

    private static Assigned_Stage__c generateStage(Stage__c stage){
        Integer totalMilestones = 0;
        Decimal allotedTime = stage.End_Day__c - stage.Start_Day__c;

        for(Included_Path__c ip : stage.Included_Paths__r) {
            if(ip.Learning_Path__r.Milestone__c != null) {
                totalMilestones += 1;
            }
        }

        Assigned_Stage__c assignedStage = new Assigned_Stage__c(
            Number_Of_Paths__c = stage.Included_Paths__r.size(),
            Number_Of_Milestones__c = totalMilestones,
            Self_Assigned__c = false,
            Cancelled__c = false,
            Due_Date__c = Date.Today().addDays((Integer)allotedTime),
            Stage__c = stage.Id,
            Journey__c = stage.Journey__c,
            User__c = UserInfo.getUserId(),
            OwnerId = UserInfo.getUserId(),
            Number_Of_Completed_Milestones__c = 0,
            Number_Of_Completed_Paths__c = 0,
            Preview__c = true
            );

        return assignedStage;
    }

    private static Assigned_Path__c generateAP(Learning_Path__c path, String type, Integer allotedTime, Decimal order){
        Integer totalCompletionIds = 0;

        if(path.Milestone_Completion_Type__c == 'Specific') {
            totalCompletionIds = path.Milestone_Completion_Ids__c.split(';').size();
        }

        Assigned_Path__c assignedPath = new Assigned_Path__c(
            Stage__c = null,
            Assigned_Stage__c = null,
            Order__c = order,
            Self_Assigned__c = false,
            Preview__c = true,
            Cancelled__c = false,
            Type__c = type,
            Due_Date__c = Date.today().addDays(allotedTime),
            Name = path.Name,
            Learning_Path__c = path.Id,
            User__c = UserInfo.getUserId(),
            OwnerId = UserInfo.getUserId(),
            Number_Of_Assignments__c = path.Included_Items__r.size(),
            Number_Of_Completed_Assignments__c = 0,
            Milestone_Completion_Ids__c = path.Milestone_Completion_Ids__c,
            Milestone_Completion_Type__c = path.Milestone_Completion_Type__c,
            Total_Milestone_Completion_Ids__c = totalCompletionIds,
            Total_Completed_Milestone_Completion_Ids__c = 0,
            Milestone__c = path.Milestone__c
            );

        return assignedPath;
    }

    private static List<Assignment__c> generateAssignments(Assigned_Path__c assignedPath, List<Included_Item__c> includedItems){
        List<Assignment__c> assignments = new List<Assignment__c>();

        for(Included_Item__c item : includedItems) {
            Assignment__c assignment = new Assignment__c(
                Journey__c = assignedPath.Journey__c,
                Stage__c = assignedPath.Stage__c,
                Cancelled__c = false,
                Order__c = item.Order__c,
                Learning_Path__c = assignedPath.Learning_Path__c,
                Course_Narrative__c = item.Course_Narrative__c,
                Due_Date__c = assignedPath.Due_Date__c,
                Assigner__c = UserInfo.getUserId(),
                Send_Email__c = false,
                Preview__c = true,
                Status__c = 'Not Started',
                OwnerId = UserInfo.getUserId(),
                Assigned_Path__c = assignedPath.Id,
                Number_of_Completed_Tasks__c = 0
                );

            if(item.Learning_Offering__c == null) {
                if(String.isNotEmpty(item.Tasks__c)) {
                    List<String> tasks = item.Tasks__c.split('\\|');
                    Set<String> uniqueTasks = new Set<String>();
                    for(String task : tasks) {
                        if(String.isNotEmpty(task.trim())) {
                            uniqueTasks.add(task);
                        }
                    }
                    assignment.Number_Of_Tasks__c = uniqueTasks.size();
                } else {
                    assignment.Number_Of_Tasks__c = 0;
                }

                assignment.Included_Item__c = item.Id;
                taskItemsById.put(item.Id, item);
            } else {
                assignment.Learning_Offering__c = item.Learning_Offering__c;
            }

            assignments.add(assignment);
        }

        return assignments;
    }

    private static void generateTasks(List<Assignment__c> assignments){
        List<Assignment__c> taskAssignments = new List<Assignment__c>();

        for(Assignment__c assignment : assignments) {
            if(assignment.Included_Item__c != null) {
                taskAssignments.add(assignment);
            }
        }

        if(!taskAssignments.isEmpty()) {
            assignmentBatchHelper.assignee = new User(Id = UserInfo.getUserId());
            assignmentBatchHelper.itemsById = taskItemsById;
            assignmentBatchHelper.createTasks(taskAssignments);
        }
    }

    private static List<Map<String, Object>> renderTemplates(List<String> emailTemplateNames, String whatId){
        Map<Id, EmailTemplate> emailTemplates = new Map<Id, EmailTemplate>([SELECT Id, Name, Description FROM EmailTemplate WHERE DeveloperName =: emailTemplateNames]);
        List<Map<String, Object>> renderedTemplates = new List<Map<String, Object>>();

        for(EmailTemplate template : emailTemplates.values()) {
            Map<String, Object> templateMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(template));
            String renderedBody = Messaging.renderStoredEmailTemplate(template.Id, UserInfo.getUserId(), whatId).htmlbody;

            templateMap.put('renderedBody', renderedBody);
            renderedTemplates.add(templateMap);
        }

        return renderedTemplates;
    }

    private static void checkAccess(Map<String, Map<String, List<String>>> checkMap){
        dmlManager.checkAccess(checkMap);
    }
}
