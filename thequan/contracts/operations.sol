// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2023 Morningstar

pragma solidity 0.8.20;

contract AccountOperations{

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

    error FEE1();
    error OWNER1();
    error PROXY1();
    error MATURITY1();
    error BALANCE1();
    error BALANCE3();
    error BALANCE2();
    error TRANSFER1();

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event Cast(
        address indexed recipient,
        address indexed asset,
        uint256 fee,
        uint256 mintable
    );

    event Vested(
        address indexed recipient,
        uint256 amount
    );

    event Withdrawn(
        address indexed recipient,
        uint256 amount
    );

    event ForgeRequested(
        address indexed requester,
        uint256 amount
    );

    event MintRequested(
        address indexed requester,
        uint168 amount,
        uint256 fee
    );

    function proxyCheck() pure private {
        if(PROXIED != true)
            revert PROXY1();
    }

    modifier onlyProxy{
        proxyCheck();
        _;
    }

    function cast(address asset, uint256 NFTID) external payable onlyProxy returns(uint256){
        Codex memory craft = spells[asset][NFTID];
        if(craft.mage != msg.sender)
            revert OWNER1();

        if(msg.value != fees.cast)
            revert FEE1();

        uint256  phase = craft.wave > 0 ? craft.wave : 30 days;
        uint256 lunars = (block.timestamp - craft.dawn) / phase;

        if(lunars > 0){
            uint256 mintable = (phase / 1 days) * lunars * craft.halo;
            spells[asset][NFTID].dawn = uint64(craft.dawn + (lunars * phase));
            allowList[msg.sender].mintable += mintable;

            emit Cast(msg.sender, asset, msg.value, mintable);
            return mintable;
        }else {
            revert MATURITY1();
        }
    }

    function requestForge(uint256 amount) external payable onlyProxy{
        if(msg.value != fees.forge)
            revert FEE1();
        emit ForgeRequested(msg.sender, amount);
    }

    function requestMint(uint168 amount) external payable onlyProxy{
        if(msg.value != fees.mint)
            revert FEE1();
        
        uint256 mintable = allowList[msg.sender].mintable;
        if(amount > mintable)
            revert BALANCE3();

        emit MintRequested(msg.sender, amount, msg.value);
    }

    function unlockVested() external onlyProxy returns(uint256){
        uint168[2][] memory vesting = allowList[msg.sender].vesting;
        uint256 vested;

        for(uint32 i = 0; i < vesting.length; i++){
            if(vesting[i][0] > 0 && vesting[i][0] < block.timestamp){
                delete allowList[msg.sender].vesting[i];
                allowList[msg.sender].mintable += vesting[i][1];
                vested += vesting[i][1];
            }
        }

        emit Vested(msg.sender, vested);
        return vested;
    }

    function withdraw(uint256 amount) external onlyProxy{
        if(amount > accountOf[msg.sender])
            revert BALANCE2();

        accountOf[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if(success == false)
            revert TRANSFER1();

        emit Withdrawn(msg.sender, amount);
    }

    function burn(uint256 amount) private onlyProxy{
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}