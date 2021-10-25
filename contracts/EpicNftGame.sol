// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

import "./libraries/Base64.sol";

contract EpicNftGame is ERC721 {
    // declare character abilities
    struct CharacterAbility {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint attackPower;
    }

    // This Counters utility from openzeppelin allows counting in integer with single step
    // It is ideal for storing ID values
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // defaultCharacters holds a list of all default characters
    CharacterAbility[] public defaultCharacters;

    // create a mapping of the tokenId => characterDetails
    mapping(uint256 => CharacterAbility) public nftHolderAttributes;

    struct BigBoss {
        string name;
        string imageUri;
        uint hp;
        uint attackPower;
    }

    BigBoss public bigBoss;

    // create a mapping from address to tokenID address => tokenId
    mapping(address => uint256) public nftHolders;

    event CharacterMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHps,
        uint[] memory characterAttackPower,
        string memory bossName,
        string memory bossImageUri,
        uint bossHp,
        uint bossAttackpower
        ) ERC721('Freedom Fighters', 'FFS') {
        // initialize nft name and symbol
        
        bigBoss = BigBoss({
            name: bossName,
            imageUri: bossImageUri,
            hp: bossHp,
            attackPower: bossAttackpower
        });
        console.log("Done initializing boss %s with HP %s, imag %s", bigBoss.name, bigBoss.hp, bigBoss.imageUri);

        // loop through arrays and assign the values to 
        // @params defaultCharaters 
        for(uint i = 0; i < characterNames.length; i+=1) {
            defaultCharacters.push(CharacterAbility({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHps[i],
                attackPower: characterAttackPower[i]
            }));

            CharacterAbility memory c = defaultCharacters[i]; 
            console.log("Done initializing %s with HP %s, imag %s", c.name, c.hp, c.imageURI);
        }

        _tokenIds.increment();
    }

    // Users can call this function to get their NFT
    // NFT is gotten based on the characterId passed in
    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current();

        // extending the ERC721 allows me to use this
        // assign the ID to the message.sender
        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAbility({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            attackPower: defaultCharacters[_characterIndex].attackPower
        });

        console.log(
            "Minted %s with tokenID %s and characterIndex %s", 
            nftHolderAttributes[newItemId].name, 
            newItemId, 
            _characterIndex
        );

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();
        emit CharacterMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAbility memory charAbility = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAbility.hp);
        string memory strAttackPower = Strings.toString(charAbility.attackPower);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAbility.name,
                        ' -- NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in Beast Huntersz", "image": "',
                        charAbility.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ', strHp,'}, { "trait_type": "Attack Power", "value": ', 
                        strAttackPower,'} ]}'
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {
        // Get the state of the player's NFT
        uint256 playerTokenId = nftHolders[msg.sender];
        CharacterAbility storage player = nftHolderAttributes[playerTokenId];
        console.log(
            "\nPlayer with character %s about to attack. Has %s HP and %s AP", 
            player.name, player.hp, player.attackPower
        );
        console.log(
            "Boss %s has %s HP and %s AP",
            bigBoss.name, bigBoss.hp, bigBoss.attackPower
        );

        // constraint player and boss to have enough HP
        require(player.hp > 0, "NFT is not able to attack, low HP");
        require(bigBoss.hp > 0, "Boss is already dead");

        // player attacks boss
        if (bigBoss.hp < player.attackPower) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackPower;
        }
        

        // boss attacks player
        if (player.hp < bigBoss.attackPower) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackPower;
        }

        console.log("Boss attacked player, new player hp: %s ", player.hp);
        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function checkIfUserHasNft() public view returns (CharacterAbility memory) {
        // Get the tokenID of the user's NFT
        const playerTokenId = nftHolders[msg.sender];

        // if player token exists, return the mapped character
        if (playerTokenId > 0) {
            return nftHolderAttributes[playerTokenId];
        } else {
            CharacterAbility memory emptyCharacter;
            return emptyCharacter;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAbility[] memory) {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }
}