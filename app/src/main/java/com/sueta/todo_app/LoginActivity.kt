package com.sueta.todo_app

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity

class LoginActivity : AppCompatActivity() {
    private val loginViewModel: Auth by viewModels()
    private var currentLogin: String = ""
    private var currentPassword: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.login_activity)

        val loginEditText = findViewById<EditText>(R.id.loginInput)
        val passwordEditText = findViewById<EditText>(R.id.passwordInput)
        val loginButton = findViewById<Button>(R.id.loginButton)
        val registerButton = findViewById<Button>(R.id.registerButton)

        loginButton.setOnClickListener {
            val login = loginEditText.text.toString()
            val password = passwordEditText.text.toString()
            if (login.isNotEmpty() && password.isNotEmpty()) {
                currentLogin = login
                currentPassword = password
                loginViewModel.performLogin(login, password)
            } else {
                Toast.makeText(this, "Введите логин и пароль", Toast.LENGTH_SHORT).show()
            }
        }

        registerButton.setOnClickListener {
            val intent = Intent(this, RegisterActivity::class.java)
            startActivity(intent)
        }

        loginViewModel.loginResult.observe(this) { result ->
            result.fold(onSuccess = {
                Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
                val intent = Intent(this, MainActivity::class.java).apply {
                    putExtra("LOGIN", currentLogin)
                    putExtra("PASSWORD", currentPassword)
                }
                startActivity(intent)
                finish()
            }, onFailure = { Toast.makeText(this, it.message, Toast.LENGTH_SHORT).show() })
        }
    }
}
