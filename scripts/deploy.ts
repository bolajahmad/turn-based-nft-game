import { ethers } from "hardhat";

const main = async () => {
    const gameContractFactory = await ethers.getContractFactory("EpicNftGame");
    const gameContract = await gameContractFactory.deploy(
        ["Tanjiro", "Kira B", "Luffy", "Captain Sparrow", "Naruto", "Saitama"],
        [
            "https://i.imgur.com/UFqJ9Pd.jpeg",
            "https://i.imgur.com/DKuu8gU.jpeg",
            "https://i.imgur.com/xi11L1D.jpeg",
            "https://i.imgur.com/rOm9iDs.jpeg",
            "https://i.imgur.com/55vcivg.jpeg",
            "https://i.imgur.com/Qb7m5NZ.jpeg",
        ],
        [300, 270, 310, 280, 300, 360],
        [200, 240, 190, 200, 300, 450],
        "Uchiha Madara",
        "https://i.imgur.com/PVKxeBI.jpeg",
        10000,
        60
    );
    await gameContract.deployed();
    console.log("Contract Deployed to: ", gameContract.address);

    let txn;
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait();
    console.log("Minted NFT #1");

    txn = await gameContract.attackBoss();
    await txn.wait();

    txn = await gameContract.attackBoss();
    await txn.wait();

    console.log("Contract Deployed and NFT(s) Minted");
};

const runMain = async () => {
    try {
        await main();
    } catch (error) {
        console.log({ error });
        throw new Error(JSON.stringify(error));
    }
};

runMain();
