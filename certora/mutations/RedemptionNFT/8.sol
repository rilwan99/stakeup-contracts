// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {ONFT721, ERC721} from "@layerzerolabs/token/onft721/ONFT721.sol";
import {IRedemptionNFT} from "../interfaces/IRedemptionNFT.sol";
import {IStTBY} from "../interfaces/IStTBY.sol";

contract RedemptionNFT is IRedemptionNFT, ONFT721 {
    address private immutable _stTBY;
    uint256 private _mintCount;
    mapping(uint256 => WithdrawalRequest) private _withdrawalRequests;

    modifier onlyStTBY() {
        if (_msgSender() != _stTBY) revert CallerNotStTBY();
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address stTBY,
        address lzEndpoint
    ) ONFT721(name, symbol, 500000, lzEndpoint) {
        _stTBY = stTBY;
    }


/**************************** Diff Block Start ****************************
diff --git a/src/token/RedemptionNFT.sol b/src/token/RedemptionNFT.sol
index 48a2a44..5f80afe 100644
--- a/src/token/RedemptionNFT.sol
+++ b/src/token/RedemptionNFT.sol
@@ -28,7 +28,7 @@ contract RedemptionNFT is IRedemptionNFT, ONFT721 {
     function addWithdrawalRequest(
         address to,
         uint256 shares
-    ) external override onlyStTBY returns (uint256) {
+    ) external override returns (uint256) {
         uint256 tokenId = _generateNextTokenId();
 
         _withdrawalRequests[tokenId] = WithdrawalRequest({
**************************** Diff Block End *****************************/

    /// @inheritdoc IRedemptionNFT
    function addWithdrawalRequest(
        address to,
        uint256 shares
    ) external override returns (uint256) {
        uint256 tokenId = _generateNextTokenId();

        _withdrawalRequests[tokenId] = WithdrawalRequest({
            amountOfShares: shares,
            owner: to,
            claimed: false
        });

        _mint(to, tokenId);

        return tokenId;
    }

    /// @inheritdoc IRedemptionNFT
    function claimWithdrawal(uint256 tokenId) external override {
        WithdrawalRequest storage request = _withdrawalRequests[tokenId];

        if (request.owner != _msgSender()) revert NotOwner();
        if (request.claimed) revert RedemptionClaimed();

        request.claimed = true;

        IStTBY(_stTBY).withdraw(request.owner, request.amountOfShares);
    }

    // Public function for anyone to clear and deliver the remaining batch sent tokenIds
    /// @dev This function overrides clearCredits from ONFT721Core to account for the 
    ///    _creditTill2 function that is used to store the remaining credits
    function clearCredits(bytes memory _payload) external override nonReentrant {
        bytes32 hashedPayload = keccak256(_payload);
        require(storedCredits[hashedPayload].creditsRemain, "no credits stored");

        (, uint256[] memory tokenIds, uint256[] memory amountOfShares)
            = abi.decode(_payload, (bytes, uint256[], uint256[]));

        uint nextIndex = _creditTill2(
            storedCredits[hashedPayload].toAddress,
            storedCredits[hashedPayload].index,
            tokenIds,
            amountOfShares
        );
        require(nextIndex > storedCredits[hashedPayload].index, "not enough gas to process credit transfer");

        if (nextIndex == tokenIds.length) {
            // cleared the credits, delete the element
            delete storedCredits[hashedPayload];
            emit CreditCleared(hashedPayload);
        } else {
            // store the next index to mint
            storedCredits[hashedPayload] = StoredCredit(
                storedCredits[hashedPayload].srcChainId,
                storedCredits[hashedPayload].toAddress,
                nextIndex,
                true
            );
        }
    }

    /// @inheritdoc IRedemptionNFT
    function getWithdrawalRequest(
        uint256 tokenId
    ) external view override returns (WithdrawalRequest memory) {
        return _withdrawalRequests[tokenId];
    }

    /// @inheritdoc IRedemptionNFT
    function getStTBY() external view returns (address) {
        return _stTBY;
    }

    /**
     * @notice Generate the next tokenId for a new redemption NFT
     * @dev This function also increments the _mintCount by 1
     * @dev The token id is generated by hashing the chainid and the mintCount with a buffer between them
     * @dev The buffer is used to prevent collisions with the token ids generated by the ONFT721 contract
     * @return id The next tokenId
     */
    function _generateNextTokenId() internal returns (uint256 id) {
        assembly {
            let c := sload(_mintCount.slot)
            // Allocate memory for token id generation
            let x := mload(0x40)
            
            // Store the needed values for tokenId hashing in memory
            mstore(x, chainid())
            mstore(add(x, 0x20), 0x00)
            mstore(add(x, 0x40), c)

            // Increment the _mintCount by 1
            sstore(_mintCount.slot, add(c, 1))

            // Hash the memory contents to get the next token id
            id := keccak256(x, 0x60)
        }
    }

    function _transfer(address from, address to, uint256 tokenId) internal override {
        WithdrawalRequest storage request = _withdrawalRequests[tokenId];
        
        if (request.owner != from) revert NotOwner();
        if (request.claimed) revert RedemptionClaimed();

        request.owner = to;

        super._transfer(from, to, tokenId);
    }

    function _receiveRequestData(bytes memory data) internal {
        (uint256 tokenId, WithdrawalRequest memory request) 
            = abi.decode(data, (uint256, WithdrawalRequest));
        _withdrawalRequests[tokenId] = request;
    }
    
    /// Overrides ONFT721Core to allow the transfer of withdrawal request data
    function _send(
        address _from,
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint256[] memory _tokenIds,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) internal override {
        // allow 1 by default
        uint256 tokenLength = _tokenIds.length;
        require(tokenLength > 0, "tokenIds[] is empty");
        require(tokenLength == 1 || tokenLength <= dstChainIdToBatchLimit[_dstChainId], "batch size exceeds dst batch limit");

        uint256[] memory amountOfShares = new uint256[](tokenLength);

        for (uint256 i = 0; i < tokenLength; ++i) {
            // Save the data needed to send to the other chain and delete the withdrawal request from storage
            WithdrawalRequest memory request = _withdrawalRequests[_tokenIds[i]];

            amountOfShares[i] = request.amountOfShares;
            
            delete _withdrawalRequests[_tokenIds[i]];

            // Burning the NFT from the src chain with the overridden _debitFrom function
            _burnFrom(_from, _tokenIds[i]);
        }

        bytes memory payload = abi.encode(_toAddress, _tokenIds, amountOfShares);

        _checkGasLimit(_dstChainId, FUNCTION_TYPE_SEND, _adapterParams, dstChainIdToTransferGas[_dstChainId] * _tokenIds.length);
        _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
        emit SendToChain(_dstChainId, _from, _toAddress, _tokenIds);
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal virtual override {
        // decode and load the toAddress
        (bytes memory toAddressBytes, uint256[] memory tokenIds, uint256[] memory amountOfShares)
            = abi.decode(_payload, (bytes, uint256[], uint256[]));

        address toAddress;
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }

        uint256 nextIndex = _creditTill2(toAddress, 0, tokenIds, amountOfShares);
        if (nextIndex < tokenIds.length) {
            // not enough gas to complete transfers, store to be cleared in another tx
            bytes32 hashedPayload = keccak256(_payload);
            storedCredits[hashedPayload] = StoredCredit(_srcChainId, toAddress, nextIndex, true);
            emit CreditStored(hashedPayload, _payload);
        }

        emit ReceiveFromChain(_srcChainId, _srcAddress, toAddress, tokenIds);
    }

    // When a srcChain has the ability to transfer more chainIds in a single tx than the dst can do.
    // Needs the ability to iterate and stop if the minGasToTransferAndStore is not met
    // This function is a copy of the _creditTill function from ONFT721Core.sol with the following changes:
    // 1. Added amountOfShares parameter
    // 2. Removed srcChainId parameter
    // 3. Adding withdrawal request to storage
    // 4. Minor gas optimizations such as caching the tokenId length
    function _creditTill2(
        address toAddress,
        uint startIndex,
        uint256[] memory tokenIds,
        uint256[] memory amountOfShares
    ) internal returns (uint) {
        uint256 i = startIndex;
        uint256 length = tokenIds.length;

        while (i < length) {
            // if not enough gas to process, store this index for next loop
            if (gasleft() < minGasToTransferAndStore) break;

            // Add the withdrawal request to storage
            _withdrawalRequests[tokenIds[i]] = WithdrawalRequest({
                amountOfShares: amountOfShares[i],
                owner: toAddress,
                claimed: false
            });

            // Mint the new NFT on the dstChain with the overridden _creditTo function
            _mintTo(toAddress, tokenIds[i]);
            ++i;
        }

        // indicates the next index to send of tokenIds,
        // if i == tokenIds.length, we are finished
        return i;
    }

    /**
     * @notice Burns the NFT from the sender's address in order to bridge it
     * @dev This function is called by _send
     * @dev This is done to prevent having NFTs that exist without a withdrawal request
     * @param _from The address that owns the NFT and is bridging it
     * @param _tokenId The id of the NFT to be bridged
     */
    function _burnFrom(
        address _from,
        uint _tokenId
    ) internal {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ONFT721: send caller is not owner nor approved");
        require(ERC721.ownerOf(_tokenId) == _from, "ONFT721: send from incorrect owner");

        _burn(_tokenId);
    }

    /**
     * @notice Burns the NFT from the sender's address in order to bridge it
     * @dev This function is called by _creditTill2 within _nonblockingLzReceive
     * @dev This is done to prevent having NFTs that exist without a withdrawal request
     * @param toAddress The address that is receiving the bridged NFT
     * @param tokenId The id of the NFT being bridged
     */
    function _mintTo(
        address toAddress,
        uint256 tokenId
    ) internal {
        require(!_exists(tokenId), "ONFT721: token already minted");
        
        _safeMint(toAddress, tokenId);
    }
}
