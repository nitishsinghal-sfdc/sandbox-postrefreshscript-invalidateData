/**
* @author Nitish Singhal (nitishsinghal007@gmail.com)
* @date 15th October 2019
* @description Batch class to update email and phone fields on Accounts and Contacts
*
* CHANGE LOG
**/
public class SandboxPostRefreshScriptBatch implements Database.Batchable<SObject> {

    // Add objects to this list to chain through objects and clear
    // out emails
    public static final List<String> OBJECT_NAMES = new List<String>{
            'Account',
            'Contact'
    };

    // The object name to query for and replace emails for
    public String currentObjectName;

    // Default Constructor to start on Account
    public SandboxPostRefreshScriptBatch() {

        // Start with the first object
        this.currentObjectName = OBJECT_NAMES[0];
    }

    // Constructor to accept object name to process job for
    public SandboxPostRefreshScriptBatch(String objectName) {
        this.currentObjectName = objectName;
    }

    // Query for all email fields for the object
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Return the query
        return Database.getQueryLocator(getQuery());
    }

    // Execute the records
    public void execute(Database.BatchableContext BC, List<SObject> scope) {

        // Iterate over the records
        for (SObject record :scope) {

            // Iterate over each email field
            for (String emailField :getEmailFieldsForObject()) {

                // Only process not null fields
                if (record.get(emailField) != null) {

                    // Retrieve the email value and attach .sandbox
                    String emailValue = String.valueOf(record.get(emailField));
                    emailValue = emailValue + '.sandbox';

                    // Put back into the field
                    record.put(emailField, emailValue);
                }
            }

            // Iterate over each phone field
            for (String phoneField : getPhoneFieldsForObject()) {

                // Only process not null fields
                if (record.get(phoneField) != null) {

                    // Retrieve the email value and attach .sandbox
                    String phoneValue = String.valueOf(record.get(phoneField));
                    phoneValue = phoneValue + '.xxxxx';

                    // Put back into the field
                    record.put(phoneField, phoneValue);
                }
            }
        }

        Database.update(scope, false);
    }

    public void finish(Database.BatchableContext BC) {

        // If we have a next object to process
        // Then we run it again!
        if (getNextObject() != null) {

            Database.executeBatch(new SandboxPostRefreshScriptBatch(getNextObject()));
        }
    }

    // Retrieve the query for the specific object
    public String getQuery() {

        List<String> allFields = new List<String>();
        allFields.addAll(getEmailFieldsForObject());
        allFields.addAll(getPhoneFieldsForObject());
        return 'SELECT ' + String.join(allFields, ',') + ' FROM ' + currentObjectName;
    }

    // Return the email fields for the object
    public List<String> getEmailFieldsForObject() {

        List<String> emailFields = new List<String>();

        // Iterate over the fields on the object to retrieve the email fields
        for (Schema.SObjectField field :Schema.getGlobalDescribe().get(currentObjectName).getDescribe().fields.getMap().values()) {

            // If an email field
            // Or name contains email and is a Text field
            if (field.getDescribe().isUpdateable() &&
                    (field.getDescribe().getType() == Schema.DisplayType.Email ||
                            (
                                    field.getDescribe().getName().containsIgnoreCase('email') &&
                                            field.getDescribe().getType() == Schema.DisplayType.String)
                    )
                    ) {

                // Add the field
                emailFields.add(field.getDescribe().getName());
            }
        }

        return emailFields;
    }

    // Return the email fields for the object
    public List<String> getPhoneFieldsForObject() {

        List<String> phoneFields = new List<String>();

        // Iterate over the fields on the object to retrieve the email fields
        for (Schema.SObjectField field :Schema.getGlobalDescribe().get(currentObjectName).getDescribe().fields.getMap().values()) {

            // If a phone field
            if (field.getDescribe().isUpdateable() && field.getDescribe().getType() == Schema.DisplayType.Phone) {
                // Add the field
                phoneFields.add(field.getDescribe().getName());
            }
        }

        return phoneFields;
    }

    // Determine which object to do next
    public String getNextObject() {

        for (Integer i = 0; i < OBJECT_NAMES.size(); i++) {

            if (currentObjectName == OBJECT_NAMES[i]) {

                try {

                    return OBJECT_NAMES[i + 1];
                }
                catch (Exception ex) {}
            }
        }

        return null;
    }
}