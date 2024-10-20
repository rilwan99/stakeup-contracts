// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {MessagingReceipt, MessagingFee, OFTReceipt} from "@LayerZero/oft/interfaces/IOFT.sol";

/**
 * @title ILayerZeroSettings
 * @notice An interfaces for the configuration settings and receipts for bridging using LayerZero
 */
interface ILayerZeroSettings {
    // ============================ Settings ============================

    /**
     * @notice Configuration settings to be used for bridging using LayerZero
     * @param messageSettings settings for messaging using LayerZero
     * @param refundRecipient The address to refund the excess LayerZero bridging/messaging fees to.
     *        Is an optional parameter on mainnet and can be set to address(0). Do not set
     *        this parameter to address(0) on L2 chains or you will lose the excess fees.
     */
    struct LzSettings {
        bytes options;
        MessagingFee fee;
        address refundRecipient;
    }

    /**
    struct MessagingFee {
        uint256 nativeFee;
        uint256 lzTokenFee;
    }
     */

    // ============================ Receipts ============================

    /**
     * @notice Receipts for bridging using LayerZero
     * @param msgReceipt Receipt returned for cross-chain messaging
     * @param oftReceipt Receipt returned for cross-chain OFT bridging
     */
    struct LzBridgeReceipt {
        MessagingReceipt msgReceipt;
        OFTReceipt oftReceipt;
    }

    /**
    struct MessagingReceipt {
        bytes32 guid;
        uint64 nonce;
        MessagingFee fee;
    }

    struct OFTReceipt {
        uint256 amountSentLD; // Amount of tokens ACTUALLY debited from the sender in local decimals.
        // @dev In non-default implementations, the amountReceivedLD COULD differ from this value.
        uint256 amountReceivedLD; // Amount of tokens to be received on the remote side.
    }
     */
}
