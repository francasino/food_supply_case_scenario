//var Migrations = artifacts.require("./Migrations.sol");
var Food_pagonis = artifacts.require("./Food_pagonis.sol");
var Processes = artifacts.require("./Processes.sol");
var Stakeholders = artifacts.require("./Stakeholders.sol");
//represents contract abstraction

module.exports = function(deployer) {
 // deployer.deploy(Migrations);
  deployer.deploy(Food_pagonis);
  deployer.deploy(Processes);
  deployer.deploy(Stakeholders);
};
