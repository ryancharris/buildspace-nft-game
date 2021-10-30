const names = ["Cloud", "Tifa", "Barret", "Aerith", "Vincent"];
const imagesURIs = [
  "https://en.wikipedia.org/wiki/Cloud_Strife#/media/File:Cloud_Strife.png",
  "https://en.wikipedia.org/wiki/Tifa_Lockhart#/media/File:Tifa_Lockhart_art.png",
  "https://en.wikipedia.org/wiki/Barret_Wallace#/media/File:Ff7-barret.png",
  "https://en.wikipedia.org/wiki/Aerith_Gainsborough#/media/File:Aerith_Gainsborough.png",
  "https://en.wikipedia.org/wiki/Vincent_Valentine#/media/File:Vincent_Valentine.png",
];
const hp = [85, 72, 100, 84, 88]; // out of 100
const mp = [30, 45, 10, 35, 25]; // out of 50
const spellDamage = [10, 20, 6, 14, 10]; // out of 25
const attackDamage = [14, 12, 16, 10, 9]; // out of 25
const limitBreakRequirement = [7, 5, 10, 6, 8]; // out of 10
const limitBreakDamage = [20, 18, 22, 16, 15]; // out of 25

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory(
    "FinalFantasyNFT"
  );
  const gameContract = await gameContractFactory.deploy(
    names,
    imagesURIs,
    hp,
    mp,
    attackDamage,
    spellDamage,
    limitBreakRequirement,
    limitBreakDamage
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn = await gameContract.mintNFT(1);
  await txn.wait();

  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
