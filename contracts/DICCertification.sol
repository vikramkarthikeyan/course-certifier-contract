pragma solidity >=0.4.22 <0.6.0;

// Requirements for the Data Intensive Computing Certification
// Reference: https://catalog.buffalo.edu/academicprograms/data-intensive_computing_cert_requirements.html
    
// Prerequisites:
// 1. CSE 115 - Intro to CS 1
// 2. CSE 116 - Intro to CS 2
    
// Required Courses:
// 1. CSE 250 - Data Structures and algorithms (or) equivalent
// 2. CSE 486 - Distributed Systems
// 3. CSE 487 - Data Intensive Computing
// 4. Any 300 or 400 level course with data intensive content in the major area of the student
    
// Required Projects:
// Capstone project in the major area of the student.

// Total credit hours required: 23
// GPA: greater than 2.5 in the required and elective courses above

contract DICCertification {
    
    uint MINIMUM_GPA_REQUIRED = 250;
    
    // Pre-requisite courses
    string CSE_115 = "CSE115";
    string CSE_116 = "CSE116";
    
    // Required courses
    string CSE_250 = "CSE250";
    string CSE_486 = "CSE486";
    string CSE_487 = "CSE487";
    
    // Only the admin should have access to add user course information
    address owner;
    
    struct Course {
        uint gpa;
        bool exists;
    }

    // Mappings
    // PersonNumber:Course:GPA Mapping
    mapping(string => mapping(string => Course)) public computerScienceCourses;
    mapping(string => mapping(string => Course)) public otherDepartmentCourses;
    
    // Modifiers
    modifier onlyBy(address _account) {
        require(
            msg.sender == _account,
            "Sender not authorized."
        );
        _;
    }

    modifier taken115(string memory personNumber) {
        require(
            computerScienceCourses[personNumber][CSE_115].exists,
            "The student has not taken CSE115"
        );
        _;
    }
    
    modifier taken116(string memory personNumber) {
        require(
            computerScienceCourses[personNumber][CSE_116].exists,
            "The student has not taken CSE116"
        );
        _;
    }
    
    modifier taken250(string memory personNumber) {
        require(
            computerScienceCourses[personNumber][CSE_250].exists,
            "The student has not taken CSE250"
        );
        _;
    }
    
    modifier taken486(string memory personNumber) {
        require(
            computerScienceCourses[personNumber][CSE_486].exists,
            "The student has not taken CSE486"
        );
        _;
    }
    
    modifier taken487(string memory personNumber) {
        require(
            computerScienceCourses[personNumber][CSE_487].exists,
            "The student has not taken CSE487"
        );
        _;
    }

    // Events
    event courseAdded(string personNumber, string courseName);
    event preRequisiteSatisified(string personNumber);
    event requiredCoursesSatisfied(string personNumber);
    event GPARequirementSatisfied(string personNumber, bool satisfied);
    event projectRequirementSatisfied(string personNumber);
    event eligibleForCertification(string personNumber);
    
    // Constructors
    constructor() public {
        owner = msg.sender;
    }
    
    // Public Functions
    function changeOwner(address newOwner)
    public onlyBy(owner) {
        owner = newOwner;
    }
    
    function addCSCourse(string memory personNumber, string memory courseName, uint courseGPA)
    public onlyBy(owner) {
        computerScienceCourses[personNumber][courseName].gpa = courseGPA;
        computerScienceCourses[personNumber][courseName].exists = true;
        emit courseAdded(personNumber, courseName);
    }
    
    function addNonCSCourse(string memory personNumber, string memory courseName, uint courseGPA) 
    public onlyBy(owner) {
        otherDepartmentCourses[personNumber][courseName].gpa = courseGPA;
        otherDepartmentCourses[personNumber][courseName].exists = true;
        emit courseAdded(personNumber, courseName);
    }
    
    function checkEligibility(string memory personNumber)
    public returns(bool) {
        return checkPreRequisites(personNumber) && checkRequiredCourses(personNumber) 
        && checkGPARequirement(personNumber);
    }
    
    // Private functions
    function checkPreRequisites(string memory personNumber)
    private taken115(personNumber) taken116(personNumber) returns(bool) {
        emit preRequisiteSatisified(personNumber);
        return true;
    }
    
    function checkRequiredCourses(string memory personNumber)
    private taken250(personNumber) taken486(personNumber) taken487(personNumber) returns(bool) {
        emit requiredCoursesSatisfied(personNumber);
        return true;
    }
    
    function checkGPARequirement(string memory personNumber)
    private returns(bool) {
        uint sum = 0;
        
        sum += computerScienceCourses[personNumber][CSE_115].gpa;
        sum += computerScienceCourses[personNumber][CSE_116].gpa;
        sum += computerScienceCourses[personNumber][CSE_250].gpa;
        sum += computerScienceCourses[personNumber][CSE_486].gpa;
        sum += computerScienceCourses[personNumber][CSE_487].gpa;
        
        bool satisfied = (sum / 5) >= MINIMUM_GPA_REQUIRED;
        emit GPARequirementSatisfied(personNumber, satisfied);
        return satisfied;
    }
}