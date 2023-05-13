import { ethers } from "hardhat";

async function main() {
  // const MultichainTicket = await ethers.getContractFactory("MultichainTicket");
  // const multichainTicket = await MultichainTicket.deploy(""); // add uri

  // await multichainTicket.deployed();

  // console.log("multichainTicket deployed to:", multichainTicket.address);

  const PoseidonUnit6L = await ethers.getContractFactory("PoseidonUnit6L");
  const poseidonUnit6L = await PoseidonUnit6L.deploy();
  await poseidonUnit6L.deployed();

  const SpongePoseidon = await ethers.getContractFactory("SpongePoseidon", {
    libraries: {
      "contracts/lib/Poseidon.sol:PoseidonUnit6L": poseidonUnit6L.address,
    },
  });
  const spongePoseidon = await SpongePoseidon.deploy();
  await spongePoseidon.deployed();

  let MultichainNftVerifier = await ethers.getContractFactory(
    "MultichainNftVerifier",
    {
      libraries: {
        "contracts/lib/Poseidon.sol:PoseidonUnit6L": poseidonUnit6L.address,
        "contracts/lib/Poseidon.sol:SpongePoseidon": spongePoseidon.address,
      },
    }
  );

  const multichainNftVerifier = await MultichainNftVerifier.deploy(
    ethers.constants.AddressZero,
    ethers.constants.AddressZero,
    ethers.constants.AddressZero,
    "",
    "",
    ""
  ); // add uri

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
