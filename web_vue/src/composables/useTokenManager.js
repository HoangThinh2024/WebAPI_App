/**
 * Token Manager Composable
 * Quản lý token với encryption và expiry
 */

import { ref, computed } from 'vue'
import CryptoJS from 'crypto-js'

const STORAGE_KEYS = {
  TOKEN: 'base_access_token',
  TOKEN_ENCRYPTED: 'base_access_token_encrypted',
  TOKEN_EXPIRY: 'base_access_token_expiry',
  BACKEND_URL: 'base_backend_url',
  ENCRYPTION_ENABLED: 'base_encryption_enabled'
}

// Secret key cho encryption (trong production nên dùng key phức tạp hơn)
const ENCRYPTION_KEY = 'BASE_VN_SECRET_2025'

// Token expiry default: 24 hours
const DEFAULT_EXPIRY_HOURS = 24

export function useTokenManager() {
  const encryptionEnabled = ref(
    localStorage.getItem(STORAGE_KEYS.ENCRYPTION_ENABLED) === 'true'
  )

  /**
   * Mã hóa token bằng AES
   */
  function encryptToken(token) {
    try {
      return CryptoJS.AES.encrypt(token, ENCRYPTION_KEY).toString()
    } catch (error) {
      console.error('Encryption error:', error)
      return token
    }
  }

  /**
   * Giải mã token
   */
  function decryptToken(encryptedToken) {
    try {
      const bytes = CryptoJS.AES.decrypt(encryptedToken, ENCRYPTION_KEY)
      return bytes.toString(CryptoJS.enc.Utf8)
    } catch (error) {
      console.error('Decryption error:', error)
      return encryptedToken
    }
  }

  /**
   * Lưu token vào localStorage
   */
  function saveToken(token, backendUrl = null, expiryHours = DEFAULT_EXPIRY_HOURS) {
    if (!token) {
      throw new Error('Token không được để trống')
    }

    // Lưu token
    if (encryptionEnabled.value) {
      const encrypted = encryptToken(token)
      localStorage.setItem(STORAGE_KEYS.TOKEN_ENCRYPTED, encrypted)
      localStorage.removeItem(STORAGE_KEYS.TOKEN) // Xóa plain token
    } else {
      localStorage.setItem(STORAGE_KEYS.TOKEN, token)
      localStorage.removeItem(STORAGE_KEYS.TOKEN_ENCRYPTED) // Xóa encrypted token
    }

    // Lưu backend URL
    if (backendUrl) {
      localStorage.setItem(STORAGE_KEYS.BACKEND_URL, backendUrl)
    }

    // Lưu expiry timestamp
    const expiryTime = Date.now() + expiryHours * 60 * 60 * 1000
    localStorage.setItem(STORAGE_KEYS.TOKEN_EXPIRY, expiryTime.toString())

    // Lưu encryption setting
    localStorage.setItem(
      STORAGE_KEYS.ENCRYPTION_ENABLED,
      encryptionEnabled.value.toString()
    )

    return {
      success: true,
      expiryTime,
      encrypted: encryptionEnabled.value
    }
  }

  /**
   * Lấy token từ localStorage
   */
  function getToken() {
    // Check expiry first
    if (isTokenExpired()) {
      clearToken()
      return null
    }

    // Lấy encrypted token nếu có
    const encrypted = localStorage.getItem(STORAGE_KEYS.TOKEN_ENCRYPTED)
    if (encrypted) {
      return decryptToken(encrypted)
    }

    // Lấy plain token
    return localStorage.getItem(STORAGE_KEYS.TOKEN)
  }

  /**
   * Lấy backend URL
   */
  function getBackendUrl() {
    return localStorage.getItem(STORAGE_KEYS.BACKEND_URL)
  }

  /**
   * Kiểm tra token có expired không
   */
  function isTokenExpired() {
    const expiryTime = localStorage.getItem(STORAGE_KEYS.TOKEN_EXPIRY)
    if (!expiryTime) return false

    return Date.now() > parseInt(expiryTime)
  }

  /**
   * Lấy thời gian còn lại của token (milliseconds)
   */
  function getTimeRemaining() {
    const expiryTime = localStorage.getItem(STORAGE_KEYS.TOKEN_EXPIRY)
    if (!expiryTime) return null

    const remaining = parseInt(expiryTime) - Date.now()
    return remaining > 0 ? remaining : 0
  }

  /**
   * Format thời gian còn lại thành string
   */
  function formatTimeRemaining() {
    const ms = getTimeRemaining()
    if (ms === null) return 'Không giới hạn'
    if (ms === 0) return 'Đã hết hạn'

    const hours = Math.floor(ms / (1000 * 60 * 60))
    const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60))

    if (hours > 0) {
      return `${hours} giờ ${minutes} phút`
    }
    return `${minutes} phút`
  }

  /**
   * Xóa token và các dữ liệu liên quan
   */
  function clearToken() {
    localStorage.removeItem(STORAGE_KEYS.TOKEN)
    localStorage.removeItem(STORAGE_KEYS.TOKEN_ENCRYPTED)
    localStorage.removeItem(STORAGE_KEYS.TOKEN_EXPIRY)
    // Không xóa BACKEND_URL và ENCRYPTION_ENABLED để giữ settings
  }

  /**
   * Xóa tất cả dữ liệu
   */
  function clearAll() {
    Object.values(STORAGE_KEYS).forEach((key) => {
      localStorage.removeItem(key)
    })
    encryptionEnabled.value = false
  }

  /**
   * Toggle encryption
   */
  function toggleEncryption() {
    const currentToken = getToken()
    encryptionEnabled.value = !encryptionEnabled.value

    // Re-save token with new encryption setting
    if (currentToken) {
      const backendUrl = getBackendUrl()
      const expiryTime = localStorage.getItem(STORAGE_KEYS.TOKEN_EXPIRY)

      // Calculate remaining hours
      let remainingHours = DEFAULT_EXPIRY_HOURS
      if (expiryTime) {
        const remaining = parseInt(expiryTime) - Date.now()
        remainingHours = Math.max(1, Math.ceil(remaining / (1000 * 60 * 60)))
      }

      saveToken(currentToken, backendUrl, remainingHours)
    } else {
      localStorage.setItem(
        STORAGE_KEYS.ENCRYPTION_ENABLED,
        encryptionEnabled.value.toString()
      )
    }
  }

  /**
   * Lấy token info để hiển thị
   */
  function getTokenInfo() {
    const token = getToken()
    const hasToken = !!token
    const expired = isTokenExpired()
    const timeRemaining = getTimeRemaining()
    const encrypted = !!localStorage.getItem(STORAGE_KEYS.TOKEN_ENCRYPTED)

    return {
      hasToken,
      expired,
      timeRemaining,
      timeRemainingFormatted: formatTimeRemaining(),
      encrypted,
      tokenPreview: token ? `${token.substring(0, 10)}...${token.substring(token.length - 6)}` : null
    }
  }

  return {
    encryptionEnabled,
    saveToken,
    getToken,
    getBackendUrl,
    isTokenExpired,
    getTimeRemaining,
    formatTimeRemaining,
    clearToken,
    clearAll,
    toggleEncryption,
    getTokenInfo
  }
}
