pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


import "./Processes.sol";
import "./Food_pagonis.sol";
/*
COPYRIGHT FRAN CASINO. 2019.
SECURITY CHECKS ARE COMMENTED FOR AN EASY USE TEST.
YOU WILL NEED TO USE METAMASK OR OTHER EXTENSIONS TO USE THE REQUIRED ADDRESSES
ACTUALLY DATA ARE STORED IN THE SC. TO ENABLE IPFS, FUNCTIONS WILL NOT STORE the values and just the hash in the structs.
This can be changed in the code by calling the hash creation function. 
Nevertheless, the code is kept clear for the sake of understanding. 

*/

contract Stakeholders{
 
    struct Stakeholder{
        uint id; // id
        string name; // the name of stakeholder
        uint timestamp; // when it was registered
        uint [] involvedproducts; // products used or related to stakeholder
        string description; // other info
	    address myself; // the address of this stakeholder
        address maker; // who registered this stakeholder, admin system
        bool active; // to enable or disable this stakeholder
        string hashIPFS; // hash of the elements of the struct, for auditing AND IPFS 
    }

    //mapping(uint => Stakeholder) private stakeholderChanges; //

    mapping(address => Stakeholder) private stakeholderAddrs; //

    uint private productsCount;
    uint private stakeholderCount;
    uint private processesCount;

    // events, since SC is for global accounts it does not have too much sense but is left here 
    event updateEvent ( // triggers update complete
    );
    
    event changeStatusEvent ( // triggers status change
    );

    address constant public stakeholder = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9; // example of stakeholder
    address constant public adminaddr = 0xE0F5206bbd039e7b0592d8918820024E2A743222; // admin, current

    constructor () public { // constructor, we map starting from id=1, hardcoded values of all
        addStakeholder("Milk Corp.",1573564413,"Local milk provider", 0xE0f5206BBD039e7b0592d8918820024e2a7437b9); //
        
    }
    
    // add stakeholder to the list. checkers security disabled
    function addStakeholder (string memory _name, uint _timestamp, string memory _description, address _stake) public {
	//require(msg.sender == adminaddr); // only if admin
        stakeholderCount++;
        /*stakeholderChanges[stakeholderCount].id = stakeholderCount;
        stakeholderChanges[stakeholderCount].name = _name; 
        stakeholderChanges[stakeholderCount].timestamp = _timestamp; 
        stakeholderChanges[stakeholderCount].description = _description;
	    stakeholderChanges[stakeholderCount].myself = _myself; 
        stakeholderChanges[stakeholderCount].active = true; 
        stakeholderChanges[stakeholderCount].maker = msg.sender;
        */

        stakeholderAddrs[_stake].id = stakeholderCount;
        stakeholderAddrs[_stake].name = _name; 
        stakeholderAddrs[_stake].timestamp = _timestamp; 
        stakeholderAddrs[_stake].description = _description;
        stakeholderAddrs[_stake].myself = _stake; 
        stakeholderAddrs[_stake].active = true; 
        stakeholderAddrs[_stake].maker = msg.sender; // admin ?
        emit updateEvent(); // trigger event 
    }

    function addStakeholderProduct(uint _id, address _stake) public { // address of the food_pagonis contract
     	//require(exists(msg.sender)==true or msg.sender == adminaddr); // if valid user
        //require(productsCount >= _id) // the product exists
        stakeholderAddrs[_stake].involvedproducts.push(_id);
        emit updateEvent(); // trigger event 
    }
    
  
    function changeStatus (bool _active, address _stake) public {
	//we will keep it simple, but we can assume that disable can be requested by admin or myself, yet enable only by admin.
        require(exists(_stake)==true);  // if exsits
        //require(msg.sender == adminaddr); // only if admin
        stakeholderAddrs[_stake].active = _active;
        emit changeStatusEvent(); // trigger event 
    }

  // get the products managed by the stakeholder
    function getStakeholdersProduct (address _stake) public view returns (uint [] memory)  {
        //require(exists(_stake)==true); // exists
        //require(exists(msg.sender)==true or msg.sender == adminaddr); // if valid user
        return stakeholderAddrs[_stake].involvedproducts;
    }

    function getStakeholder (address _stake) public view returns (Stakeholder memory)  {
        //require(exists(_stake)==true);  // if exsits
        //require(exists(msg.sender)==true or msg.sender == adminaddr); // if valid user
        return stakeholderAddrs[_stake];
    }
    
    // returns global number of status, needed to iterate the mapping and to know info.
    function getNumberOfStakeholders () public view returns (uint){    
        //tx.origin
        return stakeholderCount;
    }

    function exists(address _stake) public view returns (bool){
        if(stakeholderAddrs[_stake].active == true){
            return true;
        }
        return false;
    }

    function updateNumberOfProducts (address addr) public {
        Food_pagonis f = Food_pagonis(addr);
        productsCount =f.getNumberOfProducts();

    }

    function updateNumberOfProcesses (address addr) public {
        
        Processes p = Processes(addr);
        processesCount=p.getNumberOfProcesses();     
    }
}
