// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract RealEstate is ERC721, Ownable {
    struct Property {
        uint256 id;
        string name;
        string location;
        uint256 price;
        bool forSale;
        address payable owner;
        uint256 rentPrice;
        bool forRent;
    }

    mapping (uint256 => Property) public properties;
    uint256 public nextPropertyId;

    event PropertyListed(uint256 id, string name, uint256 price, string location);
    event PropertySold(uint256 id, address newOwner, uint256 price);
    event PropertyRented(uint256 id, address renter, uint256 rentPrice);

    constructor(address initialOwner) ERC721("RealEstate", "REALESTATE") Ownable(initialOwner) {}

    function listProperty(string memory name, string memory location, uint256 price) public onlyOwner {
        require(price > 0, "price must be greater than zero");

        properties[nextPropertyId] = Property({
            id: nextPropertyId,
            name: name,
            location: location,
            price: price,
            forSale: true,
            owner: payable(msg.sender),
            rentPrice: 0,
            forRent: false
        });

        _mint(msg.sender, nextPropertyId);

        emit PropertyListed(nextPropertyId, name, price, location);
        nextPropertyId++;
    }

    function buyProperty(uint256 propertyId) public payable {
        Property storage property = properties[propertyId];
        require(property.forSale, "Property is not for sale");
        require(msg.value > property.price, "Insufficient payment");

        address payable previousOwner = property.owner;

        _transfer(previousOwner, msg.sender, propertyId);

        property.owner = payable(msg.sender);
        property.forSale = false;

        previousOwner.transfer(msg.value);

        emit PropertySold(propertyId, msg.sender, property.price);
    } 

    function propertyListForRent(uint256 propertyId, uint256 rentPrice) public payable {
        Property storage property = properties[propertyId];
        require(msg.sender == property.owner, "Only owner can list this property for rent");
        require(rentPrice > 0, "Price must be greater than zero");

        property.forRent = true;
        property.rentPrice = rentPrice;
    }

    function rentProperty(uint256 propertyId) public payable {
        Property storage property = properties[propertyId];
        require(property.forRent, "This property is not for rent");
        require(msg.value >= property.rentPrice, "Insuficient payment");

        property.owner.transfer(msg.value);

        emit PropertyRented(propertyId, msg.sender, property.rentPrice);
    }

        receive() external payable {
        
    }
}