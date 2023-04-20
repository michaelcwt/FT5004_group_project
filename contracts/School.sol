//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../Token/EIP20Interface.sol";
import "../Token/EIP20.sol";
import "./Student.sol";
import "./Module.sol";
import "./Teacher.sol";

contract School {

    address organizer;
    Module moduleManager;
    Teacher teacherManager;
    Student studentManager;
    address[] student;
    address[] teacher;
  
    mapping(uint256 => mapping(uint256 => bool)) record;  // record whether students provided feedback on certain course
    mapping(address => uint256) public TokenBalance;  // maps student's address to Token balance

    EIP20Interface public token;  // using ERC20 token contract

    constructor (address _organizer, Student studentAddress, Module moduleAddress, Teacher teacherAddress){
        organizer = _organizer;
        studentManager = studentAddress;
        moduleManager = moduleAddress;
        teacherManager = teacherAddress;
        uint256 _supply = 100000000;
        string memory _name = "FBToken";
        string memory _symbol = "Rewards";
        uint8 _decimals = 1;
        EIP20 _token = new EIP20(_supply, _name, _decimals, _symbol, _organizer);
        
        token = EIP20Interface(_token);
        // token.transfer(_organizer, _supply); // Create a new token and give all the tokens to the school account

    }

    event TeacherCreated ();
    event StudentCreated ();
    event ModuleCreated ();
    event FeedbackRecieved ();
    event Feedback2Teacher();
    event Reward();



    //---------TEACHER FUNCTION
    function setTeacher(uint256 _moduleNumber, string memory _info,
                address _school, address _self, uint256[] memory _moduleList) public {

        require(_school == msg.sender, "only school can create student");

        uint256 newTeacherId = teacherManager.add(_moduleNumber, _info, _self, _school);
        teacherManager.setModuleList(newTeacherId,_moduleList);
        teacher.push(_self);

        emit TeacherCreated ();
    }

    function feedbackToTeacher(uint256 _moduleId) external {
        
        require(organizer == msg.sender, "only school can send feedback to teacher");
        uint256 _teacherId = moduleManager.getModuleTeacher(_moduleId);

        for(uint256 i = 0;i <= moduleManager.getModuleFeedbackCount(_moduleId);i++)
        {
            string memory _context = moduleManager.getModuleStudentFeedback(_moduleId, i);
            teacherManager.putFeedbackRecord(_teacherId, i, _moduleId, _context);  //  put the feedback to the according teacher for their reference

        }
        emit Feedback2Teacher();
    }
    //----------END OF TEACHER FUNCTION

    //---------STUDENT FUNCTION
    function setStudent(uint256 _moduleNumber, address _school, 
                address _self, uint256[] memory _moduleList) public {

        require(_school == msg.sender, "only school can create student");

        uint256 newStudentId = studentManager.add(_moduleNumber,_self, _school);
        studentManager.setModuleList(newStudentId,_moduleList);
        student.push(_self);
        for(uint256 i = 0;i < _moduleNumber;i++)
        {
            record[newStudentId][i] = false;
        }

        emit StudentCreated ();
    }

    function giveFeedback(uint256 _studentId, uint256 _moduleId,
            string memory _context, string memory _code) external {
        address studentAddress = studentManager.getStudentAddress(_studentId);
        require(studentAddress == msg.sender, "authentication failed!");
        string memory moduleCode = moduleManager.getModuleCode(_moduleId);
        require(isEqual(moduleCode, _code), "wrong code, you do not have the right to give feedback to this module!");
        require(record[_studentId][_moduleId] == false, "You have already given feedback on the module!");

        moduleManager.putModuleStudentFeedback(_moduleId, _context);  //  push the context into the according module's feedback list

        record[_studentId][_moduleId] = true;   // ensure the students can only give feedback to each module once

        uint256 _numTokens = 1;
        require(token.balanceOf(organizer) >= _numTokens, "You do not have enough token");
        TokenBalance[msg.sender] += _numTokens;
        require(token.transferFrom(organizer, msg.sender, _numTokens));  // School transfer token to student as rewards.

        emit FeedbackRecieved ();
    }

    function exchangeforRewards(uint256 _numTokens, address _studentAddress) external {
        require(_studentAddress == msg.sender,"You do not have permission to exchange");
        require(token.balanceOf(msg.sender) >= _numTokens,"Your token amount is not enough");
        TokenBalance[msg.sender] -= _numTokens;
        require(token.transferFrom(msg.sender, organizer, _numTokens));  // student exchange tokens for rewards.
        emit Reward();
    }


    //----------END OF STUDENT FUNCTION

    //---------MODULE FUNCTION
    function setModule(uint256 _studentNumber, string memory _code, string memory _intro,
                address _school, address _teacher, uint256 _teacherId) public {

        require(_school == msg.sender, "only school can create module");

        uint256 newModuleId = moduleManager.add(_studentNumber, _code, _intro, _teacher, _school, _teacherId);


        emit ModuleCreated ();
    }
    //----------END OF MODULE FUNCTION

    //----------HELPER FUNCTION
    function isEqual(string memory a, string memory b) public pure returns (bool) 
    {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        
        if (aa.length != bb.length) return false;
       
        for(uint i = 0; i < aa.length; i ++) {
            if(aa[i] != bb[i]) return false;
        }
 
        return true;
    }
    function getOrganizer() public view returns(address)
    {
        return organizer;
    }
    function getBalance(address _studentAddress) public view returns(uint256) {
        require(msg.sender == _studentAddress,"You do not have permission to check for balance");
        return TokenBalance[_studentAddress];
    }
}