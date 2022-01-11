const { expect } = require("chai");
const { ethers, network } = require("hardhat");
const { time } = require('@openzeppelin/test-helpers');
const { BigNumber } = require("ethers");
const { solidityKeccak256 } = require("ethers/lib/utils");
const balance = require("@openzeppelin/test-helpers/src/balance");

let accounts = []

function deadline() {
    return Math.floor(new Date().getTime() / 1000) + 1800*100;
}

describe("InitTest", async function () {
    beforeEach(async function() {
        accounts = await ethers.getSigners();
        const initial = await getInitialContracts();

        token = initial.TCVNtoken;
        vesting = initial.Vesting;

        //change week here
        //test tuần lẻ, ví dụ lần rút trước là giữa tuần (vd: 1,5) thì chỉ cần đợi thêm nửa tuần nữa (0,5) là có thể rút tiếp
        week = 130.6
        extend_week = 14.5
    });

    it("teamVesting test", async function () {
        //TGE 0%, 1 year cliff, linear vesting over 3 years
        await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('1700000000'), 29030400, 87091200, 0, 604800);

        //rut khi chua cliff
        await vesting.releaseMyTokens()
        admin_bl = await token.balanceOf(accounts[0].address)
        if(admin_bl != 0){
            console.log('ERROR HERE: MUST BE IN CLIFF TIME')
        }

        //cliff 1 nam
        await ethers.provider.send("evm_increaseTime", [29030400]);
        await ethers.provider.send('evm_mine');

        await vesting.releaseMyTokens()
        admin_bl = await token.balanceOf(accounts[0].address)
        if(admin_bl != 0){
            console.log('ERROR HERE: BALANCE MUST BE 0')
        }

        //vesting by week (max 144 weeks)
        console.log(`\nweek: ${week}/144`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.releaseMyTokens()
        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 144){
            console.log(`admin balance must be ${11805555.555555556 *  Math.floor(week)}:`, admin_bl/1e18 == (11805555.555555556 * Math.floor(week)))
            if(!(admin_bl/1e18 == (11805555.555555556 * Math.floor(week)))){
                console.log('expect balance:', 11805555.555555556 * Math.floor(week))
                console.log('admin balance:', admin_bl/1e18)
            }
        } else {
            temp = admin_bl/1e18 == 1700000000
            console.log('admin balance must be 1,700,000,000:', temp)
            if(!temp){
                console.log('admin balance:', admin_bl/1e18)
            }

            //vesting end check
            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)

            if(admin_bl/1e18 != 1700000000){
                console.log('ERROR HERE: VESTING MUST BE ENDED')
            }
        }

        if(week < 144 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/144`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)

            if(Math.floor(week + extend_week) < 144){
                console.log(`admin balance must be ${11805555.555555556 *  Math.floor(week + extend_week)}:`, admin_bl/1e18 == (11805555.555555556 * Math.floor(week + extend_week)))
                
                if(!(admin_bl/1e18 == (11805555.555555556 * Math.floor(week + extend_week)))){
                    console.log('expect balance:', 11805555.555555556 * Math.floor(week + extend_week))
                    console.log('admin balance:', admin_bl/1e18)
                }
            } else {
                console.log('admin balance must be 1,700,000,000:', admin_bl/1e18 == 1700000000)
                
                if(!(admin_bl/1e18 == 1700000000)){
                    console.log('expect balance:', 1700000000)
                    console.log('admin balance:', admin_bl/1e18)
                }
            }
        }
    });

    it("publicVesting test", async function () {
        //TGE 100%
        await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('5000000000'), 0, 0, 0, 0);

        //tge 100%
        await vesting.releaseMyTokens()
        tge = (await token.balanceOf(accounts[0].address)) / 1e18
            
        console.log('admin balance must be 5000000000:', tge == 5000000000)
        if(tge != 5000000000){
            console.log('ERROR HERE: BALANCE MUST BE 5000000000 AFTER TGE')
            console.log('expect balance:', 5000000000)
            console.log('admin balance:', tge/1e18)
        }

        // try to claim again
        await ethers.provider.send("evm_increaseTime", [604800 * 1]);
        await ethers.provider.send('evm_mine');

        await vesting.releaseMyTokens()
        admin_bl = (await token.balanceOf(accounts[0].address)) / 1e18

        console.log('admin balance must be 5000000000:', admin_bl == 5000000000)
        if(admin_bl != 5000000000){
            console.log('ERROR HERE: BALANCE MUST BE 5000000000')
            console.log('expect balance:', 5000000000)
            console.log('admin balance:', admin_bl/1e18)
        }

        
    });

    it("communityVesting test", async function () {
        //TGE 10%, linear vesting over 3 years 
        await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('1500000000'), 0, 87091200, ethers.utils.parseEther('150000000'), 604800);

        //tge 10%
        await vesting.releaseMyTokens()
        tge = (await token.balanceOf(accounts[0].address)) / 1e18
        if(tge == 150000000){
            console.log('admin balance must be 150000000:', tge == 150000000)
        } else {
            console.log('ERROR HERE: BALANCE MUST BE 150000000 AFTER TGE')
        }

        //vesting by week (max 144 weeks)
        console.log(`\nweek: ${week}/144`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.releaseMyTokens()
        
        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 144){
            console.log(`admin balance must be ${9375000 * Math.floor(week) + tge}:`, admin_bl/1e18 == (9375000 * Math.floor(week) + tge))
            if(!(admin_bl/1e18 == (9375000 * Math.floor(week) + tge))){
                console.log('expect balance:', 9375000 * Math.floor(week) + tge)
                console.log('admin balance:', admin_bl/1e18)
            }
        } else {
            temp = admin_bl/1e18 == 1500000000
            console.log('admin balance must be 1,500,000,000:', temp)
            if(!temp){
                console.log('admin balance:', admin_bl/1e18)
            }

            //vesting end check
            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)

            if(admin_bl/1e18 != 1500000000){
                console.log('ERROR HERE: VESTING MUST BE ENDED')
            }
        }

        if(week < 144 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/144`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)

            if(Math.floor(week + extend_week) < 144){
                console.log(`admin balance must be ${9375000 * Math.floor(week + extend_week) + tge}:`, admin_bl/1e18 == (9375000 * Math.floor(week + extend_week) + tge))
                
                if(!(admin_bl/1e18 == (9375000 * Math.floor(week + extend_week) + tge))){
                    console.log('expect balance:', 9375000 * Math.floor(week + extend_week) + tge)
                    console.log('admin balance:', admin_bl/1e18)
                }
            } else {
                console.log('admin balance must be 1,500,000,000:', admin_bl/1e18 == 1500000000)
                                
                if(!(admin_bl/1e18 == 1500000000)){
                    console.log('expect balance:', 1500000000)
                    console.log('admin balance:', admin_bl/1e18)
                }
            }
        }
    });

    it("foundationVesting test", async function () {
        //TGE 0%, 1 year cliff, linear vesting over 3 years
        await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('1000000000'), 29030400, 87091200, 0, 604800);

        //rut khi chua cliff
        await vesting.releaseMyTokens()
        admin_bl = await token.balanceOf(accounts[0].address)
        if(admin_bl != 0){
            console.log('ERROR HERE: MUST BE IN CLIFF TIME')
        }

        //cliff 1 nam
        await ethers.provider.send("evm_increaseTime", [29030400]);
        await ethers.provider.send('evm_mine');

        await vesting.releaseMyTokens()
        admin_bl = await token.balanceOf(accounts[0].address)
        if(admin_bl != 0){
            console.log('ERROR HERE: BALANCE MUST BE 0')
        }

        //vesting by week (max 144 weeks)
        console.log(`\nweek: ${week}/144`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.releaseMyTokens()

        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 144){
            console.log(`admin balance must be ${6944444.444444444 * Math.floor(week)}:`, admin_bl/1e18 == (6944444.444444444 * Math.floor(week)))
            if(!(admin_bl/1e18 == (6944444.444444444 * Math.floor(week)))){
                console.log('expect balance:', 6944444.444444444 * Math.floor(week))
                console.log('admin balance:', admin_bl/1e18)
            }
        } else {
            temp = admin_bl/1e18 == 1000000000
            console.log('admin balance must be 1,000,000,000:', temp)
            if(!temp){
                console.log('admin balance:', admin_bl/1e18)
            }

            //vesting end check
            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)

            if(admin_bl/1e18 != 1000000000){
                console.log('ERROR HERE: VESTING MUST BE ENDED')
            }
        }

        if(week < 144 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/144`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)
            
            if(Math.floor(week + extend_week) < 144){
                console.log(`admin balance must be ${6944444.444444444 * Math.floor(week + extend_week)}:`, admin_bl/1e18 == (6944444.444444444 * Math.floor(week + extend_week)))
            
                if(!(admin_bl/1e18 == (6944444.444444444 * Math.floor(week + extend_week)))){
                    console.log('expect balance:', 6944444.444444444 * Math.floor(week + extend_week))
                    console.log('admin balance:', admin_bl/1e18)
                }
            } else {
                console.log('admin balance must be 1,000,000,000:', admin_bl/1e18 == 1000000000)
                
                if(!(admin_bl/1e18 == 1000000000)){
                    console.log('expect balance:', 1000000000)
                    console.log('admin balance:', admin_bl/1e18)
                }
            }
        }
    });

    it("liquidityVesting test", async function () {
        //TGE 100%
        await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('500000000'), 0, 0, 0, 0);
        
        //tge 100%
        await vesting.releaseMyTokens()
        tge = (await token.balanceOf(accounts[0].address)) / 1e18
            
        console.log('admin balance must be 500,000,000:', tge == 500000000)
        if(tge != 500000000){
            console.log('ERROR HERE: BALANCE MUST BE 500,000,000 AFTER TGE')
            console.log('expect balance:', 500000000)
            console.log('admin balance:', tge/1e18)
        }

        // try to claim again
        await ethers.provider.send("evm_increaseTime", [604800 * 1]);
        await ethers.provider.send('evm_mine');

        await vesting.releaseMyTokens()
        admin_bl = (await token.balanceOf(accounts[0].address)) / 1e18

        console.log('admin balance must be 500,000,000:', admin_bl == 500000000)
        if(admin_bl != 500000000){
            console.log('ERROR HERE: BALANCE MUST BE 500,000,000')
            console.log('expect balance:', 500000000)
            console.log('admin balance:', admin_bl/1e18)
        }

        
    });

    it("advisorVesting test", async function () {
        //TGE 0%, 6 months cliff, linear vesting over 2 years
        await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('300000000'), 14415200, 58060800, 0, 604800);

        //rut khi chua cliff
        await vesting.releaseMyTokens()
        admin_bl = await token.balanceOf(accounts[0].address)
        if(admin_bl != 0){
            console.log('ERROR HERE: MUST BE IN CLIFF TIME')
        }

        //cliff 6 thang
        await ethers.provider.send("evm_increaseTime", [14415200]);
        await ethers.provider.send('evm_mine');

        await vesting.releaseMyTokens()
        admin_bl = await token.balanceOf(accounts[0].address)
        if(admin_bl != 0){
            console.log('ERROR HERE: BALANCE MUST BE 0')
        }

        //vesting by week (max 96 weeks)
        console.log(`\nweek: ${week}/96`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.releaseMyTokens()
        
        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 96){
            console.log(`admin balance must be ${3125000 * Math.floor(week)}:`, admin_bl/1e18 == (3125000 * Math.floor(week)))
            if(!(admin_bl/1e18 == (3125000 * Math.floor(week)))){
                console.log('expect balance:', 3125000 * Math.floor(week))
                console.log('admin balance:', admin_bl/1e18)
            }
        } else {
            temp = admin_bl/1e18 == 300000000
            console.log('admin balance must be 300,000,000:', temp)
            if(!temp){
                console.log('admin balance:', admin_bl/1e18)
            }

            //vesting end check
            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)

            if(admin_bl/1e18 != 300000000){
                console.log('ERROR HERE: VESTING MUST BE ENDED')
                console.log(admin_bl)
            }
        }

        if(week < 96 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/96`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.releaseMyTokens()
            admin_bl = await token.balanceOf(accounts[0].address)
            
            if(Math.floor(week + extend_week) < 144){
                console.log(`admin balance must be ${3125000 * Math.floor(week + extend_week)}:`, admin_bl/1e18 == (3125000 * Math.floor(week + extend_week)))
                
                if(!(admin_bl/1e18 == (3125000 * Math.floor(week + extend_week)))){
                    console.log('expect balance:', 3125000 * Math.floor(week + extend_week))
                    console.log('admin balance:', admin_bl/1e18)
                }
            } else {
                console.log('admin balance must be 300,000,000:', admin_bl/1e18 == 300000000)

                if(!(admin_bl/1e18 == 300000000)){
                    console.log('expect balance:', 300000000)
                    console.log('admin balance:', admin_bl/1e18)
                }
            }
        }
    });
});

