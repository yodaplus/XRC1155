pragma solidity ^0.5.0;

import "./XRC1155.sol";

/**
    @dev Mintable form of XRC1155
    Shows how easy it is to mint new items.
*/
contract XRC1155Mintable is XRC1155 {

    bytes4 constant private INTERFACE_SIGNATURE_URI = 0x0e89341c;

    // id => creators
    mapping (uint256 => address) public creators;
    // uris
    mapping(uint256 => string) private uris;
    // A nonce to ensure we have a unique id each time we mint.
    uint256 public nonce;

    modifier creatorOnly(uint256 _id) {
        require(creators[_id] == msg.sender);
        _;
    }

    function supportsInterface(bytes4 _interfaceId)
    public
    view
    returns (bool) {
        if (_interfaceId == INTERFACE_SIGNATURE_URI) {
            return true;
        } else {
            return super.supportsInterface(_interfaceId);
        }
    }

    // Creates a new token type and assings _initialSupply to minter
    function create(uint256 _initialSupply, string calldata _uri) external returns(uint256 _id) {

        _id = ++nonce;
        creators[_id] = msg.sender;
        balances[_id][msg.sender] = _initialSupply;

        // Transfer event with mint semantic
        emit TransferSingle(msg.sender, address(0x0), msg.sender, _id, _initialSupply);

        if (bytes(_uri).length > 0) {
             uris[_id] = _uri;
            emit URI(_uri, _id);
        }
    }

    // Batch mint tokens. Assign directly to _to[].
    function mint(uint256 _id, address[] calldata _to, uint256[] calldata _quantities) external creatorOnly(_id) {

        for (uint256 i = 0; i < _to.length; ++i) {

            address to = _to[i];
            uint256 quantity = _quantities[i];

            // Grant the items to the caller
            balances[_id][to] = quantity.add(balances[_id][to]);

            // Emit the Transfer/Mint event.
            // the 0x0 source address implies a mint
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, address(0x0), to, _id, quantity);

            if (to.isContract()) {
                _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, to, _id, quantity, '');
            }
        }
    }

    // function to allocate transfering from another address
    function allocate(uint256 _id, address _from, address[] calldata _to, uint256[] calldata _quantities) external creatorOnly(_id) returns (bool _success) {

        _success = true;
        for (uint256 i = 0; i < _to.length; ++i) {

            address to = _to[i];
            uint256 quantity = _quantities[i];

            // Grant the items to the caller
            if (quantity > balances[_id][_from]) {
                _success = false;
                return _success;
            }
            balances[_id][to] = quantity.add(balances[_id][to]);
            balances[_id][_from] = balances[_id][_from] - quantity;


            // Emit the Transfer/Mint event.
            // the 0x0 source address implies a mint
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, _from, to, _id, quantity);

            if (to.isContract()) {
                _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, to, _id, quantity, '');
            }
        }
        return _success;
    }

    function uri(uint256 _id) public view  returns (string memory) {
        return uris[_id];
    }

    function setURI(string calldata _uri, uint256 _id) external creatorOnly(_id) {
        uris[_id] = _uri;
        emit URI(_uri, _id);
    }

    function burn(uint256 _id, address[] calldata _from, uint256[] calldata _quantities) external creatorOnly(_id) {

        for (uint256 i = 0; i < _from.length; ++i) {

            address from = _from[i];
            uint256 quantity = _quantities[i];
            uint256 accountBalance = balances[_id][from];
            require(accountBalance >= quantity, "XRC1155: burn amount exceeds balance");
            // Burn items from the caller
            balances[_id][from] = accountBalance - quantity;

            // Emit the Transfer/Burn event.
            // the 0x0 destination address implies a burn
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, from, address(0x0), _id, quantity);

            if (from.isContract()) {
                _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, from, _id, quantity, '');
            }
        }
    }
}