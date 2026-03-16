import CryptoJS from 'crypto-js'

/**
 * Encrypts a string using AES with a given key.
 */
export function encryptMessage(content, key) {
    if (!key || !content) return content
    try {
        // We prepend a prefix so we can detect if a message is encrypted
        const encrypted = CryptoJS.AES.encrypt(content, key).toString()
        return `U2FsdGVkX1${encrypted}` // CryptoJS default prefix is often this, but we'll make it explicit
    } catch (e) {
        console.error('Encryption failing', e)
        return content
    }
}

/**
 * Decrypts a string using AES with a given key.
 */
export function decryptMessage(encryptedContent, key) {
    if (!key || !encryptedContent) return encryptedContent
    
    // Check if it looks like an encrypted string
    if (!encryptedContent.startsWith('U2FsdGVkX1')) {
        return encryptedContent
    }

    try {
        const rawCipher = encryptedContent.substring(10)
        const bytes = CryptoJS.AES.decrypt(rawCipher, key)
        const decrypted = bytes.toString(CryptoJS.enc.Utf8)
        
        if (!decrypted) throw new Error('Decryption resulted in empty string')
        return decrypted
    } catch (e) {
        // If decryption fails, return a placeholder
        console.warn('Decryption failed for message')
        return '🔒 [Encrypted Message]'
    }
}
