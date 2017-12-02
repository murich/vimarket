var WizePresale = artifacts.require("../contracts/WizePresale.sol");

module.exports = function(deployer) {
  deployer.deploy(
      WizePresale,
      '0x02EAAaaBdD5dd1E59ffD1ee2597f093dA580a2A4',
      '0x05Cf02f896E1D8Bc490a84e8236F49eDB2D1056f'
  ).then(function(){
    console.log('Petlyat sidet kopat patet');
  });
};
