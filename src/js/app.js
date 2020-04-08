App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Food_pagonis.json", function(food_pagonis) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Food_pagonis = TruffleContract(food_pagonis);
      // Connect provider to interact with contract
      App.contracts.Food_pagonis.setProvider(App.web3Provider);

      App.listenForEvents();

      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.Food_pagonis.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.reqEvent({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new vote is recorded
        App.render();
      });
    });
  },

  render: function() {
   var electionInstance;
    var loader = $("#loader");
    var content = $("#content");

    loader.show();
    content.hide();

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });
    var candidateId = $('#candidatesSelect').val();

    // Load contract data
    App.contracts.Food_pagonis.deployed().then(function(instance) {
      pagonisInstance = instance;
      return pagonisInstance.productsCount();
    }).then(function(productsCount) {
      var candidatesResults = $("#candidatesResults");
      candidatesResults.empty();

      //var candidatesSelect = $('#candidatesSelect');
      //candidatesSelect.empty();

       if (candidateId == "ALL"){

          for (var i = 1; i <= productsCount; i++) {
            pagonisInstance.products(i).then(function(product) {
              var id = product[0];
              var name = product[1];
              var quantity = product[2];
              var desc = product[3];
              var globalid = product[8];
              var addr = product[7];
              var hash = product[9];
              var ipfslink = "https://ipfs.io/ipfs/"+hash;

              // Render candidate Result
              var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quantity + "</td><td>" + desc + "</td><td>" + globalid + "</td><td>" + addr + "</td><td> '<a href=" + ipfslink + ">"+hash+"</a>' </td></tr>"
              candidatesResults.append(candidateTemplate);

              // Render candidate ballot option
              //var candidateOption = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quantity + "</td><td>" + desc + "</td><td>" + globalid + "</td><td>" + addr + "</td><td>" + hash + "</td></tr>"
              //candidatesSelect.append(candidateOption);
            });
          }
      }else {
          pagonisInstance.products(candidateId).then(function(product) {
              var id = product[0];
              var name = product[1];
              var quantity = product[2];
              var desc = product[3];
              var globalid = product[8];
              var addr = product[7];
              var hash = product[9];
              var ipfslink = "https://ipfs.io/ipfs/"+hash;

              // Render  result if no error
              if (id == 0 || id == null){
                var candidateTemplate = "<tr><th>" + "ID does not exist" + "</tr>";
                candidatesResults.append(candidateTemplate);
              }else{
              var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quantity + "</td><td>" + desc + "</td><td>" + globalid + "</td><td>" + addr + "</td><td> '<a href=" + ipfslink + ">"+hash+"</a>' </td></tr>"                           
              candidatesResults.append(candidateTemplate);
              }
              // Render candidate ballot option
              //var candidateOption = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quantity + "</td><td>" + desc + "</td><td>" + globalid + "</td><td>" + addr + "</td><td>" + hash + "</td></tr>"
              //candidatesSelect.append(candidateOption);
            });

      }
      //return pagonisInstance.voters(App.account);
    }).then(function(show) {
      // show always checker
      loader.hide();
      content.show();
    }).catch(function(error) {
      console.warn(error);
    });

  },

  // castVote: function() {
  //   var candidateId = $('#candidatesSelect').val();
  //   App.contracts.Food_pagonis.deployed().then(function(instance) {
  //     return instance.products(candidateId).then(function(result);
  //   }).then(function(result) {
  //     // Wait for votes to update
  //     $("#content").hide();
  //     $("#loader").show();
  //   }).catch(function(err) {
  //     console.error(err);
  //   });
  // }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
