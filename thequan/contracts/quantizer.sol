// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2023 Morningstar

pragma solidity 0.8.20;

import "./interfaces/IERC721.sol";

contract Kwantizer721{

    struct Magic{
        bool    active;
        uint16  kwantized;
        uint168 ignitionFee;
    }

    struct KwantizerCache{
        uint256 fee;
        uint256 kwantized;
        uint256 tierPoints;
        uint256 activeTier;
        uint256 assetSupply;
        uint256 submittedFee;
        uint256 augmentedNFTs;
    }

    struct Incantation{
        address angel;
        uint16  charm;
    }

    struct Codex{
        uint16  wave;
        uint64  dawn;
        uint256 halo;
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

    event Kwantized(
        address indexed asset,
        address indexed holder,
        uint256 tokenId,
        uint256 fee
    );

    event Refunded(
        address indexed recipient,
        uint256 amount
    );

    error PROXY1();
    error STATUS1();

    function proxyCheck() pure private {
        if(PROXIED != true)
            revert PROXY1();
    }

    modifier onlyProxy{
        proxyCheck();
        _;
    }

    function getTier(uint256 tierPoints) internal pure returns (uint256){
        uint24[9] memory kwantiers = [7000000, 5000000, 3000000, 2000000, 1000000, 500000, 300000, 100000, 10000];
        uint256 tier = 10;

        for(uint256 i = 0; i < kwantiers.length; i++){
            if(tierPoints < kwantiers[i])
                --tier;
        }

        return tier;
    }

    function augmentNFT(address asset, uint256 NFT, uint256 kwanta) internal {
        spells[asset][NFT].dawn = uint64(block.timestamp);
        spells[asset][NFT].mage = msg.sender;
        spells[asset][NFT].halo = kwanta * 10**18;
    }

    function kwantize(address asset, uint256[] calldata tokens)external payable onlyProxy returns(uint256, uint256){
        if(!grimoire[asset].active)
            revert STATUS1();
            
        KwantizerCache memory kwan;
        kwan.assetSupply = IERC721(asset).totalSupply();
        kwan.kwantized = grimoire[asset].kwantized;
        kwan.tierPoints = ((kwan.kwantized * 100000) / kwan.assetSupply) * 100;
        kwan.activeTier = getTier(kwan.tierPoints);
        kwan.submittedFee = msg.value;

        for (uint256 i = 0; i < tokens.length; i++){
            if(IERC721(asset).ownerOf(tokens[i]) == msg.sender){
                uint256 updatedTierPoints = ((++kwan.kwantized * 100000) / kwan.assetSupply) * 100;
                uint256 updatedTier = getTier(updatedTierPoints);

                if(updatedTier != kwan.activeTier){
                    kwan.activeTier = updatedTier;
                    kwan.fee = grimoire[asset].ignitionFee;
                    kwan.fee += kwan.fee / 2;

                    if(kwan.submittedFee > kwan.fee){
                        grimoire[asset].ignitionFee = uint168(kwan.fee);
                        kwan.submittedFee -= kwan.fee;
                        augmentNFT(asset, tokens[i], 11 - kwan.activeTier);
                        ++kwan.augmentedNFTs;
                        ++grimoire[asset].kwantized;
                        emit Kwantized(asset, msg.sender, tokens[i], kwan.fee);
                    }else{
                        accountOf[msg.sender] += kwan.submittedFee;
                        emit Refunded(msg.sender, kwan.submittedFee);
                        return (kwan.augmentedNFTs, kwan.submittedFee);
                    }

                }else{
                    if(kwan.submittedFee > kwan.fee){
                        kwan.fee = grimoire[asset].ignitionFee;
                        kwan.submittedFee -= kwan.fee;
                        augmentNFT(asset, tokens[i], 11 - kwan.activeTier);
                        ++kwan.augmentedNFTs;
                        ++grimoire[asset].kwantized;
                        emit Kwantized(asset, msg.sender, tokens[i], kwan.fee);
                    }else{
                        accountOf[msg.sender] += kwan.submittedFee;
                        emit Refunded(msg.sender, kwan.submittedFee);
                        return (kwan.augmentedNFTs, kwan.submittedFee);
                    }                    
                }
            }
        }

        if(kwan.submittedFee == 0){
            return (kwan.augmentedNFTs, kwan.submittedFee);
        }else{
            accountOf[msg.sender] += kwan.submittedFee;
            emit Refunded(msg.sender, kwan.submittedFee);
            return (kwan.augmentedNFTs, kwan.submittedFee);
        }
    }
}