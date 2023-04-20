pragma solidity ^0.8.19;


contract Student {
    
    
    struct student {
     
        uint256 studentId;
        uint256 moduleNumber;
       
        address school;
        address self;
        uint256[] moduleList;
    }
    
    uint256 public numStudents = 0;
    mapping(uint256 => student) public students;

    //function to create a new student, and add to 'students' map. 
    function add(
        uint256 moduleNumber,
        address self,
        address school
        // uint256[] memory moduleList
    ) public returns(uint256) {
        require(moduleNumber > 0);
        uint256[] memory moduleList = new uint256[](moduleNumber);
        //new student object
        student memory newStudent = student (
            0,   // here we add the initalization of studentID to 0
            moduleNumber,
            school,  //shcool
            self,
            moduleList
        );
        
        uint256 newStudentId = numStudents++;
        newStudent.studentId = newStudentId;
        students[newStudentId] = newStudent; //commit to state variable
        return newStudentId;   //return new studentId
    }

    
    modifier validStudentId(uint256 studentId) {
        require(studentId < numStudents);
        _;
    }

    //Destroy student
    function destroyStudent(uint256 studentId) public validStudentId(studentId) {
        delete students[studentId];
        numStudents = numStudents - 1;
    }
    //get module number of this student   
    function getmModuleNumber(uint256 studentId) public view validStudentId(studentId) returns (uint256) {
        return students[studentId].moduleNumber;
    }
    //get address of this student
    function getStudentAddress(uint256 studentId) public view validStudentId(studentId) returns (address) {
        return students[studentId].self;
    }
    //get module list of this student
    function getModuleList(uint256 studentId) public view validStudentId(studentId) returns (uint256[] memory) {
        return students[studentId].moduleList;
    }
    //set module list of this student
    function setModuleList(uint256 studentId, uint256[] memory _moduleList) public validStudentId(studentId) {
        students[studentId].moduleList = _moduleList;
    }
    
}

