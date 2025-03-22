package com.sueta.todo_app

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity

class RegisterActivity : AppCompatActivity() {
    private val registerViewModel: Register by viewModels()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.register_activity)

        val loginEditText = findViewById<EditText>(R.id.loginInput)
        val passwordEditText = findViewById<EditText>(R.id.passwordInput)
        val registerButton = findViewById<Button>(R.id.registerButton)
        val loginButton = findViewById<Button>(R.id.loginButton)

        registerButton.setOnClickListener {
            val login = loginEditText.text.toString()
            val password = passwordEditText.text.toString()

            if (login.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Заполните все поля", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            if (password.length < 8) {
                Toast.makeText(this, "Пароль должен быть не менее 8 символов", Toast.LENGTH_SHORT)
                    .show()
                return@setOnClickListener
            }
            registerViewModel.performRegistration(login, password)
        }

        loginButton.setOnClickListener {
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }

        registerViewModel.registerResult.observe(this) { result ->
            result.fold(onSuccess = { message ->
                Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
                startActivity(Intent(this, LoginActivity::class.java))
                finish()
            }, onFailure = { error ->
                Toast.makeText(this, error.message, Toast.LENGTH_SHORT).show()
            })
        }
    }
}
