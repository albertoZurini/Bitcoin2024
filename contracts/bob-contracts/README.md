# BOB Crypto Point of Sale

## Overview

The BOBPointOfSale is a POS system to accept BTC payments and issue USDC the equivalent stablecoin. This contract leverages the pre-existing HelloBitcoin contract template for verifying Bitcoin transactions. It is built specifically for BOB and how its bridge works.

The reason behind bridging directly to USDC is simple: it makes our FHE tax accountancy much more usable by businesses and governments alike.

## Details

### Key Structs
- Payment: Stores details for each payment, including BTC and USDC amounts, buyer information, and payment status.

### State Variables
- helloBitcoin: Address of the HelloBitcoin contract used for BTC verification.
- usdcToken: Address of the USDC token contract.
- seller: Address of the seller (who receives USDC).
- payments: Mapping to store each payment's details.
- nextPaymentId: Counter to generate unique payment IDs.

### Usage
#### Initialize Payment:

A buyer calls initializePayment with the BTC and USDC amounts for their purchase.
Generates a new paymentId for tracking.

#### Complete Payment:

Buyer provides proof of their BTC transaction using completePayment.
HelloBitcoin verifies the transaction; upon success, the contract transfers USDC to the seller.
#### Refund Payment:

Seller can refund any unpaid payment by calling refundPayment.
#### Withdraw Funds:

Seller can withdraw all remaining USDC in the contract via withdrawFunds.
### Events
- PaymentInitialized(uint256 paymentId, uint256 btcAmount, uint256 usdcAmount, address buyer): Emitted when a payment is initialized by a buyer.
- PaymentCompleted(uint256 paymentId, address buyer): Emitted when a payment is successfully completed.
- PaymentRefunded(uint256 paymentId, address buyer): Emitted when a payment is refunded.
- FundsWithdrawn(address seller, uint256 amount): Emitted when the seller withdraws funds.
### Functions
```sol
constructor(HelloBitcoin _helloBitcoin, IERC20 _usdcToken, address _seller)
```
Sets up the contract with the HelloBitcoin and USDC token addresses, and assigns the seller address.

```
function initializePayment(uint256 btcAmount, uint256 usdcAmount) external override
```
Initializes a new payment with specified BTC and USDC amounts.

completePayment
solidity
```
function completePayment(
    uint256 paymentId,
    uint256 orderId,
    BitcoinTx.Info calldata transaction,
    BitcoinTx.Proof calldata proof
) external override
```
Finalizes the payment if the BTC transaction is verified by HelloBitcoin. Transfers USDC to the seller upon success.

```
function refundPayment(uint256 paymentId) external override onlySeller
```
Allows the seller to refund a buyer if the payment is not marked as complete.

```
function withdrawFunds() external override onlySeller
```
Transfers any remaining USDC in the contract to the seller's address.

Security Considerations
Access Control: Only the designated seller can call refundPayment and withdrawFunds.
BTC Verification: Relies on HelloBitcoin for the secure validation of BTC transactions.
Safe Transfers: Uses OpenZeppelin's SafeERC20 to avoid issues with token transfers.

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```

### Deploy
```
export PRIVATE_KEY=0x<your-private-key>
export USDT_ADDRESS=0xF58de5056b7057D74f957e75bFfe865F571c3fB6
export RPC_URL=https://testnet.rpc.gobob.xyz
export VERIFIER_URL=https://testnet-explorer.gobob.xyz/api?

forge script script/HelloBitcoin.sol --rpc-url=$RPC_URL --broadcast \
--verify --verifier blockscout --verifier-url=$VERIFIER_URL \
--priority-gas-price 1

```

### Deployed Addresses
relay: `0xb364BE5B065eb435Ef9B911ad81F07897657E505`
hello bitcoin: `0x8d38Ce9c6721Af5Aac01Fe7227944476d096b3B5`
bob pos: `0x1D808dFE4271B4eF7fb3DaB96a34639683A673dD`

### Interacting
To interact with the contracts, run: (amend the variables as necessary):

```
cast send 0x1D808dFE4271B4eF7fb3DaB96a34639683A673dD "initializePayment(uint256,uint256)" 1000 1000000 --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY
cast send 0x8d38Ce9c6721Af5Aac01Fe7227944476d096b3B5 "acceptBtcSellOrder(uint256,bytes)" 1 0x00 --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY
cast send 0x1D808dFE4271B4eF7fb3DaB96a34639683A673dD "completePayment(uint256,uint256,bytes4, bytes, bytes, bytes4,bytes,uint256,bytes) 1 1 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY

```