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

class Auth : ViewModel() {
    private val client = OkHttpClient()
    private val _loginResult = MutableLiveData<Result<String>>()
    val loginResult: LiveData<Result<String>> = _loginResult
    private val _userId = MutableLiveData<String>()
    val userId: LiveData<String> = _userId

    fun performLogin(login: String, password: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val url = "http://217.71.129.139:5428/login"
                val json = JSONObject().apply {
                    put("login", login)
                    put("password", password)
                }
                val requestBody =
                    json.toString().toRequestBody("application/json; charset=utf-8".toMediaType())
                val request = Request.Builder().url(url).post(requestBody).build()
                val response = client.newCall(request).execute()

                if (response.isSuccessful) {
                    val responseBody = response.body?.string() ?: ""
                    val jsonResponse = JSONObject(responseBody)
                    val userId = jsonResponse.optString("user_id", "")

                    if (userId.isNotEmpty()) {
                        _userId.postValue(userId)
                        _loginResult.postValue(Result.success("Авторизация успешна"))
                    } else {
                        _loginResult.postValue(Result.failure(Exception("Ошибка авторизации")))
                    }
                } else {
                    _loginResult.postValue(Result.failure(Exception("Ошибка: ${response.code}")))
                }
            } catch (e: IOException) {
                _loginResult.postValue(Result.failure(Exception("Ошибка сети: ${e.message}")))
            }
        }
    }
}
