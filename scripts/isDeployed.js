const _ = require("lodash")
const fs = require("fs");
const path = require('path');
const json_path = path.join(__dirname, '/address.json');


function getNested(obj, ...args) {
	return args.reduce((obj, level) => obj && obj[level], obj)
}

function isDeployed(contract_name, platform, network) {
	var rawdata = fs.readFileSync(json_path);
	let address = JSON.parse(rawdata);

	return getNested(address, network, platform, contract_name);
}

function addNested(obj, ...args) {
	args.reduce((obj, level) => obj[level] = {}, obj)
	return obj
}

function addAdress(contract_name, platform, network, addr) {
	var rawdata = fs.readFileSync(json_path);
	let address = JSON.parse(rawdata);
	var a;

	temp = addNested({}, network, platform, contract_name);
	temp[network][platform][contract_name] = addr;	

	a = _.merge(address, temp)
	fs.writeFileSync(json_path, JSON.stringify(a, null, 4), 'utf8')
}

function AutoReset() {
	fs.writeFileSync(json_path, JSON.stringify({}, null, 4), 'utf8')
}


async function autoDeploy(objname, contract_name, platform, network, ...constructor_params){
	var Contract_addr;
	var contract_object;
  	var check_addr = isDeployed(objname, platform, network)
	
	if(check_addr==undefined){
		const contract_factory = await ethers.getContractFactory(contract_name);
		contract_object = await contract_factory.deploy(...constructor_params);
		await addAdress(objname, platform, network, await contract_object.address);
	} else {
		contract_object = await ethers.getContractAt(contract_name, check_addr);
	}

	Contract_addr = await contract_object.address;
	console.log(`${objname} address: ${Contract_addr}`);
	return contract_object
}

module.exports = {autoDeploy, getNested, addAdress, AutoReset};