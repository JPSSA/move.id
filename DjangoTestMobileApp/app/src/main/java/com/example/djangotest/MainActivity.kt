package com.example.djangotest

import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.djangotest.R
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.create
import retrofit2.http.Body
import retrofit2.http.POST

class MainActivity : AppCompatActivity() {

    interface ApiService {
        @POST("basic/") // This URL is relative to the base URL specified in Retrofit builder
        fun sendData(@Body data: Map<String, String>): Call<Map<String, String>>
    }

    private lateinit var apiService: ApiService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        
        val retrofit = Retrofit.Builder()
            // METAM AQUI O VOSSO IPV4
            .baseUrl("http://192.168.1.75:8000/") // Replace with your Django backend base URL
            .addConverterFactory(GsonConverterFactory.create())
            .build()

        apiService = retrofit.create<ApiService>(ApiService::class.java)


        val postButton: Button = findViewById(R.id.postButton)


        postButton.setOnClickListener {

            val data = mapOf(
                "first_name" to "John",
                "last_name" to "Doe"
            )


            apiService.sendData(data).enqueue(object : Callback<Map<String, String>> {
                override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                    val responseBody = response.body()
                    if (response.isSuccessful && responseBody != null) {
                        val message = "POST request successful: ${responseBody["message"]}"
                        Log.d("ya mano", responseBody.toString())
                        Toast.makeText(this@MainActivity, message, Toast.LENGTH_SHORT).show()
                    } else {
                        Log.d("ya mano","fodeu1")
                        Toast.makeText(this@MainActivity, "Failed to send POST request", Toast.LENGTH_SHORT).show()
                    }
                }

                override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                    Log.d("ya mano","fodeu2")
                    Toast.makeText(this@MainActivity, "Error: ${t.message}", Toast.LENGTH_SHORT).show()
                }
            })
        }
    }
}
