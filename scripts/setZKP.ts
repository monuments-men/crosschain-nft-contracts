import { ethers } from "hardhat";

const Operators = {
  NOOP: 0, // No operation, skip query verification in circuit
  EQ: 1, // equal
  LT: 2, // less than
  GT: 3, // greater than
  IN: 4, // in
  NIN: 5, // not in
  NE: 6, // not equal
};

async function main() {
  // you can run https://go.dev/play/p/rnrRbxXTRY6 to get schema hash and claimPathKey using YOUR schema
  const schemaBigInt = "74977327600848231385663280181476307657";

  // merklized path to field in the W3C credential according to JSONLD  schema e.g. birthday in the KYCAgeCredential under the url "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld"
  const schemaClaimPathKey =
    "20376033832371109177683048456014525905119173674985843915445634726167450989630";

  const requestId = 1;

  const query = {
    schema: schemaBigInt,
    claimPathKey: schemaClaimPathKey,
    operator: Operators.LT, // operator
    value: [20020101, ...new Array(63).fill(0).map((i) => 0)], // for operators 1-3 only first value matters
  };

  // add the address of the contract just deployed
  const multichainNftVerifierAddress =
    "0x419E4Acc8A6B4d08c6fA05534fb0aA4311F64274";

  let multichainNftVerifier = await ethers.getContractAt(
    "MultichainNftVerifier",
    multichainNftVerifierAddress
  );

  const validatorAddress = "0xF2D4Eeb4d455fb673104902282Ce68B9ce4Ac450"; // sig validator
  // const validatorAddress = "0x3DcAe4c8d94359D31e4C89D7F2b944859408C618"; // mtp validator

  try {
    await multichainNftVerifier.setZKPRequest(
      requestId,
      validatorAddress,
      query.schema,
      query.claimPathKey,
      query.operator,
      query.value
    );
    console.log("Request set");
  } catch (e) {
    console.log("error: ", e);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
