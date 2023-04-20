const _deploy_contracts = require("../migrations/1_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');
const internal = require("stream");

var Student = artifacts.require("../contracts/Student.sol");
var Module = artifacts.require("../contracts/Module.sol");
var Teacher = artifacts.require("../contracts/Teacher.sol");
var School = artifacts.require("../contracts/School.sol");

contract('School', function(accounts) {
    before(async () => {
        studenInstance = await Student.deployed();
        teacherInstance = await Teacher.deployed();
        moduleInstance = await Module.deployed();
        schoolInstance = await School.deployed(accounts[0]);
    });
    console.log("Testing School(Feedback) Contract");

    // test shcool creating student
    it('Creation of Student', async() => {

        // console.log(accounts[1]);
        let makeS1 = await schoolInstance.setStudent(3,accounts[0],accounts[2],[0,1,2],{from: accounts[0]});
        let makeS2 = await schoolInstance.setStudent(3,accounts[0],accounts[3],[1,2,3],{from: accounts[0]});
        let makeS3 = await schoolInstance.setStudent(3,accounts[0],accounts[4],[0,2,3],{from: accounts[0]});

        assert.notStrictEqual(
            makeS1,
            undefined,
            'Creating Student failed'
        );
        assert.notStrictEqual(
            makeS2,
            undefined,
            "Creating Student failed"
        );
        assert.notStrictEqual(
            makeS3,
            undefined,
            "Creating Student failed"
        );
    })

    // test shcool creating teacher
    it('Creation of Teacher', async() => {
        let makeT1 = await schoolInstance.setTeacher(2,"Kenny",accounts[0],accounts[5],[0,1],{from: accounts[0]});
        let makeT2 = await schoolInstance.setTeacher(2,"Micheal",accounts[0],accounts[6],[2,3],{from: accounts[0]});

        assert.notStrictEqual(
            makeT1,
            undefined,
            'Creating Teacher failed'
        );
        assert.notStrictEqual(
            makeT2,
            undefined,
            "Creating Teacher failed"
        );
    })
    
    // test shcool creating modules
    it('Creation of Module', async() => {
        let teacher0Address = await teacherInstance.getTeacherAddress.call(0);
        let teacher1Address = await teacherInstance.getTeacherAddress.call(1);

        let makeM1 = await schoolInstance.setModule(2,"00000","FT5001",accounts[0],teacher0Address,0,{from: accounts[0]});
        let makeM2 = await schoolInstance.setModule(3,"12345","FT5002",accounts[0],teacher0Address,0,{from: accounts[0]});
        let makeM3 = await schoolInstance.setModule(2,"54321","FT5003",accounts[0],teacher1Address,1,{from: accounts[0]});
        let makeM4 = await schoolInstance.setModule(2,"11111","FT5003",accounts[0],teacher1Address,1,{from: accounts[0]});

        assert.notStrictEqual(
            makeM1,
            undefined,
            'Creating Module failed'
        );
        assert.notStrictEqual(
            makeM2,
            undefined,
            "Creating Module failed"
        );
        assert.notStrictEqual(
            makeM3,
            undefined,
            "Creating Module failed"
        );
        assert.notStrictEqual(
            makeM4,
            undefined,
            "Creating Module failed"
        );
    })

    it("Students give feedback to a module without the right code", async() => {
        try{
            let feedback1 = await schoolInstance.giveFeedback(0,0,"this course is good",'12345',{from: accounts[2]});

            assert.fail("Contracts should have thrown an error!");
        }catch(err) {
            // assert.include(err.message, 'require','the error should be sent require statement');
        }
    })

    it("Students cannot give feedback to a module more than one time", async() => {
        let feedback2 = await schoolInstance.giveFeedback(0,1,"this course is good",'12345',{from: accounts[2]});
        try{
            let feedback3 = await schoolInstance.giveFeedback(0,1,"this course helps me a lot",'12345',{from: accounts[2]});

            assert.fail("Contracts should have thrown an error!");
        }catch(err) {
            // assert.include(err.message, 'require','the error should be sent require statement');
        }
    })

    it('school forward module feedback to teacher', async() => {
        let feedback4 = await schoolInstance.giveFeedback(1,1,"this course is bad",'12345',{from: accounts[3]});
        let feedback2teacher1 = await schoolInstance.feedbackToTeacher(1, {from: accounts[0]});
    })

    it('no one except school can forward module feedback to teacher', async() => {
        try{
            let feedback2teacher2 = await schoolInstance.feedbackToTeacher(1, {from: accounts[5]});
            assert.fail("Contracts should have thrown an error!");
        }catch(err) {
            // assert.include(err.message, 'require','the error should be sent require statement');
        }
    })

    it('student give module feedback and get 1 token', async() => {
        let feedback5 = await schoolInstance.giveFeedback(1,2,"this course helps me a lot",'54321',{from: accounts[3]});
        let feedback6 = await schoolInstance.giveFeedback(1,3,"this course is of no use",'11111',{from: accounts[3]});
        let balanceS1 = await schoolInstance.getBalance.call(accounts[3],{from: accounts[3]})
        assert.notStrictEqual(
            balanceS1,
            3,
            "Token for Feedback Error!"
        );
    })

    it('student exchange tokens for rewards, but not enough amount', async() => {
        let feedback7 = await schoolInstance.giveFeedback(2,0,"this course teach me math",'00000',{from: accounts[4]});
        let feedback8 = await schoolInstance.giveFeedback(2,3,"this course teach me coding",'11111',{from: accounts[4]});
        try{
            let rewards1 = await schoolInstance.exchangeforRewards(3,accounts[4],{from: accounts[4]});
            assert.fail("Contracts should have thrown an error!");
        }catch(err) {
            // assert.include(err.message, 'require','the error should be sent require statement');
        }
        
    })

    it('student exchange tokens for rewards, but only student himself can do it', async() => {
        // let feedback7 = await schoolInstance.giveFeedback(2,0,"this course teach me math",'00000',{from: accounts[4]});
        // let feedback8 = await schoolInstance.giveFeedback(2,3,"this course teach me coding",'11111',{from: accounts[4]});
        try{
            let rewards2 = await schoolInstance.exchangeforRewards(2,accounts[3],{from: accounts[4]});
            assert.fail("Contracts should have thrown an error!");
        }catch(err) {
            // assert.include(err.message, 'require','the error should be sent require statement');
        }
        
    })
    it('student exchange tokens for rewards successfully', async() => {
        // let feedback7 = await schoolInstance.giveFeedback(2,0,"this course teach me math",'00000',{from: accounts[4]});
        // let feedback8 = await schoolInstance.giveFeedback(2,3,"this course teach me coding",'11111',{from: accounts[4]});
        let rewards3 = await schoolInstance.exchangeforRewards(2,accounts[4],{from: accounts[4]});
        let balanceS2 = await schoolInstance.getBalance.call(accounts[4],{from: accounts[4]})
        assert.notStrictEqual(
            balanceS2,
            0,
            "Token balance Error!"
        );
        truffleAssert.eventEmitted(rewards3,'Reward');
    })

    it('only student self can check thier own balance', async() => {
        try{
            let balanceCheck = await schoolInstance.getBalance(accounts[3],{from: accounts[4]});
            assert.fail("Contracts should have thrown an error!");
        }catch(err) {
            // assert.include(err.message, 'require','the error should be sent require statement');
        }
    })
})