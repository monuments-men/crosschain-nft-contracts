import { ethers } from "hardhat";

async function main() {
  const MultichainTicket = await ethers.getContractFactory("MultichainTicket");
  const multichainTicket = await MultichainTicket.deploy(""); // add uri

  await multichainTicket.deployed();

  console.log("multichainTicket deployed to:", multichainTicket.address);

  const MultichainNftVerifier = await ethers.getContractFactory(
    "MultichainNftVerifier"
  );

  const multichainNftVerifier = await MultichainNftVerifier.deploy(
    "0xD81dE4BCEf43840a2883e5730d014630eA6b7c4A", // worldcoin polygon
    "0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d", // lenshub polygon
    "0x1e049eE762A31c27588d522c596045616C8d5Cf4", // bridge address polygon
    "app_4dbefa59fdf71b9b734938badbf9c23b", // appId worldcoin
    "register", // actionId worldcoin
    "" // add uri
  );

  await multichainNftVerifier.deployed();

  console.log(
    "multichainNftVerifier deployed to:",
    multichainNftVerifier.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
