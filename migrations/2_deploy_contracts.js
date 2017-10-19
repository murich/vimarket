var Vitoken = artifacts.require("./Vitoken.sol");
var VitokenCrowdsale = artifacts.require("./VitokenCrowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(
      VitokenCrowdsale,
      1507989696,
      1510407935,
      '0x08d6a44f78e2b851bc999e2e0de48aba1d0ed89a',
      '0xd7e321b8e8cc014abe2bbb2857bec4bec03973ee'
  ).then(function(){
    console.log('Petlyat sidet kopat patet');
  });
};
