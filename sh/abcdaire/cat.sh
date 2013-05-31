cat > /myfile << "EOF"
#!/bin/sh
# Begin /myfile

exec /myfile -l "$@"

# End /myfile
EOF
chmod -v 755 /myfile
