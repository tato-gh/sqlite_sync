// Hook for cryption
//
// refs:
// - https://developer.mozilla.org/ja/docs/Web/API/Web_Crypto_API
// - https://www.clear-code.com/blog/2019/1/30.html

const genKey = async function(salt_raw, pass_raw) {
  // 文字列をTyped Arrayに変換
  const salt = (new TextEncoder()).encode(salt_raw)
  const passwordUint8Array = (new TextEncoder()).encode(pass_raw)

  // パスワードのハッシュ値を計算
  const digest = await crypto.subtle.digest(
    { name: 'SHA-256' },
    passwordUint8Array
  )

  // 鍵素材化
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    digest,
    { name: 'PBKDF2' },
    // export可否
    false,
    // 鍵用途
    ['deriveKey']
  )

  // 鍵生成
  const key = await crypto.subtle.deriveKey(
    // 導出アルゴリズムのオブジェクト
    {
      name: 'PBKDF2',
      salt: salt,
      iterations: 100,
      hash: 'SHA-256'
    },
    // 鍵素材
    keyMaterial,
    // 鍵導出アルゴリズム
    {
      name: 'AES-GCM',
      length: 256
    },
    // export可否
    false,
    // 鍵用途
    ['encrypt', 'decrypt']
  )

  return key
}

const Cryption = {
  mounted() {
    const salt = 'keysalt'
    const pass = this.el.dataset.pass
    delete this.el.dataset.salt
    delete this.el.dataset.pass

    // setup
    genKey(salt, pass)
    .then(key => {
      this.key = key
    })

    // handler
    this.handleEvent("encode", async (payload) => {
      const inputData = (new TextEncoder()).encode(payload.raw)
      const iv = crypto.getRandomValues(new Uint8Array(16))
      const ivBytes = Array.from(new Uint8Array(iv), char => String.fromCharCode(char)).join('')
      const ivBase64String = btoa(ivBytes)

      // 暗号化
      const encryptedArrayBuffer = await crypto.subtle.encrypt(
        {name: 'AES-GCM', iv},
        this.key,
        inputData
      )

      // 暗号化内容取得
      const encryptedBytes = Array.from(new Uint8Array(encryptedArrayBuffer), char => String.fromCharCode(char)).join('')
      const encryptedBase64String = btoa(encryptedBytes)

      // 初期化ベクトルと暗号文の結合
      const encrypted = ivBase64String + "-" + encryptedBase64String

      this.pushEvent("encrypted", {
        encrypted: encrypted,
        options: payload.options
      })
    })

    this.handleEvent("decode", async (payload) => {
      const splits = payload.encrypted.split("-")
      const ivBase64String = splits[0]
      const encryptedBase64String = splits[1]

      // Base64エンコードされた文字列 -> Binary String
      const ivBytes = atob(ivBase64String)
      const encryptedBytes = atob(encryptedBase64String)

      // Binary String -> Typed array
      const iv = Uint8Array.from(ivBytes.split(''), char => char.charCodeAt(0))
      const encryptedData = Uint8Array.from(encryptedBytes.split(''), char => char.charCodeAt(0))

      // 復号化
      const decryptedArrayBuffer = await crypto.subtle.decrypt(
        { name: 'AES-GCM', iv },
        this.key,
        encryptedData
      )

      decrypted = (new TextDecoder()).decode(new Uint8Array(decryptedArrayBuffer))

      this.pushEvent("decrypted", {
        raw: decrypted,
        options: payload.options
      })
    })
  }
}

export default Cryption
