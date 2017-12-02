var abi = require('ethereumjs-abi');
/*
 uint256 _startsAt,
 address _wallet,
 address _tokenContract,
 address _pricingStrategy
 */
var contractParams = {
        kovan: {
            crowdsale: [
                1511931600,
                '0x05cf02f896e1d8bc490a84e8236f49edb2d1056f',
                '0x029a9f2bbd2bd850a8788632ad5b0d01f536d870',
                '0x5992e760023404acf1d918f2b9a63d9dad9c10c7 '
            ]
        },
        mainnet: {
            crowdsale: [
                1511931600,
                '0x14010814F3d6fBDe4970E4f7B36CdfFB23B5FA4A',
                '0x000621424c60951cb69e9d75d64b79813846d498',
                '0xf94c956376B244eB92D996a845027352e08EcD90'
            ]
        }
};
var encoded = abi.rawEncode(
    [
            "uint256",
            "address",
            "address",
            "address"
    ],
    contractParams.kovan.crowdsale
);
console.log(encoded.toString('hex'));


/*
Kovan normal:
 000000000000000000000000000000000000000000000000000000005a1e3ed000000000000000000000000005cf02f896e1d8bc490a84e8236f49edb2d1056f000000000000000000000000029a9f2bbd2bd850a8788632ad5b0d01f536d8700000000000000000000000005992e760023404acf1d918f2b9a63d9dad9c10c7

Mainnet normal:

 000000000000000000000000000000000000000000000000000000005a1e3ed000000000000000000000000005cf02f896e1d8bc490a84e8236f49edb2d1056f000000000000000000000000029a9f2bbd2bd850a8788632ad5b0d01f536d8700000000000000000000000005992e760023404acf1d918f2b9a63d9dad9c10c7
*/

// Остановился на том что нужно сгенерить параметры для нового контракта и задеплоить оба контракта