
[gen_key]

echo "Generating ssh key..."

cd ~/.ssh
ssh-keygen

[cp_key1]

echo "Copying public key to remote server..."

echo <%= user %>
echo <%= host %>

scp ~/.ssh/id_rsa.pub <%= user %>@<%= host %>:~/pubkey.txt

[cp_key2]

mkdir -p ~/.ssh
chmod 700 .ssh
cat pubkey.txt >> ~/.ssh/authorized_keys
rm ~/pubkey.txt
chmod 600 ~/.ssh/*