var solc = require('solc');
var fs = require('fs');
var Pudding = require('ether-pudding');
var SolidityFunction = require('web3/lib/web3/function');
var _ = require('lodash');
web3 = require('web3');
var abi = require('ethereumjs-abi');




// returns the encoded binary (as a Buffer) data to be sent
var encodedBuffer = abi.rawEncode(['uint','uint','uint','uint','uint','uint'], [10000, 30, 20000, 40, 0, 0]);

// returns the decoded array of arguments
//var decoded = abi.rawDecode([ "address" ], data)

console.log(encodedBuffer.toString('hex'));