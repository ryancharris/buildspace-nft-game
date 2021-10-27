// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract FinalFantasyNFT is ERC721 {

  struct Characteristics {
    uint index;
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint mp;
    uint maxMp;
    uint attackDamage;
    uint spellDamage;
  }

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  Characteristics[] defaultCharacters;

  mapping(uint256 => Characteristics) public nftHolderAttributes;
  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterMp,
    uint[] memory characterAttackDamage,
    uint[] memory characterSpellDamage
  ) ERC721("Final Fantasy", "FF") {

    for (uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(Characteristics({
        index: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        mp: characterMp[i],
        maxMp: characterMp[i],
        attackDamage: characterAttackDamage[i],
        spellDamage: characterSpellDamage[i]
      }));

      Characteristics memory character = defaultCharacters[i];
      console.log("Done initializing %s w/ %s HP & %s MP", character.name, character.hp, character.mp);

      _tokenIds.increment();
    }
  }

  function mintNFT(uint _characterIndex) external {
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = Characteristics({
      index: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      mp: defaultCharacters[_characterIndex].mp,
      maxMp: defaultCharacters[_characterIndex].maxMp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage,
      spellDamage: defaultCharacters[_characterIndex].spellDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

    nftHolders[msg.sender] = newItemId;

    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    Characteristics memory charAttr = nftHolderAttributes[_tokenId];
    console.log(charAttr.name);
    console.log(charAttr.imageURI);

    string memory strHp = Strings.toString(charAttr.hp);
    string memory strMaxHp = Strings.toString(charAttr.maxHp);
    // string memory strMp = Strings.toString(charAttr.mp);
    // string memory strMaxMp = Strings.toString(charAttr.maxMp);
    string memory strAttackDamage = Strings.toString(charAttr.attackDamage);
    // string memory strSpellDamage = Strings.toString(charAttr.spellDamage);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "', charAttr.name, ' -- ', Strings.toString(_tokenId), '"}'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
  }
}
