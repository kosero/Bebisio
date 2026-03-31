extends Node

var aes := AESContext.new()
var key := "16_byte_key_here".to_utf8_buffer()
var iv := "16_byte_iv_here!".to_utf8_buffer()


func encrypt(data: PackedByteArray) -> PackedByteArray:
	var padded := _pkcs7_pad(data, 16)
	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	var res := aes.update(padded)
	aes.finish()
	return res


func decrypt(data: PackedByteArray) -> PackedByteArray:
	if data.is_empty() or data.size() % 16 != 0:
		return PackedByteArray()

	aes.start(AESContext.MODE_CBC_DECRYPT, key, iv)
	var res := aes.update(data)
	aes.finish()
	return _pkcs7_unpad(res)


func _pkcs7_pad(data: PackedByteArray, block_size: int) -> PackedByteArray:
	var padding := block_size - (data.size() % block_size)
	var res := data.duplicate()
	for i in range(padding):
		res.append(padding)
	return res


func _pkcs7_unpad(data: PackedByteArray) -> PackedByteArray:
	if data.is_empty():
		return data

	var padding := data[data.size() - 1]
	if padding > 16 or padding > data.size():
		return data

	for i in range(data.size() - padding, data.size()):
		if data[i] != padding:
			return data

	return data.slice(0, data.size() - padding)
