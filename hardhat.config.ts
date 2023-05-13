import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.16",
  networks: {
    mumbai: {
      url: process.env.MUMBAI || "",
      accounts: process.env.PK !== undefined ? [process.env.PK] : [],
    },
  },
};

export default config;
