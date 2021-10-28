# Readme.md - XRC1155

This repository contains the contracts for implementation of XRC1155 semi-fungible token, which
conforms to EIP-1155: Multi Token Standard for EVM compatible XDC network.

XRC1155.sol is the base implementation of XRC1155 semi-fungible token.

XRC1155Mintable.sol extends base XRC1155.sol to provide mint and burn facilities.

Note :: For Ethereum Interface support and Wallet compatibility 
ERC165.sol and IERC1155TokenReceiver.sol is kept unchanged.
For further understanding refer to -
https://medium.com/yodaplus/how-to-implement-semi-fungible-token-in-xdc-network-xrc1155-73b1973dfc8f
