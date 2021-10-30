const names = ["Cloud", "Tifa", "Barret", "Aerith", "Vincent"];
const imagesURIs = [
  "https://upload.wikimedia.org/wikipedia/en/9/9e/Cloud_Strife.png",
  "https://upload.wikimedia.org/wikipedia/en/6/61/Tifa_Lockhart_art.png",
  "https://upload.wikimedia.org/wikipedia/en/c/cd/Ff7-barret.png",
  "https://upload.wikimedia.org/wikipedia/en/2/2f/Aerith_Gainsborough.png",
  "https://upload.wikimedia.org/wikipedia/en/1/1d/Vincent_Valentine.png",
];
const hp = [85, 72, 100, 84, 88]; // out of 100
const mp = [30, 45, 10, 35, 25]; // out of 50
const spellDamage = [10, 20, 6, 14, 10]; // out of 25
const attackDamage = [14, 12, 16, 10, 9]; // out of 25
const limitBreakLevel = [0, 0, 0, 0, 0]; // out of 10
const limitBreakRequirement = [7, 5, 10, 6, 8]; // out of 10
const limitBreakDamage = [20, 18, 22, 16, 15]; // out of 25
const sepiroth = [150, 150, 50, 50, 20, 20];

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
    limitBreakLevel,
    limitBreakRequirement,
    limitBreakDamage,
    "Sepiroth",
    "https://en.wikipedia.org/wiki/Sephiroth_(Final_Fantasy)#/media/File:Sephiroth.png",
    sepiroth
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  txn = await gameContract.mintNFT(3);
  await txn.wait();

  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI:", returnedTokenUri);

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.castSpellOnBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.limitBreakAttack();
  await txn.wait();

  console.log("Done!");
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
