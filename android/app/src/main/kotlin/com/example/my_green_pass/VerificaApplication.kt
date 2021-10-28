package com.example.my_green_pass

import android.app.Application
import androidx.hilt.work.HiltWorkerFactory
import androidx.work.*
import dagger.hilt.android.HiltAndroidApp
import it.ministerodellasalute.verificaC19sdk.worker.LoadKeysWorker
import java.util.concurrent.TimeUnit
import javax.inject.Inject

@HiltAndroidApp
class VerificaApplication : Application(), Configuration.Provider {

    @Inject
    lateinit var workerFactory: HiltWorkerFactory

    override fun getWorkManagerConfiguration(): Configuration {
        return Configuration.Builder()
            .setWorkerFactory(workerFactory)
            .build()
    }

    override fun onCreate() {
        super.onCreate()
        setWorkManager()
    }

    /**
     *
     * This method sets and configures the work manager as periodic. The work manager is meant to
     * be triggered with a repeat interval of one day.
     *
     */

    private fun setWorkManager() {
        val uploadWorkRequest: WorkRequest =
            PeriodicWorkRequestBuilder<LoadKeysWorker>(1, TimeUnit.DAYS)
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
                .build()
        WorkManager
            .getInstance(this)
            .enqueueUniquePeriodicWork(
                "LoadKeysWorker",
                ExistingPeriodicWorkPolicy.REPLACE,
                uploadWorkRequest as PeriodicWorkRequest
            )
    }
}