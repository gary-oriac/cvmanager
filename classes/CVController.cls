public with sharing class CVController {
      
    @AuraEnabled
    public static List<String> getSkillsList(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = CurriculumVitae__c.SkillSet__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }

                return options;
    }
       
    @AuraEnabled
    public static List<CurriculumVitae__c> getCVs() {
        system.debug('Start of getCVs...');
        
        /*
        // Check to make sure all fields are accessible to this user
        String[] fieldsToCheck = new String[] {
            'Id', 'Name', 'Amount__c', 'Candidate__c'
        };
        
        Map<String,Schema.SObjectField> fieldDescribeTokens = 
            Schema.SObjectType.CurriculumVitae__c.fields.getMap();
        
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
                return null;
            }
        }
        */
        
        // only return if user has access to the fields checked
        return [SELECT id, 
                        name, 
                        CandidateName__c,
                        Candidate__r.name,
                        Candidate__r.title,
                        MastHeading__c,
                        Subtitle__c,
                        Synopsis__c,
                        SkillSet__c,
                        Applications__c,
                        Methodologies__c
                   FROM CurriculumVitae__c];
    } 
        
    @AuraEnabled
    public static CurriculumVitae__c getCV (Id cvId) {
        system.debug('Start of getCV...');
        return [SELECT id, 
                name, 
                CandidateName__c,
                Candidate__r.name,
                Candidate__r.title,
                MastHeading__c,
                Subtitle__c,
                Synopsis__c,
                SkillSet__c,
                Applications__c,
                Methodologies__c
                FROM CurriculumVitae__c
                WHERE Id = :cvId];
    } 
    

    @AuraEnabled
        public static CurriculumVitae__c saveCV(CurriculumVitae__c cv) {
        upsert cv;
        return cv;
        } 
   
    // list to get details of the Curriculum Vita
    public list<CurriculumVitae__c> CVList = new List<CurriculumVitae__c>();
    
    // list to get the Career History from the CV
    public list<CVPosition__c> PositionList = new List<CVPosition__c>();
    
    // list to get the Qualifications linked to this CV
    public list<AwardedQualification__c> QualificationList = new List<AwardedQualification__c>();
    
    // list to get the Academic History linked to this CV
    public list<AwardedQualification__c> AcademicList = new List<AwardedQualification__c>();

    
    // id of the CV we want to display in the Site
    public id cvId = 'a0O24000008Tr3e';
    
    public void StartAction()
       {           
            system.debug('Start of StartAction...');
            PageReference pageRef = apexpages.currentpage();
            pageRef.getParameters().put('Id', cvId);
            //Test.setCurrentPage(pageRef);
            system.debug('currentPage Id: ' + ApexPages.currentPage().getParameters().get('id'));
       }
       
    // getter method for populating CVList and returning values to VF page
    public List<CurriculumVitae__c> getCVList {
       get
       {
           system.debug('Start of getCVList...');
           for (CurriculumVitae__c cv : [select id, 
                                            name, 
                                            Candidate__r.name,
                                            Candidate__r.title,
                                            MastHeading__c,
                                            Subtitle__c,
                                            Synopsis__c,
                                            SkillSet__c,
                                            Applications__c,
                                            Methodologies__c
                                       from CurriculumVitae__c
                                      where id = :ApexPages.currentPage().getParameters().get('id')]) {
                CVList.add(cv);
            }
            system.debug('CVList: ' + CVList);
            return CVList;
       }
       set;
    }
    
    // getter method for populating PositionList and returning values to VF page
    public List<CVPosition__c> getPositionList {
       get
       {
           system.debug('Start of getPositionList...');
           for (CVPosition__c pos : [select id, 
                                            name, 
                                            Description__c, 
                                            Company__r.name, 
                                            Company__r.BillingCity, 
                                            Project__c,
                                            Responsibilities__c, 
                                            Role__c, 
                                            Role__r.name,
                                            SkillsUsed__c,  
                                            StartDate__c, 
                                            StartMonthYear__c, 
                                            EndMonthYear__c, 
                                            CV__c,
                                            EmploymentType__c,
                                            Company__r.CompanyLogo__c
                                       from CVPosition__c
                                      where CV__r.id = :ApexPages.currentPage().getParameters().get('id')
                                      //where CV__r.id = :cvId
                                   order by StartDate__c desc]) {
                PositionList.add(pos);
            }
            system.debug('PositionList: ' + PositionList);
            return PositionList;
       }
       set;
    }
    
    public List<AwardedQualification__c> getQualificationList {
       get
       {
           system.debug('Start of getQualificationList...');
           for (AwardedQualification__c qual : [select id, 
                                                       Qualification__r.name,
                                                       Qualification__r.Organisation__c,
                                                       FromDate__c,
                                                       ToDate__c,  
                                                       CertificateNumber__c,
                                                       CertificateURL__c,
                                                       SortBy__c,
                                                       Qualification__r.Website__c,
                                                       DisplayFromDate__c
                                                  from AwardedQualification__c
                                                 //where CV__r.id = :cvId  
                                                 where CV__r.id = :ApexPages.currentPage().getParameters().get('id') 
                                                   and Certification__c = true                                 
                                                 order by SortBy__c asc]) {
                QualificationList.add(qual);
            }
            system.debug('QualificationList: ' + QualificationList);
            return QualificationList;
       }
       set;
    }
    
       public List<AwardedQualification__c> getAcademicList {
       get
       {
           system.debug('Start of getQualificationList...');
           for (AwardedQualification__c qual2 : [select id, 
                                                       Qualification__r.name,
                                                       Qualification__r.Organisation__c,
                                                       FromDate__c,
                                                       ToDate__c,  
                                                       CertificateNumber__c,
                                                       CertificateURL__c,
                                                       SortBy__c,
                                                       Qualification__r.Website__c,
                                                       DisplayFromDate__c,
                                                       DisplayToDate__c
                                                  from AwardedQualification__c
                                                 //where CV__r.id = :cvId  
                                                 where CV__r.id = :ApexPages.currentPage().getParameters().get('id') 
                                                   and Certification__c = false                                 
                                                 order by SortBy__c asc]) {
                AcademicList.add(qual2);
            }
            system.debug('AcademicList: ' + AcademicList);
            return AcademicList;
       }
       set;
    }

            
   
    public CVController(ApexPages.StandardController controller) {

    }

}