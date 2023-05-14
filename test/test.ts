import { expect } from "chai";
import { ethers } from "hardhat";
import { ContractFactory, Signer } from "ethers";

describe("Game Contract", () => {
  let conract;

  beforeEach(async () => {
    const Contract = await ethers.getContractFactory("MultichainNftVerifier");
    const contract = await Contract.deploy(
      "0xD81dE4BCEf43840a2883e5730d014630eA6b7c4A", // worldcoin polygon
      "0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d", // lenshub polygon
      "0x57137e3d5BbDe8cB9A799055923B04e8430c7d4C", // bridge address polygon
      "app_4dbefa59fdf71b9b734938badbf9c23b", // appId worldcoin
      "register", // actionId worldcoin
      "" // add uri
    );
    await contract.deployed();

    const Game = await ethers.getContractFactory("Game");
  });
});
