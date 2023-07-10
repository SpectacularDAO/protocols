// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2023 Morningstar

pragma solidity 0.8.20;

contract TheScepter{

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

    event DeityExalted(address indexed wizard, address candidate);
    event DeityDeposed(address indexed wizard, address incumbent);
    event WizardInducted(address indexed wizard, address candidate);
    event WizardRevoked(address indexed wizard, address incumbent);
    event CuratorRecruited(address indexed recruit);
    event CuratorRetired(address indexed retiree);

    event ETHAllocated(
        address indexed wizard,
        address recipient,
        uint256 amount
    );

    event Forged(
        address indexed recipient,
        address indexed deity,
        uint256 fee,
        uint256 mintable
    );

    event BoosterGranted(
        address indexed recipient,
        address indexed deity,
        uint8   boosterCode
    );

    event MintableGranted(
        address indexed recipient,
        address indexed deity,
        uint256 amount
    );

    event Minted(
        address indexed recipient,
        address indexed deity,
        uint256 amount,
        uint256 KWAN
    );

    event FeesUpdated(
        address indexed wizard,
        Charge feesConfig
    );

    event GeneratorCalibrated(
        address indexed asset,
        address indexed wizard,
        Magic config
    );

    event AuditPeriodSet(
        address indexed wizard,
        uint168 period
    );

    error TRANSFER1();
    error RESERVES1();
    error MATURITY2();
    error AUTHENTICATION1();
    error AUTHENTICATION2();

    function deitiesAuth() view private {
        if(deities[msg.sender] != true)
            revert AUTHENTICATION1();
    }

    modifier onlyDeities{
        deitiesAuth();
        _;
    }

    function wizardsAuth() view private {
        if(wizards[msg.sender] != true)
            revert AUTHENTICATION2();
    }

    modifier onlyWizards{
        wizardsAuth();
        _;
    }

    function ordainDeity(address being, bool seat) external onlyWizards{
        if(seat){
            deities[being] = seat;
            emit DeityExalted(being, msg.sender);
        }else {
            deities[being] = seat;
            emit DeityDeposed(being, msg.sender);
        }
    }

    function ordainWizard(address being, bool seat) external onlyWizards{
        if(seat){
            wizards[being] = seat;
            emit WizardInducted(being, msg.sender);
        }else {
            wizards[being] = seat;
            emit WizardRevoked(being, msg.sender);
        }
    }

    function setAuditPeriod(uint168 newPeriod) external onlyWizards {
        auditPeriod = newPeriod;
        emit AuditPeriodSet(msg.sender, newPeriod);
    }

    function updateFees(Charge calldata newFeesCongig) external onlyWizards {
        fees = newFeesCongig;
        emit FeesUpdated(msg.sender, fees);
    }

    function calibrateGenerator(address asset, Magic calldata config) external onlyWizards{
        grimoire[asset] = config;
        emit GeneratorCalibrated(asset, msg.sender, config);
    }

    function allocateETH(address payable recipient, uint168 amount) external onlyWizards {
        uint256 allocated = allocatedETH;
        uint256 allocationQuota = ((address(this).balance + allocated) * 2) / 3;
        if(allocated + amount > allocationQuota)
            revert RESERVES1();

        (bool success,) = recipient.call{value: amount}("");
        if(success != true)
            revert TRANSFER1();
        allocatedETH += amount;
        emit ETHAllocated(msg.sender, recipient, amount);
    }

    function grantBooster(MintBooster calldata boosterData, address recipient, uint256 index, bool renew) external onlyDeities {
        if(renew){
            allowList[recipient].boosters[index].expiry = boosterData.expiry;
        }else{
            allowList[recipient].boosters.push(boosterData);
        }
        emit BoosterGranted(recipient, msg.sender, boosterData.boosterCode);
    }

    function grantMintable(address recipient, uint256 amount) external onlyDeities{
        allowList[recipient].mintable += amount;
        emit MintableGranted(recipient, msg.sender, amount);
    }

    function forge(address recipient, uint256 mintable) external payable onlyDeities{
        allowList[recipient].mintable += mintable;
        emit Forged(recipient, msg.sender, msg.value, mintable);
    }

    function mint(address recipient, uint256 amount) external onlyDeities {
        MintBooster[] memory boosters = allowList[recipient].boosters;
        uint256 boostK100BasisPts;
        uint256 KWAN;
        
        if( boosters.length > 0){
            for(uint256 i = 0; i < boosters.length; i++){
                if(boosters[i].expiry >= block.timestamp){
                    boostK100BasisPts += boosters[i].K100BasisPts;
                }else {
                    if(boosters[i].expiry != 0)
                        delete allowList[recipient].boosters[i];
                }
            }
        }

        if( boostK100BasisPts > 0)
            KWAN = amount + ((amount * boostK100BasisPts) / 10**7);
        else
            KWAN = amount;
        
        fees.mint += (fees.mint * 100) / 10000000;
        allowList[recipient].mintable -= amount;
        balanceOf[recipient] += KWAN;
        totalSupply += KWAN;

        emit Minted(recipient, msg.sender, amount, KWAN);
    }
}