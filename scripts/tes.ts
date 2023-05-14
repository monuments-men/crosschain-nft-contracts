import { ethers } from "hardhat";

export async function tes(address: string) {
  let contract = await ethers.getContractAt("MultichainNftVerifier", address);

  const tx = await contract.registerWithoutId(10, "");

  await tx.wait();
}

if (require.main === module) {
  tes("0x85029832F3F61BbFD41407cBDaD747Fd1B388FdA")
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}
