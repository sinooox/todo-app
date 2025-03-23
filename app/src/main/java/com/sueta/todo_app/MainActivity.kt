package com.sueta.todo_app

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.util.Base64
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class MainActivity : AppCompatActivity() {
    private lateinit var noteApi: NoteApi
    private lateinit var noteAdapter: NoteAdapter
    private lateinit var authHeader: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main_activity)

        val recyclerView = findViewById<RecyclerView>(R.id.notesRecyclerView)
        noteAdapter = NoteAdapter(emptyList()) { noteId -> deleteNote(noteId) }
        recyclerView.apply {
            adapter = noteAdapter
            layoutManager = LinearLayoutManager(this@MainActivity)
        }

        findViewById<FrameLayout>(R.id.logoutButton).setOnClickListener {
            val intent = Intent(this, LoginActivity::class.java)
            startActivity(intent)
        }

        val retrofit = Retrofit.Builder().baseUrl("http://217.71.129.139:5428/")
            .addConverterFactory(GsonConverterFactory.create()).build()
        noteApi = retrofit.create(NoteApi::class.java)
        val login = intent.getStringExtra("LOGIN") ?: ""
        val password = intent.getStringExtra("PASSWORD") ?: ""

        if (login.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Нет учетных данных для авторизации", Toast.LENGTH_SHORT).show()
            return
        }

        val credentials = "$login:$password"
        authHeader = "Basic " + Base64.encodeToString(credentials.toByteArray(), Base64.NO_WRAP)

        findViewById<ImageButton>(R.id.refreshButton).setOnClickListener {
            try {
                Toast.makeText(
                    this@MainActivity, "Список задач\nуспешно обновлен", Toast.LENGTH_SHORT
                ).show()
                loadNotes()
            } catch (e: Exception) {
                Toast.makeText(
                    this@MainActivity, "Ошибка обновления: ${e.message}", Toast.LENGTH_SHORT
                ).show()
            }
        }

        findViewById<ImageButton>(R.id.addButton).setOnClickListener {
            showAddNoteDialog()
        }

        loadNotes()
    }

    private fun loadNotes() {
        lifecycleScope.launch {
            try {
                val response = withContext(Dispatchers.IO) { noteApi.getNotes(authHeader) }
                if (response.isSuccessful) {
                    val notes: List<Note> = response.body() ?: emptyList()
                    noteAdapter.updateNotes(notes)
                } else {
                    Toast.makeText(
                        this@MainActivity, "Ошибка: ${response.code()}", Toast.LENGTH_SHORT
                    ).show()
                }
            } catch (e: Exception) {
                Toast.makeText(
                    this@MainActivity, "Ошибка запроса: ${e.message}", Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    private fun deleteNote(noteId: Int) {
        lifecycleScope.launch {
            try {
                val response =
                    withContext(Dispatchers.IO) { noteApi.deleteNote(authHeader, noteId) }
                if (response.isSuccessful) {
                    Toast.makeText(this@MainActivity, "Задача удалена", Toast.LENGTH_SHORT).show()
                    loadNotes()
                } else {
                    Toast.makeText(
                        this@MainActivity, "Ошибка удаления: ${response.code()}", Toast.LENGTH_SHORT
                    ).show()
                }
            } catch (e: Exception) {
                Toast.makeText(
                    this@MainActivity, "Ошибка запроса: ${e.message}", Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    private fun showAddNoteDialog() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_add_note, null)
        val editText = dialogView.findViewById<EditText>(R.id.editTextNote)
        val dialog = AlertDialog.Builder(this).setTitle("Добавить задачу").setView(dialogView)
            .setPositiveButton("Добавить") { _, _ ->
                val noteText = editText.text.toString().trim()
                if (noteText.isNotEmpty()) {
                    addNewNote(noteText)
                } else {
                    Toast.makeText(this, "Задача не может быть пустой", Toast.LENGTH_SHORT).show()
                }
            }.setNegativeButton("Отмена", null).create()

        dialog.show()
    }

    private fun addNewNote(noteText: String) {
        lifecycleScope.launch {
            try {
                val newNote = Note(id = 0, note = noteText)
                val response: Response<Unit> = withContext(Dispatchers.IO) {
                    noteApi.addNote(authHeader, newNote)
                }

                if (response.isSuccessful) {
                    Toast.makeText(this@MainActivity, "Задача добавлена", Toast.LENGTH_SHORT).show()
                    loadNotes()
                } else {
                    Toast.makeText(
                        this@MainActivity,
                        "Ошибка добавления: ${response.code()}",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            } catch (e: Exception) {
                Toast.makeText(
                    this@MainActivity, "Ошибка запроса: ${e.message}", Toast.LENGTH_SHORT
                ).show()
            }
        }
    }
}
