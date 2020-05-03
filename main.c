
#define n 64
#define q 256

int main(void)
{
    float public_key;
    float private_key;
    float encrypted_message;
    float decrypted_message;
    int m;

    fscanf("%d", m);
    public_key = key_gen();
    private_key = key_gen();

    encrypted_message = encrypt(m, public_key);
    decrypted_message = decrypt(encrypted_message, private_key);

    printf("Message: %d", m);
    printf("Public Key: %f", public_key);
    printf("Private Key: %f", private_key);
    printf("Encrypted Message: %f", encrypted_message);
    printf("Decrypted Message: %d", decrypted_message);
}