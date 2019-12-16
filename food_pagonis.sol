pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./Processes.sol";
import "./Stakeholders.sol";

/* 
COPYRIGHT FRAN CASINO. 2019.
REQUIRE CLAUSES DEACTIVATED, TO BE DEFINED ACCORDING TO EACH SITUATION
SC FOR FOOD SUPLY CHAIN - REAL CASE STUDY PAGONIS DIARY PRODCUTS
SEVERAL STAKEHOLDERS AND PROCESSES ARE CONSIDERED, AND DEFINED IN PARALLELL SCS
*/

contract food_pagonis{

    
    struct Product {
        uint id;
        string name;
        uint quantity;
        string description;  // for QOs or conditions, location, description
        uint numberoftraces;
        uint numberoftemperatures;
	    string test_number; // microbiological test
        uint [] tracesProduct; // the ID of the traces of the product
        uint [] temperaturesProduct;
        address maker; // who  updates
        string globalId; // global id in manufacturing 
        bytes32 hashIPFS; // refernce to manufacturing description, serial number, IMEI
    }
    // key is a uint, later corresponding to the product id
    // what we store (the value) is a Product
    // the information of this mapping is the set of products of the order.
    mapping(uint => Product) private products; // public, so that w can access with a free function 

    struct Trace {
        uint id;
        uint id_product;
        string location;
        string temp_owner; // stakeholder
        uint timestamp;
        address maker; // who  updates
    }

    mapping(uint => Trace) private traces; // public, so that w can access with a free function 
    //store products count
    // since mappings cant be looped and is difficult the have a count like array
    // we need a var to store the coutings  
    // useful also to iterate the mapping 


    struct Temperature {  // we use celsious
        uint id;
        uint id_product;
        uint celsius; // the number
        uint timestamp;
        address maker; // who  updates
    }

    mapping(uint => Temperature) private temperatures; // public, so that w can access with a free function 


    //uint private temperaturesCount;
    uint private productsCount;
    uint private tracesCount;
    uint private temperaturesCount;

    // smart comm to smart comm statistics 
    uint private globalnumberstakeholders;
    uint private globalnumberProcesses;

    //PARTICIPANTS SHOULD BE FROM THE LIST OF STAKEHOLDERS
    //address constant public stake5 = 0xE0F5206bbd039E7B0592D8918820024E2a743445;
    //address constant public stake4 = 0x50e00dE2c5cC4e456Cf234FCb1A0eFA367ED016E;
    //address constant public stake3 = 0x1533234Bd32f59909E1D471CF0C9BC80C92c97d2;
    //address constant public stake2 = 0x395BE1C1Eb316f82781462C4C028893e51d8b2a5;
    address constant public stakeholder = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9; // example of stakeholder
    address constant public adminaddr = 0xE0F5206bbd039e7b0592d8918820024E2A743222; // admin, current

    bool private  triggered;
    bool private  delivery;
    bool private  received;


    //Processes public p;
    //Stakeholders public s;

    // event, voted event. this will trigger when we want
    //  when a vote is cast for example, in the vote function. 
    event triggeredEvent (  // triggers new accepted order 
    );

    event updateEvent ( // triggers product status change
    );


    constructor () public { // constructor, creates order. we map starting from id=1,  hardcoded values of all
        addProduct("Milk",200, "AAAa, from X","00011A","ADDeFFtt45045594xxE3948"); //
        addTrace(1,"some coordinates", "name or address of actual owner",1573564413); // locations of the product. to be updated by corresponding stakheolder.
        //addComponent();
        triggered=false;
        delivery=false;
        received=false;
    }


    //PRODUCT OPERATIONS******************************************
    // enables product creation
    // get product
    // get total for externally looping the mapping
    // update others.

    // add product to mapping. private because we dont want to be accesible or add products afterwards to our mapping. We only want
    // our contract to be able to do that, from constructor
    // otherwise the conditions of the accepted contract could change
    function addProduct (string memory _name, uint _quantity, string memory _description, string memory _globalID, bytes32 _hashIpfs) private {
        //require(msg.sender==stakholder);
        //require(food_pagonis.checkStakeholder(address addr, address stake)==true); // if valid stakeholder

        productsCount ++; // inc count at the begining. represents ID also. 
        products[productsCount].id = productsCount; 
        products[productsCount].name = _name;
        products[productsCount].quantity = _quantity;
        products[productsCount].description = _description;
        products[productsCount].numberoftraces = 0;
        products[productsCount].numberoftemperatures = 0; 
        products[productsCount].maker = msg.sender;
        products[productsCount].globalId = _globalID;
        products[productsCount].hashIPFS = _hashIpfs;
        // reference the mapping with the key (that is the count). We assign the value to 
        // the mapping, the count will be the ID.  
    }

    

     // only specific stakeholders, can be changed
    function UpdateProductDescription (uint _productId, string memory _description) public { 
        //require(food_pagonis.checkStakeholder(address addr, address stake)==true); // if valid stakeholder
        require(_productId > 0 && _productId <= productsCount); 

        products[_productId].description = _description;  // update conditions
        emit updateEvent(); // trigger event 
    }

    function addTestProduct (uint _productId, string memory _test_number) public { 
        require(_productId > 0 && _productId <= productsCount); 

        products[_productId].test_number = _test_number;  // update conditions
        emit updateEvent(); // trigger event 
    }
     

    // returns the number of products, needed to iterate the mapping and to know info about the order.
    function getNumberOfProducts () public view returns (uint){
        return productsCount;
    }
    // function to check the contents of the contract, the customer will check it and later will trigger if correct
    // only customer can check it 
    // customer will loop outside for this, getting the number of products before with getNumberOfProducts
    function getProduct (uint _productId) public view returns (Product memory) {
        require(_productId > 0 && _productId <= productsCount); 

        return products[_productId];
    }

      function getProductGlobalID (uint _productId) public view returns (string memory) {
        require(_productId > 0 && _productId <= productsCount); 

        return products[_productId].globalId;
    }
 
    function getProductTest (uint _productId) public view returns (string memory) {
        require(_productId > 0 && _productId <= productsCount); 

        return products[_productId].test_number;
    }


      function getProductHistoric (uint _productId) public view returns (bytes32) {
        require(_productId > 0 && _productId <= productsCount); 

        return products[_productId].hashIPFS;
    }
    //TRACES and temperatures OPERATIONS********************************************
    // enables add trace to a product
    // enables total number of traces to loop
    // get a trace
    // gets the total number of traces of a product. for statistical purposes
    // get the list of traces of a product, that can be consulter afterwards using get a trace
    // the same for temperatures

    function addTrace (uint _productId, string memory _location, string memory _temp_owner, uint _timestamp) public {  // acts as update location
        require(_productId > 0 && _productId <= productsCount); // check if product exists
        
        tracesCount ++; // inc count at the begining. represents ID also. 
        traces[tracesCount] = Trace(tracesCount, _productId, _location,_temp_owner,_timestamp,msg.sender);
        products[_productId].tracesProduct.push(tracesCount); // we store the trace reference in the corresponding product
        products[_productId].numberoftraces++;
         //this will give us the set of ID traces about our productid
        emit updateEvent();
    }


    function addTemperature (uint _productId, uint _celsius, string memory _temp_owner, uint _timestamp) public {  // acts as update location
        require(_productId > 0 && _productId <= productsCount); // check if product exists
        
        temperaturesCount ++; // inc count at the begining. represents ID also. 
        temperatures[temperaturesCount] = Temperature(temperaturesCount, _productId, _celsius,_timestamp,msg.sender);
        products[_productId].temperaturesProduct.push(temperaturesCount); // we store the trace reference in the corresponding product
        products[_productId].numberoftemperatures++;
        // this will give us the set of ID temperatures about our productid
         //this will give us the set of ID traces about our productid
        emit updateEvent();
    }
   
    // returns the number of traced locations
    //useful for generic statistical purposes
    function getNumberOfTraces () public view returns (uint) {
        
        return tracesCount;
    }

    function getNumberOfTemperatures () public view returns (uint) {
        return temperaturesCount;
    }


    // get a trace
    function getTrace (uint _traceId) public view returns (Trace memory)  {
        require(_traceId > 0 && _traceId <= tracesCount); 

        return traces[_traceId];
    }

    function getTemperature (uint _temperatureId) public view returns (Temperature memory)  {
        require(_temperatureId > 0 && _temperatureId <= temperaturesCount); 

        return temperatures[_temperatureId];
    }


    // returns the number of traced locations for specific product
    function getNumberOfTracesProduct (uint _productId) public view returns (uint) {
        require(_productId > 0 && _productId <= productsCount); // check if product exists
        
        return products[_productId].numberoftraces;
    }

	// returns the number of registered temperatures for specific product
    function getNumberOfTemperaturesProduct (uint _productId) public view returns (uint) {
        require(_productId > 0 && _productId <= productsCount); // check if product exists
        
        return products[_productId].numberoftemperatures;
    }


    // get the array of traces of a product, later we can loop them using getTrace to obtain the data
    function getTracesProduct (uint _productId) public view returns (uint [] memory)  {
        require(_productId > 0 && _productId <= productsCount); // check if product exists

        return products[_productId].tracesProduct;
    }

    // get the array of temperatures of a product, later we can loop them using getTrace to obtain the data
    function getTemperaturesProduct (uint _productId) public view returns (uint [] memory)  {
        require(_productId > 0 && _productId <= productsCount); // check if product exists

        return products[_productId].temperaturesProduct;
    }


    //EVENT AND SC OPERATIONS********************************************************
    //  computes hash of transaction
    // several event triggers


    function retrieveHashProduct (uint _productId) public view returns (bytes32){ 
        //computehash according to unique characteristics
        // hash has to identify a unique transaction so timestamp and locations and products should be used.
        // this example hashes a transaction as a whole.
        return keccak256(abi.encodePacked(block.number,msg.data, products[_productId].id, products[_productId].name, products[_productId].quantity, products[_productId].description, products[_productId].numberoftraces, products[_productId].numberoftemperatures, products[_productId].maker));

    }


     //this function triggers the contract
    function triggerContract () public { 
        triggered=true;
        emit triggeredEvent(); // trigger event 

    }

        // returns global number of stories, needed to iterate the mapping and to know info.
    // smart to smart comm
    function updateNumberOfProcesses (address addr) public {
        
        Processes p = Processes(addr);
        globalnumberProcesses=p.getNumberOfProcesses();    
    }
    
    // returns global number of status, needed to iterate the mapping and to know info.
    // smart to smart comm
    function updateNumberOfStakeholders (address addr) public {
        
        Stakeholders s = Stakeholders(addr);
        globalnumberstakeholders=s.getNumberOfStakeholders();
        
    }

    function checkStakeholder (address addr, address stake) public view returns (bool){
        Stakeholders s = Stakeholders(addr);
        bool ex=s.exists(stake);
        return ex;
    }


}
