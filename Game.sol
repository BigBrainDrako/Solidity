User
User
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ForestGame is IERC721Receiver, Context {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Events
    event ForestMinted(address indexed player, uint256 tokenId);
    event LandUnlocked(address indexed player, uint256 tokenId, uint256 landId);
    event ToolStaked(address indexed player, uint256 tokenId, uint256 landId, uint256 toolId, uint256 toolAmount);
    event RewardsClaimed(address indexed player, uint256 tokenId, uint256 landId, uint256 rewardAmount);

    // Constants
    uint256 private constant MAX_FORESTS = 10000;
    uint256 private constant LAND_PRICE = 100;

    // State variables
    address private _owner;
    IERC20 private _woodToken;
    IERC721 private _forestToken;
    mapping(uint256 => mapping(uint256 => uint256)) private _landPrices;
    mapping(uint256 => EnumerableSet.AddressSet) private _landUnlockers;
    mapping(uint256 => EnumerableSet.AddressSet) private _toolStakers;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) private _toolRewards;

    // Modifiers
    modifier onlyOwner() {
        require(_msgSender() == _owner, "ForestGame: caller is not the owner");
        _;
    }

    // Constructor
    constructor(address woodTokenAddress, address forestTokenAddress) {
        _owner = _msgSender();
        _woodToken = IERC20(woodTokenAddress);
        _forestToken = IERC721(forestTokenAddress);
    }
    
    // ... (rest of the contract code)
}
    contract ForestGame is IERC721Receiver, Context {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    // ... (state variables, constructor, modifiers, and events)

    // Public functions
    function mintForest(uint256 tokenId) public {
        require(_forestToken.ownerOf(tokenId) == _msgSender(), "ForestGame: player does not own the forest");
        require(_landPrices[tokenId][1] == 0, "ForestGame: forest already minted");

        _landPrices[tokenId][1] = LAND_PRICE;
        for (uint256 i = 2; i <= 5; i++) {
            _landPrices[tokenId][i] = LAND_PRICE * i;
        }

        emit ForestMinted
    }
   }
   // Internal functions
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
    if (from == address(0)) {
        // Minting of forest
        _forestLandOwners[tokenId] = _msgSender();
        _forestLandCount[_msgSender()]++;
    } else if (to == address(0)) {
        // Burning of forest
        _forestLandOwners[tokenId] = address(0);
        _forestLandCount[from]--;
    } else {
        // Transfer of land ownership
        require(_msgSender() == _forestLandOwners[tokenId], "ForestGame: sender is not the forest owner");
        _forestLandOwners[tokenId] = to;
        _forestLandCount[from]--;
        _forestLandCount[to]++;
    }
}

// ERC721Receiver functions
function onERC721Received(address, address from, uint256 tokenId, bytes memory) public virtual override returns (bytes4) {
    // Only accept forests from the _forestToken contract
    require(_msgSender() == address(_forestToken), "ForestGame: contract does not accept this token");
    // Check if player already owns a forest
    require(!_playerForests[from], "ForestGame: player already owns a forest");

    _playerForests[from] = true;
    return this.onERC721Received.selector;
}

// View functions
function getLandPrice(uint256 tokenId, uint256 landNumber) public view returns (uint256) {
    require(landNumber >= 1 && landNumber <= 5, "ForestGame: invalid land number");

    return _landPrices[tokenId][landNumber];
}

function getPlayerForest(address player) public view returns (uint256) {
    require(_playerForests[player], "ForestGame: player does not own a forest");

    for (uint256 i = 1; i <= _forestToken.totalSupply(); i++) {
        if (_forestToken.ownerOf(i) == player) {
            return i;
        }
    }

    // Should never happen
    revert("ForestGame: player does not own a forest");
}

function getForestLandOwners(uint256 tokenId) public view returns (address[] memory) {
    require(_forestToken.ownerOf(tokenId) != address(0), "ForestGame: forest does not exist");

    address[] memory landOwners = new address[](5);
    for (uint256 i = 1; i <= 5; i++) {
        landOwners[i - 1] = _landOwners[tokenId][i];
    }

    return landOwners;
}

function getForestLandCount(address player) public view returns (uint256) {
    return _forestLandCount[player];
}

function isPlayerForest(address player) public view returns (bool) {
    return _playerForests[player];
}