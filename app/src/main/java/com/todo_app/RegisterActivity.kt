package com.todo_app

import android.content.Intent
import android.os.Bundle
import android.widget.EditText
import android.widget.ImageView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class RegisterActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)  // Используйте правильный макет для регистрации

        val etLogin = findViewById<EditText>(R.id.et_login)
        val etPassword = findViewById<EditText>(R.id.et_password)
        val btnLogin = findViewById<ImageView>(R.id.btn_login)
        val btnRegister = findViewById<ImageView>(R.id.btn_register)

        // Логика для кнопки "Вход"
        btnLogin.setOnClickListener {
            val login = etLogin.text.toString().trim()
            val password = etPassword.text.toString().trim()

            if (login.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Введите логин и пароль", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Вход выполнен", Toast.LENGTH_SHORT).show()
                // Переход на другой экран после успешного входа
                val intent = Intent(this, HomeActivity::class.java)
                startActivity(intent)
            }
        }

        // Логика для кнопки "Регистрация"
        btnRegister.setOnClickListener {
            val intent = Intent(this, LoginActivity::class.java)
            startActivity(intent)
        }
    }
}
