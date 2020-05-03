
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

    printf("%d", decrypted_message);
}