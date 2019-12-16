pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./Stakeholders.sol";
import "./food_pagonis.sol";
/*
COPYRIGHT FRAN CASINO. 2019.
SECURITY CHECKS ARE COMMENTED FOR AN EASY USE TEST.
YOU WILL NEED TO USE METAMASK OR OTHER EXTENSIONS TO USE THE REQUIRED ADDRESSES
ACTUALLY DATA ARE STORED IN THE SC. TO ENABLE IPFS, FUNCTIONS WILL NOT STORE the values and just the hash in the structs.
This can be changed in the code by calling the hash creation function. 
Nevertheless, the code is kept clear for the sake of understanding. 
*/


contract Processes{

    struct Process {
        uint id; // 
	    string name;       
        uint timestamp; // when it was registered
        string description; // other info
	    bool active;
        address maker; // who registered it and will execute it,stakeholder
        string hashIPFS; // hash of the elements of the struct, for auditing AND IPFS
	    uint localnumberofproducts; // number of products associated with this process 
	    uint [] involvedproducts; // id of products that use this process
    }

    mapping(uint => Process) private processChanges; //

    
    uint private productsCount;
    uint private processCount;


    // events, since SC is for global accounts it does not have too much sense but is left here 
    event updateEvent ( // triggers update complete
    );
    
    event changeStatusEvent ( // triggers status change
    );

    address constant public stakeholder = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9; // who registers the token into system. 
    address constant public adminaddr = 0xE0F5206bbd039e7b0592d8918820024E2A743222; // admin, current

    constructor () public { // constructor, inserts new process in system. we map starting from id=1, hardcoded values of all
        addProcess("Mixing",1573564413,"Mix milk with L.bacteria"); // simple example.
        
    }
    
    // add process 
    function addProcess (string memory _name, uint _timestamp, string memory _description) public {
        //require(Processes.checkStakeholder(address addr, msg.sender)==true); // if valid stakeholder
        processCount++;

        processChanges[processCount].id = processCount;
        processChanges[processCount].name = _name; 
        processChanges[processCount].timestamp = _timestamp; 
        processChanges[processCount].description = _description; 
        processChanges[processCount].active = true; 
        processChanges[processCount].localnumberofproducts=0;
        processChanges[processCount].maker = msg.sender;
        emit updateEvent(); // trigger event 
    
    }

    // we add a product to a process to keep track of it
    function addProcessProduct(uint _id) public { // address of the food_pagonis contract
	    //require(msg.sender == adminaddr or msg.sender == processChanges[_id].myself); // only if admin or himself
        //require(productsCount >= _id) // the product exists
        processChanges[processCount].involvedproducts.push(_id);
        emit updateEvent(); // trigger event 
    }

    function changeStatus (uint _id, bool _active) public { 
        require(_id > 0 && _id <= processCount); 
        //require(Processes.checkStakeholder(address addr, msg.sender)==true); // if valid stakeholder
        processChanges[processCount].active = _active;
        emit changeStatusEvent(); // trigger event 
    }
    
    // get the products managed by the process
    function getProcessProduct (uint _id) public view returns (uint [] memory)  {
        require(_id > 0 && _id <= processCount);  // security check avoid memory leaks
        //require(Processes.checkStakeholder(address addr, msg.sender)==true); // if valid stakeholder
        return processChanges[_id].involvedproducts;
    }

     // get the products managed by the process
    function getNumberofProductsProcess (uint _id) public view returns (uint)  {
        require(_id > 0 && _id <= processCount);  // security check avoid memory leaks
        //require(Processes.checkStakeholder(address addr, msg.sender)==true); // if valid stakeholder
        return processChanges[_id].localnumberofproducts;
    }

    function getProcess (uint _processId) public view returns (Process memory)  {
        require(_processId > 0 && _processId <= processCount); 
       //require(Processes.checkStakeholder(address addr, msg.sender)==true); // if valid stakeholder    
        return processChanges[_processId];
    }
    
    // returns global number of stories, needed to iterate the mapping and to know info.
    function getNumberOfProcesses () public view returns (uint){
    //tx.origin 
        return processCount;
    }
    
    function checkStakeholder (address addr, address stake) public view returns (bool){
        Stakeholders s = Stakeholders(addr);
        bool ex=s.exists(stake);
        return ex;
    }

    function updateNumberOfProducts (address addr) public {
        food_pagonis f = food_pagonis(addr);
        productsCount =f.getNumberOfProducts(); 
    }
    
}