async function getInitialContracts() {
    const Mock = await ethers.getContractFactory("TCVNtoken");
    const TCVNtoken = await Mock.deploy(); 

    const _Vesting = await ethers.getContractFactory("ERC20Vesting");
    const Vesting = await _Vesting.deploy(TCVNtoken.address, 0);
    
    await TCVNtoken.transfer(Vesting.address, ethers.utils.parseEther('10000000000'));
        
    console.log('Deploy done');
    return { TCVNtoken, Vesting }
}

// Team: TGE 0%, 1 year cliff, linear vesting over 3 years
// await Vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('1700000000'), 29030400, 87091200, 0, 604800);

// Public Disitribution: TGE 100%
// await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('5000000000'), 0, 0, 0, 0);

// Community Growth: TGE 10%, linear vesting over 3 years 
// await Vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('1500000000'), 0, 87091200, ethers.utils.parseEther('150000000'), 604800);

// Foundation Reserve: TGE 0%, 1 year cliff, linear vesting over 3 years
// await Vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('1000000000'), 29030400, 87091200, 0, 604800);

// Liquidity: TGE 100%
// await vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('500000000'), 0, 0, 0, 0);

// Advisor: TGE 0%, 6 months cliff, linear vesting over 2 years
// await Vesting.addBeneficiary(accounts[0].address, ethers.utils.parseEther('300000000'), 14415200, 58060800, 0, 604800);