// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IBOBPointOfSale.sol";
import "./HelloBitcoin.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

using SafeERC20 for IERC20;

/**
 * @title BOBPointOfSale
 * @dev Point-of-Sale contract for BTC to USDC payments, utilizing HelloBitcoin for BTC verification.
 */
contract BOBPointOfSale is IBOBPointOfSale {
    HelloBitcoin public helloBitcoin;
    IERC20 public usdcToken;
    address public seller;

    struct Payment {
        uint256 btcAmount;
        uint256 usdcAmount;
        address buyer;
        bool isPaid;
        bool isRefunded;
    }

    mapping(uint256 => Payment) public payments;
    uint256 public nextPaymentId;

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can perform this action");
        _;
    }

    /**
     * @dev Constructor to initialize contract with HelloBitcoin and USDC token addresses.
     * @param _helloBitcoin Address of the deployed HelloBitcoin contract.
     * @param _usdcToken Address of the USDC token contract.
     * @param _seller Address of the seller for withdrawals and refunds.
     */
    constructor(HelloBitcoin _helloBitcoin, IERC20 _usdcToken, address _seller) {
        helloBitcoin = _helloBitcoin;
        usdcToken = _usdcToken;
        seller = _seller;
    }

    /**
     * @inheritdoc IBOBPointOfSale
     */
    function initializePayment(uint256 btcAmount, uint256 usdcAmount) external override {
        uint256 paymentId = nextPaymentId++;
        
        payments[paymentId] = Payment({
            btcAmount: btcAmount,
            usdcAmount: usdcAmount,
            buyer: msg.sender,
            isPaid: false,
            isRefunded: false
        });

        emit PaymentInitialized(paymentId, btcAmount, usdcAmount, msg.sender);
    }

    /**
     * @inheritdoc IBOBPointOfSale
     */
    function completePayment(
        uint256 paymentId,
        uint256 orderId,
        BitcoinTx.Info calldata transaction,
        BitcoinTx.Proof calldata proof
    ) external override {
        Payment storage payment = payments[paymentId];
        require(payment.buyer == msg.sender, "Only buyer can complete payment");
        require(!payment.isPaid, "Payment already completed");
        require(!payment.isRefunded, "Payment already refunded");

        // Complete the BTC sell order in HelloBitcoin
        helloBitcoin.completeBtcSellOrder(orderId, transaction, proof);
        
        // Mark payment as completed and transfer USDC to the seller
        payment.isPaid = true;
        usdcToken.safeTransfer(seller, payment.usdcAmount);
        
        emit PaymentCompleted(paymentId, msg.sender);
    }

    /**
     * @inheritdoc IBOBPointOfSale
     */
    function refundPayment(uint256 paymentId) external override onlySeller {
        Payment storage payment = payments[paymentId];
        require(!payment.isPaid, "Cannot refund a completed payment");
        require(!payment.isRefunded, "Payment already refunded");

        payment.isRefunded = true;
        usdcToken.safeTransfer(payment.buyer, payment.usdcAmount);
        
        emit PaymentRefunded(paymentId, payment.buyer);
    }

    /**
     * @inheritdoc IBOBPointOfSale
     */
    function withdrawFunds() external override onlySeller {
        uint256 balance = usdcToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");

        usdcToken.safeTransfer(seller, balance);
        emit FundsWithdrawn(seller, balance);
    }
}
