pragma solidity ^0.8.19;

contract Module {
    
    
    struct module {
     
        uint256 moduleId;
        uint256 studentNumber;
        uint256 feedbackCount;
        string code;
        string intro;
        
        address school;
        address teacher;
        uint256 teacherId;
        string[] studentFeedback;
    }
    

    
    uint256 public numModules = 0;
    mapping(uint256 => module) public modules;

    //function to create a new module, and add to 'modules' map. 
    function add(
        uint256 studentNumber,
        string memory code,
        string memory intro,
        address teacher,
        address school,
        uint256 teacherId
    ) public returns(uint256) {
        require(studentNumber > 0);
        string[] memory feedback = new string[](studentNumber);
        //new module object
        module memory newModule = module(
            0,   // here we add the initalization of moduleID to 0
            studentNumber,
            0,
            code,
            intro, 
            school,  //shcool
            teacher,
            teacherId,
            feedback
        );
        
        uint256 newModuleId = numModules++;
        newModule.moduleId = newModuleId;
        modules[newModuleId] = newModule; //commit to state variable
        return newModuleId;   //return new diceId
    }

    //modifier to ensure a function is callable only by its owner(shcool or teacher)  
    modifier ownerOnly(uint256 moduleId) {
        require((modules[moduleId].school == msg.sender) || (modules[moduleId].teacher == msg.sender));
        _;
    }
    
    modifier validModuleId(uint256 moduleId) {
        require(moduleId < numModules);
        _;
    }

   
    //Destroy module
    function destroyModule(uint256 moduleId) public ownerOnly(moduleId) validModuleId(moduleId) {
        delete modules[moduleId];
        numModules = numModules - 1;

    }
    //get code of this module   
    function getModuleCode(uint256 moduleId) public view validModuleId(moduleId) returns (string memory) {
        return modules[moduleId].code;
    }

    //get intro of this module
    function getModuleIntro(uint256 moduleId) public view validModuleId(moduleId) returns (string memory) {
        return modules[moduleId].intro;
    }

    //get student number of this module
    function getModuleStudenNumber(uint256 moduleId) public view validModuleId(moduleId) returns (uint256) {
        return modules[moduleId].studentNumber;
    }
    //get teacher of this module
    function getModuleTeacher(uint256 moduleId) public view validModuleId(moduleId) returns (uint256) {
        return modules[moduleId].teacherId;
    }
    //get student feedback of this module !!!here need attention string[]
    function getModuleStudentFeedback(uint256 moduleId) public view validModuleId(moduleId) returns (string[] memory) {
        return modules[moduleId].studentFeedback;
    }

    //set student feedback of this module !!!here need attention string[]
    function setModuleStudentFeedback(uint256 moduleId, string[] memory _feedback) public validModuleId(moduleId) {
        modules[moduleId].studentFeedback = _feedback;
    }
    //get feedback Count of this module
    function getModuleFeedbackCount(uint256 moduleId) public view validModuleId(moduleId) returns (uint256) {
        return modules[moduleId].feedbackCount;
    }
    //put one student feedback of this module !!!here need attention string[]
    function putModuleStudentFeedback(uint256 moduleId, string memory _feedback) public validModuleId(moduleId) {
        modules[moduleId].feedbackCount += 1;
        modules[moduleId].studentFeedback[modules[moduleId].feedbackCount-1] = _feedback;
    }
    //get one student feedback of this module !!!here need attention string[]
    function getModuleStudentFeedback(uint256 moduleId, uint256 _feedbackId) public view validModuleId(moduleId) returns (string memory){
        return modules[moduleId].studentFeedback[_feedbackId];
    }
}

