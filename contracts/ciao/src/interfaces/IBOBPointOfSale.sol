// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BitcoinTx} from "@bob-collective/bob/utils/BitcoinTx.sol";
import "../HelloBitcoin.sol";

/**
 * @title IBOBPointOfSale
 * @dev Interface for the Bitcoin to USDC Point-of-Sale contract.
 */
interface IBOBPointOfSale {
    /**
     * @dev Event emitted when a payment is initialized.
     * @param paymentId Unique identifier of the payment.
     * @param btcAmount Amount of BTC required for the order.
     * @param usdcAmount Amount of USDC equivalent for the payment.
     * @param buyer Address of the buyer initiating the payment.
     */
    event PaymentInitialized(uint256 indexed paymentId, uint256 btcAmount, uint256 usdcAmount, address buyer);

    /**
     * @dev Event emitted when a payment is successfully completed.
     * @param paymentId Unique identifier of the payment.
     * @param buyer Address of the buyer who completed the payment.
     */
    event PaymentCompleted(uint256 indexed paymentId, address buyer);

    /**
     * @dev Event emitted when a payment is refunded to the buyer.
     * @param paymentId Unique identifier of the refunded payment.
     * @param buyer Address of the buyer who received the refund.
     */
    event PaymentRefunded(uint256 indexed paymentId, address buyer);

    /**
     * @dev Event emitted when funds are withdrawn by the seller.
     * @param seller Address of the seller receiving the withdrawn funds.
     * @param amount Amount of USDC withdrawn.
     */
    event FundsWithdrawn(address indexed seller, uint256 amount);

    /**
     * @dev Initializes a payment with the specified BTC and USDC amounts.
     * @param btcAmount Amount of BTC required for the order.
     * @param usdcAmount Amount of USDC equivalent for the payment.
     */
    function initializePayment(uint256 btcAmount, uint256 usdcAmount) external;

    /**
     * @dev Completes a payment by finalizing the BTC sell order on HelloBitcoin.
     * @param paymentId Unique identifier of the payment.
     * @param orderId Order ID from HelloBitcoin for the BTC sell order.
     * @param transaction Bitcoin transaction details.
     * @param proof Bitcoin transaction proof.
     */
    function completePayment(
        uint256 paymentId,
        uint256 orderId,
        BitcoinTx.Info calldata transaction,
        BitcoinTx.Proof calldata proof
    ) external;

    /**
     * @dev Refunds a payment, allowing the seller to send back the USDC equivalent to the buyer.
     * @param paymentId Unique identifier of the payment to refund.
     */
    function refundPayment(uint256 paymentId) external;

    /**
     * @dev Allows the seller to withdraw all remaining USDC funds in the contract.
     */
    function withdrawFunds() external;
}
