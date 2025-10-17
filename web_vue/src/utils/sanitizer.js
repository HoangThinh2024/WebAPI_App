// HTML Sanitizer utility using DOMPurify
import DOMPurify from 'dompurify'

/**
 * Sanitize HTML content to prevent XSS attacks
 * @param {string} dirty - Unsanitized HTML string
 * @param {object} config - DOMPurify configuration
 * @returns {string} - Sanitized HTML string
 */
export function sanitizeHTML(dirty, config = {}) {
  const defaultConfig = {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'u', 'a', 'ul', 'ol', 'li', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'div', 'span'],
    ALLOWED_ATTR: ['href', 'target', 'class', 'style'],
    ALLOW_DATA_ATTR: false
  }
  
  return DOMPurify.sanitize(dirty, { ...defaultConfig, ...config })
}

/**
 * Create a safe HTML render function for Vue
 * Usage: v-html="safeHTML(content)"
 */
export function useSafeHTML() {
  return {
    safeHTML: (html) => sanitizeHTML(html)
  }
}
