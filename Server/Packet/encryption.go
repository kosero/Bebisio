package packet

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"fmt"
)

var key = []byte("16_byte_key_here") // 16, 24, or 32 bytes
var iv = []byte("16_byte_iv_here!")  // 16 bytes

func PKCS7Padding(ciphertext []byte, blockSize int) []byte {
	padding := blockSize - len(ciphertext)%blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(ciphertext, padtext...)
}

func PKCS7UnPadding(plantText []byte) ([]byte, error) {
	length := len(plantText)
	if length == 0 {
		return nil, fmt.Errorf("decryption failure: empty data")
	}
	unpadding := int(plantText[length-1])
	if unpadding > length {
		return nil, fmt.Errorf("decryption failure: invalid padding")
	}
	return plantText[:(length - unpadding)], nil
}

func Encrypt(data []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	
	paddedData := PKCS7Padding(data, block.BlockSize())
	ciphertext := make([]byte, len(paddedData))
	
	mode := cipher.NewCBCEncrypter(block, iv)
	mode.CryptBlocks(ciphertext, paddedData)
	
	return ciphertext, nil
}

func Decrypt(data []byte) ([]byte, error) {
	if len(data)%aes.BlockSize != 0 {
		return nil, fmt.Errorf("decryption failure: block size mismatch")
	}
	
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	
	plaintext := make([]byte, len(data))
	mode := cipher.NewCBCDecrypter(block, iv)
	mode.CryptBlocks(plaintext, data)
	
	unpaddedData, err := PKCS7UnPadding(plaintext)
	if err != nil {
		return nil, err
	}
	
	return unpaddedData, nil
}
