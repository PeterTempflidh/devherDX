global class BatchRestaurantNPS implements Database.Batchable<sObject> {
    public List<Messaging.SingleEmailMessage> emailList;
    Map<string, RestaurantNPSEmail__c>resEmailSettings = new Map<string, RestaurantNPSEmail__c>() ;
    List<RestaurantNPSEmail__c> resEmailList = new List<RestaurantNPSEmail__c>();
    Map<String, String> resEmailFieldByRecordTypeId = new Map<String, String>();
    List<string>recordtypeIdList = new List<string>();
    datetime starttime;
    public contact con;
    Integer volume;

    global BatchRestaurantNPS (Integer v) {
        volume = v;
        resEmailSettings = RestaurantNPSEmail__c.getAll();
        resEmailList = RestaurantNPSEmail__c.getAll().values();
        for (RestaurantNPSEmail__c r : resEmailList ) {
            recordtypeIdList.add(r.RecordTypeId__c);
            resEmailFieldByRecordTypeId.put(r.RecordTypeId__c, r.EmailFieldAPI__c);
        }
        con = [select id from contact where email != null limit 1];
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select ownerid,
                                         Online_Since__c,
                                         BillingCountry,
                                         Parent.Online_Since__c,
                                         Parent.Parent.Online_Since__c,
                                         ParentId,
                                         Parent.ParentId,
                                         Last_NPS_Date__c,
                                         nps_count__c,
                                         recordtype.developername,
                                         backend_email__c,
                                         Type,
                                         createddate, Account_Email__c
                                         FROM Account
                                         WHERE  online_status_backend__C = 'Online'
                                                 AND recordtypeID IN :recordtypeIdList
                                                 AND (Online_Since__c != null OR Parent.Online_Since__c != null OR Parent.Parent.Online_Since__c != null )
                                                 AND ((last_nps_date__c = null ) OR (last_nps_date__c != null AND last_nps_Date__c < last_n_months:3))
                                                 LIMIT :volume
                                        ] );

    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('execute method running');
        List<account> accToUpdate = new List<account>();
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        List<account> incomingAccountLst = (List<Account>)scope;
        Map<string, string> cdAccConEmailMap = new map<string, string>();
        system.debug('Incoming Accounts in Execute : ' + incomingAccountLst);
        for (Contact pcon : [Select id, Email, Accountid, Contact_Role__c from Contact
                             WHERE Email != null
                             AND Account.Recordtype.Developername = 'CD_Account'
                                     AND Contact_Role__c = 'Owner'
                                             AND Id IN (Select ContactId FROM AccountContactRelation)
                                             Order By CreatedDate]) {
            cdAccConEmailMap.put(pcon.AccountId, pcon.Email);

        }

        for (Account a : incomingAccountLst) {
            String emailAddress;
            String templateIdSelection;
            String OrgWideAdd;
            Datetime onlineSince;
            if (a.Recordtype.Developername == 'CD_Account' ) {
                if (a.Type == 'Branch' ) {
                    system.debug('Branch Account : ' + a);
                    if (a.online_since__c != null) {
                        onlineSince = a.Online_Since__c;
                        system.debug('onlineSince child' + onlineSince);
                    } else if (a.Parent.online_since__c != null) {
                        onlineSince = a.Parent.Online_Since__c;
                        system.debug('onlineSince Parent' + onlineSince);
                    } else if (a.Parent.Parent.online_since__c != null) {
                        onlineSince = a.Parent.Parent.Online_Since__c;
                        system.debug('onlineSince GrandParent' + onlineSince);
                    } else {
                        onlineSince = null;
                    }

                    system.debug('cdAccConEmailMap : ' + cdAccConEmailMap);

                    if (cdAccConEmailMap != null && cdAccConEmailMap.get(a.Id) != null) {
                        emailAddress = (String)cdAccConEmailMap.get(a.Id);// != null ? (String)cdAccConEmailMap.get(a.Id) : '';
                        system.debug('email child : ' + emailAddress);
                    } else if (cdAccConEmailMap != null && cdAccConEmailMap.get(a.ParentId) != null) {
                        emailAddress = (String)cdAccConEmailMap.get(a.ParentId);
                        system.debug('email Parent : ' + emailAddress);
                    } else if (cdAccConEmailMap != null && cdAccConEmailMap.get(a.Parent.ParentId) != null) {
                        emailAddress = (String)cdAccConEmailMap.get(a.Parent.ParentId);
                        system.debug('email Parent Parent : ' + emailAddress);
                    } else {
                        emailAddress = '';
                    }

                    System.debug(a.Billingcountry + ' ** emailaddress for CD Account comes from Primary Contact: ' + emailAddress);
                    templateIdSelection = resEmailSettings.get(a.Billingcountry).EmailTemplateId3months__c;
                    OrgWideAdd = resEmailSettings.get(a.billingcountry).OrgWideAddress__c;

                }
            } else {
                if (a.Online_Since__c != null)
                    onlineSince = a.Online_Since__c;

                String emailField = resEmailFieldByRecordTypeId.get(String.valueOf(a.recordTypeId).substring(0, 15));
                system.debug('EmailField is : ' + emailField);
                String emailFieldName = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(emailField).getDescribe().getName();
                emailAddress = (String)a.get(emailFieldName) != null ? (String)a.get(emailFieldName) : '';
                System.debug('** emailaddress for Account: ' + emailAddress);
                templateIdSelection = resEmailSettings.get(a.recordtype.developername).EmailTemplateId__c;
                OrgWideAdd = resEmailSettings.get(a.recordtype.developername).OrgWideAddress__c;
            }

            if (emailAddress != null && emailAddress != '' && onlineSince != null) {
                Matcher emailMatcher = emailPattern.matcher(emailAddress);
                if (emailMatcher.matches()) {
                    
                    Date onlineDate = onlineSince.date();
                    if ((onlineDate.daysbetween(system.today()) >= 42 && a.Last_NPS_Date__C == null) || (a.Last_NPS_Date__C != null)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] {emailAddress});
                        email.setSaveAsActivity(false);
                        email.setTargetObjectId(con.id);
                        email.setTemplateId(templateIdSelection);
                        email.setWhatId(a.Id);
                        system.debug(a.recordtype.developername);
                        email.setOrgWideEmailAddressId(OrgWideAdd);
                        lstMsgs.add(email);
                        a.Last_NPS_Date__C = system.today();
                        if (a.nps_count__c == null || a.nps_count__c == 0)
                            a.nps_count__c = 1;
                        else
                            a.nps_count__c = a.nps_count__c + 1;
                        accToUpdate.add(a);
                        system.debug('Emailmsg :: ' + email);
                        system.debug('Accountlist to Update : ' + accToUpdate);
                    }

                }
            }

        }

        system.debug('Outside For looplist of messages : ' + lstMsgs);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(lstMsgs);
        Database.rollback(sp);

        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
            lstMsgsToSend.add(emailToSend);
        }

        Messaging.sendEmail(lstMsgsToSend);
        system.debug('Message Sent - Next is Account Update');
        if (!accToUpdate.isEmpty())
            System.debug('Account Update being executed');
        update accToUpdate;
    }

    global void finish(Database.BatchableContext BC) {

    }
}