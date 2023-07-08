// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2023 Morningstar

pragma solidity 0.8.20;

contract Carver{

    struct Magic{
        bool    active;
        uint16  kwantized;
        uint168 ignitionFee;
    }

    struct Incantation{
        address angel;
        uint16  charm;
    }

    struct Codex{
        uint16  wave;
        uint64  dawn;
        uint96  halo;
        address mage;
    }

    struct Charge{
        uint80 cast;
        uint80 forge;
        uint80 mint;
    }

    struct MintBooster{
        uint24  K100BasisPts;
        uint8   boosterCode;
        uint16  expiry;
    }

    struct MintPermit{
        uint256       mintable;
        MintBooster[] boosters;
        uint168[2][]  vesting;
        uint168[2][]  auditing;
    }

    bool    private constant PROXIED = false;
    uint168 private auditPeriod;
    uint168 private allocatedETH;
    uint256 public  totalSupply;
    Charge  private fees;
    mapping(address => uint256)                     public  balanceOf;
    mapping(address => uint256)                     private accountOf;
    mapping(address => mapping(address => uint256)) public  allowance;
    mapping(address => MintPermit)                  private allowList;
    mapping(address => Magic)                       private grimoire;
    mapping(address => bool)                        private wizards;
    mapping(address => bool)                        private deities;
    mapping(address => mapping(uint256 => Codex))   private spells;
    mapping(address => uint256)                     private nonces;
    mapping(bytes4  => Incantation)                 private wand;
    bytes4[]                                        private charms;

    error AUTHENTICATION2();

    event WandDecorated(address splinter, uint8 operation, bytes4[] selectors);

    function wizardsAuth() view private {
        if(wizards[msg.sender] != true)
            revert AUTHENTICATION2();
    }

    modifier onlyWizards{
        wizardsAuth();
        _;
    }

    //0xfcad90b4
    function decorate(
        address angel,
        uint8 operation,
        bytes4[] calldata charmsList)
        external
        onlyWizards{
            if(operation == 1){
                markCharms(angel, charmsList);
            }else if(operation == 2){
                liftCharms(angel, charmsList);
            }else{
                fadeCharms(charmsList);
            }
            emit WandDecorated(angel, operation, charmsList);
    }

    function markCharms(address angel, bytes4[] calldata charmsList) private{
        uint16 charmsCount = uint16(charms.length);

        for(uint256 index; index < charmsList.length; index++){
            wand[charmsList[index]] = Incantation(angel, charmsCount);
            charms.push(charmsList[index]);
            charmsCount++;
        }
    }

    function liftCharms(address angel, bytes4[] calldata charmsList) private{
        for(uint256 index; index < charmsList.length; index++){
            wand[charmsList[index]].angel = angel;
        }
    }

    function fadeCharms(bytes4[] calldata charmsList) private{
        uint16 charmsCount = uint16(charms.length);
        uint16 lastCharmIndex;

        for(uint256 index; index < charmsList.length; index++){
            Incantation memory targetData = wand[charmsList[index]];
            lastCharmIndex = charmsCount - 1;

            if(targetData.charm != lastCharmIndex){
                bytes4 lastCharm = charms[lastCharmIndex];
                charms[targetData.charm] = lastCharm;
                wand[lastCharm].charm = targetData.charm;
            }

            charms.pop();
            delete wand[charmsList[index]];
        }
    }
}