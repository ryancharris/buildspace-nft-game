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
    uint limitBreakRequirement;
    uint limitBreakDamage;
  }

  struct Boss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint mp;
    uint maxMp;
    uint attackDamage;
    uint spellDamage;
  }
  Boss public boss;

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
    uint[] memory characterSpellDamage,
    uint[] memory characterLimitBreakRequirement,
    uint[] memory characterLimitBreakDamage,
    Boss memory boss
  ) ERC721("Final Fantasy", "FFVII") {
    boss = Boss({
      name: boss.name,
      imageURI: boss.imageURI,
      hp: boss.hp,
      maxHp: boss.maxHp,
      mp: boss.mp,
      maxMp: boss.maxMp,
      attackDamage: boss.attackDamage,
      spellDamage: boss.spellDamage
    });

    console.log("Done initializing boss %s w/ HP %s, img %s", boss.name, boss.hp, boss.imageURI);
    
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
        spellDamage: characterSpellDamage[i],
        limitBreakRequirement: characterLimitBreakRequirement[i],
        limitBreakDamage: characterLimitBreakDamage[i]
      }));

      Characteristics memory character = defaultCharacters[i];
      console.log("Done initializing %s w/ %s HP & %s MP", character.name, character.hp, character.mp);
    }

    _tokenIds.increment();
  }

  function mintNFT(uint _characterIndex) external {
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);

    // Add new item to nftHolderAttributes
    nftHolderAttributes[newItemId] = Characteristics({
      index: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      mp: defaultCharacters[_characterIndex].mp,
      maxMp: defaultCharacters[_characterIndex].maxMp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage,
      spellDamage: defaultCharacters[_characterIndex].spellDamage,
      limitBreakRequirement: defaultCharacters[_characterIndex].limitBreakRequirement,
      limitBreakDamage: defaultCharacters[_characterIndex].limitBreakDamage
    });

    console.log("Minted NFT w/ tokenId %s, name %s, and characterIndex %s", newItemId, nftHolderAttributes[newItemId].name, _characterIndex);

    // Update map of address => NFT ID relationships
    nftHolders[msg.sender] = newItemId;

    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    Characteristics memory charAttr = nftHolderAttributes[_tokenId];
    string memory strHp = Strings.toString(charAttr.hp);
    string memory strMaxHp = Strings.toString(charAttr.maxHp);
    string memory strMp = Strings.toString(charAttr.mp);
    string memory strMaxMp = Strings.toString(charAttr.maxMp);
    string memory strAttackDamage = Strings.toString(charAttr.attackDamage);
    string memory strSpellDamage = Strings.toString(charAttr.spellDamage);
    string memory strLimitBreak = Strings.toString(charAttr.limitBreakRequirement);
    string memory strLimitBreakDamage = Strings.toString(charAttr.limitBreakDamage);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            charAttr.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '", "description": "Final Fantasy on the blockchain!", "image": "',
            charAttr.imageURI,
            '", "attributes": [ { "trait_type": "Health", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Mana", "value": ',strMp,', "max_value":',strMaxMp,'}, { "trait_type": "Attack Damage", "value": ',
            strAttackDamage,'}, { "trait_type": "Spell Damage", "value": ',
            strSpellDamage,'}, { "trait_type": "Limit Break", "value": ',
            strLimitBreak,'}, { "trait_type": "Limit Break Damage", "value": ',
            strLimitBreakDamage,'}]}'
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
