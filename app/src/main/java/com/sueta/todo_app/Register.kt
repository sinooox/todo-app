package com.sueta.todo_app

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException

class Register : ViewModel() {
    private val client = OkHttpClient()
    private val _registerResult = MutableLiveData<Result<String>>()
    val registerResult: LiveData<Result<String>> = _registerResult

    fun performRegistration(login: String, password: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val url = "http://217.71.129.139:5428/register"
                val json = JSONObject().apply {
                    put("login", login)
                    put("password", password)
                }
                val requestBody =
                    json.toString().toRequestBody("application/json; charset=utf-8".toMediaType())
                val request = Request.Builder().url(url).post(requestBody).build()
                val response = client.newCall(request).execute()

                if (response.isSuccessful) {
                    _registerResult.postValue(Result.success("Регистрация успешна, перенаправляем на вход"))
                } else {
                    _registerResult.postValue(Result.failure(Exception("Ошибка регистрации: ${response.code}")))
                }
            } catch (e: IOException) {
                _registerResult.postValue(Result.failure(Exception("Ошибка сети: ${e.message}")))
            }
        }
    }
}
