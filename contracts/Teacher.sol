pragma solidity ^0.8.19;

contract Teacher {
    
    
    struct teacher {
     
        uint256 teacherId;
        uint256 moduleNumber;
        string intro;
       
        address school;
        address self;
        uint256[] moduleList;
        // string[] studentFeedback;
    }
    mapping(uint256 => mapping(uint256 => mapping(uint256 => string))) feedbackRecord;   // fetch and store the feedback for every module 
    
    
    uint256 public numTeachers = 0;
    mapping(uint256 => teacher) public teachers;

    //function to create a new module, and add to 'modules' map. 
    function add(
        uint256 moduleNumber,
        string memory intro,
        address self,
        address school
    ) public returns(uint256) {
        require(moduleNumber > 0);
        uint256[] memory moduleList = new uint256[](moduleNumber);
        //new teacher object
        teacher memory newTeacher = teacher (
            0,   // here we add the initalization of teacherID to 0
            moduleNumber,
            intro, 
            school,  //shcool
            self,
            moduleList
        );
        
        uint256 newTeacherId = numTeachers++;
        newTeacher.teacherId = newTeacherId;
        teachers[newTeacherId] = newTeacher; //commit to state variable
        return newTeacherId;   //return new teacherId
    }

    
    modifier validTeacherId(uint256 teacherId) {
        require(teacherId < numTeachers);
        _;
    }

    //Destroy teacher
    function destroyTeacher(uint256 teacherId) public validTeacherId(teacherId) {
        delete teachers[teacherId];
        numTeachers = numTeachers - 1;

    }

    //get module number of this teacher   
    function getmModuleNumber(uint256 teacherId) public view validTeacherId(teacherId) returns (uint256) {
        return teachers[teacherId].moduleNumber;
    }

    //get address of this teacher   
    function getTeacherAddress(uint256 teacherId) public view validTeacherId(teacherId) returns (address) {
        return teachers[teacherId].self;
    }

    //get intro of this teacher
    function getTeacherIntro(uint256 teacherId) public view validTeacherId(teacherId) returns (string memory) {
        return teachers[teacherId].intro;
    }

    //get module list of this teacher
    function getModuleList(uint256 teacherId) public view validTeacherId(teacherId) returns (uint256[] memory) {
        return teachers[teacherId].moduleList;
    }
    //set module list of this teacher
    function setModuleList(uint256 teacherId, uint256[] memory _moduleList) public validTeacherId(teacherId) {
        teachers[teacherId].moduleList = _moduleList;
    }
    function putFeedbackRecord(uint256 _teacherId, uint256 _feedbackId, uint256 _moduleId, string memory context) public
    {
        feedbackRecord[_teacherId][_moduleId][_feedbackId] = context;
    }
    
}

