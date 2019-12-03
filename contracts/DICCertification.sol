pragma solidity >=0.4.22 <0.6.0;

// Requirements for the Data Intensive Computing Certification
// Reference: https://catalog.buffalo.edu/academicprograms/data-intensive_computing_cert_requirements.html
    
// Prerequisites:
// 1. CSE 115 - Intro to CS 1 : 4544
// 2. CSE 116 - Intro to CS 2 : 4545
    
// Required Courses:
// 1. CSE 250 - Data Structures and algorithms : 4555
// 2. CSE 486 - Distributed Systems : 17770
// 3. CSE 487 - Data Intensive Computing : 4875

// Domain Requirement:
// 4. Any 300 or 400 level course with data intensive content in the major area of the student
// Has a list of sufficient courses. If not available, can be verified by admin.
    
// Required Projects:
// Capstone project in the major area of the student
// CSE 498 or CSE 499 is sufficient. If not available, can be verified by admin

// GPA: greater than 2.5 in the required and elective courses above

contract DICCertification {
    
    struct Course {
        uint gpa;
        bool exists;
    }

    uint constant private MINIMUM_GPA_REQUIRED = 250;
    uint[] private PRE_REQUISITE_COURSES = [4544, 4545];
    uint[] private REQUIRED_COURSES = [4555, 17770, 4875];
    uint[] private CSE_DOMAIN_COURSES = [302012, 17728, 300104, 456, 301978, 4870, 17764, 17765, 301158, 302011, 17768];

    address private admin;
    
    // Person Number -> Program Code -> {GPA, exists} mapping
    mapping(uint => mapping(uint => Course)) private computerScienceCourses;
    mapping(uint => mapping(uint => Course)) private otherDepartmentCourses;
    
    // Person Number -> Boolean mapping
    mapping(uint => bool) private capstoneProjectVerified;
    mapping(uint => bool) private domainRequirementVerified;
    
    // Modifiers 
    modifier onlyAdmin() {
        require(
            admin == msg.sender,
            "User not authorized."
        );
        _;
    }
    
    modifier validGPA(uint GPA) {
        require(
            GPA <= 400,
            "GPA should be 0 - 400 (Ex: Convert 3.98 to 398)"
        );
        _;
    }
    
    modifier validPersonNumber(uint personNumber) {
        require(
            personNumber > 0,
            "Person number cannot be 0"
        );
        _;
    }
    
    modifier validProgramCode(uint programCode) {
        require(
            programCode >= 1 && programCode <= 999999,
            "Program code should be 1-999999"
        );
        _;
    }
    
    // Events
    event courseAdded(uint personNumber, uint courseName);
    
    event preRequisiteSatisified(uint personNumber);
    event preRequisiteNotSatisified(uint personNumber, uint programCode);
    
    event requiredCoursesSatisfied(uint personNumber);
    event requiredCoursesNotSatisfied(uint personNumber, uint programCode);
    
    event GPARequirementSatisfied(uint personNumber);
    event GPARequirementNotSatisfied(uint personNumber);
    
    event projectRequirementSatisfied(uint personNumber);
    event projectRequirementNotSatisfied(uint personNumber);
    
    event domainRequirementSatisfied(uint personNumber);
    event domainRequirementNotSatisfied(uint personNumber);
    
    constructor() public {
        admin = msg.sender;
    }
    
    function addCSCourse(uint personNumber, uint programCode, uint courseGPA) public 
            validPersonNumber(personNumber) validProgramCode(programCode) validGPA(courseGPA) {
        computerScienceCourses[personNumber][programCode].gpa = courseGPA;
        computerScienceCourses[personNumber][programCode].exists = true;
        emit courseAdded(personNumber, programCode);
        
        // Verify if course satisfies project requirement
        verifyCourseForProjectRequirement(personNumber, programCode);
        
        // Verify if course satisfies domain requirement
        verifyCourseForDomainRequirement(personNumber, programCode);
    }
    
    function addNonCSCourse(uint personNumber, uint programCode, uint courseGPA) public 
            validPersonNumber(personNumber) validProgramCode(programCode) validGPA(courseGPA) {
        otherDepartmentCourses[personNumber][programCode].gpa = courseGPA;
        otherDepartmentCourses[personNumber][programCode].exists = true;
        emit courseAdded(personNumber, programCode);
    }
    
    function verifyCapstoneProject(uint personNumber) public onlyAdmin() validPersonNumber(personNumber) {
        capstoneProjectVerified[personNumber] = true;
    }
    
    function verifyDomainRequirement(uint personNumber) public onlyAdmin() validPersonNumber(personNumber) {
        domainRequirementVerified[personNumber] = true;
    }
    
    function checkEligibility(uint personNumber) public validPersonNumber(personNumber) returns(bool) {
        bool preRequisiteDone = checkPreRequisites(personNumber);
        bool requiredDone = checkRequiredCourses(personNumber);
        bool GPASatisfied = checkGPARequirement(personNumber);
        bool projectSatisfied = checkCapstoneProjectRequirement(personNumber);
        bool domainSatisfied = checkDomainRequirement(personNumber);
        
        return preRequisiteDone && requiredDone && GPASatisfied && projectSatisfied && domainSatisfied;
    }
    
    // Private functions
    
    function checkPreRequisites(uint personNumber) private returns(bool) {
        bool requirementSatisfied = true;
        
        for (uint i=0; i<PRE_REQUISITE_COURSES.length; i++) {
            if(!computerScienceCourses[personNumber][PRE_REQUISITE_COURSES[i]].exists) {
                requirementSatisfied = false;
                emit preRequisiteNotSatisified(personNumber, PRE_REQUISITE_COURSES[i]);
            }
        }
        
        if(requirementSatisfied) {
            emit preRequisiteSatisified(personNumber);
        }
        
        return requirementSatisfied;
    }
    
    function checkRequiredCourses(uint personNumber) private returns(bool) {
        bool requirementSatisfied = true;
        
        for (uint i=0; i<REQUIRED_COURSES.length; i++) {
            if(!computerScienceCourses[personNumber][REQUIRED_COURSES[i]].exists) {
                requirementSatisfied = false;
                emit requiredCoursesNotSatisfied(personNumber, REQUIRED_COURSES[i]);
            }
        }
        
        if(requirementSatisfied) {
            emit requiredCoursesSatisfied(personNumber);
        }
        
        return requirementSatisfied;
    }
    
    function checkGPARequirement(uint personNumber) private returns(bool) {
        uint sum = 0;
        uint totalCourses = PRE_REQUISITE_COURSES.length + REQUIRED_COURSES.length;
        bool result = false;
        
        for (uint i=0; i<PRE_REQUISITE_COURSES.length; i++) {
          sum += computerScienceCourses[personNumber][PRE_REQUISITE_COURSES[i]].gpa;
        }
        
        for (uint i=0; i<REQUIRED_COURSES.length; i++) {
          sum += computerScienceCourses[personNumber][REQUIRED_COURSES[i]].gpa;
        }
        
        if((sum / totalCourses) >= MINIMUM_GPA_REQUIRED) {
            result = true;
            emit GPARequirementSatisfied(personNumber);
        } else {
            emit GPARequirementNotSatisfied(personNumber);
        }
        
        return result;
    }
    
    function checkCapstoneProjectRequirement(uint personNumber) private returns(bool) {
        if(capstoneProjectVerified[personNumber]) {
            emit projectRequirementSatisfied(personNumber);
        } else {
            emit projectRequirementNotSatisfied(personNumber);
        }
        return capstoneProjectVerified[personNumber];
    }
    
    function checkDomainRequirement(uint personNumber) private returns(bool) {
        if(domainRequirementVerified[personNumber]) {
            emit domainRequirementSatisfied(personNumber);
        } else {
            emit domainRequirementNotSatisfied(personNumber);
        }
        return domainRequirementVerified[personNumber];
    }
    
    function verifyCourseForProjectRequirement(uint personNumber, uint programCode) private {
        if(programCode == 498 || programCode == 499) {
            capstoneProjectVerified[personNumber] = true;
        }
    }
    
    function verifyCourseForDomainRequirement(uint personNumber, uint programCode) private {
        for (uint i=0; i<CSE_DOMAIN_COURSES.length; i++) {
          if(CSE_DOMAIN_COURSES[i] == programCode) {
              domainRequirementVerified[personNumber] = true;
          }
        }
    }
    
}