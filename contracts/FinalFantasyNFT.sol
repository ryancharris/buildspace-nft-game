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
    uint limitBreakLevel;
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

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackCompleted(uint newBossHp, uint newPlayerHp);
  event LimitBreakAttackCompleted(uint newBossHp, uint newPlayerHp);
  event SpellCompleted(uint newBossHp, uint newPlayerHp);

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterMp,
    uint[] memory characterAttackDamage,
    uint[] memory characterSpellDamage,
    uint[] memory characterLimitBreakLevel,
    uint[] memory characterLimitBreakRequirement,
    uint[] memory characterLimitBreakDamage,
    string memory bossName,
    string memory bossImageURI,
    uint[] memory bossValues
  ) ERC721("Final Fantasy", "FFVII") {
    boss = Boss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossValues[0],
      maxHp: bossValues[1],
      mp: bossValues[2],
      maxMp: bossValues[3],
      attackDamage: bossValues[4],
      spellDamage: bossValues[5]
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
        limitBreakLevel: characterLimitBreakLevel[i],
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
    {
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
        limitBreakLevel: defaultCharacters[_characterIndex].limitBreakLevel,
        limitBreakRequirement: defaultCharacters[_characterIndex].limitBreakRequirement,
        limitBreakDamage: defaultCharacters[_characterIndex].limitBreakDamage
      });
    }

    console.log("Minted NFT w/ tokenId %s, name %s, and characterIndex %s", newItemId, nftHolderAttributes[newItemId].name, _characterIndex);

    // Update map of address => NFT ID relationships
    nftHolders[msg.sender] = newItemId;

    _tokenIds.increment();

    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
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

  function checkIfUserHasNFT() public view returns (Characteristics memory) {
    uint256 userNftTokenID = nftHolders[msg.sender];

    if (userNftTokenID > 0) {
      return nftHolderAttributes[userNftTokenID];
    } else {
      Characteristics memory nonExistentUser;
      return nonExistentUser;
    }
  }

  function getAllDefaultCharacters() public view returns (Characteristics[] memory) {
    return defaultCharacters;
  }

  function getBoss() public view returns (Boss memory) {
    return boss;
  }

  function attackBoss() public {
    uint256 nftTokenId = nftHolders[msg.sender];
    Characteristics storage player = nftHolderAttributes[nftTokenId];

    require (
      player.hp > 0,
      "Error: Player has no HP!"
    );
    console.log(
      "\n%s (# %s) is attacking!", 
      player.name, 
      nftTokenId
    );
    
    require(
      boss.hp > 0,
      "Error: Sepiroth has no HP!"
    );
    console.log("\n%s has %s HP and takes %s damage!", boss.name, boss.hp, player.attackDamage);

    if (boss.hp < player.attackDamage) {
      // The boss has died!
      console.log("\n%s is dead!", boss.name);
      boss.hp = 0;
    } else {
      // The boss takes damage
      console.log("\n%s: %s HP --> %s HP", boss.name, boss.hp, boss.hp - player.attackDamage);
      boss.hp = boss.hp - player.attackDamage;
    }

    console.log("\n%s is counter-attacking %s! They take %s damage.", boss.name, player.name, boss.attackDamage);

    if (player.hp < boss.attackDamage) {
      // The player has died!
      console.log("\n%s is dead!", player.name);
      player.hp = 0;
    } else {
      // The player takes damage
      console.log("\n%s: %s HP --> %s HP", player.name, player.hp, player.hp - boss.attackDamage);
      player.hp = player.hp - boss.attackDamage;
    }

    emit AttackCompleted(boss.hp, player.hp);
  }

  function limitBreakAttack() public {
    uint256 nftTokenId = nftHolders[msg.sender];
    Characteristics storage player = nftHolderAttributes[nftTokenId];

    require (
      player.limitBreakLevel == player.limitBreakRequirement,
      "Error: Player can't perform a limit break!"
    );
    console.log(
      "\n%s (# %s) is performing a special attack!",
      player.name,
      nftTokenId
    );

    require(
      boss.hp > 0,
      "Error: Sepiroth has no HP!"
    );
    console.log("\n%s has %s HP and takes %s damage!", boss.name, boss.hp, player.limitBreakDamage);

    if (boss.hp < player.limitBreakDamage) {
      // The boss has died!
      console.log("\n%s is dead!", boss.name);
      boss.hp = 0;
    } else {
      // The boss takes damage
      console.log("\n%s: %s HP --> %s HP", boss.name, boss.hp, boss.hp - player.limitBreakDamage);
      boss.hp = boss.hp - player.limitBreakDamage;
    }

    emit LimitBreakAttackCompleted(boss.hp, player.hp);
  }

  function castSpellOnBoss() public {
    uint256 nftTokenId = nftHolders[msg.sender];
    Characteristics storage player = nftHolderAttributes[nftTokenId];

    require (
      player.hp > 0,
      "Error: Player has no HP!"
    );
    require (
      player.mp > 0,
      "Error: Player has no MP!"
    );

    console.log(
      "\n%s (# %s) is casting a spell on %s!", 
      player.name, 
      nftTokenId,
      boss.name
    );
    
    require(
      boss.hp > 0,
      "Error: Sepiroth has no HP!"
    );
    require(
      boss.mp > 0,
      "Error: Sepiroth has no MP!"
    );
    console.log("\n%s has %s HP and takes %s damage!", boss.name, boss.hp, player.spellDamage);

    if (boss.hp < player.spellDamage) {
      // The boss has died!
      console.log("\n%s is dead!", boss.name);
      boss.hp = 0;
    } else {
      // The boss takes damage
      console.log("\n%s: %s HP --> %s HP", boss.name, boss.hp, boss.hp - player.spellDamage);
      boss.hp = boss.hp - player.spellDamage;
    }

    console.log("\n%s is counter-attacking %s with magic! They take %s damage.", boss.name, player.name, boss.spellDamage);

    if (player.hp < boss.spellDamage) {
      // The player has died!
      console.log("\n%s is dead!", player.name);
      player.hp = 0;
    } else {
      // The player takes damage
      console.log("\n%s: %s HP --> %s HP", player.name, player.hp, player.hp - boss.spellDamage);
      player.hp = player.hp - boss.spellDamage;
    }

    emit SpellCompleted(boss.hp, player.hp);
  }
}
