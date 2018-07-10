# CoreDataEncryption
**CoreDataEncryption** is static library to encrypt Core Data.

## Dependencies
* [Encrypted Core Data] (https://github.com/project-imas/encrypted-core-data)
* [SQLCipher] (https://github.com/sqlcipher/sqlcipher)

Note :- *All dependencies are managed by git submodule*

## Project Configuration Highlights
* Header Search Path is set to submodule of sqlcipher ```$(PROJECT_DIR)/submodule/sqlcipher```
* Public Headers Folder Path is ```include/CoreDataEncryption```
* Other C Flags are set to ```-DSQLITE_HAS_CODEC``` and ```-DSQLCIPHER_CRYPTO_CC```

## Project set up Instruction
* ```git submodule init```
* ```git submodule update --recursive```

## Project Build (From root project folder)
* ```cd scripts/```
* ```./release```

## Build location
**release folder```

### Notes to developer
Please Update CHANGELOG if making major changes in project.
