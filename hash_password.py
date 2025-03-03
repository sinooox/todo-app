import hashlib
import os
from insert import insert_data


#функция хеширование пароля при регистрации пользователя
def get_hashed_password(password, salt):
    if salt is None:
        salt = os.urandom(32)  # Генерируем 32 байта случайной соли
    key = hashlib.pbkdf2_hmac(
        'sha256',                # Алгоритм хеширования
        password.encode('utf-8'),# Преобразуем пароль в байты
        salt,                    # Соль
        100000                   # Количество итераций (рекомендуется не менее 100000)
    )
    return key, salt


#функция верификации пароля пользователя
def verify_password(stored_hash: bytes, stored_salt: bytes, provided_password: str) -> bool:
    
    if isinstance(stored_hash, str) and stored_hash.startswith('\\x'):
        stored_hash = bytes.fromhex(stored_hash[2:])
    if isinstance(stored_salt, str) and stored_salt.startswith('\\x'):
        stored_salt = bytes.fromhex(stored_salt[2:])

    new_key = hashlib.pbkdf2_hmac(
        'sha256',
        provided_password.encode('utf-8'),
        stored_salt,
        100000
    )
    return new_key == stored_hash
