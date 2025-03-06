#!/bin/sh

echo "🔐 Loading encryption settings from .gitattributes..."

# Extract file patterns to encrypt
ENCRYPTED_FILES=$(grep 'filter=zip-crypto' .gitattributes | awk '{print $1}')

# Extract user emails for encryption
ENCRYPTION_USERS=$(grep 'ENCRYPTION_USERS=' .gitattributes | cut -d= -f2 | tr ',' ' ')

if [[ -z "$ENCRYPTION_USERS" ]]; then
    echo "⚠️ No encryption users found in .gitattributes! Exiting..."
    exit 1
fi

# Import all GPG keys from .git-keys/
echo "📥 Importing GPG public keys..."
for key in .git-keys/*.asc; do
    if [ -f "$key" ]; then
        echo "  - Importing $key..."
        gpg --import --trust-model always "$key" 
    fi
done

# Generate the encryption command dynamically
ENCRYPT_COMMAND="gpg --batch --yes --encrypt"
for user in $ENCRYPTION_USERS; do
    ENCRYPT_COMMAND+=" --recipient $user"
done

# Apply Git filters dynamically
echo "⚙ Configuring Git filters..."
git config --local "filter.safe-git.clean" "$ENCRYPT_COMMAND"
git config --local "filter.safe-git.smudge" "gpg --batch --yes --decrypt"

# Ensure .gitattributes is tracked
git add .gitattributes

echo "✅ Encryption setup complete!"
