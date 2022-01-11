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
        week = 96.5
        extend_week = 1.5
    });

    it("TGE test", async function () {
        await vesting.tgePublic()
        await vesting.tgeCommunity()
        await vesting.tgeLiquitdity()

        //amount test
        admin_bl = await token.balanceOf(accounts[0].address)
        console.log('admin balance must be 5,650,000,000:', admin_bl == 5650000000*1e18)

        //require test
        try {
            await vesting.tgePublic()
        } catch (error) {
            console.log('TGE_PUBLIC must be 0:', (await vesting.TGE_PUBLIC()) == 0)
        }

        try {
            await vesting.tgeCommunity()
        } catch (error) {
            console.log('TGE_COMMUNITY must be 0:', (await vesting.TGE_COMMUNITY()) == 0)
        }

        try {
            await vesting.tgeLiquitdity()
        } catch (error) {
            console.log('TGE_LIQUIDITY must be 0:', (await vesting.TGE_LIQUIDITY()) == 0)
        }
    });

    it("teamVesting test", async function () {
        try {
            await vesting.teamVesting()
        } catch (error) {
            console.log('cliff time')
        }
        //cliff 1 nam
        await ethers.provider.send("evm_increaseTime", [29030400]);
        await ethers.provider.send('evm_mine');

        await vesting.teamVesting()
        admin_bl = await token.balanceOf(accounts[0].address)
        console.log('admin balance must be 0:', admin_bl == 0)

        //vesting by week (max 145 weeks)
        console.log(`\nweek: ${week}/145`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.teamVesting()
        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 145){
            console.log(`admin balance must be ${11805555.555555556 * week}:`, admin_bl/1e18 == (11805555.555555556 * Math.floor(week)))
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

            if((await vesting.TEAM_REMAINING()) == 0){
                try {
                    await vesting.teamVesting()
                    console.log('ERROR HERE: VESTING MUST BE ENDED')
                } catch (error) {
                    console.log('VESTING END')
                }
            } else {
                console.log("TEAM_REMAINING:", await vesting.TEAM_REMAINING())
                console.log('ERROR HERE: TEAM_REMAINING must be 0')
            }  
        }

        if(week < 145 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/145`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.teamVesting()
            admin_bl = await token.balanceOf(accounts[0].address)

            console.log(`admin balance must be ${11805555.555555556 * (week + extend_week)}:`, admin_bl/1e18 == (11805555.555555556 * Math.floor(week + extend_week)))
            if(!(admin_bl/1e18 == (11805555.555555556 * Math.floor(week + extend_week)))){
                console.log('expect balance:', 11805555.555555556 * Math.floor(week + extend_week))
                console.log('admin balance:', admin_bl/1e18)
            }
        }

    });

    it("communityVesting test", async function () {
        //vesting by week (max 145 weeks)
        console.log(`\nweek: ${week}/145`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.communityVesting()
        
        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 145){
            console.log(`admin balance must be ${9375000 * week}:`, admin_bl/1e18 == (9375000 * Math.floor(week)))
            if(!(admin_bl/1e18 == (9375000 * Math.floor(week)))){
                console.log('expect balance:', 9375000 * Math.floor(week))
                console.log('admin balance:', admin_bl/1e18)
            }
        } else {
            temp = admin_bl/1e18 == 1350000000
            console.log('admin balance must be 1,350,000,000:', temp)
            if(!temp){
                console.log('admin balance:', admin_bl/1e18)
            }

            if((await vesting.COMMUNITY_REMAINING()) == 0){
                try {
                    await vesting.communityVesting()
                    console.log('ERROR HERE: VESTING MUST BE ENDED')
                } catch (error) {
                    console.log('VESTING END')
                }
            } else {
                console.log("COMMUNITY_REMAINING:", await vesting.COMMUNITY_REMAINING())
                console.log('ERROR HERE: COMMUNITY_REMAINING must be 0')
            }  
        }

        if(week < 145 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/145`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.communityVesting()
            admin_bl = await token.balanceOf(accounts[0].address)

            console.log(`admin balance must be ${9375000 * (week + extend_week)}:`, admin_bl/1e18 == (9375000 * Math.floor(week + extend_week)))
            if(!(admin_bl/1e18 == (9375000 * Math.floor(week + extend_week)))){
                console.log('expect balance:', 9375000 * Math.floor(week + extend_week))
                console.log('admin balance:', admin_bl/1e18)
            }
        }
    });

    it("foundationVesting test", async function () {
        try {
            await vesting.foundationVesting()
        } catch (error) {
            console.log('cliff time')
        }
        //cliff 1 nam
        await ethers.provider.send("evm_increaseTime", [29030400]);
        await ethers.provider.send('evm_mine');

        await vesting.foundationVesting()
        admin_bl = await token.balanceOf(accounts[0].address)
        console.log('admin balance must be 0:', admin_bl == 0)

        //vesting by week (max 145 weeks)
        console.log(`\nweek: ${week}/145`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.foundationVesting()

        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 145){
            console.log(`admin balance must be ${6944444.444444444 * week}:`, admin_bl/1e18 == (6944444.444444444 * Math.floor(week)))
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

            if((await vesting.FOUNDATION_RESERVE_REMAINING()) == 0){
                try {
                    await vesting.foundationVesting()
                    console.log('ERROR HERE: VESTING MUST BE ENDED')
                } catch (error) {
                    console.log('VESTING END')
                }
            } else {
                console.log("FOUNDATION_RESERVE_REMAINING:", await vesting.FOUNDATION_RESERVE_REMAINING())
                console.log('ERROR HERE: FOUNDATION_RESERVE_REMAINING must be 0')
            }
        }

        if(week < 145 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/145`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.foundationVesting()
            admin_bl = await token.balanceOf(accounts[0].address)

            console.log(`admin balance must be ${6944444.444444444 * (week + extend_week)}:`, admin_bl/1e18 == (6944444.444444444 * Math.floor(week + extend_week)))
            if(!(admin_bl/1e18 == (6944444.444444444 * Math.floor(week + extend_week)))){
                console.log('expect balance:', 6944444.444444444 * Math.floor(week + extend_week))
                console.log('admin balance:', admin_bl/1e18)
            }
        }
    });

    it("advisorVesting test", async function () {
        try {
            await vesting.advisorVesting()
        } catch (error) {
            console.log('cliff time')
        }
        //cliff 6 thang
        await ethers.provider.send("evm_increaseTime", [14515200]);
        await ethers.provider.send('evm_mine');

        await vesting.advisorVesting()
        admin_bl = await token.balanceOf(accounts[0].address)
        console.log('admin balance must be 0:', admin_bl == 0)

        //vesting by week (max 96 weeks)
        console.log(`\nweek: ${week}/96`)

        await ethers.provider.send("evm_increaseTime", [604800 * week]);
        await ethers.provider.send('evm_mine');
        await vesting.advisorVesting()
        
        admin_bl = await token.balanceOf(accounts[0].address)

        if(week < 96){
            console.log(`admin balance must be ${3125000 * week}:`, admin_bl/1e18 == (3125000 * Math.floor(week)))
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

            if((await vesting.ADVISOR_REMAINING()) == 0){
                try {
                    await vesting.advisorVesting()
                    console.log('ERROR HERE: VESTING MUST BE ENDED')
                } catch (error) {
                    console.log('VESTING END')
                }
            } else {
                console.log("ADVISOR_REMAINING:", await vesting.ADVISOR_REMAINING())
                console.log('ERROR HERE: ADVISOR_REMAINING must be 0')
            }
        }

        if(week < 96 && extend_week > 0){
            console.log(`\nweek: ${week+extend_week}/96`)
            await ethers.provider.send("evm_increaseTime", [604800 * extend_week]);
            await ethers.provider.send('evm_mine');

            await vesting.advisorVesting()
            admin_bl = await token.balanceOf(accounts[0].address)

            console.log(`admin balance must be ${3125000 * (week + extend_week)}:`, admin_bl/1e18 == (3125000 * Math.floor(week + extend_week)))
            if(!(admin_bl/1e18 == (3125000 * Math.floor(week + extend_week)))){
                console.log('expect balance:', 3125000 * Math.floor(week + extend_week))
                console.log('admin balance:', admin_bl/1e18)
            }
        }
    });
});

async function getInitialContracts() {
    const Mock = await ethers.getContractFactory("TCVNtoken");
    const TCVNtoken = await Mock.deploy(); 

    const _Vesting = await ethers.getContractFactory("Vesting");
    const Vesting = await _Vesting.deploy();
    
    await Vesting.initToken(TCVNtoken.address);
    await TCVNtoken.transfer(Vesting.address, ethers.utils.parseEther('10000000000'));
    
    console.log('Deploy done');
    return { TCVNtoken, Vesting }
}