import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('Epic NFT Game contract', () => {
    let Token;
    let hardhatToken: any;

    beforeEach(async () => {
        Token = await ethers.getContractFactory('EpicNftGame');
        const [owner] = await ethers.getSigners();
        console.log({ owner }):

        hardhatToken = Token.deploy(
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
            [200, 240, 190, 200, 300, 450]
        );
    });

    describe('Contract Initialization', () => {
        it('Should initialize game characters', async () => {
            const defaultCharacters = await hardhatToken.defaultCharacters();
            console.log({ defaultCharacters });
            expect(defaultCharacters.length).to.equal(6)
        })
    })
})