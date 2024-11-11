import random
import json

class SimpleHomomorphicEncryption:
    def __init__(self, key):
        self.key = key

    def encrypt(self, plaintext):
        # Encrypt the plaintext by adding the key
        return plaintext * key

    def decrypt(self, ciphertext):
        # Decrypt the ciphertext by subtracting the key
        return ciphertext // key

    def add_encrypted(self, encrypted1, encrypted2):
        # Sum the two encrypted values
        return encrypted1 + encrypted2


def generate_key():
    return random.randint(10000, 1000000)  # Choose a random key between 2 and 100

# Example usage
if __name__ == "__main__":
    import sys

    # Ensure exactly 5 numbers are provided
    if len(sys.argv) != 6:
        print("Please provide exactly 5 numbers.")
        sys.exit(1)

    transactions = [int(arg) for arg in sys.argv[1:6]]

    HOW_MANY = 10
    key = generate_key()  # The encryption key
    he = SimpleHomomorphicEncryption(key)

    # Original numbers
    #transactions = [10, 15, 20, -10, 10]
    random.shuffle(transactions)
    cleartext_amounts = [] #transactions

    for t in transactions:
        if t > 0:
            cleartext_amounts.append(t)
        else:
            cleartext_amounts.append(21888242871839275222246405745257275088548364400416034343698204186575808495617 + t)

    clear_sum = sum(cleartext_amounts)

    encrypted = [he.encrypt(i) for i in cleartext_amounts]

    #enc_sum = encrypted[0]
    #for i in range(1, HOW_MANY):
    #    enc_sum = he.add_encrypted(enc_sum, encrypted[i])
    enc_sum = sum(encrypted)

    dec_sum = he.decrypt(enc_sum)

    if clear_sum == dec_sum:
        
        input_args = " ".join([str(i) for i in [key, 
              cleartext_amounts[0], cleartext_amounts[1], cleartext_amounts[2], cleartext_amounts[3], cleartext_amounts[4],
              clear_sum,
              encrypted[0], encrypted[1], encrypted[2], encrypted[3], encrypted[4],
              enc_sum]])

        print(input_args)
        with open("args.txt", "w") as f:
            f.write(input_args)
              

        # to_save = {
        #     "clear": cleartext_amounts,
        #     "clear_sum": clear_sum,
        #     "encrypted": encrypted,
        #     "enc_sum": enc_sum,
        #     "key": key,
        # }
        # 
        # with open("transactions.json", "w") as f:
        #     f.write(json.dumps(to_save))
        #     
        # print(cleartext_amounts)
        # print(to_save)
    else:
        print("Something went wrong")