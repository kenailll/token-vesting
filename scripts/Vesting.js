const { ethers } = require('hardhat');
const fs = require("fs");

const deployfunc = require("./isDeployed.js");

platform = 'hardhat'
network = 'mainnet'

let accounts = []

async function main(){
    accounts = await ethers.getSigners();
    
    //startTime in seconds
    // const startTime = 1642269600 //GMT
    const startTime = 1642244400 //Local time

    const week = 604800
    const month = week * 4 
    const year = month * 12

    //Token
    const Token = await deployfunc.autoDeploy('TCVNtoken', 'TCVNtoken', platform, network);

    //Vesting
    const Vesting = await deployfunc.autoDeploy(
        'ERC20Vesting', 
        'ERC20Vesting', 
        platform,
        network,
        Token.address,
        startTime
    );
    // Team: TGE 0%, 1 year cliff, linear vesting over 3 years
    await Vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('1700000000'), year, year * 3, 0, week);

    // Public Disitribution: TGE 100%
    // await Vesting.addBeneficiary(accounts[1].address, ethers.utils.parseEther('5000000000'), 0, 0, 0, 0);

    // // Community Growth: TGE 10%, linear vesting over 3 years 
    // await Vesting.addBeneficiary(accounts[2].address, ethers.utils.parseEther('1500000000'), 0, year * 3, ethers.utils.parseEther('150000000'), week);

    // // Foundation Reserve: TGE 0%, 1 year cliff, linear vesting over 3 years
    // await Vesting.addBeneficiary(accounts[3].address, ethers.utils.parseEther('1000000000'), year, year * 3, 0, week);

    // // Liquidity: TGE 100%
    // await Vesting.addBeneficiary(accounts[4].address, ethers.utils.parseEther('500000000'), 0, 0, 0, 0);

    // // Advisor: TGE 0%, 6 months cliff, linear vesting over 2 years
    // await Vesting.addBeneficiary(accounts[5].address, ethers.utils.parseEther('300000000'), month * 6, year * 2, 0, week);

    // console.log('tokenListingDate:', (await Vesting.tokenListingDate()))
    // console.log('Team:', (await Vesting.vestedAmount(accounts[0].address)))
    // console.log('Public Disitribution:', (await Vesting.vestedAmount(accounts[1].address)))
    // console.log('Community Growth:', (await Vesting.vestedAmount(accounts[2].address)))
    // console.log('Foundation Reserve:', (await Vesting.vestedAmount(accounts[3].address)))
    // console.log('Liquidity:', (await Vesting.vestedAmount(accounts[4].address)))
    // console.log('Advisor:', (await Vesting.vestedAmount(accounts[5 ].address)))
}
main()
	.then(() => process.exit(0))
	.catch((error) => {
	console.error(error);
	process.exit(1);
});
