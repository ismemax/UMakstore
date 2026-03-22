package com.example.umakstore

import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.umakstore/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getStorageInfo") {
                try {
                    val path = Environment.getDataDirectory()
                    val stat = StatFs(path.path)
                    val blockSize = stat.blockSizeLong
                    val totalBlocks = stat.blockCountLong
                    val availableBlocks = stat.availableBlocksLong

                    val totalSpace = totalBlocks * blockSize
                    val freeSpace = availableBlocks * blockSize

                    val storageMap = mapOf(
                        "totalSpace" to totalSpace,
                        "freeSpace" to freeSpace
                    )
                    result.success(storageMap)
                } catch (e: Exception) {
                    result.error("STORAGE_ERROR", "Failed to get store info: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
