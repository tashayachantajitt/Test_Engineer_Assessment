def simpleCipher(encrypted, k):
    decrypted = ""
    for char in encrypted:
        # 1. convert char to num  0-25 (A=0, B=1, ..., Z=25)
        # ord('A') คือ 65
        current_pos = ord(char) - ord('A')
        
        # 2. move to k  (using % 26 for can start from A back to Z)
        new_pos = (current_pos - k) % 26
        
        # 3. convert to char
        decrypted += chr(new_pos + ord('A'))
        
    return decrypted

if __name__ == "__main__":
    encrypted_str = 'VTAOG'
    k_value = 2
    
    result = simpleCipher(encrypted_str, k_value)
    print(f"Decrypted Result: {result}")