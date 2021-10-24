// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract FinalFantasyNFT {
  
  struct Characteristics {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint mp;
    uint maxMp;
    uint attackDamage;
    uint spellDamage;
  }

  constructor() {
    console.log("THIS IS MY GAME CONTRACT. NICE.");
  }
}
