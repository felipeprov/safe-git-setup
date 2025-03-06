#!/bin/sh
old_file="$1"
new_file="$2"

# If the old file exists in Git history, decrypt it
if [ -f "$old_file" ]; then
    gpg --quiet --batch --yes --decrypt "$old_file" 2>/dev/null > "$old_file.decrypted" || cp "$old_file" "$old_file.decrypted"
else
    touch "$old_file.decrypted"
fi

# If the new file exists on disk (already decrypted due to smudge filter), use it directly
if [ -f "$new_file" ]; then
    cp "$new_file" "$new_file.decrypted"
else
    touch "$new_file.decrypted"
fi

# Run diff on the decrypted files
diff -u "$old_file.decrypted" "$new_file.decrypted"

# Cleanup temporary files
rm -f "$old_file.decrypted" "$new_file.decrypted"

