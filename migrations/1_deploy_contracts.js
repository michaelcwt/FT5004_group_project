const Module = artifacts.require("Module");
const Student = artifacts.require("Student");
const Teacher = artifacts.require("Teacher");
const School = artifacts.require("School");

module.exports = async (deployer, network, accounts) => {
    // let moduleContract = await deployer.deploy(Module);
    // let studentContract = await deployer.deploy(Student);
    // let teacherContract = await deployer.deploy(Teacher);
    // deployer.deploy(School, Student.address, Module.address, Teacher.address);
    deployer.deploy(Module).then(function() {
        return deployer.deploy(Student).then(function() {
            return deployer.deploy(Teacher).then(function() {
                return deployer.deploy(School, accounts[0], Student.address, Module.address, Teacher.address);
            });
        });
    });
};
