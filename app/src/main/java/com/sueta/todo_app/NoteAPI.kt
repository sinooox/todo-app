package com.sueta.todo_app

import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Path

interface NoteApi {
    @GET("notes")
    suspend fun getNotes(
        @Header("Authorization") auth: String
    ): Response<List<Note>>

    @DELETE("notes/{id}")
    suspend fun deleteNote(
        @Header("Authorization") auth: String,
        @Path("id") noteId: Int
    ): Response<Unit>

    @POST("notes")
    suspend fun addNote(
        @Header("Authorization") auth: String,
        @Body newNote: Note
    ): Response<Unit>
}
