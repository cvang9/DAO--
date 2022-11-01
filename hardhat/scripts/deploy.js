const { ethers } = require("hardhat");
const { CRYPTODEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
    // Deploy the FakeNFTMarketplace contract first
    const FakeNFTMarketplace = await ethers.getContractFactory(
      "FakeNFTMarketPlace"
    );
    const fakeNftMarketplace = await FakeNFTMarketplace.deploy();
    await fakeNftMarketplace.deployed();
  
    console.log("FakeNFTMarketplace deployed to: ", fakeNftMarketplace.address);
  
    // Now deploy the CryptoDevsDAO contract
    const CryptoDevsDAO = await ethers.getContractFactory("CryptoDevDAO");
    const cryptoDevsDAO = await CryptoDevsDAO.deploy(
      fakeNftMarketplace.address,
      CRYPTODEVS_NFT_CONTRACT_ADDRESS,
      {
        // This assumes your account has at least 1 ETH in it's account
        // Change this value as you want
        value: ethers.utils.parseEther("0.01"),
      }
    );
    await cryptoDevsDAO.deployed();
  
    console.log("CryptoDevsDAO deployed to: ", cryptoDevsDAO.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

    // FakeNFTMarketplace deployed to:  0xDB540bC68B706a895613017c54862FD156bcf044
    // CryptoDevsDAO deployed to:  0x923A59A34A406fF228e7cB0c94D879411c39a65A