// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentSystem {
    // Mapping from payee address to required payment amount
    mapping(address => uint256) public requiredPayments;
    // Mapping to keep track of completed payments
    mapping(address => bool) public paymentConfirmed;

    // Event to log when a payment requirement is set
    event PaymentRequested(address indexed payee, uint256 amount);
    // Event to log when a payment is completed and confirmed
    event PaymentMade(address indexed payer, address indexed payee, uint256 amount);

    // Function for the payee to set a required payment amount
    function requestPayment(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        requiredPayments[msg.sender] = amount;
        paymentConfirmed[msg.sender] = false;  // Reset any previous confirmation

        emit PaymentRequested(msg.sender, amount);
    }

    // Function for the payer to make a payment to a specific payee
    function makePayment(address payee) external payable {
        uint256 requiredAmount = requiredPayments[payee];
        
        require(requiredAmount > 0, "No payment required for this payee");
        // require(msg.value == requiredAmount, "Incorrect payment amount");

        // Mark payment as confirmed
        paymentConfirmed[payee] = true;
        
        // Transfer payment to the payee
        payable(payee).transfer(msg.value);

        emit PaymentMade(msg.sender, payee, msg.value);
    }

    // Function to check if a payment has been confirmed for a specific payee
    function isPaymentConfirmed(address payee) external view returns (bool) {
        return paymentConfirmed[payee];
    }
}
